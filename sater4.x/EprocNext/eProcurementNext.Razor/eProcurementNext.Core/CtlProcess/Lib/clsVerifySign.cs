using Chilkat;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsVerifySign : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        private Dictionary<string, string>? mp_collParameters = null;

        private const string MODULE_NAME = "CtlProcess.ClsVerifySign";

        long mp_lIdPfu = 0;
        DataColumn? mp_blob = null;
        string mp_hash = string.Empty;
        string mp_attIdMsg = string.Empty;
        string mp_attOrderFile = string.Empty;
        string mp_attIdObj = string.Empty;
        string mp_nomeFile = string.Empty;
        string mp_pathFile = string.Empty;
        string url = string.Empty;
        string percorsoFile = string.Empty;
        string mp_idAzi = string.Empty;
        int mp_IDDoc = 0;
        int ATT_Cifrato = 0;
        string HASH_PDF_FIRMA = string.Empty;
        long idAttachInfo = 0;
        string ATT_FileHash = string.Empty;

        private const string algoritmoHashFile = "SHA256";

        //-- parametri da configurare sull'azione del processo
        private const string QUERY_ATTACH = "QUERY_ATTACH";             //-- Query che dovrà restituire le seguenti colonne :
                                                                        //                                         -- * blob
                                                                        //                                         -- * hash
                                                                        //                                         -- * attIdMsg
                                                                        //                                         -- * attOrderFile
                                                                        //                                         -- * attIdObj
                                                                        //                                         -- * nomeFile
                                                                        //                                         -- * idAzi
        private const string PAGE_TO_INVOKE = "PAGE_TO_INVOKE";         //-- pagina da invocare per la verifica della firma ( percorso a partire dalla root dell'application)
        private const string PATH_FILE = "PATH_FILE";                   //-- (opz) Indica il file di cui effettuare la verifica (path + nomeFile)
        private const string VERIFY_PENDING = "VERIFY_PENDING";         //-- (opz) se passato a YES indica che si sta richiedendo una verifica di un file messo in pending nella CTL_SIGN_ATTACH_INFO
                                                                        //                                              con questa modalità attiva se la select della QUERY_ATTACH deve ritornare anche le colonne HASH_PDF_FIRMA ed ID ( della CTL_SIGN_ATTACH_INFO ).
                                                                        //                                       --         HASH_PDF_FIRMA può essere vuota mentre ID no. HASH_PDF_FIRMA se valorizzata fa scattare il controllo sull'hash pdf rispetto al valore ritornato con il file presente nella colonna blob

        private string mp_baseUrl = string.Empty;
        private TSRecordSet? rsTemp2 = null;
        bool verificaPending = false;
        private int iTimeout = -1;
        private readonly DebugTrace dt = new();

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
        
            //TODO, Federico. Questa classe non deve più chiamare i vecchi aspx ma le nuove API degli allegati
        
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;
            string responseUrl = string.Empty;

            try
            {
                string strTmpFileName = string.Empty;
                string strSql = string.Empty;
                string statoFirma = string.Empty;
                bool bAvanzaSentinella = false;

                strDescrRetCode = string.Empty;
                mp_lIdPfu = lIdPfu;
                statoFirma = "SIGN_NOT_MATCH";

                // Apertura connessione
                strCause = "Apertura connessione al DB";

                cnLocal = SetConnection(connection, cdf);

                //Legge i parametri necessari
                strCause = "Lettura dei parametri che determinano le azioni";


                if (GetParameters(strParam, ref strDescrRetCode))
                {
                    //Controllo della condizione per eseguire l' update dei valori richiesti
                    strCause = "Controllo della condizione per eseguire l' update dei valori richiesti";

                    //-- Se la query passata come parametro (query_attach) ritorna record avvaloro le variabili locali
                    //-- con i parametri passati e vado avanti
                    if (CheckCondition(cnLocal, transaction, strDocKey, ref strDescrRetCode))
                    {
                        //-- Se tra i parametri non è presente il percorso in cui si trova il file da controllare
                        if (GetParamValue(PATH_FILE) == string.Empty)
                        {
                            strCause = "genero il nome file temporaneo";
                            strTmpFileName = CommonStorage.GetTempName();

                            //-- rendiamo univoco il nome del file
                            percorsoFile = $"{mp_pathFile}{strTmpFileName}_{mp_nomeFile}";
                        }
                        else
                            percorsoFile = GetParamValue(PATH_FILE);

                        mp_blob = (DataColumn)rsTemp2.Fields["blob"];

                        //-- Scrivo il blog recupero dalla query su disco, il nome del file

                        //TODO
                        //CommonDB.Basic.saveFileFromRecordSet(mp_blob.ColumnName, mp_blob.Table.TableName, "ATT_IdRow", CInt(rsTemp2["ATT_IdRow"]!), percorsoFile, cnLocal, transaction);
                        //ReadFromRecordset(mp_blob, mp_blob.ActualSize, percorsoFile);
                        //ReadFromRecordsetWithPath("blob", mp_blob.ActualSize, percorsoFile);

                        string page = mp_collParameters![PAGE_TO_INVOKE];
                        url = $"{mp_baseUrl}/{page}";

                        //--- SE RICHIESTA LA MODALITA' DI VERIFICA DEI FILE PENDING
                        if (verificaPending)
                        {
                            //-- se la colonna ATT_CIFRATO ritorna un valore uguale ad 1 ( l'allegato è cifrato) o a 2 (è stata richiesta l'apertura delle buste )
                            if (ATT_Cifrato == 1 || ATT_Cifrato == 2)
                            {
                                //-------------------------------------------------------------------------------------------------------
                                //--- Controllo se l'utente che sta richiedendo la verifica del file è autorizzato anche a decifrarlo ---
                                //-------------------------------------------------------------------------------------------------------
                                strCause = "Eseguo la select di controllo sul possesso del file cifrato";
                                var sqlParams = new Dictionary<string, object?>();
                                sqlParams.Add("@IDDoc", mp_IDDoc);
                                sqlParams.Add("@IdPfu", lIdPfu);
                                strSql = "select Id from CTL_DOC with (nolock) where Id = @IDDoc and (idpfu = @IdPfu or idpfuincharge = @IdPfu)";

                                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                                //-- se l'utente è autorizzato alla decifratura o il file è stato già messo in pending per essere decifrato
                                if (rs.RecordCount > 0 || ATT_Cifrato == 2)
                                {
                                    strCause = "Composizione del path per il file decifrato";
                                    string percorsoFileDecifrato = $"{mp_pathFile}{strTmpFileName}_DEC_{mp_nomeFile}";

                                    strCause = "Richiesta di decifratura file";
                                    strDescrRetCode = cifraFile(percorsoFile, percorsoFileDecifrato, CStr(mp_IDDoc), false, cnLocal, lIdPfu);

                                    //-- se l'esito della decrypt è positivo
                                    if (Len(Trim(strDescrRetCode)) == 0 && File.Exists(percorsoFile))
                                    {
                                        //-- cancelliamo il file cifrato e settiamo nel percorso "originale" quello decifrato
                                        File.Delete(percorsoFile);
                                        percorsoFile = percorsoFileDecifrato;
                                    }

                                    else
                                    {
                                        strDescrRetCode = $"Errore nella decrypt del file : {strDescrRetCode}";
                                        throw new Exception($"999 {strDescrRetCode} - {strCause} - FUNZIONE : {MODULE_NAME}.Elaborate");
                                    }
                                }
                                else
                                {
                                    strDescrRetCode = "Utente non autorizzato alla decifratura del file";
                                    throw new Exception($"999 {strDescrRetCode} - {strCause} - FUNZIONE : {MODULE_NAME}.Elaborate");
                                }

                            } //IF (ATT_Cifrato == 1 || ATT_Cifrato == 2)

                            //-- se non ci sono errori
                            if (Len(Trim(strDescrRetCode)) == 0)
                            {
                                //-- STEP 0. se manca l'hash binario del file lo generiamo e lo salviamo sulla tabella ctl_attach
                                if (Len(Trim(CStr(ATT_FileHash))) == 0)
                                {
                                    strCause = "Generazione hash binario del file";
                                    string strHashFile = getHashFile(percorsoFile);

                                    var sqlParams = new Dictionary<string, object?>();
                                    sqlParams.Add("@strHashFile", strHashFile);
                                    sqlParams.Add("@algoritmoHashFile", algoritmoHashFile);
                                    sqlParams.Add("@mp_hash", mp_hash);

                                    strSql = $"UPDATE CTL_Attach {Environment.NewLine}";
                                    strSql = $"{strSql} set ATT_FileHash = @strHashFile{Environment.NewLine}";
                                    strSql = $"{strSql} , ATT_AlgoritmoHash = @algoritmoHashFile{Environment.NewLine}";
                                    strSql = $"{strSql} WHERE ATT_Hash = @mp_hash";

                                    cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                                }

                                //-- STEP 1. SE E' RICHIESTA LA VERIFICA DELL'HASH PASSO A GENERARE L'HASH PDF DEL CONFRONTARLO CON QUANTO RITORNATO DALLA QUERY ATTACH
                                if (Len(Trim(HASH_PDF_FIRMA)) > 0)
                                {
                                    strCause = "Verifica hash di contenuto";

                                    string strValueHash = string.Empty;

                                    if (LCase(Right(mp_nomeFile, 3)) == "pdf")  //se il file è un pdf
                                    {
                                        strCause = "invokeUrl con giro pdf per recupero hash di contenuto";
                                        responseUrl = invokeUrl($"{url}?mode=SIGN&pdf={escapeFileUrl(percorsoFile)}&issigned=true");

                                        if (responseUrl == "0#Il file non è firmato digitalmente")
                                        {
                                            strDescrRetCode = "File PDF non firmato digitalmente";
                                            bAvanzaSentinella = true;
                                            statoFirma = "SIGN_NOT_OK";
                                        }
                                    }
                                    else if (LCase(Right(mp_nomeFile, 3)) == "p7m") //se il file è un p7m
                                    {
                                        strCause = "Composizione del path per il file sbustato";
                                        string fileSbustato = $"{mp_pathFile}{strTmpFileName}_SBUSTATO_{mp_nomeFile}";

                                        Crypt2 crypt = new Crypt2();

                                        string licenza = ConfigurationServices.GetKey("Chilkat:UNLOCK_KEY", "");
                                        bool ChilkatActivated = crypt.UnlockComponent(licenza); //'licenza
                                        if (!ChilkatActivated)
                                        {
                                            throw new Exception("Chilkat Library not activated");
                                        }

                                        //Estraggo il file originale dal p7m e verifico se è corrotto
                                        if (crypt.VerifyP7M(percorsoFile, fileSbustato))
                                        {
                                            int totIterazioni = 0;
                                            bool bSbusta = false;

                                            try
                                            {
                                                //-- Itero fino a togliere tutte le buste con tot tentativi max = 5 e assenza di errore
                                                while (totIterazioni < 5 && bSbusta)
                                                {
                                                    strCause = $"itero sulle buste. iterazione numero : {CStr(totIterazioni)}";

                                                    bSbusta = crypt.VerifyP7M(fileSbustato, fileSbustato);

                                                    totIterazioni += 1;
                                                }
                                            }
                                            catch (Exception ex)
                                            {
                                                //Catch vuoto per simulare il RESUME NEXT di VB6
                                                dt.Write($"{strCause} - {ex.Message}");
                                            }

                                            strCause = "invokeUrl per recupero hash di contenuto";
                                            responseUrl = invokeUrl($"{url}?mode=SIGN&pdf={escapeFileUrl(fileSbustato)}&issigned=false");
                                        }
                                        else
                                        {
                                            strDescrRetCode = "Busta P7M non valida";
                                            bAvanzaSentinella = true;
                                            statoFirma = "SIGN_NOT_OK";
                                        }
                                    }
                                    else
                                    {
                                        strDescrRetCode = "Estensione file non ammessa";
                                        bAvanzaSentinella = true;
                                        statoFirma = "SIGN_NOT_OK";
                                    }

                                    //-- se non c'è stato errore
                                    if (Len(Trim(strDescrRetCode)) == 0)
                                    {
                                        //-- Se non abbiamo ottenuto un esito di OK
                                        if (Left(responseUrl, 2) != "1#")
                                        {
                                            //                                strDescrRetCode = "Errore nella verifica del contenuto del file:" & Replace(responseUrl, "0#", "")
                                            //                                err.Raise 999, "clsVerifySign", strDescrRetCode
                                        }
                                        else
                                        {
                                            //--recupero hash

                                            strValueHash = responseUrl.Split("#")[1]; //Split(responseUrl, "#")(1)

                                            if (strValueHash == HASH_PDF_FIRMA)
                                                strDescrRetCode = string.Empty;
                                            else
                                            {
                                                strDescrRetCode = "Allegato inserito non corrispondente a quello generato e successivamente firmato digitalmente";
                                                bAvanzaSentinella = true;
                                            }
                                        }
                                    }

                                } //IF (Len(Trim(HASH_PDF_FIRMA)) > 0)

                                //-- STEP 2. SE L'HASH DI PDF COINCIDE(o non è stata richiesta la verifica), PASSIAMO A FARE LA VERIFICA ESTESA DEI CERTIFICATI DI FIRMA
                                if (Len(Trim(strDescrRetCode)) == 0)
                                {
                                    strCause = "Verifica envelope di firma";
                                    responseUrl = verifyFileSigned(url, percorsoFile, mp_hash, mp_idAzi);

                                    if (Left(responseUrl, 2) != "1#")
                                        throw new Exception("999" + Replace(responseUrl, "0#", "") + " - FUNZIONE : " + MODULE_NAME + ".Elaborate");
                                    else
                                        responseUrl = strDescrRetCode;
                                }

                            } // IF (Len(Trim(strDescrRetCode)) == 0)

                        }
                        else //-- IF verificaPending Then
                        {
                            strCause = "Chiamo il metodo verifyFileSigned()";

                            responseUrl = verifyFileSigned(url, percorsoFile, mp_hash, mp_idAzi, mp_attIdMsg, mp_attOrderFile, mp_attIdObj);
                        }

                        if (File.Exists(percorsoFile))
                        {
                            File.Delete(percorsoFile);
                        }

                        //-- Se abbiamo ottenuto un errore gestito
                        if (Left(responseUrl, 2) == "1#")
                        {
                            if (verificaPending)
                            {
                                //-- SE SIAMO NEL GIRO DI VERIFICA FILE PENDING ED E' ANDATO TUTTO BENE, "SGANCIAMO" IL RECORD SENTINELLA DALLA CTL_SIGN_ATTACH_INFO
                                //-- COSI' DA LASCIARE SOLO QUELLO/I VALIDI ED APPENA GENERATI(chiamata a verifyFileSigned )

                                var sqlParams = new Dictionary<string, object?>();
                                sqlParams.Add("@idAttachInfo", idAttachInfo);

                                strSql = $"UPDATE CTL_SIGN_ATTACH_INFO {Environment.NewLine}";
                                strSql += $"{strSql} set ATT_Hash = '--' + ATT_Hash {Environment.NewLine}";
                                strSql += $"{strSql} Where Id = @idAttachInfo";

                                cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                            }

                            strDescrRetCode = string.Empty;
                            strReturn = ELAB_RET_CODE.RET_CODE_OK;
                        }
                        else
                        {
                            if (Left(responseUrl, 2) == "0#")
                                strDescrRetCode = Replace(responseUrl, "0#", "");
                            else
                                strDescrRetCode = responseUrl;

                            //-- IN CASO DI VERIFICA FILE PENDING E DI RICHIESTA DI AVANZAMENTO DELLO STATO DELLA SENTINELLA,
                            //--     DOBBIAMO DARE SEMPRE UN OK AL PROCESSO PER PERMETTERE IL SETTAGGIO DELL'ESITO SUL RICHIEDENTE.
                            //--     IL KO SARA' ISOLATO SOLO AI RUNTIME ERROR, GLI ALTRI SONO ERRORI "FUNZIONALI" DA FAR RISALIRE SUL DOCUMENTO
                            if (verificaPending && bAvanzaSentinella)
                            {
                                strReturn = ELAB_RET_CODE.RET_CODE_OK;  //-- anche se c'è un output di "errore" da comunicare, è un errore funzionale.la verifica comunque è andat a buon fine.visualizziamo il dettaglio nelle note

                                var sqlParams = new Dictionary<string, object?>();
                                sqlParams.Add("@statoFirma", statoFirma);
                                sqlParams.Add("@strDescrRetCode", strDescrRetCode);
                                sqlParams.Add("@idAttachInfo", idAttachInfo);

                                strSql = $"UPDATE CTL_SIGN_ATTACH_INFO {Environment.NewLine}";
                                strSql = $"{strSql} set statoFirma = @statoFirma{Environment.NewLine}";
                                strSql = $"{strSql} note = @strDescrRetCode{Environment.NewLine}";
                                strSql = $"{strSql} Where Id = @idAttachInfo";

                                cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                            }
                        }
                    }
                }

                return strReturn;
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);

                //    '-- Se l'invocazione all'url è fallita
                if (Len(Trim(percorsoFile)) > 0 && CommonStorage.FileExists(percorsoFile))
                {
                    CommonStorage.DeleteFile(percorsoFile);
                }

                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            bool bReturn = false;

            // I parametri vengono passati come Field1=Valore1&Field2=Valore2....
            try
            {
                mp_collParameters = GetCollectionExt(strParam);

                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' controlli sui parametri passati
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (!mp_collParameters.ContainsKey(QUERY_ATTACH))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_ATTACH}";
                    return bReturn;
                }

                if (!mp_collParameters.ContainsKey(PAGE_TO_INVOKE))
                {
                    strDescrRetCode = $"Manca il parametro input {PAGE_TO_INVOKE}";
                    return bReturn;
                }

                if (mp_collParameters.ContainsKey(VERIFY_PENDING))
                {
                    verificaPending = UCase(mp_collParameters[VERIFY_PENDING]) == "YES";
                }

                bReturn = true;
                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }
        }

        private bool CheckCondition(SqlConnection conn, SqlTransaction trans, dynamic strDocKey, ref string strDescrRetCode)
        {
            bool bReturn = false;

            try
            {
                string strSql = mp_collParameters![QUERY_ATTACH];
                strSql = Replace(strSql, "<ID_USER>", CStr(mp_lIdPfu));
                strSql = Replace(strSql, "<ID_DOC>", CStr(strDocKey));

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                //-- Se ci sono record
                if (!(rs.EOF && rs.BOF))
                {
                    rs.MoveFirst();

                    mp_blob = rs.Columns["blob"];

                    mp_hash = CStr(rs["hash"]);
                    mp_attIdMsg = CStr(rs["attIdMsg"]);
                    mp_attOrderFile = CStr(rs["attOrderFile"]);
                    mp_attIdObj = CStr(rs["attIdObj"]);
                    mp_nomeFile = CStr(rs["nomeFile"]);
                    mp_idAzi = CStr(rs["idAzi"]);

                    try
                    {
                        if (verificaPending)
                        {
                            idAttachInfo = CLng(rs["id"]!);
                            mp_IDDoc = CInt(rs["ATT_IdDoc"]!);
                            ATT_Cifrato = CInt(rs["ATT_Cifrato"]!);
                            if (IsNull(idAttachInfo) || IsNull(mp_IDDoc) || IsNull(ATT_Cifrato))
                            {
                                strDescrRetCode = $"Richiedendo la modalità {VERIFY_PENDING} è obbligatorio che la QUERY_ATTACH ritorni le colonne id (corrispondente alla CTL_SIGN_ATTACH_INFO),ATT_IdDoc e ATT_Cifrato";
                                return bReturn;
                            }

                            HASH_PDF_FIRMA = CStr(rs["HASH_PDF_FIRMA"]);
                            ATT_FileHash = CStr(rs["ATT_FileHash"]);

                            if (IsNull(HASH_PDF_FIRMA))
                            {
                                HASH_PDF_FIRMA = string.Empty;
                            }

                            if (IsNull(ATT_FileHash))
                            {
                                ATT_FileHash = string.Empty;
                            }
                        }
                    }
                    catch { }

                    //TODO
                    rsTemp2 = new TSRecordSet();
                    rsTemp2.OpenWithTransaction(strSql, conn, trans, timeout: iTimeout);
                    //        rsTemp2.CursorLocation = adUseClient
                    //        rsTemp2.LockType = adLockOptimistic


                    //        rsTemp2.Fields.Append mp_blob.Name, mp_blob.Type, mp_blob.DefinedSize
                    //        rsTemp2.Open

                    //        rsTemp2.AddNew

                    //        rsTemp2.Fields(mp_blob.Name) = mp_blob.Value


                    //        rsTemp2.Update

                    //        rs.Close

                    strSql = "select dzt_valuedef from lib_dictionary where dzt_name = 'SYS_PathFolderAllegati'";

                    rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();

                        mp_pathFile = CStr(rs["dzt_valuedef"]);
                    }

                    strSql = "select dzt_valuedef from lib_dictionary where dzt_name = 'SYS_WEBSERVERAPPLICAZIONE_INTERNO'";

                    rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();

                        mp_baseUrl = CStr(rs["dzt_valuedef"]);
                    }

                    strSql = "select dzt_valuedef from lib_dictionary where dzt_name = 'SYS_NOMEAPPLICAZIONE'";

                    rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();

                        mp_baseUrl = CStr(rs["dzt_valuedef"]);
                    }

                    bReturn = true;
                }

                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckCondition", ex);
            }
        }
        private string GetParamValue(dynamic strKey)
        {
            try
            {
                return mp_collParameters![strKey];
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public string verifyFileSigned(string url, string percorsoFile, string mp_hash = "", string idazi = "", string mp_attIdMsg = "", string mp_attOrderFile = "", string mp_attIdObj = "")
        {
            string strReturn = string.Empty;
            string mode = string.Empty;

            if (Right(url, 1) != "?")
            {
                url = $"{url}?";
            }

            if (UCase(Right(percorsoFile, 3)) == "P7M")
            {
                mode = "VERIFICA_P7M";
            }
            else
            {
                mode = "VERIFICA_PDF";
            }

            url = $"{url}mode={mode}&signedfile={minimalUrlEncode(percorsoFile)}&att_hash={mp_hash}";
            url = $"{url}&attIdMsg={mp_attIdMsg}&attOrderFile={mp_attOrderFile}&attIdObj={mp_attIdObj}";
            url = $"{url}&idAzi={idazi}";
            if (verificaPending)
                url = $"{url}&NOME_FILE={mp_nomeFile}"; //-- indichiamo all'aspx il nome originale del file, in automatico recupera quello di lavoro

            strReturn = invokeUrl(url);

            return strReturn;
        }

        private string escapeFileUrl(string pathFile)
        {
            string strReturn = pathFile;

            strReturn = Replace(strReturn, " ", "%20");
            strReturn = Replace(strReturn, @"""", @"%22");
            strReturn = Replace(strReturn, "&", "%26");
            strReturn = Replace(strReturn, "<", "%3C");
            strReturn = Replace(strReturn, ">", "%3E");
            strReturn = Replace(strReturn, "è", "%C3%A8");
            strReturn = Replace(strReturn, "ò", "%C3%B2");
            strReturn = Replace(strReturn, "à", "%C3%A0");
            strReturn = Replace(strReturn, "+", "%2B");
            strReturn = Replace(strReturn, "ù", "%C3%B9");
            strReturn = Replace(strReturn, "#", "%23");
            strReturn = Replace(strReturn, @"\", @" % 5C");
            strReturn = Replace(strReturn, @"/", "%2F");
            strReturn = Replace(strReturn, ":", "%3A");

            return strReturn;
        }

        private string getHashFile(string strPathFile)
        {
            string strReturn = string.Empty;
            string strUrl = $"{mp_baseUrl}/filehash.aspx?genera_hash=yes&algoritmo={algoritmoHashFile}&file={escapeFileUrl(strPathFile)}";
            strReturn = invokeUrl(strUrl);

            if (strReturn == String.Empty || Left(strReturn, 2) == "0#")
            {
                strReturn = string.Empty;

                throw new Exception($"999 Errore nella generazione dell'hash del file. - {Replace(strReturn, "0#", "")} - FUNZIONE : {MODULE_NAME}.getHashFile");
            }
            return strReturn;
        }
    }
}
