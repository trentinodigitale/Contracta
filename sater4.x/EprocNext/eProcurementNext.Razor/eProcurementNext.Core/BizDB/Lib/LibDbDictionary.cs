using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.HTML;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.BizDB
{
    public class LibDbDictionary
    {
        public string strConnectionString = string.Empty;
        CommonDbFunctions cdf = new();

        public Field GetField(string DZT_Name, string suffix, string? strConnectionString, int Context = 0)
        {
            return GetFilteredField(DZT_Name, suffix, 0, "", strConnectionString, Context);
        }

        /// <summary>
        /// Restituisce il controllo HTML in grado di gestire l'attributo passato
        /// </summary>
        /// <param name="DZT_Name">string, Nome dell'attributo</param>
        /// <param name="suffix">string, Suffisso per indicare la lingua di riferimento</param>
        /// <param name="idPfu">long, Id dell'utente</param>
        /// <param name="Filter">string, Evenetuale filtro da utilizzare nella ricerca</param>
        /// <param name="strConnectionString">Stringa di connessione</param>
        /// <param name="Context">int, riferimento al Contesto </param>
        /// <returns></returns>
        /// <exception cref="ArgumentException"></exception>
        public Field GetFilteredField(string DZT_Name, string suffix, long idPfu, string Filter, string? strConnectionString, int Context = 0)
        {
            string strCause = string.Empty;
            Field objField; // = new Field()
            Field resultObj;
            dynamic DefaultValue;
            string strFormat = string.Empty;
            int nMultivalue = 0;

            string noKey = string.Empty;

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DZT_Name", DZT_Name);
            string strSql = "select * from lib_dictionary where DZT_Name = @DZT_Name";

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, null, parCollection: sqlParams);
            if (rs is not null && rs.RecordCount > 0)
            {
                int DZT_TYPE = (int)rs.Fields["DZT_TYPE"];
                objField = eProcurementNext.HTML.BasicFunction.getNewField(DZT_TYPE);
                objField.Language = suffix;
                objField.ConnectionString = strConnectionString;

                LibDbMultiLanguage ml = new LibDbMultiLanguage(strConnectionString);

                string dom = string.Empty;
                string umdom = string.Empty;
                string idDom = string.Empty;
                string idUmDom = string.Empty;
                LibDBDomains objDomains = new LibDBDomains();
                ClsDomain objdom = new ClsDomain();
                ClsDomain objumdom = new ClsDomain();
                string valore = string.Empty;

                //'-- recupera il dominio dell'attributo se presente
                strCause = "recupera il dominio dell'attributo se presente";
                dom = (string)rs.Fields["DZT_DM_ID"];
                if (!string.IsNullOrEmpty(dom) || dom.Length > 0)
                {
                    idUmDom = dom;
                    objumdom = objDomains.GetFilteredDom(idDom, suffix, idPfu, Filter, Context, strConnectionString);
                }
                else
                {
                    objdom = null;
                }

                // '-- recupera il dominio dell'unità di misura se presente
                strCause = "recupera il dominio dell'unità di misura se presente";
                umdom = (string)rs.Fields["DZT_DM_ID_um"];
                if (!string.IsNullOrEmpty(umdom) || umdom.Length > 0)
                {
                    idUmDom = umdom;
                    objumdom = objDomains.GetDom(idUmDom, suffix, Context, strConnectionString);
                }
                else
                {
                    objumdom = null;
                }

                try
                {
                    valore = (string)rs.Fields["DZT_ValueDef"];
                    DefaultValue = (string)rs.Fields["DZT_ValueDef"];

                    strFormat = (rs.Fields["DZT_Format"] == null) ? "" : (string)rs.Fields["DZT_Format"];

                    if (suffix == "UK")
                    {
                        strFormat = strFormat.Replace("dd/mm/yyyy", "mm/dd/yyyy");
                    }

                    // -- setto il multivalore
                    nMultivalue = rs.Fields["DZT_Multivalue"] == null ? 0 : Convert.ToInt32(rs.Fields["DZT_Multivalue"]);
                    objField.MultiValue = nMultivalue;

                    strCause = "inizializza il controllo";


                    objField.Init((Convert.ToInt32(rs.Fields["DZT_Type"].ToString())), DZT_Name, valore, objdom, objumdom, strFormat);
                    objField.MaxLen = Convert.ToInt32(rs.Fields["DZT_Len"].ToString());
                    objField.numDecimal = Convert.ToInt32(rs.Fields["DZT_dec"].ToString());
                    objField.DefaultValue = DefaultValue == null ? "" : DefaultValue;

                    objField.Caption = ml.CNV((string)rs.Fields["DZT_descML"]);
                    //'-- per i domini chiusi aggiorna la descrittiva SelectDescription -- Effettuare una selezione --"
                    objField.SetSelectDescription(ml.CNV("-- Effettuare una selezione --", suffix));
                    objField.SetPrintDescription(ml.CNV("Vedi allegato", suffix));
                    objField.SetSelezionatiDescription(ml.CNV("Selezionati", suffix));
                    objField.SetSenzaModali(ApplicationCommon.Application["DISATTIVA_MODALE_MULTIVALORE"]);

                    // '--inizializzo le descrizioni costanti per l'attributo
                    string strVisual = string.Empty;
                    dynamic[] aInfo = new dynamic[] { };
                    int i = 0;
                    int nNum = 0;
                    string strMultiValue = string.Empty;
                    string strKey = string.Empty;
                    strVisual = objField.GetPredefiniteVisualDescription();
                    aInfo = strVisual.Split("#~");

                    nNum = aInfo.Length;  // verificare se corretto
                    for (i = 0; i < nNum; i++)
                    {
                        strKey = aInfo[i].ToString();
                        strMultiValue = String.IsNullOrEmpty(strMultiValue) ? ml.CNV(strKey, suffix) : strMultiValue + "#~" + ml.CNV(strKey, suffix);
                    }

                    objField.SetPredefiniteVisualDescription(strMultiValue);
                    return objField;
                }
                catch (Exception ex)
                {
                    return null;
                }
            }
            else
            {
                return null;
            }

        }

        /// <summary>
        /// Recupera l'elemento di un dominio per un dato attributo del dizionario
        /// </summary>
        /// <param name="dztName"></param>
        /// <param name="val"></param>
        /// <param name="suffix"></param>
        /// <param name="Context"></param>
        /// <returns></returns>
        public DomElem GetDomElemOfAttr(string dztName, string val, string suffix, int Context = 0)
        {
            //Field objField = new Field();
            TSRecordSet rs;
            ClsDomain objdom = new ClsDomain();
            DomElem result = null;

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DZT_Name", dztName);

            rs = cdf.GetRSReadFromQuery_("select * from lib_dictionary where DZT_Name = @DZT_Name", strConnectionString, null, parCollection: sqlParams);
            if (rs.RecordCount > 0)
            {
                string dom;
                string idDom = string.Empty;
                LibDBDomains objDomains = new LibDBDomains();

                ClsDomain objumdom = new ClsDomain();

                objDomains.strConnectionString = strConnectionString;

                try
                {
                    // -- recupera il dominio dell'attributo se presente
                    dom = (string)rs.Fields["DZT_DM_ID"];
                    if (!String.IsNullOrEmpty(dom))
                    {
                        idDom = dom;
                        objdom = objDomains.GetDom(idDom, suffix);
                        if (objdom != null)
                        {
                            result = (DomElem)objdom.Elem[val];
                        }
                    }
                }
                catch (Exception ex)
                {
                    result = null;
                }
            }

            return result;
        }

        /// <summary>
        /// Recupera tutto il dominio di un dato attributo
        /// </summary>
        /// <param name="dztName"></param>
        /// <param name="suffix"></param>
        /// <param name="Context"></param>
        /// <returns></returns>
        public ClsDomain? GetDomOfAttr(string dztName, string suffix, int Context = 0)
        {
            Field objField;
            TSRecordSet rs;

            ClsDomain? result = null;

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DZT_Name", dztName);

            rs = cdf.GetRSReadFromQuery_($"Select * from lib_dictionary where DZT_Name = @DZT_Name", strConnectionString, null, parCollection: sqlParams);

            if (rs.RecordCount > 0)
            {
                string dom;
                string idDom = string.Empty;
                LibDBDomains objDomains = new LibDBDomains();
                ClsDomain objdom = new ClsDomain();
                ClsDomain objumdom = new ClsDomain();


                objDomains.strConnectionString = strConnectionString;

                try
                {
                    //'-- recupera il dominio dell'attributo se presente
                    dom = (string)rs.Fields["DZT_DM_ID"];
                    if (!String.IsNullOrEmpty(dom))
                    {
                        result = objDomains.GetDom(idDom, suffix);
                    }
                }
                catch (Exception ex)
                {

                }

            }


            return result;
        }

        public ClsDomain GetDomOfAttrSC(string dztName, string suffix, int Context, string strConnectionString)
        {
            TSRecordSet rs;
            string dom = string.Empty;
            string idDom = string.Empty;
            LibDBDomains objDomains = new LibDBDomains();
            ClsDomain objdom = new ClsDomain();
            ClsDomain clsumdom = new ClsDomain();

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DZT_Name", dztName);

            rs = cdf.GetRSReadFromQuery_($"select * from lib_dictionary where DZT_Name = @DZT_Name", strConnectionString, null, parCollection: sqlParams);

            if (rs.RecordCount > 0)
            {


                objDomains.strConnectionString = strConnectionString;

                try
                {
                    // recupera il dominio dell'attributo se presente
                    dom = (string)rs.Fields["DZT_DM_ID"];
                    if (!String.IsNullOrEmpty(dom))
                    {
                        idDom = dom;
                        return objDomains.GetDom(idDom, suffix);
                    }

                }
                catch (Exception ex)
                {

                }
            }

            return objdom;
        }

        public int GetTypeAttrib(string DZT_Name, string strConnectionString)
        {
            int result = 0;
            string strSql = string.Empty;
            TSRecordSet rs = new TSRecordSet();

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DZT_Name", DZT_Name);

            strSql = " select dzt_type from lib_dictionary where dzt_name=@DZT_Name";
            rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, null, parCollection: sqlParams);

            if (!rs.BOF && !rs.EOF)
            {
                rs.MoveFirst();
                result = (int)rs.Fields["DZT_Type"];
            }

            return result;

        }

        /// <summary>
        /// Restituisce il controllo HTML in grado di gestire l'attributo passato
        /// </summary>
        /// <param name="DZT_Name">string, Nome dell'attributo</param>
        /// <param name="suffix">string, Suffisso per indicare la lingua di riferimento</param>
        /// <param name="idPfu">long, Id dell'utente</param>
        /// <param name="Filter">string, Evenetuale filtro da utilizzare nella ricerca</param>
        /// <param name="strConnectionString">Stringa di connessione</param>
        /// <param name="Context">int, riferimento al Contesto </param>
        /// <returns></returns>
        /// <exception cref="ArgumentException"></exception>
        public Field GetFilteredFieldExt(string DZT_Name, string suffix, long idPfu, Session.ISession session, string Filter, string? strConnectionString, int Context = 0)
        {
            string strCause = string.Empty;
            Field objField = null;
            Field resultObj;
            dynamic DefaultValue;
            string strFormat = string.Empty;
            int nMultivalue = 0;

            string noKey = CStr(session["NoMLKey"]);

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@DZT_Name", DZT_Name);

            string strSql = $"select * from lib_dictionary where DZT_Name = @DZT_Name";

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, parCollection: sqlParams);
            if (rs is not null && rs.RecordCount > 0)
            {
                int DZT_TYPE = CInt(rs["DZT_TYPE"]!);
                objField = BasicFunction.getNewField(DZT_TYPE);
                objField.Language = suffix;
                objField.ConnectionString = strConnectionString;

                LibDbMultiLanguage ml = new LibDbMultiLanguage(strConnectionString);

                string dom = string.Empty;
                string umdom = string.Empty;
                string idDom = string.Empty;
                string idUmDom = string.Empty;
                LibDBDomains objDomains = new();
                ClsDomain? objdom = new();
                ClsDomain? objumdom = new();
                string valore = string.Empty;

                //'-- recupera il dominio dell'attributo se presente
                strCause = "recupera il dominio dell'attributo se presente";
                dom = CStr(rs["DZT_DM_ID"]);
                if (!string.IsNullOrEmpty(dom))
                {
                    idDom = dom;
                    objdom = objDomains.GetFilteredDomExt(idDom, suffix, idPfu, Filter, Context, strConnectionString, session);
                }


                // '-- recupera il dominio dell'unità di misura se presente
                strCause = "recupera il dominio dell'unità di misura se presente";
                umdom = CStr(rs["DZT_DM_ID"]);
                if (!string.IsNullOrEmpty(umdom))
                {
                    idUmDom = umdom;
                    objumdom = objDomains.GetFilteredDomExt(idDom, suffix, idPfu, "", Context, strConnectionString, session);
                }

                valore = CStr(rs["DZT_ValueDef"]);
                DefaultValue = CStr(rs["DZT_ValueDef"]);


                //'--se attributo TEXT,TEXTAREA,URL applico multilinguismo al default se contine pattern da risolvere
                strCause = "se attributo TEXT,TEXTAREA,URL applico multilinguismo al default";
                int dztType = CInt(rs["DZT_Type"]!);
                if (!String.IsNullOrEmpty(valore) && Strings.InStr(1, valore, "#ML") > 0 && dztType == 1 || dztType == 3 || dztType == 13)
                {
                    valore = Application.ApplicationCommon.CNV(valore, session);
                    DefaultValue = valore;

                    //'--tolgo il prefisso e suffisso per key non trovata
                    if (!string.IsNullOrEmpty(noKey) && CommonModule.Basic.Left(valore, noKey.Length) == noKey)
                    {
                        valore = Strings.Mid(valore, noKey.Length + 1, valore.Length - 2 * noKey.Length);
                        DefaultValue = valore;
                    }
                }

                strFormat = CStr(rs["DZT_Format"]);

                if (suffix == "UK")
                {
                    //'-- per le date si converte la formattazione della data in quella inglese
                    strFormat = strFormat.Replace("dd/mm/yyyy", "mm/dd/yyyy");
                }

                // '--recupero proprietà multivalore
                nMultivalue = CInt(rs["DZT_Multivalue"]!);
                objField.MultiValue = nMultivalue;

                strCause = "inizializza il controllo";
                try
                {
                    objField.Init((CInt(rs["DZT_Type"]!)), DZT_Name, valore, objdom, objumdom, strFormat);

                    objField.MaxLen = CInt(rs["DZT_Len"]!);
                    objField.numDecimal = CInt(rs["DZT_dec"]!);
                    objField.DefaultValue = DefaultValue is null ? "" : DefaultValue;

                    objField.Caption = ApplicationCommon.CNV(CStr(rs["DZT_descML"]));

                    //'-- per i domini chiusi aggiorna la descrittiva SelectDescription -- Effettuare una selezione --"
                    objField.SetSelectDescription(ApplicationCommon.CNV("-- Effettuare una selezione --", suffix));
                    objField.SetPrintDescription(ApplicationCommon.CNV("Vedi allegato", suffix));
                    objField.SetSelezionatiDescription(ApplicationCommon.CNV("Selezionati", suffix));
                    objField.SetSenzaModali(ApplicationCommon.Application["DISATTIVA_MODALE_MULTIVALORE"]);

                    // '--inizializzo le descrizioni costanti per l'attributo
                    string strVisual = string.Empty;
                    dynamic[] aInfo = new dynamic[] { };
                    int i = 0;
                    int nNum = 0;
                    string strMultiValue = string.Empty;
                    string strKey = string.Empty;
                    strVisual = objField.GetPredefiniteVisualDescription();
                    aInfo = strVisual.Split("#~");

                    nNum = aInfo.Length;  // verificare se corretto
                    for (i = 0; i < nNum; i++)
                    {
                        strKey = aInfo[i].ToString();
                        strMultiValue = String.IsNullOrEmpty(strMultiValue) ? ml.CNV(strKey, suffix) : strMultiValue + "#~" + ml.CNV(strKey, suffix);
                    }

                    objField.SetPredefiniteVisualDescription(strMultiValue);
                }
                catch (Exception ex)
                {
                    throw new Exception("LibDbDictionary.GetFilteredField(" + ex.Message + ")", ex);
                }
            }

            return objField;
        }
    }
}
