namespace Core.Repositories.Interfaces
{
    public interface ISqlSessionProvider
    {
        long TenantId { get; }
        long AccountId { get; }
        string SecretHashKey { get; }
        string CurrentUser { get; }
    }
}
