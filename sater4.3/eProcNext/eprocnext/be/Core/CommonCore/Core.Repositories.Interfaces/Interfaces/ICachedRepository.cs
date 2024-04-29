using System.Collections.Generic;
using System.Threading.Tasks;

namespace Core.Repositories.Interfaces
{
    public interface ICachedRepository<TDto> where TDto : class, IDtoResolver, ISecurityDTO, new()
    {
        TDto GetCachedData<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter;

        Task<TDto> GetCachedDataAsync<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter;

        IEnumerable<TDto> GetCachedList<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter;

        Task<IEnumerable<TDto>> GetCachedListAsync<TFilter>(TFilter filter) where TFilter : class, IQueryingFilter;
    }
}
