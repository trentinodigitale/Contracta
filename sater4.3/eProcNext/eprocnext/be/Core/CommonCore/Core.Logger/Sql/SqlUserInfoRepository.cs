using Core.Logger.AbstractClasses;
using Core.Logger.HelkLogEntry.Types;
using Core.Logger.Interfaces;
using Microsoft.Extensions.Configuration;
using Dapper;
using System.Linq;
using Microsoft.AspNetCore.Http;

namespace Core.Logger.Sql
{
    public interface ISqlUserInfo: ISqlLoggerRepository<CustomerInfo, UserInfoFilter>
    { }

    public class SqlUserInfoRepository : AbsSQLLoggerRepository<CustomerInfo, UserInfoFilter>, ISqlUserInfo
    {
        private class InfoQueryResult
        {
            public long TenantId { get; set; }
            public string LoginAccount { get; set; }
            public string CustomerID { get; set; }

            public CustomerInfo GetCustomerInfo()
            {
                return new CustomerInfo
                {
                    Id = CustomerID,
                    Ts_id = LoginAccount
                };
            }
        }

        public SqlUserInfoRepository(IConfiguration config, ILoggerCache cache) : base(config, cache)
        { }

        protected CustomerInfo ExecuteDBQuery(UserInfoFilter param)
        {
            string query = $@"
            Select
	            distinct an01.AN01_ID as TenantId,
	            an03.AN03_LOGIN as LoginAccount,
	            COALESCE(an06.AN06_PARTIVA, an06.AN06_CODFISCALE) as CustomerID
            From AN01_AZIENDE an01
                join AZ01_AZIENDA az01 on az01.AZ01_ID_AN01 = an01.AN01_ID
                join AN06_ANAGEN an06 on az01.AZ01_IDANAGEN_AN06 = an06.AN06_ID
                join AN05_UTENTI_AZIENDA an05 on an05.AN05_ID_AN01 = an01.AN01_ID
                join AN03_ACCOUNT an03 on an03.AN03_ID = an05.AN05_ID_AN03
            Where
	            an03.AN03_ID = {param.User}
	            And an01.AN01_ID = {param.Tenant}";

            var result = Connection.Query<InfoQueryResult>(query).FirstOrDefault();
            return result?.GetCustomerInfo()??default;
        }

        public override CustomerInfo GetInfo(UserInfoFilter param)
        {
            CustomerInfo value = null;
            try
            {
                var cachedKey = $"Logger_Customer_Info_Tenant_{param.Tenant}_{param.User}";
                value = LoggerCache.GetValue<CustomerInfo>(cachedKey);

                if (!(value is null))
                    return value;

                value = ExecuteDBQuery(param);
                LoggerCache.SetValue(cachedKey, value);
            }
            catch { }
            return value ?? new CustomerInfo();
        }
    }
}
