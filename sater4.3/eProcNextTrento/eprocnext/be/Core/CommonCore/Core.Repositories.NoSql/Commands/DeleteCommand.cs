﻿
using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Types;
using MongoDB.Driver;
using System;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Commands
{
    public class DeleteCommand<TIn> : AbsNoSqlCommand<TIn, bool, TIn> where TIn: class, INoSqlCollection
    {
        public DeleteCommand(INoSqlDBContext<TIn> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        protected FilterDefinition<TIn> BuildFilter(TIn param)
        {
            var filters = FilterBuilder.Eq(nameof(param._id), param._id);
            return filters;
        }

        public override bool Execute(TIn param, IClientSessionHandle session = null)
        {
            if (!ValidateHash(param))
                throw new UnauthorizedAccessException("Invalid Hash");

            var query = session is null ? Collection.DeleteOne(BuildFilter(param)) : Collection.DeleteOne(session, BuildFilter(param));
            return query.DeletedCount > 0;
        }

        public override async Task<bool> ExecuteAsync(TIn param, IClientSessionHandle session = null)
        {
            if (!ValidateHash(param))
                throw new UnauthorizedAccessException("Invalid Hash");

            var query = session is null ? await Collection.DeleteOneAsync(BuildFilter(param)) : await Collection.DeleteOneAsync(session, BuildFilter(param));
            return query.DeletedCount > 0;
        }
    }
}
