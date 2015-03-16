using EPiServer;
using EPiServer.Cms.Shell.UI.UIDescriptors;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using EPiServer.Shell;
using EPiServer.Shell.ViewComposition;
using EPiServerTemplating.Templates;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Codemania.LocalMediaProvider
{
    [Component]
    public class TemplatesMainNavigationComponent : ComponentDefinitionBase
    {
        public TemplatesMainNavigationComponent()
            : base("epi-cms/widget/HierarchicalList")
        {
            Categories = new string[] { "content" };
            LanguagePath = "/episerver/cms/components/templates";
            SortOrder = 102;
            PlugInAreas = new string[] { PlugInArea.AssetsDefaultGroup };
            Settings.Add(new Setting("repositoryKey", TemplatesRepositoryDescriptor.RepositoryKey));
        }
    }
}