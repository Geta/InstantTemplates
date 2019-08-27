define("instantTemplates/templatesWidget", [
    // dojo
    "dojo/_base/array",
    "dojo/_base/declare",
    "dojo/_base/lang",
    "dojo/aspect",
    "dojo/dom-construct",
    "dojo/dom-geometry",
    "dojo/dom-class",
    "dojo/on",
    "epi-cms/asset/HierarchicalList",
    // Resources
    "epi/i18n!epi-cms/nls/",
    //Helpers
    "instantTemplates/helpers"
],
    function (
        // dojo
        array,
        declare,
        lang,
        aspect,
        domConstruct,
        domGeometry,
        domClass,
        on,
        HierarchicalList,
        customLocalization,
        helpers
    ) {
        return declare([HierarchicalList],
        {
            showCreateContentArea: false,

            noDataMessages: { 
                multiple: helpers.translate(customLocalization.episerver.cms.messages.nodatamultiple, "These folders does not contain any templates"), 
                single: helpers.translate(customLocalization.episerver.cms.messages.nodatasingle, "This folder does not contain any templates")
            } 
        });
    });
