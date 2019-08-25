// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

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
            var viewModel = new TemplatesModuleViewModel(this) { TemplatesRoot = TemplatesInitialization.TemplateRoot };

            return viewModel;
        }
    }
}