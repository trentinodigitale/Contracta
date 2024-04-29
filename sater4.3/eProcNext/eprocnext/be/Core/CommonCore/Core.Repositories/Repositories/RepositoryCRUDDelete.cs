using Core.Repositories.Common;
using Core.Repositories.Interfaces;
// using Dapper;
using RepoDb;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Core.Repositories.Repositories
{
    public partial class RepositoryCrud<TDto, TModel, TRes> where TModel : class, new() where TDto : class, IDtoResolver, new() where TRes : IResolver, new()
    {
        #region Delete methods

        public virtual int Delete(object id, uint hash, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!ValidateHash(id?.ToString(), hash)) 
                    throw new UnauthorizedAccessException();
            
            return Connection.Delete(typeof(TDto).DbTableName(), id);
        }

        public virtual int Delete(TDto entityToDelete, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!HasValidEntityHash(entityToDelete, applySecurityHash))
                    throw new UnauthorizedAccessException();
            
            return Connection.Delete(_map.Map<TModel>(entityToDelete));
        }

        public virtual async Task<int> DeleteAsync(object id, uint hash, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                if (!ValidateHash(id?.ToString(), hash)) 
                    throw new UnauthorizedAccessException();
            
            return await Connection.DeleteAsync(typeof(TDto).DbTableName(), id);
        }

        public virtual async Task<int> DeleteAsync(TDto entityToDelete, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (!HasValidEntityHash(entityToDelete, applySecurityHash)) throw new UnauthorizedAccessException();
            return await Connection.DeleteAsync(_map.Map<TModel>(entityToDelete));
        }

        private void BuildDeleteParametersAndValues<T>(StringBuilder sb, IEnumerable<long> ids)
        {
            string whereCondition = "";
            foreach (var property in typeof(T).GetProperties())
            {
                if (property.GetCustomAttribute<Dapper.KeyAttribute>() != null)
                {
                    whereCondition = $" WHERE {property.Name} IN ({string.Join(',', ids)})  ";
                    break;
                }
            }
            sb.Append(whereCondition);
        }

        private string BuildBulkDeleteQuery(IEnumerable<long> idToDelete)
        {
            var sb = new StringBuilder();
            string updateStr = $"DELETE FROM {typeof(TDto).DbTableName()} ";
            sb.Append(updateStr);
            BuildDeleteParametersAndValues<TModel>(sb, idToDelete);
            sb.Append("; ");
            return sb.ToString();
        }

        public virtual int BatchDelete(IEnumerable<(long id, uint hash)> ids, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var id in ids)
                    if (!ValidateHash($"{id.id}", id.hash)) throw new UnauthorizedAccessException();

            string query = BuildBulkDeleteQuery(ids.Select(e => e.id));
            return Connection.ExecuteScalar<int>(query, transaction: transaction, commandTimeout: commandTimeout,
                commandType: CommandType.Text);
        }

        public virtual async Task<int> BatchDeleteAsync(IEnumerable<(long id, uint hash)> ids, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var id in ids)
                    if (!HasValidEntityHash(id, applySecurityHash)) throw new UnauthorizedAccessException();

            string query = BuildBulkDeleteQuery(ids.Select(e => e.id));
            return await Connection.ExecuteScalarAsync<int>(query, transaction: transaction, commandTimeout: commandTimeout,
                commandType: CommandType.Text);
        }

        public virtual int BulkDelete(IEnumerable<TDto> entities, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if(applySecurityHash)
                foreach(var e in entities)
                    if (!HasValidEntityHash(e, applySecurityHash)) throw new UnauthorizedAccessException();

            var models = MapEntities(entities);
            var sqlConnection = Connection as SqlConnection;
            var deletedRows = sqlConnection.BulkDelete(models, usePhysicalPseudoTempTable: true, transaction: transaction as SqlTransaction, bulkCopyTimeout: commandTimeout);
            return deletedRows;
        }

        public virtual async Task<int> BulkDeleteAsync(IEnumerable<TDto> entities, IDbTransaction transaction = null, int? commandTimeout = null, bool applySecurityHash = true)
        {
            if (applySecurityHash)
                foreach (var e in entities)
                    if (!HasValidEntityHash(e, applySecurityHash)) throw new UnauthorizedAccessException();

            var models = MapEntities(entities);
            var sqlConnection = Connection as SqlConnection;
            var deletedRows = await sqlConnection.BulkDeleteAsync(models, usePhysicalPseudoTempTable: true, transaction: transaction as SqlTransaction, bulkCopyTimeout: commandTimeout);
            return deletedRows;
        }

        // ** Attention Do Not expose this method to webapi, SecurityHash not checked **
        public virtual int Delete(String whereCondition, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            string query = $"DELETE FROM {typeof(TDto).DbTableName()} WHERE {Normalizer.NormalizeWhere(whereCondition)} ;";
 
            return Connection.ExecuteScalar<int>(query, transaction: transaction, commandTimeout: commandTimeout, commandType: CommandType.Text);
        }

        // ** Attention Do Not expose this method to webapi, SecurityHash not checked **
        public virtual async Task<int> DeleteAsync(String whereCondition, IDbTransaction transaction = null, int? commandTimeout = null)
        {
            string query = $"DELETE FROM {typeof(TDto).DbTableName()} WHERE {Normalizer.NormalizeWhere(whereCondition)} ;";

            return await Connection.ExecuteScalarAsync<int>(query, transaction: transaction, commandTimeout: commandTimeout, commandType: CommandType.Text);
        }

        #endregion Delete methods
    }
}
