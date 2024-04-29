using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Http;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.BizDB
{
    /// <summary>
    //' AttackInfo :
    //'[ip]
    //'[statoBlocco]
    //'[dataBlocco]
    //'[paginaAttaccata]  (opz.)
    //'[queryString]
    //'[idPfu]            (opz.)
    //'[form]             (opz.)
    //'[motivoBlocco]
    /// </summary>

    public class BlackList : IBlackList
    {
        private const int MAX_LENGTH_ip = 97;
        private const int MAX_LENGTH_paginaAttaccata = 294;
        private const int MAX_LENGTH_form = 1494;
        private const int MAX_LENGTH_motivoBlocco = 3994;

        eProcurementNext.CommonDB.CommonDbFunctions cdf;

        HttpContext _httpContext;
        Session.ISession _session;

        public BlackList()
        {
            cdf = new CommonDbFunctions();
        }

        //public BlackList(HttpContext httpContext, Session.ISession session)
        //{
        //    _httpContext = httpContext;
        //    _session = session;
        //}

        //public void setSession(Session.ISession session)
        //{
        //    _session = session;
        //}


        public void addIp(Dictionary<string, dynamic> attackInfo, Session.ISession session, string strConnectionString)
        {
            Dictionary<string, dynamic> blacklist = ApplicationCommon.Application[APPLICATION_BLACKLIST];
            TSRecordSet? rs = null;
            SqlConnection cnLocal = null;
            string strSQL = "";
            string ipRefresh = "";
            string[] vetListIp = new string[] { };
            int k;

            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;
            blacklist = ApplicationCommon.Application[APPLICATION_BLACKLIST];

            //SetConnection cnLocal, strConnectionString
            strSQL = "select * from lib_dictionary where dzt_name = 'SYS_DISATTIVA_BLACKLIST'";

            CommonDbFunctions cdb = new();
            rs = cdb.GetRSReadFromQuery_(strSQL, strConnectionString);

            //'se la sys è presente ed è uguale ad 1 vuol dire che si vuole disattivare l'inserimento degli ip in blacklist
            if (rs.RecordCount > 0 && GetValueFromRS(rs.Fields["DZT_ValueDef"]) == "1")
            {
                // 'tracciamo l'informazione dell'attacco ma non inseriamo l'ip in blacklist
                addLogAttack(attackInfo, strConnectionString);
                return;
            }

            //'-- Se la blacklist non è caricata in application vuol dire che il global asa non è aggiornato
            if (blacklist == null)
            {
                return;
            }

            //'Aggiungo l'ip alla collezione in memoria e al db

            string ip = attackInfo.ElementAt(0).Key;

            blacklist[ip] = "blocked";
            blacklist[ip + "_datablocco"] = DateTime.Now;
            blacklist[ip + "_paginaAttaccata"] = attackInfo[ip + "_paginaAttaccata"];
            blacklist[ip + "_querystring"] = attackInfo[ip + "_queryString"];
            blacklist[ip + "_idPfu"] = attackInfo[ip + "_idPfu"];
            blacklist[ip + "_form"] = attackInfo[ip + "_form"];
            blacklist[ip + "_motivoBlocco"] = attackInfo[ip + "_motivoBlocco"];


            //SetConnection cnLocal, strConnectionString
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ip", attackInfo.ElementAt(0).Key);
            strSQL = "select * from CTL_blacklist where ip = @ip";

            rs = cdb.GetRSReadFromQuery_(strSQL, strConnectionString, null, parCollection: sqlParams);

            //'-- Se l'ip non era già presente in blacklist
            DataRow dr = rs.Fields;
            if (rs.RecordCount == 0)
            {
                dr = rs.AddNew();
            }

            dr["ip"] = TruncateMessage(ip, MAX_LENGTH_ip);
            dr["statoBlocco"] = "blocked";
            dr["dataBlocco"] = DateTime.Now;

            dr["paginaAttaccata"] = TruncateMessage(attackInfo[ip + "_paginaAttaccata"].Replace("'", "''"), MAX_LENGTH_paginaAttaccata);
            dr["queryString"] = attackInfo[ip + "queryString"].Replace("'", "''"); ;

            if (!string.IsNullOrEmpty(CStr(attackInfo[ip + "_idPfu"])))
            {
                dr["idPfu"] = attackInfo[ip + "_idPfu"];
            }
            else
            {
                dr["idPfu"] = "";
            }

            if (!string.IsNullOrEmpty(CStr(attackInfo[ip + "_form"])))
            {
                dr["form"] = TruncateMessage(attackInfo[ip + "_form"].Replace("'", "''"), MAX_LENGTH_form);
            }
            else
            {
                dr["form"] = "";
            }

            dr["motivoBlocco"] =TruncateMessage(attackInfo[ip + "_motivoBlocco"].Replace("'", "''"), MAX_LENGTH_motivoBlocco);

            rs.Fields["guid"] = CommonModule.Basic.GetNewGuid();

            try
            {

                rs.Update(dr, ip, "CTL_blacklist");

                //CloseRecordset rs

                application[APPLICATION_BLACKLIST] = blacklist;

                //'Dopo aver aggiunto il nuovo ip in blacklist invoco l'aggiornamento della black list in memoria
                //'in tutte le applicazioni che lo richiedono (per contesti di load balancing e/o di portale)

                ipRefresh = ApplicationCommon.Application["app-to-refresh"];
                vetListIp = ipRefresh.Split("@");
                string page = "";

                foreach (var vet in vetListIp)
                {
                    page = vet + "/ctl_library/refresh.asp?COSA=BLACKLIST";

                    invokeUrl(page);
                }

            }
            catch (Exception ex)
            {
                throw new Exception("Errore in BlackList.addIp(), causa : " + ex.Message, ex);
            }
        }

        public Dictionary<string, dynamic> getInfoBlock(string strIp, string strConnectionString)
        {
            Dictionary<string, dynamic> attackInfo = new Dictionary<string, dynamic>(); ;
            TSRecordSet? rs = null;
            SqlConnection? cnLocal = null;
            string strSQL = "";

            //SetConnection cnLocal, strConnectionString
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ip", strIp);
            strSQL = "select * from CTL_blacklist where ip = @ip";

            rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, null, parCollection: sqlParams);

            rs.MoveFirst();

            strIp = CStr(GetValueFromRS(rs.Fields["ip"]));
            attackInfo.Add(strIp, rs.Fields["ip"]);
            attackInfo.Add(strIp + "_statoBlocco", rs.Fields["statoBlocco"]);
            attackInfo.Add(strIp + "_dataBlocco", rs.Fields["dataBlocco"]);
            attackInfo.Add(strIp + "_paginaAttaccata", rs.Fields["paginaAttaccata"]);

            if (!String.IsNullOrEmpty(CStr(GetValueFromRS(rs.Fields["paginaAttaccata"]))))
            {
                attackInfo.Add(strIp + "_paginaAttaccata", GetValueFromRS(rs.Fields["paginaAttaccata"]));
            }

            attackInfo.Add(strIp + "_queryString", GetValueFromRS(rs.Fields["_queryString"]));

            if (!String.IsNullOrEmpty(CStr(GetValueFromRS(rs.Fields["idPfu"]))))
            {
                attackInfo.Add(strIp + "_idPfu", GetValueFromRS(rs.Fields["idPfu"]));
            }

            if (!String.IsNullOrEmpty(CStr(GetValueFromRS(rs.Fields["form"]))))
            {
                attackInfo.Add(strIp + "_form", GetValueFromRS(rs.Fields["form"]));
            }

            attackInfo.Add(strIp + "_motivoBlocco", GetValueFromRS(rs.Fields["motivoBlocco"]));
            attackInfo.Add(strIp + "_guid", GetValueFromRS(rs.Fields["guid"]));

            // CloseRecordset rs

            return attackInfo;
        }

        public void removeIp(string strIp, string strConnectionString)
        {
            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;
            dynamic blacklist = application[APPLICATION_BLACKLIST];

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ip", strIp);
            string strSQL = "select id from CTL_blacklist where ip = @ip";

            TSRecordSet? rs = new();
            rs.Open(strSQL, strConnectionString, parColl: sqlParams);

            if (rs is not null && !(rs.EOF && rs.BOF))
            {
                rs.MoveFirst();
                DataRow dr = rs.Fields!;

                dr["statoBlocco"] = "sblock"; 

                rs.Update(dr, "id", "CTL_blacklist");
            }

            blacklist.Remove(strIp);
            blacklist.Remove(strIp + "_statoBlocco");
            blacklist.Remove(strIp + "_dataBlocco");
            blacklist.Remove(strIp + "_paginaAttaccata");
            blacklist.Remove(strIp + "_queryString");
            blacklist.Remove(strIp + "_idPfu");
            blacklist.Remove(strIp + "_form");
            blacklist.Remove(strIp + "_motivoBlocco");

            application[APPLICATION_BLACKLIST] = blacklist;
        }

        public Dictionary<string, dynamic> getListIp()
        {
            return null;
        }

        public void loadBlackListInMem(string strConnectionString, ref Dictionary<string, dynamic> colBlackList)
        {
            string strSQL = "select * from CTL_blacklist where statoBlocco = 'blocked'";

            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString);

                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();

                    string ip = string.Empty;

                    while (!rs.EOF)
                    {
                        ip = CStr(rs["ip"]);

                        if (!String.IsNullOrEmpty(ip))
                        {
                            colBlackList[ip] = "blocked";
                            colBlackList[ip + "_statoBlocco"] = CStr(rs["statoBlocco"]);
                            colBlackList[ip + "_dataBlocco"] = GetValueFromRS(rs.Fields["dataBlocco"]);
                            if (!string.IsNullOrEmpty(CStr(rs["paginaAttaccata"])))
                            {
                                colBlackList[ip + "_paginaAttaccata"] = CStr(rs["paginaAttaccata"]);
                            }
                            colBlackList[ip + "_queryString"] = CStr(rs["queryString"]);
                            int idPfu = CInt(rs["idPfu"]!);
                            if (idPfu > 0)
                            {
                                colBlackList[ip + "_idPfu"] = idPfu;
                            }
                            string form = CStr(rs["form"]);
                            if (!String.IsNullOrEmpty(form))
                            {
                                colBlackList[ip + "_form"] = form;
                            }
                            colBlackList[ip + "_motivoBlocco"] = CStr(rs["motivoBlocco"]);
                        }

                        rs.MoveNext();
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Errore in BlackList.loadBlackListInMem(), causa: " + ex.Message, ex);
            }
        }

        /// <summary>
        /// 'Funzione che genera la collezione contenente le informazioni sull'attacco
        /// </summary>
        /// <param name="session"></param>
        /// <param name="causa"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>

        public Dictionary<string, dynamic> getAttackInfo(string strIp, string sessionUser, string path, string queryString, IFormCollection form, string strCausa)
        {
            var attackInfo = new Dictionary<string, dynamic>();

            //string strIp = Convert.ToString(_httpContext.Connection.RemoteIpAddress)

            //httpContext.GetServerVariable("REMOTE_ADDR")

            attackInfo.Add(strIp, strIp);
            attackInfo.Add(strIp + "_statoBlocco", "blocked");
            attackInfo.Add(strIp + "_dataBlocco", DateTime.Now);

            attackInfo.Add(strIp + "_paginaAttaccata", path);
            attackInfo.Add(strIp + "_queryString", queryString);

            if (!String.IsNullOrEmpty(sessionUser))
            {
                attackInfo.Add(strIp + "_idPfu", sessionUser);
            }


            if (_httpContext.Request.HasFormContentType && _httpContext.Request.Form.Count > 0)
            {
                string strForm = "";

                foreach (var item in _httpContext.Request.Form.Keys)
                {
                    strForm += strForm + item + "#=#" + _httpContext.Request.Form[item] + "#@#";
                }

                if (strForm.Length > 1500)
                {
                    strForm = strForm.Substring(strForm.Length - 1400);
                }

                attackInfo.Add(strIp + "_form", strForm);
            }
            else
            {
                attackInfo.Add(strIp + "_form", "");
            }

            attackInfo.Add(strIp + "_motivoBlocco", strCausa);

            return attackInfo;
        }

        public Dictionary<string, dynamic> getAttackInfo(HttpContext httpContext, dynamic sessionUser, string strCausa)
        {
            var attackInfo = new Dictionary<string, dynamic>();

            string strIp = CStr(httpContext.Connection.RemoteIpAddress);

            attackInfo.Add(strIp, strIp);
            attackInfo.Add(strIp + "_statoBlocco", "blocked");
            attackInfo.Add(strIp + "_dataBlocco", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

            attackInfo.Add(strIp + "_paginaAttaccata", getPathRequest(httpContext.Request));
            attackInfo.Add(strIp + "_queryString", httpContext.Request.QueryString.ToString());

            if (!string.IsNullOrEmpty(CStr(sessionUser)))
            {
                attackInfo.Add(strIp + "_idPfu", sessionUser);
            }

            if (httpContext.Request.HasFormContentType && httpContext.Request.Form.Count > 0)
            {
                string strForm = "";

                foreach (var item in httpContext.Request.Form.Keys)
                {
                    strForm = strForm + item + "#=#" + httpContext.Request.Form[item] + "#@#";
                }

                if (strForm.Length > 1500)
                {
                    strForm = strForm.Substring(strForm.Length - 1400);
                }

                attackInfo.Add(strIp + "_form", strForm);
            }
            else
            {
                attackInfo.Add(strIp + "_form", "");
            }

            attackInfo.Add(strIp + "_motivoBlocco", strCausa);

            return attackInfo;
        }

        //public Dictionary<string, dynamic> getAttackInfo(EprocNext.Session.ISession session, string strCausa)
        //{
        //    //Federico. Questo  metodo ha 36 riferimenti, che senso ha questa eccezione lanciata così ? dobbiamo rimuoverlo in favore dell'altro ? 
        //    throw new Exception("chiamare l'atro metodo che accetta anche httpContext ?!");
        //}

        //public Dictionary<string, dynamic> getAttackInfo(string causa)
        //{
        //    return getAttackInfo(_session, causa);
        //}
        public bool isOwnerObblig(string oggettosql)
        {
            try
            {
                oggettosql = UCase(oggettosql);
                if (ApplicationCommon.Application[APPLICATION_OWNERLIST].ContainsKey(oggettosql))
                {
                    return true;
                }
            }
            catch { }

            return false;
        }

        public void loadOwnersInMem(string strConnectionString, Dictionary<string, dynamic> colOwners)
        {
            //'-- Recuperiamo i record non cancellati logicamente e degli owner che non sono opzionali
            string strSQL = "select upper(oggettoSql) as oggettoSql from CTL_sqlobj_owner where bDeleted = 0 and opzionale = 0";
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString);

            if (rs.RecordCount > 0)
            {
                rs.MoveFirst();
                while (!rs.EOF)
                {
                    if (!string.IsNullOrEmpty(CStr(rs["oggettoSql"])))
                        colOwners[CStr(rs["oggettoSql"])] = CStr(rs["oggettoSql"]);
                    rs.MoveNext();
                }
            }
        }

        public bool isDevMode(Session.ISession session = null)
        {
            //'Se siamo in modalità DEBUG (sviluppo) non aggiungiamo gli ip alla blacklist
            //var debugMode = ApplicationCommon.Application["debug-mode"]
            //if (debugMode != null && debugMode.GetType().Name == "String")
            //{
            try
            {
                if (UCase(ApplicationCommon.Application["debug-mode"]) == "SI" ||
                    UCase(ApplicationCommon.Application["debug-mode"]) == "TRUE" ||
                    UCase(ApplicationCommon.Application["debug-mode"]) == "YES")
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch { }

            return true;
        }

        public string getIpByGuid(string guid, string strConnectionString)
        {
            string getIpByGuidRet = "";

            string connString = ApplicationCommon.Application.ConnectionString;

            //SetConnection cnLocal, connString
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@guid", guid);
            string strSQL = "select ip from CTL_blacklist where guid = @guid";

            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, parCollection: sqlParams);

            if (rs.RecordCount > 0)
            {
                rs.MoveFirst();

                getIpByGuidRet = CStr(rs["ip"]);
            }
            else
            {
                getIpByGuidRet = string.Empty;
            }

            return getIpByGuidRet;
        }

        public void addLogAttack(Dictionary<string, dynamic> attackInfo, /*Session.ISession session,*/ string strConnectionString)
        {
            TSRecordSet? rs = new();
            string strSQL = "select * from CTL_blacklist where ip = '0.0.0.0'";
            rs = rs.Open(strSQL, strConnectionString);

            if (rs is not null)
            {
                DataRow dr = rs.AddNew();

                string strIp = attackInfo.ElementAt(0).Key;

                dr["ip"] = TruncateMessage(strIp, MAX_LENGTH_ip);
                dr["statoBlocco"] = "log-attack"; //'identifichiamo un log dell'attacco senza blocco dell'ip
                dr["dataBlocco"] = DateTime.Now;

                dr["paginaAttaccata"] = TruncateMessage(CStr(attackInfo[strIp + "_paginaAttaccata"]), MAX_LENGTH_paginaAttaccata);

                dr["queryString"] = CStr(attackInfo[strIp + "_queryString"]);

                if (attackInfo.ContainsKey(strIp + "_idPfu") && !string.IsNullOrEmpty(CStr(attackInfo[strIp + "_idPfu"])))
                {
                    dr["idPfu"] = attackInfo[strIp + "_idPfu"];
                }
                else
                {
                    dr["idPfu"] = -20;
                }

                if (attackInfo.ContainsKey(strIp + "_form") && !string.IsNullOrEmpty(CStr(attackInfo[strIp + "_form"])))
                {
                    dr["form"] = TruncateMessage(attackInfo[strIp + "_form"], MAX_LENGTH_form);
                }
                else
                {
                    dr["form"] = "";
                }

                dr["motivoBlocco"] = TruncateMessage(attackInfo[strIp + "_motivoBlocco"], MAX_LENGTH_motivoBlocco);

                rs.Update(dr, "id", "CTL_blacklist");
            }
        }
    }
}
