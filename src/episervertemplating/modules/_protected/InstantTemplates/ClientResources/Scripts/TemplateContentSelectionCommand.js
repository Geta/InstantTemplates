define([
    "dojo/_base/declare",
    "dojo/topic",
    // Parent class and mixins
    "epi/shell/command/_Command",
    "epi/shell/command/_SelectionCommandMixin"
], function (
    declare,
    topic,
    // Parent class and mixins
    _Command,
    _SelectionCommandMixin
) {

    return declare([_Command, _SelectionCommandMixin], {

        iconClass: "epi-iconPackage epi-icon--inverted",

        label: "New from Template",

        _execute: function () {
            var selectionData = this.get("selectionData");
            topic.publish("/epi/shell/action/changeview", "instantTemplates/ContentTypeList", {
                parentLink: selectionData.parentLink,
                contentLink: selectionData.contentLink,
                templatesRoot: this.templatesRoot
            });
        },

        _onModelChange: function () {
            this.set("canExecute", !!this.get("selectionData"));
        }
    });
});
