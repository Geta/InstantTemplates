// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using EPiServer.Shell.Modules;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.DependencyInjection.Extensions;
using System;
using System.Linq;
using EPiServer.InstantTemplates;
using EPiServer.Shell;

// ReSharper disable once CheckNamespace
namespace Microsoft.Extensions.DependencyInjection
{
    /// <summary>
    /// Contains convenient extension methods to add InstantTemplates to application
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        private static readonly Action<AuthorizationPolicyBuilder> DefaultEditPolicy = p => p.RequireRole("CmsEditors", "WebEditors");

        /// <summary>
        /// Convenient method to add InstantTemplates.
        /// </summary>
        /// <param name="services">the services.</param>
        /// <returns>The configured service container</returns>
        public static IServiceCollection AddInstantTemplates(this IServiceCollection services)
        {
            return AddInstantTemplates(services, DefaultEditPolicy);
        }

        /// <summary>
        /// Convenient method to add InstantTemplates.
        /// </summary>
        /// <param name="services">the services.</param>
        /// <returns>The configured service container</returns>
        public static IServiceCollection AddInstantTemplates(this IServiceCollection services, Action<AuthorizationPolicyBuilder> configureEditPolicy)
        {
            services.TryAddSingleton<TemplatesInitializer>();
            services.AddEmbeddedLocalization<TemplatesInitializer>();

            services.AddAuthorization(options =>
            {
                options.AddPolicy("instanttemplates:edit", configureEditPolicy);
            });

            services.Configure<ProtectedModuleOptions>(modules =>
            {
                if (!modules.Items.Any(module => module.Name.Equals("InstantTemplates", StringComparison.OrdinalIgnoreCase)))
                {
                    modules.Items.Add(new ModuleDetails { Name = "InstantTemplates" });
                }
            });

            return services;
        }
    }
}
