define([
    "dojo/_base/declare",
    "dojo/topic",
    //Resources
    "epi/i18n!epi-cms/nls/",
    // Parent class and mixins
    "epi/shell/command/_Command",
    "epi/shell/command/_SelectionCommandMixin"
], function (
    declare,
    topic,
    //Resources
    customLocalization,
    // Parent class and mixins
    _Command,
    _SelectionCommandMixin
) {

    return declare([_Command, _SelectionCommandMixin], {

        iconClass: "epi-iconPackage epi-icon--inverted",

        label: customLocalization.episerver.cms.command.newtemplate != null ?
               customLocalization.episerver.cms.command.newtemplate : "New from template",

        _execute: function () {
            var selectionData = this.get("selectionData");

            topic.publish("/epi/shell/action/changeview", "instantTemplates/ContentTypeList", {
                parentLink: selectionData.contentLink,
                contentLink: this.contentLink,
                templatesRoot: this.templatesRoot
            });
        },

        _onModelChange: function () {
            this.set("canExecute", !!this.get("selectionData"));
        }
    });
});
