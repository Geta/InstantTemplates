define([
    "dojo/_base/array",
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/when",
    "dojo/topic",

    "dijit/form/ToggleButton",
    "dijit/layout/ContentPane",

    "epi/dependency",
    "epi/shell/command/ToggleCommand",

    "epi/shell/ViewSettings",

    "instantTemplates/TemplateContentTypesCommand",
    "dijit/form/Button",

    "epi/shell/command/_CommandProviderMixin"
], function (
    array,
    declare,
    lang,
    when,
    topic,

    ToggleButton,
    ContentPane,

    dependency,
    ToggleCommand,
    ViewSettings,

    TemplateContentTypesCommand,
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

            this.addCommand();
        },

        addCommand: function () {
            // summary:
            //      Append the given command to the command list, uncategorized commands will be added to the "leading" category
            // command:
            //      The command to append
            // settings:
            //      The settings to use when creating the menu item for the command
            // tags:
            //      protected

            var command = new TemplateContentTypesCommand({ templatesRoot: this.templatesRoot });
            var settings = {};

            settings = lang.mixin({
                category: "create",
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
