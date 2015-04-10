using System.Web.Mvc;
using EPiServer;
using EPiServer.Core;
using EPiServer.DataAccess;
using EPiServer.Security;

namespace EPiServerTemplating.Controllers
{
    public class InstantTemplateController : Controller
    {
        private readonly IContentRepository _contentRepository;

        public InstantTemplateController(IContentRepository contentRepository)
        {
            this._contentRepository = contentRepository;
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