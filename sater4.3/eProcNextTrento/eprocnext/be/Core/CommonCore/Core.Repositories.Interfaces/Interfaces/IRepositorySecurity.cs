namespace Core.Repositories.Interfaces
{
    public interface IRepositorySecurity
    {
        uint GetHash(string id);

        bool ValidateHash(string id, uint hash);

        bool HasValidEntityHash<TDto>(TDto dto, bool applySecurityHas);
    }
}
