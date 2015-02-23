define([
    "dojo/_base/array",
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/when",

    "dijit/form/ToggleButton",
    "dijit/layout/ContentPane",

    "epi/dependency",
    "epi/shell/command/ToggleCommand",

    "epi/shell/ViewSettings",

    "alloy/templatesystem/CreateItemFromTemplate",
    "dijit/form/Button",

    "epi/shell/command/_CommandProviderMixin"
], function (
    array,
    declare,
    lang,
    when,

    ToggleButton,
    ContentPane,

    dependency,
    ToggleCommand,
    ViewSettings,

    CreateItemFromTemplate,
    Button,

    _CommandProviderMixin
) {

    return declare([_CommandProviderMixin], {
        // summary:
        //      Default command provider for the epi-cms/component/GlobalToolbar
        // tags:
        //      internal

        contentRepositoryDescriptors: null,
        viewName: null,

        postscript: function () {
            // summary:
            //      Ensure that an array of commands has been initialized.
            // tags:
            //      public
            this.inherited(arguments);

            this.viewName = this.viewName || ViewSettings.viewName;

            this._addCreateCommands();
        },

        _addCreateCommands: function () {

            var templateRoot = "47"; //TODO: Remove hard coded.

            var that = this;

            when(this.getContentDataStore().query({ referenceId: templateRoot, query: "getchildren" }), function (children) {
                children.forEach(function (child) {
                    var a = new CreateItemFromTemplate({"contentLink" : child.contentLink, label : "Create new " + child.name});
                    that.addCommand(a, { category: "create" });
                });
            });

            //array.forEach(descriptorsForCurrentView, function (descriptor) {
            //    array.forEach(descriptor.creatableTypes, function (type) {
            //        this.addCommand(this._createCommand(type), { category: "create" });
            //    }, this);
            //}, this);
        },

        getContentDataStore: function () {
            // summary:
            //      Gets the content data store from store registry if it's not already cached

            if (!this.contentDataStore) {
                var registry = dependency.resolve("epi.storeregistry");
                this.contentDataStore = registry.get("epi.cms.content.light");
            }
            return this.contentDataStore;
        },


        addCommand: function (/*_Command*/command, /*Object*/settings) {
            // summary:
            //      Append the given command to the command list, uncategorized commands will be added to the "leading" category
            // command:
            //      The command to append
            // settings:
            //      The settings to use when creating the menu item for the command
            // tags:
            //      protected
            settings = lang.mixin({
                "class": "epi-mediumButton",
                iconClass: command.iconClass,
                category: "leading",
                label: command.label,
                tooltip: command.tooltip,
                showLabel: false,
                widget: Button,
                model: command
            }, settings);


            //Create a delagate for the command
            command = lang.delegate(command, { settings: settings });

            //Add to the command list
            this.add("commands", command);
        }
    });
});
