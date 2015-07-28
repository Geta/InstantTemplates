using System;
using System.Security.Principal;
using EPiServer.Shell;
using EPiServer.Shell.ViewComposition;

namespace EPiServer.InstantTemplates
{
    [ViewTransformer]
    public class TemplatesViewTransformer : IViewTransformer
    {
        public int SortOrder => 10010;

        private static bool isRegistered = false;

        public void TransformView(ICompositeView view, IPrincipal principal)
        {
            CheckForTemplatesCompontent(view.RootContainer);

            if (!isRegistered)
            {
                // manually register
                var container = view.RootContainer.FindContainerByPlugInArea(PlugInArea.AssetsDefaultGroup);
                container.Add(new TemplatesMainNavigationComponent().CreateComponent());
            }
        }

        private void CheckForTemplatesCompontent(IContainer parentContainer)
        {
            foreach (IComponent component in parentContainer.Components)
            {
                IContainer childContainer = component as IContainer;

                if (component.ModuleName.Equals("InstantTemplates", StringComparison.OrdinalIgnoreCase))
                {
                    isRegistered = true;
                    return;
                }

                if (childContainer != null)
                {
                    CheckForTemplatesCompontent(childContainer);
                }
            }
        }
    }
}