using MongoDB.Driver;
using System;
using System.Threading.Tasks;
using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.AbstractClasses;
using System.Collections.Generic;
using System.Linq;
using System.Collections.Concurrent;
using MongoDB.Bson;

namespace Core.Repositories.NoSql.Commands
{
    public class BulkUpdateCommand<TIn> : AbsNoSqlCommand<IEnumerable<TIn>, bool, TIn> where TIn : class, INoSqlCollection
    {
        public BulkUpdateCommand(INoSqlDBContext<TIn> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        private FilterDefinition<TIn> BuildFilter(TIn param)
        {
            var filters = FilterBuilder.Eq(nameof(param._id), param._id);
            return filters;
        }

        public override bool Execute(IEnumerable<TIn> param, IClientSessionHandle session = null)
        {
            if (!param.All(p => p._id == ObjectId.Empty || ValidateHash(p)))
                throw new UnauthorizedAccessException("Invalid Hash");

            var updates = new List<WriteModel<TIn>>();

            param.ToList().ForEach(doc =>
             {
                 if (doc._id == ObjectId.Empty)
                     updates.Add(new InsertOneModel<TIn>(doc));
                 else
                     updates.Add(new ReplaceOneModel<TIn>(BuildFilter(doc), doc));
             });

            var result = session is null ? Collection.BulkWrite(updates) : Collection.BulkWrite(session, updates);
            return result.ModifiedCount > 0;
        }

        public override async Task<bool> ExecuteAsync(IEnumerable<TIn> param, IClientSessionHandle session = null)
        {
            if (!param.All(p => p._id == ObjectId.Empty || ValidateHash(p)))
                throw new UnauthorizedAccessException("Invalid Hash");

            var updates = new ConcurrentBag<WriteModel<TIn>>();
            var tasks = param.Select(async doc =>
                    await Task.Run(() =>
                    {
                        if (doc._id == ObjectId.Empty)
                            updates.Add(new InsertOneModel<TIn>(doc));
                        else
                            updates.Add(new ReplaceOneModel<TIn>(BuildFilter(doc), doc));
                    }));

            await Task.WhenAll(tasks);

            var result = session is null ? await Collection.BulkWriteAsync(updates) : await Collection.BulkWriteAsync(session, updates);
            return result.ModifiedCount > 0;
        }
    }
}
