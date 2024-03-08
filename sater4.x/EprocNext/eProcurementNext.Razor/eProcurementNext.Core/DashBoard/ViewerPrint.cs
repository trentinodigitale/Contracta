using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.DashBoard
{
    public class ViewerPrint
    {
        private dynamic mp_ObjSession;
        string mp_Suffix = string.Empty;
        long mp_User = 0;
        string mp_Permission = string.Empty;
        string mp_strConnectionString = string.Empty;

        private Toolbar mp_objToolbasr = new Toolbar();
        private Grid mp_objGrid = new Grid();
        private Fld_Label mp_objHelp = new Fld_Label();
        private ScrollPage mp_grSP = new ScrollPage();

        private Dictionary<string, Field> mp_Columns = new Dictionary<string, Field>();
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
        private BlackList mp_objDB;
        private TabManage mp_objDBTM;

        private string mp_strCause = string.Empty;
        private string mp_Filter = string.Empty;
        private string mp_FilterHide = string.Empty;
        private string mp_NumeroPagina = string.Empty;
        private string mp_Sort = string.Empty;
        private string mp_SortOrder = string.Empty;

        private string Request_QueryString;
        private IFormCollection Request_Form;
        private string mp_strTable = string.Empty;
        private string mp_querystring = string.Empty;
        private int mp_Row_For_Page = 0;
        private long mp_numRec = 0;
        private string mp_IDENTITY = string.Empty;

        private Fld_Hidden mp_fldCurFiltro = new Fld_Hidden();
        private Fld_Hidden mp_fldCurPag = new Fld_Hidden();
        private Fld_Hidden mp_CurSort = new Fld_Hidden();
        private Fld_Hidden mp_CurSortOrder = new Fld_Hidden();
        private Fld_Hidden mp_fldCurTable = new Fld_Hidden();
        private Fld_Hidden mp_fldQueryString = new Fld_Hidden();

        private Model mp_objModel = new Model();
        private Fld_Label mp_objCaption = new Fld_Label();
        private string mp_strModelloFiltro = string.Empty;

        private string mp_ModFiltroAdd = string.Empty;
        private string mp_ModFiltroUpd = string.Empty;

        private string mp_strToolbar = string.Empty;
        private string mp_strPathJSToolBar = string.Empty;
        private string mp_OWNER = string.Empty;
        private string mp_StrMsg = string.Empty;

        private string mp_StrDocumentType = string.Empty;
        private dynamic mp_session;
        private TSRecordSet rs = new TSRecordSet();
        private TSRecordSet mp_Rs = new TSRecordSet();
        private string mp_RSConnectionString = string.Empty; // -- se è presente una particolare connection string per la query
        private string mp_ModGriglia = string.Empty;

        private string mp_strStoredSQL = string.Empty;
        private string mp_strZoom = string.Empty;

        private string mp_ModFiltro = string.Empty;
        private string mp_idViewer = string.Empty;

        private long mp_timeout = 0;

        private Session.ISession _session;
        private IEprocResponse _response;
        private HttpContext _context;
        private IConfiguration _configuration;

        public ViewerPrint(HttpContext context, Session.ISession session, IEprocResponse response, IConfiguration configuration)
        {
            this._response = response;
            this._session = session;
            this._context = context;
            this._configuration = configuration;
            mp_objDB = new BlackList();
        }

        public void run()
        {
            string Filter = string.Empty;
            mp_session = _session;
            InitLocal();

            // controlli di sicurezza
            if (checkHackSecurity())
            {
                // se è presente NOMEAPPLICATION nell'application
                if (!String.IsNullOrEmpty(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]))
                {
                    _context.Response.Redirect("/" + Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp");
                }
                else
                {
                    _context.Response.Redirect($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp");
                }
            }

            InitGUIObject();

            Draw("");


        }

        private void InitLocal()
        {
            mp_ObjSession = _session;

            mp_Suffix = _session[SessionProperty.SESSION_SUFFIX];
            if (String.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            mp_strConnectionString = Application.ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
            //Request_Form = _context.Request.Form;

            if (!String.IsNullOrEmpty(_context.Request.Query["ConnectionString"]))
            {  // non si può fare con GetParamURL?
                mp_RSConnectionString = _context.Request.Query["ConnectionString"];
            }

            if (String.IsNullOrEmpty(mp_RSConnectionString))
            {
                mp_RSConnectionString = mp_strConnectionString;
            }

            mp_User = _session[SessionProperty.SESSION_USER];
            mp_Permission = _session[SessionProperty.SESSION_PERMISSION];

            mp_IDENTITY = CommonModule.Basic.GetParamURL(Request_QueryString, "IDENTITY");
            if (String.IsNullOrEmpty(mp_IDENTITY))
            {
                mp_IDENTITY = "id";
            }

            mp_NumeroPagina = CommonModule.Basic.GetParamURL(Request_QueryString, "nPag");

            if (CommonModule.Basic.GetParamURL(Request_QueryString, "URLDECODE").ToLower() == "yes")
            {
                mp_Filter = CommonModule.Basic.GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = CommonModule.Basic.GetParamURL(Request_QueryString, "FilterHide");
            }
            else
            {
                // duplicato per rispettare codice VB6 ch essenzialmente fa le stesse cose (vedi GetParamURL)
                mp_Filter = CommonModule.Basic.GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = CommonModule.Basic.GetParamURL(Request_QueryString, "FilterHide");
            }

            if (string.IsNullOrEmpty(mp_Filter) && CommonModule.Basic.GetParamURL(Request_QueryString, "FilterRecovery") != "no")
            {

                try
                {
                    mp_Filter = _session[mp_idViewer];
                }
                catch
                {
                    mp_Filter = "";
                }
            }

            mp_Sort = CommonModule.Basic.GetParamURL(Request_QueryString, "Sort");
            mp_SortOrder = CommonModule.Basic.GetParamURL(Request_QueryString, "SortOrder");
            mp_Row_For_Page = CInt(CommonModule.Basic.GetParamURL(Request_QueryString, "RowForPag"));
            if (mp_Row_For_Page <= 0)
            {
                mp_Row_For_Page = 50;
            }
            mp_OWNER = CommonModule.Basic.GetParamURL(Request_QueryString, "OWNER");

            mp_strTable = CommonModule.Basic.GetParamURL(Request_QueryString, "Table");

            mp_strModelloFiltro = CommonModule.Basic.GetParamURL(Request_QueryString, "ModelloFiltro");
            if (String.IsNullOrEmpty(mp_strModelloFiltro))
            {
                mp_strModelloFiltro = mp_strTable + "Filtro";
            }

            mp_ModGriglia = CommonModule.Basic.GetParamURL(Request_QueryString, "ModGriglia");
            if (String.IsNullOrEmpty(mp_ModGriglia))
            {
                mp_ModGriglia = mp_strTable + "Griglia";
            }

            mp_strStoredSQL = "";
            if (!string.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString, "STORED_SQL")))
            {
                mp_strStoredSQL = CommonModule.Basic.GetParamURL(Request_QueryString, "STORED_SQL");
            }

            mp_strToolbar = CommonModule.Basic.GetParamURL(Request_QueryString, "TOOLBAR");
            mp_idViewer = string.Format("{0}_{1}_{2}_{3}_{4}", mp_ModGriglia, mp_strModelloFiltro, mp_strTable, mp_OWNER, mp_strToolbar);

            mp_strZoom = "";
            if (!String.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString, "Zoom")))
            {
                mp_strZoom = CommonModule.Basic.GetParamURL(Request_QueryString, "Zoom") + "%";
            }

            if (!String.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString, "TIMEOUT")))
            {
                mp_timeout = Convert.ToInt64(CommonModule.Basic.GetParamURL(Request_QueryString, "TIMEOUT"));
            }
        }

        public void Draw(string filter)
        {
            string sOperation = GetParamURL(Request_QueryString, "OPERATION");

            switch (sOperation)
            {
                case "PRINT":
                    Draw_Print(filter);
                    break;
                case "EXCEL":
                    Draw_Excel(filter);
                    break;
            }
        }

        private void Draw_Excel(string filter)
        {
            _response.Write("</head><body>" + Environment.NewLine);
            _response.Write("<table width=\"100%\" >");


            string sCaption = GetParamURL(Request_QueryString, "CaptionPrint");
            if (!String.IsNullOrEmpty(sCaption))
            {
                _response.Write("<tr><td>");


                string sCaptionML = GetParamURL(Request_QueryString, "CaptionML");
                if (!String.IsNullOrEmpty(sCaptionML))
                {
                    _response.Write(sCaption.Trim());
                }
                else
                {
                    _response.Write(ApplicationCommon.CNV(sCaption.Trim(), mp_ObjSession));
                }

                _response.Write("</td></tr>");
            }

            // disegna area di riepilogo di filtro
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "FiltroPrint")))
            {
                mp_strCause = "disegna area di riepilogo di filtro";
                _response.Write("<tr><td width=\"100%\"> ");
                mp_objModel.Excel(_response);
                _response.Write("</td></tr>");
            }

            // disegna la griglia
            mp_strCause = "disegna la griglia ";
            _response.Write("<tr  ><td  width=\"100%\" >");
            mp_objGrid.Excel(_response);
            _response.Write("</td></tr>");
            _response.Write("</table>");
        }

        public void Draw_Print(string Filter)
        {
            int np = 0;
            int i = 0;

            np = mp_Rs.RecordCount / mp_Row_For_Page;

            if (np * mp_Row_For_Page < mp_Rs.RecordCount)
            {
                np++;
            }

            for (i = 1; i <= np; i++)
            {
                mp_objGrid.SetPage(Convert.ToInt64(i), Convert.ToInt64(mp_Row_For_Page));

                if (!String.IsNullOrEmpty(mp_strZoom))
                {
                    _response.Write($"<div width=\"100%\" height=\"100%\" style=\"zoom:{mp_strZoom}\" > ");
                }
                // disegna la griglia
                mp_strCause = "disegna la griglia";
                _response.Write("<table width=\"100%\">");

                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "FilterPrint")))
                {
                    mp_strCause = "disegna area di riepilogo di filtro";
                    _response.Write("<tr><td width=\"100%\" >");
                    mp_objModel.Html(_response);
                    _response.Write("</td></tr>");
                }

                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "CaptionPrint")))
                {
                    Caption objCaption = new Caption();
                    if (GetParamURL(Request_QueryString, "PrintMode").ToUpper() == "YES")
                    {
                        objCaption.PrintMode = true;
                    }

                    objCaption.Init(_session);
                    objCaption.ShowExit = false;

                    _response.Write("<tr><td>");
                    string sCaptionNoML = GetParamURL(Request_QueryString, "CaptionNoML");
                    string sCaptionPrint = GetParamURL(Request_QueryString, "CaptionPrint").Trim();

                    if (!String.IsNullOrEmpty(sCaptionNoML))
                    {
                        _response.Write(objCaption.SetCaption(sCaptionPrint));
                    }
                    else
                    {
                        _response.Write(objCaption.SetCaption(ApplicationCommon.CNV(sCaptionPrint, mp_ObjSession)));
                    }
                    _response.Write("</td></tr>");
                }

                _response.Write("<tr  ><td  width=\"100%\" >");
                mp_objGrid.PrintMode = true;
                mp_objGrid.Html(_response);
                _response.Write("</td></tr>");

                _response.Write("</table>");
                if (!String.IsNullOrEmpty(mp_strZoom))
                {
                    _response.Write("</div>");
                }

                //'-- inserisco il salto pagina
                if (i < np)
                {
                    _response.Write("<div style=\"page-break-after : always\"  ></div>");
                }
            }
        }

        // Inizializzo gli oggetti dell'interfaccia
        private void InitGUIObject()
        {

            //   dynamic objDBFunction;
            LibDbModelExt objDB = new LibDbModelExt(_configuration);
			TSRecordSet rs = new TSRecordSet();
			string[] v = null;
            int i = 0;
            //Grid mp_objGrid = new Grid();

            // recupero il recordset del Viewer dal database
            mp_strCause = "recupero il recordset del viewer dal database";
            string strSort = $"{mp_Sort} {mp_SortOrder}";
			rs = DashBoardMod.GetRSGrid(mp_OWNER, mp_User, mp_strTable, mp_Filter, mp_FilterHide, mp_RSConnectionString, "", strSort, mp_timeout, mp_strStoredSQL);  //IL SORT viene fatto direttamente dalla SQL a differenza di VB6 dove veniva effettuato più giù
			mp_Rs = rs;


            // recupero la collezione di colonne da visualizzare
            mp_strCause = "recupero la collezione di colonne da visualizzare";

            LibDbModelExt mp_ObjDBML = new LibDbModelExt(_configuration);  // attenzione: in VB6 è dichiarato Object e in precedenza era istanza BlackList
                                                                           // quindi credo altra istanza ma verificare che non ci siano problemi
            mp_ObjDBML.GetFilteredFields(mp_ModGriglia, ref mp_Columns, ref mp_ColumnsProperty, mp_Suffix, 0, 0, mp_strConnectionString, _session, false);

            // recupero il modell di filtro 
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "ModelloFiltro")))
            {
                mp_objModel = mp_ObjDBML.GetFilteredModel(GetParamURL(Request_QueryString, "ModelloFiltro"), mp_Suffix, 0, 0, mp_strConnectionString, false, mp_ObjSession);
            }
            else
            {
                mp_objModel = mp_ObjDBML.GetFilteredModel(mp_strTable + "Filtro", mp_Suffix, 0, 0, mp_strConnectionString, false, mp_ObjSession);
            }

            mp_objModel.NumberColumn = 2;
            mp_objModel.Editable = false;

            string strFilter = string.Empty;
            string p = string.Empty;
            string[] _p;
            string ValueField = string.Empty;
            string NameField = string.Empty;

            string _Filter = GetParamURL(Request_QueryString, "Filter");

            if (mp_strStoredSQL != "yes")
            {
                string s = string.Empty;

                if (string.IsNullOrEmpty(_Filter) && GetParamURL(Request_QueryString, "FilterRecovery") != "no")
                {
                    try
                    {
                        v = mp_ObjSession[mp_idViewer].Split("and");
                        s = mp_ObjSession[mp_idViewer];
                    }
                    catch
                    {

                    }


                }
                else
                {

                    v = _Filter.Split("and");
                    s = _Filter;
                }

                if (!string.IsNullOrEmpty(s))
                {
                    for (i = 0; v != null && i < v.Length; i++)  // verificare con ciclo VB6
                    {
                        strFilter = v[i];
                        ValueField = GetValue_FromAttrib_Filter(strFilter, ref NameField);
                        mp_objModel.Fields[NameField].Value = ValueField;
                    }
                }
            }
            else
            {
                // verifico se è passato un filtro per default
                if (!String.IsNullOrEmpty(_Filter))
                {
                    string[] vAtt;
                    string[] vVal;
                    string[] vCond;

                    v = mp_Filter.Split("#~#");
                    vAtt = v[0].Split("#@#");
                    vVal = v[1].Split("#@#");
                    vCond = v[2].Split("#@#");
                    for (i = 0; i < vAtt.Length; i++)
                    {
                        p = vVal[i].Replace("'", "");
                        // inserisce il valore sull'attributo
                        mp_objModel.Fields[vAtt[i]].Value = p;
                    }

                }
            }

            // verifica se è passato un filtro nascosto per default
            string sFHide = GetParamURL(Request_QueryString, "FilterHide");
            string sColTitle = GetParamURL(Request_QueryString, "COL_TITLE");
            string sHCol = GetParamURL(Request_QueryString, "HIDE_COL");

            if (!String.IsNullOrEmpty(sFHide))
            {
                v = sFHide.Split("and");
                for (i = 0; i < v.Length; i++)
                {
                    strFilter = v[i];
                    strFilter = strFilter.Trim().Replace("'", "");
                    _p = strFilter.Split('=');

                    // inserisce il valore sull'attributo  e lo blocca
                    try
                    {
                        mp_objModel.Fields[_p[0].Trim()].Value = _p[1].Trim();
                    }
                    catch { }

                }
            }

            // TOTO: verificare i vari Left e Mid
            if (!string.IsNullOrEmpty(sColTitle))
            {
                string[] vCol = sColTitle.Split("~");
                for (i = 0; i < vCol.Length; i++)
                {
                    v = vCol[i].Split(",");
                    if ((v[1].Substring(0, 1) == "*"))
                    {
                        mp_Columns[v[0]].Caption = mp_Columns[v[0]].Caption + " " + v[1].Substring(1, 2);
                    }
                    else
                    {
                        mp_Columns[v[0]].Caption = v[1];
                    }
                }
            }

            // inizializzo il riepilogo con i dati presi dal filtro
            // mp_objModel.SetFieldsValue Request_Form

            if (!String.IsNullOrEmpty(sHCol))
            {
                v = sHCol.Split(",");
                for (i = 0; i < v.Length; i++)
                {
                    mp_Columns.Remove(v[i]);
                }
            }

            // nascondo le colonne funzioni
            if (mp_ColumnsProperty.ContainsKey("FNZ_UPD")) { mp_ColumnsProperty["FNZ_UPD"].Hide = true; };
            if (mp_ColumnsProperty.ContainsKey("FNZ_DEL")) { mp_ColumnsProperty["FNZ_DEL"].Hide = true; };
            if (mp_ColumnsProperty.ContainsKey("FNZ_COPY")) { mp_ColumnsProperty["FNZ_COPY"].Hide = true; };
            if (mp_ColumnsProperty.ContainsKey("FNZ_OPEN")) { mp_ColumnsProperty["FNZ_OPEN"].Hide = true; };

            // inizializzo la griglia del viewer
            mp_strCause = "inizializzo la griglia del Viewer";
            mp_objGrid.Columns = mp_Columns;
            mp_objGrid.ColumnsProperty = mp_ColumnsProperty;
            mp_objGrid.RecordSet(rs, mp_IDENTITY, false);
            mp_objGrid.id = "GridViewer";
            mp_objGrid.width = "100%";

            //IL SORT viene fatto direttamente alla SQL chiamato sopra 
            //if (!String.IsNullOrEmpty(mp_Sort))
            //{
            //    rs.Sort(mp_Sort + " " + mp_SortOrder);
            //}

            if (!String.IsNullOrEmpty(GetParamURL(RequestQueryString, "TOTAL")))
            {
                string[] vvv = GetParamURL(RequestQueryString, "TOTAL").Split(",");
                mp_objGrid.ShowTotal(ApplicationCommon.CNV(vvv[0], mp_ObjSession), Convert.ToInt32(vvv[1]));
            }

            mp_numRec = rs.RecordCount;


        }
        public bool checkHackSecurity()
        {
            bool result = false;

            //Dim attackerInfo As New Collection

            // Set mp_objDB = CreateObject("ctldb.BlackList")

            if ((!mp_objDB.isDevMode()) && (!Basic.isValid(mp_strTable, 1)))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), _session, mp_strConnectionString);
                result = true;
                return result;
            }

            if (!mp_objDB.isDevMode() && (mp_objDB.isOwnerObblig(mp_strTable) && String.IsNullOrEmpty(mp_OWNER)))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_OWNER), _session, mp_strConnectionString);
                result = true;
                return result;
            }

            if (!mp_objDB.isDevMode())
            {
                //'sort, sostituzione di caratteri non ammessi
                mp_Sort = mp_Sort.Replace(";", " ");
                mp_Sort = mp_Sort.Replace("--", " ");
                mp_Sort = mp_Sort.Replace("'", " ");

                //Per il sort permettiamo decimali,caratteri dalla a alla z, underscore e virgole e spazi,
                if (!Basic.isValid(mp_Sort, 0, @"[\d_, a-zA-Z]{4,50}") && !Basic.isValidSortSql(mp_Sort))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_SORT), _session, mp_strConnectionString);
                    result = true;
                    return result;
                }
            }

            if (!String.IsNullOrEmpty(mp_SortOrder))
            {
                if (!mp_objDB.isDevMode() && mp_SortOrder.ToUpper() != "ASC" && mp_SortOrder.ToUpper() != "DESC")
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_SORT_ORDER), _session, mp_strConnectionString);
                    result = true;
                    return result;
                }
            }

            if (!mp_objDB.isDevMode() && !Basic.isValidaSqlFilter(mp_FilterHide, mp_strConnectionString))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), _session, mp_strConnectionString);
                result = true;
                return result;
            }

            if (!mp_objDB.isDevMode() && !Basic.isValidaSqlFilter(mp_Filter, mp_strConnectionString))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), _session, mp_strConnectionString);
                result = true;
                return result;
            }

            if (!String.IsNullOrEmpty(mp_IDENTITY))
            {
                if (!mp_objDB.isDevMode() && !Basic.isValid(mp_IDENTITY, 1))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_IDENTITY), _session, mp_strConnectionString);
                    result = true;
                    return result;
                }
            }

            // TOOLBAR
            if (!String.IsNullOrEmpty(mp_strToolbar))
            {
                if (!mp_objDB.isDevMode() && !Basic.isValid(mp_strToolbar, 0, @"[\d,_a-zA-Z]{1,250}"))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_TOOLBAR), _session, mp_strConnectionString);
                    result = true;
                    return result;
                }
            }

            // owner
            if (!mp_objDB.isDevMode() && !Basic.isValid(mp_OWNER, 1))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_OWNER), _session, mp_strConnectionString);
                result = true;
                return result;
            }

            //ModGriglia
            if (!String.IsNullOrEmpty(mp_ModGriglia))
            {
                if (!mp_objDB.isDevMode() && !Basic.isValid(mp_ModGriglia, 1))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_QUERY_MODGRIGLIA), _session, mp_strConnectionString);
                    result = true;
                    return result;
                }
            }

            // Controllo se l'utente è autorizzato ad accedere allo specifico oggetto sql (tabella, vista)
            if (!mp_objDB.isDevMode() && Basic.checkPermission(mp_strTable, _session, Application.ApplicationCommon.Application["ConnectionString"]) == false)
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(_context, _session[SessionProperty.IdPfu], ATTACK_CONTROLLO_PERMESSI), _session, mp_strConnectionString);
                result = true;
                return result;

            }

            return result;
        }

    }
}

