# EPiServer Instant Templates

![](http://tc.geta.no/app/rest/builds/buildType:(id:GetaPackages_GetaInstantTemplates_00ci),branch:master/statusIcon)

## Description

Allows editors to create their own re-usable templates directly from within EPiServer edit mode.

More information:

- https://getadigital.com/no/blogg/episerver-instant-templates/

## Features

- Create blocks and pages from a template.

## How to get started?

```
Install-Package InstantTemplates
```

Add InstantTemplates in `Startup.cs`

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddInstantTemplates();
}
``` 

Next, initialize InstantTemplates in the Configure method. This will add InstantTemplates to your application and Optimizely.
```csharp
public void Configure(IApplicationBuilder app)
{
    app.UseInstantTemplates();
    ...
}
```

When you start the site and go to Edit Mode you'll be able to add the InstantTemplates Gadget there, create new templates based on a block or page (this can be structure into folders etc), and then use the templates in a similar fashion as when creating a new page in the content tree (there's a new from template option there now).

## Changelog

[Changelog](CHANGELOG.md)

## Disclaimer

The code used to extend the editor interface is not an approach supported by EPiServer and it is not guaranteed to work with future releases. Please use at your own discretion. We will however do our best to keep it up-to-date with the latest version of EPiServer

## Package maintainers

https://github.com/frederikvig