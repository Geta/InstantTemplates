define([
    "dojo/_base/declare",
    "dojo/topic",
    // Resources
    "epi/i18n!epi/cms/nls/episerver.cms.contentediting.toolbar.buttons.compare",
    // Parent class and mixins
    "epi/shell/command/_Command",
    "epi-cms/_ContentContextMixin"
], function (
    declare,
    topic,
    // Resources
    localizations,
    // Parent class and mixins
    _Command,
    _ContentContextMixin
) {

    return declare([_Command, _ContentContextMixin], {
        // summary:
        //      A command that toggles between the compare view and the previous view when executed.
        //
        // tags:
        //      internal

        // iconClass: [public] String
        //      The CSS class which represents the icon to be used in visual elements.
        iconClass: "epi-iconObjectPageContextual",

        label: "New from Template",

        // canExecute: [readonly] Boolean
        //      Flag which indicates whether this command is able to be executed.
        canExecute: true,

        // active: [readonly] Boolean
        //      Flag which indicates whether this command is in an active state.
        active: true,

        templatesRoot: null,

        contextChanged: function (context, callerData) {
            this.inherited(arguments);
            // the context changed, probably because we navigated or published something            

            //TODO: Check if we are allowed to create this type/item here. (_onModelChange)
        },

        _execute: function () {
            topic.publish("/epi/shell/action/changeview", "instantTemplates/ContentTypeList", {
                parentLink: this.getCurrentContext().id,
                contentLink: this.contentLink,
                templatesRoot: this.templatesRoot
            });
        }
    });
});
