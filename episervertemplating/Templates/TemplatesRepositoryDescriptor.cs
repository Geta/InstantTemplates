using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using EPiServer.Cms.Shell.UI.CompositeViews;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using EPiServer.Shell;

namespace EPiServerTemplating.Templates
{
    [ServiceConfiguration(typeof(IContentRepositoryDescriptor))]
    public class TemplatesRepositoryDescriptor : ContentRepositoryDescriptorBase
    {
        public static string RepositoryKey
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

        public override IEnumerable<Type> MainNavigationTypes
        {
            get
            {
                return new System.Type[]
				{
					typeof(ContentFolder)
				};
            }
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

        public override IEnumerable<string> MainViews { get { return new string[] {  }; } }

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
}