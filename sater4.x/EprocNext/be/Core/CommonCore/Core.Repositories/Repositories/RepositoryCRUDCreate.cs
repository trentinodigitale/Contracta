using Core.Repositories.Interfaces;
using RepoDb;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace Core.Repositories.Repositories
{
    public partial class RepositoryCrud<TDto, TModel, TRes> where TModel : class, new() where TDto : class, IDtoResolver, new() where TRes : IResolver, new()
    {
        #region Insert methods

        public virtual long? Insert(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var model = _map.Map<TModel>(entityToInsert);
            var result = Connection.Insert(model);
            return (long)result;
        }

        public virtual async Task<long?> InsertAsync(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var model = _map.Map<TModel>(entityToInsert);
            var result = await Connection.InsertAsync(model);
            return (long)result;
        }

        public virtual Tuple<TKey, uint> Insert<TKey>(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var model = _map.Map<TModel>(entityToInsert);
            var tKey = Connection.Insert<TModel, TKey>(model);
            var keyHash = GetHash(tKey.ToString());
            return new Tuple<TKey, uint>(tKey, keyHash);
        }

        public virtual async Task<Tuple<TKey, uint>> InsertAsync<TKey>(long tenantId, TDto entityToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var model = _map.Map<TModel>(entityToInsert);
            var tKey = await Connection.InsertAsync<TModel, TKey>(model);
            var keyHash = GetHash(tKey.ToString());
            return new Tuple<TKey, uint>(tKey, keyHash);
        }

        private List<TModel> MapEntities(IEnumerable<TDto> entitiesToInsert)
        {
            return entitiesToInsert.Select(e => _map.Map<TModel>(e)).ToList();
        }

        public virtual int BatchInsert(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            return Connection.InsertAll(MapEntities(entitiesToInsert), commandTimeout: commandTimeout, transaction: transaction);
        }

        public virtual async Task<int> BatchInsertAsync(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            return await Connection.InsertAllAsync(MapEntities(entitiesToInsert), commandTimeout: commandTimeout, transaction: transaction);
        }

        public virtual int BulkInsert(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var models = MapEntities(entitiesToInsert); 
           return SqlServerConnection.BulkInsert(models);
        }

        public async virtual Task<int> BulkInsertAsync(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            var models = MapEntities(entitiesToInsert);
            return await SqlServerConnection.BulkInsertAsync(models);
        }

        public virtual IEnumerable<TDto> BulkInsert(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null, bool calcHash = true, bool isReturnIdentity = true)
        {
            var models = MapEntities(entitiesToInsert);
            var insertedRows = SqlServerConnection.BulkInsert(models, isReturnIdentity: isReturnIdentity, usePhysicalPseudoTempTable: true, transaction: transaction as SqlTransaction, bulkCopyTimeout: commandTimeout);
            return models.Select(m => CalcHash(m, calcHash));
        }

        public async virtual Task<IEnumerable<TDto>> BulkInsertAsync(long tenantId, IEnumerable<TDto> entitiesToInsert, IDbTransaction transaction = null, int? commandTimeout = null, bool calcHash = true, bool isReturnIdentity = true)
        {
            var models = MapEntities(entitiesToInsert);
            var insertedRows = await SqlServerConnection.BulkInsertAsync(models, isReturnIdentity: isReturnIdentity, usePhysicalPseudoTempTable: true, transaction: transaction as SqlTransaction, bulkCopyTimeout: commandTimeout);
            return models.Select(m => CalcHash(m, calcHash));
        }

        #endregion Insert methods
    }
}
