using eProcurementNext.CommonDB;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsLoadDossier : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new();
        private Dictionary<string, string>? mp_collParameters = null;
        string mp_strTableName = string.Empty;
        string mp_strFieldIDName = string.Empty;

        private const string MODULE_NAME = "CtlProcess.ClsLoadDossier";

        //-- parametri da configurare sull'azione del processo
        private const string QUERY_CONDITION = "QUERY_CONDITION"; //-- facoltativo, contiene la query che se non ritorna righe vuol dire che è falsa e non effettua i settaggi richiesti
        private const string QUERY_TESTATA = "QUERY_TESTATA";   //-- query che ritorna le info di testata del documento
        private const string QUERY_PRODOTTI = "QUERY_PRODOTTI"; //-- query che ritorna le info di dettaglio del documento
        //-- ITYPE = tipo del docmento da caricare per collegamento verso la precedente gtestione
        //-- ISUBTYPE = sottotipo

        //-- alle query viene sostituito il valore <ID_DOC> con l'identificativo del documento

        private int ITYPE = 0;
        private int ISUBTYPE = 0;

        private const int Apat_Dossier_Msg = 15;
        private const int Apat_Dossier_Msg_Articoli = 14;
        private int iTimeout = -1;

        public enum arrRsDossierPosition
        {
            indMessaggiArticoli = 0,
            indMSGVatArt = 1,
            indMSGValoriAttributi = 2,
            indMSGValoriAttributi_Datetime = 3,
            indMSGValoriAttributi_Float = 4,
            indMSGValoriAttributi_Descrizioni = 5,
            indMSGValoriAttributi_Image = 6,
            indMSGValoriAttributi_Int = 7,
            indMSGValoriAttributi_Keys = 8,
            indMSGValoriAttributi_Money = 9,
            indMSGValoriAttributi_NVarchar = 10,
            indMSGVatMsg = 11
        }

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            try
            {
                strDescrRetCode = string.Empty;

                // Apertura connessione
                strCause = "Apertura connessione al DB";
                cnLocal = SetConnection(connection, cdf);

                // STEP 1 --- legge i parametri necessari
                strCause = "Lettura dei parametri che determinano le azioni";

                if (GetParameters(strParam, ref strDescrRetCode))
                {
                    // STEP 2 --- Controllo della condizione per eseguire il popolamneto del dossier
                    strCause = "Controllo della condizione per eseguire il popolamneto del dossier";

                    if (CheckCondition(cnLocal, transaction, strDocType, strDocKey, ref strDescrRetCode))
                    {
                        // STEP 3 --- Popola il dossier
                        strCause = "Popola il dossier";
                        if (!PopolaDossier(cnLocal, transaction, strDocType, strDocKey, ref strDescrRetCode))
                        {
                            strCause = "errore inserimento documento " + strDocType + " id=" + CStr(strDocKey) + " descrizione=" + strDescrRetCode;
                            return strReturn;
                        }
                    }
                    strReturn = ELAB_RET_CODE.RET_CODE_OK;
                }

                return strReturn;
            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            bool bReturn = false;
            //    ' I parametri vengono passati come Field1=Valore1&Field2=Valore2....

            try
            {
                mp_collParameters = GetCollectionExt(strParam);

                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    ' controlli sui parametri passati
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (!mp_collParameters.ContainsKey(QUERY_TESTATA))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_TESTATA}";
                    return bReturn;
                }

                if (!mp_collParameters.ContainsKey(QUERY_PRODOTTI))
                {
                    strDescrRetCode = $"Manca il parametro input {QUERY_PRODOTTI}";
                    return bReturn;
                }

                if (mp_collParameters.ContainsKey("ITYPE"))
                {
                    ITYPE = CInt(mp_collParameters["ITYPE"]);
                }

                if (mp_collParameters.ContainsKey("ISUBTYPE"))
                {
                    ISUBTYPE = CInt(mp_collParameters["ISUBTYPE"]);
                }

                bReturn = true;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
            }
            return bReturn;
        }

        //--inserisce  il documento nel dossier
        private bool PopolaDossier(SqlConnection conn, SqlTransaction trans, string strDocType, dynamic? strDocKey, ref string strDescrRetCode)
        {
            bool bReturn = false;
            int lIdMsg = 0;
            int iddcm = 0;
            string strNameMsg = string.Empty;
            string? strProtocol = string.Empty;
            int lIdDoc = 0;
            string strCause = string.Empty;

            try
            {
                // imposto il marketplace di default
                int lIdMp = 0;

                //--recupero le info di testata del documento
                strCause = $"recupero le info di testata del documento - SQL={Replace(mp_collParameters[QUERY_TESTATA], "<ID_DOC>", CStr(strDocKey))}";
                TSRecordSet rsTestata = cdf.GetRSReadFromQueryWithTransaction(Replace(mp_collParameters[QUERY_TESTATA], "<ID_DOC>", CStr(strDocKey)), conn.ConnectionString, conn, trans, iTimeout);

                if (!(rsTestata.EOF && rsTestata.BOF))
                {
                    rsTestata.MoveFirst();

                    if (cdf.FieldExistsInRS(rsTestata, "IDMP"))
                    {
                        lIdMp = CInt(rsTestata["IDMP"]!);
                    }
                    if (cdf.FieldExistsInRS(rsTestata, "Name"))
                    {
                        strNameMsg = CStr(rsTestata["Name"]);
                    }
                    if (cdf.FieldExistsInRS(rsTestata, "Protocol"))
                    {
                        strProtocol = CStr(rsTestata["Protocol"]);
                    }
                    if (cdf.FieldExistsInRS(rsTestata, "ID"))
                    {
                        lIdDoc = CInt(rsTestata["ID"]!);
                    }
                }
                else
                {
                    strDescrRetCode = $"testata documento vuota iddoc={CStr(strDocKey)}";
                    return bReturn;
                }

                //--recupero identificativo dalla document
                strCause = $"recupera IdDcm dalla tabella Documents per il documento con itype={ITYPE} - subtype={ISUBTYPE}";
                iddcm = GetIdDcm(CInt(ITYPE), CInt(ISUBTYPE), conn, trans);

                //--se il documento non è censito nella tabella document esco
                if (iddcm == -1)
                {
                    strDescrRetCode = $"documento non è censito nella tabella document itype={ITYPE} - subtype={ISUBTYPE}";
                    return bReturn;
                }

                //--controllo messaggio già presente nel dossier e lo cancello
                strCause = $"controllo messaggio già presente nel dossier e lo cancello iddcm={iddcm} - idcdo={lIdDoc}";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@Iddcm", iddcm);
                sqlParams.Add("@IdDoc", CStr(lIdDoc));

                string strSql = "select IdMsg from Messaggi where msgIdDcm=@Iddcm and msgIdCDO=@IdDoc";

                TSRecordSet rsDossier = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
                if (rsDossier.RecordCount > 0)
                {
                    rsDossier.MoveFirst();
                    lIdMsg = CInt(rsDossier["IdMsg"]!);

                    //--cancello il messaggio dal dossier se già presente
                    strCause = $"cancello il messaggio dal dossier se già presente idmsg={lIdMsg}";
                    DeleteMessageFromDossier(lIdMsg, conn, trans);
                }
                else
                {
                    //--inserimento riga fittizia nella TAB_MESSAGGI
                    strCause = "inserimento riga fittizia nella TAB_MESSAGGI";
                    lIdMsg = InsertTabMessaggi("", ITYPE, 0, lIdMp, -1, conn, trans);
                }

                //--Inserisce nella tabella Messaggi
                strCause = $"Inserimento riga nella tabella Messaggi relativa a idmsg={lIdMsg}";
                InsertDossierTabMessaggi(lIdMsg, strNameMsg, strProtocol, conn, trans, iddcm, lIdDoc);

                //--Inserisce nella tabella MessaggiUtenti
                strCause = $"Inserimento riga nella tabella MessaggiUtenti idmsg={lIdMsg}";

                long IdPfuMitt = -1;
                int IdPfuDest = -1;
                int idAziMitt = -1;
                int idAziDest = -1;

                if (rsTestata.Columns.Contains("Doc_Owner"))
                    IdPfuMitt = CLng(rsTestata["Doc_Owner"]!);

                if (rsTestata.Columns.Contains("AZI"))
                    idAziMitt = CInt(rsTestata["AZI"]!);

                if (rsTestata.Columns.Contains("AZI_Dest"))
                {
                    int idazi = CInt(rsTestata["AZI_Dest"]!);
                    if (idazi > 0)
                        idAziDest = idazi;
                }

                if (rsTestata.Columns.Contains("IdPfuDest"))
                {
                    int idpfu = CInt(rsTestata["IdPfuDest"]!);
                    if (idpfu > 0)
                        IdPfuDest = idpfu;
                }

                InsertDossierTabMessaggiUtenti(lIdMsg, conn, trans, IdPfuMitt, idAziMitt, IdPfuDest, idAziDest, lIdMp);

                #region 
                //--Carica in memoria gli attributi con appartenenza dossier ed i dati
                //             necessari per non accedere sempre al DB
                strCause = "caricamento in memoria dal dizionario degli attributi di tipo dossier (apatidapp=15 or apatidapp=14)";

                TSRecordSet rsAttribDossier = GetAttribDossierFromDB(conn, trans);

                //--Inserimento attributi di messaggio (TESTATA)

                Dictionary<string, ClsAttribDossier>? collAttrib = new Dictionary<string, ClsAttribDossier>();
                ClsAttribDossier cAttrib = new ClsAttribDossier();

                //--carica in una collezione gli attributi figli del nodo message, ovvero i campi pseudo XML
                strCause = $"caricamento in una collezione di memoria gli attributi di TESTATA idmsg={lIdMsg}";
                if (!(rsTestata.EOF && rsTestata.BOF))
                {
                    rsTestata.MoveFirst();
                    while (!rsTestata.EOF)
                    {
                        GetAttribDossierFromRS(rsTestata, collAttrib, ref strCause, conn, trans, rsAttribDossier, Apat_Dossier_Msg);

                        rsTestata.MoveNext();
                    }
                }

                //--inserisce nel DB gli attributi di testata caricati nella collezione ()
                //--array di 12 recordset
                int lIdArt = -1;
                //    Dim ind As Integer
                TSRecordSet[] vArrRs = new TSRecordSet[12];

                //--apertura recordset dossier
                strCause = "Apertura Rs di lavoro per il Dossier";
                OpenRSDossier(vArrRs, conn, trans);

                //--scrittura attributi di TESTATA
                strCause = $"inserimento nel dossier attributi di TESTATA per il messaggio idmsg={lIdMsg}";
                InsertAttribDossier(lIdMsg, collAttrib, conn, trans, ref strCause, vArrRs: vArrRs);

                collAttrib = new Dictionary<string, ClsAttribDossier>();

                //--Inserimento delle info di dettaglio (PRODOTTI)
                strCause = $"Inserimento delle info di DETTAGLIO per idmsg={lIdMsg} - SQL={Replace(mp_collParameters[QUERY_PRODOTTI], "<ID_DOC>", CStr(strDocKey))}";
                TSRecordSet rsDettagli = cdf.GetRSReadFromQueryWithTransaction(Replace(mp_collParameters[QUERY_PRODOTTI], "<ID_DOC>", CStr(strDocKey)), conn.ConnectionString, conn, trans, iTimeout);

                if (!(rsDettagli.EOF && rsDettagli.BOF))
                {
                    rsDettagli.MoveFirst();

                    while (!rsDettagli.EOF)
                    {
                        // BUG 24 luglio 2014 - distrugge la collezione altrimenti mette gli stessi valori su tutte
                        // le righe!!!
                        collAttrib = new Dictionary<string, ClsAttribDossier>();

                        strCause = $"caricamento in una collezione di memoria gli attributi di PRODOTTI idmsg={lIdMsg} ";
                        GetAttribDossierFromRS(rsDettagli, collAttrib, ref strCause, conn, trans, rsAttribDossier, Apat_Dossier_Msg_Articoli);

                        lIdArt = -1;
                        // cerca l'attributo idart altrimento inserisce con 0
                        if (cdf.FieldExistsInRS(rsDettagli, "IdRow"))
                        {
                            lIdArt = CInt(rsDettagli["IdRow"]!);
                        }

                        strCause = $"inserimento nel dossier attributi di DETTAGLIO per il messaggio idmsg={lIdMsg} - IdArt={lIdArt}";
                        InsertAttribDossier(lIdMsg, collAttrib, conn, trans, ref strCause, lIdArt, vArrRs);

                        rsDettagli.MoveNext();
                    }
                }
                #endregion

                //-- s.f. 04-06-2009 att.n. 21621
                //-- al termine del caricamento si popola la tabella con i dati da visualizzare nelle ricerche
                strCause = $"popola la tabella con i dati da visualizzare nelle ricerche idmsg={lIdMsg}";
                DOSSIER_Load_Messaggi_Dossier_View(-1, lIdMsg, conn, trans);

                bReturn = true;
                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.PopolaDossier", ex);
            }
        }

        private bool CheckCondition(SqlConnection conn, SqlTransaction trans, string strDocType, dynamic strDocKey, ref string strDescrRetCode)
        {
            bool bReturn = false;
            string str = string.Empty;
            string strSql = string.Empty;

            try
            {
                //-- controlla che sia stata configurata una condizione altrimenti esce
                try
                {
                    if (!mp_collParameters.ContainsKey(QUERY_CONDITION))
                    {
                        bReturn = true;
                        return bReturn;
                    }
                }
                catch
                {
                    bReturn = true;
                    return bReturn;
                }

                strSql = mp_collParameters[QUERY_CONDITION];
                strSql = Replace(strSql, "<ID_DOC>", CStr(strDocKey));

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction($"{GetSQLPrefixStatement()}{strSql}", conn.ConnectionString, conn, trans, iTimeout);

                bReturn = !(rs.EOF && rs.BOF);

                return bReturn;
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.CheckCondition", ex);
            }
        }

        private int GetIdDcm(dynamic nIType, dynamic nISubType, SqlConnection conn, SqlTransaction trans)
        {
            int dReturn = -1;

            try
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@nIType", CInt(nIType));
                sqlParams.Add("@nISubType", CInt(nISubType));

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select IdDcm from Document with(nolock) where dcmIType = @nIType and dcmIsubType = @nISubType and dcmDeleted=0", conn.ConnectionString, conn, trans, iTimeout, sqlParams);

                if (!(rs.EOF && rs.BOF))
                    dReturn = CInt(rs["iddcm"]!);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetIdDcm", ex);
            }

            return dReturn;
        }

        private void InsertDossierTabMessaggi(int lIdMsg, string? strName, string? strProtocol, SqlConnection conn, SqlTransaction? trans, dynamic? iddcm, dynamic? idcdo)
        {
            try
            {
                TSRecordSet rs = new TSRecordSet();

                /*rs = rs.OpenWithTransaction("SELECT TOP 0 * FROM Messaggi with(nolock)", conn, trans);
                DataRow dr = rs.AddNew();
                dr["IdMsg"] = lIdMsg;
                dr["msgIdDcm"] = iddcm;
                dr["msgName"] = strName;
                dr["msgProtocol"] = strProtocol;
                dr["msgIdCDO"] = idcdo;
                rs.Update(dr, "IdMsg", "Messaggi");*/

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@lIdMsg", lIdMsg);
                sqlParams.Add("@iddcm", iddcm);
                sqlParams.Add("@strName", strName);
                sqlParams.Add("@strProtocol", strProtocol);
                sqlParams.Add("@idcdo", idcdo);

                string strSQL = "INSERT INTO Messaggi( IdMsg, msgIdDcm, msgName, msgProtocol, msgIdCDO ) values ( @lIdMsg,@iddcm,@strName,@strProtocol,@idcdo )";
                cdf.ExecuteWithTransaction(strSQL, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".InsertDossierTabMessaggi", ex);
            }
        }

        private void InsertDossierTabMessaggiUtenti(int lIdMsg, SqlConnection conn, SqlTransaction trans, long IdPfuMitt, int idAziMitt, int IdPfuDest, int idAziDest, int lIdMp)
        {
            try
            {
                /*
                TSRecordSet rs = new TSRecordSet();
                rs = rs.OpenWithTransaction("SELECT TOP 0 * FROM MessaggiUtenti with(nolock)", conn, trans);

                DataRow dr = rs.AddNew();
                dr["muIdMsg"] = lIdMsg;

                // utente e azienda mittente
                if (IdPfuMitt > 0)
                {
                    dr["muIdPfuMitt"] = IdPfuMitt;
                    if (idAziMitt > 0)
                        dr["muIdAziMitt"] = idAziMitt;
                }
                // utente e azienda destinatari
                if (IdPfuDest > 0)
                    dr["muIdPfuDest"] = IdPfuDest;

                if (idAziDest > 0)
                    dr["muIdAziDest"] = idAziDest;

                // Market Place mittente e destinatario
                dr["muIdMpMitt"] = lIdMp;
                dr["muIdMpDest"] = 0;

                rs.Update(dr, "IdMsg", "MessaggiUtenti");
                */

                string strsql = @"INSERT INTO [dbo].[MessaggiUtenti]
                                           ([muIdMsg]
                                           ,[muIdPfuMitt]
                                           ,[muIdPfuDest]
                                           ,[muIdAziMitt]
                                           ,[muIdAziDest]
                                           ,[muIdMpMitt]
                                           ,[muIdMpDest])
                                     VALUES
                                           (@lIdMsg
                                           ,@IdPfuMitt
                                           ,@IdPfuDest
                                           ,@idAziMitt
                                           ,@idAziDest
                                           ,@lIdMp
                                           ,@muIdMpDest)";

                var sqlParams = new Dictionary<string, object?>();

                sqlParams.Add("@lIdMsg", lIdMsg);

                if (IdPfuMitt > 0)
                {
                    sqlParams.Add("@IdPfuMitt", IdPfuMitt);
                    if (idAziMitt > 0)
                        sqlParams.Add("@idAziMitt", idAziMitt);
                    else
                        sqlParams.Add("@idAziMitt", null);
                }
                else
                {
                    sqlParams.Add("@IdPfuMitt", null);
                    sqlParams.Add("@idAziMitt", null);
                }

                // utente e azienda destinatari
                if (IdPfuDest > 0)
                    sqlParams.Add("@IdPfuDest", IdPfuDest);
                else
                    sqlParams.Add("@IdPfuDest", null);

                if (idAziDest > 0)
                    sqlParams.Add("@idAziDest", idAziDest);
                else
                    sqlParams.Add("@idAziDest", null);

                // Market Place mittente e destinatario
                sqlParams.Add("@lIdMp", lIdMp);
                sqlParams.Add("@muIdMpDest", 0);

                cdf.ExecuteWithTransaction(strsql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".InsertDossierTabMessaggiUtenti", ex);
            }
        }

        private dynamic GetAttribDossierFromDB(SqlConnection conn, SqlTransaction trans)
        {
            try
            {
                // prende gli attributi di dossier non cancellati logicamente
                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select iddzt,dztnome,dztidtid,tidtipomem,tidtipodom,apatidapp from dizionarioattributi,tipidati,appartenenzaattributi where dztidtid=idtid and iddzt=apatiddzt and (apatidapp=15 or apatidapp=14) and dztdeleted=0", conn.ConnectionString, conn, trans, iTimeout);

                return rs;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetAttribDossierFromDB", ex);
            }
        }

        //DESC=recupera attributo dal recordset e lo inserisce nella collezione collAttrib
        public void GetAttribDossierFromRS(TSRecordSet RsAttrib, Dictionary<string, ClsAttribDossier>? collAttrib, ref string strCause, SqlConnection conn, SqlTransaction trans, TSRecordSet rsAttribDossier, int nApatAttrib = Apat_Dossier_Msg)
        {
            ClsAttribDossier attribDossier = new ClsAttribDossier();
            string dztName = string.Empty;

            try
            {
                if (IsNull(collAttrib))
                    collAttrib = new Dictionary<string, ClsAttribDossier>();

                // scorre i fields attributeValue figli del nodo input
                foreach (DataColumn objField in RsAttrib.Columns)
                {
                    // verifico che l'attributo non sia già presente nella collezione
                    // se si aggiorno solo il valore e non vado ancora sul DB
                    dztName = objField.ColumnName;
                    strCause = $"caricamento attributi field {dztName}";
                    if (CStr(RsAttrib[dztName]) is not null)
                    {
                        attribDossier = GetAttribDossier(dztName, CStr(RsAttrib[dztName]), ref strCause, rsAttribDossier, nApatAttrib);

                        if (attribDossier != null && !collAttrib.ContainsKey(dztName))
                        {
                            collAttrib.Add(dztName, attribDossier);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetAttribDossierFromRS", ex);
            }
        }

        private dynamic? GetAttribDossier(string dztName, dynamic value, ref string strCause, TSRecordSet rsAttribDossier, int nApatAttrib = Apat_Dossier_Msg)
        {
            try
            {
                ClsAttribDossier attribDossier = new ClsAttribDossier();

                //    Dim Description As String
                int tipoMem = 0;
                string tipoDom = string.Empty;
                int idtid = -1;
                int iddzt = 0;

                GetDatiAttribDossier(dztName, ref tipoMem, ref iddzt, ref tipoDom, ref idtid, rsAttribDossier, nApatAttrib);

                // se trovato nel dizionario e non è di tipo allegato
                if (iddzt > 0)
                {
                    // se l'appartenza è dossier lo carica altrimenti lo ignora
                    strCause = "caricamento attributi pseudoXML, field " + dztName + " verifica appartenza attributo";

                    attribDossier.iddzt = iddzt;
                    attribDossier.tipoMem = tipoMem;
                    attribDossier.tipoDom = tipoDom;
                    attribDossier.idtid = idtid;

                    attribDossier.Valore = value;

                    return attribDossier;
                }
                else //' se non trovato nel dizionario non lo carica
                {
                    return null;
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetAttribDossier", ex);
            }
        }

        private void GetDatiAttribDossier(string dztName, ref int tipoMem, ref int iddzt, ref string tipoDom, ref int idtid, TSRecordSet rsAttribDossier, int nApatAttrib = Apat_Dossier_Msg)
        {
            try
            {
                iddzt = -1;
                tipoMem = -1;
                tipoDom = string.Empty;
                idtid = -1;

                rsAttribDossier.Filter(string.Empty);

                if (!(rsAttribDossier.EOF && rsAttribDossier.BOF))
                {
                    rsAttribDossier.Filter($"dztnome='{dztName}' AND apatidapp={nApatAttrib}");

                    rsAttribDossier.Find($"dztnome='{dztName}'");
                    if (!rsAttribDossier.EOF)
                    {
                        rsAttribDossier.MoveFirst();
                        iddzt = CInt(rsAttribDossier["iddzt"]!);
                        tipoMem = CInt(rsAttribDossier["tidtipoMem"]!);
                        tipoDom = CStr(rsAttribDossier["tidtipodom"]);
                        idtid = CInt(rsAttribDossier["dztidtid"]!);
                    }
                }
                rsAttribDossier.Filter(string.Empty);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".GetDatiAttribDossier", ex);
            }
        }
        //Inserisce un record nella tabella TAB_MESSAGGI
        private int InsertTabMessaggi(string strText, int nMsgIType, int nMsgPriorita, int lMsgIdMP, int nElabWithSuccess, SqlConnection conn, SqlTransaction trans, string strIdCDO = "-1")
        {
            try
            {
                //imposta il recordset
                TSRecordSet rsMsg = new TSRecordSet();
                rsMsg = rsMsg.OpenWithTransaction("SELECT * FROM TAB_MESSAGGI with(nolock) WHERE IdMsg=-1", conn, trans, timeout: iTimeout);

                //aggiunge un nuovo record
                DataRow dr = rsMsg.AddNew();
                dr["MsgText"] = strText;
                dr["msgiType"] = nMsgIType;
                dr["msgPriorita"] = nMsgPriorita;
                dr["msgElabWithSuccess"] = nElabWithSuccess;
                dr["msgIdMP"] = lMsgIdMP;
                dr["msgIdCDO"] = strIdCDO;
                dr["msgiSubType"] = ISUBTYPE;
                EsitoTSRecordSet esito = rsMsg.Update(dr, "IdMsg", "TAB_MESSAGGI");

                //ritorna l'id del messaggio inserito
                return esito.id;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".InsertTabMessaggi", ex);
            }
        }

        private void OpenRSDossier(TSRecordSet[] vArrRs, SqlConnection conn, SqlTransaction trans)
        {
            int i = 0;
            TSRecordSet rsTemp;
            try
            {
                i = CInt(arrRsDossierPosition.indMSGValoriAttributi);
                rsTemp = new TSRecordSet();
                rsTemp = rsTemp.OpenWithTransaction("select top 0 * from MSGValoriAttributi with (nolock)", conn, trans, timeout: iTimeout);
                vArrRs[i] = rsTemp;

                i = CInt(arrRsDossierPosition.indMSGValoriAttributi_Datetime);
                rsTemp = new TSRecordSet();
                rsTemp = rsTemp.OpenWithTransaction("select top 0 * from MSGValoriAttributi_Datetime with (nolock)", conn, trans, timeout: iTimeout);
                vArrRs[i] = rsTemp;

                i = CInt(arrRsDossierPosition.indMSGValoriAttributi_Descrizioni);
                rsTemp = new TSRecordSet();
                rsTemp = rsTemp.OpenWithTransaction("select top 0 * from MSGValoriAttributi_Descrizioni with (nolock)", conn, trans, timeout: iTimeout);
                vArrRs[i] = rsTemp;

                i = CInt(arrRsDossierPosition.indMSGValoriAttributi_NVarchar);
                rsTemp = new TSRecordSet();
                rsTemp = rsTemp.OpenWithTransaction("select top 0 * from MSGValoriAttributi_NVarchar with (nolock)", conn, trans, timeout: iTimeout);
                vArrRs[i] = rsTemp;

                i = CInt(arrRsDossierPosition.indMSGVatMsg);
                rsTemp = new TSRecordSet();
                rsTemp = rsTemp.OpenWithTransaction("select top 0 * from MSGVatMsg with (nolock)", conn, trans, timeout: iTimeout);
                vArrRs[i] = rsTemp;

                //    SetRsWrite vArrRs(indMessaggiArticoli), cnLocal
                //    vArrRs(indMessaggiArticoli).Open "select top 0 * from MessaggiArticoli"

                //    SetRsWrite vArrRs(indMSGValoriAttributi), cnLocal
                //    vArrRs(indMSGValoriAttributi).Open "select top 0 * from MSGValoriAttributi"

                //    SetRsWrite vArrRs(indMSGVatArt), cnLocal
                //    vArrRs(indMSGVatArt).Open "select top 0 * from MSGVatArt"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Datetime), cnLocal
                //    vArrRs(indMSGValoriAttributi_Datetime).Open "select top 0 * from MSGValoriAttributi_Datetime"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Descrizioni), cnLocal
                //    vArrRs(indMSGValoriAttributi_Descrizioni).Open "select top 0 * from MSGValoriAttributi_Descrizioni"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Image), cnLocal
                //    vArrRs(indMSGValoriAttributi_Image).Open "select top 0 * from MSGValoriAttributi_Image"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Int), cnLocal
                //    vArrRs(indMSGValoriAttributi_Int).Open "select top 0 * from MSGValoriAttributi_Int"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Keys), cnLocal
                //    vArrRs(indMSGValoriAttributi_Keys).Open "select top 0 * from MSGValoriAttributi_Keys"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Money), cnLocal
                //    vArrRs(indMSGValoriAttributi_Money).Open "select top 0 * from MSGValoriAttributi_Money"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_NVarchar), cnLocal
                //    vArrRs(indMSGValoriAttributi_NVarchar).Open "select top 0 * from MSGValoriAttributi_NVarchar"

                //    SetRsWrite vArrRs(indMSGValoriAttributi_Float), cnLocal
                //    vArrRs(indMSGValoriAttributi_Float).Open "select top 0 * from MSGValoriAttributi_Float"

                //    SetRsWrite vArrRs(indMSGVatMsg), cnLocal
                //    vArrRs(indMSGVatMsg).Open "select top 0 * from MSGVatMsg"
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".OpenRSDossier", ex);
            }
        }


        private void InsertAttribDossier(int lIdMsg, Dictionary<string, ClsAttribDossier>? collAttrib, SqlConnection conn, SqlTransaction trans, ref string strCause, int lIdArt = -2, dynamic? vArrRs = null)
        {
            //    On Error GoTo err


            //clsAttribDossier attribDossier = new clsAttribDossier();
            //    Dim s As String
            TSRecordSet rsMSGValoriAttributi = new TSRecordSet();
            TSRecordSet rsMSGValoriAttributi_Datetime = new TSRecordSet();
            //    Dim rsMSGValoriAttributi_Float As adodb.Recordset
            TSRecordSet rsMSGValoriAttributi_Descrizioni = new TSRecordSet();
            //    Dim rsMSGValoriAttributi_Image As adodb.Recordset
            //    Dim rsMSGValoriAttributi_Int As adodb.Recordset
            //    Dim rsMSGValoriAttributi_Keys As adodb.Recordset
            //    Dim rsMSGValoriAttributi_Money As adodb.Recordset
            TSRecordSet rsMSGValoriAttributi_NVarchar = new TSRecordSet();
            //    Dim rsMSGVatArt As adodb.Recordset
            TSRecordSet rsMSGVatMsg = new TSRecordSet();
            //    Dim rsMessaggiArticoli As adodb.Recordset
            //    Dim lIdVat As Long
            //    Dim bOpen As Boolean

            if (collAttrib == null)
                return;

            // se i recordset sono stati passati in input non li apre
            bool bOpen = (vArrRs == null);
            //    If Not IsMissing(vArrRs) Then
            //        bOpen = False
            //    End If

            string s = "Inserimento attributi di messaggio - ";
            // se la collection è non vuota apre i recorset
            // o se sono passati in input usa quelli aperti dal chiamante
            if (collAttrib.Count > 0)
            {
                //        If lIdArt<> -2 Then
                //            s = "Inserimento attributi di articolo - "
                //            ' inserimento nella tabella MessaggiArticoli
                //            If bOpen Then
                //                SetRsWrite rsMessaggiArticoli, cnLocal
                //                rsMessaggiArticoli.Open "select top 0 * from MessaggiArticoli"
                //            Else
                //                Set rsMessaggiArticoli = vArrRs(indMessaggiArticoli)
                //            End If
                //            rsMessaggiArticoli.AddNew
                //            rsMessaggiArticoli.Collect("maidmsg") = lIdMsg
                //            rsMessaggiArticoli.Collect("maidart") = lIdArt
                //            rsMessaggiArticoli.Update
                //            If bOpen Then
                //                CloseRecordset rsMessaggiArticoli
                //            End If
                //        End If
            }

            // se la collection è non vuota apre i recorset
            // o se sono passati in input usa quelli aperti dal chiamante
            if (collAttrib.Count > 0)
            {
                if (bOpen)
                {
                    //            SetRsWrite rsMSGValoriAttributi, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Datetime, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Descrizioni, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Image, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Int, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Keys, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Money, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_NVarchar, cnLocal
                    //            SetRsWrite rsMSGValoriAttributi_Float, cnLocal

                    //            rsMSGValoriAttributi.Open "select top 0 * from MSGValoriAttributi"
                    //            rsMSGValoriAttributi_Datetime.Open "select top 0 * from MSGValoriAttributi_Datetime"
                    //            rsMSGValoriAttributi_Descrizioni.Open "select top 0 * from MSGValoriAttributi_Descrizioni"
                    //            rsMSGValoriAttributi_Image.Open "select top 0 * from MSGValoriAttributi_Image"
                    //            rsMSGValoriAttributi_Int.Open "select top 0 * from MSGValoriAttributi_Int"
                    //            rsMSGValoriAttributi_Keys.Open "select top 0 * from MSGValoriAttributi_Keys"
                    //            rsMSGValoriAttributi_Money.Open "select top 0 * from MSGValoriAttributi_Money"
                    //            rsMSGValoriAttributi_NVarchar.Open "select top 0 * from MSGValoriAttributi_NVarchar"
                    //            rsMSGValoriAttributi_Float.Open "select top 0 * from MSGValoriAttributi_Float"
                }
                else
                {
                    int i = CInt(arrRsDossierPosition.indMSGValoriAttributi);
                    rsMSGValoriAttributi = vArrRs[i];
                    //            Set rsMSGValoriAttributi_Datetime = vArrRs(indMSGValoriAttributi_Datetime)
                    i = CInt(arrRsDossierPosition.indMSGValoriAttributi_Descrizioni);
                    rsMSGValoriAttributi_Descrizioni = vArrRs[i];
                    //            Set rsMSGValoriAttributi_Image = vArrRs(indMSGValoriAttributi_Image)
                    //            Set rsMSGValoriAttributi_Int = vArrRs(indMSGValoriAttributi_Int)
                    //            Set rsMSGValoriAttributi_Keys = vArrRs(indMSGValoriAttributi_Keys)
                    //            Set rsMSGValoriAttributi_Money = vArrRs(indMSGValoriAttributi_Money)
                    i = CInt(arrRsDossierPosition.indMSGValoriAttributi_NVarchar);
                    rsMSGValoriAttributi_NVarchar = vArrRs[i];
                    //            Set rsMSGValoriAttributi_Float = vArrRs(indMSGValoriAttributi_Float)
                }
            }


            if (lIdArt! > -2) // inserimento attributi di articolo
            {
                //            If bOpen Then
                //                SetRsWrite rsMSGVatArt, cnLocal
                //                rsMSGVatArt.Open "select top 0 * from MSGVatArt"
                //            Else
                //                Set rsMSGVatArt = vArrRs(indMSGVatArt)
                //            End If
            }
            else                    // inserimento attributi di messaggio
            {
                if (bOpen)
                {
                    //                SetRsWrite rsMSGVatMsg, cnLocal
                    //                rsMSGVatMsg.Open "select top 0 * from MSGVatMsg"
                }
                else
                {
                    int i = CInt(arrRsDossierPosition.indMSGVatMsg);
                    rsMSGVatMsg = vArrRs[i];
                }
            }

            // ciclo sugli attributi
            foreach (KeyValuePair<string, ClsAttribDossier> attribDossier in collAttrib)
            {
                string[]? ss = null;
                strCause = s + "inserimento attributo " + attribDossier.Value.dztName;
                // se gerarchico può essere multivalore
                if (attribDossier.Value.tipoDom?.ToString().ToUpper() == "G")
                {
                    string seq = (attribDossier.Value.Valore?.Contains("#~")) ? "#~" : "#";
                    ss = attribDossier.Value.Valore?.Split(seq);

                    foreach (string item in ss)
                    {
                        if (item.Length > 0)
                            InsertAttributeDossier(conn, trans, rsMSGValoriAttributi, rsMSGVatMsg, null, rsMSGValoriAttributi_Datetime, rsMSGValoriAttributi_Descrizioni, null, null, null, null, rsMSGValoriAttributi_NVarchar, null, lIdMsg, ref strCause, attribDossier.Value, item, lIdArt);
                    }
                }
                else
                    InsertAttributeDossier(conn, trans, rsMSGValoriAttributi, rsMSGVatMsg, null, rsMSGValoriAttributi_Datetime, rsMSGValoriAttributi_Descrizioni, null, null, null, null, rsMSGValoriAttributi_NVarchar, null, lIdMsg, ref strCause, attribDossier.Value, attribDossier.Value.Valore, lIdArt);
            }

            //    Set c = Nothing
            //    ' chiusura RS se necessario
            //    If collAttrib.count > 0 Then
            //        If bOpen Then
            //            CloseRecordset rsMSGValoriAttributi
            //            CloseRecordset rsMSGValoriAttributi_Datetime
            //            CloseRecordset rsMSGValoriAttributi_Descrizioni
            //            CloseRecordset rsMSGValoriAttributi_Image
            //            CloseRecordset rsMSGValoriAttributi_Int
            //            CloseRecordset rsMSGValoriAttributi_Keys
            //            CloseRecordset rsMSGValoriAttributi_Money
            //            CloseRecordset rsMSGValoriAttributi_NVarchar
            //            CloseRecordset rsMSGValoriAttributi_Float
            //        End If
            //        If lIdArt <> -2 Then        'attributi di articolo
            //            If bOpen Then
            //                CloseRecordset rsMSGVatArt
            //            End If
            //        Else                        'attributi di messaggio
            //            If bOpen Then
            //                CloseRecordset rsMSGVatMsg
            //            End If
            //        End If
            //    End If

            //fine:
            //    ' pulizia memoria (in ogni caso)
            //    Set rsMSGValoriAttributi = Nothing
            //    Set rsMSGValoriAttributi_Datetime = Nothing
            //    Set rsMSGValoriAttributi_Descrizioni = Nothing
            //    Set rsMSGValoriAttributi_Image = Nothing
            //    Set rsMSGValoriAttributi_Int = Nothing
            //    Set rsMSGValoriAttributi_Keys = Nothing
            //    Set rsMSGValoriAttributi_Money = Nothing
            //    Set rsMSGValoriAttributi_Float = Nothing
            //    Set rsMSGValoriAttributi_NVarchar = Nothing
            //    Set rsMSGVatArt = Nothing
            //    Set rsMSGVatMsg = Nothing
            //    Set rsMessaggiArticoli = Nothing


            //    Exit Sub
            //err:
            //    Set c = Nothing
            //    Set rsMSGValoriAttributi = Nothing
            //    Set rsMSGValoriAttributi_Datetime = Nothing
            //    Set rsMSGValoriAttributi_Descrizioni = Nothing
            //    Set rsMSGValoriAttributi_Image = Nothing
            //    Set rsMSGValoriAttributi_Int = Nothing
            //    Set rsMSGValoriAttributi_Keys = Nothing
            //    Set rsMSGValoriAttributi_Money = Nothing
            //    Set rsMSGValoriAttributi_Float = Nothing
            //    Set rsMSGValoriAttributi_NVarchar = Nothing
            //    Set rsMSGVatArt = Nothing
            //    Set rsMSGVatMsg = Nothing
            //    Set rsMessaggiArticoli = Nothing


            //    err.Raise err.Number, err.Source, err.Description
        }

        private void CloseRSDossier(TSRecordSet vArrRs)
        {

            //    On Error GoTo err
            //    Dim i As Integer


            //    For i = indMessaggiArticoli To indMSGVatMsg
            //        CloseRecordset vArrRs(i)
            //    Next i


            //    Exit Sub


            //err:
            //    err.Raise err.Number, err.Source, err.Description
        }

        private void InsertAttributeDossier(SqlConnection conn, SqlTransaction trans, TSRecordSet rsMSGValoriAttributi, TSRecordSet rsMSGVatMsg, TSRecordSet rsMSGVatArt, TSRecordSet rsMSGValoriAttributi_Datetime, TSRecordSet rsMSGValoriAttributi_Descrizioni, TSRecordSet rsMSGValoriAttributi_Image, TSRecordSet rsMSGValoriAttributi_Int, TSRecordSet rsMSGValoriAttributi_Keys, TSRecordSet rsMSGValoriAttributi_Money, TSRecordSet rsMSGValoriAttributi_NVarchar, TSRecordSet rsMSGValoriAttributi_Float, int lIdMsg, ref string strCause, ClsAttribDossier attribDossier, dynamic valore, int lIdArt = -2)
        {
            try
            {
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    inserisce prima sulla ValoriAttributi
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                DataRow dr = rsMSGValoriAttributi.AddNew();
                dr["vatTipoMem"] = CInt(attribDossier.tipoMem);
                dr["vatIdDzt"] = CInt(attribDossier.iddzt);
                if (!string.IsNullOrEmpty(CStr(attribDossier.idUMS)) && IsNumeric(attribDossier.idUMS) && attribDossier.idUMS > 0)
                    dr["vatIdUms"] = CInt(attribDossier.idUMS);
                dr["vatUltimaMod"] = DateTime.Now;
                EsitoTSRecordSet esito = rsMSGValoriAttributi.Update(dr, "IdVat", "MSGValoriAttributi");
                // preleva l'IDVAT
                int lIdVat = esito.id;
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    inserisce sulla VatArt o sulla VatMSG a seconda se
                //    attributo di articolo o di messaggio
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                if (lIdArt! > -2)
                {
                    //        ' attributo di articolo
                    //        ' inserisce nella VatArt
                    //        rsMSGVatArt.AddNew
                    //        rsMSGVatArt.Collect("idart") = lIdArt
                    //        rsMSGVatArt.Collect("idmsg") = lIdMsg
                    //        rsMSGVatArt.Collect("idvat") = lIdVat
                    //        rsMSGVatArt.Update
                }
                else
                {
                    // attributo di messaggio
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@IdVat", lIdVat);
                    sqlParams.Add("@IdMsg", lIdMsg);

                    string strSQL = "INSERT INTO MSGVatMsg (IdVat, IdMsg) VALUES (@IdVat, @IdMsg)";
                    cdf.ExecuteWithTransaction(strSQL, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
                }
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //    inserisce il valore in base a tipoMem,tipoDOM
                //    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                InsertValueAttribDossier(conn, trans, rsMSGValoriAttributi_Datetime, rsMSGValoriAttributi_Descrizioni, rsMSGValoriAttributi_Image, rsMSGValoriAttributi_Int, rsMSGValoriAttributi_Keys, rsMSGValoriAttributi_Money, rsMSGValoriAttributi_NVarchar, rsMSGValoriAttributi_Float, lIdVat, attribDossier.tipoMem, valore, attribDossier.idUMS, ref strCause);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".InsertAttributeDossier", ex);
            }
        }

        private void InsertValueAttribDossier(SqlConnection conn, SqlTransaction trans, TSRecordSet? rsMSGValoriAttributi_Datetime, TSRecordSet? rsMSGValoriAttributi_Descrizioni, TSRecordSet? rsMSGValoriAttributi_Image, TSRecordSet? rsMSGValoriAttributi_Int, TSRecordSet? rsMSGValoriAttributi_Keys, TSRecordSet? rsMSGValoriAttributi_Money, TSRecordSet? rsMSGValoriAttributi_NVarchar, TSRecordSet? rsMSGValoriAttributi_Float, int lIdVat, dynamic tipoMem, dynamic valore, dynamic idUMS, ref string strCause)
        {
            try
            {
                var sqlParams = new Dictionary<string, object?>();

                switch (tipoMem)
                {
                    //Case 1      'INT
                    //    iVal = 0
                    //    If Not IsNull(valore) Then
                    //        If Len(valore) > 0 Then
                    //            If IsNumeric(valore) Then
                    //                iVal = CLng(valore)
                    //            End If
                    //        End If
                    //    End If
                    //    rsMSGValoriAttributi_Int.AddNew
                    //    rsMSGValoriAttributi_Int.Collect("idvat") = lIdVat
                    //    rsMSGValoriAttributi_Int.Collect("vatvalore") = iVal
                    //    rsMSGValoriAttributi_Int.Update
                    //            rsMSGValoriAttributi_Int.AddNew
                    //            rsMSGValoriAttributi_Int.Collect("idvat") = lIdVat
                    //            rsMSGValoriAttributi_Int.Collect("vatvalore") = iVal
                    //            rsMSGValoriAttributi_Int.Update
                    //        Case 2      'MONEY
                    //            dVal = 0
                    //            If Not IsNull(valore) Then
                    //                If Len(valore) > 0 Then
                    //                    'valore = Replace(valore, ".", m_strDecimalSep)
                    //                    If IsNumeric(valore) Then
                    //                        dVal = CDbl(valore)
                    //                    End If
                    //                End If
                    //            End If
                    //            rsMSGValoriAttributi_Money.AddNew
                    //            rsMSGValoriAttributi_Money.Collect("idvat") = lIdVat
                    //            rsMSGValoriAttributi_Money.Collect("vatvalore") = dVal
                    //            If Len(idUMS) > 0 Then
                    //                If IsNumeric(idUMS) Then
                    //                    rsMSGValoriAttributi_Money.Collect("vatidsdv") = idUMS
                    //                End If
                    //            End If
                    //            rsMSGValoriAttributi_Money.Update
                    //        Case 3      'FLOAT
                    //            dVal = 0
                    //            If Not IsNull(valore) Then
                    //                If Len(valore) > 0 Then
                    //                    'valore = Replace(valore, ".", m_strDecimalSep)
                    //                    If IsNumeric(valore) Then
                    //                        dVal = CDbl(valore)
                    //                    End If
                    //                End If
                    //            End If
                    //            rsMSGValoriAttributi_Float.AddNew
                    //            rsMSGValoriAttributi_Float.Collect("idvat") = lIdVat
                    //            rsMSGValoriAttributi_Float.Collect("vatvalore") = dVal
                    //            rsMSGValoriAttributi_Float.Update
                    case 4:      //NVARCHAR
                        string ss = string.Empty;
                        if (!IsNull(valore))
                            ss = CStr(valore);

                        sqlParams.Clear();
                        sqlParams.Add("@IdVat", lIdVat);
                        sqlParams.Add("@vatValore", ss);

                        string strSQL = "INSERT INTO MSGValoriAttributi_Nvarchar (IdVat, vatValore) VALUES (@IdVat, @vatValore)";
                        cdf.ExecuteWithTransaction(strSQL, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

                        break;

                    case 5:      //DATETIME

                        //if (valore is null)
                        //{
                        //    sqlParams.Add("@vatValore", null);
                        //}
                        //else if (valore is string && string.IsNullOrEmpty(valore))
                        //{
                        //    sqlParams.Add("@vatValore", null);
                        //}
                        //else
                        if (!string.IsNullOrEmpty(CStr(valore)))
                        {
                            sqlParams!.Clear();
                            sqlParams.Add("@IdVat", lIdVat);
                            sqlParams.Add("@vatValore", CDate(valore));
                            strSQL = "INSERT INTO MSGValoriAttributi_Datetime (IdVat, vatValore) VALUES (@IdVat, @vatValore)";
                            cdf.ExecuteWithTransaction(strSQL, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
                        }

                        break;
                    case 6:      //DESCRIZIONI
                        try
                        {
                            if (CStr(valore) != "")
                            {
                                sqlParams.Clear();
                                sqlParams.Add("@IdVat", lIdVat);
                                sqlParams.Add("@vatIdDsc", CInt(valore));

                                strSQL = "INSERT INTO MSGValoriAttributi_Descrizioni (IdVat, vatIdDsc) VALUES (@IdVat, @vatIdDsc)";
                                cdf.ExecuteWithTransaction(strSQL, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
                            }
                        }
                        catch { }

                        break;
                    //        Case 7      'KEYS
                    //            rsMSGValoriAttributi_Keys.AddNew
                    //            rsMSGValoriAttributi_Keys.Collect("idvat") = lIdVat
                    //            rsMSGValoriAttributi_Keys.Collect("vatvalore") = valore
                    //            rsMSGValoriAttributi_Keys.Update
                    //        Case 8      'IMAGE
                    //            rsMSGValoriAttributi_Image.AddNew
                    //            rsMSGValoriAttributi_Image.Collect("idvat") = lIdVat
                    //            rsMSGValoriAttributi_Image.Collect("vatvalore") = valore
                    //            rsMSGValoriAttributi_Image.Update
                    default:
                        strCause = "tipo mem invalido!";

                        break;
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.InsertValueAttributeDossier", ex);
            }
        }

        private void DeleteMessageFromDossier(int lIdMsgCurrent, SqlConnection conn, SqlTransaction trans)
        {
            string strCause = $"CHIAMATA STORED X ELEMINAZIONE DEI MESSAGGI DA RIELABORARE (sp_DeleteMsgDossier) idmsg={lIdMsgCurrent}";

            try
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@IdMsgCurrent", lIdMsgCurrent);

                string strSql = "exec sp_DeleteMsgDossier @IdMsgCurrent";
                cdf.ExecuteWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message}-{strCause} - FUNZIONE : {MODULE_NAME}.DeleteMessageFromDossier", ex);
            }
        }

        private void Class_Initialize()
        {
            ITYPE = 1000;
            ISUBTYPE = -1;
        }

        private void DOSSIER_Load_Messaggi_Dossier_View(int idPfu, int idMsg, SqlConnection conn, SqlTransaction trans)
        {
            string strCause = "Inserimento righe in Messaggi_Dossier_View";

            try
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@IdPfu", idPfu);
                sqlParams.Add("@IdMsg", idMsg);

                string SQL = "exec  DOSSIER_Load_Messaggi_Dossier_View @IdPfu , @IdMsg";
                cdf.ExecuteWithTransaction(SQL, conn.ConnectionString, conn, trans, iTimeout, sqlParams);
            }
            catch (Exception ex)
            {
                throw new Exception($"{ex.Message}-{strCause} - FUNZIONE : {MODULE_NAME}.DOSSIER_Load_Messaggi_Dossier_View", ex);
            }
        }

        public class ClsAttribDossier
        {
            public string dztName = string.Empty;
            public dynamic? iddzt = null;
            public dynamic? tipoMem = null;
            public dynamic? idUMS = null;
            public dynamic? Valore = null;
            public dynamic? idtid = null;
            public dynamic? tipoDom = null;
        }
    }
}
