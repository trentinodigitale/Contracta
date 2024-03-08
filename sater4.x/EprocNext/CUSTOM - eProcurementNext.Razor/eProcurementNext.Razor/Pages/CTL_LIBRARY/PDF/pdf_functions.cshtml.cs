using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Razor.Pages.CTL_LIBRARY.functions;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.PDF
{
    public class pdf_functionsModel : PageModel
    {

        public static dynamic generaPDF(dynamic fromWeb, dynamic parametri, ref string strPathfileOutput, ref string pdfNameOut, HttpContext httpContext, eProcurementNext.Session.ISession session, ref string mp_ICONMSG_Process, ref string mp_StrMsg_Process, ref ELAB_RET_CODE mp_vRetCode_Process, ref int mp_show_error)
        {
            dynamic ret = "";

            HttpRequest Request = httpContext.Request;

            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            var cdf = new CommonDbFunctions();

            TSRecordSet rs = new TSRecordSet();

            TabManage objDB = null;

            //set fs = CreateObject("Scripting.FileSystemObject")
            string strOut = application["PathFolderAllegati"];

            string lng_suffisso = "";

            string moduloPDF = "";


            string strPathFile = "";


            string url = "";
            string pdfName = "";

            string toSign = "";
            string idDoc = "";
            string typeDoc = "";
            string IDDOCGEN = "";
            string legacy = "";
            string backOffice = "";
            string processo = "";
            string lngSuffix = "";

            string pdfA = "";
            string signNoPDFA = "";

            string pageSize = "";
            string pageOrientation = "";
            string fitWith = "";

            string table = "";
            string identity = "";
            string area = "";

            string saveAttach = "";
            string TABNAME = "";

            string strActiveTabName = "";

            string sign_lock = "";

            string forceSign = "";


            //'-- GESTIONE FOOTER PDF CON CHIAVE DI MULTILINGUISMO
            string ml_footer = "";
            string media_type = "";

            //'-- GESTIONE FOOTER e HEADER PDF CON GESTIONE A VISTA/VIEW
            string view_footer_header = "";


            int idPfu = -20;    // aggiunta

            bool bErrore = false;
            string strDescErrore = "";
            string strErrore = "";

            string documento = "";
            string comando = "";


            string strFileName = "";

            string moduloView = "";
            string res = ""; // aggiunta
            string strHASHPDF = "";

            string strColName = "";

            string tmp = "";

            string strCmd = "";

            string strSQL = string.Empty;

            //'-- recupero parametri in base al chiamante. se � web prendo tutto da querystring, altrimenti prendo i parametri dalla stringa 'parametri' composta come una querystring
            if (fromWeb)
            {

                url = GetParamURL(Request.QueryString, "URL");
                pdfName = GetParamURL(Request.QueryString, "PDF_NAME");

                toSign = GetParamURL(Request.QueryString, "TO_SIGN");
                idDoc = GetParamURL(Request.QueryString, "IDDOC");
                typeDoc = GetParamURL(Request.QueryString, "TYPEDOC");
                IDDOCGEN = GetParamURL(Request.QueryString, "IDDOCGEN");
                legacy = GetParamURL(Request.QueryString, "LEGACY");
                backOffice = GetParamURL(Request.QueryString, "backoffice");
                processo = GetParamURL(Request.QueryString, "PROCESS");
                lngSuffix = GetParamURL(Request.QueryString, "LanguageSuffix");

                pdfA = GetParamURL(Request.QueryString, "PDF_A");
                signNoPDFA = GetParamURL(Request.QueryString, "TO_SIGN_WITHOUT_PDFA");

                pageSize = GetParamURL(Request.QueryString, "PAGESIZE");
                pageOrientation = GetParamURL(Request.QueryString, "PAGEORIENTATION");
                fitWith = GetParamURL(Request.QueryString, "FITWITH");

                table = GetParamURL(Request.QueryString, "TABLE_SIGN");
                identity = GetParamURL(Request.QueryString, "IDENTITY_SIGN");
                area = GetParamURL(Request.QueryString, "AREA_SIGN");

                saveAttach = GetParamURL(Request.QueryString, "SAVE_ATTACH");
                TABNAME = GetParamURL(Request.QueryString, "TABNAME");

                strActiveTabName = CStr(GetParamURL(Request.QueryString, "strActiveTabName"));

                forceSign = CStr(GetParamURL(Request.QueryString, "FORCE_SIGN"));

                moduloPDF = CStr(GetParamURL(Request.QueryString, "MODULO"));
                moduloView = CStr(GetParamURL(Request.QueryString, "MODULO_VIEW"));

                //'-- GESTIONE FOOTER PDF CON CHIAVE DI MULTILINGUISMO
                ml_footer = CStr(GetParamURL(Request.QueryString, "ML_FOOTER"));
                media_type = CStr(GetParamURL(Request.QueryString, "MEDIA"));

                //'-- GESTIONE FOOTER e HEADER PDF CON GESTIONE A VISTA/VIEW
                view_footer_header = CStr(GetParamURL(Request.QueryString, "VIEW_FOOTER_HEADER"));
                //'LA VISTA PASSATA DOVRA AVERE LE SEGUENTI COLONNE
                //'	idRow,idDoc,htmlValue,tipo ( valori ammessi : 'header1','headerN', 'footer' )

                if (!string.IsNullOrEmpty(moduloPDF) &&
                        (string.IsNullOrEmpty(moduloView) || string.IsNullOrEmpty(idDoc))
                    )
                {
                    return "Configurazione errata per la richiesta di un modulo PDF";
                }

                if (!string.IsNullOrEmpty(moduloPDF))
                {

                    moduloPDF = application["PATH_MODULI_PDF"] + moduloPDF;

                    if (CommonStorage.FileExists(moduloPDF) == false)
                    {
                        return "Configurazione errata per la richiesta di un modulo PDF";
                    }
                }

                strPathFile = "";
            }
            else
            {
                url = GetParamURL(parametri, "URL");
                pdfName = GetParamURL(parametri, "PDF_NAME");
                toSign = GetParamURL(parametri, "TO_SIGN");
                idDoc = GetParamURL(parametri, "IDDOC");
                typeDoc = GetParamURL(parametri, "TYPEDOC");
                IDDOCGEN = GetParamURL(parametri, "IDDOCGEN");
                legacy = GetParamURL(parametri, "LEGACY");
                backOffice = GetParamURL(parametri, "backoffice");
                processo = GetParamURL(parametri, "PROCESS");
                lngSuffix = GetParamURL(parametri, "LanguageSuffix");

                pdfA = GetParamURL(parametri, "PDF_A");
                signNoPDFA = GetParamURL(parametri, "TO_SIGN_WITHOUT_PDFA");


                pageSize = GetParamURL(parametri, "PAGESIZE");
                pageOrientation = GetParamURL(parametri, "PAGEORIENTATION");
                fitWith = GetParamURL(parametri, "FITWITH");


                table = GetParamURL(parametri, "TABLE_SIGN");
                identity = GetParamURL(parametri, "IDENTITY_SIGN");
                area = GetParamURL(parametri, "AREA_SIGN");


                saveAttach = GetParamURL(parametri, "SAVE_ATTACH");
                TABNAME = GetParamURL(parametri, "TABNAME");


                strActiveTabName = GetParamURL(parametri, "strActiveTabName");

                forceSign = GetParamURL(parametri, "FORCE_SIGN");


                //'-- dove mettere il file pdf

                strPathFile = CStr(GetParamURL(parametri, "PATH_FILE"));


                //'-- gestione footer pdf

                ml_footer = CStr(GetParamURL(parametri, "ML_FOOTER"));


                //'-- media type screen o print

                media_type = CStr(GetParamURL(parametri, "MEDIA"));


            }


            if (fromWeb == false)
            {
                securityModel.disattivaRedirect(httpContext);
            }

            //'-- Gestione della lingua per la stampa
            if (session["IdPfu"] != null && session["IdPfu"] > 0)
            {

                //'-- Se esiste una sessione utente e non si sta passando in querystrng il parametro per la lingua
                if (string.IsNullOrEmpty(lngSuffix))
                {
                    lng_suffisso = CStr(session[SessionProperty.strSuffLing]); //'-- lingua
                }
            }

            //'---------------------------
            //'-- VALIDAZIONE PARAMETRI --
            //'---------------------------
            securityModel.validate("IDDOC", idDoc, securityModel.TIPO_PARAMETRO_NUMERO, 0, "", 0, httpContext, session);
            securityModel.validate("TO_SIGN", toSign, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
            securityModel.validate("SAVE_ATTACH", saveAttach, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
            securityModel.validate("PDF_A", pdfA, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
            securityModel.validate("LanguageSuffix", lngSuffix, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
            securityModel.validate("VIEW_FOOTER_HEADER", view_footer_header, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);

            if (fromWeb == false)
            {
                if (securityModel.isSecurityBlocked(httpContext) == 1)
                {

                    return "Blocco per tentativo di modifica parametri non consentito";
                }
            }

            //'-- Se il parametro PROCESS � avvalorato eseguo il processo richiesto
            if (!string.IsNullOrEmpty(processo) && !string.IsNullOrEmpty(idDoc))
            {

                //on error resume next;

                idPfu = -20;
                if (!string.IsNullOrEmpty(CStr(session["idPfu"])))
                {
                    idPfu = CInt(session["idPfu"]);
                }

                bErrore = false;

                if (processo.Contains("@@@", StringComparison.Ordinal))
                {
                    try
                    {
                        documento = processo.Split("@@@")[0];
                        comando = processo.Split("@@@")[1];

                        strDescErrore = "";

                        var objProc = new eProcurementNext.CtlProcess.ClsElab();
                        mp_vRetCode_Process = objProc.Elaborate(comando, documento, CLng(idDoc), CLng(idPfu), ref strDescErrore, 1, ApplicationCommon.Application.ConnectionString);
                        //'response.write strDescErrore 
                        //'response.end
                        if (!string.IsNullOrEmpty(strDescErrore))
                        {
                            //'strErrore = strDescErrore 				
                            //'--ripulisco messaggio di errore del processo
                            strErrore = InitMessageProcess(CInt(mp_vRetCode_Process), strDescErrore, mp_ICONMSG_Process, mp_StrMsg_Process);

                            //'response.write Err.number 
                            //'response.end

                            bErrore = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        strErrore = ex.Message;
                        bErrore = true;
                    }

                    if (bErrore)
                    {

                        //'call ShowError( strErrore )
                        return strErrore;

                        //'response.end

                    }

                    //Set objProc = nothing
                }
                else
                {

                    //'call ShowError( "PARAMETRO 'PROCESS' errato. es. d'uso : DOCUMENT@@@SEND" )
                    //'Response.end

                    return "PARAMETRO 'PROCESS' errato. es. d'uso : DOCUMENT@@@SEND";

                }

                //on error goto 0

            }

            //'-- Se l'url richiesto non contiene gia il ? ( cio� se ha o meno gia dei parametri passati in querystring )
            if (!url.Contains("?", StringComparison.Ordinal))
            {
                url = url + "?";
            }

            //'--accodo un parametro per non disegnare la toolbar di default sui documenti nelle stampe
            //'--disegnata dalla layout.inc
            url = url + "SHOW_TOOLBAR_PRINT=NO&";

            //'response.write "url=" & url
            //'response.end

            if (string.IsNullOrEmpty(toSign))
            {
                toSign = "no";
            }

            if (string.IsNullOrEmpty(legacy))
            {
                legacy = "NO";
            }

            int counter = CInt(session["COUNTPDFFILE"]);
            counter = counter + 1;
            session["COUNTPDFFILE"] = counter;

            string applicazione = "";

            if (application["NOMEAPPLICAZIONE"] == null || string.IsNullOrWhiteSpace(application["NOMEAPPLICAZIONE"]))
            {
                applicazione = application["ApplicationName"];
            }
            else
            {
                applicazione = application["NOMEAPPLICAZIONE"];
            }

            //'-- evito il path traversal passato sul nome del file pdf
            pdfName = pdfName.Replace("..", "");
            pdfName = pdfName.Replace("/", "");
            pdfName = pdfName.Replace("\\", "");

            /* rimosso if documento generico
            if (string.IsNullOrEmpty(idDoc))  
            { //'se � un documento generico

                strFileName = pdfName.Replace(" ", "_") + "_" + session["idPfu"];

            }
            else
            {
            */
            if (string.IsNullOrEmpty(pdfName))
            {

                if (!string.IsNullOrEmpty(idDoc))
                { //'se non provengo da un documento generico
                    strFileName = "sign_" + session["idPfu"]; //'& "_" & idDoc & "_" & counter
                }
                /* commentato/rimosso parte documento generico
                else
                {
                    strFileName = "pdf_" + session["idPfu"]; //'& "_" & idDoc & "_" & counter
                }*/

            }
            else
            {
                strFileName = pdfName.Replace(" ", "_") + "_" + session["idPfu"];
            }

            //}


            //'-- compongo l'url della pagina 
            string strSite = "";
            if (IsEmpty(application["WEBSERVERAPPLICAZIONE_INTERNO"]) || string.IsNullOrEmpty(application["WEBSERVERAPPLICAZIONE_INTERNO"]))
            {
                strSite = "http://";
                if (httpContext.GetServerVariable("SERVER_PORT_SECURE") == "1")
                {
                    strSite = "https://";
                }

                strSite = strSite + httpContext.GetServerVariable("LOCAL_ADDR"); //'Request.ServerVariables("SERVER_NAME")
            }
            else
            {
                strSite = application["WEBSERVERAPPLICAZIONE_INTERNO"];
            }

            string strBackOff = "";
            //'-- Se viene gia passato backoffice non lo re-inserisco nel url che passo alla pdf.aspx
            if (CStr(backOffice).ToUpper() == "YES")
            {
                strBackOff = "1=1";
            }
            else
            {
                strBackOff = "backoffice=yes";
            }


            string strLingua = "";

            //'-- Gestione della lingua per la stampa
            if (session["IdPfu"] != null && session["IdPfu"] > 0)
            {

                //'-- Se esiste una sessione utente e non si sta passando in querystrng il parametro per la lingua
                if (string.IsNullOrEmpty(CStr(lngSuffix)))
                {
                    string suffix = CStr(session[SessionProperty.strSuffLing]); //'-- lingua
                    strLingua = "LanguageSuffix=" + suffix;
                }
            }

            string strURL = "";
            if (string.IsNullOrEmpty(CStr(moduloPDF)))
            {
                if (!string.IsNullOrEmpty(idDoc))
                {
                    strURL = strSite + "/" + applicazione + url.Replace("'", "") + parametri;
                }
                else
                {
                    strURL = strSite + "/" + applicazione + url.Replace("'", "");
                }

                strURL = strURL + "&" + strBackOff + "&TO_SIGN=" + toSign + "&" + strLingua;
            }

            strURL = strURL + "&ml_footer=" + URLEncode(ml_footer) + "&lng_prefix=" + lng_suffisso + "&media_type=" + media_type;

            string strFile = "";
            //'-- compongo il nome del file pdf compresivo di path fisico se non � passato come parametro
            if (string.IsNullOrEmpty(strPathFile))
            {
                strFile = strFileName + ".pdf";

                if (strOut.EndsWith("\\", StringComparison.Ordinal) || strOut.EndsWith("/", StringComparison.Ordinal))
                {
                    strPathFile = strOut.ToLower() + strFile;
                }
                else
                {
                    strPathFile = strOut.ToLower() + "\\" + strFile;
                }

            }
            else
            {

                string[] fv = strPathFile.Split("\\");
                strFile = fv[fv.Length - 1];

            }

            session["PDF_NOME_FILE"] = strFile;

            //'Prima di creare il PDF cancelliamo un eventuale vecchio file con lo stesso nome
            if (CommonStorage.FileExists(strPathFile))
            {
                CommonStorage.DeleteObject(strPathFile, true);
            }

            /* da rimuovere codice legacy
            if (legacy.ToUpper() == "YES")
            {

                // TO D O set OBJ = CreateObject("File2PDF.Html2PDF")

                //'-- compongo il comando per convertire in PDF la pagina
                string CurDir = Directory.GetCurrentDirectory(); // TO D O verificare. CurDir ?
                strCmd = "java -jar " + CurDir + @"\pd4ml.jar ""<URL>"" ""<FILE>""";
                strCmd = strCmd.Replace("<URL>", strURL);
                strCmd = strCmd.Replace("<FILE>", strPathfile);

                //'Utenza del sistema, nella forma utente#password#dominio
                string utenzaSys = application["UTENZA_SISTEMA"];
                string user = utenzaSys.Split("#")[0];
                string pass = utenzaSys.Split("#")[1];
                string dominio = utenzaSys.Split("#")[2];

                //'-- eseguo il comando per creare il PDF
                // TO D O ret = OBJ.ExecuteAsUser( user,pass,dominio,cstr(strCmd),"C:\" )

                //'Se con l'utenza passata alla executeAsUser la creazione del pdf non � andata a buon fine
                //' (problema presentatosi se il server non aveva un dominio, come la afsvm020)
                //'proviamo con il vecchio comando, senza utenza
                if (ret != "0")
                {
                    // TO D O ret = OBJ.Execute(cstr(strCmd));
                }

                //set OBJ = nothing

            }
            else
            {
            */
            //'response.write strPathfile
            //'response.end

            strCmd = "pdf=" + strPathFile;

            if (string.IsNullOrEmpty(CStr(moduloPDF)))
            {
                strCmd = strCmd + "&url=" + URLEncode(strURL) + "";
            }

            //'-- Se � richiesta la firma produrr� implicitamente un pdf-a
            //'-- a meno che non viene passato il parametro TO_SIGN_WITHOUT_PDFA.
            //'-- creo pdf-a anche se non � richiesta la firma ma viene chiesto esplicitamente un pdf-a
            //'-- tramite il parametro PDF-A
            if (!string.IsNullOrEmpty(toSign) && (toSign.ToUpper() == "YES" || toSign == "1"))
            {
                if (CStr(signNoPDFA) != "YES")
                {
                    pdfA = "YES";
                }
            }
            else
            {
                pdfA = CStr(pdfA);
            }

            strCmd = strCmd + "&pagesize=" + pageSize + "&pageOrientation=" + pageOrientation + "&fitWith=" + fitWith + "&PDF_A=" + CStr(pdfA) + "&ml_footer=" + URLEncode(ml_footer) + "&lng_prefix=" + lng_suffisso;
            strCmd = strCmd + "&media_type=" + media_type + "&view_footer_header=" + view_footer_header + "&IDDOC=" + idDoc;

            //'-- Se � stato passato il modulo PDF
            if (!string.IsNullOrEmpty(CStr(moduloPDF)))
            {
                strCmd = strCmd + "&mode=COMPILA_MODULO_PDF&ID_VIEW=" + idDoc + "&VIEW=" + moduloView + "&URL_DOWNLOAD=" + URLEncode(moduloPDF);
            }

            //'response.write strCmd
            //'response.end

            /* da rimuovere. Tolto if
            if (fromWeb)
            {*/
            ret = invokePdf(strCmd, idDoc, IDDOCGEN, httpContext, session);
            /* da rimuovere codice non fromWeb
            }
            else
            {

                //on error resume next

                //TO D O Set obj = CreateObject("COMGeneraPdf.DotNetUtil.pdf")
                //TO D O res = obj.generaPdfA( strURL, strPathfile, "", pageOrientation, "")

                // TO D O sistemare blocco if
                //if err. number <> 0 then

                //    Set obj = nothing
                //    generaPDF = err.description
                //    exit function

                //end if

                //'-- se va in errore rifaccio un secondo tentativo
                if (res.StartsWith("0#"))
                {
                    // TO D O res = obj.generaPdfA( strURL, strPathfile, "", pageOrientation, "")
                }

                //Set obj = nothing

                if (res.StartsWith("0#"))
                {
                    return res.Replace("0#", "");

                }

            }

        }
        */

            //'Se il file pdf � stato creato con successo
            if (!CommonStorage.FileExists(strPathFile) || ret.StartsWith("0#", StringComparison.Ordinal))
            {

                if (ret.Contains("#", StringComparison.Ordinal))
                {
                    return "Errore nella generazione del file PDF : " + ret.Split("#")[1];
                }
                else
                {
                    return "Errore nella generazione del file PDF ";
                }

            }
            else
            {
                ret = "";
            }


            //set fs = nothing

            strPathfileOutput = strPathFile;
            pdfNameOut = pdfName;

            //'Se si st� facendo il PDF per la firma digitale calcoliamo l'hash del pdf appena creato
            if (!string.IsNullOrEmpty(toSign) && (toSign.ToUpper() == "YES" || toSign == "1"))
            {
                tmp = "";
                strHASHPDF = "";

                /* da rimuovere. Tolto if
                if (fromWeb)
                {
                */
                strCmd = "mode=SIGN&pdf=" + strPathFile + "&issigned=false";

                TSRecordSet rsSYS = cdf.GetRSReadFromQuery_("select id from LIB_Dictionary with(nolock) where dzt_name = 'SYS_ATTIVA_ATTACH_64' and DZT_ValueDef = 'YES'", ApplicationCommon.Application.ConnectionString);

                Exception ex = null;
                try
                {
                    if (rsSYS.RecordCount > 0)
                    {
                        tmp = invokeAttach64(strCmd, CStr(idDoc), IDDOCGEN, httpContext, session);
                    }
                    else
                    {
                        tmp = invokePdf(strCmd, CStr(idDoc), IDDOCGEN, httpContext, session);
                    }
                }
                catch (Exception e)
                {
                    ex = e;
                }

                //}


                //'--1# � OK se diverso � errore
                if (ex != null || tmp.Split("#")[0] != "1")
                {

                    mp_show_error = 1;

                    // miglioria
                    string d = tmp.Replace("0#", "");

                    if (ex == null)
                    {
                        ex = new Exception(d);
                    }
                    else
                    {
                        d = ex.Message;
                    }
                    eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString, "pdf_functions");

                    if (application["dettaglio-errori"].ToLower() == "yes")
                    {
                        throw new ResponseEndException(d, httpContext.Response, "errore calcolo hash file pdf");
                        //Response.Write d
                        //response.end
                    }
                    else
                    {
                        return ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO") + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                    }

                    // spostata sopra TraceErr s, d, n, "pdf_functions.inc"     
                }


                if (tmp.Split("#")[0] == "1")
                {
                    strHASHPDF = tmp.Split("#")[1];
                }
                /* da rimuovere codice non fromWeb
                }
                else
                {

                    //'-- se l'invocazione non � da web passo alla verifica via COM e non tramite l'aspx

                    // on error resume next

                    //TO D O Set obj = CreateObject("COMGeneraPdf.DotNetUtil.pdf")

                    res = "";
                    //TO D O res = obj.parsePdf(strPathFile, "0")
                    // set obj = nothing

                    //if err. number <> 0 then
                    //    generaPDF = "Errore nella generazione del'hash. " & err.description
                    //    exit function
                    //end if

                    //'-- se l'hash � stato generato correttamente
                    if (res.Split("#")[0] == "1")
                    {
                        strHASHPDF = res.Split("#")[1];
                    }
                    else
                    {
                        return "Errore nella generazione del'hash. " + res.Split("#")[1];
                    }
                }
                */

                if (!string.IsNullOrEmpty(strHASHPDF))
                {
                    var sqlParams = new Dictionary<string, object?>();
                    //'--se mi arriva sulla querystring il parametro IDDOC allora st� facendo il SAVEPDF sui nuovi documenti
                    /* da rimuovere. Tolto if
                    if (!string.IsNullOrEmpty(idDoc))
                    {
                    */
                    idPfu = CInt(session[SessionProperty.IdPfu]);

                    //'-- preparo i campi necessari per il meccanismo di firma
                    if (string.IsNullOrEmpty(table))
                    {
                        sqlParams.Add("@typeDoc", typeDoc);
                        rs = cdf.GetRSReadFromQuery_("select DOC_Table from LIB_Documents where DOC_ID = @typeDoc", ApplicationCommon.Application.ConnectionString, sqlParams);
                        table = CStr(GetValueFromRS(rs.Fields["DOC_Table"]));
                    }
                    else
                    {
                        //'-- validazione dell'input
                        securityModel.validate("TABLE_SIGN", table, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
                    }

                    if (string.IsNullOrEmpty(identity))
                    {
                        identity = "id";
                    }
                    else
                    {
                        securityModel.validate("IDENTITY_SIGN", identity, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
                    }

                    if (string.IsNullOrEmpty(idDoc) || string.IsNullOrEmpty(table))
                    {
                        //'call ShowError("Mancano parametri indispensabili alla firma digitale , IDDOC o TABLE")
                        return "Mancano parametri indispensabili alla firma digitale , IDDOC o TABLE";
                    }

                    strColName = "SIGN_HASH";
                    if (!string.IsNullOrEmpty(area))
                    {
                        securityModel.validate("AREA_SIGN", area, securityModel.TIPO_PARAMETRO_STRING, securityModel.SOTTO_TIPO_PARAMETRO_TABLE, "", 0, httpContext, session);
                        strColName = area + "_SIGN_HASH";
                    }


                    if (!string.IsNullOrEmpty(area))
                    {
                        sign_lock = area + "_SIGN_LOCK";
                    }
                    else
                    {
                        sign_lock = "SIGN_LOCK";
                    }

                    try
                    {
                        if (CStr(forceSign).ToUpper() != "YES")
                        {
                            //'-- controllo per evitare l'operazione
                            sqlParams.Clear();
                            sqlParams.Add("@idDoc", CInt(idDoc));
                            rs = cdf.GetRSReadFromQuery_($"select isnull( {sign_lock.Replace("'", "''")} , 0 ) as {sign_lock.Replace("'", "''")} from {table} where {identity} = @idDoc", ApplicationCommon.Application.ConnectionString, sqlParams);
                            if (GetValueFromRS(rs.Fields[sign_lock]) != 0)
                            {
                                //'call ShowError( "", "Operazione non consentita, � gia in corso una firma" )
                                return "Operazione non consentita, � gia in corso una firma";
                            }

                        }


                        //'-- lock della tabella
                        objDB = new TabManage(ApplicationCommon.Configuration);

                        if (!string.IsNullOrEmpty(CStr(idPfu)))
                        {
                            sqlParams.Clear();
                            sqlParams.Add("@idPfu", idPfu);
                            sqlParams.Add("@idDoc", CInt(idDoc));
                            string strSql = $"update {table} set {sign_lock} = @idPfu where {identity} = @idDoc and {sign_lock} = 0";
                            objDB.ExecSql(strSql, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
                        }

                        sqlParams.Clear();
                        sqlParams.Add("@idDoc", CInt(idDoc));
                        rs = cdf.GetRSReadFromQuery_($"select isnull( {sign_lock} , 0 ) as {sign_lock} from {table} where {identity} = @idDoc", ApplicationCommon.Application.ConnectionString, sqlParams);
                        if (GetValueFromRS(rs.Fields[sign_lock]) != idPfu)
                        {
                            //'call ShowError( "" , "Operazione non consentita, � gia in corso una firma" )
                            return "Operazione non consentita, � gia in corso una firma";
                        }


                        //'--inserisco HASH nella tabella indicata

                        sqlParams.Clear();
                        sqlParams.Add("@strHASHPDF", strHASHPDF);
                        sqlParams.Add("@idDoc", CInt(idDoc));
                        strSQL = " update " + table + " set " + strColName + " = @strHASHPDF where " + identity + "=@idDoc";
                        objDB.ExecSql(strSQL, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
                        //'set objDB = nothing

                    }
                    catch (Exception e)
                    {
                        return e.Message;
                    }

                    //'-- se � richiesto il salvataggio dell'allegato
                    if (CStr(saveAttach).ToUpper() == "YES")
                    {

                        var objAttach = new LibDbAttach();

                        string chiaveAllegato = string.Empty;
                        try
                        {
                            chiaveAllegato = objAttach.InsertCTL_Attach_FromFile(strPathFile, ApplicationCommon.Application.ConnectionString, CStr(strFile));
                        }
                        catch (Exception e)
                        {
                            return e.Message;
                        }

                        strColName = "SIGN_ATTACH";
                        if (!string.IsNullOrEmpty(area))
                        {
                            strColName = area + "_SIGN_ATTACH";
                        }

                        try
                        {
                            sqlParams.Clear();
                            sqlParams.Add("@chiaveAllegato", chiaveAllegato);
                            sqlParams.Add("@idDoc", CInt(idDoc));
                            strSQL = $"update {table} set {strColName} = @chiaveAllegato where {identity}=@idDoc";
                            objDB.ExecSql(strSQL, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
                            //set objDB = nothing
                        }
                        catch (Exception e)
                        {
                            //    'call ShowError(err.Description)
                            return e.Message;
                        }

                    }


                }
                else
                {
                    //'call ShowError( Split(tmp, "#")(1) )
                    return tmp.Split("#")[1];
                }

            }

            return ret;
        }

        public static void ShowError(dynamic ErrText, dynamic ErrCaption, dynamic ErrIco, HttpResponse httpResponse)
        {
            httpResponse.Redirect("../MessageBoxWin.asp?ML=yes&MSG=" + URLEncode(TruncateMessage(ErrText)) + "&CAPTION=" + URLEncode(ErrCaption) + "&ICO=" + URLEncode(ErrIco));
        }

        public static void ShowError_NO_ML(dynamic ErrText, dynamic ErrCaption, dynamic ErrIco, HttpResponse httpResponse)
        {
            httpResponse.Redirect("../MessageBoxWin.asp?ML=NO&MSG=" + URLEncode(TruncateMessage(ErrText)) + "&CAPTION=" + URLEncode(ErrCaption) + "&ICO=" + URLEncode(ErrIco));
        }

        public static string invokePdf(string param, string idDoc, string idDocGen, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            string invokePdfRet = "";

            //on error resume next

            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            //dim obj

            string protocol = "";
            string nomeApp = "";
            string urlToInvoke = "";





            Exception ex = null;
            try
            {

                nomeApp = application["AppLegacy"];
            }
            catch (Exception e)
            {
                ex = e;
            }

            if (ex != null || string.IsNullOrEmpty(nomeApp))
            {
                throw new Exception("sys AppLegacy non presente. Vericare installazione");
            }

            if (IsEmpty(application["WEBSERVERAPPLICAZIONE_INTERNO"]) || string.IsNullOrEmpty(application["WEBSERVERAPPLICAZIONE_INTERNO"]))
            {
                protocol = "http://";
                urlToInvoke = protocol + httpContext.GetServerVariable("LOCAL_ADDR") + "/" + nomeApp + "/pdf.aspx?" + param;
            }
            else
            {
                urlToInvoke = application["WEBSERVERAPPLICAZIONE_INTERNO"] + "/" + nomeApp + "/pdf.aspx?" + param;
            }

            Insert_LOG_GENERA_PDF("PDF.asp, metodo invokePdf(). Sto per invocare " + urlToInvoke, idDoc, idDocGen, session);


            try
            {
                invokePdfRet = invokeUrl(urlToInvoke);
            }
            catch (Exception ex1)
            {
                invokePdfRet = "0#" + ex1.ToString();
            }

            Insert_LOG_GENERA_PDF("PDF.asp, metodo invokePdf(). Risposta nella generazione del pdf: " + invokePdfRet, idDoc, idDocGen, session);

            return invokePdfRet;
        }

        public static string invokeAttach64(string param, string idDoc, dynamic idDocGen, HttpContext httpContext, eProcurementNext.Session.ISession session)
        {
            string invokePdfRet;

            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            string urlToInvoke;

            string nomeApp = application["NOMEAPPLICAZIONE_ALLEGATI"];

            if (string.IsNullOrEmpty(CStr(nomeApp)))
            {
                nomeApp = "AF_WebFileManager";
            }

            urlToInvoke = application["WEBSERVERAPPLICAZIONE_INTERNO"] + "/" + nomeApp + "/proxy/1.0/pdfoperation?" + param;

            Insert_LOG_GENERA_PDF("PDF.asp, metodo invokeAttach64(). Sto per invocare " + urlToInvoke, idDoc, idDocGen, session);

            try
            {
                invokePdfRet = invokeUrl(urlToInvoke);
            }
            catch (Exception ex1)
            {
                invokePdfRet = "0#" + ex1.ToString();
            }

            Insert_LOG_GENERA_PDF("PDF.asp, metodo invokeAttach64(). Risposta : " + invokePdfRet, idDoc, idDocGen, session);

            return invokePdfRet;
        }

        private static void Insert_LOG_GENERA_PDF(string param, string idDoc, dynamic idDocGen, eProcurementNext.Session.ISession session)
        {
            eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

            string strSql = "";

            string ID_DOCUMENTO = "";


            //'LOG_GENERA_PDF  recuperato da una sys
            if (application.KeyExists("LOG_GENERA_PDF") && application["LOG_GENERA_PDF"].ToUpper() == "YES")
            {
                strSql = "";

                if (!string.IsNullOrEmpty(idDoc))
                {
                    ID_DOCUMENTO = idDoc;
                }
                else
                {
                    ID_DOCUMENTO = idDocGen;
                }


                if (string.IsNullOrEmpty(ID_DOCUMENTO))
                {
                    ID_DOCUMENTO = "-1";
                }

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@idDoc", ID_DOCUMENTO);
                sqlParams.Add("@idPfu", CInt(session["idPfu"]));
                if(param.Length > 1000)
                {
                    param = $"{Left(param, 995)}...";
                }
                sqlParams.Add("@param", param);
                strSql = "INSERT INTO CTL_LOG_PROC " +
                        "(DOC_NAME,PROC_NAME,id_Doc,idPfu,Parametri) VALUES " +
                        "('DOCUMENT','GENERA_PDF',@idDoc,@idPfu,@param)";

                var obj = new TabManage(ApplicationCommon.Configuration);
                obj.ExecSql(strSql, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);
            }
        }


        private static dynamic InitMessageProcess(dynamic vRetCode, dynamic strDescrRetCode, dynamic mp_ICONMSG, dynamic mp_StrMsg)
        {
            string ret = "";

            string[] v;
            int i = 0;
            int c = 0;
            string[] v1;
            int i1 = 0;
            int c1 = 0;
            string strMsg = "";
            string testo = "";

            string MSG_ERR = "";
            string MSG_INFO = "";


            MSG_ERR = "2";
            MSG_INFO = "1";

            if (vRetCode == 1)
            {
                mp_ICONMSG = MSG_ERR;
                mp_StrMsg = "Errore";
            }
            else
            {
                mp_ICONMSG = MSG_INFO;
                mp_StrMsg = "Informazione";
            }


            //'-- recupero il messaggio da visualizzare
            v = strDescrRetCode.Split("#@#");
            c = v.Length;

            for (i = 0; i < c; i++)
            {
                testo = v[i];

                if (v[i].Contains("~~", StringComparison.Ordinal))
                {

                    v1 = strDescrRetCode.Split("~~");
                    c1 = v1.Length;

                    for (i1 = 0; i1 < c1; i1++)
                    {
                        if (Left(v1[i1], 7) == "@TITLE=")
                        {
                            //'-- recupero la caption del messaggio se presente
                            mp_StrMsg = MidVb6(v1[i1], 8);
                        }
                        else if (Left(v1[i1], 6) == "@ICON=")
                        {
                            //'-- recupero l'icona se presente
                            mp_ICONMSG = CInt(MidVb6(v1[i1], 7));
                        }
                        else
                        {
                            testo = v1[i1];
                            strMsg = strMsg + ApplicationCommon.CNV(CStr(v1[i1])) + " ";
                        }
                    }
                }
                else
                {
                    strMsg = strMsg + ApplicationCommon.CNV(CStr(testo)) + " ";
                }
            }

            ret = strMsg;

            return ret;
        }


        public void OnGet()
        {
        }
    }
}
