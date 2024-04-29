using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.DashBoard
{
    public class ViewerCalendar
    {
        private eProcurementNext.Session.ISession mp_ObjSession; //'-- oggetto che contiene il vettore base con gli elementi della libreria
        private string mp_Suffix = string.Empty;
        private long mp_User = default;
        private string mp_Permission = string.Empty;
        private string mp_strConnectionString = string.Empty;

        private Dictionary<string, Field> mp_Columns;
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty;
        private string mp_Filter = string.Empty;
        private string mp_FilterHide = string.Empty;
        private string mp_Sort = string.Empty;
        private string mp_SortOrder = string.Empty;
        private string mp_StrToolbar = string.Empty;

        private string Request_QueryString;
        private IFormCollection Request_Form;
        private string mp_strTable = string.Empty; //'-- nome della tabella di riferimento per la funzione
        private string mp_queryString = string.Empty;
        private string mp_IDENTITY = string.Empty;

        private string mp_strPathJSToolBar = string.Empty;
        private string mp_OWNER = string.Empty;
        private string mp_Top = string.Empty;
        private string mp_StrDocumentType = string.Empty;
        private string mp_RSConnectionString = string.Empty; //'-- se è presente una particolare connection string per la query
        private string mp_JS = string.Empty;
        private string mp_ModGriglia = string.Empty;
        private long mp_timeout = default;
        private string mp_Calendar = string.Empty;
        private string mp_FieldStyle = string.Empty;
        private string mp_ModFiltroAdd = string.Empty;
        private string mp_ModFiltroUpd = string.Empty;

        private Calendar mp_objCalendar;

        private int mp_MESI_CALENDAR = 0;
        private string mp_strStoredSQL = string.Empty;

        private string mp_ModFiltro = string.Empty;
        private string mp_idViewer = string.Empty;

        private string mp_DATA_CALENDAR = string.Empty;

        public IConfiguration configuration;

        private HttpContext _context;
        private eProcurementNext.Session.ISession _session;
        private IEprocResponse response;

        private CommonDbFunctions cdf;
        public ViewerCalendar(IConfiguration configuration, HttpContext context, eProcurementNext.Session.ISession session, EprocResponse _response)
        {
            this.configuration = configuration;
            this._session = session;
            this._context = context;
            this.response = _response;
            cdf = new CommonDbFunctions();
        }

        public string run(EprocResponse response)
        {
            // -- recupero variabili di sessione


            InitLocal();

            // -- controlli di sicurezza
            if (checkHackSecurity(_session, response))
            {
                //'Se è presente NOMEAPPLICAZIONE nell'application
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
            //'ExecuteAction

            //'-- disegna la lista dei ricambi

            return Draw();
        }

        private void InitLocal()
        {
            mp_ObjSession = _session;
            int PosSuperUser = 0;
            mp_Suffix = _session[SessionProperty.SESSION_SUFFIX];
            if (String.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
            if (_context.Request.HasFormContentType)
            {
                Request_Form = _context.Request.Form;
            }

            //  mp_User = Convert.ToInt64(SessionProperty.SESSION_USER); // this._session["SESSION_USER"];
            //dynamic test = _session[EprocNext.Session.SessionProperty.SESSION_USER];
            mp_User = CLng(_session[eProcurementNext.Session.SessionProperty.SESSION_USER]);
            mp_Permission = CStr(_session[SessionProperty.Funzionalita]);

            mp_IDENTITY = GetParamURL(Request_QueryString, "IDENTITY");

            if (String.IsNullOrEmpty(mp_IDENTITY))
            {
                mp_IDENTITY = "id";
            }

            //mp_NumeroPagina = GetParamURL(Request_QueryString, "nPag");

            if (GetParamURL(Request_QueryString, "URLDECODE").ToLower() == "yes")
            {
                mp_Filter = GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = GetParamURL(Request_QueryString, "FilterHide");
            }
            else
            {
                mp_Filter = GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = GetParamURL(Request_QueryString, "FilterHide");
            }

            mp_OWNER = GetParamURL(Request_QueryString, "OWNER");



            if (String.IsNullOrEmpty(GetParamURL(Request_QueryString, "ConnectionString")))
            {
                mp_RSConnectionString = GetParamURL(Request_QueryString, "ConnectionString");
            }

            if (String.IsNullOrEmpty(mp_RSConnectionString))
            {
                mp_RSConnectionString = mp_strConnectionString;
            }

            mp_DATA_CALENDAR = GetParamURL(Request_QueryString, "DATA_CALENDAR");
            if (String.IsNullOrEmpty(mp_DATA_CALENDAR))
            {
                mp_DATA_CALENDAR = DateTime.Now.ToString("yyyy-MM");
            }

            mp_strTable = GetParamURL(Request_QueryString, "Table");

            //'-- tolgo dalla query string elementi da usare sulla singola chiamata
            string tempQS = String.Empty;
            tempQS = CStr(Request_QueryString);
            tempQS = tempQS.Replace("&MODE=" + GetParamURL(Request_QueryString, "MODE"), "");
            tempQS = tempQS.Replace("MODE=" + GetParamURL(Request_QueryString, "MODE"), "");
            tempQS = tempQS.Replace("&IDROW=" + GetParamURL(Request_QueryString, "IDROW"), "");
            tempQS = tempQS.Replace("IDROW=" + GetParamURL(Request_QueryString, "IDROW"), "");
            mp_queryString = tempQS;

            //'-- aggiusto il filtro presente sulla querystring
            mp_queryString = mp_queryString.Replace("&Filter=" + GetParam(tempQS, "Filter"), "");
            mp_queryString = mp_queryString.Replace("Filter=" + GetParam(tempQS, "Filter"), "");
            mp_queryString = mp_queryString + "&Filter=" + URLEncode(mp_Filter);


            //'-- aggiusto il filtro nascosto
            mp_queryString = mp_queryString.Replace("&FilterHide=" + GetParam(tempQS, "FilterHide"), "");
            mp_queryString = mp_queryString.Replace("&FilterHide=" + GetParam(tempQS, "FilterHide"), "");
            mp_queryString = mp_queryString + "&FilterHide=" + URLEncode(mp_FilterHide);


            mp_queryString = mp_queryString.Replace("&DATA_CALENDAR=" + GetParam(tempQS, "DATA_CALENDAR"), "");

            if (CommonModule.Basic.Left(mp_queryString, 1) == "&")
            {
                mp_queryString = MidVb6(mp_queryString, 2);
            }

            mp_ModFiltroAdd = GetParamURL(Request_QueryString, "ModExecAdd");
            if (String.IsNullOrEmpty(mp_ModFiltroAdd))
            { mp_ModFiltroAdd = mp_strTable + "_ADD_ROW"; }
            mp_ModFiltroUpd = GetParamURL(Request_QueryString, "ModExecUpd");
            if (String.IsNullOrEmpty(mp_ModFiltroUpd))
            {
                mp_ModFiltroUpd = mp_strTable + "_UPD_ROW";
            }
            mp_ModGriglia = GetParamURL(Request_QueryString, "ModGriglia");
            if (String.IsNullOrEmpty(mp_ModGriglia))
            {
                mp_ModGriglia = mp_strTable + "Griglia";
            }

            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "ModelloFiltro")))
            {
                mp_ModFiltro = GetParamURL(Request_QueryString, "ModelloFiltro");
            }
            else
            {
                mp_ModFiltro = mp_strTable + "Filtro";
            }


            mp_idViewer = mp_ModGriglia + "_" + mp_ModFiltro + "_" + mp_strTable + "_" + mp_OWNER + "_" + mp_StrToolbar + "_CALENDAR";

            mp_timeout = 0;
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "TIMEOUT")))
            {
                mp_timeout = CLng(GetParamURL(Request_QueryString, "TIMEOUT"));
            }


            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "CALENDAR")))
            {
                mp_Calendar = GetParamURL(Request_QueryString, "CALENDAR");
            }


            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "FIELDSTYLE")))
            {
                mp_FieldStyle = GetParamURL(Request_QueryString, "FIELDSTYLE");
            }


            mp_MESI_CALENDAR = 1;

            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "MESI_CALENDAR")))
            {
                //On Error Resume Next
                mp_MESI_CALENDAR = CInt(GetParamURL(Request_QueryString, "MESI_CALENDAR"));
            }


            mp_strStoredSQL = "";
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "STORED_SQL")))
            {
                mp_strStoredSQL = GetParamURL(Request_QueryString, "STORED_SQL");
            }

        }

        public string? Draw()
        {
            Dictionary<string, string> JS = new Dictionary<string, string>();
            Window win = new Window();

            InitGUIObject();

            //'----------------------------------
            //'-- avvia la scrittura della pagina
            //'----------------------------------

            //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
            //mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";


            //'-- aggiungo i Js necessari al funzionamento della pagina
            if (!String.IsNullOrEmpty(mp_JS))
            {
                JS.Add(mp_JS, @"<script src=""" + mp_strPathJSToolBar + "jsapp/" + mp_JS + @".js"" ></script>");
            }

            //'-- carico i JS associati ai documenti
            if (!String.IsNullOrEmpty(mp_StrDocumentType))
            {
                JS.Add("document", @"<script src=""../CTL_Library/jscript/document/document.js"" ></script>");
            }

            if (mp_objCalendar != null) { mp_objCalendar.JScript(JS); }

            //'--aggiungo i javascript del blocchetto property
            string tempQS = string.Empty;
            tempQS = CStr(Request_QueryString);
            if (Left(tempQS, 1) == "&") { tempQS = Strings.Mid(tempQS, 2); }

            //'-- inserisce i java script necessari
            //mp_strcause = "inserisce i java script necessari";
            if (GetParamURL(Request_QueryString, "JSIN").ToLower() == "yes")
            {
                JavaScriptInPage(mp_ObjSession, "dashboard", response, JS);
            }
            else
            {
                response.Write(JavaScript(JS));
            }

            if (GetParamURL(Request_QueryString, "FilteredOnly").ToLower() == "yes" && String.IsNullOrEmpty(mp_Filter.Trim()))
            {
                response.Write(@"<table width=""100%"" height=""100%"" >");
                response.Write(@"<tr><td width=""100%"" height=""100%"" >");


                HTML_SinteticHelp(response, Application.ApplicationCommon.CNV("E' necessario inserire un parametro di ricerca nei campi di filtro", mp_ObjSession));


                response.Write(@"</td></tr></table>");
            }
            else
            {
                int startAnno = Convert.ToInt32(Left(mp_DATA_CALENDAR, 4));
                int startMese = Convert.ToInt32(MidVb6(mp_DATA_CALENDAR, 6, 2));
                DateTime dataStart = new DateTime(startAnno, startMese, 1);

                response.Write(@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);
                response.Write(@"function ShowData( strData ) " + Environment.NewLine);

                response.Write(@"{window.location = 'Viewer.asp?" + mp_queryString.Replace("'", "\'") + "&DATA_CALENDAR=' + strData ; }");
                response.Write("</script>" + Environment.NewLine);
                response.Write(@"<table width=""100%"" height=""100%"" >");

                string ScrollPage = "ScrollPage";
				if (IsMasterPageNew())
				{
					ScrollPage = "ScrollPageFaseII";
				}

				response.Write(@"<tr><td height=""100%"" valign=""middle"" onclick=""document.location= 'ViewerCalendar.asp?" + mp_queryString.Replace("'", "\'") + "&DATA_CALENDAR=" + dataStart.AddYears(-1).ToString("yyyy-MM") + $@"';"" ><img border=""0"" src=""../CTL_Library/images/{ScrollPage}/AllRewind.gif"" ></td>");
                response.Write(@"<td height=""100%"" valign=""middle"" onclick=""document.location= 'ViewerCalendar.asp?" + mp_queryString.Replace("'", "\'") + "&DATA_CALENDAR=" + dataStart.AddMonths(-1).ToString("yyyy-MM") + $@"';"" ><img border=""0"" src=""../CTL_Library/images/{ScrollPage}/Rewind.gif"" ></td>");

                //  '-- disegna la griglia
                //mp_strcause = "disegna i calendari";
                response.Write(@"<td width=""25%"" height=""100%"" valign=""top"">");

                //'mp_objCalendar.SetLockedInfo 2
                mp_objCalendar.Html(response);


                response.Write(@"</td><td width=""25%"" height=""100%"" valign=""top"">");


                mp_DATA_CALENDAR = AddMese(mp_DATA_CALENDAR);
                mp_objCalendar.AnnoMese = mp_DATA_CALENDAR;
                mp_objCalendar.Html(response);

                response.Write(@"</td><td width=""25%"" height=""100%"" valign=""top"">");


                mp_DATA_CALENDAR = AddMese(mp_DATA_CALENDAR);
                mp_objCalendar.AnnoMese = mp_DATA_CALENDAR;
                mp_objCalendar.Html(response);

                response.Write(@"</td><td width=""25%"" height=""100%"" valign=""top"">");


                mp_DATA_CALENDAR = AddMese(mp_DATA_CALENDAR);
                mp_objCalendar.AnnoMese = mp_DATA_CALENDAR;
                mp_objCalendar.Html(response);

                response.Write(@"</td><td height=""100%"" valign=""middle"" onclick=""document.location= 'ViewerCalendar.asp?" + mp_queryString.Replace("'", "\'") + "&DATA_CALENDAR=" + dataStart.AddMonths(1).ToString("yyyy-MM") + $@"';"" ><img border=""0"" src=""../CTL_Library/images/{ScrollPage}/Forward.gif"" ></td>");
                response.Write(@"<td height=""100%"" valign=""middle"" onclick=""document.location= 'ViewerCalendar.asp?" + mp_queryString.Replace("'", "\'") + "&DATA_CALENDAR=" + dataStart.AddYears(1).ToString("yyyy-MM") + $@"';"" ><img border=""0"" src=""../CTL_Library/images/{ScrollPage}/AllForward.gif"" ></td>");

                response.Write("</tr>");
                response.Write("</table>");

            }

            return response.Out();
        }



        public bool checkHackSecurity(Session.ISession session, IEprocResponse response)
        {
            BlackList mp_objDB = new BlackList();

            bool result = false;  // valore che la funzione restituisce
            if (!mp_objDB.isDevMode())
            {
                // table
                if (!Basic.isValid(mp_strTable, 1))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                if (!Basic.isValid(GetParamURL(Request_QueryString, "CAL_FESTIVITY"), 1))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_SQLINJECTION.Replace("##nome-parametro##", "CAL_FESTIVITY")), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // mancanza del parametro owner se però era richiesto
                if (mp_objDB.isOwnerObblig(mp_strTable) && String.IsNullOrEmpty(mp_OWNER))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_OWNER), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // owner
                if (!Basic.isValid(mp_OWNER, 1))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_OWNER), session, mp_strConnectionString);
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
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_SORT), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // sort order

                if (!String.IsNullOrEmpty(mp_SortOrder))
                {
                    if (mp_SortOrder.ToUpper() != "ASC" && mp_SortOrder.ToUpper() != "DESC")
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_SORT_ORDER), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }



                // filterhide
                if (!Basic.isValidaSqlFilter(GetParamURL(Request_QueryString, mp_FilterHide), mp_strConnectionString))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_FILTERHIDE), session, mp_strConnectionString);
                    result = true;
                    return result;
                }

                // filter 
                if (!Basic.isValidaSqlFilter(mp_Filter, mp_strConnectionString))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_FILTER), session, mp_strConnectionString);
                    result = true;
                    return result;
                }


                // identity
                if (!String.IsNullOrEmpty(mp_IDENTITY))
                {
                    if (!Basic.isValid(mp_IDENTITY, 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_IDENTITY), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                // TOOLBAR
                if (!String.IsNullOrEmpty(mp_StrToolbar))
                {
                    if (!Basic.isValid(mp_StrToolbar, 0, @"[\d,_a-zA-Z]{2,100}"))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_TOOLBAR), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                // ModGriglia
                if (!String.IsNullOrEmpty(mp_ModGriglia))
                {
                    if (!Basic.isValid(mp_ModGriglia, 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_MODGRIGLIA), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                //POSITIONALMODELGRID
                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "POSITIONALMODELGRID")))
                {
                    if (!Basic.isValid(GetParamURL(Request_QueryString, "POSITIONALMODELGRID"), 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_POSITIONALMODELGRID), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }

                // 'mp_ModFiltroAdd
                if (!string.IsNullOrEmpty(mp_ModFiltroAdd))
                {
                    if (!Basic.isValid(mp_ModFiltroAdd, 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_MODFILTROADD), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }


                // mp_ModFiltroUpd
                if (!string.IsNullOrEmpty(mp_ModFiltroUpd))
                {
                    if (!Basic.isValid(mp_ModFiltroUpd, 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_MODFILTROUPD), session, mp_strConnectionString);
                        result = true;
                        return result;

                    }
                }

                // Controllo se l'utente è autorizzato ad accedere allo specifico oggetto sql (tabella, vista)
                if (!Basic.checkPermission(mp_strTable, _session, mp_strConnectionString))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(_context, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_MODFILTRO.Replace("##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
                    result = true;
                    return result;

                }
            }
            return result;
        }

        private void InitGUIObject()
        {

            dynamic objDBFunction;
            dynamic objDB;
            TSRecordSet rs = new TSRecordSet();
            dynamic v;
            int i;

            mp_objCalendar = new Calendar();

            //'-- se provengo dalla scelta di una ricerca prelevo il criterio di ricerca

            if (GetParamURL(Request_QueryString, "MODE") == "Filtra")
            {
                Model objModel = new Model();

                //mp_strcause = "recupero il modello di ricerca";
                LibDbModelExt mp_objDB = new LibDbModelExt();


                objModel = mp_objDB.GetFilteredModel(mp_ModFiltro, mp_Suffix, 0, 0, mp_strConnectionString, true, mp_ObjSession);

                //'-- avvalora i campi del modello
                objModel.SetFieldsValue(Request_Form);

                //'-- recupera la condizione di ricerca
                if (mp_strStoredSQL.ToLower() != "yes")
                {
                    mp_Filter = objModel.GetSqlWhere();
                }
                else
                {
                    mp_Filter = objModel.GetSqlWhereList();
                }

                string tempQS = String.Empty;
                tempQS = mp_queryString;
                mp_queryString = mp_queryString.Replace("&Filter=" + GetParam(tempQS, "Filter"), "");
                mp_queryString = mp_queryString.Replace("Filter=" + GetParam(tempQS, "Filter"), "");


                mp_queryString = mp_queryString + "&Filter=" + URLEncode(mp_Filter);

                //'-- conservo in sessione il filtro
                //mp_ObjSession(OBJSESSION)(mp_idViewer) = mp_Filter
                Application.ApplicationCommon.Application[mp_idViewer] = mp_Filter;
            }

            //'-- nel caso il filtro sia vuoto cerco di recuperarlo dalla sessione di lavoro
            if (String.IsNullOrEmpty(mp_Filter) && GetParamURL(Request_QueryString, "FilterRecovery").ToLower() != "no")
            {
                mp_Filter = ApplicationCommon.Application[mp_idViewer];
            }

            //'-- esegue l'elaborazione solamente se è presente un filtro di ricerca
            if (GetParamURL(Request_QueryString, "FilteredOnly").ToLower() == "yes" && (!String.IsNullOrEmpty(mp_Filter.Trim())))
            {
                return;
            }

            //'--imposto il sort multiplo se c'è la property
            string strSort = String.Empty;

            mp_Top = "";

            DateTime dSt;
            DateTime dEn;
            Fld_Date fldD = new Fld_Date();
            dSt = DateAndTime.DateSerial(DateAndTime.Year(DateAndTime.Now), DateAndTime.Month(DateAndTime.Now), 1);
            if (!String.IsNullOrEmpty(mp_DATA_CALENDAR))
            {
                dSt = DateAndTime.DateSerial(CInt(Strings.Left(mp_DATA_CALENDAR, 4)), CInt(Strings.Mid(mp_DATA_CALENDAR, 6, 2)), 1);
            }

            dEn = DateAndTime.DateAdd("m", 1, dSt);


            //'-- aggiunge la filtro una restrizione sulle date in funzione dei mesi da visualizzare
            mp_MESI_CALENDAR = 2;

            if (mp_MESI_CALENDAR != 1)
            {
                dEn = DateAndTime.DateAdd("m", mp_MESI_CALENDAR, dEn);
                dSt = DateAndTime.DateAdd("m", -mp_MESI_CALENDAR + 2, dSt);
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

            string Solo_Colonne_Usate;

            Solo_Colonne_Usate = ApplicationCommon.Application["Viewer_Solo_Colonne_Usate"];

            //    '-- recupero il recordset del Viewer dal database
            //mp_strcause = "recupero il recordset del Viewer dal database";
            long numRec = 0;
            rs = DashBoardMod.GetRSGridCount(mp_OWNER, CLng(mp_User), mp_strTable, mp_Filter, mp_FilterHide, mp_RSConnectionString, ref numRec, mp_Top, strSort, mp_timeout, mp_strStoredSQL, Solo_Colonne_Usate);

            //'-- recupero la collezione di colonne da visualizzare
            //mp_strcause = "recupero la collezione di colonne da visualizzare";
            //'Set mp_objDB = CreateObject("ctldb.lib_dbModelext")
            //'mp_objDB.GetFilteredFields mp_ModGriglia, mp_Columns, mp_ColumnsProperty, mp_Suffix, 0, 0, mp_strConnectionString, mp_ObjSession, True
            //'Set mp_objDB = Nothing

            mp_Columns = new Dictionary<string, Field>();
            mp_ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

            mp_objCalendar.AnnoMese = mp_DATA_CALENDAR;

            mp_objCalendar.Columns = mp_Columns;
            mp_objCalendar.ColumnsProperty = mp_ColumnsProperty;
            mp_objCalendar.RecordSet(rs, mp_IDENTITY, false);
            mp_objCalendar.FieldData = mp_Calendar;
            mp_objCalendar.id = "GridViewer";
            mp_objCalendar.width = "100%";
            mp_objCalendar.ActiveSelection = Convert.ToInt32(GetParamURL(Request_QueryString, "ACTIVESEL"));
            mp_objCalendar.MesiShow = 1; // mp_MESI_CALENDAR;
            mp_objCalendar.ShowSintetic = true;
            mp_objCalendar.Style = "CalSintetic";
            mp_objCalendar.OnClickDay = "ShowData";
            //'-- se è indicato la vista per le festività carica il RS

            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "CAL_FESTIVITY")))
            {
                mp_objCalendar.RsFestivity(cdf.GetRSReadFromQuery_("select * from " + GetParamURL(Request_QueryString, "CAL_FESTIVITY"), mp_strConnectionString));
            }
        }

        private string AddMese(string strData)
        {
            int a = 0;
            int m = 0;
            DateTime d = new DateTime();
            int _Anno = Convert.ToInt32(Left(strData, 4));
            int _mese = Convert.ToInt32(MidVb6(strData, 6, 2));



            d = new DateTime(_Anno, _mese, 1).AddMonths(1);
            return d.ToString("yyyy-MM");
        }
    }
}
