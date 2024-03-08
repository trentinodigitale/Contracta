using ClosedXML.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Security;
using Microsoft.VisualBasic;
using System.Data.SqlClient;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using FileAccess = System.IO.FileAccess;

namespace eProcurementNext.Razor.Pages.AVCP
{
    public class avcp_xlsxModel
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

        private static string strConnectionString = ApplicationCommon.Application.ConnectionString;//ConfigurationSettings.AppSettings("db.conn");
        private static string paginaChiamata = "avcp/avcp_xlsx.aspx";
        private static int mp_idpfu = -20;
        private static eProcurementNext.Session.ISession session;


        public static void Page_Load(HttpContext HttpContext, EprocResponse htmlToReturn, eProcurementNext.Session.ISession _session)
        {
            Microsoft.AspNetCore.Http.HttpResponse Response = HttpContext.Response;
            Microsoft.AspNetCore.Http.HttpRequest Request = HttpContext.Request;
            session = _session;

            int indCol = 0;
            int indRow = 0;
            string idpfu = GetParamURL(Request.QueryString.ToString(), "UFP");
            string filter = CStr(GetParamURL(Request.QueryString.ToString(), "filter"));
            string strCause = "";
            string strSQL = "";

            string strfilename = GetParamURL(Request.QueryString.ToString(), "TitoloFile");
            SqlConnection sqlConn1 = null;
            SqlConnection sqlConn2 = null;

            bool attivaDebug = true;



            string P_Azi_Ente;
            P_Azi_Ente = GetParamURL(Request.QueryString.ToString(), "Azi_Ente");
            validaInput("Azi_Ente", P_Azi_Ente, TIPO_PARAMETRO_INT, CStr(SOTTO_TIPO_VUOTO), HttpContext);

            string P_CIG;
            P_CIG = GetParamURL(Request.QueryString.ToString(), "CIG");
            validaInput("CIG", P_CIG, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_VUOTO), HttpContext);

            string P_Anno;
            P_Anno = GetParamURL(Request.QueryString.ToString(), "Anno");
            validaInput("Anno", P_Anno, TIPO_PARAMETRO_INT, CStr(SOTTO_TIPO_VUOTO), HttpContext);

            string P_Oggetto;
            P_Oggetto = GetParamURL(Request.QueryString.ToString(), "Oggetto");
            validaInput("Oggetto", P_Oggetto, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_VUOTO), HttpContext);

            string SingoloEnte;
            string EntiPerCF;

            SingoloEnte = GetParamURL(Request.QueryString.ToString(), "SINGOLO_ENTE");

            if (SingoloEnte == "yes")
                EntiPerCF = "no";
            else
                EntiPerCF = "si";

            //ExcelPackage pck;
            XLWorkbook pck;


            try
            {
                if (strfilename == "")
                    strfilename = "gare";

                strfilename = strfilename + ".xlsx";

                strfilename = Strings.Replace(strfilename, "..", ""); // -- replace per evitare Path Traversal
                strfilename = Strings.Replace(strfilename, "/", "");  // -- replace per evitare Path Traversal
                strfilename = Strings.Replace(strfilename, @"\", "");  // -- replace per evitare Path Traversal


                // ------------------------------------
                // --- APRO LA CONNESSIONE CON IL DB --
                // ------------------------------------

                strCause = "Apro la connessione con il db";
                sqlConn1 = new SqlConnection(strConnectionString);
                sqlConn1.Open();

                sqlConn2 = new SqlConnection(strConnectionString);
                sqlConn2.Open();


                string strVisualValue = "";
                int dztType = 0;
                string strFormat = "";
                string strTechValue = "";

                // ------------------------------------
                // ------- INIZIALIZZO L'XSLX ---------
                // ------------------------------------



                strCause = "Inizializzo excelpackage";
                //pck = new ExcelPackage();
                pck = new XLWorkbook();


                strCause = "Aggiungo il foglio di lavoro dati";

                // Aggiugo lo sheet 'Dati'
                //ExcelWorksheet ws;
                IXLWorksheet ws;
                ws = pck.Worksheets.Add("avcp");

                //ws.View.ShowGridLines = true; // mostro la griglia
                ws.PageSetup.ShowGridlines = true;



                strCause = "Eseguo la select per il recupero dei dati";
                strSQL = "exec AVCP_EXPORT_CSV 0 , '" + Strings.Replace(P_Azi_Ente, "'", "''") + "' , '" + Strings.Replace(P_CIG, "'", "''") + "' , '" + Strings.Replace(P_Anno, "'", "''") + "' , '" + Strings.Replace(P_Oggetto, "'", "''") + "' , '" + Strings.Replace(EntiPerCF, "'", "''") + "' ";

                SqlCommand sqlComm = new SqlCommand(strSQL, sqlConn1);
                sqlComm.CommandTimeout = 1800; // il default era 30 secondi

                SqlDataReader rsDati = sqlComm.ExecuteReader();

                SqlCommand sqlComm2;
                SqlDataReader rsColonne;
                string listaColonneOrdinate = "";

                // -- compongo la select per recuperare le colonne da inserire nel foglio di lavoro
                strCause = "Eseguo la select per recuperare le colonne";
                strSQL = "exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV 'AVCP_EXPORT_CSV' , ''";

                sqlComm2 = new SqlCommand(strSQL, sqlConn2);
                rsColonne = sqlComm2.ExecuteReader();

                // --------------------------------------------------
                // -- CICLO SULLE COLONNE PER GENERARE LA TESTATA --
                // --------------------------------------------------
                if (rsColonne.Read())
                {
                    indCol = 1;

                    do
                    {
                        strCause = "Lavoro la colonna " + CStr(indCol);
                        strVisualValue = CStr(rsColonne["Caption"]);
                        dztType = CInt(rsColonne["DZT_Type"]);
                        strFormat = CStr(rsColonne["DZT_Format"]);
                        listaColonneOrdinate = listaColonneOrdinate + rsColonne["DZT_Name"] + "###";
                        ws.Cell(1, indCol).Value = strVisualValue;

                        // -- se è una data e non ha una format specifica ne applico una di default
                        if (dztType == 6 & strFormat == "")
                            strFormat = "dd/MM/yyyy";

                        // ---  IMPOSTO LA FORMAT SULLA COLONNA 
                        switch (dztType)
                        {
                            case 2:
                            case 6:
                            case 7:
                                {
                                    strCause = "Imposto la format";
                                    strFormat = Strings.Replace(strFormat, "~", "");
                                    ws.Column(indCol).Style.NumberFormat.Format = strFormat;
                                    break;
                                }

                            default:
                                {

                                    // -- imposto il formato cella testo
                                    ws.Column(indCol).Style.NumberFormat.Format = "@";
                                    break;
                                }
                        }

                        strCause = "Imposto lo stile";
                        ws.Cell(1, indCol).Style.Font.Bold = true;
                        ws.Cell(1, indCol).Style.Protection.SetLocked(true);
                        ws.Column(indCol).AdjustToContents();
                        indCol = indCol + 1;
                    }
                    while (rsColonne.Read())// SE number, date , colored number// AD ESEMPIO "#,##0.00" o "dd/mm/yyyy"
    ;
                }
                else
                {
                    rsColonne.Close();
                    //rsColonne = null;
                    rsDati.Close();
                    //rsDati = null;

                    throw new Exception("Metadati per le colonne mancanti");
                }

                // dim nomeColonna as String = ""
                string[] listaColonne;

                // --------------------------------------------------
                // --------------------- CICLO SUI DATI -------------
                // --------------------------------------------------
                if (rsDati.Read())
                {
                    indRow = 2;

                    do
                    {

                        // -- CICLO DELLE RIGHE

                        indCol = 1;
                        sqlComm2.Dispose();
                        rsColonne.Close();
                        strCause = "Recupero le informazioni delle colonne";
                        // -- non potendo fare una movefirst per ritornare all'inizio del recordset, rieseguo la query
                        // strSQL = "exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV 'AVCP_EXPORT_CSV' , ''"
                        // sqlComm2 = New SqlCommand(strSQL, sqlConn2)
                        // rsColonne = sqlComm2.ExecuteReader()

                        // rsColonne.Read()

                        listaColonne = Strings.Split(listaColonneOrdinate, "###");

                        // Do
                        foreach (string nomeColonna in listaColonne)
                        {

                            // -- ciclo delle colonne

                            if (nomeColonna != "")
                            {
                                strCause = "Lavoro la colonna " + CStr(indCol) + " e la riga " + CStr(indRow);

                                // -- setto il valore nella cella
                                if (!IsDbNull(rsDati[nomeColonna]))
                                {

                                    // -- recupero dinamicamente la natura della colonna restituita dal recordset ed in base al suo tipo utilizzo una format specifica
                                    int indiceColonna = rsDati.GetOrdinal(nomeColonna);
                                    Type tipoColonna = rsDati.GetFieldType(indiceColonna);
                                    string strTipoColonna = Strings.UCase(CStr(tipoColonna.Name));
                                    string strFormatCol = "@";
                                    switch (strTipoColonna)
                                    {
                                        case "INT32":
                                            {
                                                strFormatCol = "#.##0";
                                                break;
                                            }

                                        case "DOUBLE":
                                            {
                                                strFormatCol = "#,##0.00";
                                                break;
                                            }

                                        case "DATETIME":
                                            {
                                                strFormatCol = "dd/MM/yyyy";
                                                break;
                                            }

                                        default:
                                            {
                                                // String
                                                strFormatCol = "@";
                                                break;
                                            }
                                    }

                                    ws.Cell(indRow, indCol).Style.NumberFormat.Format = strFormatCol;
                                    ws.Cell(indRow, indCol).Value = rsDati[nomeColonna];
                                }

                                indCol = indCol + 1;
                            }
                        }
                        // Loop While rsColonne.Read

                        indRow = indRow + 1;
                    }
                    while (rsDati.Read())// -- il default lo lascio a stringa// "###,###,##0" '#,##0.00// "###,###,##0.00###"
    ;
                }



                strCause = "Chiudo i recordset";

                rsDati.Close();



                strCause = "Imposto il contentype di output";
                Response.ContentType = "application/XLSX";
                Response.Headers.TryAdd("content-disposition", "attachment; filename=" + Strings.Replace(strfilename, " ", "_"));

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

                //htmlToReturn.BinaryWrite(HttpContext, pck.GetAsByteArray());

                pck.Dispose();

                strCause = "Chiudo le connessioni";
                sqlConn1.Close();
                sqlConn2.Close();
            }
            catch (Exception ex)
            {
                string msgError = "Si è verificato un errore di sistema.<br/>";
                msgError = msgError + "Occorre ripetere l'operazione, nel caso in cui il problema si dovesse ripresentare si può contattare il supporto per avere maggiori informazioni.<br/>";
                msgError = msgError + "Il riferimento é :" + DateAndTime.Now;

                string msgErrExt = strCause + " -- " + ex.ToString();

                if (attivaDebug)
                    htmlToReturn.Write(msgErrExt);
                else
                    htmlToReturn.Write(msgError);

                traceError(sqlConn1, idpfu, msgErrExt, Request.Path);

                if (sqlConn1 != null)
                    sqlConn1.Close();

                if (sqlConn2 != null)
                    sqlConn2.Close();
            }
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

            sEvent = Strings.Left("Errore nella generazione del file XLSX.URL:" + querystring + " --- Descrizione dell'errore : " + descrizione, 4000);

            strSQL = "INSERT INTO CTL_LOG_UTENTE (idpfu,datalog,paginaDiArrivo,querystring,descrizione) " + Environment.NewLine;
            strSQL = strSQL + " VALUES(" + idpfu + ", getdate(), '" + contesto + "', '" + Strings.Replace(typeTrace, "'", "''") + "', '" + Strings.Replace(sEvent, "'", "''") + "')";

            var sqlComm = new SqlCommand(strSQL, sqlConn);
            sqlComm.ExecuteNonQuery();

            WriteToEventLog(sEvent);

        }

        private string ColumnIndexToColumnLetter(int colIndex)
        {
            int div = colIndex;
            string colLetter = string.Empty;
            int modnum = 0;

            while (div > 0)
            {
                modnum = (div - 1) % 26;
                colLetter = Strings.Chr(65 + modnum) + colLetter;
                div = CInt((div - modnum) / 26);
            }

            return colLetter;
        }

        private void disegnaGriglia(IXLWorksheet ws, int totRighe, int totColonne)
        {
            var letteraExcel = ColumnIndexToColumnLetter(totColonne);
            ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.BottomBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.LeftBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.RightBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
            ws.Cell("A1:" + letteraExcel + totRighe).Style.Border.TopBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

            ws.Cell("A1:" + letteraExcel + totRighe).Style.NumberFormat.Format = "@";
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
                            if (Information.IsNumeric(valoreDaValidare) == false)
                                isAttacked = true;
                            break;
                        }

                    case TIPO_PARAMETRO_DATA:
                        {
                            if (Information.IsDate(valoreDaValidare) == false)
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
                                        if (objSecurityLib.isValidValue(valoreDaValidare, 1) == false)
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_SORT:
                                    {
                                        if (objSecurityLib.isValidSqlSort(valoreDaValidare, "") == false)
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_FILTROSQL:
                                    {
                                        if (objSecurityLib.isValidFilterSql(valoreDaValidare) == false)
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_LISTANUMERI:
                                    {
                                        if (objSecurityLib.isValidValue(valoreDaValidare, 4) == false)
                                            isAttacked = true;
                                        break;
                                    }
                            }

                            break;
                        }
                }

                objSecurityLib = null;

                if (isAttacked == true)
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
    }
}

