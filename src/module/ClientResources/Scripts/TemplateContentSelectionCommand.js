// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

define([
    "dojo/_base/declare",
    "dojo/topic",
    //Resources
    "epi/i18n!epi-cms/nls/",
    // Parent class and mixins
    "epi/shell/command/_Command",
    "epi/shell/command/_SelectionCommandMixin",
    //Helpers
    "instantTemplates/helpers"
], function (
    declare,
    topic,
    //Resources
    customLocalization,
    // Parent class and mixins
    _Command,
    _SelectionCommandMixin,
    helpers
) {

        return declare([_Command, _SelectionCommandMixin], {

            iconClass: "epi-iconPackage epi-icon--inverted",

            label: helpers.translate(customLocalization.episerver.cms.command.newtemplate, "New from template"),

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
