using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.Interfaces;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Linq;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Querying
{
    class GetQuerying<TOut> : AbsNoSqlQuerying<string, TOut, TOut>, INoSqlActionAsync<TOut, string> where TOut : class, INoSqlCollection
    {
        public GetQuerying(INoSqlDBContext<TOut> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        private FilterDefinition<TOut> BuildFilter(string param)
        {
            return Builders<TOut>.Filter.Eq(nameof(INoSqlCollection._id), ObjectId.Parse(param));
        }

        public override TOut Execute(string param, IClientSessionHandle session = null)
        {
            var find = session is null ? Collection.Find(BuildFilter(param)) : Collection.Find(session, BuildFilter(param));
            var data = find.FirstOrDefault();
            CalculateHash(data);
            return data;
        }

        public override async Task<TOut> ExecuteAsync(string param, IClientSessionHandle session = null)
        {
            var find = session is null ? await Collection.FindAsync(BuildFilter(param)) : await Collection.FindAsync(session, BuildFilter(param));
            var data = find.FirstOrDefault();
            CalculateHash(data);
            return data;
        }
    }
}
