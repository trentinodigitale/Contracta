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
    public class CubeGrid
    {
        //'-- parametri amessi sull'URL
        //'-- Table        = nome della tabella o della vista da visualizzare
        //'-- ModGriglia   = nome modello dati, di base ha il nome della tabella pi� Griglia
        //'-- IDENTITY     = opzionale, campo che contiene l'identity di riga sul DB, per default = 'id'
        //'-- OWNER        = opzionale, se presente attua un filtro sull'idpfu con il nome del campo indicato
        //'-- FilterHide   = opzionale, effettua un filtro sul risultato , la stringa deve essere compatibile con un URL ( chiamare URLEncode )
        //'-- Caption      = opzionale, se presente visualizza una testata con il titolo passato
        //'-- FilteredOnly = yes
        //'-- OPERATION    = PRINT - EXCEL
        //'-- JSIN         = yes - se i jscript sono in linea
        //'-- NOTE         = inserisce delle note sopra la griglia
        //'-- GROUPNAME    = aggiunge alla Caption una scritta senza ML
        //'-- JScript
        //'-- FilterHide
        //'-- Filter
        //'-- Table
        //'-- ModGriglia
        //'-- ModelloFiltro
        //'-- OWNER
        //'-- TOOLBAR
        //'-- PATHTOOLBAR
        //'-- MODULE
        //'-- STORED_SQL
        //'-- TEXT         = se vale "no" riporta la griglia a visualizzare tutti i dati e non solo la forma testuale
        //'-- SORT_COL     =
        //'-- TIMEOUT      = Timeout per l'esecuzione delle query

        private eProcurementNext.Session.ISession mp_ObjSession; // As Variant //'-- oggetto che contiene il vettore base con gli elementi della libreria
        private string mp_Suffix = string.Empty;
        private long mp_User = 0;
        private string mp_Permission = string.Empty;
        private string mp_strConnectionString = string.Empty;
        private Toolbar mp_objToolbar; // As CtlHtml.Toolbar
        private GridMultiDimension mp_objGrid; // As CtlHtml.GridMultiDimension
        private ScrollPage mp_grSP; // As CtlHtml.ScrollPage
        private Model mp_objModel; // As CtlHtml.Model
        private string mp_strTable = string.Empty; //'-- nome della tabella per l'estrazione
        private string mp_ModGriglia = string.Empty; //'-- nome del modello dati
        private static string mp_StrToolbar = string.Empty;
        private TSRecordSet mp_Rs = new TSRecordSet(); // As ADODB.Recordset
        private Dictionary<string, ClsDomain> mp_collDomains = new Dictionary<string, ClsDomain>();
        private Dictionary<string, Field> mp_Columns = new Dictionary<string, Field>();
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
        private LibDbModelExt mp_objDB = new LibDbModelExt();
        private string mp_strcause = string.Empty;
        private string mp_Filter = string.Empty;
        private string mp_Filter_Hide = string.Empty;
        private string mp_NumeroPagina = string.Empty;
        private string mp_Property = string.Empty;
        private string mp_Command = string.Empty;
        private string Request_QueryString = string.Empty;
        private IFormCollection? Request_Form;
        private string mp_queryString = string.Empty;
        private int mp_Row_For_Page = 0;
        private string mp_ModuleBudget = string.Empty; //'-- modulo di budget
        private string mp_AllFiltro = string.Empty;
        private string mp_OWNER = string.Empty;
        private string mp_strStoredSQL = string.Empty;
        private string mp_SORT_COL = string.Empty;
        private Session.ISession _session;
        private EprocResponse _response;
        public IConfiguration configuration;
        private HttpContext _context;


        private CommonDbFunctions cdf = new CommonDbFunctions();

        public CubeGrid(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this.configuration = configuration;

            this._session = session;

            this._context = httpContext;
            this._response = new EprocResponse(CommonModule.Basic.GetParamURL(_context.Request.QueryString.ToString(), "XML_ATTACH_TYPE"));
        }

        public string run(IEprocResponse _response)
        {
            try
            {
                //_context = _accessor.HttpContext;
                Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;

                //'-- recupero variabili di sessione
                mp_strcause = "InitLocal session";
                InitLocal();

                //'-- Controlli di sicurezza
                if (checkHackSecurity(_context, _session))
                {


                    //'Se � presente NOMEAPPLICAZIONE nell'application
                    if (!string.IsNullOrEmpty(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]))
                    {

                        _context.Response.Redirect("/" + Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp");
                        return null;



                    }
                    else
                    {

                        _context.Response.Redirect("/application/blocked.asp");
                        return null;

                    }

                }

                //'-- Esegue i comando richiesti sulla tabella come add,del upd
                mp_strcause = "ExecuteAction";
                ExecuteAction();


                //'-- Inizializzo gli oggetti dell'interfaccia
                mp_strcause = "InitGUIObject";
                InitGUIObject();


                //'-- disegna
                mp_strcause = @"run = Draw(session, """", Response)";
                return Draw(_session, "", _response);

            }
            catch (Exception ex)
            {
                throw new Exception(mp_strcause + ", CUBEGRID, FUNZIONE: RUN", ex);
            }

        }


        public string Draw(Session.ISession session, string Filter, IEprocResponse Response)
        {

            //'----------------------------------
            //'-- avvia la scrittura della pagina
            //'----------------------------------
            if (CommonModule.Basic.GetParamURL(Request_QueryString.ToString(), "FilteredOnly") == "yes" && string.IsNullOrEmpty(mp_Filter))
            {
            }
            else
            {


                if (mp_Rs.RecordCount == 0)
                {
                    Response.Write("</head><body>" + Environment.NewLine);

                    Response.Write(@"<table width=""100%"" height=""100%"" >");
                    Response.Write(@"<tr><td width=""100%"" height=""100%"" >");


                    HTML.Basic.HTML_SinteticHelp(Response, Application.ApplicationCommon.CNV("Il risultato dell'analisi è nullo, provare con altri parametri", mp_ObjSession));


                    Response.Write("</td></tr></table>");
                    return Response.Out();
                }



                switch (CommonModule.Basic.GetParamURL(Request_QueryString.ToString(), "OPERATION").ToUpper())
                {
                    case "PRINT":
                        Draw_Print(session, Filter, Response);
                        break;
                    case "EXCEL":
                        Draw_Excel(session, Filter, Response);
                        break;
                    default:
                        Draw_Layout(session, Filter, Response);
                        break;
                }


                mp_objGrid.SetCustomDrawer(null);


            }

            return Response.Out();

        }

        private string Draw_Layout(Session.ISession session, string Filter, IEprocResponse Response)
        {


            Dictionary<string, string> JS = new Dictionary<string, string>();
            int R = 0;

            if (GetParamURL(Request_QueryString, "FilteredOnly").ToLower() == "yes" && string.IsNullOrEmpty(mp_Filter))
            {

                Response.Write(@"<table width=""100%"" height=""100%"" >");
                Response.Write(@"<tr><td width=""100%"" height=""100%"" >");


                HTML.Basic.HTML_SinteticHelp(Response, Application.ApplicationCommon.CNV("E' necessario inserire un filtro per la visualizzazione dei dati"));


                Response.Write("</td></tr></table>");
                return Response.Out();
            }

            HTML.Basic.HTML_HiddenField(Response, "QueryString", mp_queryString);
            HTML.Basic.HTML_HiddenField(Response, "WHERE_SQL", mp_AllFiltro);

            if (mp_Rs != null)
            {

                //'-- disegna area di riepilogo di filtro
                mp_strcause = "disegna area riepilogo di filtro";

                Response.Write(@"<table width=""100%""   height=""100%"">");

                //'-- disegna la toolbar
                if (mp_objToolbar != null)
                {
                    Response.Write("<tr><td>" + Environment.NewLine);
                    mp_objToolbar.Html(Response);
                    Response.Write("</td></tr>" + Environment.NewLine);
                }

                if (!string.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString.ToString(), "NOTE")))
                {
                    Response.Write(@"<tr><td class=""NoteGrid"" >" + Environment.NewLine);
                    Response.Write(Application.ApplicationCommon.CNV(GetParamURL(Request_QueryString, "NOTE"), mp_ObjSession));
                    Response.Write("</td></tr>" + Environment.NewLine);
                }

                //'-- disegna la griglia
                mp_strcause = "disegna la griglia ";
                mp_objGrid.id = "Grid";


                Response.Write(@"<tr><td id=""Position"" width=""100%"" height=""100%"" >");
                mp_objGrid.Html_DrawDimensionInfo(Response);
                mp_objGrid.Html(Response);
                Response.Write("</td></tr>");

                Response.Write("</table>");

                //'-- inserisce le righe per lo scroll della griglia
                mp_objGrid.DrawLockedHtml(Response);


            }

            return Response.Out();
        }


        public string Draw_Print(Session.ISession session, string Filter, IEprocResponse Response)
        {

            //try
            //{
            int i = 0;
            int np = 0;
            Caption Caption = new Caption();

            //'----------------------------------
            //'-- avvia la scrittura della pagina
            //'----------------------------------

            //'-- imposto il titolo della pagina nel caso della stampa
            Response.Write(Title(Application.ApplicationCommon.CNV("Stampa", mp_ObjSession)));

            //'-- rimuovo dalla griglia le colonne superflue
            // todo On Error Resume Next



            Response.Write("</head><body>" + Environment.NewLine);



            Response.Write(@"<div style=""orientation: landscape;  size: landscape ""  >");

            //'-- disegna area di riepilogo
            //'-- titolo
            Caption.PrintMode = true;


            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "Caption")))
            {
                string vC = string.Empty;
                vC = Application.ApplicationCommon.CNV(GetParamURL(Request_QueryString, "Caption"), mp_ObjSession);
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "GROUPNAME"))) ;
                {
                    vC = vC + " - " + GetParamURL(Request_QueryString, "GROUPNAME");
                }
                Caption.Init(mp_ObjSession);
                Response.Write(Caption.SetCaption(vC));
            }


            Response.Write("<table  >");

            //'-- nel caso sia presente un filtro si indica
            if (!string.IsNullOrEmpty(mp_Filter))
            {
                Response.Write("<tr>");
                Response.Write(@"<td nowrap colspan=""3"" class=""VerticalModel_ObbligCaption"">");
                //'& CNV("E' presente un filtro di selezione", mp_ObjSession) & " & nbsp; "
                mp_objModel.Editable = false;
                mp_objModel.Html(Response);

                Response.Write("</td></tr>");
            }



            Response.Write("</table>");




            //'-- disegna la griglia
            mp_strcause = "disegna la griglia ";
            Response.Write(@"<table width=""100%"" style=""zoom : 1.00;"" >");


            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "NOTE")))
            {
                Response.Write(@"<tr><td class=""NoteGrid"" >" + Environment.NewLine);
                Response.Write(Application.ApplicationCommon.CNV(GetParamURL(Request_QueryString, "NOTE"), mp_ObjSession));
                Response.Write("</td></tr>" + Environment.NewLine);
            }

            Response.Write(@"<tr  ><td  width=""100%"" >");
            //'mp_objGrid.SetPage CLng(i), 50
            mp_objGrid.PrintMode = true;
            mp_objGrid.width = "100%";
            mp_objGrid.Html(Response);
            Response.Write("</td></tr>");




            Response.Write("</table>");
            Response.Write("</div>");

            return Response.Out();

            //'-- inserisco il salto pagina

            //}

            //catch
            //{
            //    //    RaiseError mp_strcause
            //    throw new Exception(mp_strcause + ", CubeGrid FUNZIONE: Draw_Print");
            //}


        }

        public string Draw_Excel(Session.ISession session, string Filter, IEprocResponse Response)
        {

            Response.Write("</head><body>" + Environment.NewLine);


            Response.Write(@"<table width=""100%"" >");


            //'-- rimuovo dalla griglia le colonne superflue

            //'-- disegna area di riepilogo
            mp_strcause = "disegna area riepilogo";


            //'-- titolo
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "Caption")))
            {
                string vC = string.Empty;
                vC = Application.ApplicationCommon.CNV(GetParamURL(Request_QueryString, "Caption"), mp_ObjSession);
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "GROUPNAME")))
                {
                    vC = vC + " - " + GetParamURL(Request_QueryString, "GROUPNAME");
                }

                Response.Write("<tr>");
                Response.Write(@"<td nowrap colspan=""16"" >");
                Response.Write(vC);
                Response.Write("</td></tr>");
            }


            Response.Write("<table  >");



            //'-- nel caso sia presente un filtro si indica
            if (!string.IsNullOrEmpty(mp_Filter))
            {
                Response.Write("<tr>");
                Response.Write(@"<td nowrap colspan=""16"" class=""VerticalModel_ObbligCaption"">");
                mp_objModel.Excel(Response);
                //'& CNV("E' presente un filtro di selezione", mp_ObjSession) & " & nbsp; "
                Response.Write("</td></tr>");
            }


            //'-- Valuta



            //'Response.Write "</table>"
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "NOTE")))
            {
                Response.Write("<tr><td>" + Environment.NewLine);
                Response.Write(Application.ApplicationCommon.CNV(GetParamURL(Request_QueryString, "NOTE"), mp_ObjSession));
                Response.Write("</td></tr>" + Environment.NewLine);
            }




            //'-- disegna la griglia
            mp_strcause = "disegna la griglia ";
            Response.Write(@"<tr  ><td  width=""100%"" >");



            mp_objGrid.Excel(Response);
            Response.Write("</td></tr>");


            Response.Write("<tr><td>&nbsp;</td></tr>");



            Response.Write("</table>");

            return Response.Out();



            //HError:

            //    RaiseError mp_strcause


            //End Function
        }

        private void InitLocal()
        {

            mp_ObjSession = _session;

            try
            {
                mp_Suffix = _session[SessionProperty.SESSION_SUFFIX];
                if (string.IsNullOrEmpty(mp_Suffix)) { mp_Suffix = "I"; };

                mp_strConnectionString = Application.ApplicationCommon.Application.ConnectionString;

                Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);



                mp_strcause = "InitLocal session - mp_User = session(SESSION_USER)";
                mp_User = _session[SessionProperty.IdPfu];
                mp_Permission = _session[SessionProperty.Funzionalita];



                mp_strcause = @"InitLocal session - mp_NumeroPagina = Request_QueryString(""nPag"")";
                mp_NumeroPagina = GetParamURL(Request_QueryString, "nPag");
                string strTestnumRowForPag = GetParamURL(Request_QueryString, "numRowForPag");
                if (!string.IsNullOrEmpty(strTestnumRowForPag))
                {
                    mp_Row_For_Page = Convert.ToInt32(strTestnumRowForPag);
                }
                if (mp_Row_For_Page <= 0) { mp_Row_For_Page = 20; }
                if (string.IsNullOrEmpty(mp_NumeroPagina)) { mp_NumeroPagina = "1"; }

                mp_queryString = Request_QueryString;


                //'-- tolgo dalla richiesta la modalita di chiamata per reintrodurla sul comando

                mp_Filter_Hide = GetParamURL(Request_QueryString, "FilterHide");
                mp_Filter = GetParamURL(Request_QueryString, "Filter");



                if (mp_queryString.StartsWith("&", StringComparison.Ordinal))
                {
                    mp_queryString = MidVb6(mp_queryString, 2);
                }

                //'-- recupera il comando
                mp_Command = GetParamURL(Request_QueryString, "COMMAND");
                mp_queryString = MyReplace(mp_queryString, "&COMMAND=" + mp_Command, "");
                mp_queryString = MyReplace(mp_queryString, "COMMAND=" + mp_Command, "");
                mp_queryString = MyReplace(mp_queryString, "COMMAND=", "");



                //'-- verifica se il primo carattere � un & e lo elimina
                //If left(mp_queryString, 1) = "&" Then mp_queryString = Mid(mp_queryString, 2)   ----- GIA' FATTO SOPRA!!!



                mp_strTable = GetParamURL(Request_QueryString, "Table");

                mp_ModGriglia = GetParamURL(Request_QueryString, "ModGriglia");
                if (string.IsNullOrEmpty(mp_ModGriglia)) { mp_ModGriglia = mp_strTable + "Griglia"; }

                mp_OWNER = GetParamURL(Request_QueryString, "OWNER");

                mp_StrToolbar = GetParamURL(Request_QueryString, "TOOLBAR");
                mp_ModuleBudget = GetParamURL(Request_QueryString, "MODULE");


                mp_strStoredSQL = "";
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "STORED_SQL")))
                {
                    mp_strStoredSQL = GetParamURL(Request_QueryString, "STORED_SQL");
                }


                mp_SORT_COL = GetParamURL(Request_QueryString, "SORT_COL");

                /*
                mp_timeout = 0;
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "TIMEOUT")))
                {
                    mp_timeout = CLng(GetParamURL(Request_QueryString, "TIMEOUT"));
                }*/

                mp_strcause = "InitLocal session - Fine";

            }
            catch
            {
                throw new Exception(mp_strcause + ", CUBEGRID, Funzione: InitLocal");
            }
        }

        private void InitGUIObject()
        {

            //Dim objDBFunction As Object
            LibDbModelExt objDB = new LibDbModelExt();
            TSRecordSet rs = new TSRecordSet();
            bool bAllColumn = default;
            bAllColumn = true;
            int j = 0;


            mp_objGrid = new GridMultiDimension();
            mp_grSP = new ScrollPage();

            TSRecordSet rsu = new TSRecordSet();

            mp_collDomains = new Dictionary<string, ClsDomain>();


            //'-- recupero il modello di ricerca
            mp_strcause = "recupero il modello di ricerca";

            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "ModelloFiltro")))
            {
                mp_objModel = mp_objDB.GetFilteredModel(GetParamURL(Request_QueryString, "ModelloFiltro"), mp_Suffix, 0, 0, mp_strConnectionString, true, mp_ObjSession);
            }
            else
            {
                mp_objModel = mp_objDB.GetFilteredModel(mp_strTable + "Filtro", mp_Suffix, 0, 0, mp_strConnectionString, true, mp_ObjSession);
            }
            //Set mp_objDB = Nothing



            if (GetParamURL(Request_QueryString, "OPERATION").ToUpper() == "EXCEL" || GetParamURL(Request_QueryString, "OPERATION").ToUpper() == "PRINT")
            {

                mp_Filter = GetParamURL(Request_QueryString, "Filter");
                dynamic v;
                int i = 0;
                string strFilter = string.Empty;
                dynamic p;



                //'-- verifica se � passato un filtro per default
                LoadFiltro();
            }
            else
            {
                //'-- se provengo dalla scela di una ricerca prelevo il criterio di ricerca
                if (GetParamURL(Request_QueryString, "MODE").ToLower() == "filtra")
                {

                    //'-- avvalora i campi del modello
                    mp_objModel.SetFieldsValue(Request_Form);


                    //'-- recupera la condizione di ricerca
                    //      '--mp_Filter = mp_objModel.GetSqlWhere()
                    if (mp_strStoredSQL != "yes")
                    {
                        mp_Filter = mp_objModel.GetSqlWhere();
                    }
                    else
                    {
                        mp_Filter = mp_objModel.GetSqlWhereList();
                    }

                    //'-- inserisco sulla query string il filtro creato sostituendolo al precedente

                    string tempQS = string.Empty;
                    tempQS = mp_queryString;

                    //mp_queryString = mp_queryString.Replace("&filter=" + GetParam(tempQS, "filter"), "");
                    //mp_queryString = mp_queryString.Replace("filter=" + GetParam(tempQS, "filter"), "");


                    //mp_queryString = mp_queryString.Replace("&Filter=" + GetParam(tempQS, "Filter"), "");
                    //mp_queryString = mp_queryString.Replace("Filter=" + GetParam(tempQS, "Filter"), "");


                    mp_queryString = MyReplace(mp_queryString, "&Filter=" + GetParam(tempQS, "Filter"), "");
                    mp_queryString = MyReplace(mp_queryString, "Filter=" + GetParam(tempQS, "Filter"), "");


                    //mp_queryString = mp_queryString + "&Filter=" +  URLEncode(mp_Filter);
                    mp_queryString = mp_queryString + "&Filter=" + URLEncode(mp_Filter);
                }
                else
                {

                    //'-- verifica se il filtro � passato
                    LoadFiltro();

                }

            }



            //'-- esegue l'elaborazione solamente se � presente un filtro di ricerca
            if (GetParamURL(Request_QueryString, "FilteredOnly").ToLower() == "yes" && string.IsNullOrEmpty(mp_Filter.Trim()))
            {
                return;
            }


            //'-- recuper l'evetuale toolbar associata
            if (!string.IsNullOrEmpty(mp_StrToolbar))
            {
                // Lib_dbFunctions mp_objDB = new Lib_dbFunctions();
                mp_objToolbar = Lib_dbFunctions.GetHtmlToolbar(mp_StrToolbar, mp_Permission, mp_Suffix, mp_strConnectionString, mp_ObjSession);

            }


            if (GetParamURL(Request_QueryString, "MODE").ToLower() == "property")
            {
                // mp_Property = Request_Form("Property")
                mp_Property = GetValueFromForm(_context.Request, "Property");
                mp_ObjSession["CUBE_Property"] = mp_Property;

            }
            else
            {
                //'-- recupera dalla sessione l'ordinamento delle colonne
                mp_Property = mp_ObjSession["CUBE_Property"];


                //'-- nel caso non sia specificata una modilit� utente si usa il default
                if (string.IsNullOrEmpty(mp_Property))
                {
                    mp_Property = GetParamURL(Request_QueryString, "Property");
                }


            }


            //'-- recupera i dati per la rappresentazione
            rs = InitGuiObject_GetRSCUBE();

            if (rs.RecordCount > 0)
            {

                dynamic[] mp_ArrValues; //= new int[0];


                //'-- cicla per determinare la presenza di totali
                for (j = 1; j <= mp_ColumnsProperty.Count(); j++)
                {
                    if (mp_ColumnsProperty.ElementAt(j - 1).Value.Total)
                    {
                        mp_objGrid.ShowTotalCol = true;
                    }
                }

                //'-- inizializzo la griglia
                mp_strcause = "InitGUIObject - inizializzo la griglia";


                //'-- inizializzazione della griglia multidimensionale


                mp_objGrid = new GridMultiDimension();

                mp_objGrid.ShowTotalCol = true;
                if (GetParamURL(Request_QueryString, "TEXT").ToLower() != "no")
                {
                    mp_objGrid.bDrawText = true;
                }

                mp_objGrid.CaptionTotalCol = Application.ApplicationCommon.CNV("totali di riga", mp_ObjSession);

                Dictionary<dynamic, dynamic> collDimensionProperty = new Dictionary<dynamic, dynamic>();


                mp_objGrid.InitGridValues(mp_collDomains, mp_Columns, mp_ColumnsProperty, collDimensionProperty);


                mp_ArrValues = mp_ObjSession["CUBE_Values" + mp_ModuleBudget];



                if (IsEmpty(mp_ArrValues))
                {
                    mp_objGrid.LoadGridValuesFromRS((TSRecordSet)rs.Clone());
                }
                else
                {
                    mp_objGrid.SetExternalValues(ref mp_ArrValues, mp_ObjSession["CUBE_ValuesTotal" + mp_ModuleBudget]);
                }


            }

            mp_Rs = rs;

            //'--------------------------------------------------------------
            //'-- inizializzo la paginazione della griglia
            //'--------------------------------------------------------------
            mp_strcause = "disegna la barra per sfogliare";

        }

        //'-- esegue i comandi richiesti alla tabella come add, del upd
        private void ExecuteAction()
        {

        }



        public TSRecordSet InitGuiObject_GetRSCUBE()
        {
            //Dim mp_objDB As Object
            TSRecordSet rs = new TSRecordSet();
            //Dim objDBUser As Object
            string strAttribFilter = string.Empty;
            string[] VetAttribFilter = new string[] { };
            string strKeyView = string.Empty;


            string strSql = string.Empty;


            //'GetFilterdAziForUser = ""
            LibDbModelExt mp_objDB = new LibDbModelExt();
            //'Set objDBUser = CreateObject("ctldb.lib_dbuser")


            //'Set GetRSDetailKey = Nothing


            bool bNonTutte = default;
            int n = 0;
            int i = 0;

            //Dim newCol As New Collection

            //Dim obj As Object
            string[] strVetAttrib = new string[] { };
            string[] strVetProp = new string[] { };
            string strSort = string.Empty;
            string strTableName = string.Empty;
            string strOR_Condition = string.Empty;
            Dictionary<string, Field> collDomains = new Dictionary<string, Field>();
            string strSqlCalc = string.Empty;
            string strCol = string.Empty;


            Field fld = new Field();


            Grid_ColumnsProperty pr = new Grid_ColumnsProperty();


            Dictionary<string, Field> tmpColumns = new Dictionary<string, Field>();
            Dictionary<string, Grid_ColumnsProperty> tmpColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

            //'-- carico il modello degli attributi per i dati
            mp_strcause = "recupero la collezione di colonne dei dati";
            mp_objDB.GetFilteredFields(mp_ModGriglia, ref tmpColumns, ref tmpColumnsProperty, mp_Suffix, 0, 0, mp_strConnectionString, mp_ObjSession, true);

            //Sganciamo il dizionario dei field e delle property dall'area di memoria cache ( sembra che facendo la REMOVE di questo dictionary andiamo a toccare anche la cache )
            mp_Columns = tmpColumns.ToDictionary(entry => entry.Key, entry => entry.Value);
            mp_ColumnsProperty = tmpColumnsProperty.ToDictionary(entry => entry.Key, entry => entry.Value);

            string strFilter = string.Empty;


            //'-- scorro il modello per comporre la visualizzazione
            n = mp_Columns.Count;
            string strName = string.Empty;
            for (i = 1; i <= n; i++)
            {


                //'On Error Resume Next 
                //Set pr = Nothing
                strName = mp_Columns.ElementAt(i - 1).Value.Name;
                mp_strcause = "recupero le property di " + strName;

                pr = mp_ColumnsProperty[strName];
                if (pr != null)
                {


                    if (string.IsNullOrEmpty(pr.Dimension))
                    {
                        bNonTutte = true;
                    }
                    else
                    {

                        if (pr.Dimension.ToLower() == "calc")
                        {
                            pr.Name = strName;
                            strCol = strCol + strName + ",";
                        }


                        else if (pr.Dimension.ToLower() == "info")
                        {


                            strSqlCalc = strSqlCalc + ", sum( " + strName + " ) as " + strName + " ";
                        }

                        else //'-- aggiunto alle dimensioni
                        {

                            strCol = strCol + strName + ",";
                            if (!string.IsNullOrEmpty(mp_SORT_COL))
                            {
                                strCol = strCol + strName + "_Sort ,";
                            }


                            string strPrSort = pr.Sort ? "desc" : "asc";

                            strSort = strSort + strName + " " + strPrSort + ",";

                            //'-- aggiunge la colonna alle dimensioni delle righe o colonne
                            mp_strcause = "aggiunge la colonna alle dimensioni delle righe o colonne";
                            fld = mp_Columns.ElementAt(i - 1).Value;

                            //'-- inserisco il dominio nella collezione delle dimensioni
                            collDomains.Add(fld.Name, fld);

                        }

                    }
                }
            }





            //'-- tolgo l'ultima virgola dal sort
            if (Right(strSort, 1) == ",") { strSort = Left(strSort, Len(strSort) - 1); }
            if (Right(strCol, 1) == ",") { strCol = Left(strCol, Len(strCol) - 1); }



            //'-- compone la query di estrazione
            strSql = "select " + strCol + strSqlCalc;


            //'-- aggiungo il filtro
            string strMpFilter = !string.IsNullOrEmpty(mp_Filter_Hide) ? " where " + mp_Filter_Hide : "";
            strSql = strSql + " from " + mp_strTable + strMpFilter;


            mp_AllFiltro = mp_Filter_Hide;
            if (!string.IsNullOrEmpty(mp_Filter))
            {
                if (!string.IsNullOrEmpty(mp_Filter_Hide))
                {
                    strSql = strSql + " and " + mp_Filter;
                    mp_AllFiltro = mp_AllFiltro + " and " + mp_Filter;
                }
                else
                {
                    strSql = strSql + " where " + mp_Filter;
                    mp_AllFiltro = mp_Filter;
                }
            }



            if (!string.IsNullOrEmpty(mp_OWNER))
            {
                if (strSql.Contains(" where ", StringComparison.Ordinal))
                {
                    strSql = strSql + " and " + mp_OWNER + " = '" + mp_User + "'";
                }
                else
                {
                    strSql = strSql + " where " + mp_OWNER + " = '" + mp_User + "'";
                }
            }


            //'-- compongo il raggruppamento
            strSql = strSql + " group by " + strCol;

            //'-- rimuovo dagli attributi quelli da mettere sulle dimensioni
            for (i = 1; i <= collDomains.Count; i++)
            {
                mp_Columns.Remove(collDomains.ElementAt(i - 1).Value.Name);
            }


            if (mp_strStoredSQL.ToLower() != "yes")
            {


                //'-- la esegue sul DB
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString); //, , mp_timeout);

            }
            else
            {
                strSql = "exec " + mp_strTable + " " + mp_User + " , '" + strCol + "' , '" + Replace(mp_Filter, "'", "''") + "' , '" + Replace(mp_Filter_Hide, "'", "''") + "'  ";
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString); //, , mp_timeout);



            }

            //'-- per ogni dimensione si genera un dominio con tutti i valori presenti
            InitGuiObject_LoadDomain((TSRecordSet)rs.Clone(), collDomains);

            return rs;
        }

        private void InitGuiObject_LoadDomain(TSRecordSet rs, Dictionary<string, Field> collDomains)
        {

            int n = 0;
            int i = 0;
            n = collDomains.Count;

            //'-- per ogni dimensione generiamo il dominio con soli i valori validi
            for (i = 1; i <= n; i++)
            {
                InitGUIObject_LoadDimensionX(rs, collDomains.ElementAt(i - 1).Value);
            }

        }

        //'-- carica la dimensione da utilizzare sulle colonne per la griglia di riepilogo
        private void InitGUIObject_LoadDimensionX(TSRecordSet rs, Field fld)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            //TSRecordSet rs;
            string strAttrib = string.Empty;
            string strSql = string.Empty;
            IDomElem? el;// = new DomElem();
            dynamic? LastValue;

            //rs = mp_rsDati;

            /*
            if (mp_rsDati.Columns.Contains(fld.Name + "_Sort"))
                mp_rsDati.Sort(fld.Name + "_Sort");
            else
                mp_rsDati.Sort(fld.Name);
            */

            if (rs.Columns.Contains(fld.Name + "_Sort"))
                rs.Sort(fld.Name + "_Sort");
            else
                rs.Sort(fld.Name);

            strAttrib = fld.Name;

            ClsDomain objDom = new ClsDomain();
            DomElem objElem = new DomElem();
            long i = 0;

            objDom.Id = strAttrib;
            objDom.Desc = fld.Caption;

            //'-- carica gli elementi del dominio
            if (rs.RecordCount > 0)
            {
                LastValue = null;
                if (fld.Domain == null)
                {
                    rs.MoveFirst();
                    i = 0;

                    while (!rs.EOF)
                    {

                        if (GetValueFromRS(rs.Fields[strAttrib]) != null)
                        {
                            if (CStr(rs.Fields[strAttrib]) != CStr(LastValue))
                            {
                                LastValue = rs.Fields[strAttrib];
                                objElem = new DomElem();
                                objElem.id = (string)rs.Fields[strAttrib];
                                objElem.Desc = objElem.id;
                                objElem.Sort = (int)i;

                                if (Left(objElem.Desc, 6) == "ZZZZZ#")
                                {
                                    objElem.Desc = Application.ApplicationCommon.CNV(MidVb6(objElem.Desc, 7), mp_ObjSession);
                                }
                                if (!objDom.Elem.ContainsKey(objElem.id))
                                {
                                    objDom.Elem.Add(CStr(objElem.id), objElem);
                                }

                                i = i + 1;
                            }
                        }
                        rs.MoveNext();
                    }
                }
                else
                {

                    rs.MoveFirst();
                    i = 0;
                    while (!rs.EOF)
                    {

                        if (GetValueFromRS(rs.Fields[strAttrib]) != null)
                        {

                            if (CStr(rs.Fields[strAttrib]) != CStr(LastValue))
                            {
                                LastValue = rs.Fields[strAttrib];
                                objElem = new DomElem();
                                objElem.id = (string)rs.Fields[strAttrib];

                                el = fld.Domain.FindCode(objElem.id);

                                //if(fld.Domain.FindCode(objElem.id) != null)
                                //if (fld.Domain != null)
                                //if (el == null)
                                if (el != null)
                                {
                                    IDomElem? tmpDomElem = fld.Domain.FindCode(objElem.id);

                                    if (tmpDomElem != null)
                                        objElem.Desc = tmpDomElem.Desc;
                                }
                                else
                                {
                                    objElem.Desc = Application.ApplicationCommon.CNV(objElem.id, mp_ObjSession);
                                }

                                objElem.Sort = (int)i;
                                if (!objDom.Elem.ContainsKey(objElem.id))
                                {
                                    objDom.Elem.Add(CStr(objElem.id), objElem);
                                }

                                //Set objElem = Nothing
                                i = i + 1;
                            }
                        }

                        rs.MoveNext();
                    }
                }
            }

            if (!mp_collDomains.ContainsKey(objDom.Id))
            {
                mp_collDomains.Add(objDom.Id, objDom);
            }

        }


        private void LoadFiltro()
        {
            string[] v = new string[2];
            int i = 0;
            dynamic p;
            dynamic ValueField;
            string NameField = string.Empty;


            string strFilter = string.Empty;


            //'-- verifica se � passato un filtro per default
            if (!string.IsNullOrEmpty(mp_Filter))
            {

                if (mp_strStoredSQL.ToLower() != "yes")
                {

                    v = mp_Filter.Split("and");


                    for (i = 0; i < v.GetUpperBound(0); i++)
                    {


                        strFilter = v[i];
                        //'strFilter = Trim(strFilter)
                        //''p = Split(strFilter, "=")


                        //'p(1) = Replace(Trim(p(1)), "'", "")


                        //'-- inserisce il valore sull'attributo
                        //'mp_objModel.Fields(Trim(p(0))).Value = p(1)


                        ValueField = GetValue_FromAttrib_Filter(strFilter, ref NameField);


                        mp_objModel.Fields[NameField].Value = ValueField;


                    }
                }
                else
                {
                    string[] vAtt = new string[0];
                    string[] vVal = new string[0];
                    string[] vCond = new string[0];
                    v = mp_Filter.Split("#~#");
                    vAtt = v[0].Split("#@#");
                    vVal = v[1].Split("#@#");
                    vCond = v[2].Split("#@#");
                    for (i = 0; i < vAtt.GetUpperBound(0); i++)
                    {
                        p = vVal[i].Trim().Replace(@"'", @"");
                        //'-- inserisce il valore sull'attributo
                        mp_objModel.Fields[vAtt[i]].Value = p;
                    }
                }

            }

        }

        public bool checkHackSecurity(HttpContext httpContext, Session.ISession session)
        {
            BlackList mp_objDB = new BlackList();
            Dictionary<string, string> attackerInfo = new Dictionary<string, string>();

            bool result = false;


            //Set mp_objDB = CreateObject("ctldb.BlackList")

            if (!mp_objDB.isDevMode(session) && !DashBoard.Basic.isValid(CStr(mp_strTable), 1))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                result = true;
                return result;

            }

            if (!mp_objDB.isDevMode(session) && mp_objDB.isOwnerObblig(CStr(mp_strTable)) && string.IsNullOrEmpty(CStr(mp_OWNER)))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_OWNER), session, mp_strConnectionString);
                result = true;
                return result;

            }

            if (!mp_objDB.isDevMode(session) && !DashBoard.Basic.isValidaSqlFilter(CStr(mp_Filter_Hide), mp_strConnectionString))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), session, mp_strConnectionString);
                result = true;
                return result;

            }



            //' Controllo se l'utente � autorizzato ad accedere allo specifico oggetto sql(tabella, vista)
            if (!mp_objDB.isDevMode(session) && !DashBoard.Basic.checkPermission(mp_strTable, session, mp_strConnectionString))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_CONTROLLO_PERMESSI, "##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
                result = true;
                return result;

            }

            //Set mp_objDB = Nothing

            return result;

        }
    }
}
