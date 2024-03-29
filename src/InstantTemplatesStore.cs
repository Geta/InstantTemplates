﻿// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using System.Globalization;
using System.Linq;
using System.Threading;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.DataAccess;
using EPiServer.Globalization;
using EPiServer.Security;
using EPiServer.ServiceLocation;
using EPiServer.Shell.Services.Rest;
using Microsoft.AspNetCore.Mvc;

namespace EPiServer.InstantTemplates
{
    [RestStore("instanttemplates")]
    public class InstantTemplatesStore : RestControllerBase
    {
        private readonly IContentRepository _contentRepository;
        private readonly IContentTypeRepository _contentTypeRepository;
        private readonly ContentTypeAvailabilityService _contentTypeAvailabilityService;

        public InstantTemplatesStore(IContentRepository contentRepository, IContentTypeRepository contentTypeRepository, ContentTypeAvailabilityService contentTypeAvailabilityService)
        {
            this._contentRepository = contentRepository;
            this._contentTypeRepository = contentTypeRepository;
            this._contentTypeAvailabilityService = contentTypeAvailabilityService;
        }

        public RestResult Get(string id)
        {
            string parentLink = id;

            var allContentReferences = this._contentRepository.GetDescendents(TemplatesInitializer.TemplateRoot);

            // Get all templates for current language
            CultureInfo currentCulture = ContentLanguage.PreferredCulture;
            if (currentCulture == null)
                currentCulture = Thread.CurrentThread.CurrentCulture;
            var descendents = _contentRepository.GetItems(allContentReferences, currentCulture);

            var folderContentType = this._contentTypeRepository.Load(typeof(ContentFolder));
            descendents = descendents.Where(c => c.ContentTypeID != folderContentType.ID);

            // Make sure the user has access to it
            descendents = descendents.Where(content => content.QueryDistinctAccess(AccessLevel.Create));

            var parentContent = this._contentRepository.Get<IContent>(new ContentReference(parentLink));

            if (parentContent is PageData && !((PageData)parentContent).ACL.HasAccess(PrincipalInfo.CurrentPrincipal, AccessLevel.Create))
            {
                return Rest("You don't have access to create content");
            }

            var contentType = this._contentTypeRepository.Load(parentContent.ContentTypeID);

            var settings = this._contentTypeAvailabilityService.GetSetting(contentType.Name);
            
            // Show only published content
            var publishedStateAssessor = ServiceLocator.Current.GetInstance<IPublishedStateAssessor>();
            descendents = descendents.Where(content => publishedStateAssessor.IsPublished(content, PagePublishedStatus.Published));

            var result = descendents
                           .Select(content => new
                            {
                                name = content.Name,
                                contentLink = content.ContentLink.ID.ToString(CultureInfo.InvariantCulture),
                                parentLink = parentContent.ContentLink.ID.ToString(CultureInfo.InvariantCulture),
                                ContentType = this._contentTypeRepository.Load(content.ContentTypeID),
                                localizedDescription = this._contentTypeRepository.Load(content.ContentTypeID).LocalizedDescription
                            });

            if (settings.Availability == Availability.Specific)
            {
                var allowedContentTypes = settings.AllowedContentTypeNames.Select(name => this._contentTypeRepository.Load(name));

                result = result.Where(content => allowedContentTypes.Contains(content.ContentType));
            }

            // access right of page types
            result = result.Where(content => content.ContentType.ACL.HasAccess(PrincipalInfo.CurrentPrincipal, AccessLevel.Create));

            // clean up response and remove the ContentType property since it's causing serializing problems
            var response = result.Select(item => new
            {
                item.name,
                item.contentLink,
                item.parentLink,
                item.localizedDescription 
            });

            return Rest(response);
        }

        public RestResult Post([FromBody] AddRequest request)
        {
            var templateBlockData = this._contentRepository.Get<ContentData>(new ContentReference(request.templateLink)) as BlockData;

            ContentReference contentLink;

            if (templateBlockData != null)
            {
                var assetsFolderForPage = ServiceLocator.Current
                    .GetInstance<ContentAssetHelper>()
                    .GetOrCreateAssetFolder(new ContentReference(request.parentLink));

                contentLink = this._contentRepository.Copy(new ContentReference(request.templateLink),
                    assetsFolderForPage.ContentLink, AccessLevel.Edit, AccessLevel.Edit, false);
            }
            else
            {
                contentLink = this._contentRepository.Copy(new ContentReference(request.templateLink),
                    new ContentReference(request.parentLink), AccessLevel.Edit, AccessLevel.Edit, false);
            }

            var temp = this._contentRepository.Get<ContentData>(contentLink).CreateWritableClone();

            ((IContent)temp).Name = request.name;

            this._contentRepository.Save((IContent)temp, SaveAction.ForceCurrentVersion);
            return Rest(contentLink.ID);
        }

        public class AddRequest
        {
            public string templateLink { get; set; }
            public string parentLink { get; set; }
            public string name { get; set; }
        }
    }
}