# Changelog

All notable changes to this project will be documented in this file.

## [1.1.2]

### Fixed

- #57 Nuget.Core deprecated

## [1.1.1]

### Fixed

- #58 Pages tree/Folders tree don't display correctly when create a new page/block by click (+) button on Global toolbar

## [1.1.0]

### Changed

- Templates are filtered by language

### Fixed

- Creation of template from Global toolbar
- Only published templates are shown in available templates list
- Layout design
- Minor bugfixes


## [1.0.4]

### Changed

- Upgraded ASP.NET MVC to v5
- Upgrading System.Security.Cryptography.Xml package
- Updated README.md

### Added

- Added Docker support
- Added support for creating blocks from template
- Added translation of content for English, Norwegian and Swedish
- Added CHANGELOG.md

### Fixed

- "Available templates" is now scrollable
- Pages from templates are created with correct parent page
- Fixed updating instant templates store on template creation (affect that template is available on creation without refresh)
- Fixed focus on "Templates" asset pane, when user clicks somewhere else in edit mode
- Templates can be deleted
- Before creating new page/block from template, widget content is cleared
