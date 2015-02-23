define([
// dojo
    "dojo/_base/array",
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/promise/all",
    "dojo/when",
// epi
    "epi",

    "epi/shell/command/_Command",
    "epi/shell/command/_ClipboardCommandMixin",
    "epi/shell/command/_SelectionCommandMixin"
],

function (
// dojo
    array,
    declare,
    lang,
    promiseAll,
    when,
// epi
    epi,

    _Command,
    _ClipboardCommandMixin,
    _SelectionCommandMixin
) {

    return declare([_Command, _ClipboardCommandMixin, _SelectionCommandMixin], {
        // summary:
        //      A command that pastes whats in the clip board onto the current selection.
        // tags:
        //      public

        // label: [readonly] String
        //      The action text of the command to be used in visual elements.
        label: epi.resources.action.paste,

        // iconClass: [readonly] String
        //      The icon class of the command to be used in visual elements.
        iconClass: "epi-iconPaste",

        // createAsLocalAsset: [public] Boolean
        //      Indicate if the content should be created as local asset of its parent.
        createAsLocalAsset: false,

        _execute: function () {
            // summary:
            //      Executes this command; publishes a change view request to change to the create content view.
            // tags:
            //      protected

            var source = this.get("clipboardData"),
               target = this.get("selectionData");

            this.model.set("createAsLocalAsset", this.createAsLocalAsset);

            if (this.clipboard.copy) {
                return this.model.copy(source, target);
            } else {
                return when(this.model.move(source, target), lang.hitch(this, function () {
                    // Clear clipboard after successfully moving
                    this.clipboard.clear();
                }));
            }
        },

        _onModelChange: function () {
            // summary:
            //      Updates canExecute after the model has been updated.
            // tags:
            //      protected

            var self = this,
                model = self.model,
                source = self.get("clipboardData"),
                target = self.get("selectionData");

            // Set to false by default in case there are any timing delays in the deferred.
            self.set("canExecute", false);

            if (model && source && source.length && target) {
                var deferreds = array.map(source, function (item) {
                    return model.canPaste(item.data, target, self.clipboard.copy);
                });

                when(promiseAll(deferreds), function (results) {
                    var canExecute = array.every(results, function (result) { return result; });

                    if (self.clipboard.copy) {
                        self.set("canExecute", canExecute);
                        return;
                    }

                    // Check to make sure the target is not a descendant of the source.
                    model.getAncestors(target, function (ancestors) {
                        var isDescendant = array.some(source, function (item) {
                            return array.indexOf(ancestors, item.data) >= 0;
                        });
                        self.set("canExecute", canExecute && !isDescendant);
                    });
                });
            }
        }

    });

});