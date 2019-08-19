define([
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/_base/array",
    "dojo/dom-style",
    "dojo/text!./templates/ContentTypeGroup.html",
    "dojo/topic",
    "dojo",

    "dijit/_TemplatedMixin",
    "dijit/layout/_LayoutWidget",

    "./ContentType",
    "dojo/keys",
    "dijit/_KeyNavContainer",

    "epi/dependency"

], function (declare, lang, array, domStyle, template, topic, dojo, _TemplatedMixin, _LayoutWidget, ContentType, keys, _KeyNavContainer, dependency) {

    return declare([_LayoutWidget, _TemplatedMixin, _KeyNavContainer], {
        // summary:
        //		Displays a group of content types under a common heading.
        //
        // tags:
        //      internal

        // title: [public] String
        //		The title for the content type group.
        title: "",

        // contentTypes: [public] Array
        //		Collection of content types that are displayed in the group.
        contentTypes: null,

        // templateString: [protected] String
        //		A string that represents the widget template.
        templateString: template,

        contentDataStore: null,

        templatesRoot: null,

        buildRendering: function () {
            // summary:
            //		Construct the UI with the initial content types
            // tags:
            //		protected

            this.inherited(arguments);
        },

        postCreate: function () {
            this.inherited(arguments);

            this.render();

            this.connectKeyNavHandlers(
				this.isLeftToRight() ? [keys.LEFT_ARROW, keys.UP_ARROW] : [keys.RIGHT_ARROW, keys.DOWN_ARROW],
				this.isLeftToRight() ? [keys.RIGHT_ARROW, keys.DOWN_ARROW] : [keys.LEFT_ARROW, keys.UP_ARROW]
			);
        },

        render: function () {
            // summary:
            //		Render the group with the current content types. This will
            //		destroy the current view if it exists.
            // tags:
            //		public

            this.clear();
            var that = this;

            var registry = dependency.resolve("epi.storeregistry");

            var instantTemplatesStore = registry.get("instanttemplates");

            dojo.when(instantTemplatesStore.get(that.contentLink), function (response) {
                array.forEach(response, function (contentData) {
                    var child = new ContentType({ contentData: contentData });
                    that.connect(child, "onSelect", that.onSelect);
                    that.addChild(child);
                }, that);
            });
        },

        clear: function () {
            // summary:
            //		Destroys the current view.
            // tags:
            //		public

            array.forEach(this.getChildren(), function (child) {
                this.removeChild(child);
                child.destroyRecursive();
            }, this);
        },

        _setTitleAttr: { node: "titleNode", type: "innerText" },

        _setContentTypesAttr: function (value) {
            this._set("contentTypes", value);
            if (this._created) {
                this.render();
            }
        },

        onSelect: function (item) {
            // summary:
            //		Callback that is executed when an item in this
            //		group is selected.
            // tags:
            //		callback

            topic.publish("/epi/shell/action/changeview", "instantTemplates/CreateContentView", null, {
                parent: item.parentLink,
                contentLink: item.contentLink,
                headingText: "New Instant Template",
                templateName: item.name
            });
        },

        setVisibility: function (display) {
            // summary:
            //    Set the group's visibility
            //
            // display:
            //    Flag states if the group will be shown or not.
            //
            // tags:
            //    public
            var value = (display ? "block" : "none");
            domStyle.set(this.domNode, "display", value);
        },
        getContentDataStore: function () {
            // summary:
            //      Gets the content data store from store registry if it's not already cached

            if (!this.contentDataStore) {
                var registry = dependency.resolve("epi.storeregistry");
                this.contentDataStore = registry.get("epi.cms.content.light");
            }
            return this.contentDataStore;
        },
    });
});
