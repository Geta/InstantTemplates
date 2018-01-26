using System.Web.Mvc;
using EPiServer.Framework;
using EPiServer.Framework.Initialization;
using EPiServer.ServiceLocation;
using EPiServerTemplating.Business.Rendering;
using EPiServerTemplating.Helpers;
using EPiServer.Web.Mvc;
using EPiServer.Web.Mvc.Html;
using StructureMap;

namespace EPiServerTemplating.Business.Initialization
{
    [InitializableModule]
    [ModuleDependency(typeof(EPiServer.Web.InitializationModule))]
    public class DependencyResolverInitialization : IConfigurableModule
    {
        public void ConfigureContainer(ServiceConfigurationContext context)
        {
            var container = context.StructureMap();
            container.Configure(x =>
            {
                x.For<IContentRenderer>().Use<ErrorHandlingContentRenderer>();
                x.For<ContentAreaRenderer>().Use<AlloyContentAreaRenderer>();
            });

            DependencyResolver.SetResolver(new StructureMapDependencyResolver(container));
        }

        private static void ConfigureContainer(ConfigurationExpression container)
        {
            //Swap out the default ContentRenderer for our custom
            container.For<IContentRenderer>().Use<ErrorHandlingContentRenderer>();
            container.For<ContentAreaRenderer>().Use<AlloyContentAreaRenderer>();

            //Implementations for custom interfaces can be registered here.
        }

        public void Initialize(InitializationEngine context)
        {
        }

        public void Uninitialize(InitializationEngine context)
        {
        }

        public void Preload(string[] parameters)
        {
        }
    }
}
