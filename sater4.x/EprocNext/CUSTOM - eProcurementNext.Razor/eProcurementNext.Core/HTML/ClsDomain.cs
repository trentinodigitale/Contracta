using eProcurementNext.CommonDB;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class ClsDomain : IClsDomain
    {
        public string? Desc { get; set; }
        public string? Id { get; set; }
        public Dictionary<string, dynamic>? Elem { get; set; }// = null; //dizionario string - DomElem
        public bool Dynamic { get; set; } = false;
        public string? Query { get; set; } = "";
        public string? ConnectionString { get; set; } = "";
        public string? Suffix { get; set; }
        public string? Filter { get; set; } = ""; // indica la chiave su cui si è filtrato il dominio
        public DateTime LastLoad { get; set; }
        public string? DynamicReload { get; set; }
        public TSRecordSet RsElem = new TSRecordSet(); //{ get; set; } = null;
        public string? RsElemBackup { get; set; } = "";
        public string? StrFormat { get; set; }
        CommonDbFunctions cdf = new CommonDbFunctions();
        public ClsDomain()
        {
            Elem = new Dictionary<string, dynamic>();
            StrFormat = "";
        }

        public ClsDomain(string? desc, string? id, Dictionary<string, dynamic>? elem, bool dynamic, string? query, string? connectionString, string? suffix, string? filter, DateTime lastLoad, string? dynamicReload, TSRecordSet? rsElem, string? strFormat)
        {
            Desc = desc;
            Id = id;
            Elem = elem;
            Dynamic = dynamic;
            Query = query;
            ConnectionString = connectionString;
            Suffix = suffix;
            Filter = filter;
            LastLoad = lastLoad;
            DynamicReload = dynamicReload;
            RsElem = new TSRecordSet();
            RsElem = rsElem;
            StrFormat = strFormat;
        }

        public IDomElem? FindExtCode(string ext)
        {
            //DomElem el = null;

            try
            {
                if (RsElem != null && this.Elem != null)
                {
                    foreach (DomElem el in this.Elem.Values)
                    {
                        if (el.CodExt == ext)
                        {
                            return el;
                        }
                    }
                }

                if (RsElem.RecordCount > 0)
                {
                    RsElem.MoveFirst();
                    RsElem.Filter(@$"DMV_CodExt = '{ext.Replace("'", "''")}'");

                    if (RsElem.RecordCount > 0)
                    {
                        string rsCodExt = (string)RsElem.Fields["DMV_CodExt"];
                        if (rsCodExt == ext)
                        {
                            DomElem el = new DomElem(RsElem);

                            return el;
                        }
                    }
                }
            }
            catch (Exception)
            {
            }

            return null!;

        }

        public IDomElem? FindCode(string id)
        {
            DomElem? el = null;

            string strSql = "";

            if (UCase(DynamicReload) == "NO MEM" || (Left(UCase(DynamicReload), 13) == "FILTERED ONLY" && CStr(Filter) == ""))
            {
                //'-- recupera l'informazione direttamente dal DB
                int ix = 0;
                TSRecordSet rs;
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@suffix", this.Suffix);

                ix = InStrVb6(1, UCase(Query), "ORDER BY");

                if (ix > 0)
                {
                    string strOrderBy = "";
                    strSql = Left(Query, ix - 1);
                    strOrderBy = MidVb6(Query, ix);

                    strSql = "select top 1 * from ( " + strSql + " ) as a where DMV_Cod = '" + id.Replace("'", "''") + "' " + strOrderBy;
                }
                else
                {
                    strSql = "select top 1 * from ( " + Query + " ) as a where DMV_Cod = '" + id.Replace("'", "''") + "' ";

                }


                rs = cdf.GetRSReadFromQuery_(strSql, ConnectionString, parCollection: sqlParams);

                if (rs != null)
                {
                    if (rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        el = new DomElem(rs);
                    }
                }

            }
            else
            {
                if (RsElem == null)
                {
                    el = Elem[id];
                }
                else
                {
                    RsElem.MoveFirst();
                    RsElem.Find("DMV_Cod = '" + CStr(id).Replace("'", "''") + "'");

                    if (RsElem.EOF == false)
                    {
                        if (CStr(GetValueFromRS(RsElem.Fields["DMV_Cod"])) == id)
                        {
                            el = new DomElem(RsElem);
                        }
                    }

                }

            }

            return el;
        }
        /// <summary>
        /// ritorna il domElem corrispondente all'indice passato in input
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public IDomElem index(int id)
        {
            DomElem el = null;

            if (RsElem == null)
            {
                el = (DomElem)Elem.ElementAt(id).Value;
            }
            else
            {
                try
                {

                    RsElem.AbsolutePosition = id;
                    RsElem.position = id;
                    el = new DomElem(RsElem);
                }
                catch (Exception)
                {
                    throw;
                }
            }

            return el;
        }

        /// <summary>
        /// ritorna un valore nel caso in cui il dominio è composto da un singolo elemento
        /// </summary>
        /// <param name="strFormat"></param>
        /// <returns></returns>
        public string GetSingleValue(string strFormat = "")
        {
            DomElem el = null;
            int totElements = 0;
            string strRetVal = "";

            if (RsElem == null)
            {
                if (Elem.Count == 1)
                {
                    strRetVal = el.id;
                }
            }
            else
            {
                //'-- Se nel dominio non vogliamo far uscire anche i cancellati logicamente
                if (!strFormat.Contains("Y", StringComparison.Ordinal))
                {
                    totElements = RsElem.RecordCount;

                    try
                    {
                        RsElem.Filter("DMV_Deleted = 0");
                        totElements = RsElem.RecordCount;
                    }
                    catch (Exception)
                    {

                        //throw;
                        totElements = RsElem.RecordCount;
                    }

                    RsElem.Filter(""); //adFilterNone

                }

                if (totElements == 1)
                {
                    RsElem.MoveFirst();
                    strRetVal = (string)GetValueFromRS(RsElem.Fields["DMV_Cod"]);
                }


            }

            return strRetVal;

        }

        public string FindDescLeft(string Desc)
        {
            string strRetVal = "";
            int del = 0;
            string strSql = "";

            if (UCase(DynamicReload) == "NO MEM" || (Left(UCase(DynamicReload), 13) == "FILTERED ONLY" && CStr(Filter) == ""))
            {
                //'-- recupera l'informazione direttamente dal DB
                int ix = 0;
                TSRecordSet rs = null;

                ix = InStrVb6(1, UCase(Query), "ORDER BY");

                if (ix > 0)
                {
                    strSql = Left(Query, ix - 1);

                    strSql = "select top 1 * from ( " + strSql + " ) as a where DMV_DescML like '" + Desc.Replace("'", "''") + "%' ";
                }
                else
                {
                    strSql = "select top 1 * from ( " + Query + " ) as a where DMV_DescML like '" + Desc.Replace("'", "''") + "%' ";
                }

                rs = cdf.GetRSReadFromQuery_(strSql, ConnectionString);

                if (rs != null)
                {
                    if (rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        strRetVal = GetValueFromRS(rs.Fields["DMV_Cod"]) + "###" + GetValueFromRS(rs.Fields["DMV_DescML"]) + "###" + GetValueFromRS(rs.Fields["DMV_CodExt"]);
                    }
                }

            }
            else
            {
                if (RsElem != null)
                {
                    RsElem.MoveFirst();

                    RsElem.Find("DMV_DescML like '" + Desc.Replace("'", "''") + "%'");

                    if (RsElem.EOF == false)
                    {
                        try
                        {
                            del = GetValueFromRS(RsElem.Fields["DMV_Deleted"]);
                        }
                        catch (Exception)
                        {
                            del = 0;
                        }

                        if (del == 0)
                        {
                            strRetVal = GetValueFromRS(RsElem.Fields["DMV_Cod"]) + "###" + GetValueFromRS(RsElem.Fields["DMV_DescML"]) + "###" + GetValueFromRS(RsElem.Fields["DMV_CodExt"]);
                        }

                    }

                }
            }

            return strRetVal;

        }

        public string FindDesc(string Desc)
        {
            string strRetVal = "";
            int del = 0;
            string strSql = "";

            if (UCase(DynamicReload) == "NO MEM" || (Left(UCase(DynamicReload), 13) == "FILTERED ONLY" && CStr(Filter) == ""))
            {
                //'-- recupera l'informazione direttamente dal DB
                int ix = 0;
                TSRecordSet rs = null;

                ix = InStrVb6(1, UCase(Query), "ORDER BY");

                if (ix > 0)
                {
                    string strOrderBy = "";
                    strSql = Left(Query, ix - 1);
                    strOrderBy = MidVb6(Query, ix);
                    strSql = "select top 1 * from ( " + strSql + " ) as a where DMV_DescML = '" + Desc.Replace("'", "''") + "' ";
                }
                else
                {
                    strSql = "select top 1 * from ( " + Query + " ) as a where DMV_DescML = '" + Desc.Replace("'", "''") + "' ";
                }

                rs = cdf.GetRSReadFromQuery_(strSql, ConnectionString);

                if (rs != null)
                {
                    if (rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        strRetVal = GetValueFromRS(rs.Fields["DMV_Cod"]) + "###" + GetValueFromRS(rs.Fields["DMV_DescML"]) + "###" + GetValueFromRS(rs.Fields["DMV_CodExt"]);
                    }
                }

            }
            else
            {
                if (RsElem != null)
                {
                    RsElem.MoveFirst();

                    RsElem.Find("DMV_DescML = '" + Desc.Replace("'", "''") + "'");

                    if (RsElem.EOF == false)
                    {
                        try
                        {
                            del = GetValueFromRS(RsElem.Fields["DMV_Deleted"]);
                        }
                        catch (Exception)
                        {
                            del = 0;
                        }

                        if (del == 0)
                        {
                            strRetVal = GetValueFromRS(RsElem.Fields["DMV_Cod"]) + "###" + GetValueFromRS(RsElem.Fields["DMV_DescML"]) + "###" + GetValueFromRS(RsElem.Fields["DMV_CodExt"]);
                        }

                    }

                }
            }

            return strRetVal;

        }

        public string FindDescOrFirstOccurency(string Desc)
        {
            string strRetVal = "";
            int del = 0;

            if (RsElem != null)
            {
                RsElem.MoveFirst();
                // TODO: verificare
                RsElem.Find("DMV_DescML like '%" + Desc.Replace("'", "''") + "%'"); //, 0, SearchDirectionEnum.adSearchForward);
                del = 0;



                //gestione dei cancellati logici
                if (RsElem.EOF == false)
                {
                    if (StrFormat.Contains("Y", StringComparison.Ordinal))
                    {
                        del = 0;
                    }
                    else
                    {
                        try
                        {

                            if (GetValueFromRS(RsElem.Fields["DMV_Deleted"]) == null)
                            {
                                del = 0;
                            }
                            else
                            {
                                del = GetValueFromRS(RsElem.Fields["DMV_Deleted"]);
                            }
                        }
                        catch (Exception)
                        {
                            del = 0;
                        }
                    }

                    //'-- se non ho chiesto i cancellati logici ma mi trovo su un cancellato logico, scorro il recordset fintanto che ci sono elementi o trovo un elemento non cancellato
                    if (del == 1)
                    {
                        int maxLoopCount = 1;
                        RsElem.MoveNext();

                        //Do While Not rsElem.EOF And err.number = 0 And del = 1 And maxLoopCount < 10
                        try
                        {
                            while (!RsElem.EOF && del == 1 && maxLoopCount < 10)
                            {
                                if (GetValueFromRS(RsElem.Fields["DMV_Deleted"]) == null)
                                {
                                    del = 0;
                                }
                                else
                                {
                                    del = GetValueFromRS(RsElem.Fields["DMV_Deleted"]);
                                }

                                if (del == 0)
                                    break;
                                else
                                    RsElem.MoveNext();

                                maxLoopCount++;
                            }
                        }
                        catch (Exception)
                        {
                            throw;
                        }


                    }

                } //-- fine gestione dei cancellati logici

                if (RsElem.EOF == false && del == 0)
                {
                    strRetVal = GetValueFromRS(RsElem.Fields["DMV_Cod"]) + "###" + GetValueFromRS(RsElem.Fields["DMV_DescML"]) + "###" + GetValueFromRS(RsElem.Fields["DMV_CodExt"]);

                    //'-- Se la descrizione combacia con quella richiesta diamo in output l'elemento esatto
                    if (UCase(Desc) != UCase(GetValueFromRS(RsElem.Fields["DMV_DescML"])))
                    {

                        //dynamic mark = RsElem.Bookmark; 
                        bool foundOnlyOne = RsElem.Find("DMV_DescML like '%" + Desc.Replace("'", "''") + "%'");

                        //'-- Se l'elemento non combacia esattamente ma la ricerca ha prodotto un solo risultato
                        //'-- diamo quel risultato in output
                        if (foundOnlyOne /*RsElem.EOF == true*/ )
                        {
                            //'FindDescOrFirstOccurency = rsElem.Fields("DMV_Cod") & "###" & rsElem.Fields("DMV_DescML") & "###" & rsElem.Fields("DMV_CodExt")
                        }
                        else
                        {
                            strRetVal = "";
                        }
                    }

                }

            }

            return strRetVal;
        }

        /// <summary>
        /// '-- restituisce il recordset del dominio
        /// '-- nel caso in cui il dominio non sia in memoria esegue la query dinamicamente ma solo nel caso sia applicato un filtro
        /// '-- il motivo del filtro è che questi domini sono troppo ampi per poter essere gestiti senza filtro
        /// </summary>
        /// <returns></returns>
        public TSRecordSet GetRsElem()
        {
            if (RsElem == null)
            {
                if (Left(UCase(DynamicReload), 13) == "FILTERED ONLY" && !string.IsNullOrEmpty(Filter))
                {
                    //'-- recupera l'informazione direttamente dal DB
                    RsElem = cdf.GetRSReadFromQuery_(Query, ConnectionString);
                }
            }
            return RsElem;
        }
        /// <summary>
        /// restituisce le desc relative ad una selzione multivalore ###cod1###cod2#....#codN###
        /// </summary>
        /// <param name="objField"></param>
        /// <param name="strMultiCod"></param>
        /// <param name="strSep"></param>
        /// <returns></returns>
        public string FindDescMultiValue(dynamic objField, string strMultiCod, string strSep = "</br>") //objField è di tipo Fld_Domain. cambiare da dynamic a Fld_Domain non appena sarà pronto
        {
            string strDesc = "";

            //'--tolgo i primi 3 ### in testa se presenti
            if (Left(strMultiCod, 3) == "###")
            {
                strMultiCod = MidVb6(strMultiCod, 4);
            }
            //'--tolgo gli ultimi 3 ### in coda se presenti
            if (Right(strMultiCod, 3) == "###")
            {
                strMultiCod = Left(strMultiCod, Len(strMultiCod) - 3);
            }
            //'--tolgo singolo apice per SQL
            strMultiCod = strMultiCod.Replace("'", "''");
            //'--preparo la clausola in
            strMultiCod = strMultiCod.Replace("###", "','");
            //'-- recupera l'informazione direttamente dal DB
            int ix = InStrVb6(1, UCase(Query), "ORDER BY");
            string strSql = "";

            if (ix > 0)
            {
                string strOrderBy = "";
                strSql = Left(Query, ix - 1);
                strOrderBy = MidVb6(Query, ix);
                strSql = $"select * from ( {strSql} ) as a where DMV_Cod in ('{strMultiCod} ') {strOrderBy}";
            }
            else
            {
                strSql = $"select * from ( {Query} ) as a where DMV_Cod in ('{strMultiCod} ') ";
            }

            //'--apro rs
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, ConnectionString);

            if (rs != null)
            {
                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();

                    while (!rs.EOF)
                    {
                        //Private Function FormattedElem(Image As String, CodExt As String, Desc As String) As String
                        string tmpDesc = objField.FormattedElem("", GetValueFromRS(rs.Fields["DMV_CodExt"]), GetValueFromRS(rs.Fields["DMV_DescML"]), CStr(StrFormat));
                        //objField.FormattedElem( "", rs.Fields("DMV_CodExt"), rs.Fields("DMV_DescML"), CStr(strFormat));

                        strDesc = IIF((strDesc == ""), tmpDesc, strDesc + strSep + tmpDesc);

                        rs.MoveNext();
                    }

                }
            }

            return strDesc;

        }

        public string FindDescOrFirstOccurencyExt(string Desc, string format)
        {
            this.StrFormat = format;
            return FindDescOrFirstOccurency(Desc);
        }

    }
}
