// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

define([
    "dojo/_base/lang",
    "epi-cms/component/ContentContextMenuCommandProvider",
    "instantTemplates/TemplateContentSelectionCommand"
], function (
    lang,
    ContentContextMenuCommandProvider,
    TemplateContentSelectionCommand
) {

    var originalMethod = ContentContextMenuCommandProvider.prototype.postscript;

    lang.mixin(ContentContextMenuCommandProvider.prototype, {

        postscript: function () {
            originalMethod.call(this);

            var command = new TemplateContentSelectionCommand(this._settings);

            this.commands.push(command);
        }
    });

    ContentContextMenuCommandProvider.prototype.postscript.nom = "postscript";
});