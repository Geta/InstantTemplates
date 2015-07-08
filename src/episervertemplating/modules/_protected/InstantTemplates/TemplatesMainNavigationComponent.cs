using EPiServer.Shell;
using EPiServer.Shell.ViewComposition;

namespace EPiServer.InstantTemplates
{
    [Component]
    public class TemplatesMainNavigationComponent : ComponentDefinitionBase
    {
        public TemplatesMainNavigationComponent()
            : base("epi-cms/widget/HierarchicalList")
        {
            Categories = new string[] { "content" };
            //LanguagePath = "/episerver/cms/components/templates";
            Title = "Templates";
            SortOrder = 102;
            PlugInAreas = new string[] { PlugInArea.AssetsDefaultGroup };
            Settings.Add(new Setting("repositoryKey", TemplatesRepositoryDescriptor.RepositoryKey));
        }
    }
}