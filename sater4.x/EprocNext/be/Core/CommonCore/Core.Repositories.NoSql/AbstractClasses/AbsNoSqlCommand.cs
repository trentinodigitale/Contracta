using Core.Repositories.NoSql.Interfaces;
using MongoDB.Driver;

namespace Core.Repositories.NoSql.AbstractClasses
{
    public abstract class AbsNoSqlCommand<TIn, Tout, TContext> : AbsNoSqlAction<TIn, Tout, TContext> where TContext : class, INoSqlCollection
    {
        protected AbsNoSqlCommand(INoSqlDBContext<TContext> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }
    }
}
