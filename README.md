# EPiServer Instant Templates

## Description

Allows editors to create their own re-usable templates directly from within EPiServer edit mode.
More information:

- https://getadigital.com/no/blogg/episerver-instant-templates/
- https://niteco.com/resources/blogs/Episerver-instant-templates-worth-trying-out/

## Installation

```
Install-Package InstantTemplates -Prerelease
```

## Demo

git clone https://github.com/Geta/InstantTemplates

Open up in Visual Studio 2013 or newer, F5 to run (make sure you have automatic NuGet package restore enabled and EPiServerTemplating project is set as startup project).

Test user for Edit mode
username: Tester
password: Tester.123

## Package maintainers

https://github.com/frederikvig
https://github.com/patkleef
https://github.com/milosmih92

## Local development setup

See description in [shared repository](https://github.com/Geta/package-shared/blob/master/README.md#local-development-set-up) regarding how to setup local development environment.

### Docker hostnames

Instead of using the static IP addresses the following hostnames can be used out-of-the-box.

- http://instanttemplates.getalocaltest.me

## Changelog

[Changelog](CHANGELOG.md)

## Disclaimer

The code used to extend the editor interface is not an approach supported by EPiServer and it is not guaranteed to work with future releases. Please use at your own discretion. We will however do our best to keep it up-to-date with the latest version of EPiServer
