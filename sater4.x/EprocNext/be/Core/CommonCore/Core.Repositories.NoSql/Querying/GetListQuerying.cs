using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.Interfaces;
using MongoDB.Driver;
using MongoDB.Driver.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Querying
{
    class GetListQuerying<TIn, TOut> : AbsNoSqlQuerying<TIn, IEnumerable<TOut>, TOut>, INoSqlActionAsync<IEnumerable<TOut>, TIn>
        where TIn : class, INoSqlLinqDynamicFilter
        where TOut : class, INoSqlCollection
    {
        public GetListQuerying(INoSqlDBContext<TOut> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        public override IEnumerable<TOut> Execute(TIn param, IClientSessionHandle session = null)
        {
            var queryable = session is null ? Collection.AsQueryable() : Collection.AsQueryable(session);
            var data = queryable.Where(param.Where);
            if (!(param.OrderBy is null))
                data = data.OrderBy(param.OrderBy);

            var result = data.ToList();
            result.ForEach(d => CalculateHash(d));
            return result;
        }

        public override async Task<IEnumerable<TOut>> ExecuteAsync(TIn param, IClientSessionHandle session = null)
        {
            var queryable = session is null ? Collection.AsQueryable() : Collection.AsQueryable(session);
            var query = await Task.Run(() =>
            {
                var res = queryable.Where(param.Where) as IMongoQueryable<TOut>;
                if (!(param.OrderBy is null))
                    res = res.OrderBy(param.OrderBy) as IMongoQueryable<TOut>;
                return res;
            });

            var data = await query.ToListAsync();
            data.ForEach(d => CalculateHash(d));
            return data;
        }
    }

    class GetListLinqQuerying<TOut> : AbsNoSqlQuerying<Expression<Func<TOut, bool>>, IEnumerable<TOut>, TOut>, INoSqlActionAsync<IEnumerable<TOut>, Expression<Func<TOut, bool>>> where TOut : class, INoSqlCollection
    {
        public GetListLinqQuerying(INoSqlDBContext<TOut> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        public override IEnumerable<TOut> Execute(Expression<Func<TOut, bool>> param, IClientSessionHandle session = null)
        {
            var queryable = session is null ? Collection.AsQueryable() : Collection.AsQueryable(session);
            var data = queryable.Where(param).ToList();
            data.ForEach(d => CalculateHash(d));
            return data;
        }

        public override async Task<IEnumerable<TOut>> ExecuteAsync(Expression<Func<TOut, bool>> param, IClientSessionHandle session = null)
        {
            var queryable = session is null ? Collection.AsQueryable() : Collection.AsQueryable(session);
            var data = await Task.Run(() => queryable.Where(param).ToList());
            data.ForEach(d => CalculateHash(d));
            return data;
        }
    }
}
