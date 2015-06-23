using EPiServer.Framework.Web.Resources;
using EPiServer.Shell.Modules;

namespace EPiServer.InstantTemplates
{
    public class TemplatesModule : ShellModule
    {
        public TemplatesModule(string name, string routeBasePath, string resourceBasePath) : base(name, routeBasePath, resourceBasePath)
        {
        }

        public override ModuleViewModel CreateViewModel(ModuleTable moduleTable, IClientResourceService clientResourceService)
        {
            var viewModel = new TemplatesModuleViewModel(this) { TemplatesRoot = TemplatesInit.TemplateRoot };

            return viewModel;
        }
    }
}