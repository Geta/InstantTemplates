using System.Globalization;
using System.Linq;
using System.Web.Mvc;
using EPiServer;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.DataAccess;
using EPiServer.Security;

namespace EPiServerTemplating.Controllers
{
    public class InstantTemplateController : Controller
    {
        private readonly IContentRepository _contentRepository;
        private readonly IContentTypeRepository _contentTypeRepository;
        private readonly ContentTypeAvailabilityService _contentTypeAvailabilityService;

        public InstantTemplateController(IContentRepository contentRepository, IContentTypeRepository contentTypeRepository, ContentTypeAvailabilityService contentTypeAvailabilityService)
        {
            this._contentRepository = contentRepository;
            this._contentTypeRepository = contentTypeRepository;
            this._contentTypeAvailabilityService = contentTypeAvailabilityService;
        }

        [Authorize(Roles = "Administrators, WebAdmins, WebEditors")]
        [HttpPost]
        public ActionResult Query(string templatesRoot, string parentLink)
        {
            var children = this._contentRepository.GetChildren<IContent>(new ContentReference(templatesRoot));

            var parentContent = this._contentRepository.Get<PageData>(new ContentReference(parentLink));

            var contentType = this._contentTypeRepository.Load(parentContent.ContentTypeID);

            var settings = this._contentTypeAvailabilityService.GetSetting(contentType.Name);

            var response = children.Select(content => new
            {
                name = content.Name, 
                contentLink = content.ContentLink.ID.ToString(CultureInfo.InvariantCulture),
                contentTypeId = content.ContentTypeID
            });

            if (settings.Availability == Availability.Specific)
            {
                var allowedContentTypes = settings.AllowedContentTypeNames.Select(name => this._contentTypeRepository.Load(name).ID);

                response = response.Where(content => allowedContentTypes.Contains(content.contentTypeId));
            }

            // access right of page types
            // access right of content creation

            return Json(response);
        }

        [Authorize(Roles = "Administrators, WebAdmins, WebEditors")]
        [HttpPost]
        public ActionResult Create(string templateLink, string parentLink, string name)
        {
            var contentLink = this._contentRepository.Copy(new ContentReference(templateLink),
                new ContentReference(parentLink), AccessLevel.Edit, AccessLevel.Edit, false);

            var temp = this._contentRepository.Get<ContentData>(contentLink).CreateWritableClone();

            ((IContent) temp).Name = name;

            this._contentRepository.Save((IContent) temp, SaveAction.ForceCurrentVersion);

            return Json(contentLink.ID);
        }
    }
}