define([
// dojo
    "dojo/_base/array",
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/_base/json",

    "dojo/Stateful",
    "dojo/string",
    "dojo/when",
    "dojo/Evented",
    "dojo/topic",

// epi
    "epi/dependency",
    "epi/shell/TypeDescriptorManager",
    "epi-cms/core/ContentReference",

    "epi-cms/widget/ContentTreeStoreModel",
    "epi-cms/_ContentContextMixin",

// resources
    "epi/i18n!epi/shell/ui/nls/episerver.shared.messages"
],

function (
// dojo
    array,
    declare,
    lang,
    json,

    Stateful,
    string,
    when,
    Evented,
    topic,

// epi
    dependency,
    TypeDescriptorManager,
    ContentReference,

    ContentTreeStoreModel,

    _ContentContextMixin,

// resources
    sharedMessages
) {

    return declare([Stateful, Evented, _ContentContextMixin], {
        // summary:
        //      View model of epi-cms/contentediting/CreateContent component.
        // tags:
        //      internal

        // =======================================================================
        // Dependencies
        // =======================================================================

        // contentStructureStore: epi/shell/RestStore
        //      The content structure store instance.
        contentStructureStore: null,

        // =======================================================================
        // Data model properties
        // =======================================================================

        // parent: Content
        //      The parent content on which the new content is created.
        parent: null,

        // =======================================================================
        // View model properties
        // =======================================================================

        // contentName: String
        //      Name of the content being created. This is initialized from the resource bundle and bound to the name text box in the widget.
        contentName: null,

        // ignoreDefaultNameWarning: Boolean
        //      Indicates that name checking should be ignored.
        ignoreDefaultNameWarning: null,

        // headingText: String
        //      Heading text which is displayed on the top of the toolbar. This is set according to the current request type.
        headingText: null,

        // contentNameHelpText: String
        //      Help text for the content name input
        contentNameHelpText: "",

        // namePanelIsVisible: Boolean
        //      Indicate that the name panel is visible. If the content is created as local asset, name panel should not be visible
        namePanelIsVisible: null,

        // headingPanelIsVisible: Boolean
        //      Indicates that the heading panel is visible. Similar to the name panel, heading panel is not visible when the content is created as local asset. 
        //      In that case, a more detail heading is displayed inside the content type selection list or properties form.
        headingPanelIsVisible: null,

        // seamlessTopPanel: Boolean
        //      Indicates that the top panel should show seamlessly.
        seamlessTopPanel: null,

        // saveButtonIsVisible: Boolean
        //      Indicate that the save button should be visible, normally in the last step.
        saveButtonIsVisible: null,

        // saveButtonDisabled: Boolean
        //      Indicate that the save button should be disabled, when saving is on going.
        saveButtonDisabled: null,

        // showAllProperties: Boolean
        //      Indicates that it should show all properties for user to enter initial value, normally when content is created from content area.
        showAllProperties: null,

        // showCurrentNodeOnBreadcrumb: Boolean
        //      Indicates that the breadcrumb should show current content node.
        showCurrentNodeOnBreadcrumb: null,

        contentTreeStoreModel: null,

        // =======================================================================
        // Public methods
        // =======================================================================

        postscript: function () {
            // summary:
            //      Initializes internal objects and state after constructed.
            // description:
            //      Obtains content data store and metadata manager instances from dependency manager.
            // tags:
            //      protected

            this.inherited(arguments);

            if (!this.contentDataStore) {
                var registry = dependency.resolve("epi.storeregistry");
                this.contentStructureStore = registry.get("epi.cms.content.light");
            }

            this.contentTreeStoreModel = new ContentTreeStoreModel({
                store: this.contentStructureStore
            });
        },

        update: function (settings) {
            // summary:
            //      Update the component with new settings.
            // description:
            //      Taking settings from the ones who request the Create content component. 
            //      The supported settings are: requestedType, parent, createAsLocalAsset, addToDestination, contentTypeId. They will be mixed to the current instance.
            // settings: Object
            //      The settings object.
            // tags:
            //      protected

            // Reset view properties

            this.set("ignoreDefaultNameWarning", false);
            this.set("properties", null);
            this.set("saveButtonIsVisible", false);

            this.set("namePanelIsVisible", true);
            this.set("headingPanelIsVisible", true);

            this.set("showCurrentNodeOnBreadcrumb", true);
            this.set("seamlessTopPanel", true);

            // Copy data properties from topic sender
            if (settings) {
                array.forEach(["propertyName", "contentLink", "requestedType", "parent", "autoPublish", "addToDestination", "headingText", "templateName"], function (property) {
                    this.set(property, settings[property]);
                }, this);
            }

            // Setup the validator
            if (this.parent) {
                var notificationContextId = this.parent.contentLink + "_new_content"; // A pseudo context id for the content that not yet created.

                this.set("notificationContext", { contextTypeName: "epi.cms.contentdata", contextId: notificationContextId });
            }
        },

        save: function () {
            // summary:
            //      Save the content and finish the wizard.
            // description:
            //      save() will validate the content name if ignoreDefaultNameWarning is not set. By then "invalidContentName" might be emitted.
            //      If data validation is fine, the new content object will be put on the content data store. 
            //      On success, "saveSuccess" event is emitted, otherwise "saveError" is emitted.
            // tags:
            //      public
            //this.set("saveButtonDisabled", true);

            // Validate content name
            if (!this.ignoreDefaultNameWarning && (!this.contentName || this.contentName === "" || this.contentName === this.defaultName)) {

                this._emitSaveEvent("invalidContentName", contentName);
                return;
            }

            var registry = dependency.resolve("epi.storeregistry");
            var contentDataStore = registry.get("epi.cms.contentdata");

            var contentDataQuery = contentDataStore.query({ id: this.contentLink });
            var parentDataQuery = contentDataStore.query({ id: this.getCurrentContext().id /* this.parent*/ });

            var contentData, parentData;

            var contentTreeStoreModel = this.contentTreeStoreModel;
            var contentName = this.contentName;
            var changeContext = this._changeContext;

            contentDataQuery.then(function (result) {

                contentData = result;

                parentDataQuery.then(function (parentResult) {
                    parentData = parentResult;

                    if (!contentTreeStoreModel.canPaste(contentData, parentData, true)) {
                        console.log("Cannot copy this item.");
                        return;
                    }

                    var contentLink = jQuery.ajax({
                        type: "POST",
                        url: "/instanttemplate/create",
                        data: { templateLink: contentData.contentLink, parentLink: parentData.contentLink, name: contentName },
                        async: false
                    }).responseText;

                    changeContext(contentLink);
                });
            });
        },

        _emitSaveEvent: function (eventName, params) {
            this.set("saveButtonDisabled", false);
            this.emit(eventName, params);
        },

        cancel: function () {
            // summary:
            //      Cancel operation and finish the wizard
            // tags:
            //      Public

            this.addToDestination && (typeof this.addToDestination.cancel === "function") && this.addToDestination.cancel();
        },

        _changeContext: function (contentLink) {
            // summary:
            //    Redirect the newly created content to editmode.
            //
            // contentLink:
            //    The content link.
            //
            // tags:
            //    private

            topic.publish("/epi/shell/context/request", {
                uri: "epi.cms.contentdata:///" + contentLink
            }, {
                sender: this,
                viewName: this.view,
                forceContextChange: true,
                forceReload: true
            });
        }
    });
});