using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.DataAnnotations;
using Geta.InstantTemplates.Sample.Models;
using Geta.InstantTemplates.Sample.Models.Pages;
using System.ComponentModel.DataAnnotations;

namespace Geta.InstantTemplates.Sample
{
    [SiteContentType(GUID = "0877D78B-8673-4CF9-9F78-3E50C30C4479",
        GroupName = Geta.InstantTemplates.Sample.Global.GroupNames.Specialized,
        DisplayName = "Find GDPR API Demo Page")]
    public class GDPRApiDemoPage : SitePageData, ISearchPage
    {
    }
}
