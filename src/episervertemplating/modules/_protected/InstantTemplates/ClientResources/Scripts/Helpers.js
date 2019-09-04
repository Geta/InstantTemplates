define("instantTemplates/helpers", [ ],
    function () {
        return {
            translate: function (translation, fallback) {
                if (translation != null)
                    return translation;

                return fallback;
            },
        };
    });