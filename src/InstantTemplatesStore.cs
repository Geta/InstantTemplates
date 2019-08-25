// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using System.Globalization;
using System.Linq;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.DataAccess;
using EPiServer.Security;
using EPiServer.ServiceLocation;
using EPiServer.Shell.Services.Rest;

namespace EPiServer.InstantTemplates
{
    [RestStore("instanttemplates")]
    public class InstantTemplatesStore : RestControllerBase
    {
        private readonly IContentRepository _contentRepository;
        private readonly IContentTypeRepository _contentTypeRepository;
        private readonly ContentTypeAvailabilityService _contentTypeAvailabilityService;

        public InstantTemplatesStore() : this(ServiceLocator.Current.GetInstance<IContentRepository>(), ServiceLocator.Current.GetInstance<IContentTypeRepository>(), ServiceLocator.Current.GetInstance<ContentTypeAvailabilityService>())
        {
        }

        public InstantTemplatesStore(IContentRepository contentRepository, IContentTypeRepository contentTypeRepository, ContentTypeAvailabilityService contentTypeAvailabilityService)
        {
            this._contentRepository = contentRepository;
            this._contentTypeRepository = contentTypeRepository;
            this._contentTypeAvailabilityService = contentTypeAvailabilityService;
        }

        public RestResult Get(string id)
        {
            string parentLink = id;

            var allContentReferences = this._contentRepository.GetDescendents(TemplatesInitialization.TemplateRoot);

            var descendents = allContentReferences.Select(contentReference => _contentRepository.Get<IContent>(contentReference));

            var folderContentType = this._contentTypeRepository.Load(typeof(ContentFolder));
            descendents = descendents.Where(c => c.ContentTypeID != folderContentType.ID);

            // make sure the user has access to it
            descendents = descendents.Where(content => content.QueryDistinctAccess(AccessLevel.Create));

            var parentContent = this._contentRepository.Get<IContent>(new ContentReference(parentLink));

            if (parentContent is PageData && !((PageData)parentContent).ACL.HasAccess(PrincipalInfo.CurrentPrincipal, AccessLevel.Create))
            {
                return Rest("You don't have access to create content");
            }

            var contentType = this._contentTypeRepository.Load(parentContent.ContentTypeID);

            var settings = this._contentTypeAvailabilityService.GetSetting(contentType.Name);

            var response = descendents.Select(content => new
            {
                name = content.Name,
                contentLink = content.ContentLink.ID.ToString(CultureInfo.InvariantCulture),
                ContentType = this._contentTypeRepository.Load(content.ContentTypeID),
                localizedDescription = this._contentTypeRepository.Load(content.ContentTypeID).LocalizedDescription
            });

            if (settings.Availability == Availability.Specific)
            {
                var allowedContentTypes = settings.AllowedContentTypeNames.Select(name => this._contentTypeRepository.Load(name));

                response = response.Where(content => allowedContentTypes.Contains(content.ContentType));
            }

            // access right of page types
            response = response.Where(content => content.ContentType.ACL.HasAccess(PrincipalInfo.CurrentPrincipal, AccessLevel.Create));

            return Rest(response);
        }

        public RestResult Post(string templateLink, string parentLink, string name)
        {
            var contentLink = this._contentRepository.Copy(new ContentReference(templateLink),
                new ContentReference(parentLink), AccessLevel.Edit, AccessLevel.Edit, false);

            var temp = this._contentRepository.Get<ContentData>(contentLink).CreateWritableClone();

            ((IContent)temp).Name = name;

            this._contentRepository.Save((IContent)temp, SaveAction.ForceCurrentVersion);
            return Rest(contentLink.ID);
        }
    }
}