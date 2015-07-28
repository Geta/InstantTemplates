using System;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.Framework;
using EPiServer.Framework.Initialization;
using EPiServer.ServiceLocation;
using InitializationModule = EPiServer.Web.InitializationModule;

namespace EPiServer.InstantTemplates
{
    [ModuleDependency(typeof(InitializationModule))]
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
        }

        public void Uninitialize(InitializationEngine context)
        {
            //Add uninitialization logic
        }
    }
}