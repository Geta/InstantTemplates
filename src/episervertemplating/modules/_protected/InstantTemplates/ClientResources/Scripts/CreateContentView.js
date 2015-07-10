define([
// dojo
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/aspect",
    "dojo/dom-style",
    "dojo/dom-class",
    "dojo/topic",
    "dojo/when",

// dijit
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",

    "dijit/form/ValidationTextBox",

    "dijit/layout/_LayoutWidget",
    "dijit/layout/BorderContainer",
    "dijit/layout/ContentPane",

// epi
    "epi/dependency",
    "epi/shell/widget/_ModelBindingMixin",
    "epi/shell/widget/dialog/Dialog",

    "epi-cms/contentediting/NewContentNameInputDialog",

    "instantTemplates/CreateContentViewModel",

    "epi-cms/widget/PropertiesForm",
    "epi-cms/widget/Breadcrumb",
    "epi-cms/widget/BreadcrumbCurrentItem",

// resources
    "dojo/text!./templates/CreateContentView.html",
    "epi/i18n!epi/nls/episerver.shared"
],

function (
// dojo
    declare,
    lang,
    aspect,
    domStyle,
    domClass,
    topic,
    when,

// dijit
    _TemplatedMixin,
    _WidgetsInTemplateMixin,

    ValidationTextBox,

    _LayoutWidget,
    BorderContainer,
    ContentPane,

// epi
    dependency,
    _ModelBindingMixin,
    Dialog,

    NewContentNameInputDialog,

    CreateContentViewModel,

    PropertiesForm,
    BreadCrumbs,
    BreadcrumbCurrentItem,

// resources
    template,
    sharedResources
) {

    return declare([_LayoutWidget, _TemplatedMixin, _WidgetsInTemplateMixin, _ModelBindingMixin], {
        // summary:
        //      A stack container that acts as a content creation wizard.
        // description:
        //      A wizard-like widget that is responsible for showing the widget for
        //      selecting a content type, then determines whether content editing or the
        //      mandatory fields editor is displayed.
        // tags:
        //      internal

        templateString: template,
        sharedResources: sharedResources,

        modelType: CreateContentViewModel,

        // _contextService: [private] epi/shell/ContextService
        _contextService: null,

        // _beingSuspended: [private] boolean
        //      Indicate that the component is being suspended and another view component is being requested.
        _beingSuspended: null,

        constructor : function(){
            var a = this;
        },

        modelBindingMap: {
            "parent": ["parent"],
            "contentLink": ["contentLink"],

            "headingText": ["headingText"],
            "templateName": ["templateName"],
            "contentNameHelpText" : ["contentNameHelpText"],

            "seamlessTopPanel": ["seamlessTopPanel"],
            "saveButtonDisabled": ["saveButtonDisabled"],
            "showCurrentNodeOnBreadcrumb": ["showCurrentNodeOnBreadcrumb"],
            "notificationContext": ["notificationContext"],
            "propertyName": ["propertyName"]
        },

        // Setters
        _setParentAttr: function (parent) {
            // summary:
            //      set parent attribute
            // tags:
            //      private

            if (parent) {
                this.toolbar.setItemProperty("currentcontent", "currentItemInfo", {
                    name: parent.name,
                    dataType: parent.typeIdentifier
                });
            }
        },

        _setHeadingTextAttr: {
            // summary:
            //      Setter for setting the help text next to the name input
            // tags:
            //      private
            node: "headingTextNode",
            type: "innerText"
        },

        _setTemplateNameAttr: {
            // summary:
            //      Setter for setting the help text next to the name input
            // tags:
            //      private
            node: "templateNameNode",
            type: "innerText"
        },

        _setContentNameAttr: function (contentName) {
            // summary:
            //      set content name attribute
            // tags:
            //      private

            this.nameTextBox.set("value", contentName);
        },

        _setSaveButtonIsVisibleAttr: function (isVisible) {
            // summary:
            //      set save button visibility
            // tags:
            //      private

            this.toolbar.setItemVisibility("saveButton", isVisible);
        },

        _setSaveButtonDisabledAttr: function (disabled) {
            // summary:
            //      set save button visibility
            // tags:
            //      private

            this.toolbar.setItemProperty("saveButton", "disabled", disabled);
        },

        _setShowCurrentNodeOnBreadcrumbAttr: function (show) {
            // summary:
            //      set whether the breadcrumd should display the current content node.
            // description:
            //      If the current content node is displayed, content name label in the heading is not and vice versa
            // tags:
            //      private

            this.toolbar.setItemProperty("breadcrumbs", "showCurrentNode", show);
            this.toolbar.setItemVisibility("currentcontent", !show);
        },

        _setNotificationContextAttr: function (context) {
            // summary:
            //      set context on the notification center
            // context: Object
            //      The notification context
            // tags:
            //      private

            this.toolbar.setItemProperty("notificationCenter", "notificationContext", context);
        },

        postMixInProperties: function () {
            // summary:
            //      Post properties mixin handler.
            // description:
            //		Set up model and resource for template binding.
            // tags:
            //		protected

            this.inherited(arguments);

            this.model = new this.modelType();
            this.model.parent = this.parent;

            this.own(this.model.on("saveSuccess", lang.hitch(this, this._onSaveSuccess)));
            this.own(this.model.on("saveError", lang.hitch(this, this._onSaveError)));
            this.own(this.model.on("invalidContentName", lang.hitch(this, this._onInvalidContentName)));
        },

        postCreate: function () {
            // summary:
            //		Post widget creation handler.
            // description:
            //      Set up local toolbar
            // tags:
            //		protected

            this.inherited(arguments);

            this._contextService = this._contextService || dependency.resolve("epi.shell.ContextService");

            this._setupToolbar();
        },

        layout: function () {
            // summary:
            //      Layout the widget
            // description:
            //      Set the widget's size to the top layout container
            // tags:
            //    protected

            if (this._started) {
                this.layoutContainer.resize(this._containerContentBox || this._contentBox);
            }
        },

        updateView: function (data) {
            // summary:
            //      Update the current view with new data from the main widget switcher.
            // data: Object
            //      The settings data. The data requires parent and requestedType property in order to update the view
            // tags:
            //    public

            // content can only be created when it has parent and requestedType (when creating via New Page, Block buttons)
            // or content can be created when it has contentData and languageBranch (when creating via Translate notification)
            // if incoming data doesn't have parent and requestedType then no need to update the view & model.

            // WidgetSwitcher calls the updateView when a context change occurs or when a view change happens. If the view change is initiated by the NewContent command then the required information is supplied.
            // but on a context change the required information is not being supplied correctly.
            if (data && ((data.parent) || (data.contentData))) {

                this.view = data.view;
                this._setCreateMode();
                this._beingSuspended = false;

                when(this.model.update(data), lang.hitch(this, function () {
                    this.layout();

                    //We want the name text box to have focus and the content selected when the view has loaded
                    if(this.nameTextBox) {
                        this.nameTextBox.focus();
                        this.nameTextBox.textbox.select();
                    }

                }), function(err) {
                    console.log(err);
                });
            }
        },

        _onSaveSuccess: function (result) {
            // summary:
            //    Handle save success event from the model.
            //
            // tags:
            //    private

            this._clearCreateMode();

            this._beingSuspended = true;

            if (result.changeContext) {
                this._changeContext(result.newContentLink);
            } else {
                this._backToCurrentContext();
            }

            if (this.createAsLocalAsset === true) {
                topic.publish("/epi/cms/action/createlocalasset");
            }
        },

        _onSaveError: function () {
            // summary:
            //    Handle save error event from the model.
            //
            // tags:
            //    private

            this._clearCreateMode();

            topic.publish("/epi/cms/action/showerror");
        },

        _onInvalidContentName: function (defaultName) {
            // summary:
            //    Handle invalid content name event from the model.
            //
            // tags:
            //    private

            var contentNameInput = new NewContentNameInputDialog({ defaultContentName: defaultName });

            var dialog = new Dialog({
                defaultActionsVisible: false,
                autofocus: true,
                content: contentNameInput,
                title: contentNameInput.title,
                destroyOnHide: true
            });

            this.own(
                aspect.after(dialog, "onExecute", lang.hitch(this, function () {
                    var name = contentNameInput.get("value");
                    if (name === defaultName) {
                        this.model.set("ignoreDefaultNameWarning", true);
                    }
                    this.model.set("contentName", name);
                    this.model.save();
                }), true),

                aspect.after(dialog, "onCancel", lang.hitch(this, function () {
                    this._cancel();
                }), true)
            );

            dialog.show();
        },

        _onPropertyValidStateChange: function (property, error) {
            // summary:
            //      Handle property validity change event from the properties form widget.
            // property: String
            //      The property name
            // error: String
            //      The error message
            // tags:
            //    private

            if (error) {
                this.model.addInvalidProperty(property, error);
            } else {
                this.model.removeInvalidProperty(property);
            }
        },

        _onBlurVerifyContent: function () {
            // summary:
            //    check if the textfield content is empty on blur,
            //    set to default value if it is.
            //
            // tags:
            //    private
            if(this.nameTextBox.get("value") === "") {
                this.nameTextBox.set("value", this.model.defaultName);
            }
        },

        _onContentNameChange: function (name) {
            // summary:
            //    Handle change event from the content name textbox.
            //
            // tags:
            //    private

            this.model.set("contentName", name);
        },

        _onSave: function () {
            // summary:
            //    Handle action of the save button.
            //
            // tags:
            //    private

            if (this._beingSuspended) {
                return;
            }

            this.model.save();
        },

        _onCancel: function () {
            // summary:
            //    Handle action of the cancel button.
            //
            // tags:
            //    private

            this._cancel();
        },

        _cancel: function () {
            this._clearCreateMode();

            this.model.cancel();
            this._backToCurrentContext();
        },

        _setupToolbar: function () {
            // summary:
            //    Set up the local toolbar.
            //
            // tags:
            //    private

            var toolbarGroups = [
            {
                name: "leading",
                type: "toolbargroup",
                settings: { region: "leading" }
            },
            {
                name: "trailing",
                type: "toolbargroup",
                settings: { region: "trailing" }
            }];

            var toolbarButtons = [
            {
                parent: "leading",
                name: "breadcrumbs",
                widgetType: "epi-cms/widget/Breadcrumb",
                settings: { showCurrentNode: false }
            },
            {
                parent: "leading",
                name: "currentcontent",
                widgetType: "epi-cms/widget/BreadcrumbCurrentItem"
            },
            {
                parent: "trailing",
                name: "notificationCenter",
                widgetType: "epi-cms/widget/NotificationStatusBar"
            },
            {
                parent: "trailing",
                name: "saveButton",
                title: sharedResources.action.create,
                label: sharedResources.action.create,
                type: "button",
                action: lang.hitch(this, this._onSave),
                settings: { "class": "epi-button--bold epi-primary" }
            },
            {
                parent: "trailing",
                name: "cancelButton",
                title: sharedResources.action.cancel,
                label: sharedResources.action.cancel,
                type: "button",
                action: lang.hitch(this, this._onCancel),
                settings: { "class": "epi-button--bold" }
            }];

            when(this.toolbar.add(toolbarGroups), lang.hitch(this, function () {
                this.toolbar.add(toolbarButtons);
            }));
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
        },

        _backToCurrentContext: function () {
            // summary:
            //    Get back to the default main widget of the current context.
            //
            // tags:
            //    private
            
            topic.publish("/epi/shell/action/changeview/back");
        },

        _setCreateMode: function () {
            // summary:
            //      Set create new content state for current mode
            // tags:
            //      private

            lang.mixin(this._contextService.currentContext, {
                "currentMode": "create"
            });

            topic.publish("/epi/cms/action/togglecreatemode", true);
        },

        _clearCreateMode: function () {
            // summary:
            //      Clear create new content state for current mode
            // tags:
            //      private

            lang.mixin(this._contextService.currentContext, {
                "currentMode": undefined
            });

            topic.publish("/epi/cms/action/togglecreatemode", false);
        }
    });
});