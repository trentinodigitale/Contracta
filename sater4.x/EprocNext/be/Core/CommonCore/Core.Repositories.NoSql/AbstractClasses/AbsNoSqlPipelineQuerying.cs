using Core.Repositories.NoSql.Interfaces;
using NeoSmart.Hashing.XXHash.Core;
using System.Text;

namespace Core.Repositories.NoSql.AbstractClasses
{
    public abstract class AbsNoSqlPipelineQuerying
    {
        protected INoSqlSessionProvider Session { get; }

        public AbsNoSqlPipelineQuerying(INoSqlSessionProvider session)
        {
            Session = session;
        }

        protected void CalculateHash<T>(T obj)
        {
            if (obj is INoSqlTenantSecurityCollection securityParam)
            {
                string messageToSign = $"{securityParam._id}{Session?.TenantId}{Session?.AccountId}{Session?.SecretHashKey}";
                securityParam.Hash = XXHash.XXH32(Encoding.ASCII.GetBytes(messageToSign));
            }
        }
    }
}
