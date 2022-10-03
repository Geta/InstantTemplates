// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

using EPiServer.InstantTemplates;
using Microsoft.Extensions.DependencyInjection;

// ReSharper disable once CheckNamespace
namespace Microsoft.AspNetCore.Builder
{
    public static class ApplicationBuilderExtensions
    {
        public static IApplicationBuilder UseInstantTemplates(this IApplicationBuilder app)
        {
            var services = app.ApplicationServices;

            services.GetRequiredService<TemplatesInitializer>().Initialize();

            return app;
        }
    }
}
