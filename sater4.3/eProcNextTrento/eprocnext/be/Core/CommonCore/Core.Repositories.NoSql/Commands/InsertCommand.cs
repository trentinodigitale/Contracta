using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.Interfaces;
using MongoDB.Driver;
using System;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Commands
{
    public class InsertCommand<TIn> : AbsNoSqlCommand<TIn, bool, TIn> where TIn : class, INoSqlCollection
    {
        public InsertCommand(INoSqlDBContext<TIn> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }

        public override bool Execute(TIn param, IClientSessionHandle session = null)
        {
           // try
          //  {
                if(session is null)
                    Collection.InsertOne(param, new InsertOneOptions { BypassDocumentValidation = true });
                else
                    Collection.InsertOne(session, param, new InsertOneOptions { BypassDocumentValidation = true });

                CalculateHash(param);
                return true;
          /*}
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }*/
        }

        public override async Task<bool> ExecuteAsync(TIn param, IClientSessionHandle session = null)
        {
          //  try
          //  {
                if (session is null)
                    await Collection.InsertOneAsync(param, new InsertOneOptions { BypassDocumentValidation = true });
                else
                    await Collection.InsertOneAsync(session, param, new InsertOneOptions { BypassDocumentValidation = true });

                CalculateHash(param);
                return true;
          /* }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }*/
        }
    }
}
