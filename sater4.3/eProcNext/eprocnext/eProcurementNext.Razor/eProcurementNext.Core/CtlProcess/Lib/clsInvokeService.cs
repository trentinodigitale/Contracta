using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsInvokeService : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new();
        private Dictionary<string, string>? mp_collParameters = null;

        private const string MODULE_NAME = "CtlProcess.ClsInvokeService";

        //-- parametri da configurare sull'azione del processo
        private const string URL_TO_INVOKE = "URL_TO_INVOKE";       //-- Url da invocare (Ci viene invocato una cnv estesa sopra per risolvere sys e multilinguismi vari)
                                                                    //-- Ci sostituiremo (replace):
                                                                    //-- <ID_DOC>
                                                                    //-- <ID_USER>

        //-- (opz.) Query di update che viene eseguita dopo l'invocazione di URL_TO_INVOKE per gestire il valore di ritorno
        //-- a tale query andremo poi a sostituire i parametri sotto elencati :
        private const string QUERY_UPDATE = "QUERY_UPDATE";         //-- <ID_DOC>
                                                                    //-- <ID_USER>
                                                                    //-- <TYPE_DOC>    ( strDocType )
                                                                    //-- <URL_OUTPUT>  (Output della pagina invocata)

        //-- (opz.) Vista che ritorna N parametri i cui valori vanno a sostituirsi ai vari <NOME_COLONNA> trovati nel parametro URL_FILE, URL_TO_INVOKE
        private const string VIEW_URL_PARAMS = "VIEW_URL_PARAMS";

        private const string URL_TO_GET_DOCUMENT_XML = "URL_TO_GET_DOCUMENT_XML";       //-- (opz.) Url da invocare per ottenere l'xml del documento
                                                                                        //-- Ci sostituiremo (replace):
                                                                                        //-- <ID_DOC>
                                                                                        //-- <ID_USER>

        private const string POST_PARAMS = "POST_PARAMS";           //-- Se presente il parametro URL_TO_GET_DOCUMENT_XML vuol dire che a quest'url
                                                                    //-- mando un documento in formato xml inviato via POST alla pagina, quindi far una replace
                                                                    //-- del tag ##DOCUMENT-XML-POST## a questi parametri, (nella forma nomeParametro=111&param=aaa) verranno inviati a URL_TO_INVOKE


        private const string LOAD_DOC_FROM_VB = "LOAD_DOC_FROM_VB";     //-- SE YES recupera la versione xml del documento direttamente dal documento vb6 senza passare da una pagina web

        private const string CONTEXT = "CONTEXT";     //-- parametro opzionale atto ad indicare il contesto funzionale che si sta invocando ( ad es. SIMOG, NOTIER, PROTOCOLLO GENERALE, ETC ).
                                                      //--     il suo valore sar soggetto a CNV_ESTESA e verr anteposto al messaggio di errore per far capire all'utente che l'errore
                                                      //--      dovuto ad un contesto (spesso esterno all'applicazione ) specifico piuttosto che al processo stesso

        private const string NO_MSG_RETRY = "NO_MSG_RETRY";  // opzionale se YES non restituisco il messaggio "riprovare più tardi"

        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR_NOCNV;
            SqlConnection? cnLocal = null!;
            string strCause = string.Empty;
            iTimeout = timeout;

            try
            {
                string strSql = string.Empty;
                string urlToInvoke = string.Empty;
                string resp = string.Empty;
                string urlDocXml = string.Empty;
                string dataPost = string.Empty;
                string Contesto = string.Empty;
                string msgErroreGenerico = string.Empty;
                string msgRiprovare = string.Empty;
                string no_msg_retry = string.Empty;
                string msgErroreEscape = string.Empty;
                string strRel_Type = string.Empty;
                string strErrore_Trascodificato = string.Empty;

                strDescrRetCode = string.Empty;

                strCause = "Lettura dei parametri che determinano le azioni";

                if (GetParameters(strParam, ref strDescrRetCode))
                {
                    // Apertura connessione
                    strCause = "Apertura connessione al DB";
                    cnLocal = SetConnection(connection, cdf);

                    urlToInvoke = GetParamValue(URL_TO_INVOKE);
                    urlDocXml = GetParamValue(URL_TO_GET_DOCUMENT_XML);
                    dataPost = GetParamValue(POST_PARAMS);
                    Contesto = GetParamValue(CONTEXT);

                    //--leggo il nuovo paraemtro per stabilire se restuiire la frase riprovare
                    no_msg_retry = GetParamValue(NO_MSG_RETRY);

                    //-- in assenza del parametro CONTEXT usiamo un default
                    if (Len(Trim(Contesto)) == 0)
                    {
                        Contesto = $"INVOKE-{strDocType}";
                    }

                    SqlConnection objConn = cdf.SetConnection(cnLocal.ConnectionString);

                    //-- invoco la cnv_estesa sul URL_TO_INVOKE ( e su tutti quelli necessari )per risolvere eventuali ML e SYS
                    //-- es di chiave: http://localhost/#SYS.SYS_nomeappportale#/downloader.asp

                    DebugTrace dt = new();
                    dt.Write("clsInvokeService - urlToInvoke =" + urlToInvoke);
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@urlToInvoke", urlToInvoke);
                    sqlParams.Add("@urlDocXml", urlDocXml);
                    sqlParams.Add("@dataPost", dataPost);
                    sqlParams.Add("@Contesto", Contesto);
                    strSql = "select dbo.CNV_ESTESA(@urlToInvoke,'I') as valore1, dbo.CNV_ESTESA(@urlDocXml,'I') as valore2 , dbo.CNV_ESTESA(@dataPost,'I') as valore3, dbo.CNV_ESTESA(@Contesto,'I') as valore4, dbo.CNV_ESTESA('INFO_UTENTE_ERRORE_PROCESSO','I') as valore5 , dbo.CNV_ESTESA('ctlProcess.clsInvokeService - Si prega di riprovare piu tardi','I') as valore6";

                    strCause = "Applico la funzione sql cnv_estesa sul parametro URL_TO_INVOKE";
                    TSRecordSet? rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                    if (rs is not null && rs.RecordCount > 0)
                    {
                        //-- Ottimizzo l'accesso al DB facendo un unica query risolvendo 3 cnvestese
                        rs.MoveFirst();
                        urlToInvoke = CStr(rs["valore1"]);
                        urlDocXml = CStr(rs["valore2"]);
                        dataPost = CStr(rs["valore3"]);
                        Contesto = CStr(rs["valore4"]);
                        msgErroreGenerico = CStr(rs["valore5"]);
                        msgRiprovare = CStr(rs["valore6"]);
                    }

                    //-- Applico le sostituzioni di idUser e idDoc all'url da invocare
                    urlToInvoke = Replace(urlToInvoke, "<ID_USER>", CStr(lIdPfu));
                    urlToInvoke = Replace(urlToInvoke, "<ID_DOC>", CStr(strDocKey));

                    //-- Applico le sostituzioni rispetto alla collezione (nomeColonna/Valore) ritornata dalla vista
                    string viewParams = string.Empty;
                    viewParams = CStr(GetParamValue(VIEW_URL_PARAMS));

                    if (Len(Trim(viewParams)) > 0)
                    {
                        viewParams = Replace(viewParams, " ", "");
                        viewParams = Replace(viewParams, ";", "");
                        viewParams = Replace(viewParams, "--", "");

                        strCause = $"Sostituisco i parametri in URL_TO_INVOKE rispetto alla vista {viewParams}";

                        sqlParams.Clear();
                        sqlParams.Add("@DocKey", CInt(strDocKey));
                        strSql = $"select * from {viewParams} where id = @DocKey";

                        strCause = $"Eseguo la query {strSql}";

                        rs = cdf.GetRSReadFromQuery_(strSql, objConn.ConnectionString, objConn, iTimeout, sqlParams);

                        if (rs is not null && rs.RecordCount > 0)
                        {
                            rs.MoveFirst();
                            try
                            {
                                dynamic valore = string.Empty;
                                foreach (DataColumn dc in rs.Columns!)
                                {
                                    if (!IsNull(CStr(rs[dc.ColumnName])))
                                    {
                                        valore = CStr(rs[dc.ColumnName]);
                                    }

                                    //-- Sostituisco alla stringa urlDown tutte le ricorrenze nella forma <NOME_COLONNA>
                                    //-- Con il relativo valore recupero dalla vista
                                    urlToInvoke = Replace(urlToInvoke, $"<{UCase(dc.ColumnName)}>", valore);
                                    dataPost = Replace(dataPost, $"<{UCase(dc.ColumnName)}>", valore);
                                }
                            }
                            catch (Exception ex)
                            {
                                //Catch vuoto per simulare il RESUME NEXT di VB6
                                dt.Write($"{strCause} - {ex.Message}");
                            }
                        }
                    }

                    string outputXmlDocument = string.Empty;
                    bool bErr = false;
                    string sErrDescription = string.Empty;

                    if (!string.IsNullOrEmpty(urlDocXml))
                    {
                        try
                        {
                            //-- invocazione con metodo POST in cui la pagina prima recupero il documento XML e poi lo invio alla pagina
                            //-- che invocherà a sua volta il WS
                            urlDocXml = Replace(urlDocXml, "<ID_USER>", CStr(lIdPfu));
                            urlDocXml = Replace(urlDocXml, "<ID_DOC>", CStr(strDocKey));

                            strCause = "Invocazione url documento";

                            outputXmlDocument = invokeUrl(urlDocXml);

                            //-- Se la risposta è arrivata vuota (potenziali problemi di rete o rallentamenti di varia natura, riprovo)
                            if (Len(Trim(outputXmlDocument)) == 0)
                                outputXmlDocument = invokeUrl(urlDocXml);
                        }
                        catch (Exception ex)
                        {
                            outputXmlDocument = "0#Risposta vuota dall'url per serializzare il documento";
                            resp = "0#Risposta vuota dall'url per serializzare il documento";
                            bErr = true;
                            sErrDescription = ex.Message;
                        }

                        if (!bErr && Len(Trim(outputXmlDocument)) > 0)
                        {
                            try
                            {
                                //-- Metto in POST il documento XML recuperato
                                dataPost = Replace(dataPost, "##DOCUMENT-XML-POST##", postEncode(outputXmlDocument));

                                strCause = "Invocazione url WS";
                                resp = invokePageInPost(urlToInvoke, dataPost);
                            }
                            catch (Exception ex)
                            {
                                bErr = true;
                                sErrDescription = ex.Message;
                            }
                        }
                    }
                    else
                    {
                        //-- Se si vuole far recuperare il documento xml non dalla pagina xml.asp
                        //-- ma direttamente dalla struttura del documento rigenerata da qui
                        string docFromVB = string.Empty;

                        try
                        {
                            docFromVB = GetParamValue(LOAD_DOC_FROM_VB);
                        }
                        catch (Exception ex)
                        {
                            bErr = true;
                            sErrDescription = ex.Message;
                        }

                        if (Len(Trim(docFromVB)) > 0 && UCase(CStr(docFromVB)) == "YES")
                        {
                            try
                            {
                                outputXmlDocument = getXmlDocument(CStr(strDocKey), strDocType, cnLocal.ConnectionString);
                            }
                            catch (Exception ex)
                            {
                                bErr = true;
                                sErrDescription = ex.Message;
                            }

                            if (!bErr)
                            {
                                //-- Metto in POST il documento XML recuperato
                                dataPost = Replace(dataPost, "##DOCUMENT-XML-POST##", postEncode(outputXmlDocument));

                                strCause = "Invocazione url WS";
                                resp = invokePageInPost(urlToInvoke, dataPost);
                            }
                        }
                        else
                        {
                            try
                            {
                                //-- invocazione standard in cui la pagina chiamata recupera lei il documento xml da inviare al ws
                                strCause = "Invoco l'url del servizio remoto";
                                resp = invokeUrl(urlToInvoke);
                            }
                            catch (Exception ex)
                            {
                                resp = "0#Errore invocazione servizio";
                                bErr = true;
                                sErrDescription = ex.Message;
                            }
                            //-- se c' stato un errore nell'invocazione, riprovo prima di far risalire l'errore
                            if (bErr || (Len(resp) > 2 && Left(resp, 2) != "1#"))
                            {
                                bErr = false;
                                resp = invokeUrl(urlToInvoke);
                            }
                        }
                    }

                    if (bErr || Left(resp, 2) != "1#") //-- Se la pagina ha ritornato un errore
                    {
                        string msgErrore = string.Empty;

                        if (!bErr) //-- Se era un errore gestito e non un errore di runtime
                        {
                            msgErrore = Replace(resp, "0#", "");
                        }
                        else
                        {
                            msgErrore = $"Run time error nella invoke. {sErrDescription}";
                            throw new Exception($"{strCause} - {msgErrore} - FUNZIONE : {MODULE_NAME}.Elaborate");
                        }

                        //        '--VERIFICO SE HO UNA TRASCODIFICA PER L'ERRORE RITORNATO
                        //'--nella ctl_relation ED ENTRO PER REL_TYPE=INVOKE_SERVICE-<CONTESTO>
                        //'--                                REL_VALUE_INPUT = msgErrore
                        //'--                                REL_VALUE_OUTPUT = ERRORE TRASCODIFICATO A CUI APPLICARE ML
                        //'-- se torna righe restituisco REL_VALUE_OUTPUT tradotto
                        //'-- altrimenti come adesso

                        //'--applico escape al messaggio (tolgo singolo apice e vbcrlf)
                        strErrore_Trascodificato = string.Empty;

                        if (Len(Trim(msgErrore)) > 0)
                        {
                            strRel_Type = "INVOKE_SERVICE-" + Trim(Contesto);

                            strCause = $"Cerco una trascodifica dell'errore tramite una relazione per l'errore ritornato rel_type={strRel_Type}";
                            msgErroreEscape = Replace(msgErrore, Environment.NewLine, " ");
                            msgErroreEscape = Trim(msgErrore);
                            msgErroreEscape = Replace(msgErroreEscape, "'", "''");

                            sqlParams.Clear();
                            sqlParams.Add("@Rel_Type", strRel_Type);
                            sqlParams.Add("@ErroreEscape", msgErroreEscape);

                            strSql = "select dbo.CNV_ESTESA (REL_ValueOutput,'I') as ErroreTrascodificato From CTL_Relations with (nolock) where rel_type = @Rel_Type and REL_ValueInput=@ErroreEscape";

                            rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                            if (rs is not null && rs.RecordCount > 0)
                            {
                                rs.MoveFirst();
                                strErrore_Trascodificato = CStr(rs["ErroreTrascodificato"]);
                            }
                        }

                        //'--se non ho un trascodifica dell'errore
                        if (Len(Trim(strErrore_Trascodificato)) == 0)
                        {
                            strDescrRetCode = $"{Contesto} : {msgErrore}";

                            //    '--se il nuovo paraemtro  dioverso da YES aggiungo il messaggio riprovare...
                            if (NO_MSG_RETRY != "YES")
                                strDescrRetCode = $"{strDescrRetCode} - {msgRiprovare}";
                        }
                        else
                            strDescrRetCode = strErrore_Trascodificato;
                    }
                    else
                    {
                        try
                        {
                            if (GetParamValue(QUERY_UPDATE) != "")
                            {
                                //--recupero valore di ritorno
                                if (resp.Contains('#', StringComparison.Ordinal))
                                {
                                    string[] vT = resp.Split("#");
                                    resp = vT[1].ToString();
                                }

                                strSql = GetParamValue(QUERY_UPDATE);
                                strSql = Replace(strSql, "<ID_USER>", CStr(lIdPfu));
                                strSql = Replace(strSql, "<ID_DOC>", CStr(strDocKey));
                                strSql = Replace(strSql, "<TYPE_DOC>", strDocType);
                                strSql = Replace(strSql, "<URL_OUTPUT>", Replace(resp, "'", "''"));

                                strCause = $"Eseguo la query con execSql : {strSql}";

                                cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                            }
                            //-- tutto ok
                            strReturn = ELAB_RET_CODE.RET_CODE_OK;

                        }
                        catch (Exception ex)
                        {
                            throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
                        }
                    }
                    //        ' Chiusura connessione
                    //        strCause = "Chiusura connessione al DB"

                    //        If Not objctx Is Nothing Then
                    //            CloseConnection cnLocal
                    //            objctx.SetComplete
                    //        End If
                }
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
            return strReturn;
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            bool bReturn = false;
            //    ' I parametri vengono passati come Field1=Valore1&Field2=Valore2....

            try
            {
                mp_collParameters = GetCollectionExt(strParam);


                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                // controlli sui parametri passati
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

                // query di selezione righe invalide
                if (!mp_collParameters.ContainsKey(URL_TO_INVOKE))
                {
                    strDescrRetCode = $"Manca il parametro input {URL_TO_INVOKE}";
                    return bReturn;
                }

                bReturn = true;
                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }
        }

        private string GetParamValue(string strKey)
        {
            string strReturn = string.Empty;

            if (mp_collParameters!.ContainsKey(strKey))
                strReturn = mp_collParameters[strKey].ToString();

            return strReturn;
        }

        private string postEncode(string dati)
        {
            string strReturn = string.Empty;
            if (Len(Trim(dati)) > 0)
            {
                strReturn = Replace(dati, " ", "%20");
                strReturn = Replace(strReturn, @"""", "%22");
                strReturn = Replace(strReturn, "&", "%26");
                strReturn = Replace(strReturn, "<", "%3C");
                strReturn = Replace(strReturn, ">", "%3E");
                strReturn = Replace(strReturn, Environment.NewLine, "");
            }
            return strReturn;
        }

        private string getXmlDocument(string mp_IDDoc, string mp_TypeDoc, string mp_strConnectionString)
        {
            Document.CTLDOCOBJ.Document? mp_ObjHtml;
            EprocResponse ScopeLayer;
            string outputXml = string.Empty;

            //On Error Resume Next

            //try{
            //    mp_objSession[0] = collezioneVuota;
            //}catch{}
            //try{
            //    mp_objSession[1] = collezioneVuota;
            //}catch{}

            //try{
            //    mp_objSession[SESSION_SUFFIX] = "I";
            //}catch{}
            //try{
            //    mp_objSession[SESSION_CONNECTIONSTRING] = mp_strConnectionString;
            //}catch{}
            //try{
            //    mp_objSession[SESSION_USER] = CInt(0);
            //}catch{}
            //try{
            //    mp_objSession[SESSION_PERMISSION] = "";
            //}catch{}

            //try{
            //    mp_objSession[5] = collezioneVuota;
            //}catch{}
            //try{
            //    mp_objSession[OBJAPPLICATION] = collezioneVuota;
            //}catch{}
            //try{
            //    mp_objSession[13] = collezioneVuota;
            //}catch{}

            eProcurementNext.Session.Session dummySession = new eProcurementNext.Session.Session();
            dummySession.Init(Guid.NewGuid().ToString());
            dummySession[Session.SessionProperty.SESSION_SUFFIX] = "I";//'Request_QueryString("Suffix")
            dummySession["IdPfu"] = CInt(0); //'Request_QueryString("User")
            dummySession["Funzionalita"] = ""; //'SESSION_PERMISSION)

            HttpContext dummyContext = new DummyContext();

            EprocResponse dummyResponse = new EprocResponse();//= CreateObject("ctlhtml.scopelayer")

            Lib_dbDocument objDB = new Lib_dbDocument(dummyContext, dummySession, dummyResponse);

            //'-- recupero la struttura del documento
            mp_ObjHtml = objDB.getDocumentFuoriSessione(mp_TypeDoc, "", "I", 0, mp_strConnectionString);

            if (mp_ObjHtml is not null)
            {
                mp_ObjHtml.ReadOnly = true;

                //ATTENZIONE IN DEBUG VVV Commenti soluzione as-is VVV
                //'-- Fino a qui funziona, ma la load dei dati nelle singole sezioni fallisce
                //'-- bisogna aggiungere un po ovunque IF sulla presenza del vettore di sessione
                //'-- o di variabili in esso contenute che in questa situazione vengono a mancare

                mp_ObjHtml.Load(dummySession, mp_IDDoc);
                //'mp_ObjHtml.UpdateContentInMem mp_objSession

                ScopeLayer = new EprocResponse(); //= CreateObject("ctlhtml.scopelayer")
                                                 //ScopeLayer.InitNew(null, outputXml, null, CInt(3));   //'-- OUTPUT di tipo stringa (non response)

                //'-- crea l'xml del' documento
                mp_ObjHtml.xml(ScopeLayer);

                return ScopeLayer.Out();
            }
            else 
            {
                return outputXml;
            }
        }
    }
}
