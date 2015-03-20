using EPiServer.Shell.Modules;

namespace EPiServer.InstantTemplates
{
    public class TemplatesModule : ShellModule
    {
        public TemplatesModule(string name, string routeBasePath, string resourceBasePath)
            : base(name, routeBasePath, resourceBasePath)
        {
            string a = "";
        }

        public override ModuleViewModel CreateViewModel(ModuleTable moduleTable, EPiServer.Framework.Web.Resources.IClientResourceService clientResourceService)
        {
            var viewModel = new TemplatesModuleViewModel(this);

            viewModel.TemplatesRoot = TemplatesInit.TemplateRoot;

            return viewModel;
        }
    }
}