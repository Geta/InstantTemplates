using EPiServer.Core;

namespace EPiServerTemplating.Models.Pages
{
    public interface IHasRelatedContent
    {
        ContentArea RelatedContentArea { get; }
    }
}
