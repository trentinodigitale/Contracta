using Core.Repositories.NoSql.Model;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Interfaces
{
    public interface IPipelineQuerying<TContext, TOutput>
    {
        Task<IEnumerable<TOutput>> GetAsync(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null);

        IEnumerable<TOutput> Get(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null);

        BsonDocument BuildMatchStage<T>(BsonDocument startMatchFilter, LookUpNoSqlFilter filter);

        BsonDocument BuildSortStage<T>(BsonDocument startSortFilter, LookUpNoSqlFilter filter);
    }
}
