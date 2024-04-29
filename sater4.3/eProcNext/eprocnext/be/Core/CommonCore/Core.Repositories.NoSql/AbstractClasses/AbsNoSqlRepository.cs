using Core.Repositories.NoSql.Commands;
using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Model;
using Core.Repositories.NoSql.Querying;
using Core.Repositories.NoSql.Types;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.AbstractClasses
{
    public abstract class AbsNoSqlRepository<TEntity> : INoSqlRepository<TEntity> where TEntity : class, INoSqlCollection, new()
    {
        protected INoSqlDBContext<TEntity> Context { get; }

        protected INoSqlSessionProvider Session { get; }

        public AbsNoSqlRepository(INoSqlDBContext<TEntity> dBContext, INoSqlSessionProvider session)
        {
            Context = dBContext;
            Session = session;
        }

        private TCommand CommandBuilder<TCommand>() where TCommand : class
        {
            return (TCommand)Activator.CreateInstance(typeof(TCommand), new object[] { Context, Session });
        }

        public virtual INoSqlDBContext<TEntity> GetDBContext()
        {
            return Context;
        }

        public virtual bool Add(TEntity obj, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<InsertCommand<TEntity>>();
            return command.Execute(obj, session);
        }

        public virtual async Task<bool> AddAsync(TEntity obj, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<InsertCommand<TEntity>>();
            return await command.ExecuteAsync(obj, session);
        }

        public virtual bool Remove(TEntity obj, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<DeleteCommand<TEntity>>();
            return command.Execute(obj, session);
        }

        public virtual async Task<bool> RemoveAsync(TEntity obj, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<DeleteCommand<TEntity>>();
            return await command.ExecuteAsync(obj, session);
        }

        public virtual bool Update(TEntity obj, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<UpdateCommand<TEntity>>();
            return command.Execute(obj, session);
        }

        public virtual async Task<bool> UpdateAsync(TEntity obj, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<UpdateCommand<TEntity>>();
            return await command.ExecuteAsync(obj, session);
        }

        public IEnumerable<TEntity> GetList(string where, string orderby = null, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<GetListQuerying<INoSqlLinqDynamicFilter, TEntity>>();
            var param = new NoSqlLinqDynamicFilter { Where = where, OrderBy = orderby };
            return command.Execute(param, session);
        }

        public async Task<IEnumerable<TEntity>> GetListAsync(string where, string orderby = null, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<GetListQuerying<INoSqlLinqDynamicFilter, TEntity>>();
            var param = new NoSqlLinqDynamicFilter { Where = where, OrderBy = orderby };
            return await command.ExecuteAsync(param, session);
        }

        public virtual TEntity Get(string id, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<GetQuerying<TEntity>>();
            return command.Execute(id, session);
        }

        public virtual async Task<TEntity> GetAsync(string id, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<GetQuerying<TEntity>>();
            return await command.ExecuteAsync(id, session);
        }

        public virtual async Task<IEnumerable<TEntity>> GetListAsync(Expression<Func<TEntity, bool>> predicate, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<GetListLinqQuerying<TEntity>>();
            return await command.ExecuteAsync(predicate, session);
        }

        public virtual IEnumerable<TEntity> GetList(Expression<Func<TEntity, bool>> predicate, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<GetListLinqQuerying<TEntity>>();
            return command.Execute(predicate, session);
        }

        public virtual PageItems<TEntity> GetList(ILookUpFilter filter, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<SearchPagedQuerying<TEntity>>();
            return command.Execute(filter, session);
        }

        public virtual async Task<PageItems<TEntity>> GetListAsync(ILookUpFilter filter, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<SearchPagedQuerying<TEntity>>();
            return await command.ExecuteAsync(filter, session);
        }

        public virtual bool Add(IEnumerable<TEntity> list, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<BulkInsertCommand<TEntity>>();
            return command.Execute(list, session);
        }

        public virtual async Task<bool> AddAsync(IEnumerable<TEntity> list, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<BulkInsertCommand<TEntity>>();
            return await command.ExecuteAsync(list, session);
        }

        public virtual bool Update(IEnumerable<TEntity> list, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<BulkUpdateCommand<TEntity>>();
            return command.Execute(list, session);
        }

        public virtual async Task<bool> UpdateAsync(IEnumerable<TEntity> list, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<BulkUpdateCommand<TEntity>>();
            return await command.ExecuteAsync(list, session);
        }

        public virtual bool Remove(IEnumerable<TEntity> list, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<BulkDeleteCommand<TEntity>>();
            return command.Execute(list, session);
        }

        public virtual async Task<bool> RemoveAsync(IEnumerable<TEntity> list, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<BulkDeleteCommand<TEntity>>();
            return await command.ExecuteAsync(list, session);
        }

        public virtual async Task<IEnumerable<TOutput>> GetListAsync<TOutput>(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<PipelineQuerying<TEntity, TOutput>>();
            return await command.GetAsync(aggregatePipeline, session);
        }

        public virtual IEnumerable<TOutput> GetList<TOutput>(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null)
        {
            var command = CommandBuilder<PipelineQuerying<TEntity, TOutput>>();
            return command.Get(aggregatePipeline, session);
        }

        public bool ValidateHash(ObjectId id, uint hash)
        {
            if(typeof(INoSqlTenantSecurityCollection).IsAssignableFrom(typeof(TEntity)))
            {
                var entity = new TEntity { _id = id };
                if(entity is INoSqlTenantSecurityCollection entitySecurity)
                    entitySecurity.Hash = hash;

                var command = CommandBuilder<GetQuerying<TEntity>>();
                return command.ValidateHash(entity);
            }

            return true;
        }

        public void CalculateHash(TEntity obj)
        {
            if (typeof(INoSqlTenantSecurityCollection).IsAssignableFrom(typeof(TEntity)))
            {
                var command = CommandBuilder<GetQuerying<TEntity>>();
                command.CalculateHash(obj);
            }
        }
    }
}
