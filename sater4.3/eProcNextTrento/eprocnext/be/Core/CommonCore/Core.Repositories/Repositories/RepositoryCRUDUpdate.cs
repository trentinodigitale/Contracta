using Core.Repositories.Interfaces;
using RepoDb;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Core.Repositories.Repositories
{
    public partial class RepositoryCrud<TDto, TModel, TRes> where TModel : class, new() where TDto : class, IDtoResolver, new() where TRes : IResolver, new()
    {
        #region Update methods

        public virtual int Update(TDto entityToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!HasValidEntityHash(entityToUpdate, applySecurityHash))
                    throw new UnauthorizedAccessException();
            
            return Connection.Update(_map.Map<TModel>(entityToUpdate), commandTimeout: commandTimeout, transaction: transaction);
        }

        public virtual int Update<TWhat>(TDto entityToUpdate, TWhat what, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!HasValidEntityHash(entityToUpdate, applySecurityHash))
                    throw new UnauthorizedAccessException();

            return Connection.Update(_map.Map<TModel>(entityToUpdate), what, commandTimeout: commandTimeout, transaction: transaction);
        }

        public virtual async Task<int> UpdateAsync(TDto entityToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!HasValidEntityHash(entityToUpdate, applySecurityHash)) 
                    throw new UnauthorizedAccessException();
            
            return await Connection.UpdateAsync(_map.Map<TModel>(entityToUpdate), commandTimeout: commandTimeout, transaction: transaction);
        }

        public virtual async Task<int> UpdateAsync<TWhat>(TDto entityToUpdate, TWhat what, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!HasValidEntityHash(entityToUpdate, applySecurityHash))
                    throw new UnauthorizedAccessException();

            return await Connection.UpdateAsync(_map.Map<TModel>(entityToUpdate), what, commandTimeout: commandTimeout, transaction: transaction);
        }

        //private string BuildBatchUpdateQuery(IEnumerable<TDto> entitiesToInsert)
        //{
        //    var sb = new StringBuilder();
        //    string updateStr = $"UPDATE {typeof(TDto).DbTableName()} SET ";
        //    foreach (var entityDto in entitiesToInsert)
        //    {
        //        sb.Append(updateStr);
        //        var model = _map.Map<TModel>(entityDto);
        //        Normalizer.BuildUpdateParametersAndValues(sb, model);
        //        sb.Append("; ");
        //    }

        //    return sb.ToString();
        //}

        public virtual int BatchUpdate(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var entityToUpdate in entitiesToUpdate)
                    if (!HasValidEntityHash(entityToUpdate, applySecurityHash)) 
                        throw new UnauthorizedAccessException();

            var models = MapEntities(entitiesToUpdate);
            return Connection.UpdateAll(models, transaction: transaction, commandTimeout: commandTimeout);
        }

        public virtual async Task<int> BatchUpdateAsync(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var entityToUpdate in entitiesToUpdate)
                    if (!HasValidEntityHash(entityToUpdate, applySecurityHash))
                            throw new UnauthorizedAccessException();
            
            var models = MapEntities(entitiesToUpdate);
            return await Connection.UpdateAllAsync(models, transaction: transaction, commandTimeout: commandTimeout);
        }

        public virtual int BulkUpdate(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var entityToUpdate in entitiesToUpdate)
                    if (!HasValidEntityHash(entityToUpdate, applySecurityHash)) 
                        throw new UnauthorizedAccessException();

            var models = MapEntities(entitiesToUpdate);
            return SqlServerConnection.BulkUpdate(models, transaction: transaction as SqlTransaction, bulkCopyTimeout: commandTimeout);
        }

        public virtual async Task<int> BulkUpdateAsync(long tenantId, IEnumerable<TDto> entitiesToUpdate, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var entityToUpdate in entitiesToUpdate)
                    if (!HasValidEntityHash(entityToUpdate, applySecurityHash))
                        throw new UnauthorizedAccessException();

            var models = MapEntities(entitiesToUpdate);
            return await SqlServerConnection.BulkUpdateAsync(models, transaction: transaction as SqlTransaction, bulkCopyTimeout: commandTimeout);
        }

        #endregion Update methods
    }
}
