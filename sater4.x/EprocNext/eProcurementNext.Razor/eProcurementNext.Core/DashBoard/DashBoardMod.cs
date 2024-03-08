using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;


namespace eProcurementNext.DashBoard
{
    public class DashBoardMod
    {



        public static TSRecordSet GetRSGrid(string OWNER, long idPfu, string strTable, string strFilter, string FilterHide, string strConnectionString, string strTop = "", string strSort = "", long lTime = 0, string strStored = "")
        {
            TSRecordSet rs = new TSRecordSet();
            string strSql = string.Empty;

            if (strStored.ToLower() != "yes")
            {
                if (string.IsNullOrEmpty(strTop))
                {
                    strSql = $"select * from {strTable} ";
                }
                else
                {
                    strSql = $"select top {strTop} * from {strTable} ";
                }

                if (!String.IsNullOrEmpty(strFilter))
                {
                    strSql += $" where {strFilter} ";
                    if (!String.IsNullOrEmpty(OWNER))
                    {
                        strSql += $" and {OWNER} = '{idPfu}'";
                    }
                }
                else
                {
                    if (!String.IsNullOrEmpty(OWNER))
                    {
                        strSql += $" where {OWNER} = '{idPfu}'";
                    }
                }

                // accoda alla query il filtro implicito non visibile
                if (!String.IsNullOrEmpty(FilterHide))
                {
                    if (!strSql.Contains(" where ", StringComparison.Ordinal))
                    {
                        strSql += $" where {FilterHide}";
                    }
                    else
                    {
                        strSql += $" and {FilterHide}";
                    }
                }

                // accoda le condizioni di sort ( forse )
                if (!String.IsNullOrEmpty(strSort.Trim()))
                {
                    strSql += $" order by {strSort}";
                }
            }
            else
            {
                string[] vl = strFilter.Split("#~#");
                if (vl.GetUpperBound(0) > 1)
                {
                    strSql = $"exec {strTable}  {idPfu} , '{vl[0]}', '{vl[1].Replace("'", "''")}', '{vl[2]}' ";
                }
                else
                {
                    strSql = $"exec {strTable}  {idPfu} , '', '', '' ";
                }

                string testTop = String.IsNullOrEmpty(strTop) ? "-1" : strTop;
                strSql += $", '{FilterHide.Replace("'", "''")}', '{strSort}', {testTop}, 1";
            }

            try
            {
                CommonDbFunctions cdf = new CommonDbFunctions();
                SqlConnection cnLocal = new SqlConnection();
                if (lTime > 0)
                {
                    SetConnection(cnLocal, strConnectionString, lTime);
                    //cnLocal.CommandTimeout = (int)lTime;
                    rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, cnLocal);
                }
                else
                {

                    rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString);
                }
            }
            catch
            {

            }

            /*
             *  If Not cnLocal Is Nothing Then
                    cnLocal.Close
                    Set cnLocal = Nothing
                End If

                Set GetRSGrid = rs
             */

            return rs;
        }



        public static TSRecordSet GetRSGridCount(string OWNER, long idPfu, string strTable, string strFilter, string FilterHide, string strConnectionString, ref long NumRec, string strTop = "", string strSort = "", long lTime = 0, string strStored = "", string Solo_Colonne_usate = "SI")
        {
            CommonDbFunctions cdf = new CommonDbFunctions();

            TSRecordSet rs;
            string strSql = string.Empty;
            SqlConnection cnLocal = new SqlConnection();

            if (lTime > 0)
            {
                cnLocal = new SqlConnection();
            }

            if (strStored != "yes")
            {
                strSql = $"select count(*) as num from {strTable}";
                if (!string.IsNullOrEmpty(strFilter))
                {
                    strSql = strSql + $" where {strFilter}";
                    if (!string.IsNullOrEmpty(OWNER))
                    {
                        strSql = strSql + $" and {OWNER} = '{idPfu}'";
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(OWNER))
                    {
                        strSql = strSql + $" where {OWNER} = '{idPfu}'";
                    }
                }



                if (!string.IsNullOrEmpty(FilterHide))
                {
                    if (!strSql.Contains(" where ", StringComparison.Ordinal))
                    {
                        strSql = strSql + $" where ( {FilterHide} ) ";
                    }
                    else
                    {
                        strSql = strSql + $" and ( {FilterHide} ) ";
                    }
                }

                //-- recupero prima il numero di record
                rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString); // verificare cnlocal!!

                NumRec = eProcurementNext.CommonModule.Basic.CLng(rs.Fields["num"]);

                //--per non usare la stored GET_RECORDSET_VIEWER (aad esempio per i DB access che non la supportano) per ritornare le colonne del modello richioesto
                if (Solo_Colonne_usate == "NO")
                {
                    if (string.IsNullOrEmpty(strTop))
                    {
                        strSql = "select * from " + strTable;
                    }
                    else
                    {
                        strSql = "select top " + strTop + " * from " + strTable;
                    }

                    if (!string.IsNullOrEmpty(strFilter))
                    {
                        strSql = strSql + " where " + strFilter;
                        if (!string.IsNullOrEmpty(OWNER))
                        {
                            strSql = strSql + " and " + OWNER + " = '" + idPfu + "'";
                        }
                        else
                        {
                            if (!string.IsNullOrEmpty(OWNER))
                            {
                                strSql = strSql + " where " + OWNER + " = '" + idPfu + "'";
                            }
                        }
                    }

                    //-- accoda alla query il filtro implicito non visibile
                    if (!string.IsNullOrEmpty(FilterHide))
                    {
                        if (!strSql.Contains(" where ", StringComparison.Ordinal))
                        {
                            strSql = strSql + " where ( " + FilterHide + " ) ";
                        }
                        else
                        {
                            strSql = strSql + " and ( " + FilterHide + " ) ";
                        }

                        //-- accoda le condizione di sort ( forse )
                        if (!string.IsNullOrEmpty(strSort.Trim()))
                        {
                            strSql = strSql + " order by " + strSort;
                        }
                    }
                }
                else
                {
                    if (!String.IsNullOrEmpty(strFilter))
                    {
                        strFilter = strFilter.Replace("'", "''");
                    }
                    else
                    {
                        strFilter = String.Empty;
                    }
                    strSql = "exec GET_RECORDSET_VIEWER '" + strTable + "' , '" + strTop + "' , '" + strFilter + "' , '" + OWNER + "' , '" + FilterHide.Replace("'", "''") + "' , '" + strSort.Trim() + "' , '" + strStored + "' , '" + idPfu + "' ";
                }
            }
            else
            {
                //-- altrimenti compongo la chiamata per la stored
                string[] vl = strFilter != null ? strFilter.Split("#~#") : new string[0];
                if (vl.GetUpperBound(0) > 1)
                {
                    strSql = $"exec {strTable} {idPfu}, '{vl[0]}' ,'{vl[1].Replace("'", "''")}' ,'{vl[2]}' ";
                }
                else
                {
                    strSql = "exec " + strTable + "  " + idPfu + " , '' , '' , ''";
                }
                string sTop = strTop == "" ? "-1" : strTop;
                strSql = strSql + $" , '{FilterHide.Replace("'", "''")}' , '{strSort}' , {sTop},  1";
            }

            rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString); // VERIFICARE CNLOCAL !!

            if (strStored == "yes")
            {
                NumRec = rs.RecordCount;
            }

            return rs;
        }


        /// <summary>
        /// '-- esegue un processo per un dato documento e ritorna nei parametri di output gli elementi per il messaggio di ritorno
        /// </summary>
        /// <param name="session"></param>
        /// <param name="DOCUMENT"></param>
        /// <param name="PROCESS"></param>
        /// <param name="IdDoc"></param>
        /// <param name="idUser"></param>
        /// <param name="msgTitle"></param>
        /// <param name="msgIcon"></param>
        /// <param name="msgBody"></param>
        /// <param name="strConnectionString"></param>
        /// <returns></returns>
        public static bool ExecuteProcess(Session.ISession session, string DOCUMENT, string PROCESS, long IdDoc, long idUser, ref string msgTitle, ref int msgIcon, ref string msgBody, string strConnectionString)
        {
            bool ret = true;

            CtlProcess.ClsElab obj;

            string strDescrRetCode = "";
            dynamic vIdMp;
            CommonModule.Const.ELAB_RET_CODE vRetCode;

            vIdMp = 1;

            try
            {

                vIdMp = session[Session.SessionProperty.SESSION_WORKROOM];

                obj = new CtlProcess.ClsElab();
                vRetCode = obj.Elaborate(PROCESS, DOCUMENT, IdDoc, idUser, ref strDescrRetCode, vIdMp, strConnectionString);

                //Se il processo è andato in errore
                if (vRetCode != CommonModule.Const.ELAB_RET_CODE.RET_CODE_OK)
                {
                    InitMessageProcess(session, (int)vRetCode, strDescrRetCode, ref msgTitle, ref msgIcon, ref msgBody);

                    if (vRetCode == CommonModule.Const.ELAB_RET_CODE.RET_CODE_ERROR)
                    {

                        ret = false;

                        string dettError = (string)ApplicationCommon.Application["dettaglio-errori"];

                        if (string.IsNullOrEmpty(dettError) || dettError.ToLower() == "yes")
                        {
                            //Il messaggio d'errore non cambia, lasciamo quanto ritornato dalla InitMessageProcess
                            ;
                        }
                        else
                        {
                            if (!string.IsNullOrEmpty(msgBody) && msgBody.ToLower().Contains("numero :", StringComparison.Ordinal))
                            {
                                msgBody = CStr(ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", session) + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                            }
                        }
                    }
                    else
                    {
                        ret = true;
                    }

                }
                else
                {
                    string nomeProcesso = string.Empty;

                    if (PROCESS.Contains(':', StringComparison.Ordinal))
                    {
                        string[] arrProcess = PROCESS.Split(":");
                        nomeProcesso += arrProcess[0];
                    }
                    else
                    {
                        nomeProcesso = PROCESS;
                    }

                    msgTitle = "Attenzione";
                    msgIcon = MSG_INFO;
                    //msgBody = ApplicationCommon.CNV(PROCESS, session) + ApplicationCommon.CNV(" - Correttamente eseguito", session);
                    msgBody = ApplicationCommon.CNV(nomeProcesso, session) + ApplicationCommon.CNV(" - Correttamente eseguito", session);
                }
            }
            catch (Exception ex)
            {
                //tracciamo l'eccezione e NON facciamo risalire l'exception ma un errore gestito tramite i parametri già previsti da questo metodo
                ret = false;

                eProcurementNext.CommonDB.Basic.TraceErr(ex, strConnectionString, "DashBoardMod");

                msgBody = CStr(ApplicationCommon.CNV("Errore esecuzione comando : ", session)) + PROCESS + Environment.NewLine + "<br/>Tipo : " + ex.GetType().ToString() + Environment.NewLine + "<br/>Descrizione : " + ex.Message;
                msgTitle = "Errore";
                msgIcon = MSG_ERR;

                //'-- Se NON è attiva la modalità debug visualizziamo all'utente solo un messaggio generico 
                if ((ApplicationCommon.Application["debug-mode"].ToLower() != "yes" ||
                    ApplicationCommon.Application["debug-mode"].ToLower() != "si" ||
                    ApplicationCommon.Application["debug-mode"].ToLower() != "true"
                    ) && (ApplicationCommon.Application["dettaglio-errori"].ToLower() != "yes" ||
                        ApplicationCommon.Application["dettaglio-errori"].ToLower() != "si"))
                {


                    msgBody = (ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO") + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                }
            }

            return ret;
        }


    /// <summary>
    /// '-- prende in input il valore ritornato dall'elaborazione del processo
    /// '-- e costruisce i parametri per visualizzare il messaggio all'utente
    /// </summary>
    /// <param name="session"></param>
    /// <param name="vRetCode"></param>
    /// <param name="strDescrRetCode"></param>
    /// <param name="msgTitle"></param>
    /// <param name="msgIcon"></param>
    /// <param name="msgBody"></param>
    public static void InitMessageProcess(dynamic session, int vRetCode, string strDescrRetCode, ref string msgTitle, ref int msgIcon, ref string msgBody)
    {
        string[] v;
        int i;
        int c;
        string[] v1;
        int i1;
        int c1;
        var strMsg = string.Empty; // default(string);
        string testo;

        if (vRetCode == 1)
        {
            msgIcon = MSG_ERR;
            msgTitle = "Errore";
        }
        else
        {
            msgIcon = MSG_INFO;
            msgTitle = "Attenzione";
        }

        //'-- recupero il messaggio da visualizzare
        v = strDescrRetCode.Split("#@#");
        c = v.GetUpperBound(0);

        //for (i = 0; i <= v.Length; i++)
        for (i = 0; i <= c; i++)
        {

            testo = v[i];

            //if (InStr(1, v[i], "~~") > 0)
            if (testo.Contains("~~", StringComparison.Ordinal))
            {

                v1 = strDescrRetCode.Split("~~");

                for (i1 = 0; i1 < v1.Length; i1++)
                {

                    if (Left(v1[i1], 7) == "@TITLE=")
                    {
                        //'-- recupero la caption del messaggio se presente
                        msgTitle = v1[i1].Substring(7);
                    }

                    else if (Left(v1[i1], 6) == "@ICON=")
                    {
                        //'-- recupero l'icona se presente
                        msgIcon = Convert.ToInt32(v1[i1].Substring(6));
                    }

                    else
                    {
                        testo = v1[i1];
                        strMsg = strMsg + ApplicationCommon.CNV(v1[i1], session) + " ";
                    }
                }
            }

            else
            {
                strMsg += ApplicationCommon.CNV(testo, session) + " ";
            }


        }

        msgBody = strMsg;
    }


    public static void SetConnection(SqlConnection cnLocal, string sValue, long lTimeOut = -1)
    {

        if (cnLocal == null)
        {
            cnLocal = new SqlConnection();
        }


        sValue = sValue.Trim();
        cnLocal.ConnectionString = sValue;


        //if (lTimeOut > 0)
        //{
        //    cnLocal.CommandTimeout = (int)lTimeOut;
        //}


        //Else


        //-- Settiamo un default timeout diverso dal default di ADODB, 30 secondi
        //if( queryTimeOut == 0) Then


        //    '-- recupero il timeOut dal registro di sistema
        //    Timeout = GetDefaultQueryTimeOut


        //    If Timeout<> "" Then

        //       queryTimeOut = CLng(Timeout)


        //    Else

        //        queryTimeOut = CLng(60) '-- default a 60 secondi


        //    End If


        //End If


        //    cnLocal.CommandTimeout = queryTimeOut

        //End If


        //Apre connessione
        //cnLocal.Open();
    }


}
}
