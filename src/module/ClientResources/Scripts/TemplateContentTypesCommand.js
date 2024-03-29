﻿// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

define([
    "dojo/_base/declare",
    "dojo/topic",
    // Resources
    "epi/i18n!epi-cms/nls/",
    "epi/i18n!epi-cms/nls/episerver.cms.contentediting.toolbar.buttons.compare",
    // Parent class and mixins
    "epi/shell/command/_Command",
    "epi-cms/_ContentContextMixin",
    "epi-cms/core/ContentReference",
    //Helpers
    "instantTemplates/helpers"
], function (
    declare,
    topic,
    // Resources
    customLocalization,
    localizations,
    // Parent class and mixins
    _Command,
    _ContentContextMixin,
    _ContentReference,
    helpers
) {

        return declare([_Command, _ContentContextMixin], {
            // summary:
            //      A command that toggles between the compare view and the previous view when executed.
            //
            // tags:
            //      internal

            // iconClass: [public] String
            //      The CSS class which represents the icon to be used in visual elements.
            iconClass: "epi-iconPackage epi-icon--inverted",

            label: helpers.translate(customLocalization.episerver.cms.command.newtemplate, "New from template"),

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
            },

            _execute: function () {
                var currentContext = this.getCurrentContext();
                var currentContentReference = new _ContentReference(currentContext.id);

                topic.publish("/epi/shell/action/changeview", "instantTemplates/ContentTypeList", {
                    parentLink: currentContext.parentLink,
                    contentLink: currentContentReference.id,
                    templatesRoot: this.templatesRoot
                });
            }
        });
    });
