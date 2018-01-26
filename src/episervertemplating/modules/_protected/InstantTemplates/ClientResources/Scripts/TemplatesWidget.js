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
    "epi-cms/asset/HierarchicalList"
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
        HierarchicalList) {
        return declare([HierarchicalList],
        {
            showCreateContentArea: false,

            noDataMessages: { 
                    multiple: "These folders does not contain any templates", 
                    single: "This folder does not contain any templates"
                } 
        });
    });
