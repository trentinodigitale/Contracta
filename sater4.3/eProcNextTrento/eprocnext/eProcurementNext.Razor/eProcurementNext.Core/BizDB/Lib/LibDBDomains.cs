using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.BizDB
{
    public partial class LibDBDomains : ILibDBDomains
    {
        public static Dictionary<string, ClsDomain>? Domains = null;
        public static int gl_NoCache = 0;
        public string strConnectionString;
        CommonDbFunctions cdf = new CommonDbFunctions();

        ////'-- ritorna un oggetto dominio creandolo dalla tabella degli stati
        public ClsDomain GetDom(string idDom, string suffix, int Context = 0, string strConnectionStringOpt = "")
        {
            return GetFilteredDom(idDom, suffix, 0, "", Context, strConnectionStringOpt);
        }

        public ClsDomain? GetFilteredDom(string idDom, string suffix, long idPfu, string Filter, int Context = 0, string strConnectionStringOpt = "")
        {
            TSRecordSet rsD = new TSRecordSet();
            ClsDomain dom = new ClsDomain();
            string strDom = string.Empty;

            if (!string.IsNullOrEmpty(strConnectionStringOpt))
            {
                strConnectionString = strConnectionStringOpt;
            }

            strDom = idDom;

            //On Error Resume Next

            ////'-- verifico la presenza del dominio se non esiste lo carico
            if (Domains == null)
            {
                Domains = new Dictionary<string, ClsDomain>();//Collection
            }

            string domainName;
            domainName = strDom + "_" + suffix + strConnectionString + "_" + idPfu + "_" + Filter;
            //err.Clear
            dom = null;
            dom = Domains != null ? Domains[domainName] : null;

            if (dom == null)
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DM_ID", idDom);

                rsD = cdf.GetRSReadFromQuery_("select * from lib_domain where DM_ID = @DM_ID", strConnectionString, null, parCollection: sqlParams);

                if (rsD.RecordCount == 0)
                {
                    return null;
                }


                string strQuery;

                if (!IsNull(rsD.Fields["DM_Query"]))
                {
                    strQuery = CStr(rsD.Fields["DM_Query"]).Trim();
                }
                else
                {
                    strQuery = "";
                }

                if (string.IsNullOrEmpty(strQuery))
                {
                    dom = LoadLocalDomain(idDom, rsD, idPfu, Filter, suffix, Context);
                }
                else
                {
                    dom = LoadExternalDomain(idDom, rsD, idPfu, Filter, suffix, Context);
                }

                if (dom != null)
                {
                    ////'--- ATTIVARE LE RIGHE PER IL CHACING
                    if (gl_NoCache == 0)
                    {
                        Domains.Add(domainName, dom);
                    }
                }



            }

            //rsD = null;
            return dom;

            //if ( err.Number <> 0 ) {
            //    AFLErrorControl.StoreErrWithSource err.Source & "FUNZIONE : Lib_dbDomains.GetFilteredDom()"
            //    On Error GoTo 0
            //    AFLErrorControl.DecodeErr
            //}
        }

        public ClsDomain? GetFilteredDomExt(string idDom, string suffix, long idPfu, string Filter, int Context, string strConnectionStringOpt, ISession Session)
        {

            TSRecordSet? rsD;
            ClsDomain? dom = null;
            string strDom;
            //Dim AppicationASP As Object
            string strDomainName;
            bool bNew = false;
            eProcurementNext.Cache.IEprocNextCache objCache;
            //Dim vetInfo() As Variant

            if (!string.IsNullOrEmpty(strConnectionStringOpt))
            {
                strConnectionString = strConnectionStringOpt;
            }

            //AppicationASP = session(OBJAPPLICATION)
            objCache = ApplicationCommon.Cache;

            strDomainName = "CTL_DOMAIN_" + idDom + "_" + suffix;
            string strCause = "";

            strDom = idDom;


            try
            {



                strCause = "determina il nome del dominio in memoria cache";

                ////'-- se è presente un filtro il nome in chache del dominio si estende
                if (!string.IsNullOrEmpty(Filter))
                {

                    ////'-- per un dominio filtrato ma non sulla persona non � necessario indicare l'utente
                    if (Strings.Left(Filter, 10).ToUpper() == "SQL_WHERE=" && InStrVb6(1, Filter, "<ID_USER>") <= 0)
                    {
                        strDomainName = strDomainName + Filter;
                    }
                    else
                    {
                        strDomainName = strDomainName + "_" + idPfu + "_" + Filter;
                    }

                }



                //'-- verifica se il dominio è presente in memoria se non è filtrato e lo carica
                if (!string.IsNullOrEmpty(objCache[strDomainName]))
                {

                    strCause = "recupera il dominio dalla memoria cache dominio = " + strDomainName;

                    dom = new HTML.ClsDomain();

                    dynamic[] vetInfo = objCache[strDomainName + "_VET"];

                    dom.ConnectionString = vetInfo[DOM_connectionString];
                    dom.Desc = vetInfo[DOM_Desc];
                    dom.Dynamic = vetInfo[DOM_Dynamic];
                    dom.DynamicReload = vetInfo[DOM_DynamicReload];
                    //'dom.elem = vetInfo(DOM_elem)
                    dom.Filter = vetInfo[DOM_Filter];
                    dom.Id = vetInfo[DOM_Id];
                    dom.LastLoad = CDate(vetInfo[DOM_LastLoad]);
                    dom.Query = vetInfo[DOM_Query];
                    dom.Suffix = vetInfo[DOM_suffix];

                    dom.RsElem = objCache[strDomainName + "_rsElem"];

                    bNew = false;
                }


                //'-- altrimenti lo carico
                if (dom == null)
                {

                    bNew = true;

                    strCause = $@"recupera il dominio dal DB [" + $@"select * from lib_domain with(nolock) where DM_ID = '" + Replace(idDom, "'", "''") + $@"'" + $@"]";

                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@DM_ID", idDom);

                    rsD = cdf.GetRSReadFromQuery_($@"select * from lib_domain with(nolock) where DM_ID = @DM_ID", strConnectionString, null, parCollection: sqlParams);

                    if (rsD.RecordCount == 0)
                    {
                        return null;
                    }

                    string strQuery;

                    if (rsD["DM_Query"] is not null)
                    {
                        strQuery = CStr(rsD["DM_Query"]).Trim();
                    }
                    else
                    {
                        strQuery = "";
                    }


                    if (string.IsNullOrEmpty(strQuery))
                    {
                        dom = LoadLocalDomain(idDom, rsD, idPfu, Filter, suffix, Context, true, Session);
                    }
                    else
                    {
                        dom = LoadExternalDomain(idDom, rsD, idPfu, Filter, suffix, Context, true, Session);
                    }


                }


                //'-- se è nuovo lo conservo in memoria
                if (bNew == true)
                {

                    strCause = "Conservo il domino in memoria dominio=" + strDomainName;
                    bool bStoreInMem = true;

                    //'-- un dominio che deve essere aggiornato ogni volta non deve andare in memoria "every 0 0"
                    if (dom.DynamicReload.ToLower().Contains("every 0 0", StringComparison.Ordinal))
                    {
                        bStoreInMem = false;
                    }

                    //'-- un dominio filtrato per l'utente non deve andare in memoria "<ID_USER>"
                    if (!string.IsNullOrEmpty(Filter) && bStoreInMem == true)
                    {
                        if (dom.Filter.ToUpper().StartsWith("SQL_WHERE=", StringComparison.Ordinal) && !dom.Filter.Contains("<ID_USER>", StringComparison.Ordinal))
                        {
                            bStoreInMem = true; //'-- non � filtrato per utente
                        }
                        else
                        {
                            bStoreInMem = false; //'-- � filtrato per utente
                        }
                    }

                    //'-- un dominio da usare solo filtrato non deve andare in memoria "FILTERED ONLY"
                    if (dom.DynamicReload.ToUpper().Contains("FILTERED ONLY", StringComparison.Ordinal))
                    {
                        bStoreInMem = false;
                    }

                    if (bStoreInMem)
                    {


                        objCache[strDomainName] = "YES";

                        dynamic[] vetInfo = new dynamic[15];
                        vetInfo[DOM_connectionString] = dom.ConnectionString;
                        vetInfo[DOM_Desc] = dom.Desc;
                        vetInfo[DOM_Dynamic] = dom.Dynamic;
                        vetInfo[DOM_DynamicReload] = dom.DynamicReload;
                        vetInfo[DOM_Filter] = dom.Filter;
                        vetInfo[DOM_Id] = dom.Id;
                        vetInfo[DOM_LastLoad] = dom.LastLoad;
                        vetInfo[DOM_Query] = dom.Query;
                        vetInfo[DOM_suffix] = dom.Suffix;

                        objCache[strDomainName + "_rsElem"] = dom.RsElem;

                        objCache[strDomainName + "_VET"] = vetInfo;

                        objCache.Save();

                    }

                }
                else
                {
                    DateTime last;

                    if (!string.IsNullOrEmpty(dom.DynamicReload) && dom.DynamicReload.ToUpper() != "NO MEM")
                    {

                        if (dom.Dynamic == true && dom.DynamicReload.ToLower() != "never")
                        {
                            last = dom.LastLoad;

                            strCause = "recupero il domino in memoria dominio=" + strDomainName;

                            ReloadDomain(dom);

                            //'-- se il dominio � stato ricaricato aggiorno in memoria il cambiamento
                            if (last != dom.LastLoad)
                            {

                                strCause = "se il dominio è stato ricaricato aggiorno in memoria il cambiamento dominio=" + strDomainName;

                                dynamic[] vetInfo = objCache[strDomainName + "_VET"];
                                vetInfo[DOM_LastLoad] = dom.LastLoad;
                                objCache[strDomainName + "_VET"] = vetInfo;
                                objCache[strDomainName + "_rsElem"] = dom.RsElem;

                            }
                        }

                    }
                }

                //Set rsD = Nothing
                return dom;

            }
            catch (Exception ex)
            {
                CommonDB.Basic.TraceErr(ex, strConnectionString);
                throw;
            }
        }

        public void Refresh()
        {
            //'-- rimuove tutti gli oggetti contenuti nella collezione
            if (Domains != null)
            {
                while (Domains.Count > 0)
                {
                    Domains.Remove(Domains.ElementAt(0).Key);
                }

                Domains = null;
            }
        }

        public void ReloadDomain(ClsDomain dom) // dom = CtlHtml.clsDomain
        {
            TSRecordSet? rsE = null;
            string strCause = "";
            string LocDynamicReload;
            DateTime DM_LastUpdate = DateTime.Now;
            bool flagUpdDataFromDB;

            flagUpdDataFromDB = false;

            //On Error GoTo eh
            try
            {
                if (dom.DynamicReload.ToUpper() != "NO MEM")
                {
                    if ((Strings.Left(dom.DynamicReload.ToUpper(), 13) != "FILTERED ONLY" || !string.IsNullOrEmpty(dom.Filter)))
                    {

                        LocDynamicReload = dom.DynamicReload.ToLower();

                        if (Strings.Left(dom.DynamicReload.ToUpper(), 13) == "FILTERED ONLY")
                        {
                            //'-- tolgo la frase filtered only per applicare le medesime logiche gi� presenti
                            LocDynamicReload = MidVb6(dom.DynamicReload.ToLower(), 15);
                        }

                        strCause = $@"determino se fare l'aggiornamento del dominio - " + dom.DynamicReload;

                        //'-- verifica che il dominio sia scaduto
                        if (!string.IsNullOrEmpty(LocDynamicReload.Trim()))
                        {

                            string[] v;
                            v = LocDynamicReload.Split(" ");
                            if (v[0] == "never")
                            {
                                return;
                            }
                            if (v[0] == "verify_upd")
                            {

                                //'-- esegue una select sul DB per controllare la data di ultimo aggiornamento del dominio
                                TSRecordSet? rsLU;
                                var sqlParams = new Dictionary<string, object?>();
                                sqlParams.Add("@DM_ID", dom.Id);

                                rsLU = cdf.GetRSReadFromQuery_("select DM_LastUpdate from lib_domain where DM_ID = @DM_ID", dom.ConnectionString, null, parCollection: sqlParams);

                                rsLU.MoveFirst();
                                if (IsNull(rsLU.Fields["DM_LastUpdate"]))
                                {
                                    rsLU = null;
                                    return;
                                }

                                DM_LastUpdate = DateTime.Parse(rsLU.Fields["DM_LastUpdate"].ToString());

                                //'-- se il dominio non � cambiato non lo ricarico
                                if (DM_LastUpdate == dom.LastLoad)
                                {
                                    return;
                                }
                                flagUpdDataFromDB = true;

                            }
                            else
                            {
                                try
                                {
                                    if (v[2] == "day")
                                    {
                                        if (DateDiff("d", dom.LastLoad, DateAndTime.Now) < CInt(v[1]))
                                        {
                                            return;
                                        }
                                    }


                                    if (v[2] == "minute")
                                    {
                                        if (DateDiff("n", dom.LastLoad, DateAndTime.Now) < CInt(v[1]))
                                        {
                                            return;
                                        }
                                    }

                                    if (v[2] == "minute")
                                    {
                                        if (DateDiff("n", dom.LastLoad, DateAndTime.Now) < CInt(v[1]))
                                        {
                                            return;
                                        }
                                    }
                                }
                                catch
                                {
                                    return;

                                }


                            }






                        }
                        else
                        {
                            //'-- in questo caso ci troviamo con un dominio statico
                            //'-- caricato dinamicamente ed aggiorniamo con una periodicit� di mezzora
                            if (DateDiff("n", dom.LastLoad, DateAndTime.Now) < 30)
                            {
                                return;
                            }

                        }

                        strCause = "Imposto la data";

                        if (flagUpdDataFromDB == true)
                        {
                            dom.LastLoad = DM_LastUpdate;
                        }
                        else
                        {
                            dom.LastLoad = DateAndTime.Now;
                        }

                        strCause = "Leggo il RS dal DB - " + dom.Query;

                        //'-- recupero il dominioa aggiornato
                        if (Strings.Left(dom.DynamicReload.ToUpper(), 13) != "FILTERED ONLY" || !string.IsNullOrEmpty(dom.Filter))
                        {
                            Dictionary<string, object?> dict = new();
                            dict.Add("@suffix", dom.Suffix);
                            rsE = cdf.GetRSReadFromQuery_(dom.Query, dom.ConnectionString, dict);
                        }

                        if (dom.RsElem != null)
                        {
                            dom.RsElem = rsE;
                        }
                        else
                        {
                            //'-- svuoto la precedente collezione
                            strCause = "svuoto la precedente collezione";

                            //while (dom.Elem.Count > 0) {
                            //    dom.Elem.Remove 1
                            //}

                            dom.Elem = null;

                            LibDbMultiLanguage? ml = new LibDbMultiLanguage(Application.ApplicationCommon.Application["ConnectionString"]);
                            //'-- carico il recordset nel dominio
                            if (string.IsNullOrEmpty(dom.Suffix))
                            {
                                ml = null;
                            }
                            else
                            {
                                ml = new LibDbMultiLanguage(Application.ApplicationCommon.Application["ConnectionString"]);
                            }

                            LoadRSDomain(dom, rsE, ml, dom.Suffix);
                        }

                        //'-- aggiorno il dominio in cache

                    }

                }

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : Lib_dbDomains.ReloadDomain( " + strCause + " )", ex);
                //eh:

                //    AFLErrorControl.StoreErrWithSource err.Source & " - FUNZIONE : Lib_dbDomains.ReloadDomain( " & strCause & " )"
                //    On Error GoTo 0
                //    AFLErrorControl.DecodeErr
            }

        }

        public ClsDomain LoadLocalDomain(string idDom, TSRecordSet rsD, long idPfu, string Filter, string suffix, int Context = 0, bool bExt = false, ISession? session = null)
        {
            TSRecordSet rsE;
            TSRecordSet rs;
            ClsDomain dom;
            LibDbMultiLanguage ml = new LibDbMultiLanguage(Application.ApplicationCommon.Application["ConnectionString"]);
            DomElem el;
            string sql;
            //ml.connString = strConnectionString
            dom = new ClsDomain();
            dom.Dynamic = false;
            //Dim AppicationASP As Object

            sql = $@"select * from lib_domainvalues where DMV_DM_ID = '" + idDom.Replace($@"'", $@"''") + $@"' "; //'order by DMV_Father, dmv_sort"
            if (!string.IsNullOrEmpty(Filter))
            {

                //'-- verifico se il filtro � una restrizione del tipo IN
                if (Strings.Left(Filter, 10).ToUpper() == "SQL_WHERE=")
                {

                    sql = sql + " and ( " + MidVb6(Filter, 11) + " ) ";

                    sql = Replace(sql, "<ID_USER>", idPfu.ToString());

                }
                else
                {

                    //'-- verifica se il il filtro sul dominio � relazionato ( CTL_RELATION )
                    if (Filter.Contains(".", StringComparison.Ordinal))
                    {
                        string[] v;

                        v = Filter.Split("."); //'-- Attributo.relazione.path

                        //'-- in questo caso la query va sulla CTL_Relation
                        rs = cdf.User_GetInfoAttrib(idPfu, CStr(v[0]), strConnectionString);
                        if (rs.RecordCount > 0)
                        {

                            if (v.Length - 1 == 2)
                            { //'-- nel caso il filtro � su tre paramatri la relazione si attua sul percorso e non sul codice

                                sql = $@"select distinct lib_domainvalues.* from lib_domainvalues , profiliutenteattrib , CTL_Relations where idpfu = " + idPfu + " and ";
                                sql = sql + $@" dztnome = '" + v[0].Replace("'", "''") + $@"' and  attvalue = REL_ValueInput and  REL_Type = '" + Replace(v[1], $@"'", $@"''") + $@"' ";
                                sql = sql + $@" and ( REL_ValueOutput = left( DMV_Father , len ( REL_ValueOutput ) ) or DMV_Father = left( REL_ValueOutput , len( DMV_Father )) ) and ";
                                sql = sql + $@" DMV_DM_ID = '" + idDom.Replace("'", "''") + $@"' "; //' order by DMV_Father, dmv_sort"

                            }
                            else
                            {

                                sql = $@"select distinct lib_domainvalues.* from lib_domainvalues , profiliutenteattrib , CTL_Relations where idpfu = " + idPfu + $@" and ";
                                sql = sql + $@" dztnome = '" + v[0].Replace($@"'", $@"''") + $@"' and  attvalue = REL_ValueInput and  REL_Type = '" + Replace(v[1], $@"'", $@"''") + "' and REL_ValueOutput = DMV_Cod and DMV_DM_ID = '" + Replace(idDom, "'", "''") + "' "; //'order by DMV_Father, dmv_sort"

                            }
                        }



                    }
                    else
                    {

                        //'-- verifico che per l'utente esiste una restrizione sul dominio
                        rs = cdf.User_GetInfoAttrib(idPfu, Filter, strConnectionString);
                        if (rs.RecordCount > 0)
                        {
                            sql = $@"select * from lib_domainvalues , profiliutenteattrib where idpfu = " + idPfu + " and ";
                            sql = sql + $@" dztnome = '" + Replace(Filter, "'", "''") + $@"' and  attvalue = DMV_Cod and DMV_DM_ID = '" + Replace(idDom, "'", "''") + $@"' "; //'order by DMV_Father, dmv_sort"
                        }


                    }

                }
                dom.ConnectionString = strConnectionString;
                dom.Dynamic = true;

                dom.Suffix = suffix;
                dom.Filter = Filter;
            }

            dom.ConnectionString = strConnectionString;
            //On Error Resume Next
            try
            {
                dom.DynamicReload = CStr(rsD.Fields["DM_DynamicReload"]);

            }
            catch
            {

            }
            if (!string.IsNullOrEmpty(dom.DynamicReload))
            {
                dom.Dynamic = true;
            }
            dom.LastLoad = DateAndTime.Now;
            //On Error GoTo 0

            if (bExt == true)
            {

                //AppicationASP = session(OBJAPPLICATION)

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@suffix", suffix);
                if (Application.ApplicationCommon.Application["DB"] == "ACCESS")
                {
                    sql = $@"select a.id, a.DMV_DM_ID,a.DMV_Cod,a.DMV_Father,a.DMV_Level,iif(ISNULL( ML_Description) ,  a.DMV_DescML , ML_Description ) as DMV_DescML,a.DMV_Image,a.DMV_Sort,a.DMV_CodExt,a.DMV_Module , a.DMV_Deleted from ( " + sql + $@"  ) as a left join ( select * from LIB_Multilinguismo where ML_LNG = @suffix ) as b on ";
                    sql = sql + "  a.DMV_DescML = b.ML_KEY  order by DMV_Father, dmv_sort";
                }
                else
                {
                    sql = $@"select a.id, a.DMV_DM_ID,a.DMV_Cod,a.DMV_Father,a.DMV_Level,ISNULL( ML_Description ,  a.DMV_DescML  ) as DMV_DescML,a.DMV_Image,a.DMV_Sort,a.DMV_CodExt,a.DMV_Module , a.DMV_Deleted from ( " + sql + $@"  ) as a left outer join LIB_Multilinguismo on ";
                    sql = sql + $@"  a.DMV_DescML = ML_KEY and ML_LNG = @suffix order by DMV_Father, dmv_sort";
                }
                dom.Query = sql;
                dom.Suffix = suffix;
                rsE = cdf.GetRSReadFromQuery_(sql, strConnectionString, null, parCollection: sqlParams);

                dom.Desc = Application.ApplicationCommon.CNV(CStr(rsD["DM_DescML"]), session);
                dom.RsElem = rsE;

            }
            else
            {

                sql = sql + " order by DMV_Father, dmv_sort";
                dom.Query = sql;
                rsE = cdf.GetRSReadFromQuery_(sql, strConnectionString);

                dom.Desc = Application.ApplicationCommon.CNV(CStr(rsD.Fields["DM_DescML"]), suffix, Context);

                //'-- carico il recordset nel dominio
                LoadRSDomain(dom, rsE, ml, suffix);

            }

            dom.Id = idDom;

            return dom;

        }

        public ClsDomain LoadExternalDomain(string idDom, TSRecordSet rsD, long idPfu, string Filter, string suffix, int Context = 0, bool bExt = false, ISession? session = null)
        {
            TSRecordSet? rsE = null;
            TSRecordSet rs;
            ClsDomain dom;
            LibDbMultiLanguage ml;
            DomElem el;
            string connectionString;

            dom = new ClsDomain();

            if (string.IsNullOrEmpty(CStr(rsD.Fields["DM_ConnectionString"]).Trim()) || IsNull(rsD.Fields["DM_ConnectionString"]))
            {
                connectionString = strConnectionString;
                dom.ConnectionString = connectionString;
            }
            else
            {
                dom.ConnectionString = CStr(rsD.Fields["DM_ConnectionString"]);
            }


            dom.Dynamic = true;
            dom.Query = CStr(rsD.Fields["DM_Query"]);
            dom.Query = dom.Query.Replace("#LNG#", suffix);

            if (bExt == true)
            {
                dom.Desc = Application.ApplicationCommon.CNV(CStr(rsD.Fields["DM_DescML"]), session);
            }
            else
            {
                ml = new LibDbMultiLanguage(Application.ApplicationCommon.Application["ConnectionString"]);
                dom.Desc = ml.CNV(CStr(rsD.Fields["DM_DescML"]), suffix, Context);
            }
            dom.Id = idDom;
            dom.Suffix = ""; //'suffix
            dom.Filter = Filter;

            //On Error Resume Next
            try
            {
                dom.DynamicReload = CStr(rsD.Fields["DM_DynamicReload"]);


                if (!string.IsNullOrEmpty(dom.DynamicReload))
                {
                    dom.Dynamic = true;
                }
                else
                {
                    dom.Dynamic = false;
                }


            }
            catch (Exception ex) { }


            if (dom.DynamicReload != null && dom.DynamicReload.ToLower().Contains("verify_upd", StringComparison.Ordinal))
            {
                dom.LastLoad = DateTime.Parse(rsD.Fields["DM_LastUpdate"].ToString());
            }
            else
            {
                dom.LastLoad = DateAndTime.Now;
            }

            string sql = "";
            try
            {
                //On Error GoTo errore

                string oldSql;
                int ind;
                string strOrderBy;
                strOrderBy = "";

                if (!string.IsNullOrEmpty(Filter))
                {

                    oldSql = dom.Query;
                    ind = InStrVb6(1, oldSql.ToUpper(), "ORDER BY");
                    if (ind > 0)
                    {

                        strOrderBy = MidVb6(oldSql, ind);
                        oldSql = Strings.Left(oldSql, ind - 1);

                    }


                    //'-- verifico se il filtro � una restrizione del tipo IN
                    if (Strings.Left(Filter, 10).ToUpper() == "SQL_WHERE=")
                    {

                        sql = oldSql + " and ( " + MidVb6(Filter, 11) + " ) ";

                        if (string.IsNullOrEmpty(strOrderBy))
                        {
                            sql = sql + " order by DMV_Father, dmv_sort";
                        }
                        else
                        {
                            sql = sql + " " + strOrderBy;
                        }

                        sql = sql.Replace($@"<ID_USER>", idPfu.ToString());

                        dom.Query = sql;

                    }
                    else
                    {

                        if (Filter.ToUpper() == "IDPFU")
                        {

                            sql = oldSql + " and  idpfu = " + idPfu;

                            //'--sql = sql & " order by DMV_Father, dmv_sort"
                            if (string.IsNullOrEmpty(strOrderBy))
                            {
                                sql = sql + " order by DMV_Father, dmv_sort";
                            }
                            else
                            {
                                sql = sql + " " + strOrderBy;
                            }

                            dom.Query = sql;

                        }
                        else
                        {

                            //'-- verifica se il il filtro sul dominio � relazionato
                            if (Filter.Contains(".", StringComparison.Ordinal))
                            {
                                string[] v;

                                v = Filter.Split("."); //'-- Attributo.relazione
                                //'-- in questo caso la query va sulla CTL_Relation
                                rs = cdf.User_GetInfoAttrib(idPfu, CStr(v[0]), strConnectionString);
                                if (rs.RecordCount > 0)
                                {

                                    if (v.Length - 1 == 2)
                                    { //'-- nel caso il filtro � su tre paramatri la relazione si attua sul percorso e non sul codice

                                        sql = $@"select distinct ta.* from ( " + oldSql + $@" ) as ta , profiliutenteattrib , CTL_Relations where idpfu = " + CLng(idPfu) + $@" and ";
                                        sql = sql + $@" dztnome = '" + v[0].Replace($@"'", $@"''") + $@"' and  attvalue = REL_ValueInput and  REL_Type = '" + v[1].Replace($@"'", $@"''") + $@"' ";
                                        sql = sql + $@" and ( REL_ValueOutput = left( DMV_Father , len ( REL_ValueOutput ) ) or DMV_Father = left( REL_ValueOutput , len( DMV_Father )) ) and ";
                                        sql = sql + $@" DMV_DM_ID = '" + idDom.Replace($@"'", $@"''") + $@"' order by DMV_Father, dmv_sort";

                                    }
                                    else
                                    {


                                        sql = $@"select distinct ta.* from ( " + oldSql + $@" ) as ta , profiliutenteattrib , CTL_Relations where idpfu = " + CLng(idPfu) + $@" and ";
                                        sql = sql + $@" dztnome = '" + v[0].Replace($@"'", $@"''") + $@"' and  attvalue = REL_ValueInput and  REL_Type = '" + v[1].Replace($@"'", $@"''") + $@"' and REL_ValueOutput = DMV_Cod and DMV_DM_ID = '" + idDom + $@"' order by DMV_Father, dmv_sort";

                                    }
                                    dom.Query = sql;
                                }


                            }
                            else
                            {

                                //'-- verifico che per l'utente esiste una restrizione sul dominio
                                rs = cdf.User_GetInfoAttrib(idPfu, Filter, strConnectionString);
                                if (rs.RecordCount > 0)
                                {

                                    sql = $@"select distinct ta.* from ( " + oldSql + " ) as ta , profiliutenteattrib where idpfu = " + CLng(idPfu) + " and ";
                                    sql = sql + " dztnome = '" + Replace(Filter, "'", "''") + "' and  attvalue = DMV_Cod order by DMV_Father, dmv_sort";
                                    dom.Query = sql;

                                }

                            }

                        }
                    }
                }

                if (dom.DynamicReload.ToUpper() != "NO MEM")
                {
                    if (Strings.Left(dom.DynamicReload.ToUpper(), 13) != "FILTERED ONLY" || !string.IsNullOrEmpty(dom.Filter))
                    {
                        rsE = cdf.GetRSReadFromQuery_(dom.Query, dom.ConnectionString);
                    }
                }

                if (bExt == true)
                {

                    dom.RsElem = rsE;
                }
                else
                {

                    //'-- carico il recordset nel dominio

                    LoadRSDomain(dom, rsE, null, suffix);
                }

                return dom;

            }
            catch (Exception ex)
            {

                throw new Exception(ex.Message + "FUNZIONE : Lib_dbDomains.LoadExternalDomain( " + sql + " )", ex);
                //errore:

                //AFLErrorControl.StoreErrWithSource err.Source & "FUNZIONE : Lib_dbDomains.LoadExternalDomain( " & sql & " )"
                //AFLErrorControl.DecodeErr
            }

        }

        private dynamic OldLoadExternalDomain(string idDom, TSRecordSet rsD, string suffix, int Context = 0)
        {
            throw new NotImplementedException();
        }
        public void LoadRSDomain(ClsDomain dom, TSRecordSet rsE, LibDbMultiLanguage ml, string suffix) // dom = CtlHtml.clsDomain
        {
            //On Error GoTo eh
            string strCause = "";
            DomElem el;
            try
            {

                if (rsE.RecordCount > 0)
                {

                    rsE.MoveFirst();
                    while (!rsE.EOF)
                    {

                        el = new DomElem();

                        el.id = CStr(rsE.Fields["DMV_Cod"]);
                        el.Father = CStr(rsE.Fields["DMV_Father"]);
                        el.Level = CInt(rsE.Fields["DMV_Level"]);
                        if (ml == null)
                        {
                            el.Desc = CStr(rsE.Fields["DMV_DescML"]);
                        }
                        else
                        {
                            el.Desc = ml.CNV(CStr(rsE.Fields["DMV_DescML"]), suffix);
                        }

                        //On Error Resume Next
                        try
                        {
                            el.Image = CStr(rsE.Fields["DMV_Image"]);
                        }
                        catch { }
                        try
                        {
                            el.Sort = CInt(rsE.Fields["DMV_Sort"]);
                        }
                        catch { }
                        try
                        {
                            el.CodExt = CStr(rsE.Fields["DMV_CodExt"]);
                        }
                        catch { }
                        try
                        {
                            el.ToolTip = CStr(rsE.Fields["DMV_ToolTip"]);
                        }
                        catch { }

                        //err.Clear

                        strCause = "Dom: " + dom.Id + " - Val: " + el.id;

                        dom.Elem.Add(el.id, el);

                        rsE.MoveNext();
                    }

                }

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : Lib_dbDomains.LoadRSDomain( " + strCause + " )", ex);
                //eh:

                //    AFLErrorControl.StoreErrWithSource err.Source & " - FUNZIONE : Lib_dbDomains.LoadRSDomain( " & strCause & " )"
                //On Error GoTo 0
                //AFLErrorControl.DecodeErr
            }


        }
    }
}
