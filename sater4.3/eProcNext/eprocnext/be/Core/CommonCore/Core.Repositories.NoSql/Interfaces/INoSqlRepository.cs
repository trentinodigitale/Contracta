using Core.Repositories.NoSql.Model;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlRepository<TEntity> where TEntity : class, INoSqlCollection
    {
        #region IMongoDbContext - Help function
        INoSqlDBContext<TEntity> GetDBContext();
        bool ValidateHash(ObjectId id, uint hash);
        void CalculateHash(TEntity obj);
        #endregion

        #region Single Command operation - Add / Update / Remove
        bool Add(TEntity obj, IClientSessionHandle session = null);
        Task<bool> AddAsync(TEntity obj, IClientSessionHandle session = null);
        bool Update(TEntity obj, IClientSessionHandle session = null);
        Task<bool> UpdateAsync(TEntity obj, IClientSessionHandle session = null);
        bool Remove(TEntity obj, IClientSessionHandle session = null);
        Task<bool> RemoveAsync(TEntity obj, IClientSessionHandle session = null);
        #endregion

        #region Bulk Command operation - Add / Update / Remove
        bool Add(IEnumerable<TEntity> list, IClientSessionHandle session = null);
        Task<bool> AddAsync(IEnumerable<TEntity> list, IClientSessionHandle session = null);
        bool Update(IEnumerable<TEntity> list, IClientSessionHandle session = null);
        Task<bool> UpdateAsync(IEnumerable<TEntity> list, IClientSessionHandle session = null);
        bool Remove(IEnumerable<TEntity> list, IClientSessionHandle session = null);
        Task<bool> RemoveAsync(IEnumerable<TEntity> list, IClientSessionHandle session = null);
        #endregion

        #region Querying Operation - Get-Single / Get-List / Get-Paging
        TEntity Get(string id, IClientSessionHandle session = null);
        Task<TEntity> GetAsync(string id, IClientSessionHandle session = null);
        IEnumerable<TEntity> GetList(Expression<Func<TEntity, bool>> where, IClientSessionHandle session = null);
        Task<IEnumerable<TEntity>> GetListAsync(Expression<Func<TEntity, bool>> where, IClientSessionHandle session = null);
        IEnumerable<TEntity> GetList(string where, string orderby = null, IClientSessionHandle session = null);
        Task<IEnumerable<TEntity>> GetListAsync(string where, string orderby = null, IClientSessionHandle session = null);
        PageItems<TEntity> GetList(ILookUpFilter filter, IClientSessionHandle session = null);
        Task<PageItems<TEntity>> GetListAsync(ILookUpFilter filter, IClientSessionHandle session = null);
        #endregion

        #region Aggregation Pipeline Operation
        Task<IEnumerable<TOutput>> GetListAsync<TOutput>(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null);
        IEnumerable<TOutput> GetList<TOutput>(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null);
        #endregion
    }
}
