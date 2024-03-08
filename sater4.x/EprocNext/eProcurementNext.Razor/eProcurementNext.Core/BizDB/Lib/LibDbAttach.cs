using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using Newtonsoft.Json;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using DocumentFormat.OpenXml.Wordprocessing;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CtlProcess.Basic;
using static eProcurementNext.Application.ApplicationCommon;
using FileAccess = System.IO.FileAccess;
using ISession = eProcurementNext.Session.ISession;
using DocumentFormat.OpenXml.Office2010.Excel;
using StackExchange.Redis;

namespace eProcurementNext.BizDB
{
    public class LibDbAttach
    {
        private string mp_idDoc = string.Empty;
        private string strBinaryHashFile = string.Empty;
        private readonly string algoritmoHashFile = ApplicationCommon.FileHashAlgorithm;
        private string strAttDataInsert = string.Empty;
        private bool bSaltaControlli = false;

        private readonly CommonDbFunctions cdf = new();

        public void run(Session.ISession session, IEprocResponse objResp, HttpContext httpContext, string accessGuid = "", string filePath = "", string fileOriginalName = "")
        {
            var operation = GetParamURL(httpContext.Request.QueryString.ToString(), "OPERATION");

            switch (operation.ToUpper())
            {
                case "INSERT":
                    UpLoadAttach(httpContext, accessGuid, filePath, fileOriginalName);
                    break;

                case "DISPLAY":
                    DisplayAttach(session, objResp, httpContext);
                    break;

                //'--inserisce file firmati associati ad un documento oparti del documento
                case "INSERTSIGN":
                    LibDbAttach.UpLoadAttachSign(session, httpContext, accessGuid, filePath, fileOriginalName);
                    break;

                default:
                    throw new Exception($"LibDbAttach.run() operation {operation} non supportato");
            }

        }

        public string AllegaFirma(ISession session, HttpContext httpContext, string accessGuid, string filePath, string fileOriginalName, string TABLE = "", string IDDOC = "", string CIF = "0", string IDENTITY = "", string AREA = "", string CF = "")
        {
            return LibDbAttach.UpLoadAttachSign(session, httpContext, accessGuid, filePath, fileOriginalName, TABLE, IDDOC, CIF, IDENTITY, AREA,CF);
        }

        public string allegaFile(HttpContext httpContext, string accessGuid, string filePath, string fileOriginalName, string TABLE = "", string IDDOC = "", string IDENTITY = "", string AREA = "")
        {
            string strInfoTechAttach = UpLoadAttach(httpContext, accessGuid, filePath, fileOriginalName);

            if (strInfoTechAttach.StartsWith("1#"))
            {
                strInfoTechAttach = Strings.Split(strInfoTechAttach, "#")[1];
            }
            else if(strInfoTechAttach.StartsWith("0#"))
            {
                throw new Exception("LibDbAttach, UpLoadAttach error: " + Strings.Split(strInfoTechAttach, "#")[1]);
            }
            else
            {
                throw new Exception("LibDbAttach, UpLoadAttach error: " + strInfoTechAttach);
            }

            //'-- se è passata la tabella e l'id vuol dire che vogliamo portare l'allegato su un documento
            if ( !string.IsNullOrEmpty(TABLE) && !string.IsNullOrEmpty(IDDOC)){

                string strArea = AREA;

                string strIdentity = "ID";
                if(!string.IsNullOrEmpty((IDENTITY))) {
                    strIdentity = IDENTITY;
                }


                string strColAttach = "SIGN_ATTACH";


                if( !string.IsNullOrEmpty(strArea)){
                    strColAttach = strArea + "_" + strColAttach;
                }

                //'--aggiorno sul documento la codifca tecnica dell 'allegato di firma
                //string strCause = "aggiorno sul documento la codifca tecnica dell 'allegato di firma";
                Dictionary<string, object?> parColl = new();
                parColl.Add("@strInfoTechAttach", strInfoTechAttach);
                parColl.Add("@IDDOC", CLng(IDDOC));
                string strSQL = "update " + Strings.Replace(TABLE, " ", "") + " set " + strColAttach + " = @strInfoTechAttach Where " + Strings.Replace(strIdentity, " ", "") + " = @IDDOC";


                //strCause = "aggiorno sul documento la codifica tecnica dell 'allegato di firma [" + strSQL + "]";

                CommonDbFunctions cdf = new();
                cdf.Execute(strSQL, ApplicationCommon.Application.ConnectionString, parCollection: parColl);


            }

            return strInfoTechAttach;
            

        }

        //'--inserisce un nuovo attach nella tabella CTL_ATTACH e poi aggiorna html a video dell'attributo
        public string UpLoadAttach(HttpContext httpContext, string accessGuid, string filePath, string fileOriginalName)
        {
            if (string.IsNullOrEmpty(accessGuid) || string.IsNullOrEmpty(filePath) || string.IsNullOrEmpty(fileOriginalName))
            {
                throw new Exception("Errore UpLoadAttach, non sono stati forniti i parametri necessari");
            }

            //Es: http://localhost/AF_WebFileManager/proxy/1.0/uploadpath?filename=nomeFile.pdf&filepath=e:\PortaleGareTelematiche\Allegati\Busta_TEC_77.pdf&timeout=60&OPERATION=INSERT

            string AF_WebFileManager = "AF_WebFileManager";
            string urlToInvoke;
            if (!string.IsNullOrEmpty(ApplicationCommon.Application["NOMEAPPLICAZIONE_ALLEGATI"]))
            {
                AF_WebFileManager = CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE_ALLEGATI"]);
            }
            if (IsEmpty(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]) || string.IsNullOrEmpty(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]))
            {
                urlToInvoke = httpContext.GetServerVariable("LOCAL_ADDR") + "/" + AF_WebFileManager + "/proxy/1.0/uploadpath?filename=";
            }
            else
            {
                urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + "/" + AF_WebFileManager + "/proxy/1.0/uploadpath?filename=";
            }

            urlToInvoke = urlToInvoke + CStr(fileOriginalName) + "&filepath=" + URLEncode(filePath) + "&OPERATION=INSERT" + "&timeout=" + URLEncode(ApplicationCommon.Application["timeoutApiCall"]);
            urlToInvoke = urlToInvoke + "&acckey=" + URLEncode(CStr(accessGuid));

            string returnedString = invokeUrl(urlToInvoke);

            ReturnedJson? returnedJson = JsonConvert.DeserializeObject<ReturnedJson>(returnedString);

            //JSON di ritorno {esit:true, content:<VALORE TECNICO>, message: <MESSAGGIO IN CASO DI ERRORE>}
            if (returnedJson is not null)
            {
                if (returnedJson.esit)
                {
                    return $"1#{returnedJson.content}";
                }
                else
                {
                    return $"0#{returnedJson.message}";
                }
            }
            else
            {
                throw new Exception("JSON di ritorno == null");
            }
        }

        public static string UpLoadAttachSign(ISession session, HttpContext httpContext, string accessGuid, string filePath, string fileOriginalName, string table = "", string iddoc = "", string cif = "0", string identity = "", string area = "", string CF = "")
        {
            if (string.IsNullOrEmpty(accessGuid) || string.IsNullOrEmpty(filePath) || string.IsNullOrEmpty(fileOriginalName))
            {
                throw new Exception("Errore UpLoadAttach, non sono stati forniti i parametri necessari");
            }

            //Es : 	http://localhost/AF_WebFileManager/proxy/1.0/uploadpath_signed?filename=Busta_TEC_77.pdf.p7m&filepath=e:\PortaleGareTelematiche\Allegati\Busta_TEC_77.pdf.p7m&timeout=60&TABLE=ctl_doc_sign&IDDOC=429811&CIF=1&OPERATION=INSERTSIGN&IDENTITY=IdHeader&AREA=F1

            var afWebFileManager = "AF_WebFileManager";
            string urlToInvoke;
            if (!string.IsNullOrEmpty(ApplicationCommon.Application["NOMEAPPLICAZIONE_ALLEGATI"]))
            {
                afWebFileManager = CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE_ALLEGATI"]);
            }
            if (IsEmpty(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]) || string.IsNullOrEmpty(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]))
            {
                urlToInvoke = httpContext.GetServerVariable("LOCAL_ADDR") + "/" + afWebFileManager + "/proxy/1.0/uploadpath_signed?filename=";
            }
            else
            {
                urlToInvoke = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + "/" + afWebFileManager + "/proxy/1.0/uploadpath_signed?filename=";
            }

            urlToInvoke = urlToInvoke + fileOriginalName + "&filepath=" + URLEncode(filePath) + "&OPERATION=INSERTSIGN&timeout=" + URLEncode(ApplicationCommon.Application["timeoutApiCall"]);
            urlToInvoke = urlToInvoke + "&TABLE=" + URLEncode(table);
            urlToInvoke = urlToInvoke + "&IDDOC=" + URLEncode(iddoc);
            urlToInvoke = urlToInvoke + "&CIF=" + URLEncode(cif);
            urlToInvoke = urlToInvoke + "&IDENTITY=" + URLEncode(identity);
            urlToInvoke = urlToInvoke + "&AREA=" + URLEncode(area);
            urlToInvoke = urlToInvoke + "&acckey=" + URLEncode(accessGuid);
            urlToInvoke = urlToInvoke + "&CF=" + URLEncode(CF);

            var returnedString = invokeUrl(urlToInvoke);

            //JSON di ritorno {esit:true, content:<VALORE TECNICO>, message: <MESSAGGIO IN CASO DI ERRORE>}
            var returnedJson = JsonConvert.DeserializeObject<ReturnedJson>(returnedString);

            if (returnedJson == null) throw new NullReferenceException("UpLoadAttachSign. JSON di ritorno null");

            if (returnedJson.esit)
            {
                return "1#" + returnedJson.content;
            }

            var msg = returnedJson.message;

            if (string.IsNullOrEmpty(msg)) return "0#"; //In teoria in caso di eccezione ( 0# ) non dovremmo mai avere un msg vuoto

            msg = msg.Replace("Pdf Hash: ", "");

            if (!msg.Contains("~YES_ML")) return "0#" + msg;

            msg = msg.Replace("~YES_ML", "");
            msg = CNV(msg, session);

            return "0#" + msg;
        }

        /// <summary>
        /// '--inserisce un file allegato nella tabella CTL_ATTACH
        /// </summary>
        /// <param name="strObjFile"></param>
        /// <param name="strObjHash"></param>
        /// <param name="strObjSize"></param>
        /// <param name="strObjName"></param>
        /// <param name="strObjType"></param>
        /// <param name="cnLocal"></param>
        /// <param name="session"></param>
        /// <param name="cifra"></param>
        /// <param name="idDoc"></param>
        /// <returns></returns>
        private int InsertCTL_Attach(string strObjFile,
                        ref string strObjHash,
                        string strObjSize,
                        string strObjName,
                        string strObjType,
                        SqlConnection cnLocal, string cifra = "0", string idDoc = "", Session.ISession? session = null, SqlTransaction? transaction = null)
        {
            int ret = -1;

            TSRecordSet? rsObj = null;
            string strPathFileCifrato = string.Empty;
            string strSqlCopy = string.Empty;
            string strCause = string.Empty;
            EsitoTSRecordSet colID = null!;

            if (cifra[0] == '1')
            {
                string strTmpFileName = string.Empty;
                string strOut = string.Empty;
                //Dim tmpFS As New Scripting.FileSystemObject
                //'-- se presente, estraggo dal parametro cifra la vista da utilizzare per recuperare la chiave di cifratura
                dynamic arrTmp;
                string strTable = string.Empty;

                strCause = "Genero nome file temporaneo per cifrare";

                strTmpFileName = CommonStorage.GetTempName();

                arrTmp = cifra.Split("~");

                if (arrTmp.Length > 0)
                {
                    strTable = arrTmp[1];
                }
                else
                {
                    strTable = "ctl_doc";
                }

                strPathFileCifrato = $"{strObjFile}{strTmpFileName}";

                strCause = $"Invocazione cifraFile per richiedere la cifratura del file {strObjFile}";
                strOut = cifraFile(strObjFile, strPathFileCifrato, idDoc, true, cnLocal, strTable, session);

                if (!string.IsNullOrEmpty(strOut))
                {

                    if (CommonStorage.FileExists(strPathFileCifrato))
                    {
                        CommonStorage.DeleteFile(strPathFileCifrato);
                    }

                    throw new Exception("cifraFile " + strOut);
                }

            }

            CommonModule.DebugTrace dt = new CommonModule.DebugTrace();

            strCause = "Apertura recordset con CTL_ATTACH WHERE ATT_IdRow=-1";

            //'lo apre
            rsObj = new TSRecordSet();
            rsObj = rsObj.Open("SELECT * FROM CTL_ATTACH WHERE ATT_IdRow=-1", cnLocal.ConnectionString);

            //'aggiunge un nuovo record
            DataRow dr = rsObj.AddNew();
            
            if (cifra[0] == '1')
            {
                try
                {
                    strCause = "Cifra = 1, scrivo su ATT_OBJ " + strPathFileCifrato;
                    dt.Write("LibDbAttach - riga 267 - " + strPathFileCifrato);
                    using System.IO.Stream file = CommonStorage.Get(strPathFileCifrato);
                    byte[] buf = new byte[file.Length];
                    file.Read(buf, 0, buf.Length);
                    dr["ATT_OBJ"] = buf;
                    colID = rsObj.Update(dr, "ATT_IdRow", "CTL_ATTACH");
                    dt.Write("LibDbAttach - riga 273 - colID = " + colID.id);

                    strCause = "cancello il file cifrato dal filesystem";
                    file.Close();
                    CommonStorage.DeleteFile(strPathFileCifrato, true);
                }
                catch (Exception ex)
                {
                    dt.Write("LibDbAttach - riga 190 - colID = " + ex.ToString());
                    throw new Exception($"Metodo InsertCTL_Attach. {strCause} - Exception : {ex.Message}", ex);
                }
            }
            else
            {
                try
                {
                    strCause = "Cifra = 0, scrivo su ATT_OBJ " + strObjFile;
                    dt.Write("LibDbAttach - riga 204 - " + strCause);
                    using System.IO.Stream file = CommonStorage.Get(strObjFile);
                    byte[] buf = new byte[file.Length];
                    file.Read(buf, 0, buf.Length);
                    dr["ATT_OBJ"] = buf;
                    colID = rsObj.Update(dr, "ATT_IdRow", "CTL_ATTACH");
                    dt.Write("LibDbAttach - riga 212 - colID = " + colID.id);
                }
                catch (Exception ex)
                {
                    dt.Write("LibDbAttach - riga 217 - " + ex.ToString());
                    throw new Exception($"Metodo InsertCTL_Attach. {strCause} - Exception : {ex.Message}", ex);
                }
            }

            strCause = "invocazione funzione GetGUID()";
            strObjHash = CommonModule.Basic.GetNewGuid();

            strCause = "valorizzo nel recordset la colonna ATT_Hash";
            dr["ATT_Hash"] = strObjHash;
            
            strCause = "valorizzo nel recordset la colonna ATT_Size";
            dr["ATT_Size"] = strObjSize;
            
            strCause = "valorizzo nel recordset la colonna ATT_Name";
            dr["ATT_Name"] = strObjName;
            
            strCause = "valorizzo nel recordset la colonna ATT_Type";
            dr["ATT_Type"] = strObjType;
            
            if (cifra[0] == '1')
            {
                strCause = "valorizzo nel recordset la colonna ATT_CIFRATO";
                dr["ATT_CIFRATO"] = 1;
                
                strCause = "valorizzo nel recordset la colonna ATT_IDDOC";
                dr["ATT_IDDOC"] = mp_idDoc;
            }

            dt.Write("LibDbAttach - riga 252 - ATT_IDDOC=" + mp_idDoc);

            //'-- Controllo paracadute per evitare che un blocco sul file non abbia consentito la scrittura del blob
            if (IsNull(GetValueFromRS(dr["ATT_OBJ"])))
            {
                throw new Exception("999 - BizDB.InsertCTL_Attach.InsertCTL_Attach - Errore in scrittura allegato sul DB");
            }

            dt.Write("LibDbAttach.InsertCTL_Attach - riga 262");

            if (!string.IsNullOrEmpty(strBinaryHashFile) && rsObj.ColumnExists("ATT_FileHash"))
            {
                //'-- gestisco la possibilità che le colonne ATT_FileHash e ATT_AlgoritmoHash non esistano
                dr["ATT_FileHash"] = strBinaryHashFile;
                dr["ATT_AlgoritmoHash"] = algoritmoHashFile;
            }

            dr["ATT_IdRow"] = colID.id;
            dt.Write("LibDbAttach.InsertCTL_Attach - riga 279 prima di Update CTL_ATTACH:colID.id=" + colID.id.ToString());
            strCause = "invocazione rsObj.Update";

            rsObj.Update(dr, "ATT_IdRow", "CTL_ATTACH");

            dt.Write("LibDbAttach.InsertCTL_Attach - riga 282 dopo Update CTL_ATTACH:colID.id=" + colID.id.ToString());
            //'ritorna l'id del  inserito
            strCause = "Recupero dal recordset la colonna ATT_IdRow";
            ret = colID.id;

            //'--recupero il timestamp del momento nel quale l'allegato è entrato nel db ( per aggiungerlo alla techvalue )
            strCause = "Recupero dal recordset la colonna ATT_DataInsert";

            strAttDataInsert = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss").Replace(".", ":");

            if (cifra[0] == '1')
            {
                strCause = "Inserimento record nella tabella CTL_Encrypted_Attach";

                //'----------------------------------------------------------------------------------------
                //'--- EFFETTUO LA COPIA DI BACKUP DEL BLOB CIFRATO NELLA TABELLA CTL_ENCRYPTED_ATTACH ----
                //'----------------------------------------------------------------------------------------
                Dictionary<string, object?> sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@att_hash", strObjHash);
                strSqlCopy = "insert into CTL_Encrypted_Attach( att_idRow, att_obj ) select ATT_IdRow,ATT_Obj from CTL_Attach with(nolock) where att_hash = @att_hash";

                try
                {
                    cdf.Execute(strSqlCopy, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);
                }
                catch (Exception ex)
                {
                    throw new Exception($"Metodo InsertCTL_Attach. {strCause} - Exception : {ex.Message}", ex);
                }
            }

            return ret;
        }

        //'--visualizza l'allegato a partire dall'identificativo di riga della tabella CTL_ATTACH
        //Private Function DisplayAttach(session As Variant, response As Object) As Variant
        private void DisplayAttach(eProcurementNext.Session.ISession session, IEprocResponse objResp, HttpContext httpContext)
        {
            string Request_QueryString = GetQueryStringFromContext(httpContext.Request.QueryString);
            string strFormat = string.Empty;
            string strFileName = string.Empty;
            string strTechValue = string.Empty;
            string[] aInfo;
            TSRecordSet rsAttach = null!;
            string strConnectionString = string.Empty;
            bool decifrato;
            string fileDeCifrato = string.Empty;
            string escludiBusta = string.Empty;
            string percorsoFile = string.Empty;
            string strCause = string.Empty;
            TabManage tabManage = new TabManage(ApplicationCommon.Configuration);

            fileDeCifrato = string.Empty;
            decifrato = true;

            strConnectionString = ApplicationCommon.Application.ConnectionString;

            //On Error Resume Next

            //On Error GoTo 0

            //'--recupero valore tecnico attributo
            strTechValue = GetParamURL(Request_QueryString, "TECHVALUE");

            aInfo = strTechValue.Split("*");

            //'--recupero id attach
            //'lIdAttach = aInfo(0)

            //'--recupero nome file
            strFileName = aInfo[0];

            //'--recupero type file
            string strType = aInfo[1];

            //'--recupero guid
            string strGuid = aInfo[3];

            //'--recupero formattazione
            strFormat = GetParamURL(Request_QueryString, "FORMAT");

            escludiBusta = CStr(GetParamURL(Request_QueryString, "ESCLUDI_BUSTA")).ToUpper();

            tabManage.traceDB("Inizio metodo displayAttach()", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

            if (strFormat.Contains("EXT:", StringComparison.Ordinal))
            {
                string a = string.Empty;
                int ix = 0;
                int ix2 = 0;
                ix = Strings.InStr(1, strFormat, "EXT:");
                ix2 = Strings.InStr(ix + 1, strFormat, "-");
                a = Strings.Mid(strFormat, ix, ix2 - ix + 1);
                strFormat = Replace(strFormat, a, "");
            }


            strCause = "Eseguo la select di recupero dell'allegato";
            //'--recupero binario del file
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ATT_Hash", strGuid);
            rsAttach = cdf.GetRSReadFromQuery_("select [ATT_IdRow], [ATT_Hash], [ATT_Size], [ATT_Name], [ATT_Type], [ATT_DataInsert], [URL_CLIENT], [ATT_Cifrato], [ATT_IdDoc], [ATT_Pubblico], [ATT_FileHash], [ATT_Deleted], [ATT_AlgoritmoHash], [ATT_VerificaEstensione],  case when [ATT_Obj] is null then 1 else 0 end as ATT_TestObjNull from ctl_Attach with(nolock) where ATT_Hash =@ATT_Hash", ApplicationCommon.Application.ConnectionString, null, parCollection: sqlParams);
            if (rsAttach is not null && !(rsAttach.EOF && rsAttach.BOF) && CInt(rsAttach["ATT_TestObjNull"]!) == 0)
            {
                int cifrato = 0;
                int idDoc = -1000;
                int idPfu = 0;

                if (cdf.FieldExistsInRS(rsAttach, "ATT_CIFRATO"))
                {
                    cifrato = CInt(rsAttach["ATT_CIFRATO"]!);
                }

                tabManage.traceDB("Query di recupero sulla ctl_attach eseguita e record ritornato con successo", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                //'-- se la colonna ATT_CIFRATO è presente ed è uguale ad 1 ( l'allegato è cifrato) o a 2 ( è stata richiesta l'apertura delle buste )
                if (cifrato == 1 || cifrato == 2)
                {

                    idDoc = CInt(rsAttach["ATT_IDDOC"]!);

                    string strTmpFileName = string.Empty;
                    string strOutput = string.Empty;
                    SqlConnection cnLocal = new();
                    TSRecordSet rsUser;
                    string strSQL = string.Empty;

                    using (cnLocal = cdf.SetConnection(strConnectionString))
                    {

                        //'------------------------------------------------------------------------------------
                        //'--- Controllo se l'utente che sta richiedendo il file decifrato è autorizzato  -----
                        //'------------------------------------------------------------------------------------
                        idPfu = CInt(session[SessionProperty.SESSION_USER]);
                        strCause = "Eseguo la select di controllo sul possesso del file cifrato";
                        sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@IdDoc", idDoc);
                        sqlParams.Add("@IdPfu", idPfu);

                        strSQL = "select id from ctl_doc with (nolock) where id = @IdDoc and (idpfu = @IdPfu or idpfuincharge = @IdPfu)";

                        tabManage.traceDB($"Il file è cifrato. eseguo la select di controllo : {strSQL}", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                        rsUser = cdf.GetRSReadFromQuery_(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);

                        //'-- se l'utente è autorizzato alla decifratura o il file è stato già messo in pending per essere decifrato
                        if (rsUser.RecordCount > 0 || cifrato == 2)
                        {

                            strTmpFileName = CommonStorage.GetTempName();
                            percorsoFile = CStr(ApplicationCommon.Application["PathFolderAllegati"] + strTmpFileName);

                            strCause = "Salvo il file sul disco";
                            eProcurementNext.CommonDB.Basic.saveFileFromRecordSet("ATT_Obj", "ctl_Attach", "ATT_Hash", strGuid, percorsoFile);

                            if (CommonStorage.FileExists(percorsoFile))
                            {

                                fileDeCifrato = $"{percorsoFile}_D";

                                strCause = "Decifro il file";
                                //'-- decifro il file  -- Aggiunto il passaggio del vttore di sessione per recuperare l'utente
                                strOutput = cifraFile(percorsoFile, fileDeCifrato, idDoc.ToString(), false, cnLocal, session: session);

                                if (!string.IsNullOrEmpty(strOutput))
                                {
                                    throw new Exception($"{strCause} - {strOutput}");
                                }

                                //'-- Segnalo la presenza del file decifrato su disco, manderemo quindi quello all'utente e non il blob in base dati
                                decifrato = false;
                            }
                            else
                            {
                                throw new Exception($"{strCause} - Errore nell'estrazione dell'allegato cifrato");
                            }
                        }
                        else
                        {

                            objResp.Write(@"<script language=""JavaScript"">" + Environment.NewLine);
                            objResp.Write("self.location = '../../MessageBoxWin.asp?ML=yes&MSG=Download del file non consentito&CAPTION=Errore&ICO=1';" + Environment.NewLine);
                            objResp.Write("</script>" + Environment.NewLine);

                            return;

                        }

                    }

                }


                //'--costruisco l'header del file restituito
                switch (strType.ToLower())
                {

                    case "bmp":
                        httpContext.Response.ContentType = "image/x-xbitmap";
                        break;
                    case "jpg":
                        httpContext.Response.ContentType = "image/jpeg";
                        break;

                    case "pdf":
                        httpContext.Response.ContentType = "application/pdf";
                        break;

                    case "doc":
                        httpContext.Response.ContentType = "application/msword";
                        break;

                    case "zip":
                        httpContext.Response.ContentType = "application/zip";
                        break;

                    default:
                        httpContext.Response.ContentType = "application/x-AFLink";
                        break;
                }

                //'-- Con firefox se il nome del file contiene uno spazio il file in output avrà un filename sbagliato, senza estensione e si fermerà fino al primo spazio.
                //'-- la correzione più corretta sarebbe fare un encode del nome file ma non garantisce una retrocompatibiltà maggiore ( i vecchi browser non supportano questa encode)
                //'-- testo lo useragent e se è firefox sostituisco gli spazi con _

                //'If MyInStr(CStr(userAgent), "firefox") > 0 Then
                //'    strFileName = MyReplace(strFileName, " ", "_")
                //'End If


                if (strFormat.Contains("O", StringComparison.Ordinal))
                {

                    //'--faccio aprire il file direttamente

                    if (escludiBusta == "YES" && strFileName.ToUpper().EndsWith("P7M", StringComparison.Ordinal))
                    {
                        httpContext.Response.Headers.TryAdd("Content-Disposition", @"inline; filename=""" + ReplaceInsensitive(strFileName, ".p7m", "") + @"""");
                    }
                    else
                    {
                        httpContext.Response.Headers.TryAdd("Content-Disposition", @"inline; filename=""" + strFileName + @"""");
                    }


                }
                else
                {
                    //'--faccio aprire la mascheria per il download

                    if (escludiBusta == "YES" && strFileName.ToUpper().EndsWith("P7M", StringComparison.Ordinal))
                    {


                        httpContext.Response.Headers.TryAdd("Content-Disposition", @"attachment; filename=""" + ReplaceInsensitive(strFileName, ".p7m", "") + @"""");
                    }
                    else
                    {
                        httpContext.Response.Headers.TryAdd("Content-Disposition", @"attachment; filename=""" + strFileName + @"""");
                    }

                }

                //'--restituisco il file
                //'Response.BinaryWrite rsAttach.Fields.Item("ATT_Obj").GetChunk(rsAttach.Fields("ATT_Obj").ActualSize)

                //long s = 0;
                //long block = 0;
                //long it = 0;

                //it = 0;
                //s = 0;
                //block = 10000;

                //'-- se il file in base dati è già decifrato mandiamo quello
                if (decifrato)
                {

                    if (escludiBusta == "YES" && strFileName.ToUpper().EndsWith("P7M", StringComparison.Ordinal))
                    {

                        tabManage.traceDB("Inizio operazioni per escludi busta", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                        string strTmpFileName = CommonStorage.GetTempName();

                        //Set ApplicationASP = session(OBJAPPLICATION)

                        percorsoFile = CStr(ApplicationCommon.Application["PathFolderAllegati"]) + strTmpFileName;

                        strCause = "Salvo il file sul disco prima di sbustarlo";
                        eProcurementNext.CommonDB.Basic.saveFileFromRecordSet("ATT_Obj", "ctl_Attach", "ATT_Hash", strGuid, percorsoFile);

                        tabManage.traceDB($"File originale salvato con successo : '{percorsoFile}' . Invoco il metodo togliBustaP7M", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                        strCause = "Sbusto il file p7m";
                        togliBustaP7M(percorsoFile, session, strConnectionString);

                        tabManage.traceDB("metodo togliBustaP7M concluso. err.description : '" + CStr("err.Description") + "' . invoco il metodo writeToOutput", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                        strCause = "porto il output il file p7m sbustato";
                        writeToOutput(objResp, percorsoFile, httpContext);

                        tabManage.traceDB($"Metodo writeToOutput concluso. passo a cancellare il file '{percorsoFile}' dal disco", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                        strCause = "cancello il file decifrato dal filesystem";
                        File.Delete(percorsoFile);

                    }
                    else
                    {

                        //'--restituisco il file
                        eProcurementNext.CommonDB.Basic.saveFileFromRecordSet("ATT_Obj", "ctl_attach", "ATT_Hash", Replace(strGuid, "'", "''"), httpContext.Response.Body);

                        //int it = 0;
                        //while (s + block < rsAttach.Fields["ATT_Obj"] && it < 1000000) {
                        //    //'Response.BinaryWrite rsAttach.Fields.Item("ATT_Obj").GetChunk(rsAttach.Fields("ATT_Obj").ActualSize)
                        //    objResp.BinaryWrite(httpContext, rsAttach.Fields.["ATT_Obj"]);

                        //    s = s + block;
                        //    it = it + 1;
                        //    //response.Flush
                        //}
                        //If rsAttach.Fields("ATT_Obj").ActualSize - s > 0 Then
                        //    objResp.BinaryWrite rsAttach.Fields.item("ATT_Obj").GetChunk(rsAttach.Fields("ATT_Obj").ActualSize - s)
                        //}

                    }

                }
                else
                {

                    if (escludiBusta == "YES" && strFileName.ToUpper().EndsWith("P7M", StringComparison.Ordinal))
                    {

                        strCause = "Sbusto il file p7m";

                        tabManage.traceDB("Invoco il metodo togliBustaP7M", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                        togliBustaP7M(fileDeCifrato, session, strConnectionString);

                    }

                    tabManage.traceDB("Invoco il metodo writeToOtput", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                    strCause = "porto il output il file decifrato";
                    writeToOutput(objResp, fileDeCifrato, httpContext);

                    strCause = "cancello il file decifrato dal filesystem";
                    File.Delete(fileDeCifrato);

                    tabManage.traceDB($"File '{fileDeCifrato}' cancellato", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);
                }
            }

        }


        /// <summary>
        /// '-- metodo richiamabile dall'esterno
        /// '--inserisce un file allegato nella tabella CTL_ATTACH
        /// </summary>
        /// <param name="strPathFile"></param>
        /// <param name="strObjSize"></param>
        /// <param name="strObjName"></param>
        /// <param name="strObjType"></param>
        /// <param name="strConnectionString"></param>
        /// <param name="strInfoTechAttach"></param>
        /// <param name="strHashName"></param>
        /// <param name="cifra"></param>
        /// <param name="idDoc"></param>
        /// <returns></returns>
        public void InsertCTL_Attachment(
                                string strPathFile,
                                string strObjSize,
                                string strObjName,
                                string strObjType,
                                string strConnectionString,
                                ref string strInfoTechAttach,
                                ref string strHashName, string cifra = "0", string idDoc = "")
        {

            using SqlConnection cnLocal = SetConnection(strConnectionString, cdf);
            //'-- passo la sessione a nothing non avendola nella firma del metodo e dal chiamante ( questo metodo sembra essere usato solo per caricare i .EML )
            try
            {
                traceHashFile(null, strPathFile, cnLocal);
            }
            catch { }

            InsertCTL_Attach(strPathFile, ref strHashName, strObjSize, strObjName, strObjType, cnLocal, cifra, idDoc, null, null);

            DebugTrace dt = new DebugTrace();
            dt.Write("LibDbAttach - riga 807 -  strBinaryHashFile= " + strBinaryHashFile.ToString());
            //'--costruisco il valore tecnico
            strInfoTechAttach = $"{strObjName}*{strObjType}*{strObjSize}*{strHashName}";

            //'-- Se la chiamata a 'traceHashFile' ha valorizzato correttamente l'hash binario del file estendiamo la forma tech
            if (!string.IsNullOrEmpty(strBinaryHashFile))
            {
                strInfoTechAttach = $"{strInfoTechAttach}*{algoritmoHashFile}*{strBinaryHashFile}*{strAttDataInsert}";
            }

        }

        public void Base64attach(string strTechValue, eProcurementNext.CommonModule.IEprocResponse objResp)
        {
            TSRecordSet rsAttach;

            string[] aInfo = strTechValue.Split("*");

            //'--recupero guid
            string strGuid = aInfo[3];

            //'--recupero binario del file
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ATT_Hash", strGuid);

            rsAttach = cdf.GetRSReadFromQuery_("select * from ctl_Attach with(nolock) where ATT_Hash = @ATT_Hash", ApplicationCommon.Application.ConnectionString, null, parCollection: sqlParams);

            if (rsAttach is not null && !(rsAttach.EOF && rsAttach.BOF) && !IsNull(GetValueFromRS(rsAttach.Fields["ATT_Obj"])))
            {
                //'--restituisco il file
                objResp.Write(Convert.ToBase64String(Encoding.ASCII.GetBytes(GetValueFromRS(rsAttach.Fields["ATT_Obj"]))));
            }
        }

        public string InsertCTL_Attach_FromFile(string strPathFile,
                        string strConnectionString, string nomeFile = "", string cifra = "0", string idDoc = "")
        {
            string ret = string.Empty;

            double dSize = 0;
            string strName = string.Empty;
            string strType = string.Empty;
            string strCause = string.Empty;

            SqlConnection cnLocal = eProcurementNext.CtlProcess.Basic.SetConnection(strConnectionString, cdf);

            try
            {
                strCause = "Open connessione sql";
                cnLocal.Open();
                int lIdAttach = 0;
                string strHashName = string.Empty;

                //'--ricavo la size del file
                FileInfo objFile = new FileInfo(strPathFile);
                dSize = objFile.Length;

                //'-- Se non viene passato un nome di file specifico (per non fargli prendere quello del fileSystem)
                if (string.IsNullOrEmpty(nomeFile))
                {
                    //'--ricavo il nome del file
                    strName = Path.GetFileName(strPathFile);
                }
                else
                {
                    strName = nomeFile;
                }

                strCause = "ricavo estensione del file";
                strType = Path.GetExtension(strPathFile);
                DebugTrace dt = new DebugTrace();
                dt.Write("LibDbAttach - riga 885 - strType = " + strType);
                string strLocalHashBinary = String.Empty;

                strCause = "Chiamata al metodo getHashFile";
                strLocalHashBinary = eProcurementNext.CommonModule.FileHash.GetHashFile(ApplicationCommon.FileHashAlgorithm, strPathFile);

                //'--salvo il file in base dati
                strCause = "salvo il file in base dati";
                lIdAttach = InsertCTL_Attach(strPathFile, ref strHashName, dSize.ToString(), strName, strType, cnLocal, cifra, idDoc, null);

                strCause = "costruisco e restituisco il valore tecnico";
                ret = $"{strName}*{strType}*{dSize}*{strHashName}";

                //'-- Se la chiamata a 'traceHashFile' ha valorizzato correttamente l'hash binario del file estendiamo la forma tech
                if (!string.IsNullOrEmpty(strLocalHashBinary))
                {
                    ret = $"{ret}*{algoritmoHashFile}*{strLocalHashBinary}*{strAttDataInsert}";
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Eccezione nel metodo InsertCTL_Attach_FromFile. {strCause}", ex);
            }
            finally
            {
                cnLocal.Close();
            }

            return ret;

        }

        private void traceHashFile(Session.ISession? session, string strPathFile, SqlConnection cnLocal)
        {
            string hash = "";
            int idPfu = 0;

            //'-- se abbiamo la sessione
            if (session != null)
            {
                hash = getHashFile(strPathFile);
                idPfu = session[SessionProperty.SESSION_USER];

                string strSQL = "insert into ctl_log_utente (idpfu, datalog, paginadiarrivo, querystring,browserUsato) values ( @idpfu, getdate(), 'UploadAttach.asp', @hash,'HASH')";

                var parCollection = new Dictionary<string, object?>();
                parCollection.Add("@idpfu", idPfu);
                parCollection.Add("@hash", hash);

                cdf.Execute(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: parCollection);
            }
        }


        private string cifraFile(string pathFileInput, string pathFileOutput, string idDoc, bool cifra, SqlConnection cnLocal, string table = "ctl_doc", Session.ISession? session = null)
        {
            string cifraFileRet = string.Empty;

            string cryptoKey = string.Empty;
            string strCause = string.Empty;

            var obj = new eProcurementNext.CommonModule.Cifratura();

            //'-- salvo l'idDoc passato come parametro nella variabile locale
            this.mp_idDoc = idDoc;

            strCause = "Invocazione getChiaveDiCifratura";
            cryptoKey = getChiaveDiCifratura(idDoc, cnLocal, table, session);

            if (cifra)
            {

                strCause = "Invocazione cifraturaFile per " + pathFileInput;
                cifraFileRet = obj.CifraturaFile(pathFileInput, pathFileOutput, cryptoKey, true, "");

                //'-- Se la cifratura non mi ha ritornato errori passo ad effettuare una verifica incrociata
                //'-- andandomi a decifrare il file appena cifrato per verificare se combacia con l'originale
                if (string.IsNullOrEmpty(cifraFileRet))
                {

                    string out2 = string.Empty;
                    string tmpFlName = string.Empty;
                    tmpFlName = pathFileOutput + "_2";

                    strCause = "Invocazione decifratura per " + pathFileOutput;
                    bool errDecifra2 = false;
                    try
                    {
                        out2 = obj.CifraturaFile(pathFileOutput, tmpFlName, cryptoKey, false, "");
                    }
                    catch (Exception)
                    {
                        errDecifra2 = true;
                    }

                    try
                    {
                        //'-- Se non ho errore
                        if (string.IsNullOrEmpty(out2) && !errDecifra2)
                        {
                            if (session != null)
                            {
                                string hashFileOriginale = string.Empty;
                                string hashControVerifica = string.Empty;

                                strCause = $"Invocazione getHashFile per {pathFileInput}";

                                bool errGetHash = false;
                                string msgGetHash = string.Empty;

                                try
                                {
                                    hashFileOriginale = getHashFile(pathFileInput);
                                }
                                catch (Exception e)
                                {
                                    if (!bSaltaControlli)
                                    {
                                        errGetHash = true;
                                        msgGetHash = e.ToString();
                                    }
                                }

                                //'-- se c'è stato un errore nella produzione dell'hash binario del file originale
                                if (string.IsNullOrEmpty(hashFileOriginale) || errGetHash)
                                {
                                    if (!bSaltaControlli)
                                    {
                                        cifraFileRet = $"cifraFile() - Errore nella generazione dell'hash del file originale. {msgGetHash}";
                                    }
                                }
                                else
                                {

                                    strCause = $"Invocazione getHashFile per {tmpFlName}";

                                    bool errGetHash2 = false;
                                    string msgGetHash2 = string.Empty;

                                    try
                                    {
                                        hashControVerifica = getHashFile(tmpFlName);
                                    }
                                    catch (Exception e)
                                    {
                                        if (!bSaltaControlli)
                                        {
                                            errGetHash2 = true;
                                            msgGetHash2 = e.ToString();
                                        }

                                    }


                                    //'-- se c'è stato un errore nella produzione dell'hash binario del file decifrato
                                    if (string.IsNullOrEmpty(hashControVerifica) || errGetHash2)
                                    {
                                        if (!bSaltaControlli)
                                        {
                                            cifraFileRet = $"cifraFile() - Errore nella generazione dell'hash del file decifrato. {msgGetHash2}";
                                        }
                                    }
                                    else
                                    {
                                        if (hashFileOriginale != hashControVerifica)
                                        {
                                            cifraFileRet = $"cifraFile() - Errore nella verifica incrociata sul file. Hash differenti. {hashFileOriginale} - {hashControVerifica}";
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            cifraFileRet = $"cifraFile() - Errore nella verifica incrociata sul file. Decrypt fallita.{out2}";
                        }
                    }
                    finally
                    {
                        string fileToDel = $"{pathFileOutput}_2";

                        if (CommonStorage.FileExists(fileToDel))
                        {
                            //'-- Cancello il file temporaneo utilizzato come verifica.
                            strCause = $"Kill il file {fileToDel}";
                            CommonStorage.DeleteFile(fileToDel, true);
                        }

                    }

                }
            }
            else
            {
                cifraFileRet = obj.CifraturaFile(pathFileInput, pathFileOutput, cryptoKey, false, "");
            }

            return cifraFileRet;
        }

		private string getChiaveDiCifratura(string idDoc, SqlConnection cnLocal, string table = "ctl_doc", Session.ISession? session = null)
		{
			string ret = string.Empty;

			string strSQL = string.Empty;
			TSRecordSet rs;

			//'-- verifico la presenza dell'utente che ha richiesto la chiave per poterlo tracciare
			int? idPfu = -1;
			if (session is not null)
			{
				idPfu = session[SessionProperty.IdPfu];
				if (idPfu is null)
				{
					idPfu = -1;
				}
			}

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@IdPfu", idPfu);
			sqlParams.Add("@IdDoc", idDoc);
			sqlParams.Add("@Table", table);

			strSQL = "Exec AFS_CRYPT_KEY_ATTACH @IdPfu, @IdDoc, @Table";
			rs = cdf.GetRSReadFromQuery_(strSQL, cnLocal.ConnectionString, null, parCollection: sqlParams);

			if (rs.RecordCount > 0)
			{
				if (table.ToLower() != "ctl_doc")
				{
					//'-- sovrascrivo l'idDoc recuperato dalla vista invece di utilizzare quello passato come parametro alla pagina di upload
					mp_idDoc = CStr(rs["idDoc"]);
				}

				rs.MoveFirst();
				ret = CStr(rs["chiave"]);

				if (string.IsNullOrEmpty(ret))
				{
					throw new NullReferenceException("chiave di cifratura vuota");
				}
			}
			else
			{
				throw new Exception("errore recupero chiave di cifratura");
			}

			return ret;
		}

		private void togliBustaP7M(string pathFile, Session.ISession session, string strConnectionString)
        {

            string strCause = String.Empty;

            try
            {

                Chilkat.Crypt2 crypt;
                
                int totIterazioni = 0;
                TabManage tabManage = new TabManage(ApplicationCommon.Configuration);

                strCause = "Istanzio chilkat";

                //'-- proviamo prima ad istanziare la nuova libreria, in sua assenza usiamo la vecchia
                crypt = new Chilkat.Crypt2();
                crypt.UnlockComponent(Email.Basic.GetUnlockKey(ApplicationCommon.Configuration)); //"AFSOLUCrypt_kBFfOFAyUJJG" 'licenza

                strCause = "tolgo la busta P7M";

                //'Estraggo il file originale dal p7m e verifico se è corrotto
                if (crypt.VerifyP7M(pathFile, pathFile))
                {

                    totIterazioni = 0;

                    bool bSbusta = false;

                    tabManage.traceDB("Metodo 'togliBustaP7M' invocazione del metodo Chilkat.Crypt-VerifyP7M eseguito con successo. Passo a verificare la presenza di buste multiple", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                    bSbusta = true;

                    //'-- Itero fino a togliere tutte le buste con tot tentativi max = 5 e assenza di errore
                    while (totIterazioni < 5 && bSbusta)
                    {

                        strCause = "itero sulle buste. iterazione numero : " + totIterazioni.ToString();

                        if (crypt.VerifyP7M(pathFile, pathFile))
                        {
                            bSbusta = true;
                        }
                        else
                        {
                            bSbusta = false;
                        }

                        totIterazioni = totIterazioni + 1;

                    }

                    tabManage.traceDB("Ciclo di sbustamenti conclusi con " + CStr(totIterazioni + 1) + " iterazioni. err.description : '" + /*err.Description &*/ "'", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString);

                }
                else
                {
                    throw new Exception("Busta P7M non valida");
                }

            }
            catch (Exception ex)
            {
                throw new Exception($"Eccezione metodo togliBustaP7M() - {strCause} - {ex.Message}", ex);
            }

        }

        private string getHashFile(string strPathFile)
        {
            string ret = "";

            string strTmpOut = string.Empty;

            this.strBinaryHashFile = string.Empty; //'-- variabile della classe Lib_dbAttach

            Exception? ex = null;

            try
            {
                ret = CommonModule.FileHash.GetHashFile(algoritmoHashFile, strPathFile);
            }
            catch (Exception e)
            {
                ex = e;
            }

            if (string.IsNullOrEmpty(ret))
            {
                strTmpOut = ret;
                ret = "";
                strBinaryHashFile = "";

                //Se non è stato forzato il bypass degli errori
                if (!bSaltaControlli)
                {
                    if (ex is not null)
                    {
                        throw new Exception("getHashFile(): Errore nella generazione dell'hash del file." + ex.Message, ex);
                    }
                    else
                    {
                        throw new Exception("getHashFile(): Errore nella generazione dell'hash del file.");
                    }
                }
            }
            else
            {
                strBinaryHashFile = ret;
            }

            return ret;
        }



        // verificare se utilizzare anche per download.aspx?
        public void writeToOutput(IEprocResponse response, string DiskFile, HttpContext httpContext)
        {
            //Con il costrutto using usato in questo modo viene fatta una dispose automatica non appena l'oggetto esce fuori scope, sia in caso di OK che di errore
            using FileStream fs = new FileStream(DiskFile, FileMode.Open, FileAccess.Read);
            byte[] b = new byte[1024];
            int len;
            int counter = 0;
            while (true)
            {
                len = fs.Read(b, 0, b.Length);
                byte[] c = new byte[len];
                b.Take(len).ToArray().CopyTo(c, 0);
                response.BinaryWrite(httpContext, c);
                if (len == 0 || len < 1024)
                {
                    break;
                }
                counter++;
            }
        }

        public void attivaByPassControlli()
        {
            bSaltaControlli = true;
        }

        public void disattivaByPassControlli()
        {
            bSaltaControlli = false;
        }

    }

    public class ReturnedJson
    {
        public bool esit { get; set; }
        public string? content { get; set; }
        public string? message { get; set; }
    }

}
