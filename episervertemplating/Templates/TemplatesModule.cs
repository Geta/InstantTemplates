using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using EPiServer.Shell.Modules;

namespace EPiServerTemplating.Templates
{
    public class TemplatesModule : ShellModule
    {
        public TemplatesModule(string name, string routeBasePath, string resourceBasePath)
            : base(name, routeBasePath, resourceBasePath)
        { }

        public override ModuleViewModel CreateViewModel(ModuleTable moduleTable, EPiServer.Framework.Web.Resources.IClientResourceService clientResourceService)
        {
            var viewModel = new TemplatesModuleViewModel(this);

            viewModel.TemplatesRoot = TemplatesInit.TemplateRoot;

            return viewModel;
        }
    }
}