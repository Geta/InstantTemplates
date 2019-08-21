// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using System;
using System.Linq;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.Framework;
using EPiServer.Framework.Initialization;
using EPiServer.Security;
using EPiServer.ServiceLocation;
using InitializationModule = EPiServer.Web.InitializationModule;

namespace EPiServer.InstantTemplates
{
    [ModuleDependency(typeof(InitializationModule))]
    public class TemplatesInitialization : IInitializableModule
    {
        public const string TemplateRootName = "TemplateRoot";
        public static Guid TemplateRootGuid = new Guid("98ed413d-d7b5-4fbf-92a6-120d850fe610");

        public static ContentReference TemplateRoot;

        public void Initialize(InitializationEngine context)
        {
            var contentRootService = ServiceLocator.Current.GetInstance<ContentRootService>();
            var contentSecurityRepository = ServiceLocator.Current.GetInstance<IContentSecurityRepository>();

            contentRootService.Register<ContentFolder>(TemplateRootName, TemplateRootGuid, ContentReference.RootPage);

            TemplateRoot = contentRootService.Get(TemplateRootName);

            // make sure everyone is removed from the public list
            var securityDescriptor = contentSecurityRepository.Get(TemplateRoot).CreateWritableClone() as IContentSecurityDescriptor;

            if (securityDescriptor != null)
            {
                securityDescriptor.IsInherited = false;

                // remove everyone group
                var everyoneEntry = securityDescriptor.Entries.FirstOrDefault(e => e.Name.Equals("everyone", StringComparison.InvariantCultureIgnoreCase));

                if (everyoneEntry != null)
                {
                    securityDescriptor.RemoveEntry(everyoneEntry);
                    contentSecurityRepository.Save(TemplateRoot, securityDescriptor, SecuritySaveType.Replace);
                }
            }
        }

        public void Uninitialize(InitializationEngine context)
        {
            //Add uninitialization logic
        }
    }
}