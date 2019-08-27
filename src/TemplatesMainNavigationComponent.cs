// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using EPiServer.Cms.Shell.UI.Components;
using EPiServer.Shell;
using EPiServer.Shell.ViewComposition;

namespace InstantTemplates
{
    [Component]
    public class TemplatesMainNavigationComponent : ComponentDefinitionBase
    {
        public TemplatesMainNavigationComponent() : base("instantTemplates/templatesWidget")
        {
            Categories = new string[] { "content" };
            //LanguagePath = "/episerver/cms/components/templates";
            Title = "Templates";
            SortOrder = 102;
            PlugInAreas = new string[] { PlugInArea.AssetsDefaultGroup };
            Settings.Add(new Setting("repositoryKey", TemplatesRepositoryDescriptor.RepositoryKey));
            Description = "Allows editors to easily create their own templates from within EPiServer edit mode.";
        }
    }
}