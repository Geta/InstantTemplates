define([
    // Pull in the patches. Not used here, just evaluated, since this is the first module loaded when starting the application.
    "dojo/_base/declare",
    "dojo/_base/lang",
    "epi/_Module",
    "epi/dependency",
    "alloy/templatesystem/AddItemFromTemplateCommandProvider"
],

function (
    declare,
    lang,
    _Module,
    dependency,
    AddItemFromTemplateCommandProvider
) {

    return declare([_Module], {
        // summary:
        //		Template module implementation.
        //
        // tags:
        //      internal

        initialize: function () {

            var commandregistry = dependency.resolve("epi.globalcommandregistry");

            //We need to wait for the viewsettings to initialized before creating the global toolbar command provider
            commandregistry.registerProvider("epi.cms.globalToolbar", new AddItemFromTemplateCommandProvider());
        }
    });
});
