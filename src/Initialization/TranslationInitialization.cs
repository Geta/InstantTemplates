using System;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Web;
using EPiServer.Framework;
using EPiServer.Framework.Initialization;
using EPiServer.Framework.Localization;
using EPiServer.Framework.Localization.XmlResources;

namespace EPiServer.InstantTemplates.Initialization
{
    [InitializableModule]
    public class TranslationInitialization : IInitializableModule
    {
        public void Initialize(InitializationEngine context)
        {
            var localizationService = context.Locate.Advanced.GetInstance<LocalizationService>() as ProviderBasedLocalizationService;
            if (localizationService != null)
            {
                string langFolder = HttpContext.Current.Server.MapPath("~/lang");
                if (Directory.Exists(langFolder))
                {
                    var configValues = new NameValueCollection { { FileXmlLocalizationProvider.PhysicalPathKey, langFolder } };
                    var localizationProvider = new FileXmlLocalizationProvider();
                    localizationProvider.Initialize("languageFiles", configValues);
                    localizationService.AddProvider(localizationProvider);
                }
            }
        }
        
        public void Uninitialize(InitializationEngine context)
        {
        }
    }
}