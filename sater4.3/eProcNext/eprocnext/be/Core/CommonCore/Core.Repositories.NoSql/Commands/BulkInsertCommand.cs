using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.Interfaces;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Commands
{
    public class BulkInsertCommand<TIn> : AbsNoSqlCommand<IEnumerable<TIn>, bool, TIn> where TIn : class, INoSqlCollection
    {
        public BulkInsertCommand(INoSqlDBContext<TIn> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        public override bool Execute(IEnumerable<TIn> param, IClientSessionHandle session = null)
        {
            try
            {
                if (session is null)
                    Collection.InsertMany(param);
                else
                    Collection.InsertMany(session, param);

                param.ToList().ForEach(p => CalculateHash(p));
                return true;
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }

        public override async Task<bool> ExecuteAsync(IEnumerable<TIn> param, IClientSessionHandle session = null)
        {
            try
            {
                if (session is null)
                    await Collection.InsertManyAsync(param);
                else
                    await Collection.InsertManyAsync(session, param);

                var list = param.ToList();
                var tasks = list.Select(p => Task.Run(() => CalculateHash(p)));
                await Task.WhenAll(tasks);
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }
    }
}
