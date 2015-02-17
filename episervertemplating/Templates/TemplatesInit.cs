using System;
using System.Linq;
using EPiServer.Framework;
using EPiServer.Framework.Initialization;
using EPiServer.ServiceLocation;
using EPiServer;
using EPiServer.Core;

namespace EPiServerTemplating.Templates
{
    [InitializableModule]
    [ModuleDependency(typeof(EPiServer.Web.InitializationModule))]
    public class TemplatesInit : IInitializableModule
    {
        public const string ROOTNAME = "Templates";
        public static ContentReference TemplateRoot;
        public void Initialize(InitializationEngine context)
        {
            //Add initialization logic, this method is called once after CMS has been initialized
            //Ensure a template root exists
            var repo = ServiceLocator.Current.GetInstance<IContentRepository>();

            var cf = repo.GetChildren<ContentFolder>(ContentReference.RootPage).Where(cff => cff.Name==ROOTNAME).FirstOrDefault();

            if (cf == null)
            {
                cf = repo.GetDefault<ContentFolder>(ContentReference.RootPage);
                cf.Name = ROOTNAME;
                TemplateRoot = repo.Save(cf, EPiServer.DataAccess.SaveAction.Publish, EPiServer.Security.AccessLevel.NoAccess);
            }
            else TemplateRoot = cf.ContentLink;
            
        }

        public void Preload(string[] parameters) { }

        public void Uninitialize(InitializationEngine context)
        {
            //Add uninitialization logic
        }
    }
}