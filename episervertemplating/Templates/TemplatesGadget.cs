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
    [ServiceConfiguration(typeof(IContentRepositoryDescriptor))]
    public class TemplatesRepositoryDescriptor : BlockRepositoryDescriptor
    {
        private IContentProviderManager _providerManager;
        public TemplatesRepositoryDescriptor(IContentProviderManager providerManager)
        {
            _providerManager = providerManager;
        }

        public static new string RepositoryKey
        {
            get { return "templates"; }
        }

        public override string Key
        {
            get
            {
                return RepositoryKey;
            }
        }

        public override string Name
        {
            get { return "Templates"; }
        }
        public override System.Collections.Generic.IEnumerable<System.Type> ContainedTypes
        {
            get
            {
                return new System.Type[]
				{
					typeof(ContentFolder),
					typeof(BlockData),
                    typeof(PageData)
				};
            }
        }
        public override System.Collections.Generic.IEnumerable<System.Type> CreatableTypes
        {
            get
            {
                return new System.Type[]
				{
					typeof(BlockData), typeof(PageData)
				};
            }
        }
        public override IEnumerable<ContentReference> Roots
        {
            get
            {
                return new ContentReference[] { TemplatesInit.TemplateRoot };
            }
        }
    }

    [Component]
    public class TemplatesMainNavigationComponent : ComponentDefinitionBase
    {
        public TemplatesMainNavigationComponent()
            : base("epi-cms.component.SharedBlocks")
        {
            Categories = new string[] { "content" };
            LanguagePath = "/episerver/cms/components/templates";
            SortOrder = 102;
            PlugInAreas = new string[] { PlugInArea.AssetsDefaultGroup };
            Settings.Add(new Setting("repositoryKey", TemplatesRepositoryDescriptor.RepositoryKey));
        }
    }
}