// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using System;
using System.Collections.Generic;
using EPiServer.Core;
using EPiServer.ServiceLocation;
using EPiServer.Shell;

namespace EPiServer.InstantTemplates
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
                return new[]
                {
                    typeof(ContentFolder)
                };
            }
        }

        public override IEnumerable<Type> ContainedTypes
        {
            get
            {
                return new[]
                {
                    typeof(ContentFolder),
                    typeof(BlockData),
                    typeof(PageData)
                };
            }
        }

        public override IEnumerable<string> MainViews { get { return new string[] { }; } }

        public override IEnumerable<Type> CreatableTypes
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
                return new[] { TemplatesInitialization.TemplateRoot };
            }
        }

        public bool EnableContextualContent { get { return true; } }
    }
}