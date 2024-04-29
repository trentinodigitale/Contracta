using ClosedXML.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using eProcurementNext.Security;
//using Microsoft.VisualBasic;
using System.Data.SqlClient;
using System.Diagnostics;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using FileAccess = System.IO.FileAccess;
using DocumentFormat.OpenXml.EMMA;
using eProcurementNext.CommonDB;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class downloadModel
    {

        public void OnGet()
        {
            throw new NotSupportedException("Pagina non più supportata in seguito a reingegnerizzazione di altra pagina in origine chiamante");
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


        const int BLOCCO_READ_BYTE = 10000;

        private static string strConnectionString = ApplicationCommon.Application.ConnectionString;//ConfigurationSettings.AppSettings("db.conn");
        private static string strMotivoBlocco;
        private static int mp_idpfu = -20;
        private static string mp_sessionID = string.Empty;
        private static string paginaChiamata = "ctl_library/functions/download.aspx";

        private static string mp_strNomeCompleto;
        private static string mp_strNomeFIle;
        private static string mp_strDeleteFIle;
        private static string mp_str_Drive;
        private static string mp_str_UserName;
        private static string mp_str_Pwd;
        private static Process p = new Process();
        private static eProcurementNext.Session.ISession session;


        public static void Page_Load(HttpContext HttpContext, EprocResponse htmlToReturn, eProcurementNext.Session.ISession _session)
        {

            throw new NotSupportedException("Pagina non più supportata in seguito a reingegnerizzazione di altra pagina in origine chiamante");


            Microsoft.AspNetCore.Http.HttpResponse Response = HttpContext.Response;
            Microsoft.AspNetCore.Http.HttpRequest Request = HttpContext.Request;
            session = _session;

            string strCause = "";
            SqlConnection sqlConn1 = new SqlConnection(strConnectionString);
            sqlConn1.Open();

            string motivo = string.Empty;
            string guid = CStr(GetParamURL(Request.QueryString.ToString(), "acckey"));

            try
            {
                strCause = "RECUPERO guid";
                if (guid == "")
                {
                    strMotivoBlocco = "Riferimento non trovato";
                    motivo = "Permesso di accesso negato al download. Motivazione: [[" + strMotivoBlocco + "]] ";
                    sendBlock(paginaChiamata, motivo, HttpContext);
                }

                strCause = "validaInput guid";
                validaInput("acckey", guid.Replace("-", ""), TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);

                // --RECUPERO PARAEMTRI PER FARE IL DOWNLOAD DELLO ZIP
                strCause = "RECUPERO PARAEMTRI PER FARE IL DOWNLOAD DELLO ZIP";
                getParameterFromGuid(guid);


                // --se mp_strNomeCompleto non inizia con una lettera allora faccio il MAP con un drive logico
                strCause = "MAP_SHARE_WITH_DRIVE";
                MAP_SHARE_WITH_DRIVE();

                // response.write (mp_strNomeCompleto & "<br>" )
                // response.write (mp_strNomeFIle & "<br>" )
                // response.end

                if (System.IO.File.Exists(mp_strNomeCompleto))
                {
                    Response.ContentType = "application/zip";
                    Response.Headers.TryAdd("content-disposition", "attachment; filename=" + mp_strNomeFIle.Replace(" ", "_"));


                    // apriamo il file
                    strCause = "apriamo il file";
                    // Dim objStream as Stream = File.Open(mp_strNomeCompleto, FileMode.Open)
                    System.IO.Stream objStream = File.Open(mp_strNomeCompleto, FileMode.Open, FileAccess.Read, FileShare.Read);


                    byte[] buffer = new byte[10001];
                    long ByteLetti;
                    int i;

                    // --CICLO E LEGGO UN BLOCCO ALLA VOLTA E LO MANDO AL CLIENT
                    strCause = "CICLO E LEGGO UN BLOCCO ALLA VOLTA E LO MANDO AL CLIENT";
                    ByteLetti = objStream.Read(buffer, 0, buffer.Length);

                    while (ByteLetti > 0)
                    {

                        // --VERIFICARE CHE IL CLIENT SIA CONNESSO 



                        if (ByteLetti == buffer.Length)
                        {
                            htmlToReturn.BinaryWrite(HttpContext, buffer);
                            // response.write ( ByteLetti & "<br>" )

                            // --LEGGIAMO IL CONTENUTO
                            strCause = "LEGGIAMO IL CONTENUTO";
                            ByteLetti = objStream.Read(buffer, 0, buffer.Length);
                        }
                        else
                        {

                            // --byte[] BufferLast = new byte[(int)ByteLetti];
                            byte[] BufferLast = new byte[ByteLetti + 1];

                            // --copio il buffer in BufferLast
                            strCause = "copio il buffer in BufferLast";
                            for (i = 0; i <= ByteLetti - 1; i++)
                                BufferLast[i] = buffer[i];

                            htmlToReturn.BinaryWrite(HttpContext, BufferLast);
                            // response.write ( "last=" & ByteLetti & "<br>" )
                            ByteLetti = 0;
                        }


                        // --inviamo in output al browser
                        //Response.flush();
                    }

                    strCause = "CHIUDO objStream";
                    objStream.Close();


                    // --SE RICHIESTO CANCELLO IL FILE CHE HO SCARICATO
                    strCause = "Cancello il file precedente se presente";
                    if (mp_strDeleteFIle.ToLower() == "delete")
                    {
                        if (File.Exists(mp_strNomeCompleto))
                            File.Delete(mp_strNomeCompleto);
                    }


                    // --TOLGO IL MAP DEL DRIVE LOGICO
                    UnMapDrive(mp_str_Drive);
                }
                else
                {
                    htmlToReturn.Write(mp_strNomeCompleto + " non esiste");
                    //response.end();
                    throw new ResponseEndException(htmlToReturn.Out(), Response, mp_strNomeCompleto + " non esiste");
                }
            }
            catch (Exception ex)
            {

                // --SEGNALO L'Errore
                traceError(sqlConn1, CStr(mp_idpfu), strCause + " -- " + ex.Message, Request.Path);
            }

            // --PROVO A CHIUDERE LA CONNESSIONE UTILIZZATA PER IL LOG DELL'ERRORE
            try
            {
                sqlConn1.Close();
            }
            catch (Exception ex3)
            {
            }
        }

        public static void getParameterFromGuid(string guid)
        {
            var sqlConn = new SqlConnection(strConnectionString);
            sqlConn.Open();

            string strSql = "select idpfu,sessionid,PKCE_code_challenge,PKCE_code_verifier, isnull(id_token,'') as id_token from CTL_ACCESS_BARRIER with(nolock) where guid = '" + guid.Replace("'", "''") + "' and datediff(SECOND, data,getdate()) <= 30";

            SqlCommand sqlComm = new SqlCommand(strSql, sqlConn);
            SqlDataReader rs = sqlComm.ExecuteReader();

            if ((rs.Read()))
            {
                mp_idpfu = CInt(rs["idpfu"]);
                mp_sessionID = CStr(rs["sessionid"]);
                mp_strNomeCompleto = CStr(rs["PKCE_code_challenge"]);
                mp_strNomeFIle = CStr(rs["PKCE_code_verifier"]);
                mp_strDeleteFIle = CStr(rs["id_token"]);
            }

            rs.Close();

            // --CANCELLO ENTRATA NELLA CTL_ACCESS_BARRIER PER IL MIO GUID
            strSql = "delete ctl_access_barrier where guid='" + guid.Replace("'", "''") + "'";
            // Dim sqlComm1 As New SqlCommand(strSql, sqlConn)
            // sqlComm1.ExecuteNonQuery()
            // sqlComm1 = Nothing

            sqlConn.Close();


        }

        private static void traceError(SqlConnection sqlConn, string idpfu, string descrizione, string querystring)
        {
            string strSQL = "";
            var contesto = "Generazione XLSX";
            string typeTrace = "TRACE-ERROR";

            string sSource;
            string sLog;
            string sEvent;
            string sMachine;

            if (string.IsNullOrEmpty(idpfu))
                idpfu = "-1";

            sEvent = ("Errore nella generazione del file XLSX.URL:" + querystring + " --- Descrizione dell'errore : " + descrizione).Substring(0, 4000);

            strSQL = "INSERT INTO CTL_LOG_UTENTE (idpfu,datalog,paginaDiArrivo,querystring,descrizione) " + Environment.NewLine;
            strSQL = strSQL + " VALUES(" + idpfu + ", getdate(), '" + contesto + "', '" + typeTrace.Replace("'", "''") + "', '" + sEvent.Replace("'", "''") + "')";

            var sqlComm = new SqlCommand(strSQL, sqlConn);
            sqlComm.ExecuteNonQuery();

            WriteToEventLog(sEvent);

        }

        private string ColumnIndexToColumnLetter(int colIndex)
        {
            int div = colIndex;
            string colLetter = string.Empty;
            //int modnum = 0;

            //while (div > 0)
            //{
            //    modnum = (div - 1) % 26;
            //    colLetter = Strings.Chr(65 + modnum) + colLetter;
            //    div = CInt((div - modnum) / 26);
            //}

            return colLetter;
        }

        //private void disegnaGriglia(IXLWorksheet ws, int totRighe, int totColonne)
        //{
        //    var letteraExcel = ColumnIndexToColumnLetter(totColonne);
        //    ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.BottomBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
        //    ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.LeftBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
        //    ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.RightBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
        //    ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.TopBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

        //    ws.Cell("A1:" + letteraExcel + totRighe).Style.NumberFormat.Format = "@";
        //}




        /// <summary>
        ///  cancellare ValidaInput in favore di Validate
        /// </summary>
        /// <param name="nomeParametro"></param>
        /// <param name="valoreDaValidare"></param>
        /// <param name="tipoDaValidare"></param>
        /// <param name="sottoTipoDaValidare"></param>
        /// <param name="HttpContext"></param>
        /// <param name="regExp"></param>

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
                    objSecurityLib = new Validation();//Server.CreateObject("CtlSecurity.Validation");
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
                            if (!IsNumeric(valoreDaValidare))
                                isAttacked = true;
                            break;
                        }

                    case TIPO_PARAMETRO_DATA:
                        {
                            if (!IsDate(valoreDaValidare))
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

                    //string motivo = "";

                    //try
                    //{
                    //    motivo = "Injection, CtlSecurity.validate() : Tenativo di modifica del parametro '" + nomeParametro + "'";
                    //}
                    //catch (Exception ex)
                    //{
                    //}



                    string motivo = "Injection, CtlSecurity.validate() : Tenativo di modifica del parametro '" + nomeParametro + "'";
                    sendBlock(paginaChiamata, motivo, HttpContext);
                }
            }
        }

        public static void sendBlock(string paginaAttaccata, string motivo, HttpContext ctx)
        {
            addSecurityBlockTrace(paginaAttaccata, motivo, ctx);
            throw new ResponseRedirectException("../blocked.asp", ctx.Response);
            //Response.Redirect("../blocked.asp");
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

        public static void getInfoForMapShare()
        {
            var sqlConn = new SqlConnection(strConnectionString);
            sqlConn.Open();

            string strSql = "select DZT_ValueDef,DZT_Name from LIB_Dictionary where DZT_Name in  ('SYS_MAP_SHARE_ACCESS_FILE_DRIVE','SYS_MAP_SHARE_ACCESS_FILE_PWD','SYS_MAP_SHARE_ACCESS_FILE_USERNAME')";

            SqlCommand sqlComm = new SqlCommand(strSql, sqlConn);
            SqlDataReader rs = sqlComm.ExecuteReader();

            if ((rs.Read()))
            {
                do
                {
                    if (CStr(rs["DZT_Name"]).ToUpper() == "SYS_MAP_SHARE_ACCESS_FILE_DRIVE")
                        mp_str_Drive = CStr(rs["DZT_ValueDef"]);
                    if (CStr(rs["DZT_Name"]).ToUpper() == "SYS_MAP_SHARE_ACCESS_FILE_USERNAME")
                        mp_str_UserName = CStr(rs["DZT_ValueDef"]);
                    if (CStr(rs["DZT_Name"]).ToUpper() == "SYS_MAP_SHARE_ACCESS_FILE_PWD")
                        mp_str_Pwd = CStr(rs["DZT_ValueDef"]);
                }
                while (rs.Read());
            }

            rs.Close();

            sqlConn.Close();

        }



        public static void MAP_SHARE_WITH_DRIVE()
        {
            string str_Head;
            string str_NewPath;

            str_Head = mp_strNomeCompleto.Substring(0, 1).ToUpper();

            if (str_Head.Contains("*[A-Z]*", StringComparison.Ordinal))
            {
                return;

            }
            else
            {

                getInfoForMapShare();



                if (!string.IsNullOrEmpty(mp_str_Drive) && !string.IsNullOrEmpty(mp_str_UserName) && !string.IsNullOrEmpty(mp_str_Pwd))
                {


                    //'--ricavo il percorso del file senza il nome e ultimo \

                    str_NewPath = mp_strNomeCompleto.Replace(@"\" + mp_strNomeFIle, "");


                    //'response.write ( str_NewPath )

                    //'response.end


                    mp_strNomeCompleto = mp_str_Drive + @":\" + mp_strNomeFIle;


                    MapDrive(mp_str_Drive, str_NewPath, mp_str_UserName, mp_str_Pwd);




                }


            }
        }


        public static void MapDrive(string DriveLetter, string UNCPath, string strUsername, string strPassword)
        {
            p.StartInfo.FileName = "net.exe";
            p.StartInfo.Arguments = " use " + DriveLetter + ": \"" + UNCPath + "\" " + strPassword + " /USER:" + strUsername;
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            p.WaitForExit();
        }

        public static void UnMapDrive(string DriveLetter)
        {

            // p.Kill()
            // net use  z:  /DELETE

            p.StartInfo.FileName = "net.exe";
            p.StartInfo.Arguments = " use " + DriveLetter + ": /DELETE";
            p.StartInfo.CreateNoWindow = true;
            p.Start();
            p.WaitForExit();
        }



    }
}

