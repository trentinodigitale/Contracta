using EprocNext.Repositories.Models;
using Core.Repositories.Interfaces;

namespace EprocNext.Repositories.Interfaces
{
    /// <summary>
    /// This is the repository interface based on CRUD Repository
    /// </summary>
    public partial interface IAziendeRepository: IRepositoryCrud<AziendeDTO>
    {
        // Define extension methods here
    }

    /// <summary>
    /// This is the querying interface for querying data with caching
    /// </summary>
    public partial interface IAziendeQuerying: ICachedRepository<AziendeDTO>
    {
        // Define extension methods here
    }
}
