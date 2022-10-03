// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using System;
using System.Linq;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.Security;

namespace EPiServer.InstantTemplates
{
    public class TemplatesInitializer
    {
        private readonly ContentRootService _contentRootService;
        private readonly IContentSecurityRepository _contentSecurityRepository;

        public const string TemplateRootName = "TemplateRoot";
        public static Guid TemplateRootGuid = new Guid("98ed413d-d7b5-4fbf-92a6-120d850fe610");

        public static ContentReference TemplateRoot;

        public TemplatesInitializer(ContentRootService contentRootService, IContentSecurityRepository contentSecurityRepository)
        {
            _contentRootService = contentRootService;
            _contentSecurityRepository = contentSecurityRepository;
        }

        public void Initialize()
        {
            _contentRootService.Register<ContentFolder>(TemplateRootName, TemplateRootGuid, ContentReference.RootPage);

            TemplateRoot = _contentRootService.Get(TemplateRootName);

            // make sure everyone is removed from the public list
            var securityDescriptor = _contentSecurityRepository.Get(TemplateRoot).CreateWritableClone() as IContentSecurityDescriptor;

            if (securityDescriptor != null)
            {
                securityDescriptor.IsInherited = false;

                // remove everyone group
                var everyoneEntry = securityDescriptor.Entries.FirstOrDefault(e => e.Name.Equals("everyone", StringComparison.InvariantCultureIgnoreCase));

                if (everyoneEntry != null)
                {
                    securityDescriptor.RemoveEntry(everyoneEntry);
                    _contentSecurityRepository.Save(TemplateRoot, securityDescriptor, SecuritySaveType.Replace);
                }
            }
        }
    }
}