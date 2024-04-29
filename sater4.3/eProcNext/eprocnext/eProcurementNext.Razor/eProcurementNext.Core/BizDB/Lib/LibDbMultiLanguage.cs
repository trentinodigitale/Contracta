using eProcurementNext.Application;
using eProcurementNext.Cache;
using eProcurementNext.CommonDB;
using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.BizDB
{
    public class LibDbMultiLanguage : ILibDbMultilanguage
    {
        private readonly IConfiguration _configuration;
        readonly string connString;

        public int step { get; set; }

        private readonly CommonDbFunctions cdf = new();

        public LibDbMultiLanguage(IConfiguration configuration)
        {
            connString = configuration.GetConnectionString("DefaultConnection");
            _configuration = configuration;
        }

        public LibDbMultiLanguage(string connectionstring)
        {
            connString = connectionstring;
        }

        public string CNV(string Key, string suffix = "I", int Context = 0)
        {
            return ApplicationCommon.CNV(Key, suffix, Context);
        }


        public void InitLanguagePlus(string suffix, IDictionary<string, string> KeyLanguagePlus)
        {
            string strSql;
            TSRecordSet rs;
            string? Description;
            string Key_MLG;
            string ml_lng;
            int ml_context = 0;

            Dictionary<string, object?> SqlParameters = new Dictionary<string, object?>();

            using SqlConnection conn = new SqlConnection(connString);
            conn.Open();

            //'-- recupero le stringhe del linguaggio
            strSql = @"SELECT   LTRIM(RTRIM(ML_KEY)) AS ML_KEY,
		                            ML_LNG,
		                            case when ML_Description like '%#ML.%' or ML_Description like '%#SYS.%' or ML_Description like '%#PROP.%' then dbo.CNV_ESTESA(ML_KEY, ML_LNG) 
			                             else ML_Description end as ML_Description,
		                            ML_Context
	                        FROM Lib_Multilinguismo with(nolock)"; // EX : "SELECT * FROM Lib_Multilinguismo with(nolock) "

            if (!string.IsNullOrEmpty(suffix))
            {
                strSql += " where ML_LNG = @suffix";
                SqlParameters.Add("@suffix", suffix);
            }

            rs = cdf.GetRSReadFromQuery_(strSql, connString, conn, parCollection: SqlParameters);

            if (rs is not null && rs.RecordCount > 0)
            {
                rs.MoveFirst();

                while (!rs.EOF)
                {

                    if (rs["ML_Description"] == null)
                        Description = "";
                    else
                        Description = (string)rs["ML_Description"];

                    Key_MLG = (string)rs.Fields["ML_KEY"];
                    ml_lng = (string)rs.Fields["ML_LNG"];
                    ml_context = CInt(rs.Fields["ML_Context"]);

                    //Description = RisolvoDescrizioneMultilinguismo(Description, ml_lng, Key_MLG, conn)

                    string key = UCase(ml_context + "_" + ml_lng + "_" + Key_MLG);

                    if (EProcNextCache.RedisDBEnabled)
                    {
                        ApplicationCommon.Cache.SetML(key, Description);
                    }
                    else
                    {
                        if (!KeyLanguagePlus.ContainsKey(key))
                            KeyLanguagePlus.Add(key, Description);
                    }

                    rs.MoveNext();
                }
            }
        }

        public string RisolvoDescrizioneMultilinguismo(string strML, string suffix, string strKey, SqlConnection? conn = null)
        {
            string strSql;
            TSRecordSet rs;

            if (strML.ToUpper().Contains("#ML.", StringComparison.Ordinal) || strML.ToUpper().Contains("#SYS.", StringComparison.Ordinal) || strML.ToUpper().Contains("#PROP.", StringComparison.Ordinal))
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@strKey", strKey);
                sqlParams.Add("@suffix", suffix);

                strSql = "Select dbo.CNV_ESTESA(@strKey, @suffix) as ret";

                rs = cdf.GetRSReadFromQuery_(strSql, connString, conn, parCollection: sqlParams);

                if (rs is not null)
                {
                    if (rs.RecordCount > 0)
                    {
                        rs.MoveFirst();

                        return CStr(rs["ret"]);
                    }
                }
            }

            return strML;
        }
    }
}
