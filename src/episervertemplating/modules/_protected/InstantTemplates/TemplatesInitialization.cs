using System;
using System.Web.Mvc;
using System.Web.Routing;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.Framework;
using EPiServer.Framework.Initialization;
using EPiServer.ServiceLocation;

namespace EPiServer.InstantTemplates
{
    [ModuleDependency(typeof(Web.InitializationModule))]
    public class TemplatesInitialization : IInitializableModule
    {
        public const string TemplateRootName = "TemplateRoot";
        public static Guid TemplateRootGuid = new Guid("98ed413d-d7b5-4fbf-92a6-120d850fe610");

        public static ContentReference TemplateRoot;

        public void Initialize(InitializationEngine context)
        {
            var contentRootService = ServiceLocator.Current.GetInstance<ContentRootService>();

            contentRootService.Register<ContentFolder>(TemplateRootName, TemplateRootGuid, ContentReference.RootPage);

            TemplateRoot = contentRootService.Get(TemplateRootName);

            RouteTable.Routes.MapRoute(
                "InstantTemplates",
                "instanttemplates/{action}",
                new { action = "Query", controller = "InstantTemplates" });
        }

        public void Preload(string[] parameters) { }

        public void Uninitialize(InitializationEngine context)
        {
            //Add uninitialization logic
        }
    }
}