using eProcurementNext.CommonDB;
using Microsoft.Extensions.Configuration;
using System.Data;
using SysVars = System.Collections.Generic.Dictionary<string, string>;

namespace eProcurementNext.BizDB
{
    //using SysVars = List<KeyValuePair<string, dynamic>>;

    public class GlobalAsa
    {
        private readonly IConfiguration _configuration;
        private string _connectionString;

        public GlobalAsa(IConfiguration configuration)
        {
            this._configuration = configuration;
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public SysVars GetSysVariables()
        {
            SysVars vars = new SysVars();

            string strSql = "select DZT_Name, DZT_ValueDef from lib_dictionary with(nolock) where dzt_name like 'sys_%' and dzt_module = 'Systema'";
            CommonDbFunctions cdf = new CommonDbFunctions();
            DataTable? dt = cdf.GetRSReadFromQuery_(strSql, _connectionString).dt;

            if (dt != null && dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    string key = ((string)dr["DZT_Name"]).Trim().Substring(4);
                    string value = (string)dr["DZT_ValueDef"];

                    vars.Add(key, value);
                }
            }

            return vars;
        }
    }
}
