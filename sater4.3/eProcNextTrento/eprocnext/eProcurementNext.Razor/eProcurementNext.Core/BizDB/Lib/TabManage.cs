using eProcurementNext.CommonDB;
using eProcurementNext.Session;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.BizDB
{
    public class TabManage : ITabManage
    {
        private IConfiguration configuration;
        private DbProfiler profiler;
        private string ConnString = string.Empty;
        CommonDbFunctions cdf = new CommonDbFunctions();
        public TabManage(IConfiguration Configuration)
        {
            configuration = Configuration;
            profiler = new DbProfiler(configuration);
            ConnString = configuration.GetConnectionString("DefaultConnection");
        }
        //public Dictionary<string, dynamic> GetRsReadFromQuery(string strSql)
        //{
        //    Dictionary<string, dynamic> rs = new Dictionary<string, dynamic>();
        //    rs = Utils.ModMonitor.GetRSReadFromQuery(strSql, configuration.GetConnectionString("DefaultConnection"));
        //    return rs;
        //}

        public string GetValue(string strRec, string strLen, string strType)
        {
            string result = string.Empty;  // sostituisce ilrisultato della funzione in visual basic
            string[] vetLen;
            string s = string.Empty;

            vetLen = strLen.Split('-');

            result = CommonModule.Basic.MidVb6(strRec, Convert.ToInt32(vetLen[0]), Convert.ToInt32(vetLen[1]));
            s = result;

            if (strType == "f")
            {
                //' se vetLen(2) � numerico contiene il numero di decimali
                //' altrimenti il carattere separatore da sostituire con il punto

                if (CommonModule.Basic.IsNumeric(vetLen[2]))
                {
                    result = CommonModule.Basic.Left(result, (Convert.ToInt32(vetLen[1]) - Convert.ToInt32(vetLen[2]))) + "." + CommonModule.Basic.Right(result, Convert.ToInt32(vetLen[2]));
                }
                else
                {
                    result = Strings.Replace(result, vetLen[2], ".", 1, 1, CompareMethod.Text);
                    // result = result.Replace(vetLen[2], ".", StringComparison.CurrentCultureIgnoreCase); // TODO: verificare
                }
            }
            else if (strType == "d")
            {
                if (string.IsNullOrEmpty(result.Trim()))
                {
                    result = "";
                }
                else
                {
                    result = $"'{CommonModule.Basic.MidVb6(result, 1, 4)}-{CommonModule.Basic.MidVb6(result, 5, 2)}-{CommonModule.Basic.MidVb6(result, 7, 2)}'";
                }
            }
            else if (strType == "s")
            {
                s = s.Replace(@"'", @"''");
                result = $"'{s}'";
            }

            return result;
        }

        private void AddRecord(SqlConnection cnLocal, string strLineRec, string strTableName, string strCol, string strTypeCol, string strColLen)
        {
            string[] VetCol;
            string[] VetType;
            string[] VetLen;
            int ncol = 0;
            int i = 0;

            string strSql = string.Empty;

            VetCol = strCol.Split('#');
            VetType = strTypeCol.Split('#');
            VetLen = strColLen.Split('#');

            ncol = VetCol.GetUpperBound(0);

            strSql = $"Insert into {strTableName.Replace(" ", "")} ({strCol.Replace("#", ",")}) values ( ";
            try
            {
                // ciclo su tutte le colonne
                for (i = 0; i < ncol; i++)
                {
                    //'-- per ogni colonna estraggo il valore aggiungendolo alla statement sql
                    strSql += GetValue(strLineRec, VetLen[i], VetType[i]);

                    //'-- aggiungo la virgola di separazione valore
                    if (i < ncol) { strSql += ","; }
                }

                strSql += " )";

                cdf.Execute(strSql, configuration.GetConnectionString("DefaultConnection"), cnLocal);
            }
            catch
            {
                throw new NotImplementedException();
            }
        }

        public void ExecSql(string strSql, string? strConnectionString, SqlConnection? conn = null, Dictionary<string, object?>? parCollection = null)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            cdf.Execute(strSql, strConnectionString, conn, parCollection: parCollection);
        }


        public void traceDB(string messaggio, string contesto, eProcurementNext.Session.ISession session, string strConnString, SqlConnection? parConnection = null, string? sessionIdASP = "", string? sessionIdApp = "", string idDoc = "NULL")
        {
            string strSql = string.Empty;
            string attivaTrace = string.Empty;
            int? idPfu;
            int? localIdDoc;

            if (!string.IsNullOrEmpty(Application.ApplicationCommon.Application["ATTIVA_TRACE"]))
            {
                attivaTrace = CStr(Application.ApplicationCommon.Application["ATTIVA_TRACE"]);
            }

            if (attivaTrace.ToUpper() == "YES")
            {
                string? tmpIdPfu = session[SessionProperty.SESSION_USER] as string;

                if (String.IsNullOrEmpty(tmpIdPfu) || !CommonModule.Basic.IsNumeric(tmpIdPfu))
                {
                    idPfu = null;
                }
                else
                {
                    idPfu = CInt(tmpIdPfu);
                }


                if (string.IsNullOrEmpty(idDoc) || idDoc.ToUpper() == "NULL" || !CommonModule.Basic.IsNumeric(idDoc))
                {
                    localIdDoc = null;
                }
                else
                {
                    localIdDoc = CInt(idDoc);
                }

                var sqlParams = new Dictionary<string, object?>();

                sqlParams.Add("@contesto", contesto);
                sqlParams.Add("@sessionIdASP", sessionIdASP);
                sqlParams.Add("@sessionIdApp", sessionIdApp);
                sqlParams.Add("@idPfu", idPfu);
                sqlParams.Add("@idDoc", localIdDoc);
                sqlParams.Add("@messaggio", messaggio);

                strSql = "INSERT INTO CTL_TRACE (contesto,sessionIdASP,sessionIdApp,idpfu,idDoc,descrizione) VALUES ( @contesto,@sessionIdASP,@sessionIdApp,@idPfu,@idDoc,@messaggio)";

                CommonDbFunctions cdf = new CommonDbFunctions();
                cdf.Execute(strSql, strConnString, parConnection, parCollection: sqlParams);
            }
        }

        public void setProfilerDB(string value)
        {
            attivaDbProfiler = value;
        }

        public void setGlobalConnectionString(string strConnString)
        {
            globalConnectionString = strConnString;
        }

        public string? getProfilerDB()
        {
            return attivaDbProfiler;
        }
    }
}
