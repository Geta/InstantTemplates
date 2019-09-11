// Copyright (c) Geta Digital. All rights reserved.
// Licensed under Apache-2.0. See the LICENSE file in the project root for more information

define([
    "dojo",
    "dojo/dom-class",
    "dojo/string",

    "dijit/focus",
    "dijit/_Widget",
    "dijit/_TemplatedMixin",

    "epi/i18n!epi-cms/nls/episerver.cms.widget.pagetype",
    "dojo/text!./templates/ContentType.html"
], function (dojo, domClass, string, focus, _Widget, _TemplatedMixin, i18n, template) {

    return dojo.declare([_Widget, _TemplatedMixin], {
        // summary:
        //		Widget for displaying content type information.
        //
        // tags:
        //      internal

        // templateString: [protected] String
        //		The widget template.
        templateString: template,

        // contentType: [public] Object
        //		The content type to be displayed.
        contentType: null,

        contentData: null,

        // iconTemplate: [public] String
        //		The template used when an icon image is provided.
        iconTemplate: '<img src="${0}" alt="${1}" class="epi-preview" />',

        // emptyIconTemplate: [public] String
        //		The template used when no icon image is provided.
        emptyIconTemplate: string.substitute('<div class="epi-noPreviewIcon"><span class="epi-noPreview">${0}</span></div>', [i18n.nopreview]),

        buildRendering: function () {
            // summary:
            //		Construct the UI with the initial content type.
            // tags:
            //		protected

            this.inherited(arguments);

            this.connect(this.domNode, "onclick", this._onClick);
            this.render();
        },

        render: function () {
            // summary:
            //		Render the content type information.
            // tags:
            //		public
            var data = this.contentData;


            if (data) {
                this.set("name", data.name);
                this.set("description", data.localizedDescription || i18n.nodescription);
            }
        },

        _setContentTypeAttr: function (value) {
            this._set("contentType", value);
            if (this._created) {
                this.render();
            }
        },

        _setNameAttr: { node: "nameNode", type: "innerText" },

        _setDescriptionAttr: { node: "descriptionNode", type: "innerText" },

        _setIconAttr: function (value) {
        },

        focus: function () {
            this.inherited(arguments);

            domClass.add(this.focusNode, "epi-advancedListingItemActive");

            focus.focus(this.focusNode);
        },

        _onBlur: function () {
            this.inherited(arguments);

            domClass.remove(this.focusNode, "epi-advancedListingItemActive");
        },

        _onKeyPress: function (e) {
            //Fire click when pressing the enter/space key
            if (e.keyCode === 13 || e.keyCode === 32) {
                this.onSelect(this.contentData);
            }
        },

        _onClick: function () {
            // summary:
            //    Raised when the widget is clicked.
            //
            // tags:
            //   private

            this.onSelect(this.contentData);
        },

        _onMouseOver: function () {
            domClass.add(this.focusNode, "epi-advancedListingItemActive");
        },
        _onMouseOut: function () {
            domClass.remove(this.focusNode, "epi-advancedListingItemActive");
        },

        onSelect: function (item) {
            // summary:
            //    Raised when the content type is selected.
            //
            // item:
            //    The content data.
            //
            // tags:
            //   public event
        }
    });
});