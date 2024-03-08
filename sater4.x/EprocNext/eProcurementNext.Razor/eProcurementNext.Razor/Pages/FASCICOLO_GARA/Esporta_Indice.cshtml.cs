using ClosedXML.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Security;
using Microsoft.VisualBasic;
using System.Collections.Specialized;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using FileAccess = System.IO.FileAccess;

namespace eProcurementNext.Razor.Pages.FASCICOLO_GARA
{
    public class EsportaIndiceModel
    {
        public void OnGet()
        {
        }

        const int TIPO_PARAMETRO_STRING = 1;
        const int TIPO_PARAMETRO_INT = 2;
        const int TIPO_PARAMETRO_FLOAT = 3;
        const int TIPO_PARAMETRO_NUMERO = 4;
        const int TIPO_PARAMETRO_DATA = 5;

        const int SOTTO_TIPO_PARAMETRO_CUSTOM = 0;
        const int SOTTO_TIPO_PARAMETRO_NESSUNO = 0;
        const int SOTTO_TIPO_VUOTO = 0;
        const int SOTTO_TIPO_PARAMETRO_TABLE = 1;
        const int SOTTO_TIPO_PARAMETRO_PAROLASINGOLA = 1;
        const int SOTTO_TIPO_PARAMETRO_SORT = 2;
        const int SOTTO_TIPO_PARAMETRO_FILTROSQL = 3;
        const int SOTTO_TIPO_PARAMETRO_LISTANUMERI = 4;

        private static int mp_idpfu = -20;
        private static string mp_sessionID = "";

        private static string strConnectionString = ApplicationCommon.Application.ConnectionString;
        private static string paginaChiamata = "fascicolo_gara/Esporta_Indice.aspx";

        private static string lngSuffix = "I";
        private static string strPermission = string.Empty;

        private static string strMotivoBlocco;

        private static eProcurementNext.Session.ISession _session;

        public static void Page_Load(HttpContext HttpContext, EprocResponse htmlToReturn, eProcurementNext.Session.ISession session)
        {
            Microsoft.AspNetCore.Http.HttpResponse Response = HttpContext.Response;
            Microsoft.AspNetCore.Http.HttpRequest Request = HttpContext.Request;
            _session = session;
            //session = _session
            // response.write (Request.QueryString())
            // response.end

            //'--recupero id del documento fascicolo gara
            string idDoc = GetParamURL(Request.QueryString.ToString(), "IDDOC");
            string HIDECOL = CStr(GetParamURL(Request.QueryString.ToString(), "HIDECOL"));
            string MODEL = GetParamURL(Request.QueryString.ToString(), "MODEL"); // -- se il model non � passato porto in output tutte le colonne ritornate dal recordset

            string strCause = "";
            string strSQL = "";
            string debug = "";
            string strfilename = "";

            // -- iniazializzo parametro SHOW_ATTACH per capire se gestire o meno i campi di tipo attach
            // -- il default � SI 
            string SHOW_ATTACH = "SI";

            strSQL = "select * from LIB_Dictionary where dzt_name='SYS_dettaglio-errori'";

            strCause = "Apro la connessione con il db";
            SqlConnection sqlConn1 = new(strConnectionString);
            sqlConn1.Open();


            SqlCommand sqlComm = new(strSQL, sqlConn1);
            SqlDataReader rsDati = sqlComm.ExecuteReader();

            rsDati.Read();

            do
            {
                if (UCase(CStr(rsDati["DZT_ValueDef"])) != "YES" && UCase(CStr(rsDati["DZT_ValueDef"])) != "SI")
                {
                    debug = "NO";
                }
                else
                {
                    debug = "YES";
                }
            }

            while (rsDati.Read());

            rsDati.Close();

            SqlConnection sqlConn2 = new(strConnectionString);
            try
            {

                //' ------------------------------------------
                //' --- SICUREZZA. VALIDAZIONE INPUT ---------
                //' ------------------------------------------

                validaInput("IDDOC", idDoc, TIPO_PARAMETRO_INT, "", HttpContext);

                mp_idpfu = -20;

                strfilename = "Indice Fascicolo di Gara.xlsx";

                logDB(sqlConn1, "Inizio elaborazione. Superati i controlli di sicurezza", false, HttpContext);

                sqlConn2.Open();

                string strTableInput = string.Empty;

                // -- compongo la select per il recupero dati

                // --CREO IL PACCHETTO EXCEL
                XLWorkbook pck = new();

                // --RECUPERO I DATI DEI DOCUMENTI DEL FASCICOLO
                strTableInput = "VIEW_FASCICOLO_GARA_DETTAGLI";
                MODEL = "FASCICOLO_GARA_DETTAGLI";
                string sqlWhere = $" idheader = {idDoc}";
                string lngSuffix = "i";
                mp_idpfu = -1;
                HIDECOL = ",Esito,";
                strSQL = "exec SP_XSLX_DECODIFICA_FOR_EXPORT '" + strTableInput + "' , '" + Replace(MODEL, "'", "''") + "' , '" + Replace(sqlWhere, "'", "''") + "' , '" + lngSuffix + "' , " + mp_idpfu + ",'" + Replace(HIDECOL, "'", "''") + "','',' path  ASC '";

                strCause = $"Eseguo query per recuperare i dati: {strSQL}";
                sqlComm = new(strSQL, sqlConn1);
                sqlComm.CommandTimeout = 180;
                rsDati = sqlComm.ExecuteReader();

                SqlCommand sqlComm2;
                SqlDataReader rsColonne;

                // --RECUPERO LE COLONNE DA VISUALIZZARE PER IL FOGLIO DOCUMENTI
                strCause = $"Eseguo la select per recuperare le colonne del modello {MODEL}";
                strSQL = "exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV '" + Replace(MODEL, "'", "''") + "' , '" + Replace(HIDECOL, "'", "''") + "', 1 ,'" + SHOW_ATTACH + "','" + strTableInput + "'"; // --penultimo parametro ad 1 mi fa ritornare le descrizioni delle colonne gia in CNV
                                                                                                                                                                                               // response.write ( strSQL )
                                                                                                                                                                                               // response.end
                sqlComm2 = new SqlCommand(strSQL, sqlConn2);
                rsColonne = sqlComm2.ExecuteReader();

                // --AGGIUNGO IL FOGLIO DOCUMENTI ALL'ExcelPackage
                strCause = "AGGIUNGO IL FOGLIO DOCUMENTI";
                AggiungiFoglio(pck, "documenti", rsColonne, rsDati);

                // --RECUPERO GLI ALLEGATI DEL FASCICOLO
                strTableInput = "Document_Fascicolo_Gara_Allegati";
                MODEL = "FASCICOLO_GARA_ALLEGATI";
                HIDECOL = ",Esito,Encrypted,";
                strSQL = "exec SP_XSLX_DECODIFICA_FOR_EXPORT '" + strTableInput + "' , '" + Replace(MODEL, "'", "''") + "' , '" + Replace(sqlWhere, "'", "''") + "' , '" + lngSuffix + "' , " + mp_idpfu + ",'" + Replace(HIDECOL, "'", "''") + "','',' Path,NomeFile asc'";

                // strCause = "Eseguo query per recuperare i dati: " & strSQL
                sqlComm = new SqlCommand(strSQL, sqlConn1);
                sqlComm.CommandTimeout = 180;
                rsDati = sqlComm.ExecuteReader();

                // --RECUPERO LE COLONNE DA VISUALIZZARE PER IL FOGLIO ALLEGATI 
                // strCause = "Eseguo la select per recuperare le colonne del modello " & MODEL
                strSQL = "exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV '" + Replace(MODEL, "'", "''") + "' , '" + Replace(HIDECOL, "'", "''") + "', 1 ,'" + SHOW_ATTACH + "','" + strTableInput + "'"; // --penultimo parametro ad 1 mi fa ritornare le descrizioni delle colonne gia in CNV


                sqlComm2 = new SqlCommand(strSQL, sqlConn2);
                rsColonne = sqlComm2.ExecuteReader();

                // response.write ("tutto ok")
                // response.end

                // --AGGIUNGO IL FOGLIO ALLEGATI ALL'ExcelPackage
                // strCause = "AGGIUNGO IL FOGLIO ALLEGATI"
                AggiungiFoglio(pck, "allegati", rsColonne, rsDati);

                // --mandiamo il file excel al client
                strCause = "Imposto il contentype di output";
                Response.ContentType = "application/XLSX";

                strCause = "aggiunto il content-disposition";
                Response.Headers.TryAdd("content-disposition", $"attachment; filename={Replace(strfilename, " ", "_")}");

                strCause = "effettuo il binaryWrite";

                string tempPath = $"{CStr(ApplicationCommon.Application["PathFolderAllegati"])}{CommonStorage.GetTempName()}.xlsx";

                pck.SaveAs(tempPath);

                //Open the File into file stream

                //Create and populate a memorystream with the contents of the
                using FileStream fs = new System.IO.FileStream(tempPath, FileMode.Open, FileAccess.Read);
                byte[] b = new byte[1024];
                int len;
                int counter = 0;
                while (true)
                {
                    len = fs.Read(b, 0, b.Length);
                    byte[] c = new byte[len];
                    b.Take(len).ToArray().CopyTo(c, 0);
                    htmlToReturn.BinaryWrite(HttpContext, c);
                    if (len == 0 || len < 1024)
                    {
                        break;
                    }
                    counter++;
                }
                fs.Close();

                // delete the file when it is been added to memory stream
                CommonStorage.DeleteFile(tempPath);

                //htmlToReturn.BinaryWrite(HttpContext, pck.GetAsByteArray())

                pck.Dispose();

            }
            catch (Exception ex)
            {

                string msgError = $@"Si è verificato un errore di sistema.<br/>";
                msgError = msgError + $@"Occorre ripetere l'operazione, nel caso in cui il problema si dovesse ripresentare si può contattare il supporto per avere maggiori informazioni.<br/>";
                msgError = msgError + $@"Il riferimento è :" + DateTime.Now;

                if (CStr(Strings.UCase(debug)) == "YES")
                    htmlToReturn.Write(strCause + $@" -- " + ex.ToString());
                else
                    htmlToReturn.Write(msgError);

                traceError(sqlConn1, CStr(mp_idpfu), $"{strCause} -- {ex.Message}", Request.QueryString.ToString());

                if (sqlConn1 != null)
                    sqlConn1.Close();

                if (sqlConn2 != null)
                    sqlConn2.Close();
            }
        }

        private static void traceError(SqlConnection sqlConn, string idpfu, string descrizione, string querystring)
        {
            string contesto = "Generazione XLSX";
            string typeTrace = "TRACE-ERROR";

            if (string.IsNullOrEmpty(idpfu))
            {
                idpfu = "-1";
            }

            string sEvent = Left($"Errore nella generazione del file XLSX.URL:{querystring} --- Descrizione dell'errore : {descrizione}", 4000);

            CommonDbFunctions cdb = new();
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@idpfu", CInt(idpfu));
            sqlParams.Add("@contesto", contesto);
            sqlParams.Add("@typeTrace", typeTrace);
            sqlParams.Add("@sEvent", sEvent);
            string strSQL = $"INSERT INTO CTL_LOG_UTENTE (idpfu,datalog,paginaDiArrivo,querystring,descrizione) {Environment.NewLine}";
            strSQL = $"{strSQL} VALUES (@idpfu, getdate(), @contesto, @typeTrace, @sEvent)";
            cdb.Execute(strSQL, sqlConn.ConnectionString, parCollection: sqlParams);

            WriteToEventLog(sEvent);
        }

        // -- ritorna tre stringhe contenenti separatamente la lista degli attributi, la lista delle condizioni e la lista dei valori
        // -- da passare alla stored per il recupero dati
        public static string GetSqlWhereList(IFormCollection form)
        {
            int nf;
            int i;
            string ListAtt = string.Empty;
            string ListCond = string.Empty;
            string ListVal = string.Empty;
            string condition = "="; // non serve rendarla dinamica. metto come condition fissa l'uguaglianza

            nf = form.Count;

            for (i = 0; i <= nf - 1; i++)
            {
                if (!string.IsNullOrEmpty(form.ElementAt(i).Value))
                {
                    ListAtt = $"{ListAtt}#@#{form.Keys.ElementAt(i)}";
                    ListCond = $"{ListCond}#@#{condition}";
                    ListVal = ListVal + "#@#" + ("'" + form.ElementAt(i).Value + "'"); // -- tratto tutti i campi come stringa. lascio alla stored il compito di gestirlo nel modo + appropriato per il contesto d'uso
                }
            }

            if (!string.IsNullOrEmpty(ListAtt))
                ListAtt = Strings.Mid(ListAtt, 4);
            if (!string.IsNullOrEmpty(ListCond))
                ListCond = Strings.Mid(ListCond, 4);
            if (!string.IsNullOrEmpty(ListVal))
                ListVal = Strings.Mid(ListVal, 4);

            return $"{ListAtt}#~#{ListVal}#~#{ListCond}";
        }

        public static StringDictionary getFormColl(string stored, string mp_Filter)
        {
            // response.write (mp_Filter & "<br>") 

            string[] v;
            string strFilter = "";
            string[] p;
            StringDictionary collezione = new StringDictionary();
            int i;


            if (!string.IsNullOrEmpty(mp_Filter))
            {
                if (Trim(CStr(stored).ToUpper()) != "YES")
                {
                    // If stored <> "yes" Then

                    v = Strings.Split(Strings.LCase(mp_Filter), " and ");


                    for (i = 0; i <= Information.UBound(v); i++)
                    {
                        strFilter = v[i];
                        strFilter = Trim(strFilter);

                        strFilter = Replace(strFilter, "'", "");

                        if (Strings.InStr(1, strFilter, "=") > 0)
                            p = Strings.Split(strFilter, "=");
                        else
                        {
                            strFilter = Replace(strFilter, "%", "");
                            p = Strings.Split(Strings.LCase(strFilter), " like ");
                        }

                        p[1] = Replace(Trim(p[1]), "'", "");
                        p[1] = Replace(Trim(p[1]), ")", "");

                        // -- Aggiunto attributo e valore

                        // --ripulisco nome attributo di eventuale convert applicate alle date come ad es.:
                        // --convert( varchar(10) , DataScadenzaOfferta , 121 ) >= '2018-05-05' and convert( varchar(10) , DataScadenzaA , 121 ) <= '2018-05-10' 
                        p[0] = Replace(p[0], "convert( varchar(10) , ", "");
                        p[0] = Replace(p[0], " , 121 ) ", "");
                        p[0] = Replace(p[0], ">", "");
                        p[0] = Replace(p[0], "<", "");
                        p[0] = Replace(p[0], "#", "");
                        p[0] = Replace(p[0], "(", "");
                        p[0] = Replace(p[0], "+", "");
                        // response.write (Trim(p(0)).ToLower & "------" &  p(1) & "<br>")
                        collezione.Add(Trim(p[0]).ToLower(), p[1]);
                    }
                }
                else
                {
                    string[] vAtt;
                    string[] vVal;
                    string[] vCond;
                    string p2 = "";

                    v = Strings.Split(mp_Filter, "#~#");
                    vAtt = Strings.Split(v[0], "#@#");
                    vVal = Strings.Split(v[1], "#@#");
                    vCond = Strings.Split(v[2], "#@#");

                    for (i = 0; i <= Information.UBound(vAtt); i++)
                    {
                        p2 = Replace(Trim(vVal[i]), "'", "");

                        // -- Aggiunto attributo e valore
                        collezione.Add(Strings.Trim(vAtt[i]).ToLower(), p2);
                    }
                }
            }

            return collezione;
        }

        public static string getFilterVAlue(string key, IFormCollection? form, StringDictionary coll)
        {
            string @out = "";

            key = key.ToLower();

            // If vexcel = "1" Then
            if (form == null || form.Count == 0)
                @out = coll[key];
            else
                @out = form[key];

            return @out;
        }

        // --restituisce il pezzo di statement relativo al filtro basato sulla profilazione utente
        private static string Get_Filter_User_Profile(string mp_Info_User_Profile, int mp_User, SqlConnection sqlConn2)
        {
            string tempFilterProfile = string.Empty;
            string[] aInfo;
            string[] aInfo1;
            int nNumAttrib = 0;
            int i = 0;
            TSRecordSet rs = new();
            string strColMyMessage = string.Empty;

            if (!String.IsNullOrEmpty(mp_Info_User_Profile))
            {
                aInfo1 = mp_Info_User_Profile.Split(':');
                if (aInfo1.GetUpperBound(0) == 1)
                {
                    strColMyMessage = aInfo1[1];
                }

                aInfo = aInfo1[0].Split(',');
                nNumAttrib = aInfo.GetUpperBound(0);

                for (i = 0; i <= nNumAttrib; i++)
                {
                    string strSQL = $"select attvalue from profiliutenteattrib with(nolock) where idpfu={mp_User} and dztnome='{aInfo[i].Replace("'", "''")} '";

                    CommonDbFunctions cdf = new();
                    rs = cdf.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application.ConnectionString);

                    if (rs is not null)
                    {
                        if (rs.RecordCount > 0)
                        {
                            if (!String.IsNullOrEmpty(tempFilterProfile))
                            {
                                tempFilterProfile = $"{tempFilterProfile} and ";
                            }

                            tempFilterProfile = $"{tempFilterProfile}( {aInfo[i]} in (select attvalue from profiliutenteattrib where idpfu={mp_User} and dztnome='{aInfo[i].Replace("'", "''")}' )";
                            //'--se indicata la colonna per prendere comunque i documenti fatti dall'utente collegato
                            if (!String.IsNullOrEmpty(strColMyMessage))
                            {
                                tempFilterProfile = $"{tempFilterProfile} or {strColMyMessage}={mp_User}";
                            }

                            tempFilterProfile = $"{tempFilterProfile} )";
                        }
                    }
                }
            }

            return tempFilterProfile;
        }

        public static void validaInput(string nomeParametro, string valoreDaValidare, int tipoDaValidare, string sottoTipoDaValidare, HttpContext HttpContext, string regExp = "")
        {
            Validation objSecurityLib;
            bool isAttacked = false;

            //if (Information.Err.Number != 0)
            //{
            //    htmlToReturn.Write($@"ERRORE DI REGISTRAZIONE NELLA DLL CtlSecurity");
            //    throw new ResponseEndException(htmlToReturn.Out(), Response, "");
            //}

            if (string.IsNullOrEmpty(sottoTipoDaValidare.Trim()))
                sottoTipoDaValidare = CStr(0);

            if (!string.IsNullOrEmpty(valoreDaValidare.Trim()))
            {
                try
                {
                    objSecurityLib = new Validation();
                }
                catch (Exception ex)
                {
                    return;
                }

                try
                {
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB;", "");
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.1;", "");
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.2;", "");
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.3;", "");
                }
                catch (Exception ex)
                {
                }

                switch (tipoDaValidare)
                {
                    case TIPO_PARAMETRO_FLOAT:
                    case TIPO_PARAMETRO_INT:
                    case TIPO_PARAMETRO_NUMERO:
                        {
                            if (!Information.IsNumeric(valoreDaValidare))
                                isAttacked = true;
                            break;
                        }

                    case TIPO_PARAMETRO_DATA:
                        {
                            if (!Information.IsDate(valoreDaValidare))
                                isAttacked = true;
                            break;
                        }

                    default:
                        {
                            switch (CInt(sottoTipoDaValidare))
                            {
                                //case SOTTO_TIPO_PARAMETRO_TABLE:
                                case SOTTO_TIPO_PARAMETRO_PAROLASINGOLA:
                                    {
                                        if (!objSecurityLib.isValidValue(valoreDaValidare, 1))
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_SORT:
                                    {
                                        if (!objSecurityLib.isValidSqlSort(valoreDaValidare, ""))
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_FILTROSQL:
                                    {
                                        if (!objSecurityLib.isValidFilterSql(valoreDaValidare, ""))
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_LISTANUMERI:
                                    {
                                        if (!objSecurityLib.isValidValue(valoreDaValidare, 4))
                                            isAttacked = true;
                                        break;
                                    }
                            }

                            break;
                        }
                }

                objSecurityLib = null;

                if (isAttacked)
                {

                    // Response.Write("BLOCCO!Parametro:" & nomeParametro)
                    // Response.Write("Valore:" & valoreDaValidare)
                    // Response.End()

                    string motivo = "";

                    try
                    {
                        motivo = "Injection, CtlSecurity.validate() : Tenativo di modifica del parametro '" + nomeParametro + "'";
                    }
                    catch (Exception ex)
                    {
                    }

                    sendBlock(paginaChiamata, motivo, HttpContext);
                }
            }
        }

        public static void sendBlock(string paginaAttaccata, string motivo, Microsoft.AspNetCore.Http.HttpContext HttpContext)
        {
            addSecurityBlockTrace(paginaAttaccata, motivo, HttpContext);
            throw new ResponseRedirectException("../blocked.asp", HttpContext.Response);
        }

        public static void addSecurityBlockTrace(string paginaAttaccata, string motivo, HttpContext HttpContext)
        {
            const int MAX_LENGTH_ip = 97;
            const int MAX_LENGTH_paginaAttaccata = 294;
            const int MAX_LENGTH_motivoBlocco = 3994;

            string ipChiamante = string.Empty;
            string strQueryString = string.Empty;

            try
            {
                ipChiamante = eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.net_utilsModel.getIpClient(HttpContext.Request);/*Request.UserHostAddress;*/
                strQueryString = GetQueryStringFromContext(HttpContext.Request.QueryString);//Request.QueryString;
            }
            catch (Exception ex)
            {
                ipChiamante = string.Empty;
            }

            try
            {
                var sqlParams = new Dictionary<string, object?>()
                {
                    { "@ip", TruncateMessage(ipChiamante, MAX_LENGTH_ip)},
                    {"@paginaAttaccata", TruncateMessage(paginaAttaccata, MAX_LENGTH_paginaAttaccata)},
                    {"@queryString", strQueryString},
                    {"@idpfu", mp_idpfu},
                    { "@motivoBlocco",  TruncateMessage(motivo, MAX_LENGTH_motivoBlocco)}
                };
                string strsql = "INSERT INTO [CTL_blacklist] ([ip],[statoBlocco],[dataBlocco],[dataRefresh],[numeroRefresh],[paginaAttaccata],[queryString],[idPfu],[form],[motivoBlocco])";
                strsql = strsql + " VALUES (@ip, 'log-attack', getdate(), null, 0, @paginaAttaccata, @queryString, @idpfu, null, @motivoBlocco)";

                CommonDbFunctions cdf = new();
                cdf.Execute(strsql, strConnectionString, parCollection: sqlParams);
            }
            catch (Exception ex)
            {
            }
        }

        public static bool checkPermission(string strSqlTable)
        {
            bool result = false;

            string strSql = string.Empty;
            bool ret = false;
            string strConnectionString = string.Empty;
            string strCause = string.Empty;
            TSRecordSet rs = new TSRecordSet();

            string strPermission = string.Empty;
            string permesso = string.Empty;

            ret = true;

            strPermission = _session["Funzionalita"];
            if (string.IsNullOrEmpty(strPermission))
            {
                result = true;
                return result;
            }

            if (!string.IsNullOrEmpty(strSqlTable))
            {
                strSql = "select lfn_paramtarget + '&' as params, ISNULL(lfn_pospermission,'-1') as permesso from lib_functions where lfn_paramtarget like '%TABLE=" + strSqlTable.Replace("'", "''") + "&%' Union select mpclink + '&' as params , ISNULL(mpcuserfunz,'-1') as permesso from mpcommands  where mpclink like '%TABLE=" + strSqlTable.Replace("'", "''") + "&%'";
                strConnectionString = ApplicationCommon.Application.ConnectionString;
                CommonDbFunctions cdf = new();
                rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString);

                if (rs.RecordCount == 0)
                {
                    ret = false;
                }
                else
                {
                    rs.Filter("permesso = '-1'");

                    if (rs.RecordCount == 0)
                    {
                        rs.Filter("permesso <> '-1'");
                        rs.MoveFirst();
                        ret = false; //'fino a che non trovo un permesso per l'utente rispetto all'oggetto sql a cui vuole accedere, lo considero non autorizzato

                        while (!rs.EOF)
                        {
                            permesso = CStr(rs["permesso"]);
                            if (CLng(permesso) > 0)
                            {
                                if (Strings.Mid(strPermission, CInt(permesso), 1) != "0")
                                {
                                    ret = true;
                                    rs.MoveLast();
                                }
                            }
                            else
                            {
                                ret = true;
                                rs.MoveLast(); // forzo l'uscita dal ciclo
                            }

                            rs.MoveNext();
                        }
                    }
                }
            }
            return ret;
        }

        public static void getInfoUser()
        {
            if (mp_idpfu > 0)
            { 
                return;
			}

			var sqlConn = new SqlConnection(strConnectionString);
            sqlConn.Open();

            string strSql = "select isnull(lngSuffisso,'I') as suffisso, pfuFunzionalita from profiliutente with(nolock) left join lingue ON idlng = pfuidlng where idpfu = " + CStr(CLng(mp_idpfu));

            SqlCommand sqlComm = new(strSql, sqlConn);
            SqlDataReader rs = sqlComm.ExecuteReader();

            if (rs.Read())
            {
                lngSuffix = CStr(rs["suffisso"]);
                strPermission = CStr(rs["pfuFunzionalita"]);
            }

            rs.Close();
            sqlConn.Close();
            sqlComm = null;
            rs = null;
            sqlConn = null;
        }

        // RIPARTI DA QUI

        public static bool isOwnerObblig(string oggettoSQL)
        {
            if (string.IsNullOrEmpty(oggettoSQL))
            {
                return false;
            }


            bool bEsito;
            var sqlConn = new SqlConnection(strConnectionString);
            sqlConn.Open();

            string strSql = "select * from CTL_sqlobj_owner with(nolock) where bDeleted = 0 and opzionale = 0 and oggettoSql = '" + Strings.Replace(oggettoSQL, "'", "''") + "'";

            SqlCommand sqlComm = new(strSql, sqlConn);
            SqlDataReader rs = sqlComm.ExecuteReader();

            if ((rs.Read()))
            {
                bEsito = true;
            }
            else
            {
                bEsito = false;
            }
            rs.Close();
            sqlConn.Close();

            return bEsito;
        }

        public static void logDB(SqlConnection sqlConn, string messaggio, bool errore, HttpContext HttpContext, string browser = "ASPX")
        {
            try
            {
                string ip = "";
                string strSql = "";
                string level = "INFO";
                string queryString = "";

                if (errore)
                { 
                    level = "ERROR";
				}

				try
                {
                    ip = eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.net_utilsModel.getIpClient(HttpContext.Request);
                    queryString = GetQueryStringFromContext(HttpContext.Request.QueryString);
                }
                catch (Exception ex)
                {
                }

                strSql = "INSERT INTO CTL_LOG_UTENTE(ip,idpfu,datalog,paginaDiArrivo,paginaDiPartenza,querystring,form,browserUsato,sessionID) VALUES ('" + Strings.Replace(ip, "'", "''") + "'," + CStr(CLng(mp_idpfu)) + ",getdate(),'LOG-" + level + "','" + Strings.Replace(paginaChiamata, "'", "''") + "','" + Strings.Replace(queryString, "'", "''") + "','" + Strings.Replace(messaggio, "'", "''") + "','" + Strings.Replace(browser, "'", "''") + "','" + Strings.Replace(mp_sessionID, "'", "''") + "')";

                SqlCommand sqlComm = new(strSql, sqlConn);

                sqlComm.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
            }
        }

        public static void getIdpfuFromGuid(string guid)
        {
            var sqlConn = new SqlConnection(strConnectionString);
            sqlConn.Open();

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@guid", guid);
            string strSql = "select * from CTL_ACCESS_BARRIER with(nolock) where guid = @guid and datediff(SECOND, data,getdate()) <= 30";

            SqlCommand sqlComm = new(strSql, sqlConn);
            SqlDataReader rs = sqlComm.ExecuteReader();

            if ((rs.Read()))
            {
                mp_idpfu = _session["idpfu"]; //rs.Fields["idpfu"]
                mp_sessionID = _session.SessionID; // rs.Fields["sessionid"]
            }

            rs.Close();
            sqlConn.Close();
        }

        public static bool documentPermission(string tipoDocumento, string idpfu, string IDDOC)
        {
            bool bEsito = true;

            if (string.IsNullOrEmpty(tipoDocumento) || string.IsNullOrEmpty(idpfu))
                return true;

            var sqlConn = new SqlConnection(strConnectionString);
            sqlConn.Open();

            string strSql = "select isnull(DOC_DocPermission,'') as DOC_DocPermission from LIB_DOCUMENTS with(nolock) where DOC_ID='" + Replace(tipoDocumento, "'", "''") + "'";

            // response.write(strSql)
            // response.end

            SqlCommand sqlComm = new SqlCommand(strSql, sqlConn);
            SqlDataReader rs = sqlComm.ExecuteReader();

            if (rs.Read())
            {
                string nomeStored = CStr(rs["DOC_DocPermission"]);

                if (!string.IsNullOrEmpty(nomeStored))
                {
                    rs.Close();
                    string strSQL = " exec " + nomeStored + " " + CStr(CInt(idpfu)) + " , '" + Replace(IDDOC, "'", "''") + "'";

                    // response.write(strSql)
                    // response.end

                    strMotivoBlocco = strSQL;

                    sqlComm = new SqlCommand(CStr(strSql), sqlConn);
                    rs = sqlComm.ExecuteReader();

                    if (rs.Read() == false)
                        bEsito = false;
                }
            }
            else
                rs.Close();

            sqlConn.Close();
            sqlComm = null;
            rs = null;
            sqlConn = null;

            return bEsito;
        }

        // --ritorna la forma clausola where per un attributo	
        public static string GetSqlWhere(string strModello, string strAttributo, string strOperatore, string strValore, SqlConnection sqlConn2)
        {
            int nf;
            int i;
            string strWhere;
            string v;
            int k;
            string[] alistvalue;
            int FType;
            string strSQL;
            string strcondition;

            if (!string.IsNullOrEmpty(strModello))
            {

                // --carico le info dell'attributo  dal modello
                strSQL = "SELECT        top 1 MA_DZT_Name," + Environment.NewLine;
                strSQL = strSQL + "     DZT_Type ,isnull(DZT_MultiValue,0) as DZT_MultiValue," + Environment.NewLine;
                strSQL = strSQL + "     isnull( isnull(F.MAP_Value,b.DZT_Format) ,'') as DZT_Format," + Environment.NewLine;
                strSQL = strSQL + "     isnull(C.MAP_Value,'=') as Condition" + Environment.NewLine;
                strSQL = strSQL + " FROM  LIB_ModelAttributes A" + Environment.NewLine;
                strSQL = strSQL + "         INNER JOIN LIB_Dictionary B ON MA_DZT_Name = DZT_Name" + Environment.NewLine;
                strSQL = strSQL + "         LEFT JOIN LIB_ModelAttributeProperties F ON F.MAP_MA_MOD_ID = MA_MOD_ID and F.MAP_MA_DZT_Name = B.DZT_Name and F.MAP_Propety = 'format'" + Environment.NewLine;
                strSQL = strSQL + "         LEFT JOIN LIB_ModelAttributeProperties C ON C.MAP_MA_MOD_ID = MA_MOD_ID and c.MAP_MA_DZT_Name = B.DZT_Name and c.MAP_Propety = 'SQLCondition'" + Environment.NewLine;
                strSQL = strSQL + " WHERE MA_MOD_ID = '" + Strings.Replace(strModello, "'", "''") + "' and MA_DZT_Name='" + Strings.Replace(strAttributo, "'", "''") + "'" + Environment.NewLine;
                strSQL = strSQL + " ORDER BY MA_Order";
            }
            else
            {

                // --carico le info dell'attributo dal dizionario
                strSQL = "SELECT        top 1 DZT_Name," + Environment.NewLine;
                strSQL = strSQL + "     DZT_Type ,isnull(DZT_MultiValue,0) as DZT_MultiValue," + Environment.NewLine;
                strSQL = strSQL + "     isnull(DZT_Format ,'') as DZT_Format," + Environment.NewLine;
                strSQL = strSQL + "     '=' as Condition" + Environment.NewLine;
                strSQL = strSQL + "     FROM LIB_Dictionary " + Environment.NewLine;
                strSQL = strSQL + " 	WHERE DZT_Name='" + Strings.Replace(strAttributo, "'", "''") + "'" + Environment.NewLine;
            }

            // response.write(strSQL)
            // response.end()

            SqlCommand sqlComm3 = null;
            SqlDataReader rsAttributi = null;
            sqlComm3 = new SqlCommand(strSQL, sqlConn2);
            rsAttributi = sqlComm3.ExecuteReader();

            strWhere = strAttributo + strOperatore + strValore;

            if (rsAttributi.Read())
            {
                strWhere = "";

                if (!string.IsNullOrEmpty(strValore))
                {
                    strcondition = Trim(CStr(rsAttributi["Condition"]));
                    FType = CInt(rsAttributi["DZT_Type"]);

                    // -- Se � un dominio normale, esteso o gerarchico ed � multivalue
                    if ((FType == 4 || FType == 5 || FType == 8) && (CInt(rsAttributi["DZT_MultiValue"]) == 1 || InStr(1, CStr(rsAttributi["DZT_Format"]), "M") > 0))
                    {

                        // --per i multivalore faccio tanti OR sui valori selezionati
                        string tempvale;
                        tempvale = Strings.Replace(strValore, "'", "");
                        alistvalue = Strings.Split(tempvale, "###");

                        string strSql1;
                        string stroperator;

                        string strFieldName;


                        if (Strings.InStr(1, Strings.LCase(strcondition), "like") > 0)
                            strcondition = " like ";
                        strSql1 = "";
                        stroperator = " OR ";

                        if (Strings.LCase(strcondition) == "likeand")
                            stroperator = " AND ";

                        for (k = 0; k <= Information.UBound(alistvalue); k++)
                        {
                            if (!string.IsNullOrEmpty(alistvalue[k]))
                            {
                                strFieldName = strAttributo;

                                if (Strings.Trim(strcondition) == "like" | Strings.Trim(strcondition) == "=")
                                    strFieldName = " '###' + " + strFieldName + " + '###' ";

                                if (string.IsNullOrEmpty(strSql1))
                                    strSql1 = strSql1 + strFieldName + " " + strcondition + " ";
                                else
                                    strSql1 = strSql1 + stroperator + strFieldName + " " + strcondition + " ";

                                if (Strings.Trim(strcondition) == "like")
                                {
                                    v = Strings.Replace(alistvalue[k], "*", "%");
                                    v = "'%###" + v + "###%'";
                                    strSql1 = strSql1 + v;
                                }
                                else
                                    strSql1 = strSql1 + "'###" + alistvalue[k] + "###'";
                            }
                        }

                        strWhere = strWhere + " ( " + strSql1 + " ) ";
                    }
                    else if (FType == 6 | FType == 22)
                    {

                        // -- per gli attributi di tipo data se la formattazione della data � dd/mm/yyyy si taglia l'orario
                        if (LCase(CStr(rsAttributi["DZT_Format"])) == "dd/mm/yyyy" || LCase(CStr(rsAttributi["DZT_Format"])) == "mm/dd/yyyy")
                        {
                            strWhere = strWhere + " convert( varchar(10) , " + strAttributo + " , 121 ) ";
                            strWhere = strWhere + " " + strcondition + " ";
                            strWhere = strWhere + Strings.Left(strValore, 11) + "'";
                        }
                        else
                        {
                            strWhere = strWhere + strAttributo;
                            strWhere = strWhere + " " + strcondition + " ";
                            strWhere = strWhere + strValore;
                        }
                    }
                    else
                    {
                        strWhere = strWhere + strAttributo;


                        // -- Se testo ,textarea o email
                        if (FType == 1 | FType == 3 | FType == 14)
                        {
                            strcondition = "like";

                            strWhere = strWhere + " " + strcondition + " ";

                            string specialCharLeft;
                            string specialCharRight;

                            specialCharLeft = "%";
                            specialCharRight = "%";

                            v = Strings.Replace(strValore, "*", "%");

                            if (Strings.UCase(strcondition) == "LIKE")
                            {

                                // -- Se la condizione � di like e nel valore che si � inserito
                                // -- c'� all'inizio o alla fine della stringa la parantesi quadra,
                                // -- vuol dire che si sta cercando una parola che inizia o finisce
                                // -- nel modo richiesto e non si vuole cercare all'interno della stringa
                                // -- utilizzando cio� il % ( che rimane il default ). Se invece
                                // -- si scrive [xxx] vuol dire che si sta cercando solo le parole esatte xxx
                                // -- e non verranno messi i % ne prima ne dopo

                                if (Strings.Len(v) >= 3)
                                {
                                    if (Strings.Mid(v, 2, 1) == "[")
                                    {
                                        specialCharLeft = "";

                                        // -- tolgo il [ all'inizio
                                        v = "'" + Strings.Right(v, Strings.Len(v) - 2);
                                    }

                                    if (Strings.Left(Strings.Right(v, 2), 1) == "]")
                                    {
                                        specialCharRight = "";

                                        // -- tolgo il ] alla fine
                                        v = Strings.Left(v, Strings.Len(v) - 2) + "'";
                                    }
                                }
                            }

                            v = "'" + specialCharLeft + Strings.Mid(v, 2, Strings.Len(v) - 2) + specialCharRight + "'";

                            strWhere = strWhere + v;
                        }
                        else
                        {
                            strWhere = strWhere + " " + strcondition + " ";
                            strWhere = strWhere + strValore;
                        }
                    }
                }
            }

            rsAttributi.Close();


            return strWhere;
        }


        public static string StripTags(string html)
        {

            // Remove HTML tags.

            string replacementstring = "";
            string matchpattern = @"<(?:[^>=]|='[^']*'|=""[^""]*""|=[^'""][^\s>]*)*>";
            return Regex.Replace(html, matchpattern, replacementstring, RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Multiline | RegexOptions.Singleline);
        }

        // --converte la data dal formato tecnico in una data
        public static DateTime StrToDate(string strValue)
        {

            // --esempio data formato tecnico 2012-03-22T11:00:00
            if (strValue.Length == 10)
                strValue = strValue + " 00:00:00";

            if (strValue.Length == 19)
                return new DateTime(CInt(strValue.Substring(0, 4)), CInt(strValue.Substring(5, 2)), CInt(strValue.Substring(8, 2)), CInt(strValue.Substring(11, 2)), CInt(strValue.Substring(14, 2)), CInt(strValue.Substring(17, 2)));

            return new DateTime();
        }

        static public void AggiungiFoglio(XLWorkbook pck, string strNomeFoglio, SqlDataReader rsColonneFunc, SqlDataReader rsDati)
        {


            // --INIZIO FARE DIVENTARE UNA FUNZIONE 
            string strCause = "";

            strCause = "Aggiungo il foglio di lavoro dati";

            // Aggiugo lo sheet 'Documenti'
            IXLWorksheet ws;
            ws = pck.Worksheets.Add(strNomeFoglio);
            //ws.View.ShowGridLines = true; // mostro la griglia
            ws.PageSetup.ShowGridlines = true;
            // --------------------------------------
            // -- CASO D'USO CON MODELLO DI OUTPUT --
            // --------------------------------------

            string listaColonne = "";
            string listaColonneType = "";
            string listaColonneFormat = "";
            int m = 0;
            int indCol = 0;
            string strVisualValue = "";
            int dztType = 0;
            string strFormat = "";
            string strTechValue = "";
            int indRow = 0;

            // --------------------------------------------------
            // -- CICLO SULLE COLONNE PER GENERARE LA TESTATA --
            // --------------------------------------------------


            if (rsColonneFunc.Read())
            {
                indCol = 1;

                do
                {
                    listaColonne = listaColonne + "###" + rsColonneFunc["DZT_Name"];
                    listaColonneType = listaColonneType + "###" + rsColonneFunc["DZT_Type"];
                    listaColonneFormat = listaColonneFormat + "@@@" + rsColonneFunc["DZT_Format"];
                    strCause = "Lavoro la colonna " + CStr(indCol);
                    strVisualValue = CStr(rsColonneFunc["Caption"]);
                    dztType = CInt(rsColonneFunc["DZT_Type"]);
                    strFormat = CStr(rsColonneFunc["DZT_Format"]);
                    ws.Cell(1, indCol).Value = strVisualValue;

                    // -- se � una data e non ha una format specifica ne applico una di default
                    if (dztType == 6 & string.IsNullOrEmpty(strFormat))
                        strFormat = "dd/mm/yyyy";


                    // ---  IMPOSTO LA FORMAT SULLA COLONNA 
                    switch (dztType)
                    {
                        case 2:
                        case 6:
                        case 7:
                            {
                                strCause = "Imposto la format";
                                strFormat = Replace(strFormat, "~", "");
                                ws.Column(indCol).Style.NumberFormat.SetFormat(strFormat);
                                break;
                            }

                        default:
                            {

                                // -- imposto il formato cella testo
                                ws.Column(indCol).Style.NumberFormat.SetFormat("@");
                                break;
                            }
                    }

                    strCause = "Imposto lo stile";
                    ws.Cell(1, indCol).Style.Font.Bold = true;
                    ws.Cell(1, indCol).Style.Protection.SetLocked(true);
                    ws.Column(indCol).AdjustToContents();
                    indCol = indCol + 1;
                }
                while (rsColonneFunc.Read())// SE number, date , colored number// AD ESEMPIO "#,##0.00" o "dd/mm/yyyy"
    ;
            }
            else
            {
                rsColonneFunc.Close();
                rsDati.Close();

                throw new Exception(strCause + "Metadati per le colonne mancanti");
            }


            // Response.write("A---" & listaColonne & "---B<br>")
            // Response.write("A---" & listaColonneType & "---B")
            // response.end


            // --------------------------------------------------
            // --------------------- CICLO SUI DATI -------------
            // --------------------------------------------------
            object strTempVal;
            int posCol;
            string typeCol;

            string[] resSplit;
            string[] resSplitType;
            string[] resSplitFormat;

            resSplit = Strings.Split(listaColonne, "###");
            resSplitType = Strings.Split(listaColonneType, "###");
            resSplitFormat = Strings.Split(listaColonneFormat, "@@@");




            if (rsDati.Read())
            {
                indRow = 2;

                do
                {

                    // -- CICLO DELLE RIGHE


                    indCol = 1;

                    // -- non potendo fare una movefirst per ritornare all'inizio del recordset, rieseguo la query
                    // --sqlComm2.Dispose()
                    // --rsColonne.Close()

                    // --strCause = "Recupero le informazioni delle colonne"
                    // --strSQL = "exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV '" & Replace(MODEL, "'", "''") & "' , '" & Replace(HIDECOL, "'", "''") & "', 1"
                    // --sqlComm2 = New SqlCommand(strSQL, sqlConn2)
                    // --rsColonne = sqlComm2.ExecuteReader()

                    // --rsColonne.Read()

                    for (m = 1; m <= resSplit.Length - 1; m++)
                    {
                        // --Do
                        // -- ciclo delle colonne

                        strVisualValue = "";

                        // Response.write("SCRIVO LA COLONNA " & resSplit(m))
                        // Response.Write(rsDati(resSplit(m)))


                        strCause = "Lavoro la colonna " + CStr(indCol) + " - Nome = " + resSplit[m] + " e la riga " + CStr(indRow);

                        // -- setto il valore nella cella
                        // --If Not IsDbNull(rsDati(rsColonne("DZT_Name"))) Then

                        // dim tmpStrTestVal as Object = rsDati(resSplit(m))

                        strCause = "Lavorobis la colonna " + CStr(indCol) + " - Nome = " + resSplit[m] + " e la riga " + CStr(indRow);
                        if (!IsDbNull(rsDati[resSplit[m]]))
                        {

                            // strVisualValue = rsDati(nomeColonna)


                            // --posCol = rsDati.GetOrdinal(rsColonne("DZT_Name"))
                            posCol = rsDati.GetOrdinal(resSplit[m]);
                            typeCol = UCase(rsDati.GetFieldType(posCol).Name);

                            // Response.write("A---" & typeCol & "---B")
                            // Response.write("<br/>")
                            // --per attributi numerici, se il tipo della colonna non � coerente con il dizionario lo trasformo in numerico
                            // --if ( rsColonne("DZT_Type") = "2"  and  typeCol <> "INT32" and typeCol <> "DOUBLE" and Not IsDbNull( rsDati(rsColonne("DZT_Name")) ) )  then
                            if ((resSplitType[m] == "2" & typeCol != "BOOLEAN" & typeCol != "INT32" & typeCol != "DOUBLE" & typeCol != "DECIMAL" & typeCol != "BYTE" & !IsDbNull(rsDati[resSplit[m]])))
                            {
                                strTempVal = "";

                                // --strTempVal = rsDati(rsColonne("DZT_Name"))
                                // long longValue = Convert.ToInt64(doubleValue);

                                strTempVal = rsDati[resSplit[m]];
                                strCause = "typeCol=" + typeCol + " converto " + strTempVal + " da stringa in double tipo dizionario = " + resSplitType[m];

                                // -- TEST PER IL REGIONAL SETTINGS
                                if (Strings.InStr(1, CStr(0.5), ",") > 0)
                                    strTempVal = Replace(CStr(strTempVal), ".", ",");
                                if ((strTempVal != ""))
                                    ws.Cell(indRow, indCol).Value = CDbl(strTempVal);
                            }
                            else if (resSplitType[m] == "6")
                            {
                                strCause = "tratto le date valore cella ='" + rsDati[resSplit[m]] + "' -- tipo dizionario=" + resSplitType[m];
                                if (typeCol == "DATETIME")
                                    ws.Cell(indRow, indCol).Value = rsDati[resSplit[m]];
                                else
                                    ws.Cell(indRow, indCol).Value = StrToDate(CStr(rsDati[resSplit[m]]));
                            }
                            else
                            {
                                strCause = "tratto gli altri tipi valore cella ='" + rsDati[resSplit[m]] + "' -- tipo dizionario=" + resSplitType[m];

                                // --ws.Cells(indRow, indCol).Value = rsDati(rsColonne("DZT_Name"))
                                // --ws.Cells(indRow, indCol).IsRichText = true
                                // --se la format contiene la H allora applico la StripTags
                                // --per togliere i tag html

                                if (Strings.InStr(1, Strings.UCase(resSplitFormat[m]), "H") == 0)
                                    ws.Cell(indRow, indCol).Value = rsDati[resSplit[m]];
                                else
                                    ws.Cell(indRow, indCol).Value = StripTags(CStr(rsDati[resSplit[m]]));
                            }
                        }

                        // -- setto il valore nella cella
                        // ws.Cells(indRow, indCol).Value = strVisualValue

                        indCol = indCol + 1;
                    }

                    indRow = indRow + 1;
                }
                while (rsDati.Read());
            }

            // response.end()

            strCause = "Dispose dell'oggetto excel";
            // ws.Dispose()
            // ws = Nothing

            rsDati.Close();

            strCause = "Chiudo i recordset";


            rsColonneFunc.Close();
        }

    }
}

