using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
//using static EprocNext.BizDB.BasicFunction;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.BizDB
{
    public class LibDbModelExt
    {
        public IConfiguration configuration;
        private CommonDbFunctions cdf = new CommonDbFunctions();
        public LibDbModelExt(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public LibDbModelExt()
        {

        }




        /// <summary>
        /// '-- ritorna un oggetto di tipo modello prelevando tutta la configurazione dal DB
        /// </summary>
        /// <param name="strModelName"></param>
        /// <param name="suffix"></param>
        /// <param name="idPfu"></param>
        /// <param name="Context"></param>
        /// <param name="strConnectionStringOpt"></param>
        /// <param name="bEditable"></param>
        /// <param name="session"></param>
        /// <returns></returns>
        public dynamic GetFilteredModel(string strModelName, string suffix, long idPfu, int Context = 0, string strConnectionStringOpt = "", bool bEditable = true, eProcurementNext.Session.ISession session = null)
        {

            Model objMod = null; // new Model();
            Dictionary<string, eProcurementNext.HTML.Field> Model = new Dictionary<string, eProcurementNext.HTML.Field>();
            Dictionary<string, Grid_ColumnsProperty> fieldProperty = new Dictionary<string, Grid_ColumnsProperty>();
            //Dim rs As ADODB.Recordset
            string strValParam;

            string strModelNameCache;

            strModelNameCache = $"CTL_MODEL_{strModelName}_{Context}_{suffix}_{bEditable}";

            try
            {
                objMod = new Model();

                //'-- recupera le informazioni del modello
                strValParam = GetFilteredFields(strModelName, ref Model, ref fieldProperty, suffix, idPfu, Context, strConnectionStringOpt, session, bEditable);
                Dictionary<string, Field> tempModel = new Dictionary<string, Field>();
                foreach (KeyValuePair<string, Field> field in Model)
                {
                    tempModel.Add(field.Key, (Field)field.Value.Clone());
                }

                Dictionary<string, Grid_ColumnsProperty> tempFieldProperty = new();
                foreach (var gcl in fieldProperty)
                {
                    tempFieldProperty.Add(gcl.Key, gcl.Value);
                }

                objMod.Fields = tempModel;
                objMod.PropFields = tempFieldProperty;
                objMod.id = strModelName;

                // -- recupera i parametri del modello
                if (!string.IsNullOrEmpty(strValParam))
                {
                    Dictionary<string, string> param;
                    string strVal;
                    param = eProcurementNext.HTML.BasicFunction.GetCollection(strValParam);

                    if (param.ContainsKey("DrawMode"))
                    {
                        objMod.DrawMode = CInt(param["DrawMode"]);

                    }
                    if (param.ContainsKey("NumberColumn"))
                    {
                        objMod.NumberColumn = CInt(param["NumberColumn"]);

                    }
                    if (param.ContainsKey("Style"))
                    {
                        objMod.Style = CStr(param["Style"]);


                    }

                    objMod.param = strValParam;
                }



                objMod.Template = ApplicationCommon.Cache[strModelNameCache + "_Template"];

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + " - FUNZIONE : LibDbModelExt.GetFilteredModel()", ex);

            }

            return objMod;
        }



        // -- crea un nuovo oggetto per le priopità dell'attributo nel modello

        private Grid_ColumnsProperty SetModelProp(TSRecordSet rsprop, HTML.Field objField, dynamic session)
        {
            Grid_ColumnsProperty obj;
            string strVal;
            obj = new Grid_ColumnsProperty();
            rsprop.MoveFirst();
            while (!rsprop.EOF)
            {
                try
                {
                    strVal = CStr(GetValueFromRS(rsprop.Fields["MAP_Value"]));
                    switch (rsprop.Fields["MAP_Propety"])
                    {
                        case "Width":
                            {
                                obj.width = strVal;
                                break;
                            }

                        case "Length":
                            {
                                obj.Length = Convert.ToInt32(strVal);
                                break;
                            }

                        case "Alignment":
                            {
                                obj.Alignment = strVal;
                                break;
                            }

                        case "vAlignment":
                            {
                                obj.vAlignment = strVal;
                                break;
                            }

                        case "Style":
                            {
                                obj.Style = strVal;
                                objField.Style = strVal;
                                break;
                            }

                        case "OnClickCell":
                            {
                                obj.OnClickCell = strVal;
                                break;
                            }

                        case "Total":
                            {
                                obj.Total = cdf.ParseBool(strVal);
                                break;
                            }

                        case "Sort":
                            {
                                obj.Sort = cdf.ParseBool(strVal);
                                break;
                            }

                        case "Wrap":
                            {
                                obj.Wrap = cdf.ParseBool(strVal);
                                break;
                            }

                        case "Hide":
                            {
                                obj.Hide = cdf.ParseBool(strVal);
                                break;
                            }

                        case "Editable":
                            {
                                objField.SetEditable(cdf.ParseBool(strVal));
                                break;
                            }

                        case "Obbligatory":
                            {
                                objField.Obbligatory = cdf.ParseBool(strVal);
                                break;
                            }

                        case "Format":
                            {
                                //  if (session[SESSION_SUFFIX] == "UK")
                                string naz = session[SessionProperty.SESSION_SUFFIX];
                                if (session[SessionProperty.SESSION_SUFFIX] == "UK")
                                {
                                    // -- per le date si converte la formattazione della data in quella inglese
                                    strVal = Strings.Replace(strVal, "dd/mm/yyyy", "mm/dd/yyyy");
                                }

                                objField.strFormat = strVal;
                                break;
                            }

                        case "ColSpan":
                            {
                                objField.colspan = Convert.ToInt32(strVal);
                                break;
                            }

                        case "Help":
                            {
                                objField.Help = strVal;
                                break;
                            }

                        case "OnChange":
                            {
                                objField.setOnChange(strVal);
                                break;
                            }

                        case "OnClick":
                            {
                                objField.setOnClick(strVal);
                                break;
                            }

                        case "DefaultValue":
                            {
                                objField.DefaultValue = strVal;
                                break;
                            }
                        // objField.Value = strVal
                        // objField.GetPrimitiveObject().Value = strVal



                        case "PathImage":
                            {
                                objField.PathImage = strVal;
                                break;
                            }

                        case "Path":
                            {
                                objField.Path = strVal;
                                break;
                            }

                        case "MaxLen":
                            {
                                objField.MaxLen = Convert.ToInt32(strVal);
                                break;
                            }

                        case "PredefiniteVisualDescription":
                            {
                                if (!string.IsNullOrEmpty(strVal))
                                {
                                    SetConstLNG(objField, session, strVal);
                                }

                                break;
                            }

                        case "Rows":
                            {
                                objField.SetRows(Convert.ToInt32(strVal));
                                break;
                            }

                        case "Dimension":
                            {
                                obj.Dimension = strVal;
                                break;
                            }

                        case "Expr":
                            {
                                obj.Expr = strVal;
                                break;
                            }

                        case "bSumm":
                            {
                                obj.bSumm = Conversions.ToBoolean(strVal);
                                break;
                            }

                        case "FormatCondition":
                            {
                                obj.FormatCondition = strVal;
                                break;
                            }

                        case "SQLCondition":
                            {
                                objField.Condition = " " + strVal + " ";
                                break;
                            }
                    }

                    rsprop.MoveNext();
                }
                catch (Exception ex) { }
            }

            return obj;
        }

        private void ReloadDinamicDomain(List<HTML.Field> Model)
        {
            var lib = new LibDBDomains();

            foreach (HTML.Field fl in Model)
            {
                try
                {
                    if (fl.Domain != null)
                    {
                        if (fl.Domain.Dynamic)
                        {
                            lib.ReloadDomain(fl.Domain);
                        }
                    }
                }
                catch (Exception ex) { }
            }
        }


        private void SetConstLNG(HTML.Field objField, dynamic session, string pstrVisual = "")
        {
            // --inizializzo le descrizioni costanti per l'attributo
            string strVisual;
            string[] aInfo;
            int i;
            int nNum;
            string strMultValue;
            string strKey;

            try
            {
                if (string.IsNullOrEmpty(pstrVisual))
                {
                    strVisual = Convert.ToString(objField.GetPredefiniteVisualDescription());
                }
                else
                {
                    strVisual = pstrVisual;
                }
                aInfo = Strings.Split(strVisual, "#~");

                strMultValue = "";
                if (aInfo != null && aInfo.Length > 0)
                {
                    for (i = 0; i < aInfo.Length; i++)
                    {
                        strKey = aInfo[i];
                        // strMultValue = IIf(strMultValue = "", CNV_Session(strKey, session), strMultValue & "#~" & ml.CNV(strKey, suffix))
                        if (!string.IsNullOrEmpty(strKey))
                        {
                            if (!string.IsNullOrEmpty(strMultValue))
                            {
                                strMultValue = strMultValue + "#~";
                            }
                            strMultValue = strMultValue + ApplicationCommon.CNV(strKey, session);
                        }
                    }
                }

                objField.SetPredefiniteVisualDescription(strMultValue);
            }
            catch (Exception ex)
            {
                // errore non era gestito 
            }
        }




        // '-- la seguente funzione è strttamente cotrrelata ad una ptrecedente di nome SetModelProp

        public dynamic SetModelPropDesign(Model MODprop, HTML.Field objField, eProcurementNext.Session.ISession session)
        {
            Grid_ColumnsProperty obj;
            string strVal;
            int i;
            int c;

            c = MODprop.Fields.Count;

            obj = new Grid_ColumnsProperty();

            obj.Name = objField.Name;

            HTML.Field fl;

            for (i = 0; i < c; i++)
            {
                strVal = CStr(MODprop.Fields.ElementAt(i));

                //try
                //{

                switch (strVal)
                {
                    case "Width":
                        {
                            obj.width = strVal;
                            break;
                        }

                    case "Length":
                        {
                            obj.Length = Convert.ToInt32(strVal);
                            break;
                        }

                    case "Alignment":
                        {
                            obj.Alignment = strVal;
                            break;
                        }

                    case "vAlignment":
                        {
                            obj.vAlignment = strVal;
                            break;
                        }

                    case "Style":
                        {
                            obj.Style = strVal;
                            objField.Style = strVal;
                            //objField.GetPrimitiveObject().Style = strVal;
                            break;
                        }

                    case "OnClickCell":
                        {
                            obj.OnClickCell = strVal;
                            break;
                        }

                    case "Total":
                        {
                            obj.Total = cdf.ParseBool(strVal);
                            break;
                        }

                    case "Sort":
                        {
                            obj.Sort = cdf.ParseBool(strVal);
                            break;
                        }

                    case "Wrap":
                        {
                            obj.Wrap = cdf.ParseBool(strVal);
                            break;
                        }

                    case "Hide":
                        {
                            obj.Hide = cdf.ParseBool(strVal);
                            break;
                        }

                    case "Editable":
                        {
                            objField.SetEditable(cdf.ParseBool(strVal));
                            break;
                        }

                    case "Obbligatory":
                        {
                            objField.Obbligatory = cdf.ParseBool(strVal);
                            break;
                        }

                    case "Format":
                        {
                            if (session[SessionProperty.SESSION_SUFFIX] == "UK")
                            {
                                // -- per le date si converte la formattazione della data in quella inglese
                                strVal = Replace(strVal, "dd/mm/yyyy", "mm/dd/yyyy");
                            }

                            objField.strFormat = strVal;
                            break;
                        }

                    case "ColSpan":
                        {
                            objField.colspan = Convert.ToInt32(strVal);
                            break;
                        }

                    case "Help":
                        {
                            objField.Help = strVal;
                            break;
                        }

                    case "OnChange":
                        {
                            objField.setOnChange(strVal);
                            break;
                        }

                    case "OnClick":
                        {
                            objField.setOnClick(strVal);
                            break;
                        }

                    case "DefaultValue":
                        {
                            objField.DefaultValue = strVal;
                            break;
                        }
                    // objField.Value = strVal
                    // objField.GetPrimitiveObject().Value = strVal



                    case "PathImage":
                        {
                            objField.PathImage = strVal;
                            break;
                        }

                    case "Path":
                        {
                            objField.Path = strVal;
                            break;
                        }

                    case "MaxLen":
                        {
                            objField.MaxLen = Convert.ToInt32(strVal);
                            break;
                        }

                    case "PredefiniteVisualDescription":
                        {
                            if (!string.IsNullOrEmpty(strVal))
                            {
                                SetConstLNG(objField, session, strVal);
                            }

                            break;
                        }

                    case "Dimension":
                        {
                            obj.Dimension = strVal;
                            break;
                        }

                    case "Expr":
                        {
                            obj.Expr = strVal;
                            break;
                        }

                    case "bSumm":
                        {
                            obj.bSumm = Conversions.ToBoolean(strVal);
                            break;
                        }

                    case "FormatCondition":
                        {
                            obj.FormatCondition = strVal;
                            break;
                        }

                    case "SQLCondition":
                        {
                            objField.Condition = " " + strVal + " ";
                            break;
                        }

                    case "Rows":
                        {
                            objField.SetRows(Convert.ToInt32(strVal));
                            break;
                        }

                    case "Filter":
                        {
                            objField.Domain.Filter = strVal;
                            break;
                        }
                }

                //}
                //catch (Exception ex) { }
            }

            return obj;
        }

        public dynamic GetFilteredFieldsWeb(string strModelName, ref Dictionary<string, Field> Model, ref Dictionary<string, Grid_ColumnsProperty> fieldProperty, string suffix, long idPfu, int Context, string strConnectionString, eProcurementNext.Session.ISession session, bool bEditable)
        {
            //Dim Model1 As Collection
            //Dim fieldProperty1 As Collection
            return GetFilteredFields(strModelName, ref Model, ref fieldProperty, suffix, idPfu, Context, strConnectionString, session, bEditable);
            //Set Model = Model1
            //Set fieldProperty = fieldProperty1
        }

        //'--risolve ml o sys
        public string RisolvoML_SYS(string strML, string suffix, int Context, ISession session, LibDbDictionary objDBDiz)
        {

            string[] aInfo;
            string[] atypekey;
            int i;
            int n;
            string strTemp;
            Field objField;
            //Dim MLCollection As Collection


            //On Error Resume Next

            aInfo = Strings.Split(strML, "#");
            n = aInfo.Length - 1;

            if (n > 0)
            {// Then

                for (i = 0; i <= n; i++)
                {  //To n

                    if (!string.IsNullOrEmpty(aInfo[i]))
                    {

                        if (Strings.InStr(UCase(aInfo[i]), "ML.") > 0 || Strings.InStr(UCase(aInfo[i]), "SYS.") > 0)
                        {

                            atypekey = Strings.Split(aInfo[i], ".");

                            strTemp = CStr(atypekey[1]);

                            if (UCase(atypekey[0]) == "ML")
                            {

                                //'--provo a recuperare il valore di un'altra key del nuovo multilinguismo
                                //'-- me lo prendo dal collezione del nuov multilinguismo
                                strTemp = ApplicationCommon.CNV(Trim(atypekey[1]), session);

                            }

                            if ((UCase(atypekey[0]) == "SYS"))
                            {

                                //'--attributo dizionario prendo il default
                                objDBDiz = new LibDbDictionary();
                                objField = objDBDiz.GetFilteredFieldExt(CStr(atypekey[1]), suffix, 0, session, "", CStr(ApplicationCommon.Application.ConnectionString), Context);
                                if (objField != null)
                                {
                                    strTemp = objField.TxtValue();
                                }
                                //Set objField = Nothing

                            }

                            strML = Replace(strML, "#" + aInfo[i] + "#", strTemp);

                        }

                    }

                }

                return strML;

            }
            else
            {
                return strML;

            }

        }

        async Task LoadField(HTML.Field fld, Session.ISession session, dynamic vetInfoPropElem, Dictionary<string, Grid_ColumnsProperty> fieldProperty, int Context, List<Exception> exList)
        {
            await Task.Run(() =>
            {
                dynamic[] vetInfoFieldProp;
                try
                {
                    var objDomains = new LibDBDomains();
                    if (fld.Domain != null)
                    {
                        var domain = objDomains.GetFilteredDomExt(CStr(fld.Domain.Id), CStr(session[SessionProperty.SESSION_SUFFIX]) != "" ? CStr(session[SessionProperty.SESSION_SUFFIX]) : "I", CLng(session[SessionProperty.IdPfu]), CStr(fld.Domain.Filter), Context, ApplicationCommon.Application.ConnectionString, session);
                        fld.Domain = domain;
                    }

                    if (fld.umDomain != null){
                        //è corretto mettere fld.Domain.Id al posto di fld.umDomain.Id (era così anche in vb6)
                        var umDomain = objDomains.GetFilteredDomExt(CStr(fld.Domain != null ? fld.Domain.Id : ""), CStr(session[SessionProperty.SESSION_SUFFIX]) != "" ? CStr(session[SessionProperty.SESSION_SUFFIX]) : "I", CLng(session[SessionProperty.IdPfu]), CStr(fld.Domain != null ? fld.Domain.Filter : ""), Context, ApplicationCommon.Application.ConnectionString, session);
                        fld.umDomain = umDomain;
                    }

                    //'-- per i domini chiusi aggiorna la descrittiva SelectDescription -- Effettuare una selezione --"
                    fld.SetSelectDescription(ApplicationCommon.CNV("-- Effettuare una selezione --", session));
                    fld.SetPrintDescription(ApplicationCommon.CNV("Vedi allegato", session));
                    fld.SetSelezionatiDescription(ApplicationCommon.CNV("Selezionati", session));
                    fld.SetSenzaModali(ApplicationCommon.CNV(CStr(ApplicationCommon.Application["DISATTIVA_MODALE_MULTIVALORE"])));

                    //'-- setto le descrizioni delle costanti sul campo nella lingua richiesta
                    SetConstLNG(fld, session);

                    if (!IsEmpty(vetInfoPropElem))
                    {
                        //'-- recupero le propietà se presenti
                        Grid_ColumnsProperty colProp = new Grid_ColumnsProperty();//CreateObject("CtlHtml.Grid_ColumnsProperty")


                        vetInfoFieldProp = vetInfoPropElem;
                        colProp.Alignment = vetInfoFieldProp[PROP_Alignment];
                        colProp.Dimension = vetInfoFieldProp[PROP_Dimension];
                        colProp.Hide = vetInfoFieldProp[PROP_Hide];
                        colProp.Length = vetInfoFieldProp[PROP_Length];
                        colProp.Name = vetInfoFieldProp[PROP_Name];
                        colProp.OnClickCell = vetInfoFieldProp[PROP_OnClickCell];
                        colProp.Sort = vetInfoFieldProp[PROP_Sort];
                        colProp.Style = vetInfoFieldProp[PROP_Style];
                        colProp.Total = vetInfoFieldProp[PROP_Total];
                        colProp.vAlignment = vetInfoFieldProp[PROP_vAlignment];
                        colProp.width = vetInfoFieldProp[PROP_Width];
                        colProp.Wrap = vetInfoFieldProp[PROP_Wrap];


                        colProp.Expr = vetInfoFieldProp[PROP_Expr];
                        colProp.bSumm = vetInfoFieldProp[PROP_bSumm];
                        colProp.FormatCondition = vetInfoFieldProp[PROP_FormatCondition];


                        lock (fieldProperty)
                        {
                            fieldProperty.Add(fld.Name, colProp);
                        }

                    }
                }
                catch (Exception ex)
                {
                    lock (exList)
                    {
                        exList.Add(ex);
                    }
                }
            });
        }

        async Task LoadAllFieldsAsync(Dictionary<string, HTML.Field> Model, ISession session, dynamic[] vetInfoProp, Dictionary<string, Grid_ColumnsProperty> fieldProperty, int Context)
        {
            List<Exception>? exList = new();
            var tasks = Model.Select(async (fld, index) =>
            {
                await LoadField(fld.Value, session, vetInfoProp[index], fieldProperty, Context, exList);
            });

            await Task.WhenAll(tasks);

            if (exList.Count != 0)
            {
                throw exList.First();
            }

        }

        async Task LoadFieldFromDataRow(
            int i,
            DataRow dr,
            bool bEditable,
            TSRecordSet rsprop,
            int DZT_TYPE,
            string strConnectionString,
            string suffix,
            long idPfu,
            int Context,
            ISession session,
            string noKey,
            bool bNoML,
            bool bCTL,
            Dictionary<string, Grid_ColumnsProperty> fieldProperty,
            Dictionary<string, Field> Model,
            List<Exception> exList)
        {
            await Task.Run((Action)(() =>
            {

                try
                {
                    bool bLocEditable = false;
                    string strCause = string.Empty;
                    string adFilterNone = string.Empty;
                    string Filter = "";
                    string strFormat = "";
                    string dom = "";

                    ClsDomain objdom;
                    Field objField;
                    var objDomains = new LibDBDomains();
                    dynamic objumdom;
                    string umDom = "";
                    string valore = "";
                    string DefaultValue = "";
                    int nMultivalue = 0;

                    string value = CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_Format"]));
                    if (!string.IsNullOrEmpty(value))
                    {
                        strFormat = value;
                    }
                    else
                    {
                        strFormat = "";
                    }

                    lock (rsprop)
                    {
                        //'-- verifico la presenza di una formattazione specifica di modello
                        rsprop.Filter(adFilterNone);
                        rsprop.Filter("MAP_MA_DZT_Name = '" + CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"]) + "' and MAP_Propety='Format'");
                        if (rsprop.RecordCount > 0)
                        {
                            rsprop.MoveFirst();
                            strFormat = CStr(CommonModule.Basic.GetValueFromRS(rsprop.Fields["MAP_Value"]));
                        }
                        rsprop.Filter(adFilterNone);
                    }

                    bLocEditable = bEditable;
                    strCause = "Model: " + CommonModule.Basic.GetValueFromRS(dr["MA_MOD_ID"]) + " - Field: " + CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"]);

                    lock (rsprop)
                    {
                        //'-- filtro le prorietà sull'attributo corrente per determinare la presenza di un filtro sull'attributo
                        rsprop.Filter(adFilterNone);
                        rsprop.Filter("MAP_MA_DZT_Name = '" + CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"]) + "' and MAP_Propety='Filter'");
                        if (rsprop.RecordCount > 0)
                        {
                            Filter = CStr(CommonModule.Basic.GetValueFromRS(rsprop.Fields["MAP_Value"]));
                        }
                        else
                        {
                            Filter = "";
                        }

                        //'-- determina se il campo è editabile
                        rsprop.Filter(adFilterNone);
                        rsprop.Filter("MAP_MA_DZT_Name = '" + CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"]) + "' and MAP_Propety='Editable'");
                        if (rsprop.RecordCount > 0)
                        {
                            bLocEditable = bEditable && cdf.ParseBool(CStr(CommonModule.Basic.GetValueFromRS(rsprop.Fields["MAP_Value"])));
                        }

                        //'-- se il campo non è editabile il dominio viene caricato intero e non filtrato
                        if (!bLocEditable)
                        {
                            //Lo svuoto se non trovo la combinazione O ed M,cioè la format richiede un dominio filtrato sempre per esempio con il checkbox multiselezione
                            if ( !(strFormat.ToUpper().Contains('O') && strFormat.ToUpper().Contains('M')) )
                                Filter = "";
                               
                        }

                        rsprop.Filter(adFilterNone);
                    }

                    //'-- creo il nuovo campo
                    DZT_TYPE = (int)dr["DZT_TYPE"];
                    objField = eProcurementNext.HTML.BasicFunction.getNewField(DZT_TYPE);
                    objField.Language = suffix;
                    objField.ConnectionString = strConnectionString;

                    //'-- recupera il dominio dell'attributo se presente
                    strCause = "recupera il dominio dell'attributo se presente";
                    dom = CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_DM_ID"]));

                    //'-- recupera il dominio dell'attributo se presente
                    strCause = "recupera il dominio dell'attributo se presente";
                    dom = CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_DM_ID"]));

                    if (!string.IsNullOrEmpty(dom))
                    {
                        objdom = objDomains.GetFilteredDomExt(dom, suffix, idPfu, Filter, Context, strConnectionString, session);
                    }
                    else
                    {
                        objdom = null!;
                    }


                    //'-- recupera il dominio dell'unità di misura se presente
                    strCause = "recupera il dominio dell'unità di misura se presente";
                    umDom = CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_DM_ID_um"]));

                    if (!string.IsNullOrWhiteSpace(umDom))
                    {
                        try
                        {
                            //'Set objumdom = objDomains.GetDomExt(umDom, suffix)


                            objumdom = objDomains.GetFilteredDomExt(umDom, suffix, 0, "", 0, strConnectionString, session);
                        }
                        catch
                        {
                            objumdom = null;
                        }
                    }
                    else
                    {
                        objumdom = null;
                    }


                    //'-- imposto il valore di default
                    valore = "";
                    try
                    {
                        valore = CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_ValueDef"]));
                    }
                    catch { }
                    DefaultValue = valore;

                    //'--se attributo TEXT,TEXTAREA,URL applico multilinguismo al default se lo devo risolvere
                    lock (rsprop)
                    {
                        rsprop.Filter(adFilterNone);
                        rsprop.Filter("MAP_MA_DZT_Name = '" + CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"]) + "' and MAP_Propety='DefaultValue'");
                        if (rsprop.RecordCount > 0)
                        {
                            rsprop.MoveFirst();
                            DefaultValue = CStr(CommonModule.Basic.GetValueFromRS(rsprop.Fields["MAP_Value"]));
                            valore = DefaultValue;
                        }
                        rsprop.Filter(adFilterNone);

                    }

                    strCause = "se attributo TEXT,TEXTAREA,URL applico multilinguismo al default";
                    if (!string.IsNullOrEmpty(valore) && (DZT_TYPE == 1 || DZT_TYPE == 3 || DZT_TYPE == 13))
                    {
                        if (UCase(valore).Contains("ML.", StringComparison.Ordinal) || UCase(valore).Contains("SYS.", StringComparison.Ordinal))
                        {
                            valore = ApplicationCommon.CNV(valore, session);
                            DefaultValue = valore;


                            //'--tolgo il prefisso e suffisso per key non trovata
                            if (!string.IsNullOrEmpty(noKey))
                            {
                                if (Strings.Left(valore, Strings.Len(noKey)) == noKey)
                                {
                                    valore = Strings.Mid(valore, Strings.Len(noKey) + 1, Strings.Len(valore) - 2 * Strings.Len(noKey));
                                    DefaultValue = valore;
                                }
                            }
                        }
                    }

                    //'-- Se presente la RegExp sul field nel dizionario aggiungo la validazione formale
                    string strTmpRegExp = "";

                    try
                    {
                        strTmpRegExp = CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_RegExp"]));
                    }
                    catch
                    {
                        strTmpRegExp = "";
                    }

                    lock (rsprop)
                    {
                        //'-- verifico la presenza di un espressione regolare specifica di modello
                        rsprop.Filter(adFilterNone);
                        rsprop.Filter("MAP_MA_DZT_Name = '" + CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"]) + "' and MAP_Propety='RegExp'");
                        if (rsprop.RecordCount > 0)
                        {
                            rsprop.MoveFirst();
                            if (!string.IsNullOrEmpty(CStr(CommonModule.Basic.GetValueFromRS(rsprop.Fields["MAP_Value"]))))
                            {
                                strTmpRegExp = CStr(CommonModule.Basic.GetValueFromRS(rsprop.Fields["MAP_Value"]));
                            }
                        }
                        rsprop.Filter(adFilterNone);
                    }

                    if (!string.IsNullOrEmpty(strFormat) && suffix == "UK")
                    {
                        //'-- per le date si converte la formattazione della data in quella inglese
                        //strFormat = strFormat.Replace("dd/mm/yyyy", "mm/dd/yyyy");   ---- Modificata la porzione del mese che va espressa in Maiuscolo
                        strFormat = ReplaceInsensitive(strFormat, "dd/MM/yyyy", "MM/dd/yyyy");
                    }

                    //'-- imposta il separatore dei decimali definito sull'utente
                    objField.sepDecimal = session["SEP_DECIMALI"];
                    if (objField.sepDecimal != "." & objField.sepDecimal != ",")
                    {
                        objField.sepDecimal = ",";
                    }

                    //'--imposta proprietà multivalore
                    nMultivalue = (CommonModule.Basic.GetValueFromRS(dr["DZT_Multivalue"]) == null ? 0 : CommonModule.Basic.CInt(dr["DZT_Multivalue"]));
                    objField.MultiValue = nMultivalue;


                    strCause = "inizializza il controllo";
                    DZT_TYPE = CommonModule.Basic.GetValueFromRS(dr["DZT_TYPE"]);
                    objField.Init(CommonModule.Basic.GetValueFromRS(dr["DZT_TYPE"]), CStr(CommonModule.Basic.GetValueFromRS(dr["DZT_Name"])), valore, objdom, objumdom, strFormat, bEditable);

                    if (DZT_TYPE != 3) //'-- per i text area si usa come max len la property
                    {
                        try
                        {
                            objField.MaxLen = Convert.ToInt32(CommonModule.Basic.GetValueFromRS(dr["DZT_Len"]));
                        }
                        catch
                        {
                        }
                    }

                    try
                    {
                        objField.numDecimal = Convert.ToInt32(CommonModule.Basic.GetValueFromRS(dr["DZT_dec"]));
                    }
                    catch
                    {
                    }
                    objField.DefaultValue = DefaultValue;

                    try
                    {
                        objField.Position = Convert.ToInt32(CommonModule.Basic.GetValueFromRS(dr["ma_Order"]));

                    }
                    catch
                    {
                    }

                    //'-- Setto l'espressione regolare sul field

                    if (!string.IsNullOrEmpty(strTmpRegExp))
                    {
                        objField.validazioneFormale = true;
                        objField.regExp = strTmpRegExp;
                    }

                    //'-- setto la larghezza del campo definita sul modello
                    objField.width = CInt(CommonModule.Basic.GetValueFromRS(dr["ma_len"]));


                    if (IsNull(dr["ma_descML"]))
                    {
                        objField.Caption = "";
                    }
                    else
                    {

                        //'-- Se il modello proviene dalle CTL e non dalle LIB non chiamo la CNV ma
                        //'-- provo a cercare il multilinguismo dalla tabella CTL_Multilinguismo, se il record manca
                        //'-- ( quindi siamo sulla lingua di default ) utilizzo come multilinguismo la chiave stessa
                        //'-- presente sul modello (ma_descML)

                        if (bNoML == true)
                        {
                            objField.Caption = CStr(CommonModule.Basic.GetValueFromRS(dr["ma_descML"]));
                        }
                        else
                        {
                            if (bCTL)
                            {
                                objField.Caption = CStr(CommonModule.Basic.GetValueFromRS(dr["DescField"]));
                            }
                            else
                            {
                                objField.Caption = ApplicationCommon.CNV(CStr(CommonModule.Basic.GetValueFromRS(dr["ma_descML"])), session);
                            }
                        }
                    }



                    //' objField.Caption = rs.Fields("ML_Description")

                    //'-- per i domini chiusi aggiorna la descrittiva SelectDescription -- Effettuare una selezione --"
                    objField.SetSelectDescription(ApplicationCommon.CNV("-- Effettuare una selezione --", session));
                    objField.SetPrintDescription(ApplicationCommon.CNV("Vedi allegato", session));
                    objField.SetSelezionatiDescription(ApplicationCommon.CNV("Selezionati", session));
                    objField.SetSenzaModali(ApplicationCommon.Application["DISATTIVA_MODALE_MULTIVALORE"]);


                    //'-- setto le descrizioni delle costanti sul campo nella lingua richiesta
                    SetConstLNG(objField, session);

                    lock (rsprop)
                    {
                        // -- carico le propietà dell'attributo
                        rsprop.Filter(adFilterNone);
                        rsprop.Filter("MAP_MA_DZT_Name = '" + CStr(CommonModule.Basic.GetValueFromRS(dr["MA_DZT_Name"])) + "'");
                        if (rsprop.RecordCount > 0)
                        {
                            Grid_ColumnsProperty objProp = new Grid_ColumnsProperty();
                            objProp = SetModelProp(rsprop, objField, session);

                            //'-- associo alla collezione delle propietà le propietà dell'attributo
                            objProp.Name = objField.Name;
                            if ( ! fieldProperty.ContainsKey(objField.Name) )
                                fieldProperty.Add(objField.Name, objProp);
                        }

                        if (!string.IsNullOrEmpty(objField.Help))
                        {
                            objField.Help = ApplicationCommon.CNV(objField.Help, session);
                        }

                        //nuovo indice per riordinare poi i field
                        objField.indexInModel = i;

                        //'-- lo carico nel modello
                        lock (Model)
                        {
                            if (! Model.ContainsKey(objField.Name) )
                                Model.Add(objField.Name, objField);
                        }

                    }
                }
                catch (Exception ex)
                {
                    lock (exList)
                    {
                        exList.Add(ex);
                    }
                }


            }));
        }

        async Task LoadModelAsync(TSRecordSet rs, bool bEditable, TSRecordSet rsprop, int DZT_TYPE, string strConnectionString, string suffix, long idPfu, int Context, ISession session, string noKey, bool bNoML, bool bCTL, Dictionary<string, Grid_ColumnsProperty> fieldProperty, Dictionary<string, Field> Model)
        {

           

            List<Exception>? exList = new();
            var tasks = rs.dt.AsEnumerable().Select(async (dr, i) =>
            {
                await LoadFieldFromDataRow(i, dr, bEditable, rsprop, DZT_TYPE, strConnectionString, suffix, idPfu, Context, session, noKey, bNoML, bCTL, fieldProperty, Model, exList);
            });

            await Task.WhenAll(tasks);

            if (exList.Count != 0)
            {
                throw exList.First();
            }
        }

        public string GetFilteredFieldsCTL(string strModelName, ref Dictionary<string, HTML.Field> Model, ref Dictionary<string, Grid_ColumnsProperty> fieldProperty, string suffix, long idPfu, int Context, string strConnectionString, eProcurementNext.Session.ISession session, bool bEditable, string idDoc = "")
        {
            string GetFilteredFieldsCTLRet = "";
            TSRecordSet? rs;
            TSRecordSet? rsprop;
            TSRecordSet? rsTemplate;

            string adFilterNone = "";      // richiesto per i recordset
            string strCause = "";
            string strSQL = "";

            ClsDomain objdom;
            dynamic objumdom;

            string valore = "";
            string DefaultValue = "";

            HTML.Field objField;
            string dom = "";
            string umDom = "";
            string Filter = "";
            string strModelNameCache;

            var objDomains = new LibDBDomains();
            bool bLocEditable;

            bool bNew = false;
            bool bNewIDoc = false;
            dynamic objCache;
            dynamic[] vetInfo;
            dynamic[] vetInfoField;
            dynamic[] vetInfoProp;
            dynamic[] vetInfoFieldProp;
            int i = 0;
            int c;
            Grid_ColumnsProperty colProp;
            string strFormat = "";
            int nMultivalue = 0;
            string Template = "";
            string MOD_PARAM = "";
            bool bCTL = false;

            int DZT_TYPE = 0;

            Dictionary<string, object?> sqlParams = new Dictionary<string, object?>();

            try
            {

                rsprop = new TSRecordSet();

                // -- creo le collezioni
                Model = new Dictionary<string, HTML.Field>();
                fieldProperty = new Dictionary<string, Grid_ColumnsProperty>();

                strModelNameCache = $"CTL_MODEL_{strModelName}_{Context}_{suffix}_{bEditable}";
                objCache = ApplicationCommon.Cache;
                
                //'-- VERIFICA SE IN MEMORIA ESISTE IL MODELLO DEL DOCUMENTO
                //'-- in questo caso cambio il nome in cache
                if (!string.IsNullOrEmpty(idDoc))
                {

                    //Dim sessionASP As Object
                    //Set sessionASP = session(OBJSESSION)
                    bNewIDoc = true;

                    string? strModel = session[$"CTL_MODEL_{strModelName}_{idDoc}"];

                    if (!string.IsNullOrEmpty(strModel))
                    {
                        strModelNameCache = $"CTL_MODEL_{strModelName}_{idDoc}";


                        objCache = session;


                        bNewIDoc = false;


                    }
                    else
                    {
                        //'-- DEVO VERIFICARE SE ESISTE UNA VERSIONE SALVATA IN QUESTO CASO DEVO RICARE DAL DISCO
                        
                        //if (Strings.LCase(Strings.Left(idDoc, 3)) != "new")
                        if (idDoc.Substring(0, 3).ToLower() != "new")
                        {
                            objCache = session;
                        }


                    }
                }

                bNew = true;

                //'-- se il modello è in memoria lo ricreo partendo dalla memoria
                if (!string.IsNullOrEmpty(objCache[strModelNameCache]))
                {
                    bNew = false;

                    //new Code Refactoring
                    Dictionary<string, Field> tempModel = new();
                    foreach (KeyValuePair<string, Field> field in objCache[strModelNameCache + "_ModelRefactoringNext"])
                    {
                        tempModel.Add(field.Key, (Field)field.Value.Clone());
                    }
                    Model = tempModel;
                    //end new Code Refactoring 


                    //'-- creo il vettore per contenere tutti gli attributi
                    MOD_PARAM = objCache[strModelNameCache + "_GetFilteredFields"];
                    GetFilteredFieldsCTLRet = MOD_PARAM;
                    vetInfoProp = objCache[strModelNameCache + "_FieldProp"];

                    LoadAllFieldsAsync(Model, session, vetInfoProp, fieldProperty, Context).Wait();

                }

                if (bNew == true)
                {
                    rs = null;

                    //'-- verifico se esiste una versione del modello sul documento  '" 
                    if (!string.IsNullOrEmpty(idDoc))
                    {
                        sqlParams.Add("@ModelName", strModelName + "_" + idDoc);
                        StringBuilder sb = new StringBuilder("select  MOD_Param , CTL_modelattributes.* ,MOD_Template , MA_DZT_Name as DZT_Name ");
                        sb.Append("From CTL_modelattributes with(nolock), CTL_models with(nolock) ");
                        sb.Append("where MOD_Name = '" + strModelName.Replace("'", "''") + "_" + idDoc + "' and MOD_ID = MA_MOD_ID order by ma_order");
                        strSQL = sb.ToString();

                        rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString);
                        if (rs.RecordCount == 0)
                        {
                            rs = null;
                        }
                        else
                        {

                            if (!IsNull(rs.Fields["MOD_Template"]) && !string.IsNullOrEmpty(CStr(rs.Fields["MOD_Template"]).Trim()))
                            {
                                Template = CStr(rs.Fields["MOD_Template"]);
                            }


                            //'-- recupero le propietà degli attributi
                            sqlParams.Clear();

                            //sqlParams.Add("@ModelName", strModelName);
                            //rsprop = cdf.GetRSReadFromQuery_("select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = @ModelName", strConnectionString, null, parCollection: sqlParams);
                            rsprop = cdf.GetRSReadFromQuery_($"select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = '{strModelName.Replace("'","''")}'", strConnectionString);
                        }
                    }

                    //'-- recupero gli attributi da caricare
                    string noKey = "";
                    if (rs is null)
                    {
                        int numRec;

                        try
                        {
                            sqlParams.Clear();
                            sqlParams.Add("@suffix", suffix);
                            sqlParams.Add("@ModelName", strModelName);

                            System.Text.StringBuilder sb = new System.Text.StringBuilder("select distinct MOD_Param, ctAttr.MA_ID, ctAttr.MA_MOD_ID, ctAttr.MA_DZT_Name, ctAttr.MA_DescML, ctAttr.MA_Pos, ctAttr.MA_Len, ctAttr.MA_Order, ctAttr.MA_Module, ");
                            sb.Append(" ISNULL(ctMlg.ML_Description, ctAttr.MA_DescML) as DescField,");
                            sb.Append(" isnull( dzt.DZT_Type, ctattr.DZT_Type) as DZT_Type,");
                            sb.Append(" isnull( dzt.DZT_DM_ID, ctattr.DZT_DM_ID) as DZT_DM_ID,");
                            sb.Append(" isnull( dzt.DZT_DM_ID_Um, ctattr.DZT_DM_ID_Um) as DZT_DM_ID_Um,");
                            sb.Append(" isnull( dzt.DZT_Len, ctattr.DZT_Len) as DZT_Len,");
                            sb.Append(" isnull( dzt.DZT_Dec, ctattr.DZT_Dec) as DZT_Dec,");
                            sb.Append(" isnull( dzt.DZT_Format, ctattr.DZT_Format) as DZT_Format,");
                            sb.Append(" isnull( dzt.DZT_Help, ctattr.DZT_Help) as DZT_Help,");
                            sb.Append(" isnull( dzt.DZT_Multivalue, ctattr.DZT_Multivalue) as DZT_Multivalue,");
                            sb.Append(" isnull( dzt.DZT_Name , ctAttr.MA_DZT_Name ) as DZT_Name  , isnull( dzt.DZT_DescML, ctAttr.MA_DescML) as DZT_DescML, isnull( dzt.DZT_Sys , 1 ) as DZT_Sys , dzt.DZT_ValueDef, dzt.DZT_RegExp");
                            sb.Append(" From CTL_models with(nolock)");
                            sb.Append("         inner join CTL_modelattributes ctAttr with(nolock) ON  MOD_ID = ctAttr.MA_MOD_ID");
                            sb.Append("         left join CTL_Multilinguismo ctMlg with(nolock)   ON MA_DescML = ML_KEY and ml_lng = @suffix");
                            sb.Append("         left join LIB_Dictionary dzt with(nolock)   ON DZT_Name = MA_DZT_Name");
                            sb.Append(" where MOD_Name = '" + strModelName.Replace("'","''") + "' and isnull( dzt.DZT_Type, ctattr.DZT_Type) is not null");
                            sb.Append(" order by ma_order");

                            strSQL = sb.ToString();

                            //'-- verifico se il modello è presente nelle tabelle CTL
                            rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, null, parCollection: sqlParams);
                            numRec = rs.RecordCount;
                        }
                        catch
                        {
                            numRec = 0;
                        }

                        sqlParams.Clear();
                        sqlParams.Add("@ModelName", strModelName);
                        if (numRec <= 0)
                        {
                            StringBuilder sb = new StringBuilder();
                            sb.Append("select distinct MOD_Param, lib_modelattributes.*, LIB_Dictionary.* ");
                            sb.Append("From LIB_Dictionary, lib_modelattributes, lib_models ");
                            sb.Append("where DZT_Name = MA_DZT_Name and MOD_Name = @ModelName and MOD_ID = MA_MOD_ID order by ma_order");
                            strSQL = sb.ToString();

                            rs = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, null, parCollection: sqlParams);

                            //!-- recupero le propietà degli attributi
                            try
                            {
                                rsprop = cdf.GetRSReadFromQuery_("select * from LIB_ModelAttributeProperties_Customized where MAP_MA_MOD_ID = @ModelName ", strConnectionString, null, parCollection: sqlParams);
                            }
                            catch
                            {
                                //!-- se c'è un errore allora non cè la vista che guarda le proprità custom
                                rsprop = cdf.GetRSReadFromQuery_("select * from lib_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = @ModelName", strConnectionString, null, parCollection: sqlParams);
                            }

                            bCTL = false;
                        }
                        else
                        {
                            //'-- recupero le propietà degli attributi
                            //rsprop = cdf.GetRSReadFromQuery_("select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = @ModelName", strConnectionString, null, parCollection: sqlParams);
                            rsprop = cdf.GetRSReadFromQuery_($"select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = '{strModelName.Replace("'", "''")}'", strConnectionString);
                            bCTL = true;
                        }

                        if (rs is null)
                            return GetFilteredFieldsCTLRet;
                        if (rs.RecordCount <= 0)
                            return GetFilteredFieldsCTLRet;

                        //'-- recupero il template

                        noKey = string.Empty;
                        var TempMame = string.Empty;


                        Template = ApplicationCommon.CNV(strModelName, session);
                        noKey = session["NoMLKey"];

                        if (string.IsNullOrEmpty(noKey))
                        {
                            noKey = "???";
                        }

                        if (strModelName == Strings.Left(Strings.Replace(Template, noKey, ""), Strings.Len(strModelName)))
                        {
                            sqlParams.Clear();
                            sqlParams.Add("@ModelName", strModelName);
                            if (bCTL == true)
                            {
                                //rsTemplate = cdf.GetRSReadFromQuery_("select MOD_Template from CTL_models with(nolock) where MOD_Name = @ModelName", strConnectionString, null, parCollection: sqlParams);
                                rsTemplate = cdf.GetRSReadFromQuery_($"select MOD_Template from CTL_models with(nolock) where MOD_Name = '{strModelName.Replace("'", "''")}'", strConnectionString);
                            }
                            else
                            {
                                rsTemplate = cdf.GetRSReadFromQuery_("select MOD_Template from lib_models with(nolock) where MOD_Name = @ModelName", strConnectionString, null, parCollection: sqlParams);
                            }

                            if (rsTemplate != null)
                            {

                                Template = CStr(GetValueFromRS(rsTemplate.Fields["MOD_Template"]));
                                Template = Template.Trim();

                                if (!string.IsNullOrEmpty(Template))
                                {
                                    //'--ricolso pattern ML. SYS.
                                    if (Template.Contains("#ML.", StringComparison.Ordinal) | Template.Contains("#SYS.", StringComparison.Ordinal))
                                    {
                                        LibDbDictionary objDiz = new LibDbDictionary();
                                        Template = RisolvoML_SYS(Template, suffix, Context, session, objDiz);
                                    }
                                }
                            }
                        }


                    }

                    if (rs == null)
                        throw new NullReferenceException("rs null");


                    //'-- per ogni attributo carico la collezione del modello ed i suoi attributi
                    rs.MoveFirst();

                    DZT_TYPE = (int)rs.Fields["DZT_TYPE"];

                    if (IsNull(GetValueFromRS(rs.Fields["MOD_Param"])))
                    {
                        GetFilteredFieldsCTLRet = "";
                        MOD_PARAM = "";
                    }
                    else
                    {
                        MOD_PARAM = CStr(GetValueFromRS(rs.Fields["MOD_Param"]));
                        GetFilteredFieldsCTLRet = MOD_PARAM;
                    }

                    //'-- verifico se è stato chiesto di non applicare il ML
                    var bNoML = GetParam(MOD_PARAM, "ML").ToUpper() == "NO";

                    LoadModelAsync(rs, bEditable, rsprop, DZT_TYPE, strConnectionString, suffix, idPfu, Context, session, noKey, bNoML, bCTL, fieldProperty, Model).Wait();
                    Model = Model.OrderBy((fld) => fld.Value.indexInModel).ToDictionary(x => x.Key, x => x.Value);
                }

                //!-- se è nuovo lo conservo in memoria
                if (bNew)
                {
                    SaveModelInCache(ApplicationCommon.Cache, strModelNameCache, Model, fieldProperty, suffix, idPfu, Context, strConnectionString, session, bEditable, Template, MOD_PARAM, idDoc);
                }


                //!-- salvo in memoria anche il modello del documento

                if (!string.IsNullOrEmpty(idDoc) && bNewIDoc)
                {


                    strModelNameCache = "CTL_MODEL_" + strModelName + "_" + idDoc;
                    SaveModelInCache(session, strModelNameCache, Model, fieldProperty, suffix, idPfu, Context, strConnectionString, session, bEditable, Template, MOD_PARAM, idDoc);
                }

            }
            catch (Exception ex)
            {
                throw new Exception($@"{strCause} - {ex.Message}", ex);
            }

            return GetFilteredFieldsCTLRet;
        }

        public void SaveModelInCache(ITSCollection objCache, string strModelNameCache, Dictionary<string, Field> Model, Dictionary<string, Grid_ColumnsProperty> fieldProperty, string suffix, long idPfu, int Context, string strConnectionString, Session.ISession session, bool bEditable, string Template, string MOD_PARAM, string idDoc = "")
        {

            dynamic[] vetInfo = new dynamic[Model.Count];
            dynamic[] vetInfoField;
            dynamic[] vetInfoProp = new dynamic[Model.Count];
            dynamic[] vetInfoFieldProp;

            objCache[strModelNameCache] = "YES";

            //new Code Refactoring
            Dictionary<string, Field> tempModel = new Dictionary<string, Field>();
            foreach (KeyValuePair<string, Field> field in Model)
            {
                tempModel.Add(field.Key, (Field)field.Value.Clone());
            }
            objCache[strModelNameCache + "_ModelRefactoringNext"] = tempModel;
            //end new Code Refactoring

            //'-- creo il vettore per contenere tutti gli attributi

            //ReDim vetInfo(Model.Count) As Variant
            //ReDim vetInfoProp(Model.Count) As Variant
            objCache[strModelNameCache + "_NumField"] = Model.Count;
            int c;
            int i;
            Grid_ColumnsProperty colProp = null;

            c = Model.Count;

            //On Error Resume Next
            for (i = 0; i < Model.Count; i++)
            {

                vetInfoField = new dynamic[FIELD_NUMPROP + 1];

                //'-- recupero il vettore con le informazioni del campo
                Model.ElementAt(i).Value.GetVetInfo(ref vetInfoField);

                vetInfo[i] = vetInfoField;

                //'-- recupero le propiet� se presenti
                colProp = null;
                if (fieldProperty.ContainsKey(Model.ElementAt(i).Value.Name))
                {
                    colProp = fieldProperty[Model.ElementAt(i).Value.Name];
                }
                //err.Clear

                if (colProp != null)
                {

                    vetInfoFieldProp = new dynamic[15];

                    vetInfoFieldProp[PROP_Alignment] = colProp.Alignment;
                    vetInfoFieldProp[PROP_Dimension] = colProp.Dimension;
                    vetInfoFieldProp[PROP_Hide] = colProp.Hide;
                    vetInfoFieldProp[PROP_Length] = colProp.Length;
                    vetInfoFieldProp[PROP_Name] = colProp.Name;
                    vetInfoFieldProp[PROP_OnClickCell] = colProp.OnClickCell;
                    vetInfoFieldProp[PROP_Sort] = colProp.Sort;
                    vetInfoFieldProp[PROP_Style] = colProp.Style;
                    vetInfoFieldProp[PROP_Total] = colProp.Total;
                    vetInfoFieldProp[PROP_vAlignment] = colProp.vAlignment;
                    vetInfoFieldProp[PROP_Width] = colProp.width;
                    vetInfoFieldProp[PROP_Wrap] = colProp.Wrap;
                    vetInfoFieldProp[PROP_Expr] = colProp.Expr;
                    vetInfoFieldProp[PROP_bSumm] = colProp.bSumm;
                    vetInfoFieldProp[PROP_FormatCondition] = colProp.FormatCondition;


                    vetInfoProp[i] = vetInfoFieldProp;



                }
                else
                {

                    //'vetInfoProp = Empty

                }
            }

            //objCache[strModelNameCache + "_Field"] = vetInfo;
            objCache[strModelNameCache + "_FieldProp"] = vetInfoProp;
            objCache[strModelNameCache + "_GetFilteredFields"] = MOD_PARAM;
            objCache[strModelNameCache + "_Template"] = Template;

            objCache.Save();

        }



        /// <summary>
        /// '-- ritorna un oggetto di tipo modello prelevando tutta la configurazione dal DB
        /// </summary>
        /// <param name="strModelName"></param>
        /// <param name="suffix"></param>
        /// <param name="idPfu"></param>
        /// <param name="session"></param>
        /// <param name="Context"></param>
        /// <param name="ConnectionStringOpt"></param>
        /// <param name="bEditable"></param>
        /// <param name="idDoc"></param>
        /// <returns></returns>
        public dynamic GetFilteredModelCTL(string strModelName, string suffix, long idPfu, ISession session, int Context = 0, string strConnectionStringOpt = "", bool bEditable = true, string idDoc = "")
        {
            Model objMod = new Model();
            Dictionary<string, HTML.Field> Model = new Dictionary<string, HTML.Field>();
            Dictionary<string, Grid_ColumnsProperty> fieldProperty = new Dictionary<string, Grid_ColumnsProperty>();
            //Dim rs As ADODB.Recordset
            string strValParam = "";

            string strModelNameCache = "";


            try
            {

                strModelNameCache = "CTL_MODEL_" + strModelName + "_" + Context + "_" + suffix + "_" + bEditable;
                if (!String.IsNullOrEmpty(idDoc))
                {
                    strModelNameCache = strModelNameCache + "_" + idDoc;
                }


                //'-- recupera le informazioni del modello
                strValParam = GetFilteredFieldsCTL(strModelName, ref Model, ref fieldProperty, suffix, idPfu, Context, strConnectionStringOpt, session, bEditable, idDoc);

                objMod.Fields = Model;
                objMod.PropFields = fieldProperty;
                objMod.id = strModelName;

            }
            catch (Exception ex)
            {
                throw new Exception("Lib_dbDictionary.GetFilteredField(" + ex.Message + ")", ex);

            }

            //'-- recupera i parametri del modello
            if (!string.IsNullOrEmpty(strValParam))
            {
                Dictionary<string, string> param;
                string strVal;
                param = eProcurementNext.HTML.BasicFunction.GetCollection(strValParam);

                if (param.ContainsKey("DrawMode"))
                {
                    objMod.DrawMode = CInt(param["DrawMode"]);

                }
                if (param.ContainsKey("NumberColumn"))
                {
                    objMod.NumberColumn = CInt(param["NumberColumn"]);

                }
                if (param.ContainsKey("Style"))
                {
                    objMod.Style = CStr(param["Style"]);


                }

                objMod.param = strValParam;
            }



            objMod.Template = ApplicationCommon.Cache[strModelNameCache + "_Template"];


            return objMod;

        }

        public void SaveDocModel(string PnameMod, ISession session, SqlConnection cnLocal, string id_REF, string id_Documento)
        {
            //Dim sessionASP As Object
            //Set sessionASP = session(OBJSESSION)

            string DZT_Name;
            string strConS;
            string modulo;
            string nameMod;
            string str;
            //dynamic v;


            dynamic[] vetInfo;
            dynamic[] vetInfoField;
            dynamic[] vetInfoProp;
            dynamic[] vetInfoFieldProp;

            string strModelNameCache;
            strModelNameCache = "CTL_MODEL_" + PnameMod + "_" + id_REF;

            nameMod = PnameMod; //'objModel



            //Collection colAttr;
            //Collection colProp;



            TSRecordSet rsM;
            TSRecordSet rsA;
            TSRecordSet rsP;

            try
            {
                //'-- cancello il modello dalle tabelle
                cdf.Execute("delete from CTL_ModelAttributeProperties where MAP_MA_MOD_ID = '" + nameMod + "_" + id_REF + "'", ApplicationCommon.Application.ConnectionString);
                cdf.Execute("delete from CTL_ModelAttributes where MA_MOD_ID = '" + nameMod + "_" + id_REF + "'", ApplicationCommon.Application.ConnectionString);
                cdf.Execute("delete from CTL_Models where MOD_ID = '" + nameMod + "_" + id_REF + "'", ApplicationCommon.Application.ConnectionString);


                //'-- salvo il modello

                //rsM.Open("select top 0 * from CTL_Models", ApplicationCommon.Application.ConnectionString);
                rsM = cdf.GetRSReadFromQuery_("select top 0 * from CTL_Models", ApplicationCommon.Application.ConnectionString);
                DataRow drM = rsM.AddNew();
                drM["MOD_ID"] = nameMod + "_" + id_Documento;      // 
                drM["MOD_Name"] = nameMod + "_" + id_Documento;
                drM["MOD_DescML"] = nameMod + "_" + id_Documento;
                drM["MOD_Type"] = "1"; //' IIf(mp_TypeModel = "griglia", 1, 2);
                drM["MOD_Sys"] = true;
                drM["MOD_help"] = "";
                drM["MOD_Param"] = session[strModelNameCache + "_GetFilteredFields"]; //'objModel.param

                drM["MOD_Template"] = session[strModelNameCache + "_Template"];

                //'If (objModel.Template <> "") Then
                //'    rsM.Fields("MOD_Template") = objModel.Template
                //'End If

                rsM.Update(drM, "id", "CTL_Models");


                int c;
                int i;



                vetInfo = session[strModelNameCache + "_Field"];
                vetInfoProp = session[strModelNameCache + "_FieldProp"];
                c = session[strModelNameCache + "_NumField"];

                rsP = cdf.GetRSReadFromQuery_("select top 0 * from CTL_ModelAttributeProperties", ApplicationCommon.Application.ConnectionString);
                rsA = cdf.GetRSReadFromQuery_("select top 0 * from CTL_ModelAttributes", ApplicationCommon.Application.ConnectionString);

                //For i = 1 To c
                for (i = 1; i <= c; i++)
                {
                    vetInfoField = vetInfo[i];
                    DataRow drA = rsA.AddNew();

                    DZT_Name = vetInfoField[FIELD_Name];
                    drA["MA_MOD_ID"] = nameMod + "_" + id_Documento;
                    drA["MA_DZT_Name"] = vetInfoField[FIELD_Name];

                    drA["MA_DescML"] = vetInfoField[FIELD_Caption];
                    drA["MA_Len"] = vetInfoField[FIELD_MaxLen];
                    drA["MA_Pos"] = vetInfoField[FIELD_Position];
                    drA["MA_Order"] = vetInfoField[FIELD_Position];


                    drA["DZT_Type"] = CInt(vetInfoField[FIELD_mp_iType]);
                    drA["DZT_DM_ID"] = vetInfoField[FIELD_Domain];
                    drA["DZT_DM_ID_Um"] = vetInfoField[FIELD_umDomain];


                    drA["DZT_Len"] = vetInfoField[FIELD_MaxLen];
                    drA["DZT_Dec"] = vetInfoField[FIELD_numDecimal];
                    drA["DZT_Format"] = vetInfoField[FIELD_strFormat];
                    drA["DZT_Help"] = vetInfoField[FIELD_Help];
                    drA["DZT_Multivalue"] = vetInfoField[FIELD_Multivalue];

                    rsA.Update(drA, "MA_ID", "CTL_ModelAttributes");

                    if (!IsEmpty(vetInfoProp[i]))
                    {
                        vetInfoFieldProp = vetInfoProp[i];



                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Dimension", vetInfoFieldProp[PROP_Dimension]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Hide", IIF(vetInfoFieldProp[PROP_Hide], "1", ""));
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Length", vetInfoFieldProp[PROP_Length]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "OnClickCell", vetInfoFieldProp[PROP_OnClickCell]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Sort", IIF(vetInfoFieldProp[PROP_Sort], "1", ""));
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Width", vetInfoFieldProp[PROP_Width]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Alignment", vetInfoFieldProp[PROP_Alignment]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "vAlignment", vetInfoFieldProp[PROP_vAlignment]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Style", vetInfoFieldProp[PROP_Style]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Total", IIF(vetInfoFieldProp[PROP_Total], "1", ""));
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Wrap", IIF(vetInfoFieldProp[PROP_Wrap], "1", ""));
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Expr", vetInfoFieldProp[PROP_Expr]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "bSumm", IIF(vetInfoFieldProp[PROP_bSumm], "1", ""));
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "FormatCondition", vetInfoFieldProp[PROP_FormatCondition]);



                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Editable", vetInfoField[FIELD_Editable]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Obbligatory", IIF(vetInfoField[FIELD_Obbligatory], "1", ""));
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Format", vetInfoField[FIELD_strFormat]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "ColSpan", vetInfoField[FIELD_colspan]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Help", vetInfoField[FIELD_Help]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "OnChange", vetInfoField[FIELD_mp_OnChange]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "OnClick", vetInfoField[FIELD_mp_OnClick]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "DefaultValue", vetInfoField[FIELD_DefaultValue]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "PathImage", vetInfoField[FIELD_PathImage]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Path", vetInfoField[FIELD_Path]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "MaxLen", vetInfoField[FIELD_MaxLen]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "Rows", vetInfoField[FIELD_Rows]);
                        AddPropModelDB(rsP, nameMod + "_" + id_Documento, DZT_Name, "SQLCondition", Strings.Mid(vetInfoField[FIELD_Condition], 2, Len(vetInfoField[FIELD_Condition]) - 2));


                    }
                }

                //rsA.Close();
                //rsP.Close();
            }
            catch (Exception ex)
            {

                throw new Exception(" SaveDocModel( " + ex.Message + " )", ex);
            }
        }

        private void AddPropModelDB(TSRecordSet rsP, string NomeModello, string DZT_Name, string Property, string value)
        {
            if (!String.IsNullOrEmpty(value))
            {
                DataRow drP = rsP.AddNew();

                drP["MAP_MA_MOD_ID"] = NomeModello;
                drP["MAP_MA_DZT_Name"] = DZT_Name;

                drP["MAP_Propety"] = Property;
                drP["MAP_Value"] = value;

                rsP.Update(drP, "MAP_IP", "CTL_ModelAttributeProperties");
            }

        }



        private Grid_ColumnsProperty SetModelProp_(Dictionary<string, object> prop, HTML.Field objField, dynamic session)
        {
            if (prop == null)
            {
                return null;
            }

            Grid_ColumnsProperty obj = new Grid_ColumnsProperty();

            if (prop.ContainsKey("Width")) { obj.width = prop["Width"].ToString(); }
            if (prop.ContainsKey("Length")) { obj.Length = Convert.ToInt32(prop["Length"].ToString()); }
            if (prop.ContainsKey("Alignment")) { obj.Alignment = prop["Alignment"].ToString(); }
            if (prop.ContainsKey("vAlignment")) { obj.vAlignment = prop["vAlignment"].ToString(); }
            if (prop.ContainsKey("Style")) { obj.Style = prop["Style"].ToString(); }
            if (prop.ContainsKey("OnClickCell")) { obj.OnClickCell = prop["OnClickCell"].ToString(); }
            if (prop.ContainsKey("Total")) { obj.Total = cdf.ParseBool(prop["Total"].ToString()); }
            if (prop.ContainsKey("Sort")) { obj.Sort = cdf.ParseBool(prop["Sort"].ToString()); }
            if (prop.ContainsKey("Wrap")) { obj.Wrap = cdf.ParseBool(prop["Wrap"].ToString()); }
            if (prop.ContainsKey("Hide")) { obj.Hide = cdf.ParseBool(prop["Hide"].ToString()); }

            return obj;

        }

        public string GetFilteredFields(string strModelName, ref Dictionary<string, HTML.Field> Model, ref Dictionary<string, Grid_ColumnsProperty> fieldProperty, string suffix, long idPfu, int Context, string strConnectionString, eProcurementNext.Session.ISession session, bool bEditable)
        {
            return GetFilteredFieldsCTL(strModelName, ref Model, ref fieldProperty, suffix, idPfu, Context, strConnectionString, session, bEditable, "");
        }
    }
}