using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using StackExchange.Redis;
using System.Web;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.DashBoard
{
    public class ViewerGriglia
    {
        private dynamic mp_ObjSession;//'-- oggetto che contiene il vettore base con gli elementi della libreria
        private string mp_Suffix;
        private long mp_User;
        private string mp_Permission;
        private string mp_strConnectionString;

        private Toolbar mp_objToolbar;
        private Grid mp_objGrid;
        private Fld_Label mp_objHelp;
        private ScrollPage mp_grSP;

        private Dictionary<string, Field> mp_Columns;
        private Dictionary<string, Field> mp_ColumnsProp;
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty;

        private LibDbModelExt mp_objDB;
        private TabManage mp_ObjTabManager;

        private string mp_strcause;
        private string mp_Filter = "";
        private string mp_FilterHide;
        private string mp_NumeroPagina;
        private string mp_Sort;
        private string mp_SortOrder;

        private dynamic Request_QueryString;
        private IFormCollection Request_Form;
        private string mp_strTable; //'-- nome della tabella di riferimento per la funzione
        private string mp_queryString;
        private int mp_Row_For_Page;
        private long mp_numRec;
        private string mp_IDENTITY;

        private Fld_Hidden mp_fldCurFiltro;
        private Fld_Hidden mp_fldCurPag;
        private Fld_Hidden mp_fldCurSort;
        private Fld_Hidden mp_fldCurSortOrder;
        private Fld_Hidden mp_fldCurTable;
        private Fld_Hidden mp_fldQueryString;
        private PropertySelector mp_objModel;
        private Form mp_objForm;
        private ButtonBar mp_ObjButtonBar;

        private string mp_ModFiltroAdd;
        private string mp_ModFiltroUpd;

        private string mp_StrToolbar;
        private string mp_strPathJSToolBar;
        private string mp_OWNER;
        private string mp_StrMsg;
        private string mp_Top;
        private string mp_StrDocumentType;
        private string mp_Property;
        private string mp_PropertyH;
        private string mp_PropertyW;
        private string mp_queryStringProp;
        private string mp_RSConnectionString = ""; //'-- se � presente una particolare connection string per la query
        private string mp_JS;
        private string mp_ModGriglia;
        private long mp_timeout;
        private string mp_Calendar;
        private string mp_FieldStyle;

        private Calendar mp_objCalendar;
        private ScrollDate mp_grSD; // = new ScrollDate();

        private int mp_MESI_CALENDAR;
        private string mp_strStoredSQL;
        private Model mp_objModelPos;
        private long mp_numrecord; //'int andava in overflow
        private string mp_ModFiltro;
        private string mp_idViewer;
        private dynamic mp_DATA_CALENDAR;

        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsPropertyProp;
        private bool mp_ShowProperty;
        private string mp_PosToolbar;
        private string mp_Info_User_Profile;

        public string mp_accessible;

        public IConfiguration configuration;

        private HttpContext _context;
        private eProcurementNext.Session.ISession _session;
        private EprocResponse _response;

        private CommonDbFunctions cdf;

        public ViewerGriglia(IConfiguration configuration, HttpContext context, eProcurementNext.Session.ISession session, EprocResponse response)
        {
            this.configuration = configuration;
            this._session = session;
            mp_fldCurFiltro = new Fld_Hidden();
            mp_fldCurPag = new Fld_Hidden();
            mp_fldCurSort = new Fld_Hidden();
            mp_fldCurSortOrder = new Fld_Hidden();
            mp_fldCurTable = new Fld_Hidden();
            mp_fldQueryString = new Fld_Hidden();
            this._context = context;
            this._response = response;
            cdf = new CommonDbFunctions();
        }


        public dynamic run(EprocResponse _response)
        {

            //'-- recupero variabili di sessione
            InitLocal();

            //'-- Controlli di sicurezza
            if (checkHackSecurity(_session, _response))
            {
                //'Se � presente NOMEAPPLICAZIONE nell'application
                if (!String.IsNullOrEmpty(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]))
                {
                    _context.Response.Redirect($"/{Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]}/blocked.asp");
                }
                else
                {
                    _context.Response.Redirect($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp");
                    return null;
                }
            }




            //'-- Esegue i comando richiesti sulla tabella come add,del upd
            ExecuteAction();

            //'-- Inizializzo gli oggetti dell'interfaccia
            InitGUIObject(_response);

            //'-- disegna la lista dei ricambi
            return Draw("", _response);

        }

        private void ExecuteAction()
        {
            long idRow = 0;
            string se = string.Empty;

            if (GetParamURL(Request_QueryString, "MODE").ToUpper() == "ADD")
            {
                try
                {
                    Add(Request_Form, mp_strTable, mp_strConnectionString);
                }
                catch
                {
                    // se = err.Description ??
                    mp_StrMsg = Application.ApplicationCommon.CNV("Impossibile aggiungere il record in", _session) + mp_strTable + ": " + Environment.NewLine + se;
                }
            }

            if (GetParamURL(Request_QueryString, "MODE").ToUpper() == "DEL")
            {
                try
                {
                    idRow = GetParamURL(Request_QueryString, "IDROW");
                    DEL(idRow, mp_strTable, mp_strConnectionString);
                }
                catch
                {
                    // se = err.Description ??
                    mp_StrMsg = Application.ApplicationCommon.CNV("Impossibile eliminare il record in", _session) + mp_strTable + ": " + Environment.NewLine + se;
                }
            }

            if (GetParamURL(Request_QueryString, "MODE").ToUpper() == "UPD")
            {
                try
                {
                    idRow = GetParamURL(Request_QueryString, "IDROW");
                    UPD(idRow, Request_Form, mp_strTable, mp_strConnectionString);
                }
                catch
                {
                    // se = err.Description ??
                    mp_StrMsg = Application.ApplicationCommon.CNV("Impossibile aggiornare il record in", _session) + mp_strTable + ": " + Environment.NewLine + se;
                }
            }
        }

        private string AddMese(string strData)
        {
            int a = 0;
            int m = 0;
            DateTime d;
            int Year = Convert.ToInt32(strData.Substring(0, 4));
            int Month = Convert.ToInt32(strData.Substring(5, 2)) + 1;
            int Day = 1;
            d = new DateTime(Year, Month, Day);
            return d.Date.ToString("yyyy-MM-dd");
        }

        // '-- date le propriet� di visualizzazione riordina le colonne della collezione ed elimina le colonne in eccesso
        private bool InitGuiObject_SetColumnPosition(Dictionary<string, Field> Attrib, string strProperty)
        {
            bool result = true;

            bool bNonTutte = false;
            int n = default;
            int i = default;
            Dictionary<string, Field> newCol = new Dictionary<string, Field>();
            Field obj;
            string[] strVetAttrib = new string[0];
            dynamic strVetProp;

            strVetAttrib = strProperty.Split("#");

            n = strVetAttrib.GetUpperBound(0);
            for (i = 0; i < n; i++)
            {
                if (!String.IsNullOrEmpty(strVetAttrib[i]))
                {
                    strVetProp = strVetAttrib[i].Split(",");

                    //'-- se l'attributo � da visualizzare lo clono nella nuova collezione
                    if (strVetProp[1] == "1")
                    {
                        obj = Attrib[strVetProp[0]];
                        newCol.Add(obj.Name, (Field)obj.Clone());
                    }

                    Attrib.Remove(strVetProp[0]);

                }
            }

            while (Attrib.Count > 0)
            {
                obj = Attrib.ElementAt(0).Value;
                newCol.Add(obj.Name, (Field)obj.Clone());
                Attrib.Remove(obj.Name);
            }

            Attrib = null;

            return result;
        }



        /// <summary>
        /// recupera dal form passato gli attributi di un modello e li inserisce in una tabella
        /// i nomi degli attributi devono combaciare fra form e tabella
        /// </summary>
        /// <param name="objForm"></param>
        /// <param name="strTable"></param>
        /// <param name="strConnectionString"></param>
        public void Add(dynamic objForm, string strTable, string strConnectionString)
        {
            LibDbModelExt objDB = new LibDbModelExt(configuration);
            Dictionary<string, Field> Columns = new Dictionary<string, Field>();
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

            string strSql = string.Empty;
            string strValue = string.Empty;
            string strCol = string.Empty;
            int numFld;
            int i;

            if (objForm == null)
            {
                return;
            }

            //  '-- recupera il modello per determinare gli attributi  da inserire nel record
            mp_objDB.GetFilteredFields(mp_ModFiltroAdd, ref Columns, ref ColumnsProperty, "I", 0, 0, mp_strConnectionString, _session, true);

            numFld = Columns.Count;
            i = 1;

            foreach (Field objAtt in Columns.Values)
            {
                objAtt.Value = objForm[objAtt.Name].Value;

                strValue = strValue + objAtt.SQLValue();

                strCol = strCol + objAtt.Name;

                if (i < numFld)
                {
                    strValue = strValue + ",";
                    strCol = strCol + ",";
                }

                i++;

            }

            strSql = "insert into " + strTable + " ( " + strCol + " ) values ( " + strValue + " )";
            mp_ObjTabManager = new TabManage(configuration);
            mp_ObjTabManager.ExecSql(strSql, strConnectionString);

        }

        /// <summary>
        /// rimuove l'articolo dal catalogo
        /// </summary>
        /// <param name="Id"></param>
        /// <param name="strTable"></param>
        /// <param name="strConnectionString"></param>
        public void DEL(long Id, string strTable, string strConnectionString)
        {
            string strSql = string.Empty;
            TabManage objDB = new TabManage(configuration);

            strSql = "delete from " + strTable + " where " + mp_IDENTITY + " = " + Id;
            objDB.ExecSql(strSql, strConnectionString);


        }
        /// <summary>
        /// recupera dal form passato gli attributi di un modello e li inserisce in una tabella 
        /// i nomi degli attributi devono combaciare fra form e tabella
        /// </summary>
        /// <param name="IDrOW"></param>
        /// <param name="objForm"></param>
        /// <param name="strTable"></param>
        /// <param name="strConnectionString"></param>
        public void UPD(long IDrOW, dynamic objForm, string strTable, string strConnectionString)
        {
            LibDbModelExt objDB = new LibDbModelExt(configuration);
            Dictionary<string, Field> Columns = new Dictionary<string, Field>();
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

            string strSql;

            int numFld;
            int i;

            if (objForm == null)
            {
                return;
            }

            mp_objDB.GetFilteredFields(mp_ModFiltroUpd, ref Columns, ref ColumnsProperty, "I", 0, 0, mp_strConnectionString, _session, true);

            strSql = $"update {strTable} set ";
            numFld = Columns.Count;
            i = 1;

            foreach (Field objAtt in Columns.Values)
            {
                objAtt.Value = objForm[objAtt.Name].Value;

                strSql += objAtt.Name + " = " + objAtt.SQLValue();

                if (i < numFld) { strSql += ","; }

                i++;

            }

            strSql += $" where {mp_IDENTITY} = {IDrOW}";

            TabManage mp_objDBTM = new TabManage(configuration);
            mp_objDBTM.ExecSql(strSql, strConnectionString);

        }

        public dynamic? Draw(string Filter, IEprocResponse _response)
        {
            try
            {
                switch (GetParamURL(Request_QueryString, "OPERATION"))
                {

                    //case "PRINT_CAL":
                    //    Draw_PrintCal(_session, Filter, _response);
                    //    break;

                    //case "XML":
                    //Draw_Xml(_session, _response);
                    //break;
                    default:
                        return Draw_Page(Filter, _response);
                }
            }
            catch (Exception ex)
            {

                throw new Exception(ex.Message, ex);
            }

            // raiserror mp_strcause

            // verificare cosa deve succedere in caso di errore rapportato alla gestione vb6

            //     return null;
            // }

        }

        //private dynamic Draw_Xml()
        //{

        //}

        private void InitLocal()
        {
            mp_ObjSession = this._session;

            int PosSuperUser;

            mp_Suffix = _session[SessionProperty.SESSION_SUFFIX];

            if (String.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            mp_strConnectionString = ApplicationCommon.Application.ConnectionString; // configuration.GetConnectionString("DefaultConnection");
            //mp_strConnectionString = session[SESSION_CONNECTIONSTRING];

            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);

            if (_context.Request.HasFormContentType)
            {
                Request_Form = _context.Request.Form;
            }
            else
            {

            }
            try
            {
                mp_User = Convert.ToInt64(_session[SessionProperty.SESSION_USER]);

            }
            catch
            {
            }
            mp_Permission = _session["Funzionalita"];



            mp_IDENTITY = GetParamURL(Request_QueryString, "IDENTITY");

            if (String.IsNullOrEmpty(mp_IDENTITY))
            {
                mp_IDENTITY = "id";
            }


            mp_NumeroPagina = GetParamURL(Request_QueryString, "nPag");


            if (GetParamURL(Request_QueryString, "URLDECODE") == "yes")
            {
                mp_Filter = GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = GetParamURL(Request_QueryString, "FilterHide");
            }
            else
            {
                mp_Filter = GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = GetParamURL(Request_QueryString, "FilterHide");
            }


            mp_Sort = GetParamURL(Request_QueryString, "Sort");
            mp_SortOrder = GetParamURL(Request_QueryString, "SortOrder");
            try
            {
                mp_Row_For_Page = CInt(GetParamURL(Request_QueryString, "numRowForPag"));

            }
            catch
            {

            }
            if (mp_Row_For_Page <= 0)
            {
                mp_Row_For_Page = 10;
            }
            mp_OWNER = GetParamURL(Request_QueryString, "OWNER");
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "TOP")))
            {
                mp_Top = GetParamURL(Request_QueryString, "TOP");
            }


            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "ConnectionString")))
            {
                mp_RSConnectionString = GetParamURL(Request_QueryString, "ConnectionString"); // configuration.GetConnectionString("DefaultConnection");
            }
            if (mp_RSConnectionString == "")
            {
                mp_RSConnectionString = mp_strConnectionString;
            }


            mp_JS = GetParamURL(Request_QueryString, "JScript");


            //'-- nel caso non ci sia il filtro precedente la pagina da visualizzare � la prima
            //'-- perch� � stata fatta una nuova ricerca
            if (string.IsNullOrEmpty(mp_NumeroPagina))
            {
                mp_NumeroPagina = 1.ToString();
            }


            mp_strTable = GetParamURL(Request_QueryString, "Table");
            //'mp_queryString = "&ClearNew=" & Request_QueryString("ClearNew") & "&CaptionAdd=" & Request_QueryString("CaptionAdd") & "&CaptionUpd=" & Request_QueryString("CaptionUpd") & "&RowForPage=" & Request_QueryString("RowForPage") & "&IDENTITY=" & Request_QueryString("IDENTITY")


            //'-- tolgo dalla query string elementi da usare sulla singola chiamata
            string tempQS;
            tempQS = CStr(Request_QueryString);


            tempQS = tempQS.Replace($"&MODE={GetParamURL(Request_QueryString, "MODE")}", "");
            tempQS = tempQS.Replace($"MODE={GetParamURL(Request_QueryString, "MODE")}", "");


            tempQS = tempQS.Replace($"&IDROW={GetParamURL(Request_QueryString, "IDROW")}", "");
            tempQS = tempQS.Replace($"IDROW={GetParamURL(Request_QueryString, "IDROW")}", "");



            mp_queryString = tempQS;

            //'-- aggiusto il filtro presente sulla querystring
            mp_queryString = MyReplace(mp_queryString, "&Filter=" + GetParam(tempQS, "Filter"), "");
            mp_queryString = MyReplace(mp_queryString, "Filter=" + GetParam(tempQS, "Filter"), "");
            mp_queryString = mp_queryString + "&Filter=" + URLEncode(mp_Filter);


            //'-- aggiusto il filtro nascosto
            mp_queryString = MyReplace(mp_queryString, "&FilterHide=" + GetParam(tempQS, "FilterHide"), "");
            mp_queryString = MyReplace(mp_queryString, "FilterHide=" + GetParam(tempQS, "FilterHide"), "");


            mp_queryString = mp_queryString + "&FilterHide=" + URLEncode(mp_FilterHide);



            if (Strings.Left(mp_queryString, 1) == "&")
            {
                mp_queryString = Strings.Mid(mp_queryString, 2);
            }



            mp_StrDocumentType = GetParamURL(Request_QueryString, "DOCUMENT");
            mp_StrToolbar = GetParamURL(Request_QueryString, "TOOLBAR");


            dynamic aInfo;
            aInfo = Strings.Split(mp_StrToolbar, ",");
            mp_PosToolbar = "TOP";
            if (Information.UBound(aInfo) > 0)
            {
                mp_PosToolbar = Strings.UCase(aInfo[1]);
                mp_StrToolbar = aInfo[0];
            }


            mp_strPathJSToolBar = GetParamURL(Request_QueryString, "PATHTOOLBAR");


            mp_ModFiltroAdd = GetParamURL(Request_QueryString, "ModExecAdd");
            if (string.IsNullOrEmpty(mp_ModFiltroAdd))
            {
                mp_ModFiltroAdd = $"{mp_strTable}_ADD_ROW";
            }
            mp_ModFiltroUpd = GetParamURL(Request_QueryString, "ModExecUpd");
            if (string.IsNullOrEmpty(mp_ModFiltroUpd))
            {
                mp_ModFiltroUpd = $"{mp_strTable}_UPD_ROW";
            }
            mp_ModGriglia = GetParamURL(Request_QueryString, "ModGriglia");
            if (string.IsNullOrEmpty(mp_ModGriglia))
            {
                mp_ModGriglia = $"{mp_strTable}Griglia";
            }



            if (GetParamURL(Request_QueryString, "ModelloFiltro") != "")
            {
                mp_ModFiltro = GetParamURL(Request_QueryString, "ModelloFiltro");
            }
            else
            {
                mp_ModFiltro = $"{mp_strTable}Filtro";
            }


            mp_idViewer = $"{mp_ModGriglia}_{mp_ModFiltro}_{mp_strTable}_{mp_OWNER}_{mp_StrToolbar}";


            //'--recupero property per sort sulla griglia
            if (Request_Form != null && Request_Form.ContainsKey("Property"))
            {
                mp_Property = Request_Form["Property"];
            }
            else
            {
                mp_Property = GetParamURL(Request_QueryString, "Property");
            }

            ////'--recupero proerty per sort sulla griglia
            //try
            //{
            //    mp_Property = Request_Form["Property"];
            //}
            //catch
            //{
            //    mp_Property = "";
            //}

            //if (mp_Property == "")
            //{

            //    mp_Property = GetParamURL(Request_QueryString, "Property");

            //}


            //'If UCase(session(OBJAPPLICATION)"ACCESSIBLE")) <> "YES" Then


            if (!string.IsNullOrEmpty(mp_Property) || GetParamURL(Request_QueryString, "PropModel") != "" || GetParamURL(Request_QueryString, "PropHide") != "")
            {
                mp_ShowProperty = true;
            }
            else
            {
                mp_ShowProperty = false;
            }


            if (UCase(GetParamURL(Request_QueryString, "PropModel")) == "NO_PROP")
            {
                mp_ShowProperty = false;
            }


            //'Else


            //'-- a meno che non � stata richiesta la non-visualizzazione del property selector
            //'    If UCase(Request_QueryString("PropModel")) = "NO_PROP" Then
            //'        mp_ShowProperty = False
            //'    Else
            //'        mp_ShowProperty = True
            //'    End If


            //'End If


            //'--aggiusto la property
            mp_queryString = MyReplace(mp_queryString, $"&Property={GetParam(tempQS, "&Property")}", "");
            mp_queryStringProp = $"{mp_queryString}&Property={mp_Property}";
            mp_queryString = $"{mp_queryString}&Property={HttpUtility.UrlEncode(mp_Property)}";





            mp_PropertyH = (GetParamURL(Request_QueryString, "PropertyH") == "" ? "400" : GetParamURL(Request_QueryString, "PropertyH"));
            mp_PropertyW = (GetParamURL(Request_QueryString, "PropertyW") == "" ? "450" : GetParamURL(Request_QueryString, "PropertyW"));


            mp_timeout = 0;
            if (GetParamURL(Request_QueryString, "TIMEOUT") != "")
            {
                mp_timeout = CLng(GetParamURL(Request_QueryString, "TIMEOUT"));
            }

            if (GetParamURL(Request_QueryString, "CALENDAR") != "")
            {
                mp_Calendar = GetParamURL(Request_QueryString, "CALENDAR");
            }


            if (GetParamURL(Request_QueryString, "FIELDSTYLE") != "")
            {
                mp_FieldStyle = GetParamURL(Request_QueryString, "FIELDSTYLE");
            }


            mp_MESI_CALENDAR = 1;
            if (GetParamURL(Request_QueryString, "MESI_CALENDAR") != "")
            {
                mp_MESI_CALENDAR = CInt(GetParamURL(Request_QueryString, "MESI_CALENDAR"));
            }


            mp_strStoredSQL = "";
            if (GetParamURL(Request_QueryString, "STORED_SQL") != "")
            {
                mp_strStoredSQL = GetParamURL(Request_QueryString, "STORED_SQL");
            }


            mp_DATA_CALENDAR = GetParamURL(Request_QueryString, "DATA_CALENDAR");
            if (string.IsNullOrEmpty(mp_DATA_CALENDAR))
            {
                mp_DATA_CALENDAR = _session[$"{mp_idViewer}_DATA_CALENDAR"];
            }
            if (string.IsNullOrEmpty(mp_DATA_CALENDAR))
            {
                mp_DATA_CALENDAR = Strings.Format(DateAndTime.Now, "yyyy-MM");
            }

            if (!string.IsNullOrEmpty(mp_Calendar))
            {
                mp_DATA_CALENDAR = Strings.Replace(mp_DATA_CALENDAR, "/", "-");
                _session[$"{mp_idViewer}_DATA_CALENDAR"] = mp_DATA_CALENDAR;
            }



            mp_queryString = MyReplace(mp_queryString, $"&DATA_CALENDAR={GetParam(tempQS, "DATA_CALENDAR")}", "");
            mp_queryString = $"{mp_queryString}&DATA_CALENDAR={mp_DATA_CALENDAR}";


            mp_Info_User_Profile = CStr(GetParamURL(Request_QueryString, "FILTER_USER_PROFILE"));


            mp_accessible = Strings.UCase(_session["ACCESSIBLE"]);


        }

        private void InitGUIObject(EprocResponse objResp)
        {

            //dynamic objDBFunction;
            //dynamic objDB;
            TSRecordSet rs = new TSRecordSet();
            string[] v = new string[0];
            int i;

            if (string.IsNullOrEmpty(mp_Calendar))
            {
                mp_objGrid = new Grid();
                mp_objGrid.mp_accessible = mp_accessible;
            }
            else
            {
                mp_objCalendar = new Calendar();
            }


            mp_grSP = new ScrollPage();
            mp_objForm = new Form();
            mp_ObjButtonBar = new ButtonBar();

            //'-- se provengo dalla scelta di una ricerca prelevo il criterio di ricerca
            //if (Strings.LCase(GetParamURL(Request_QueryString, "MODE")) == "filtra" && Request_Form != "" && RequestForm != null && Request_Form.Count > 0)
            if (Strings.LCase(GetParamURL(Request_QueryString, "MODE")) == "filtra" && Request_Form != null && Request_Form.Count > 0)
            {

                Model objModel;

                //'-- recupero il modello di ricerca
                mp_strcause = "recupero il modello di ricerca";
                LibDbModelExt mp_objDB2 = new LibDbModelExt(configuration);//CreateObject("ctldb.LibDbModelExt");

                objModel = mp_objDB2.GetFilteredModel(mp_ModFiltro, mp_Suffix, 0, 0, mp_strConnectionString, true, _session);

                //'-- avvalora i campi del modello
                objModel.SetFieldsValue(Request_Form);

                //'-- recupera la condizione di ricerca
                if (mp_strStoredSQL != "yes")
                {
                    mp_Filter = objModel.GetSqlWhere();
                }
                else
                {
                    mp_Filter = objModel.GetSqlWhereList();
                }

                string tempQS;
                tempQS = mp_queryString;
                mp_queryString = MyReplace(mp_queryString, $"&Filter={GetParam(tempQS, "Filter")}", "");
                mp_queryString = MyReplace(mp_queryString, $"Filter={GetParam(tempQS, "Filter")}", "");

                mp_queryString = $"{mp_queryString}&Filter={HttpUtility.UrlEncode(mp_Filter)}";

                //'-- conservo in sessione il filtro
                _session[mp_idViewer] = mp_Filter;
                _session[mp_idViewer + "_location"] = CStr(Request_QueryString);


            }

            //'-- nel caso il filtro sia vuoto cerco di recuperarlo dalla sessione di lavoro
            if (Strings.Trim(Strings.LCase(CStr(GetParamURL(Request_QueryString, "brcrumb")))) == "yes" || (string.IsNullOrEmpty(mp_Filter) && GetParamURL(Request_QueryString, "FilterRecovery") != "no") && !String.IsNullOrEmpty(_session[mp_idViewer]))
            {
                mp_Filter = _session[mp_idViewer] != null ? _session[mp_idViewer] : "";
            }

			//'-- esegue l'elaborazione solamente se � presente un filtro di ricerca
			if (GetParamURL(Request_QueryString, "FilteredOnly") == "yes" && string.IsNullOrEmpty(mp_Filter.Trim()))
            {
                return;
            }

            //'-- se si � aggiunta una riga la griglia toglie filtri ed ordinamenti psizionandosi sull'ultimo record
            if (GetParamURL(Request_QueryString, "MODE") == "ADD")
            {
                //'mp_Filter = ""
                //'mp_Sort = ""
            }


            //'-- recupero la collezione di colonne da visualizzare
            mp_strcause = "recupero la collezione di colonne da visualizzare";
            //LibDbModelExt 
            mp_objDB = new LibDbModelExt(configuration);
            //mp_Columns = new Dictionary<string, Field>();
            //mp_objDB = CreateObject("ctldb.LibDbModelExt");
            mp_objDB.GetFilteredFields(mp_ModGriglia, ref mp_Columns, ref mp_ColumnsProperty, mp_Suffix, 0, 0, mp_strConnectionString, _session, true);

            if (mp_ShowProperty == true)
            {

                if (GetParamURL(Request_QueryString, "PropModel") != "")
                {
                    mp_objDB.GetFilteredFields(GetParamURL(Request_QueryString, "PropModel"), ref mp_ColumnsProp, ref mp_ColumnsPropertyProp, mp_Suffix, 0, 0, mp_strConnectionString, _session, true);
                }
                else
                {
                    mp_objDB.GetFilteredFields(mp_ModGriglia, ref mp_ColumnsProp, ref mp_ColumnsPropertyProp, mp_Suffix, 0, 0, mp_strConnectionString, _session, true);
                }

                //'-- rimuovo le colonne nascoste
                RimuoviColonne(mp_ColumnsProp, mp_ColumnsPropertyProp);

            }



            //'--imposto il sort multiplo se c'� la property
            string strSort = "";

            if (mp_ShowProperty == true)
            {
                strSort = RetrieveSortFromProperty();
            }
            else
            {
                strSort = $"{mp_Sort} {mp_SortOrder}";
            }


            //'-- aggiungo al sort la colonna identity per evitare ordinamenti errati sulle pagine
            if (!string.IsNullOrEmpty(mp_IDENTITY))
            {
                if (!string.IsNullOrEmpty(strSort.Trim()))
                {
                    //'-- se l'identity non � presente nel sort lo aggiungo
                    if (!UCase(" " + strSort + " ").Contains(UCase(" " + mp_IDENTITY + " "), StringComparison.Ordinal))
                    {
                        strSort = $"{strSort} , {mp_IDENTITY} asc";
                    }
                }
                else
                {
                    strSort = $"{mp_IDENTITY} asc";
                }
            }


            if (string.IsNullOrEmpty(mp_Top))
            {
                mp_Top = CStr(CLng(mp_Row_For_Page) * (CLng(mp_NumeroPagina)));
            }

            //'-- la presenza dei totali obbliga l'estrazione di tutti i dati per ottenere il totale corretto
            if (GetParamURL(Request_QueryString, "TOTAL") != "")
            {
                mp_Top = "";
            }


            //'-- applica il filtro per restrigere i dati da ritornare sul calendario
            if (!string.IsNullOrEmpty(mp_Calendar))
            {
                mp_Top = "";

                DateTime dSt;
                DateTime dEn;
                Fld_Date fldD = new Fld_Date();
                dSt = DateAndTime.DateSerial(DateAndTime.Year(DateAndTime.Now), DateAndTime.Month(DateAndTime.Now), 1);
                if (mp_DATA_CALENDAR != "")
                {
                    dSt = DateAndTime.DateSerial(CInt(Strings.Left(mp_DATA_CALENDAR, 4)), CInt(Strings.Mid(mp_DATA_CALENDAR, 6, 2)), 1);
                }

                dEn = DateAndTime.DateAdd("m", 1, dSt);
                //'-- se � richiesta la data fine per la stampa si estende il filtro
                //if (GetParamURL(Request_QueryString,"DATA_CALENDAR_END"] != "")
                //{
                //    string strDFin;
                //    int ixD;
                //    ixD = 0;
                //    strDFin = GetParamURL(Request_QueryString,"DATA_CALENDAR_END"];
                //    while (Strings.Format(dEn, "yyyy-mm") <= Strings.Left(strDFin, 7))
                //    {
                //        dEn = DateAndTime.DateAdd("m", 1, dEn);
                //        ixD = ixD + 1;
                //        if (ixD > 100)
                //        {
                //            break;
                //        }
                //    }
                //}


                //'-- aggiunge la filtro una restrizione sulle date in funzione dei mesi da visualizzare
                if (mp_MESI_CALENDAR != 1)
                {
                    dEn = DateAndTime.DateAdd("m", mp_MESI_CALENDAR - 1, dEn);
                    dSt = DateAndTime.DateAdd("m", -mp_MESI_CALENDAR + 1, dSt);
                }

                dEn = DateAndTime.DateAdd("d", 15, dEn);
                dSt = DateAndTime.DateAdd("d", -15, dSt);

                if (!string.IsNullOrEmpty(mp_FilterHide))
                {
                    mp_FilterHide = $"{mp_FilterHide} and ";
                }

                string filterCalendar = "";
                fldD.Value = dSt;
                filterCalendar = $"{mp_Calendar} >= {fldD.SQLValue()}";
                fldD.Value = dEn;
                filterCalendar = $"{filterCalendar} and {mp_Calendar} <= {fldD.SQLValue()} ";
                mp_FilterHide = $"{mp_FilterHide}{filterCalendar}";



            }

            //'-- recupero il recordset del Viewer dal database
            mp_strcause = "recupero il recordset del Viewer dal database";
            //'Set rs = GetRSGrid(mp_strTable, mp_Filter, mp_RSConnectionString)
            if (!string.IsNullOrEmpty(ApplicationCommon.Application["NO_TOP_VIEWER"]))
            {
                mp_Top = "";
            }

            //'--aggiungo alla filter eventuali condizioni di profilazione
            string strGlobalFilter;
            string strFilterUserProfile = "";
            strGlobalFilter = mp_Filter;

            mp_strcause = $"recupero il filtro legato alla profilazione utente = {mp_Info_User_Profile}";
            strFilterUserProfile = Get_Filter_User_Profile();

            if (!string.IsNullOrEmpty(strFilterUserProfile))
            {
                if (!string.IsNullOrEmpty(strGlobalFilter))
                {
                    strGlobalFilter = $"{strGlobalFilter} and {strFilterUserProfile}";
                }
                else
                {
                    strGlobalFilter = strFilterUserProfile;
                }
            }

            string l_strStoredSQL;
            l_strStoredSQL = mp_strStoredSQL;

            //'-- nel caso la query non sia in una stored, passo il nome del modello, verr� utilizzato per limitare la select alle sole colonne utili al posto di *
            if (mp_strStoredSQL != "yes")
            {

                l_strStoredSQL = $"MODELLO={mp_ModGriglia}&IDENTITY={mp_IDENTITY}";

                //'--se non uso la stored recupero e aggiungo il parametro che mi dice se voglio tutte le colonne
                //'--per gestire eccezioni o casi particolari
                l_strStoredSQL = $"{l_strStoredSQL}&ALL_COLUMN={GetParamURL(Request_QueryString, "ALL_COLUMN")}";

                //'--aggiungo paraemtro ROWCONDITION per capire le altre colonne da aggiungere
                l_strStoredSQL = $"{l_strStoredSQL}&ROWCONDITION={GetParamURL(Request_QueryString, "ROWCONDITION")}";

                //'--RS_PARAM  lista parametri aggiuntivi da recuperare dalla querystring e portare avanti
                if (GetParamURL(Request_QueryString, "RS_PARAM") != "")
                {

                    string strRs_Param;
                    dynamic aInfo;
                    //'Dim i As Integer

                    strRs_Param = GetParamURL(Request_QueryString, "RS_PARAM");

                    if (strRs_Param != "")
                    {

                        aInfo = Strings.Split(strRs_Param, ",");

                        for (i = 0; i <= Information.UBound(aInfo); i++)
                        {

                            l_strStoredSQL = $"{l_strStoredSQL}&{aInfo[i]}={GetParamURL(Request_QueryString, aInfo[i])}";

                        }

                    }


                }


            }

            string Solo_Colonne_Usate;

            Solo_Colonne_Usate = ApplicationCommon.Application["Viewer_Solo_Colonne_Usate"];

            //rs = DashBoardMod.GetRSGridCount(mp_OWNER, CLng(mp_User), mp_strTable, strGlobalFilter, mp_FilterHide, mp_RSConnectionString, mp_numRec, mp_Top, strSort, mp_timeout, l_strStoredSQL, Solo_Colonne_Usate);

            rs = DashBoardMod.GetRSGridCount(mp_OWNER, CLng(mp_User), mp_strTable, strGlobalFilter, mp_FilterHide, mp_RSConnectionString, ref mp_numRec, mp_Top, strSort, mp_timeout, l_strStoredSQL, Solo_Colonne_Usate);
            //'Set rs = DashBoardMod.GetRSGrid(mp_OWNER, CLng(mp_User), mp_strTable, mp_Filter, mp_FilterHide, strConnectionString, mp_Top, strSort, mp_timeout)



            if (GetParamURL(Request_QueryString, "MODE") == "ADD")
            {
                //'-- dopo un add si punta all'ultima pagina
                //'mp_NumeroPagina = Fix(rs.RecordCount / mp_Row_For_Page) + IIf((rs.RecordCount Mod mp_Row_For_Page) <> 0, 1, 0)
            }


            RimuoviColonneAssenti(mp_ColumnsProp, rs);

            //'Set mp_Columns = New Collection



            //'    //'-- recupero la collezione di colonne da visualizzare
            //'    mp_strcause = "recupero la collezione di colonne da visualizzare"
            //'    Set mp_objDB = CreateObject("ctldb.LibDbModelExt")
            //'    mp_objDB.GetFilteredFields mp_ModGriglia, mp_Columns, mp_ColumnsProperty, mp_Suffix, 0, 0, mp_strConnectionString, mp_ObjSession, True
            //'
            //'    If mp_Property <> "" Then
            //'
            //'        If Request_QueryString("PropModel") <> "" Then
            //'            mp_objDB.GetFilteredFields Request_QueryString("PropModel"), mp_ColumnsProp, mp_ColumnsPropertyProp, mp_Suffix, 0, 0, mp_strConnectionString, mp_ObjSession, True
            //'        Else
            //'            mp_objDB.GetFilteredFields mp_ModGriglia, mp_ColumnsProp, mp_ColumnsPropertyProp, mp_Suffix, 0, 0, mp_strConnectionString, mp_ObjSession, True
            //'        End If
            //'
            //'        //'-- rimuovo le colonne nascoste
            //'        RimuoviColonne mp_ColumnsProp, mp_ColumnsPropertyProp
            //'
            //'    End If


            //'-- elimino le colonne in funzione della scelta utente nelle property
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "PropHide")))
            {
                InitGuiObject_SetColumnPosition(mp_Columns, mp_Property);
            }

            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "COL_TITLE")))
            {
                dynamic[] vCol;
                vCol = Strings.Split(GetParamURL(Request_QueryString, "COL_TITLE"), "~");
                for (i = 0; i <= vCol.GetUpperBound(0); i++)
                {

                    v = vCol[i].Split(",");

                    if (v.Length >= 2 && v[1].StartsWith('*'))
                    {
                        mp_Columns[v[0]].Caption = $"{mp_Columns[v[0]].Caption} {Strings.Mid(v[1], 2)}";
                    }
                    else
                    {
                        mp_Columns[v[0]].Caption = v[1];
                    }
                }
            }

            //'-- recuper l'evetuale toolbar associata
            if (!string.IsNullOrEmpty(mp_StrToolbar))
            {
                mp_objToolbar = Lib_dbFunctions.GetHtmlToolbar(mp_StrToolbar, mp_Permission, mp_Suffix, mp_strConnectionString, _session);

            }

            //'-- nascondo le colonne richieste
            if (GetParamURL(Request_QueryString, "HIDE_COL") != "")
            {
                v = Strings.Split(GetParamURL(Request_QueryString, "HIDE_COL"), ",");
                for (i = 0; i <= Information.UBound(v); i++)
                {
                    mp_Columns.Remove(v[i]);
                }
            }

            if (mp_objGrid != null)
            {

                mp_numrecord = rs.RecordCount;

                //'-- inizializzo la griglia del Viewer
                mp_strcause = "inizializzo la griglia del Viewer";
                mp_objGrid.Columns = mp_Columns;
                mp_objGrid.ColumnsProperty = mp_ColumnsProperty;

                bool bAutoCol;

                if (Strings.UCase(CStr(GetParamURL(Request_QueryString, "AUTO_COL"))) == "YES")
                {
                    bAutoCol = true;
                }
                else
                {
                    bAutoCol = false;
                }

                mp_objGrid.RecordSet(rs, mp_IDENTITY, bAutoCol);

                mp_objGrid.id = "GridViewer";
                mp_objGrid.width = "100%";
                mp_objGrid.ActiveSelection = CInt(GetParamURL(Request_QueryString, "ACTIVESEL"));
                mp_objGrid.mp_ColFieldNotEditable = GetParamURL(Request_QueryString, "COLUMN_NOT_EDITABLE");

                if (!String.IsNullOrEmpty(mp_FieldStyle))
                {
                    mp_objGrid.Style = mp_FieldStyle;
                }

                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "TOTAL")))
                {
                    dynamic vvv;
                    vvv = Strings.Split(GetParamURL(Request_QueryString, "TOTAL"), ",");
                    mp_objGrid.ShowTotal(ApplicationCommon.CNV(CStr(vvv[0]), _session), CInt(CStr(vvv[1])));
                }
                if (GetParamURL(Request_QueryString, "EDITABLE") == "yes")
                {
                    mp_objGrid.Editable = true;
                }

                AddRowCondition();

                long maxNumPagina;
                maxNumPagina = Conversion.Fix(rs.RecordCount / mp_Row_For_Page) + ((rs.RecordCount % mp_Row_For_Page) != 0 ? 1 : 0);


                //'-- se la pagina richiesta � superiore al numero massimo di pagine disponibili ci portiamo sull'ultima
                mp_NumeroPagina = (CInt(mp_NumeroPagina) > maxNumPagina ? maxNumPagina.ToString() : mp_NumeroPagina);

                //'mp_objGrid.Editable = True
                mp_objGrid.SetPage(CLng(mp_NumeroPagina), CLng(mp_Row_For_Page));
                //'mp_objGrid.SetSort "Filter=" & UrlEncode(mp_Filter) & "&Sort=" & mp_Sort & "&SortOrder=" & mp_SortOrder & "&Table=" & mp_strTable & Replace(mp_queryString, "'", "\'"), "ViewerGriglia.asp", True, True

                if ((string.IsNullOrEmpty(mp_Property) && Strings.UCase(GetParamURL(Request_QueryString, "PropModel")) != "NO_PROP"))
                {
                    if (GetParamURL(Request_QueryString, "PAGEDEST") == "")
                    {
                        mp_objGrid.SetSort(Strings.Replace(mp_queryString, @"'", @"\'"), "Viewer.asp", true, false); //' True
                    }
                    else
                    {
                        mp_objGrid.SetSort(Strings.Replace(mp_queryString, @"'", @"\'"), GetParamURL(Request_QueryString, "PAGEDEST"), true, false); //' True
                    }
                }


                //'--controllo se impostare sulla griglia un modello posizionale per il disegno delle righe
                if (GetParamURL(Request_QueryString, "POSITIONALMODELGRID") != "")
                {

                    //'--recupero modello posizionale
                    mp_strcause = "recupero il modello di ricerca";
                    LibDbModelExt mp_objDB3 = new LibDbModelExt(configuration);
                    //mp_objDB = CreateObject("ctldb.LibDbModelExt");
                    mp_objModelPos = mp_objDB3.GetFilteredModel(GetParamURL(Request_QueryString, "POSITIONALMODELGRID"), mp_Suffix, mp_User, 0, mp_strConnectionString, true, _session);

                    mp_objGrid.objModelPositional = mp_objModelPos;

                }


            }
            else
            {

                mp_objCalendar.AnnoMese = mp_DATA_CALENDAR;

                mp_objCalendar.Columns = mp_Columns;
                mp_objCalendar.ColumnsProperty = mp_ColumnsProperty;
                mp_objCalendar.RecordSet(rs, mp_IDENTITY, false);
                mp_objCalendar.FieldData = mp_Calendar;
                mp_objCalendar.id = "GridViewer";
                mp_objCalendar.width = "100%";
                mp_objCalendar.ActiveSelection = Convert.ToInt32(GetParamURL(Request_QueryString, "ACTIVESEL"));
                mp_objCalendar.MesiShow = mp_MESI_CALENDAR;

                if (!String.IsNullOrEmpty(mp_FieldStyle))
                {
                    mp_objCalendar.Style = mp_FieldStyle;
                }

                //'-- se � indicato la vista per le festivit� carica il RS
                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "CAL_FESTIVITY")))
                {
                    // mp_objCalendar.RsFestivity(CommonDB.CommonDbFunctions.GetRSReadFromQuery_($"select * from {GetParamURL(Request_QueryString, "CAL_FESTIVITY")}", mp_strConnectionString));
                    mp_objCalendar.RsFestivity(cdf.GetRSReadFromQuery_($"select * from {GetParamURL(Request_QueryString, "CAL_FESTIVITY")}", mp_strConnectionString));
                }


                mp_grSD = new ScrollDate();


                mp_grSD.SetScrollDate("Viewer.asp", mp_queryString);


            }

            //'--------------------------------------------------------------
            //'-- inizializzo la paginazione della griglia
            //'--------------------------------------------------------------
            mp_strcause = "disegna la barra per sfogliare i ricambi";

            mp_grSP.NumRowForPage = mp_Row_For_Page;
            mp_grSP.numPagToShow = "10";

            if (String.IsNullOrEmpty(GetParamURL(Request_QueryString, "PAGEDEST")))
            {

                mp_grSP.SetScrollPage("Viewer.asp", mp_queryString, mp_numRec);
            }
            else
            {
                mp_grSP.SetScrollPage(GetParamURL(Request_QueryString, "PAGEDEST"), mp_queryString, mp_numRec);
            }

            //'-- campi nascosti per filtro e numero pagina correnti
            mp_strcause = "campi nascosti per filtro e numero pagina correnti";
            mp_fldCurFiltro = new Fld_Hidden();
            mp_fldCurPag = new Fld_Hidden();
            mp_fldCurSort = new Fld_Hidden();
            mp_fldCurSortOrder = new Fld_Hidden();
            mp_fldCurTable = new Fld_Hidden();
            mp_fldQueryString = new Fld_Hidden();

            mp_fldCurFiltro.Name = "CurFilter";
            mp_fldCurPag.Name = "CurPage";
            mp_fldCurSort.Name = "CurSort";
            mp_fldCurSortOrder.Name = "CurSortOrder";
            mp_fldCurTable.Name = "CurTable";
            mp_fldQueryString.Name = "QueryString";

            mp_fldCurFiltro.Value = mp_Filter;
            mp_fldCurPag.Value = mp_NumeroPagina;
            mp_fldCurSort.Value = mp_Sort;
            mp_fldCurSort.Value = mp_SortOrder;
            mp_fldCurTable.Value = mp_strTable;

            //'-- tolgo IDROW e MODE
            mp_fldQueryString.Value = mp_queryString;

            //'--inizializzo blocchetto delle property
            if (mp_ShowProperty == true)
            {

                //'-- inizializzo il form
                mp_objForm.id = "FormProperty";

                //'-- barra dei bottoni
                mp_ObjButtonBar.CaptionSubmit = ApplicationCommon.CNV("Esegui", _session);

                mp_ObjButtonBar.OnSubmit = @"FormViewerFiltro.submit();return false;";

                mp_ObjButtonBar.CaptionReset = ApplicationCommon.CNV("Pulisci", mp_ObjSession);
                mp_ObjButtonBar.ShowButtons = eProcurementNext.HTML.ButtonBar.SubmitButton;

                mp_ObjButtonBar.id = "ViewerGriglia";

                mp_objModel = new PropertySelector(objResp);
                mp_objModel.Caption = ApplicationCommon.CNV("Attributo,Seleziona,Ordina,Tipo ordine", _session);
                mp_objModel.Id = "Property";
                mp_objModel.URL = mp_queryStringProp;

                mp_ColumnsProp.Remove("CodicePlant");
                mp_objModel.Column = mp_ColumnsProp;

            }

        }

        public dynamic Draw_Page(string Filter, IEprocResponse _response)
        {

            Collection JS = new Collection();
            Window win = new Window();
            dynamic obJDraw;

            //'----------------------------------
            //'-- avvia la scrittura della pagina
            //'----------------------------------

            //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
            mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";

            string tempQS;
            tempQS = CStr(Request_QueryString);
            tempQS = MyReplace(tempQS, $"&MODE={GetParamURL(Request_QueryString, "MODE")}", "");
            tempQS = MyReplace(tempQS, $"MODE={GetParamURL(Request_QueryString, "MODE")}", "");
            tempQS = MyReplace(tempQS, $"&IDROW={GetParamURL(Request_QueryString, "IDROW")}", "");
            tempQS = MyReplace(tempQS, $"IDROW={GetParamURL(Request_QueryString, "IDROW")}", "");
            tempQS = MyReplace(tempQS, $"npag={GetParamURL(Request_QueryString, "npag")}", "");


            if (Strings.Left(tempQS, 1) == "&")
            {
                tempQS = Strings.Mid(tempQS, 2);
            }
            //'-- nel caso si debba visualizzare un messaggio si inserisce lo script
            if (!String.IsNullOrEmpty(mp_StrMsg))
            {
                _response.Write($@"{ShowMessageBox(mp_StrMsg, ApplicationCommon.CNV("Attenzione", _session))}");
            }

            //'-- nel caso sia stato eseguito un UPD aggiorno il frame di add per far aggiungere record
            if (GetParamURL(Request_QueryString, "MODE") == "UPD")
            {
                string strIdRow = string.Empty;

                //    //'-- se voglio lasciare il vecchio contenuto gli passo l'id del record da caricare

                strIdRow = GetParamURL(Request_QueryString, "ClearNew") == "1" ? "" : "&IDROW=" + GetParamURL(Request_QueryString, "IDROW");


                _response.Write("<script type=\"text/javascript\" language=\"javascript\">" + Environment.NewLine);
                _response.Write("ExecFunction( 'ViewerAddNew.asp?MODE=ADD" + strIdRow + "&" + tempQS.Replace("'", "\'") + "' , 'ViewerAddNew' , ',height=250,width=400' );" + Environment.NewLine);
                _response.Write("</script>" + Environment.NewLine);
            }
            else if (GetParamURL(Request_QueryString, "MODE") == "ADD" && GetParamURL(Request_QueryString, "ClearNew") == "1")
            {
                //'-- in questo caso ricarico il form di inserimento per svuotarlo
                _response.Write("<script type=\"text/javascript\" language=\"javascript\">" + Environment.NewLine);
                _response.Write("ExecFunction( 'ViewerAddNew.asp?" + tempQS.Replace("'", "\'") + "' , 'ViewerAddNew' , ',height=250,width=400' );" + Environment.NewLine);
                _response.Write("</script>" + Environment.NewLine);
            }



            _response.Write($@"<form id=""FormViewerGriglia"" action="""">");
            _response.Write($@"<fieldset>");






            if (GetParamURL(Request_QueryString, "FilteredOnly") == "yes" && mp_Filter.Trim() == "")
            {

                _response.Write($"<table width=\"100%\" ");

                _response.Write($@">");


                _response.Write($@"<tr><td class=""width_100_percent height_100_percent"">");

                HTML_SinteticHelp(_response, ApplicationCommon.CNV("E' necessario inserire un parametro di ricerca nei campi di filtro", mp_ObjSession));


                _response.Write($@"</td></tr></table>");

            }
            else
            {


                //'-- aggiungo i campi nascosti per il filtro e la pagina corrente

                mp_fldCurFiltro.Html(_response);
                mp_fldCurPag.Html(_response);
                mp_fldCurSort.Html(_response);
                mp_fldCurSortOrder.Html(_response);
                mp_fldCurTable.Html(_response);

                mp_fldQueryString.Html(_response);

                HTML_HiddenField(_response, "MsgConfirmDel", ApplicationCommon.CNV("Sei sicuro di voler cancellare?", _session));

                if (!string.IsNullOrEmpty(mp_StrDocumentType))
                {
                    HTML_HiddenField(_response, "DOCUMENT", mp_StrDocumentType);
                }

                HTML_HiddenField(_response, "DATA_CALENDAR", Strings.Left(mp_DATA_CALENDAR, 7));
                HTML_HiddenField(_response, "ModGriglia", mp_ModGriglia);



                _response.Write(@"<table width=""100%"" ");


                _response.Write(@">");


                bool bDrawToolbar;
                bDrawToolbar = false;

                //'-- disegna la toolbar



                if (mp_objToolbar != null && (GetParamURL(Request_QueryString, "TOOLBAR_PAGINAZIONE") != "1" || mp_numRec <= mp_Row_For_Page))
                {
                    if (mp_PosToolbar.Contains("TOP", StringComparison.Ordinal))
                    {

                        _response.Write(@"<tr><td> ");

                        //'--Toolbar presente:se SHOW_NUMBER_ROW non � no disegno numero righe
                        if (GetParamURL(Request_QueryString, "SHOW_NUMBER_ROW").ToLower() != "no")
                        {
                            _response.Write($"<span class=\"viewer_label_numerorighe\">{ApplicationCommon.CNV("Numero Righe Viewer", _session)}</span><span class=\"viewer_numerorighe\">{mp_numRec}</span>");
                        }

                        mp_objToolbar.mp_accessible = mp_accessible;
                        mp_objToolbar.Html(_response);
                        _response.Write(@"</td></tr> ");

                        bDrawToolbar = true;

                    }
                }

                if (!bDrawToolbar)
                {
                    //'--Toolbar non presente: se SHOW_NUMBER_ROW � si disegno numero righe
                    if (Strings.LCase(GetParamURL(Request_QueryString, "SHOW_NUMBER_ROW")) == "si")
                    {
                        _response.Write(@"<tr><td > ");
                        _response.Write(@$"<span class=""viewer_label_numerorighe"">{ApplicationCommon.CNV("Numero Righe Viewer", _session)}</span><span class=""viewer_numerorighe"">{mp_numRec}</span>");
                        _response.Write(@"</td></tr> ");
                    }
                }

                if (GetParamURL(Request_QueryString, "HELP") != "")
                {
                    _response.Write(@$"<tr><td>{ApplicationCommon.CNV(GetParamURL(Request_QueryString, "HELP"), _session)}");
                    _response.Write(@"</td></tr>");
                }

                if ((mp_numRec > mp_Row_For_Page || !string.IsNullOrEmpty(mp_Calendar)) || mp_ShowProperty == true)
                {

                    //'-- disegna la barra di paginazione

                    _response.Write(@"<tr><td > ");
                    _response.Write(@"<table width=""100%"" cellspacing=""0"" cellpadding=""0""><tr>");


                    if (mp_numRec > mp_Row_For_Page && string.IsNullOrEmpty(mp_Calendar))
                    {

                        if (GetParamURL(Request_QueryString, "TOOLBAR_PAGINAZIONE") == "1")
                        {
                            if (mp_PosToolbar.Contains("TOP", StringComparison.Ordinal))
                            {

                                _response.Write(@"<td class=""width_100_percent""> " + Environment.NewLine);

                                mp_objToolbar.Html(_response);
                                _response.Write(@"</td> ");

                            }

                        }

                        if (GetParamURL(Request_QueryString, "PAGINAZIONE") != "0")
                        {
                            _response.Write(@"<td class=""cellPaginazione"" > " + Environment.NewLine);
                            mp_grSP.Html(_response);
                            _response.Write(@"</td> ");
                        }
                    }

                    if (mp_grSD != null)
                    {

                        if (GetParamURL(Request_QueryString, "TOOLBAR_PAGINAZIONE") == "1" && mp_objToolbar != null)
                        {
                            if (mp_PosToolbar.Contains("TOP", StringComparison.Ordinal))
                            {
                                _response.Write(@"<td > " + Environment.NewLine);
                                mp_objToolbar.Html(_response);
                                _response.Write(@"</td> " + Environment.NewLine);
                            }

                        }

                        _response.Write(@"<td > " + Environment.NewLine);
                        mp_grSD.Html(_response, _session);
                        _response.Write(@"</td> " + Environment.NewLine);

                    }

                    //'--disegno il blocchetto con le propriet� per il sort sulla griglia

                    if (mp_ShowProperty)
                    {
                        mp_strcause = "disegna le proprietà di visualizzazione";
                        //'-- disegna le proprieta di visualizzazione
                        _response.Write("<td align=\"right\">" + Environment.NewLine);
                        if (ApplicationCommon.Application["ShowImages"] != "0")
                        {
                            //VERIFICARE !!!
                            win.Init("WinProperty", ApplicationCommon.CNV("Ordina per colonne", _session), false, Window.Group);
                        }
                        else
                        {
                            // VERIFICARE !!
                            win.Init("WinProperty", ApplicationCommon.CNV("Ordina per colonne", _session), false, Window.NOIMAGES);
                        }

                        win.Zindex = 10;


                        win.PositionAbsolute = true;


                        win.mp_accessible = "YES"; // _session["ACCESSIBLE"].ToUpper();
                        win.Height = mp_PropertyH;
                        win.width = mp_PropertyW;
                        win.Html(_response, this);  // VERIFICARE
                        _response.Write("</td>" + Environment.NewLine);

                        //End If
                    }

                    _response.Write(@"</tr></table></td></tr> ");

                }


                //'-- Crea l'oggetto preposto alla stampa delle righe se richiesto
                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "OBJ_CUSTOM_DRAW")))
                {
                    // COSA VUOLE DIRE???!!!!!!!!


                    //obJDraw = CreateObject(GetParamURL(Request_QueryString,"OBJ_CUSTOM_DRAW"]);
                    //mp_objGrid.SetCustomDrawer(obJDraw);
                }

                //'-- disegna la griglia
                mp_strcause = "disegna la griglia";

                _response.Write(@"<tr><td class=""width_100_percent height_100_percent"">");


                if (mp_objGrid != null)
                {


                    mp_objGrid.SetLockedInfo(0, 0);

                    mp_objGrid.Html(_response);
                }
                else
                {

                    mp_objCalendar.SetLockedInfo(0, 0);

                    mp_objCalendar.Html(_response);

                }
                _response.Write(@"</td></tr>");

                //'--se richiesto disegno la toolbar anche a fine pagina
                if (mp_PosToolbar.Contains("BOTTOM", StringComparison.Ordinal))
                {
                    _response.Write(@"<tr><td> ");

                    //'--se SHOW_NUMBER_ROW non � no
                    if (Strings.LCase(GetParamURL(Request_QueryString.ToString(), "SHOW_NUMBER_ROW")) != "no")
                    {
                        _response.Write(@$"<span class=""numerorighe"">{ApplicationCommon.CNV("Numero Righe Viewer", _session)}&nbsp;{mp_numRec}</span>");
                    }

                    mp_objToolbar.Html(_response);
                    _response.Write(@"</td></tr> ");
                }

                _response.Write(@"</table>");


                if (mp_objGrid != null)
                {

                    mp_objGrid.SetCustomDrawer(null);

                }
                else
                {

                    //mp_objCalendar.SetCustomDrawer(null);
                }

            }
            _response.Write("</fieldset>");
            _response.Write(@"</form>");

            return _response.Out();

        }

        private string Get_Filter_User_Profile()
        {
            string tempFilterProfile = string.Empty;
            string[] aInfo;
            string[] aInfo1;
            int nNumAttrib = 0;
            int i = 0;
            string strSql = string.Empty;
            TSRecordSet rs = new TSRecordSet();
            string strColMyMessage = string.Empty;

            if (!String.IsNullOrEmpty(mp_Info_User_Profile))
            {
                aInfo1 = mp_Info_User_Profile.Split(':');
                if (aInfo1.GetUpperBound(0) == 1)
                {
                    strColMyMessage = aInfo1[1];
                }

                aInfo = aInfo1[0].Split(',');
                nNumAttrib = aInfo.GetUpperBound(0);

                for (i = 0; i <= nNumAttrib; i++)
                {
                    mp_strcause = "costruzione filter user profile idpfu=" + mp_User + " attrib=" + aInfo[i];
                    strSql = $"select attvalue from profiliutenteattrib where idpfu={mp_User} and dztnome='{aInfo[i].Replace("'", "''")} '";
                    //rs = CommonDbFunctions.GetRSReadFromQuery_(strSql, mp_strConnectionString);
                    rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                    if (rs != null)
                    {
                        if (rs.RecordCount > 0)
                        {
                            if (!String.IsNullOrEmpty(tempFilterProfile))
                            {
                                tempFilterProfile = tempFilterProfile + " and ";
                            }

                            tempFilterProfile += "( " + aInfo[i] + " in (select attvalue from profiliutenteattrib where idpfu=" + mp_User + " and dztnome='" + aInfo[i].Replace("'", "''") + "' )";
                            //'--se indicata la colonna per prendere comunque i documenti fatti dall'utente collegato
                            if (!String.IsNullOrEmpty(strColMyMessage))
                            {
                                tempFilterProfile = tempFilterProfile + " or " + strColMyMessage + "=" + mp_User;
                            }


                            tempFilterProfile = tempFilterProfile + " )";
                        }
                    }
                }
            }

            return tempFilterProfile;
        }

        private TSRecordSet GetRSGrid(string strTable, string strFilter, string strConnectionString)
        {
            return DashBoardMod.GetRSGrid(mp_OWNER, mp_User, mp_strTable, mp_Filter, mp_FilterHide, strConnectionString, mp_Top);
        }

        private string RetrieveSortFromProperty()
        {
            string[] aInfo;
            int nCol = 0;
            int A = 0;
            string[] aInfoDett;
            string strSort = string.Empty;
            int i = 0;


            if (mp_Property.ToLower() != "yes")
            {
                aInfo = mp_Property.Split('#');
                nCol = aInfo.GetUpperBound(0);

                for (i = 0; i <= nCol; i++)
                {
                    try
                    {
                        aInfoDett = aInfo[i].Split(',');

                        if (aInfo[i] == "1")
                        {
                            strSort = aInfoDett[0] + " " + aInfoDett[2];
                        }
                        else
                        {
                            strSort += "," + aInfoDett[0] + " " + aInfoDett[2];
                        }

                    }
                    catch (Exception ex)
                    {
                        // return null;
                    }
                }
            }
            else
            {
                i = 1;
                try
                {
                    while (i <= mp_Columns.Count)
                    {

                        /* While i <= mp_ColumnsProp.count
                            If strSort = "" Then
                                strSort = mp_ColumnsProp(i).Name & " "
                            Else
                                strSort = strSort & "," & mp_ColumnsProp(i).Name & " "
                             End If
            
                           i = i + 1
                        Wend */

                        if (String.IsNullOrEmpty(strSort))
                        {
                            strSort = mp_ColumnsProp.ElementAt(i).Value + " ";  // Name??? vedi codice vb6
                        }
                        else
                        {
                            strSort += "," + mp_ColumnsProp.ElementAt(i).Value + " ";// Name??? vedi codice vb6
                        }

                        i++;
                    }
                }
                catch (Exception ex)
                {
                    // return null;
                }


            }
            return strSort;
        }

        public void Html(IEprocResponse response)
        {


            response.Write("<div");

            response.Write($@" class=""width_100_percent height_100_percent overflow_auto"">");

            mp_ObjButtonBar.Html(response);

            mp_objModel = new PropertySelector(response);

            mp_objModel.Html(response);

            response.Write("</div>");

        }
        public Fld_Label HTML_SynteticHelp(string strTitle, string Icon = "", string strAction = "", string strPath = "../images/")
        {
            Fld_Label obj = new Fld_Label();
            obj.PathImage = strPath;
            obj.Style = "SinteticHelp";

            obj.Value = strTitle;
            obj.Image = Icon;

            obj.setOnClick(strAction);
            obj.Html(_response);
            return obj;
        }
        private void RimuoviColonne(Dictionary<string, Field> Columns, Dictionary<string, Grid_ColumnsProperty> ColumnsProperty)
        {
            int i;
            //dynamic obj;
            Grid_ColumnsProperty prop;
            i = 1;
            foreach (KeyValuePair<string, Field> col in Columns)
            {
                {
                    try
                    {
                        //obj = col;
                        prop = ColumnsProperty[col.Value.Name];
                        if (prop.Hide == true)
                        {
                            Columns.Remove(col.Key);
                        }
                        else
                        {
                            i = i + 1;
                        }

                    }
                    catch
                    {
                        i = i + 1;
                    }

                }
            }


        }

        //check codice - 22/04/2022 su suggerimento di Federico questo metodo non va tradotto in quanto inconsistente
        private void RimuoviColonneAssenti(Dictionary<string, Field> Columns, TSRecordSet rs)
        {

            /*Dim i As Integer
    Dim obj As Object
    Dim v As Variant
    
    On Error Resume Next
    
    i = 1
    
    If IsEmpty(Columns) = True Then
    
        While i <= Columns.count
        
            Set obj = Columns(i)
            v = rs(obj.Name)
            
            '-- se la colonna non è presente nel recordset
            If err.Number <> 0 Then
                err.Clear
                Columns.Remove i
            Else
                '-- oppure è un tipo su cui non è possibile fare l'ordinamento
                If (rs.Fields(obj.Name).Type = adLongVarWChar Or rs.Fields(obj.Name).Type = adLongVarChar) Then
                    err.Clear
                    Columns.Remove i
                End If
            End If
            
            i = i + 1
            
        Wend
        
    End If}
            */
        }


        #region AddRowCondition VB6

        //Private Sub AddRowCondition()

        //    Dim strRC As String
        //    Dim vcon As Variant

        //    On Error Resume Next

        //    strRC = Request_QueryString("ROWCONDITION")
        //    If strRC <> "" Then
        //        Dim vRC As Variant
        //        'Dim vcon As Variant
        //        Dim i As Integer
        //        Dim n As Integer

        //        vRC = Split(strRC, "~")
        //        n = UBound(vRC)
        //        For i = 0 To n - 1
        //            vcon = Split(vRC(i), ",")
        //            mp_objGrid.AddRowCondition CStr(vcon(0)), CStr(vcon(1))
        //        Next


        //    End If

        //    strRC = Request_QueryString("NOTREAD")
        //    If UCase(strRC) = "YES" Then
        //          mp_objGrid.AddRowCondition "BLACK", "bRead=1"
        //    End If

        //End Sub

        #endregion

        private void AddRowCondition()
        {

            string strRC;
            string[] vcon;

            strRC = GetParamURL(Request_QueryString, "ROWCONDITION");
            if (strRC != "")
            {
                string[] vRC;
                int i;
                int n;

                vRC = Strings.Split(strRC, "~");
                n = vRC.GetUpperBound(0); // Information.UBound(vRC);
                for (i = 0; i < n; i++)
                {
                    vcon = Strings.Split(vRC[i], ",");
                    mp_objGrid.AddRowCondition(vcon[0], vcon[1]);
                }


            }

            strRC = GetParamURL(Request_QueryString, "NOTREAD");
            if (strRC.ToUpper() == "YES")
            {
                mp_objGrid.AddRowCondition("BLACK", "bRead=1");
            }

        }

        public bool checkHackSecurity(Session.ISession session, EprocResponse response)
        {
            BlackList mp_objDBBL = new BlackList();  // Cambiato nome all'istanza di BlackList per evitare ambiguita con l'istanza di LibDbModelExt con lo stesso nome

            //dynamic attackerInfo = null;

            bool result = false;  // valore che la funzione restituisce
            if (!mp_objDBBL.isDevMode())
            {
                // table
                if (!Basic.isValid(mp_strTable, 1))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                if (!Basic.isValid(GetParamURL(Request_QueryString, "CAL_FESTIVITY"), 1))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_SQLINJECTION.Replace("##nome-parametro##", "CAL_FESTIVITY")), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // mancanza del parametro owner se però era richiesto
                if (mp_objDBBL.isOwnerObblig(mp_strTable) && String.IsNullOrEmpty(mp_OWNER))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_OWNER), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // owner
                if (!Basic.isValid(mp_OWNER, 1))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_OWNER), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // 'sort, sostituzione di caratteri non ammessi
                mp_Sort = mp_Sort.Replace(";", " ");
                mp_Sort = mp_Sort.Replace("--", " ");
                mp_Sort = mp_Sort.Replace("'", " ");

                // 'Per il sort permettiamo decimali,caratteri dalla a alla z, underscore e virgole e spazi,
                if ((!Basic.isValid(mp_Sort, 0, @"[\d_, a-zA-Z]{4,50}")) && (!Basic.isValidSortSql(mp_Sort)))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_SORT), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // sort order

                if (!String.IsNullOrEmpty(mp_SortOrder))
                {
                    if (mp_SortOrder.ToUpper() != "ASC" && mp_SortOrder.ToUpper() != "DESC")
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_SORT_ORDER), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }



                // filterhide
                if (!Basic.isValidaSqlFilter(GetParamURL(Request_QueryString, mp_FilterHide), mp_strConnectionString))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // filter 
                if (!Basic.isValidaSqlFilter(mp_Filter, mp_strConnectionString))
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTER), session, mp_strConnectionString);
                    result = true;
                    return result;
                }


                // identity
                if (!String.IsNullOrEmpty(mp_IDENTITY))
                {
                    if (!Basic.isValid(mp_IDENTITY, 1))
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_IDENTITY), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                // TOOLBAR
                if (!String.IsNullOrEmpty(mp_StrToolbar))
                {
                    if (!Basic.isValid(mp_StrToolbar, 0, @"[\d,_a-zA-Z]{2,100}"))
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_TOOLBAR), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                // ModGriglia
                if (!String.IsNullOrEmpty(mp_ModGriglia))
                {
                    if (!Basic.isValid(mp_ModGriglia, 1))
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_MODGRIGLIA), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                //POSITIONALMODELGRID
                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "POSITIONALMODELGRID")))
                {
                    if (!Basic.isValid(GetParamURL(Request_QueryString, "POSITIONALMODELGRID"), 1))
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_POSITIONALMODELGRID), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                // 'mp_ModFiltroAdd
                if (!string.IsNullOrEmpty(mp_ModFiltroAdd))
                {
                    if (!Basic.isValid(mp_ModFiltroAdd, 1))
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_MODFILTROADD), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }


                // mp_ModFiltroUpd
                if (!string.IsNullOrEmpty(mp_ModFiltroUpd))
                {
                    if (!Basic.isValid(mp_ModFiltroUpd, 1))
                    {
                        mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_MODFILTROUPD), session, mp_strConnectionString);
                        result = true;
                        return result;

                    }
                }

                // Controllo se l'utente è autorizzato ad accedere allo specifico oggetto sql (tabella, vista)
                if (Basic.checkPermission(mp_strTable, _session, mp_strConnectionString) == false)
                {
                    mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_CONTROLLO_PERMESSI.Replace("##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
                    result = true;
                    return result;

                }
            }
            return result;
        }

    }
}

