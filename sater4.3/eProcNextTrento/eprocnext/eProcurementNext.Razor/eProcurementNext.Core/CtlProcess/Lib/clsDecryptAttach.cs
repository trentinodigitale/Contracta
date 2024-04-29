using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using System.Data.SqlClient;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsDecryptAttach : ProcessBase
    {
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();

        private const string MODULE_NAME = "CtlProcess.ClsDecryptAttach";

        long mp_lIdPfu = 0;
        string mp_IDDoc = string.Empty;
        string percorsoFile = string.Empty;
        string fileDecifrato = string.Empty;
        private int iTimeout = -1;

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            try
            {
                strDescrRetCode = string.Empty;
                mp_lIdPfu = lIdPfu;

                // Apertura connessione
                strCause = "Apertura connessione al DB";
                cnLocal = SetConnection(connection, cdf);

                if (!string.IsNullOrEmpty(CStr(strDocKey)))
                {
                    string keyAttach = string.Empty;
                    string[] aInfo;
                    string strGUID = string.Empty;
                    string strSql = string.Empty;
                    string pathDirectory = string.Empty;
                    string strTmpFileName = string.Empty;
                    int attIdRow = 0;
                    string erroreCifratura = string.Empty;

                    strCause = "Decifro la chiave";
                    keyAttach = decifraChiave(CStr(strDocKey), cnLocal, transaction);

                    if (!string.IsNullOrEmpty(keyAttach) && keyAttach.Contains('*', StringComparison.Ordinal))
                    {
                        aInfo = keyAttach.Split("*");

                        //--recupero guid
                        strGUID = aInfo[3];

                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@Att_hash", strGUID);

                        strSql = "select ATT_IdRow,att_hash,ATT_Cifrato from ctl_attach with(nolock) where att_hash = @Att_hash";

                        strCause = "select per il recupero dell'allegato";
                        TSRecordSet rsAttach = new TSRecordSet();
                        rsAttach = rsAttach.OpenWithTransaction(strSql, cnLocal, transaction, sqlParams, iTimeout);

                        if (rsAttach.RecordCount > 0)
                        {
                            strCause = "Controllo se si è alzato in maniera corretta l'allegato di 'in corso di decifratura'";

                            //-- se l'allegato è 'in corso di decifratura'
                            if (CStr(rsAttach["ATT_Cifrato"]) == "2")
                            {
                                try
                                {
                                    strCause = "Recupero il valore della colonna ATT_IdRow";
                                    attIdRow = CInt(rsAttach["ATT_IdRow"]!);

                                    strCause = "genero il nome file temporaneo";
                                    strTmpFileName = CommonStorage.GetTempName();

                                    strCause = "recupero la directory di lavoro";
                                    pathDirectory = getPathFolderAllegati(cnLocal, transaction);

                                    percorsoFile = $"{pathDirectory}{strTmpFileName}";
                                    fileDecifrato = $"{pathDirectory}{CommonStorage.GetTempName()}";

                                    strCause = "salvo su disco l'attach";

                                    saveFileFromRecordSet("ATT_Obj", "CTL_Attach", "ATT_IdRow", attIdRow, percorsoFile, cnLocal, transaction);

                                    strCause = "decifro il file";

                                    //-- decifro il file
                                    erroreCifratura = cifraFile(percorsoFile, fileDecifrato, mp_IDDoc, false, cnLocal, lIdPfu, transaction);

                                    //-- se non ci sono stati errori nel processo di decifratura
                                    if (string.IsNullOrEmpty(erroreCifratura))
                                    {
                                        strCause = "salvo il file decifrato sul db";

                                        //-- salvo il file decifrato sul db
                                        SaveToRecordset("ATT_Obj", "Ctl_Attach", "ATT_IdRow", attIdRow, fileDecifrato, cnLocal.ConnectionString);

                                        strCause = "cambio lo stato all'attach";

                                        //-- cambio il flag dell'allegato a 'non cifrato'
                                        rsAttach.Fields!["ATT_Cifrato"] = 0;

                                        rsAttach.Update(rsAttach.Fields, "ATT_IdRow", "Ctl_Attach");

                                        strCause = "cancello la richiesta di decrypt";

                                        //-- cancello il record dalla tabella di richiesta decifratura file
                                        sqlParams.Clear();
                                        sqlParams.Add("@DocKey", CInt(strDocKey));

                                        strSql = "delete from CTL_DECRYPT_ATTACH where id = @DocKey";
                                        cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                                        strCause = "rimuovo il record backup dell'allegato";

                                        //-- non servendo più, rimuovo il record backup dell'allegato
                                        sqlParams.Clear();
                                        sqlParams.Add("@Att_idRow", CInt(attIdRow));

                                        strSql = "DELETE FROM CTL_Encrypted_Attach where att_idRow = @Att_idRow";
                                        cdf.ExecuteWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
                                    }
                                    else
                                    {
                                        throw new Exception($"{erroreCifratura} - FUNZIONE : {MODULE_NAME}.Elaborate");
                                    }

                                }
                                finally
                                {
                                    cancellaFiles();
                                }


                            }
                            else
                            {
                                cdf.ExecuteWithTransaction("insert into CTL_LOG_UTENTE ( paginaDiArrivo, querystring, datalog ) values( 'ATTACH-ERRORE-CIFRATURA' , 'ATT_cifrato non coerente con la richiesta di decifratura' , getdate() )", cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                                throw new Exception($"ATT_cifrato non coerente con la richiesta di decifratura - FUNZIONE : {MODULE_NAME}.Elaborate");
                            }
                        }
                        else
                        {
                            cdf.ExecuteWithTransaction("insert into CTL_LOG_UTENTE ( paginaDiArrivo, querystring, datalog ) values( 'ATTACH-ERRORE-CIFRATURA' , 'Allegato non trovato in base dati' , getdate() )", cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                            throw new Exception($"Allegato non trovato in base dati - FUNZIONE : {MODULE_NAME}.Elaborate");
                        }
                    }

                    else
                    {
                        cdf.ExecuteWithTransaction("insert into CTL_LOG_UTENTE ( paginaDiArrivo, querystring, datalog ) values( 'ATTACH-ERRORE-CIFRATURA' , 'Errore nella generazione della chiave' , getdate() )", cnLocal.ConnectionString, cnLocal, transaction, iTimeout);
                        throw new Exception($"Errore nella generazione della chiave - FUNZIONE : {MODULE_NAME}.Elaborate");
                    }
                }

                strReturn = ELAB_RET_CODE.RET_CODE_OK;

                return strReturn;
            }
            catch (Exception ex)
            {
                TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }

        }

        private string decifraChiave(string Id, SqlConnection conn, SqlTransaction trans)
        {
            string strReturn = string.Empty;

            string strSql = string.Empty;
            //    Dim rs As New ADODB.Recordset
            string chiave;

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ParamID", CInt(Id));

            strSql = $"declare @KeyCrypt varchar(200){Environment.NewLine}";
            strSql = $"{strSql}declare @KeyName varchar(200){Environment.NewLine}";
            strSql = $"{strSql}declare @SQLCrypt varchar(max){Environment.NewLine}";
            strSql = $"{strSql}declare @ID_DOC int{Environment.NewLine}";
            strSql = $"{strSql}declare @id int{Environment.NewLine}";

            strSql = $"{strSql}set @id = @ParamID{Environment.NewLine}";

            strSql = $"{strSql}select @ID_DOC = idX from CTL_DECRYPT_ATTACH with(nolock) where id = @id{Environment.NewLine}";

            strSql = $"{strSql}select  @KeyCrypt = reverse( substring(  cast( [GUID] as varchar(100)) ,  id % 33  + 2 + 2, 36))  + substring(  cast( [GUID] as varchar(100)) , 2 , id % 33 + 2) ,{Environment.NewLine}";
            strSql = $"{strSql}  @KeyName = + reverse( substring( cast( [GUID] as varchar(100)) ,  id % 6 , 5 ) + cast( id as varchar(10))){Environment.NewLine}";
            strSql = $"{strSql}  from ctl_doc with(nolock) where id = @ID_DOC{Environment.NewLine}";

            strSql = $"{strSql}set @KeyCrypt =  convert(varchar(200) ,  HASHBYTES( 'MD5' , @KeyCrypt ) , 2 ) + '-' + convert( varchar(200) ,  HASHBYTES( 'SHA1' , @KeyCrypt ) ,2){Environment.NewLine}";
            strSql = $"{strSql}set @KeyName ='KEY_' + convert(varchar(200) ,  HASHBYTES( 'SHA1' , @KeyName )  ,2){Environment.NewLine}";

            strSql = $"{strSql}set @SQLCrypt = 'OPEN SYMMETRIC KEY ' + @KeyName + ' DECRYPTION BY  PASSWORD = ''' + @KeyCrypt + ''' '{Environment.NewLine}";
            strSql = $"{strSql}exec( @SQLCrypt ){Environment.NewLine}";

            strSql = $"{strSql}select cast( DecryptByKey( keyFile ) as nvarchar(1000)) as keyFile, idX as idDoc from CTL_DECRYPT_ATTACH with(nolock) where id = @id{Environment.NewLine}";

            TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

            if (rs.RecordCount > 0)
            {
                rs.MoveFirst();
                chiave = CStr(rs["keyFile"]);
                mp_IDDoc = CStr(rs["idDoc"]);

                strReturn = chiave;
            }
            else
                throw new Exception("Errore nel recupero della chiave allegato decifrata - FUNZIONE : " + MODULE_NAME + ".Elaborate");

            return strReturn;
        }

        private string getPathFolderAllegati(SqlConnection conn, SqlTransaction? trans)
        {
            string strReturn = string.Empty;

            strReturn = ConfigurationServices.GetKey("ApplicationContext:PathFolderAllegati", "")!;

            if (string.IsNullOrEmpty(strReturn))
            {
                string strSql = "select dzt_valuedef from lib_dictionary with(nolock) where dzt_name = 'SYS_PathFolderAllegati'";

                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout);

                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();
                    strReturn = CStr(rs["dzt_valuedef"]);   //-- Recupero il path della directory allegati
                }
                else
                    throw new Exception("Manca SYS SYS_PathFolderAllegati - FUNZIONE : " + MODULE_NAME + ".Elaborate");
            }

            return strReturn;
        }

        private void cancellaFiles()
        {
            try
            {
                if (Len(Trim(percorsoFile)) > 0 && CommonStorage.FileExists(percorsoFile))
                    CommonStorage.DeleteFile(percorsoFile);

                if (Len(Trim(fileDecifrato)) > 0 && CommonStorage.FileExists(fileDecifrato))
                    CommonStorage.DeleteFile(fileDecifrato);
            }
            catch { }
        }
    }
}
