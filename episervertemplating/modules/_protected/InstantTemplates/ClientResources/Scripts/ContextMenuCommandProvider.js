define([
    "dojo/_base/lang",
    "epi-cms/component/ContentContextMenuCommandProvider",
    "instantTemplates/TemplateContentTypesCommand"
], function (
    lang,
    ContentContextMenuCommandProvider,
    TemplateContentTypesCommand
) {

    var originalMethod = ContentContextMenuCommandProvider.prototype.postscript;

    lang.mixin(ContentContextMenuCommandProvider.prototype, {

        postscript: function () {
            originalMethod.call(this);

            var templateContentTypesCommand = new TemplateContentTypesCommand(this._settings);

            this.commands.push(templateContentTypesCommand);
        }
    });

    ContentContextMenuCommandProvider.prototype.postscript.nom = "postscript";
});