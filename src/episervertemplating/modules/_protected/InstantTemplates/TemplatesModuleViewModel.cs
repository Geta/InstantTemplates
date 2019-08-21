// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using EPiServer.Core;
using EPiServer.Framework.Web.Resources;
using EPiServer.ServiceLocation;
using EPiServer.Shell.Modules;

namespace EPiServer.InstantTemplates
{
    public class TemplatesModuleViewModel : ModuleViewModel
    {
        public TemplatesModuleViewModel(ShellModule module)
            : base(module, ServiceLocator.Current.GetInstance<IClientResourceService>())
        {

        }
        public ContentReference TemplatesRoot { get; set; }
    }
}