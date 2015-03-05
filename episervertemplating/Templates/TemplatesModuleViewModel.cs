using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using EPiServer.Core;
using EPiServer.Framework.Web.Resources;
using EPiServer.ServiceLocation;
using EPiServer.Shell.Modules;

namespace EPiServerTemplating.Templates
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