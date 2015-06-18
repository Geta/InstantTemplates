define([
// dojo
    "dojo/_base/array",
    "dojo/_base/declare",
    "dojo/_base/lang",

    "dojo/dom-class",

    "dojo/Deferred",
    "dojo/promise/all",
    "dojo/when",
    "dojo/topic",

// dijit
    "dijit/layout/_LayoutWidget",
// epi
    "epi/dependency",
    "epi/shell/TypeDescriptorManager",
    "./ContentTypeGroup",

    "epi/i18n!epi/cms/nls/episerver.cms.widget.contenttypelist"
],

function (
// dojo
    array,
    declare,
    lang,

    domClass,

    Deferred,
    all,
    when,
    topic,
// dijit
    _LayoutWidget,
// epi
    dependency,
    TypeDescriptorManager,
    ContentTypeGroup,

    i18n
) {

    return declare([_LayoutWidget], {
        // summary:
        //      A list of suggested and available content types for content creation.
        // description:
        //      Displays a list of suggested and available content types for content creation.
        // tags:
        //      internal

        // store: [readonly] dojo.store
        //      Underlying store which will be queried for data to display.
        store: null,

        // parentLink: [public] String
        //      Link to parent content which the new content will be created beneath.
        parentLink: null,

        // groups: [public] Object
        //      Named value object containing the current content type groups.
        groups: null,

        // requestedType: [public] String
        //      Specify the content type to be shown on the list.
        requestedType: null,

        // shouldSkipContentTypeSelection: [public] Boolean
        //      Indicate that we have only 1 available type, so type selection can be skipped.
        shouldSkipContentTypeSelection: null,

        // propertyName: [public] String
        //      The name of the property by which the list will be filtered on (via AllowedTypes attribute)
        propertyName: null,

        // contentLink: [public] String
        //     The contentlink for which the list will be filtered on.
        contentLink: null,

        templatesRoot: null,

        postMixInProperties: function () {
            // summary:
            //      Initiates the store if none has been mixed in.
            // tags:
            //      protected

            this.inherited(arguments);

            this.groups = {};

            if (!this.store) {
                var registry = dependency.resolve("epi.storeregistry");
                this.store = registry.get("epi.cms.contenttype");
            }
        },

        buildRendering: function () {
            // summary:
            //      Construct the base UI with suggested content types.
            // tags:
            //      protected

            console.log("buildrendering is called");
            this.inherited(arguments);

            var suggested = new ContentTypeGroup();
            
            domClass.add(suggested.titleNode, "epi-ribbonHeaderSpecial");
            suggested.set("title", "Available Instant Templates");
            suggested.set("templatesRoot", this.templatesRoot);
            //suggested.set("contentTypes", this._getAvailableContentTypes(this.requestedType));
            suggested.setVisibility(true);
            this.connect(suggested, "onSelect", function (item) { this.onContentTypeSelected(item); });
            this.addChild(suggested);
            this._suggestedContentTypes = suggested;

            this.set("shouldSkipContentTypeSelection", false);
        },

        refresh: function () {
            // summary:
            //      Refresh the content and rendered view of the list.
            // tags:
            //      public

            // Clear any existing data first to stop flickering in the UI.

            console.log("refresh is called");
            this.clear();

            this._setupWidgetTemplate();


            when(all({
                types: this._getSuggestedContentTypes(this.requestedType),
                groups: this._groupContentTypes()
            }), lang.hitch(this, function (result) {
                var types = result.types;

                
                // Setup the suggested content types.
                domClass.add(this._suggestedContentTypes.titleNode, "epi-ribbonHeaderSpecial");
                this._suggestedContentTypes.set("title", this._suggestedTypesTitle);
                this._suggestedContentTypes.set("contentTypes", types);
                this._suggestedContentTypes.setVisibility(true);

                this.set("shouldSkipContentTypeSelection", false);
            }));
        },

        setVisibility: function (display) {
            // summary:
            //      The common method to show / hide this widget
            // display: Boolean
            //      The flag to show or hide.
            // tags:
            //      pubic

            this.getChildren().forEach(function (group) {
                group.setVisibility(display);
            }, this);
        },

        _setupWidgetTemplate: function () {
            console.log("hei3");
            this._suggestedTypesTitle = TypeDescriptorManager.getResourceValue(this.requestedType, "suggestedtypes");
            this._otherTypesTitle = TypeDescriptorManager.getResourceValue(this.requestedType, "othertypes");
        },

        clear: function () {
            // summary:
            //      Removes all the content types groups from the current view, except for
            //      suggested content types which will only have it's children removed.
            // tags:
            //      public

            this._suggestedContentTypes.clear();

            for (var key in this.groups) {
                this.groups[key].destroyRecursive();
                delete this.groups[key];
            }
        },

        _getOrCreateGroup: function (name) {
            var group = this.groups[name];
            if (!group) {
                group = new ContentTypeGroup({ title: name });
                this.connect(group, "onSelect", function (item) { this.onContentTypeSelected(item); });
                this.addChild(group);
                this.groups[name] = group;
            }

            return group;
        },

        _getAvailableContentTypes: function (type) {
            // summary:
            //      Query for available content types based on the type.
            // tags:
            //      private

            return this.store.query({
                query: "getavailablecontenttypes",
                localAsset: this.get("localAsset"),
                parentReference: this.parentLink,
                requestedTypes: [type],
                contentLink: this.contentLink,
                propertyName: this.propertyName
            });
        },

        _getSuggestedContentTypes: function (type) {
            // summary:
            //      Query for suggested content types based on the parent page.
            // tags:
            //      private

            return this.store.query({
                query: "getsuggestedcontenttypes",
                localAsset: this.get("localAsset"),
                parentReference: this.parentLink,
                requestedTypes: [type]
            });
        },

        _groupContentTypes: function () {
            // summary:
            //      Group the available content types.
            // tags:
            //      private

            var grouped = {},
                deferred = new Deferred(),
                otherGroupType = this._otherTypesTitle;

            when(this._getAvailableContentTypes(this.requestedType), lang.hitch(this, function (available) {
                var count = available.length;
                array.forEach(available, function (item) {
                    when(item, function (type) {
                        var groupName = type.groupName || otherGroupType,
                            group = grouped[groupName] || [];

                        group.push(type);
                        grouped[groupName] = group;
                        count--;
                        if (count === 0) {
                            deferred.resolve({ grouped: grouped, contentTypes: available });
                        }
                    });
                });
            }));

            return deferred;
        },

        _setLocalAssetAttr: function (localAsset) {
            this._set("localAsset", localAsset);

            if (this.requestedType && this.parentLink) {
                this.refresh();
            }
        },

        _setParentLinkAttr: function (value) {
            this._set("parentLink", value);

            if (this.requestedType) {
                this.refresh();
            }
        },

        _setRequestedTypeAttr: function (value) {
            this._set("requestedType", value);
        },
        _setPropertyNameAttr: function (name) {
            // summary:
            //      set the property name
            // tags:
            //      private

            this._set("propertyName", name);
        },

        _setContentLinkAttr: function (value) {
            // summary:
            //      set the content link
            // tags:
            //      private

            this._set("contentLink", value);
        },

        onContentTypeSelected: function (item) {
            // summary:
            //      Event raised when a content type widget on the list
            //      is clicked.
            // tags:
            //      callback

            topic.publish("/epi/shell/action/changeview", "instantTemplates/CreateContentView", null, {
                parent: this.parentLink,
                contentLink: item.contentLink,
                headingText: "New Instant Template",
                templateName: item.name
            });

            // TODO show the name dialog instead
        }

    });

});