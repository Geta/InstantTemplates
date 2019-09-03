// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

define([
    // Pull in the patches. Not used here, just evaluated, since this is the first module loaded when starting the application.
    "dojo/_base/declare",
    "dojo/_base/lang",
    "epi/_Module",
    "epi/routes",
    "epi/dependency",
    "instantTemplates/AddItemFromTemplateCommandProvider",
    "instantTemplates/ContextMenuCommandProvider"
],

    function (
        declare,
        lang,
        _Module,
        routes,
        dependency,
        AddItemFromTemplateCommandProvider,
        ContextMenuCommandProvider
    ) {

        return declare([_Module], {
            // summary:
            //		Template module implementation.
            //
            // tags:
            //      internal

            _settings: null,

            constructor: function (settings) {
                this._settings = settings;
            },

            initialize: function () {

                var commandregistry = dependency.resolve("epi.globalcommandregistry");
                var registry = this.resolveDependency("epi.storeregistry");

                //Register the store
                registry.create("instanttemplates", this._getRestPath("instanttemplates"));

                //We need to wait for the viewsettings to initialized before creating the global toolbar command provider
                commandregistry.registerProvider("epi.cms.globalToolbar", new AddItemFromTemplateCommandProvider({ templatesRoot: this._settings.templatesRoot }));
            },

            _getRestPath: function (name) {
                return routes.getRestPath({ moduleArea: "InstantTemplates", storeName: name });
            }
        });
    });
