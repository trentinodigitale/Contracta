using Core.Repositories.NoSql.Interfaces;

namespace Core.Repositories.NoSql.AbstractClasses
{
    public abstract class AbsNoSqlQuerying<TIn, Tout, TContext> : AbsNoSqlAction<TIn, Tout, TContext> where TContext : class, INoSqlCollection
    {
        public AbsNoSqlQuerying(INoSqlDBContext<TContext> dBContext, INoSqlSessionProvider session) : base(dBContext, session)
        { }
    }
}
