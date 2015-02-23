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

// epi
    "epi/dependency",
    "epi/shell/TypeDescriptorManager",
    "epi-cms/core/ContentReference",

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

// epi
    dependency,
    TypeDescriptorManager,
    ContentReference,

// resources
    sharedMessages
) {

    return declare([Stateful, Evented], {
        // summary:
        //      View model of epi-cms/contentediting/CreateContent component.
        // tags:
        //      internal

        // =======================================================================
        // Private stuffs
        // =======================================================================

        // _topLevelContainerType: String
        //      The default top level container type used in properties form.
        _topLevelContainerType: "epi/shell/layout/SimpleContainer",

        // _groupContainerType: String
        //      The default group container type used in properties form.
        _groupContainerType: "epi-cms/layout/CreateContentGroupContainer",

        // =======================================================================
        // Dependencies
        // =======================================================================

        // contentDataStore: epi/shell/RestStore
        //      The content data store instance.
        contentDataStore: null,

        // =======================================================================
        // Data model properties
        // =======================================================================

        // parent: Content
        //      The parent content on which the new content is created.
        parent: null,

        // autoPublish: Boolean 
        //       Indicates if the content should be published automatically when created if the user has publish rights.
        autoPublish: false,

        // addToDestination: Delegate
        //      A delagate object which contains a save method. The method will be executed after the content is successfully created.
        addToDestination: null,

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

        // actualParentLink: String
        //      Link of the parent beneath which the content is created. It could be the given parent or the given parent's local asset folder.
        actualParentLink: null,

        // metadata: Object
        //      The metadata object of the content being created.
        metadata: null,

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
                this.contentDataStore = registry.get("epi.cms.contentdata");
            }
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
            this.set("wizardStep", this.startWizardStep);

            this.set("namePanelIsVisible", true);
            this.set("headingPanelIsVisible", true);

            this.set("showCurrentNodeOnBreadcrumb", true);
            this.set("seamlessTopPanel", true);

            // Copy data properties from topic sender
            if (settings) {
                array.forEach(["propertyName", "ownerContentLink", "requestedType", "parent", "autoPublish", "addToDestination", "headingText", "templateName"], function (property) {
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

            this.set("saveButtonDisabled", true);

            // Validate content name
            if (!this.ignoreDefaultNameWarning && (!this.contentName || this.contentName === "" || this.contentName === this.defaultName)) {

                var contentName = this.contentName;
                if (this.metadata && this.metadata.additionalValues && this.metadata.additionalValues.modelTypeIdentifier) {
                    contentName = TypeDescriptorManager.getResourceValue(this.metadata.additionalValues.modelTypeIdentifier, "newitemdefaultname");
                }

                this._emitSaveEvent("invalidContentName", contentName);
                return;
            }
            
            console.log("TODO: Copy template using the content data store.");
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

        _saveSuccessHandler: function (contentLink) {
            // summary:
            //      Save success handler
            // contentLink: String
            //      The newly created content's link
            // tags:
            //      private

            var ref = new ContentReference(contentLink),
                versionAgnosticRef = ref.createVersionUnspecificReference(),
                changeToNewContext = lang.hitch(this, function (/*String*/targetLink) {
                    this._emitSaveEvent("saveSuccess", {
                        newContentLink: targetLink,
                        changeContext: true
                    });
                });

            when(this.contentDataStore.refresh(contentLink), lang.hitch(this, function (newContent) {
                if (this.addToDestination) {
                    this.addToDestination.save({
                        contentLink: versionAgnosticRef.toString(),
                        name: newContent.name,
                        typeIdentifier: this.requestedType
                    });

                    // Keep the current context
                    this._emitSaveEvent("saveSuccess", {
                        changeContext: false
                    });

                } else {
                    // Change to new context
                    changeToNewContext(versionAgnosticRef.toString());
                }
            }));
        },

        _saveErrorHandler: function (err) {
            // summary:
            //      Save error handler
            // err: Object
            //      The error object.
            // tags:
            //      private

            // err is actually the xhr error, as for now the rest store doesn't pre handle errors.
            if (err && err.responseText) {
                // received a list of problems

                // NOTE: Do not copy this code since it's not a good practice to handle error. We are finding a pattern to handle server errors in a nicer manner, perhaps inside the rest store.
                var validationErrors = json.fromJson(err.responseText);

                array.forEach(validationErrors, function (item) {
                    if (item.propertyName) {
                        this.validator.setPropertyErrors(item.propertyName, [{
                            severity: item.severity,
                            errorMessage: item.errorMessage
                        }], this.validator.validationSource.server);
                    } else {
                        this.validator.setGlobalErrors([{
                            severity: item.severity,
                            errorMessage: item.errorMessage
                        }], this.validator.validationSource.server);
                    }
                }, this);

            } else if (err) {
                // general error
                this.validator.setGlobalErrors([{
                    severity: this.validator.severity.error,
                    errorMessage: err.message
                }], this.validator.validationSource.server);
            }

            this._emitSaveEvent("saveError", err);
        },

        buildContentObject: function () {
            // summary:
            //      Build up the content object to create from model properties.
            // tags:
            //      protected

            return {
                name: string.trim(this.contentName + ""),
                parentLink: this._getParentLink(),
                properties: this.properties,
                autoPublish: this.autoPublish
            };
        },

        _parentSetter: function (parent) {
            this.parent = parent;

            var typeIdentifier = this.parent.typeIdentifier,
                requestedTypeName = TypeDescriptorManager.getResourceValue(this.requestedType, "name"),
                parentTypeName = TypeDescriptorManager.getResourceValue(typeIdentifier, "name"),
                createAsLocalAssetHelpText = TypeDescriptorManager.getResourceValue(typeIdentifier, "createaslocalassethelptext");

            if (requestedTypeName && parentTypeName) {
                createAsLocalAssetHelpText = lang.replace(createAsLocalAssetHelpText, [requestedTypeName.toLowerCase(), parentTypeName.toLowerCase()]);
            }

            this.set("createAsLocalAssetHelpText", createAsLocalAssetHelpText);
        },

        // =======================================================================
        // Private methods
        // =======================================================================

        _getParentLink: function() {
            // summary:
            //      Gets the link to the parent where the content should be created under.
            //      If the parent is a Content Asset folder the link to the owner content will be returned.
            // tags:
            //      private

            if(!this.parent) {
                return null;
            }

            if(this.createAsLocalAsset) {
                return this.parent.ownerContentLink ? this.parent.ownerContentLink : this.parent.contentLink;
            }
            return this.parent.contentLink;
        }
    });

});