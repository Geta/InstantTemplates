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