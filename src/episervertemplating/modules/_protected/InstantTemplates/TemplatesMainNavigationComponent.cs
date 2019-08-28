using EPiServer.Cms.Shell.UI.Components;
using EPiServer.Shell;
using EPiServer.Shell.ViewComposition;

namespace EPiServer.InstantTemplates
{
    [Component]
    public class TemplatesMainNavigationComponent : ComponentDefinitionBase
    {

        public TemplatesMainNavigationComponent() : base("instantTemplates/templatesWidget")
        {
            PlugInAreas = new string[] { PlugInArea.AssetsDefaultGroup };
            Categories = new string[] { "content" };
            SortOrder = 102;
            LanguagePath = "/episerver/cms/views/templates";
            Title = "Templates";
            Settings.Add(new Setting("repositoryKey", TemplatesRepositoryDescriptor.RepositoryKey));
            Description = "Allows editors to easily create their own templates from within EPiServer edit mode.";
        }
    }
}