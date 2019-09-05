using EPiServer.Core;

namespace Geta.InstantTemplates.Sample.Models.Pages
{
    public interface IHasRelatedContent
    {
        ContentArea RelatedContentArea { get; }
    }
}
