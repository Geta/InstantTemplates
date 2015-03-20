define([
    "dojo/_base/declare",
    "dojo/topic",
    // Resources
    "epi/i18n!epi/cms/nls/episerver.cms.contentediting.toolbar.buttons.compare",
    // Parent class and mixins
    "epi/shell/command/_Command",
    "epi-cms/_ContentContextMixin"
], function(
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
        iconClass: "epi-iconCompare",

        // canExecute: [readonly] Boolean
        //      Flag which indicates whether this command is able to be executed.
        canExecute: true,

        // active: [readonly] Boolean
        //      Flag which indicates whether this command is in an active state.
        active: true,

        contextChanged: function (context, callerData) {
            this.inherited(arguments);             
            // the context changed, probably because we navigated or published something            
            console.dir(context);

            //TODO: Check if we are allowed to create this type/item here. (_onModelChange)
        },

        _execute: function() {
            topic.publish("/epi/shell/action/changeview", "instantTemplates/CreateContentView", null, {
                "parent": "40", //TODO: remove hard coded value
                contentLink: this.contentLink, //This should be populated when the command is created instead with the contentLink of the item.
                headingText: "Needed?",
                templateName: this.label
            });
        }
    });
});
