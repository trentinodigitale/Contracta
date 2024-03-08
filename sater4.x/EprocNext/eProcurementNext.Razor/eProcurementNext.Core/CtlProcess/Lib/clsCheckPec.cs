using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    internal class ClsCheckPec : ProcessBase
    {

        private string mp_strTableName = "";
        private string mp_strFieldIDName = "";
        private Dictionary<string, string>? mp_collParameters = null!;

        private const string MODULE_NAME = "CtlProcess.ClsCheckPec";

        private string mp_DocType = "";
        private int mp_BlockOnNoPec = 0;
        private string mp_MsgPecKo = "";
        private string mp_MsgPecWait = "";
        private string mp_ProcessName = "";
        private readonly CommonDbFunctions cdf = new CommonDbFunctions();
        private readonly DebugTrace dt = new();
        private int iTimeout = -1;

        //'LIST_FIELDS#=#nuovo_dztname;;vecchio_dztname,, .........
        //' ad esempio:
        //'LIST_FIELDS#=#RDA_Protocol;;RDA_Protocol
        //'FORMAT#=#0 se =0 oppure non esiste allora applico la formattazione altrimenti no
        //'COL_IDAZI#=#col se è presente indica la colonna del documento che4 contiene idazi su cui voglio i contatori
        //'COLS_FORSCRIPT#=#col1,...,colN se è presente indica le colonne della tabella del documento utili al calcolo dei contatori
        //'TABNAME#=#tabella opzionale è la tabella su cui vado ad agire
        //'FIELD_ID#=# opzionale colonna usata come perno sulla tabella
        //'QUERY_DOCKEY#=# opzionale è la query che mi restituisce gli id delle righe su cui operare
        //''Const LIST_FIELDS = "LIST_FIELDS"

        const string FORMAT = "FORMAT";

        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            ELAB_RET_CODE ret = ELAB_RET_CODE.RET_CODE_ERROR;

            string strCause = string.Empty;
            SqlConnection? cnLocal = null!;
            iTimeout = timeout;

            try
            {
                strDescrRetCode = "";

                //' Apertura connessione
                strCause = "Apertura connessione al DB";
                cnLocal = SetConnection(connection, cdf);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 1 --- legge i parametri necessari
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "Lettura dei parametri che determinano le azioni";
                bool bOK = false;
                bOK = GetParameters(strParam, ref strDescrRetCode);

                if (!bOK)
                {
                    dt.Write("clsCheckPec riga 68: NOT OK - strcause= " + strCause);
                    return ret;
                }

                //'--se nei parametri non viene passato il tipo doc. usa quello input
                if (string.IsNullOrEmpty(mp_DocType))
                {
                    mp_DocType = strDocType;
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 2 --- estrazione attributi di tipo PEC
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                strCause = "estrazione attributi di tipo PEC";

                List<dynamic> vettAttribName = new List<dynamic>();
                List<dynamic> vettAttribValue = new List<dynamic>(); ;
                List<dynamic> vettAttribValueResult = new List<dynamic>(); ;
                int cnt_pec_ko = 0;
                int cnt_pec_wait = 0;

                dt.Write("clsCheckPec riga 93: strcause= " + strCause);

                GetAttribPec(cnLocal, transaction, lIdPfu, strDocKey, mp_DocType, vettAttribName, vettAttribValue);

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' STEP 3 --- Verifica valori attributi di tipo PEC
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

                //' se ci sono attributi di tipo PEC
                if (!IsEmpty(vettAttribName))
                {
                    strCause = "Verifica valori attributi di tipo PEC";


                    CheckAttribPec(cnLocal, transaction, lIdPfu, strDocKey, mp_DocType, vettAttribName, vettAttribValue, vettAttribValueResult, cnt_pec_ko, cnt_pec_wait);
                    dt.Write("clsCheckPec riga 108: strcause= " + strCause);
                    //' caso di errore (se ci sono indirizzi non pec)
                    if ((cnt_pec_ko > 0 || cnt_pec_wait > 0) && mp_BlockOnNoPec == 1)
                    //' vede se deve bloccare oppure no
                    {
                        strDescrRetCode = cnt_pec_ko > 0 ? mp_MsgPecKo : mp_MsgPecWait;

                        if (cnt_pec_wait > 0)
                        {
                            strCause = "Memorizza informazioni PEC errate o in attesa";

                            StoreDocumentWait4Pec(cnLocal, transaction, lIdPfu, strDocKey, mp_DocType, vettAttribName, vettAttribValue, vettAttribValueResult, mp_ProcessName);
                        }
                    }

                    //' se non ci sono stati wait va a rimuovere il documento da un possibile stato precedente di wait
                    if (cnt_pec_wait == 0)
                    {
                        cnt_pec_wait = 0;
                        strCause = "Rimuove il documento dallo stato eventuale di wait";
                        StoreDocumentWait4Pec(cnLocal, transaction, lIdPfu, strDocKey, mp_DocType, vettAttribName, vettAttribValue, vettAttribValueResult, mp_ProcessName, true);
                    }

                    if ((cnt_pec_wait == 0 && cnt_pec_ko == 0) || mp_BlockOnNoPec == 0)
                    {
                        ret = ELAB_RET_CODE.RET_CODE_OK;
                    }
                }

            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);
                throw new Exception($"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate", ex);
            }
            return ret;
        }

        private bool GetParameters(string strParam, ref string strDescrRetCode)
        {
            try
            {
                bool ret = false;

                // On Error GoTo err

                //' I parametri vengono passati come Field1=Valore1&Field2=Valore2....


                string[] s = new string[] { };
                string[] w = new string[] { };
                int i = 0;
                int l = 0;
                string strField = "";
                string strvalue = "";

                mp_collParameters = new Dictionary<string, string>();

                s = strParam.Split("#@#");
                l = s.Length - 1;

                for (i = 0; i <= l; i++)
                {
                    w = s[i].Split("#=#");
                    strField = w[0];
                    strvalue = w[1];

                    mp_collParameters.Add(strField, strvalue);
                }

                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                //' controlli sui parametri passati
                //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                mp_DocType = "";
                strvalue = "";

                mp_collParameters.TryGetValue("DocType", out strvalue);
                if (!string.IsNullOrEmpty(strvalue))
                {
                    mp_DocType = strvalue;
                }

                //'' -- errore bloccante in caso di NoPec
                mp_BlockOnNoPec = 1;

                strvalue = "";
                if (mp_collParameters.TryGetValue("BlockOnNoPec", out strvalue) && strvalue == "0")
                {
                    mp_BlockOnNoPec = 0;
                }

                mp_collParameters.TryGetValue("MsgPecKo", out mp_MsgPecKo);
                mp_collParameters.TryGetValue("MsgPecWait", out mp_MsgPecWait);

                if (string.IsNullOrEmpty(mp_MsgPecKo))
                {
                    mp_MsgPecKo = "Errore: ci sono campi che non risultano PEC";
                }

                if (string.IsNullOrEmpty(mp_MsgPecWait))
                {
                    mp_MsgPecWait = "Errore: ci sono campi PEC in attesa di verifica";
                }

                mp_collParameters.TryGetValue("ProcessName", out mp_ProcessName);

                ret = true;

                return ret;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message, ex);
            }
        }

        private void GetAttribPec(SqlConnection cnLocal, SqlTransaction transaction, long lIdPfu, dynamic DocKey, string DocType, List<dynamic> vettAttribName, List<dynamic> vettAttribValue)
        {
            string strCause = string.Empty;
            string valore = string.Empty;

            vettAttribName = null;
            vettAttribValue = null;

            strCause = "recupera gli attributi del documento di tipo PEC per ogni sezione e modello";
            dt.Write("clsCheckPec riga 237: strcause= " + strCause);
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DocType", DocType);

            string st = "select distinct DZT_Name,des_table,DSE_ID,DES_FieldIdDoc from dbo.LIB_Documents " +
            "inner join LIB_DocumentSections  on doc_id=DSE_DOC_ID " +
            "inner join LIB_Models on MOD_ID=DSE_MOD_ID " +
            "inner join LIB_ModelAttributes on MOD_ID=MA_MOD_ID " +
            "inner join LIB_Dictionary on DZT_Name=MA_DZT_Name " +
            "where doc_id=@DocType and dzt_type=14 and DZT_Format like '%pec%'";

			TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(st, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
            dt.Write("clsCheckPec riga 249: strcause= " + strCause);
            if (!(rs.EOF && rs.BOF))
            {
                //' se ha trovato attributi di tipo pec
                rs.MoveFirst();

                //' per ogni attributo di tipo pec
                while (!rs.EOF)
                {
                    //' memorizza nome attributo

                    AddData(vettAttribName, CStr(rs["DZT_Name"]));

                    strCause = $"recupera valori per attributo {CStr(rs["DZT_Name"])}";

                    valore = GetValoriPec(cnLocal, transaction, DocKey, DocType, CStr(rs["DZT_Name"]), CStr(rs["des_table"]), CStr(rs["DES_FieldIdDoc"]), CommonModule.Basic.GetValueFromRS(rs.Fields["DSE_ID"]));

                    //' memorizza valori attributo
                    AddData(vettAttribValue, valore);
                    dt.Write("clsCheckPec riga 268: strcause= " + strCause);
                    rs.MoveNext();
                }
            }
        }


        private void AddData(List<dynamic> vet, dynamic sData)
        {

            vet.Add(sData);



        }

        private dynamic GetValoriPec(SqlConnection cnLocal, SqlTransaction transaction, dynamic DocKey, dynamic DocType, dynamic DZT_Name, string des_table, dynamic FieldIdDoc, dynamic SectionId)
        {
            string ret = string.Empty;

            string strCause = string.Empty;
            TSRecordSet? rs = null;
            string st = string.Empty;
            string out_ = string.Empty;

            if (des_table.ToUpper() == "CTL_DOC_VALUE")
            {
                //' caso attributo in verticale
                strCause = $"recupera valori attributo {DZT_Name} (in verticale)";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocKey", CInt(DocKey));
                sqlParams.Add("@SectionId", CStr(SectionId));
                sqlParams.Add("@DZT_Name", CStr(DZT_Name));

                st = @"select distinct Value from CTL_DOC_Value with(nolock) where IdHeader=@DocKey
                        and DSE_ID=@SectionId and DZT_Name=@DZT_Name
                        and Value is not null and Value<>''";

                rs = cdf.GetRSReadFromQueryWithTransaction(st, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                if (!(rs.EOF && rs.BOF))
                {
                    if (string.IsNullOrEmpty(out_))
                    {
                        out_ = CStr(rs["Value"]);
                    }
                    else
                    {
                        out_ = $"{out_};{CStr(rs["Value"])}";
                    }

                    rs.MoveNext();
                }

            }
            else
            {
                //' caso attributo in orizzontale
                strCause = $"recupera valori attributo {DZT_Name} (in orizzontale)";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocKey", CInt(DocKey));

                st = "select distinct " + DZT_Name + " from " + des_table +
                " where " + FieldIdDoc + "=@DocKey" +
                " and " + DZT_Name + " is not null and " +
                DZT_Name + "<>''";

                rs = cdf.GetRSReadFromQueryWithTransaction(st, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

                if (!(rs.EOF && rs.BOF))
                {
                    //' se ha trovato valori
                    rs.MoveFirst();

                    //' per ogni attributo di tipo pec
                    while (!rs.EOF)
                    {
                        if (string.IsNullOrEmpty(out_))
                        {
                            out_ = CStr(rs[DZT_Name]);
                        }
                        else
                        {
                            out_ = $"{out_};{CStr(rs[DZT_Name])}";
                        }

                        rs.MoveNext();
                    }
                }
            }

            return ret;
        }

        private void CheckAttribPec(SqlConnection cnLocal, SqlTransaction transaction, long lIdPfu, dynamic DocKey, dynamic DocType, List<dynamic> vettAttribName, List<dynamic> vettAttribValue, List<dynamic> vettAttribValueResult, int cnt_pec_ko, int cnt_pec_wait)
        {
            // On Error GoTo err

            string strCause = "";
            TSRecordSet? rs = null;
            long n;
            long i;
            string[] st;
            long m = 0;
            long j = 0;
            string status = "";
            string esito = "";

            cnt_pec_ko = 0;
            cnt_pec_wait = 0;

            n = vettAttribName.Count;

            // ReDim vettAttribValueResult(1 To n)  

            for (i = 0; i < n; i++)
            {

                //'' per ogni attributo vede la pec è già stata controllata
                st = CStr(vettAttribValue.ElementAt((int)i)).Split(";");
                esito = "";

                m = st.Count();

                for (j = 0; j < m; j++)
                {
                    strCause = "controlla pec per attributo " + CStr(vettAttribValue.ElementAt((int)i)) + " - valore=" + st[j];

                    //' vede se il record esiste
                    // SetRsWrite rs, cnLocal  
                    rs = new TSRecordSet();

                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@Email", st[j]);

                    rs = rs.OpenWithTransaction("select isPEC, Status from CTL_Pec_Verify where eMail=@Email", cnLocal, transaction, sqlParams, iTimeout);

                    if (rs.EOF && rs.BOF)
                    {
                        //' se non esiste inscerisce
                        DataRow dr = rs.AddNew();

                        dr["email"] = st[j];
                        dr["ispec"] = 0;
                        dr["DataIns"] = DateTime.Now;
                        dr["DataUpd"] = DateTime.Now;
                        dr["Status"] = "Inserted";

                        rs.Update(dr, "id", "CTL_Pec_Verify");

                        status = "PEC_IN_WAIT";
                        cnt_pec_wait = cnt_pec_wait + 1;
                    }
                    else
                    {
                        //' se già esiste vede se è PEC
                        status = "Inserted";

                        if (CInt(rs["isPEC"]!) == 1)
                        {
                            status = "PEC_SI";
                        }
                        else
                        {
                            if (CStr(rs["Status"]) == "Elaborated")
                            {
                                status = "PEC_NO";
                                cnt_pec_ko = cnt_pec_ko + 1;
                            }
                            else
                            {
                                cnt_pec_wait = cnt_pec_wait + 1;
                                status = "PEC_IN_WAIT";
                            }
                        }

                    }

                    //' memorizza l'esito del controllo per ogni attributo
                    if (string.IsNullOrEmpty(status))
                    {
                        esito = status;
                    }
                    else
                    {
                        esito = esito + ";" + status;
                    }

                }
                vettAttribValueResult.Add(esito);
                //vettAttribValueResult[i] = esito;
            }
        }

        private void StoreDocumentWait4Pec(SqlConnection cnLocal, SqlTransaction transaction, long lIdPfu, dynamic DocKey, string DocType, dynamic vettAttribName, dynamic vettAttribValue, dynamic vettAttribValueResult, string ProcessName, bool bLastStep = false)
        {
            string strCause = "";
            long n = 0;
            long i = 0;
            string[] st;
            string[] st1;
            long m = 0;
            long j = 0;
            int lID = 0;

            //' vede se quel documento esiste già nella CTL_Pec_Document_Wait
            strCause = "inserimento documento nella CTL_Pec_Document_Wait";
			//SetRsWrite rs, cnLocal    
			TSRecordSet? rs = new();
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DocKey", CInt(DocKey));
            sqlParams.Add("@DocType", DocType);

            rs = rs.OpenWithTransaction("select * from CTL_Pec_Document_Wait where IdDoc=@DocKey and TypeDoc=@DocType", cnLocal, transaction, sqlParams, iTimeout);

            //' viene usato per "rimuovere" il documento dallo stato di wait
            if (bLastStep)
            {
                if (rs is not null && !(rs.EOF && rs.BOF))
                {
                    DataRow dr = rs.Fields;
                    dr["IdPfu"] = lIdPfu;
                    dr["ProcessName"] = ProcessName;
                    dr["DataUpdate"] = DateTime.Now;
                    dr["Status"] = "Elaborated";

                    rs.Update(dr, "idrow", "CTL_Pec_Document_Wait");
                }

                return;
            }

            if (rs.EOF && rs.BOF)
            {
                //' se non esiste inserisce
                DataRow dr = rs.AddNew();

                dr["IdDoc"] = DocKey;
                dr["IdPfu"] = lIdPfu;
                dr["TypeDoc"] = DocType;
                dr["ProcessName"] = ProcessName;
                dr["DataIns"] = DateTime.Now;
                dr["Status"] = "Inserted";

                rs.Update(dr, "idrow", "CTL_Pec_Document_Wait");

                lID = CInt(rs["id"]!);
            }
            else
            {
                //' se esiste lo rimette come inserito

                lID = CInt(rs["id"]!);

                DataRow dr = rs.Fields;
                dr["IdPfu"] = lIdPfu;
                dr["ProcessName"] = ProcessName;
                dr["DataUpdate"] = DateTime.Now;
                dr["Status"] = "Inserted";
                //
                rs.Update(dr, "idrow", "CTL_Pec_Document_Wait");

                //' cancella dettagli precedenti
                sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@Idheader", lID);

                cdf.ExecuteWithTransaction("delete from CTL_Pec_Document_Wait_Attributes where idHeader=@Idheader", cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);
            }

            //'  attributi documento nella CTL_Pec_Document_Wait_Attributes
            strCause = "inserimento attributi documento nella CTL_Pec_Document_Wait_Attributes";
            //SetRsWrite rs, cnLocal    
            rs = new TSRecordSet();
            rs = rs.OpenWithTransaction("select top 0 * from CTL_Pec_Document_Wait_Attributes", cnLocal, transaction, timeout: iTimeout);

            n = vettAttribName.Length;

            for (i = 0; i < n; i++)
            {
                //'' per ogni attributo vede la pec è già stata controllata
                st = vettAttribValue[i].Split(";");
                st1 = vettAttribValueResult[i].Split(";");

                m = st.Length;

                for (j = 0; j < m; j++)
                {
                    if (st[j] == "PEC_IN_WAIT")
                    {
                        strCause = "inserimento attributo " + vettAttribName(i) + " - valore=" + st[j];

                        DataRow dr = rs.AddNew();

                        dr["idHeader"] = lID;
                        dr["AttribName"] = vettAttribName[i];
                        dr["AttribValue"] = st[j];

                        rs.Update(dr, "idrow", "CTL_Pec_Document_Wait_Attributes");
                    }
                }
            }
        }
    }
}
