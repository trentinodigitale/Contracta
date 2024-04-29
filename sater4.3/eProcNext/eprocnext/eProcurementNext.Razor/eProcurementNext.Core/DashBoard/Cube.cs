using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.DashBoard.Basic;

namespace eProcurementNext.DashBoard
{

    public class Cube
    {
        private string mp_Suffix = string.Empty;
        private long mp_User = 0;
        private string mp_Permission = string.Empty;
        private string mp_strConnectionString = string.Empty;

        private string mp_AreaAdd = string.Empty;
        private string mp_Caption = string.Empty;
        private string mp_Periodo = string.Empty;
        private Caption mp_objCaption = new Caption();
        private Toolbar mp_objToolbar = new Toolbar();


        private string mp_strcause = string.Empty;
        private string mp_Table = string.Empty;
        private string[] mp_vetHeight = new string[] { };

        private string mp_AreaUpd = string.Empty; //'nome della pagina da utilizzare nella parte inferiore

        private string mp_CUBEMode = string.Empty; //'-- conitene la modalita della funzione, fra definizione,esercizio e storico
                                                   //'-- valori: def , esercizio , storico .
                                                   //'-- nel caso di storico deve essere passato il periodo per cui si vuole operare


        private string mp_Toolbar = string.Empty; //'-- contiene il nome della toolbar da caricare
        private int mp_PosPerAdd = 0; //' -- contiene la posizione del permesso per l'area di add
        private string mp_queryString = string.Empty;


        private string Request_QueryString = string.Empty;

        private string mp_ModuleCUBE = string.Empty; //'-- modulo di CUBE
        private dynamic mp_ObjSession; //'-- oggetto che contiene il vettore base con gli elementi della libreria

        private string mp_AreaFiltro = string.Empty;
        private string mp_AreaFiltroWin = string.Empty;

        private IHttpContextAccessor _accessor;
        private HttpContext _context;
        private eProcurementNext.Session.ISession _session;
        private IEprocResponse _response;
        public IConfiguration configuration;
        private CommonDbFunctions cdf = new CommonDbFunctions();

        public Cube(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this._context = httpContext;
            this._session = session;
            this._response = response;
        }

        public void run()
        {

            //TODO
            //On Error GoTo HError

            //'-- recupero variabili di sessione
            Window win = new Window();

            InitLocal();

            //'-- Controlli di sicurezza
            if (checkHackSecurity(_context, _session))
            {
                {
                    //'Se � presente NOMEAPPLICAZIONE nell'application
                    if (!string.IsNullOrEmpty(CStr(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
                    {

                        _context.Response.Redirect("/" + Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp");
                        return;
                    }
                    else
                    {
                        _context.Response.Redirect("/application/blocked.asp");
                        return;
                    }
                }
            }

            InitGUIObject();


            //Set mp_objCaption = New CtlHtml.Caption

            //        if UCase(session(OBJAPPLICATION)("ACCESSIBLE")) <> "YES" {

            //            Dim Ext As New CtlHtml.ActiveExtendedAttrib
            //            Dim JS As New Collection


            //    '-- recupera i javascript necessari dagli oggetti dell'interfaccia
            //    mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia"
            //            win.JScript JS
            //            Ext.JScript JS
            //            JS.Add "<script src=""../ctl_library/jscript/toolbar/toolbar.js"" ></script>", "toolbar"

            //    '-- inserisce i java script necessari
            //            mp_strcause = "inserisce i java script necessari"
            //            Response.Write JavaScript(JS)

            //    '-- cambio il titolo del folder
            //            mp_strcause = "Inserisco il titolo"


            //    '--imposto il titolo della pagina
            //            Response.Write Title(CNV("CUBE", session))

            //    Response.Write "</head><body  >" & vbCrLf

            //    mp_strcause = "inserisco i controlli estesi"
            //            Ext.Html Response


            //}


            //'-- inserisco il form per l'esportazione excel
            mp_strcause = "inserico il form";
            Form form = new Form();
            form.Target = "CUBE_Excel";
            form.Action = "excel.asp";
            form.id = "CUBE_Excel";
            _response.Write(form.OpenForm());
            _response.Write(form.CloseForm());

            HTML.Basic.HTML_HiddenField((EprocResponse)_response, "OPTION", GetParamURL(Request_QueryString, "OPTION"));
            HTML.Basic.HTML_HiddenField((EprocResponse)_response, "FILTERHIDE", GetParamURL(Request_QueryString, "FilterHide"));


            //if UCase(session(OBJAPPLICATION)("ACCESSIBLE")) <> "YES" {
            //    Response.Write "<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"">"
            //} else {

            _response.Write(@"<table class=""height_100_percent width_100_percent""  border=""0"" cellspacing=""0"" cellpadding=""0"">");

            if (!string.IsNullOrEmpty(mp_Caption))
            {

                _response.Write("<tr><td>");
                if (GetParamURL(Request_QueryString, "ShowExit") == "0")
                {
                    mp_objCaption.ShowExit = false;
                }

                mp_objCaption.Init(mp_ObjSession);
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "CaptionNoML")))
                {
                    _response.Write(mp_objCaption.SetCaption(Trim(mp_Caption)));
                }
                else
                {
                    _response.Write(mp_objCaption.SetCaption(Application.ApplicationCommon.CNV(Trim(mp_Caption), mp_ObjSession)));
                }
                _response.Write("</td></tr>");
            }
            //}
            if (mp_AreaFiltro.ToLower() != "no")
            {
                {

                    CubeFilter objCubeFilter = new CubeFilter(_context, _session, _response);


                    //'--se richiesto disegno l'area di filtro in una win apri e chiudi
                    if (mp_AreaFiltroWin == "1" || mp_AreaFiltroWin.ToLower() == "open" || mp_AreaFiltroWin.ToLower() == "close")
                    {

                        // win.JScript(JS);
                        bool filOpen = false;
                        filOpen = mp_AreaFiltroWin.ToLower() == "open" ? true : false;



                        if (Application.ApplicationCommon.Application["ShowImages"] != "0")
                        {
                            win.Init("WinFilter", Application.ApplicationCommon.CNV("Filtra", mp_ObjSession), filOpen, Window.Group);
                        }
                        else
                        {
                            win.Init("WinFilter", Application.ApplicationCommon.CNV("Filtra", mp_ObjSession), filOpen, Window.NOIMAGES);
                        }


                        //'win.Zindex = 0
                        win.PositionAbsolute = false;
                        win.Height = mp_vetHeight[0];

                        //if UCase(session(OBJAPPLICATION)("ACCESSIBLE")) <> "YES" {
                        //    Response.Write "<tr><td width=""100%"">"
                        //    win.Html Response, HTML_iframe("CubeFilter", "CubeFilter.asp?" & Request_QueryString)
                        //} else {

                        _response.Write(@"<tr><td class=""width_100_percent"">");
                        _response.Write(@"<div id=""Div_CubeFilter"" class=""width_100_percent"">");



                        objCubeFilter.run(_response);


                        //  Set objCubeFilter = Nothing



                        _response.Write("</div>");


                        //}

                        _response.Write("</td></tr>");
                    }
                    else
                    {

                        //    if(Application.ApplicationCommon.Application["ACCESSIBLE"]) <> "YES" {
                        //        Response.Write HTML_iframeTR("CubeFilter", mp_vetHeight(0), "CubeFilter.asp?" & Request_QueryString)
                        //}
                        //    else
                        //{

                        if (CStr(mp_vetHeight[0]) != "0")
                        {


                            //'-- Invoco la viwerFiltro non pi� tramite un iframe ma ne 'sparata' in una div
                            _response.Write(@"<tr><td class=""width_100_percent"">");


                            _response.Write(@"<div id=""Div_CubeFilter"" class=""width_100_percent"">");



                            objCubeFilter.run(_response);
                            // Set objCubeFilter = Nothing



                            _response.Write("</div>");
                            _response.Write("</td></tr>");



                            //}


                        }


                    }


                }



                //'-- disegna la toolbar
                mp_strcause = "disegna la toolbar";
                _response.Write("<tr><td><table><tr><td>");

                _response.Write("</td></tr></table></td></tr>");



                mp_strcause = "disegna la griglia";


                //if UCase(session(OBJAPPLICATION)("ACCESSIBLE")) <> "YES" {

                //    _response.Write("<tr height=""100%""><td height=""100%"">"
                //    _response.Write(HTML_iframe("CUBEGrid", "CUBEGrid.asp?" & mp_queryString, 1, "scrolling=""no""")
                //    _response.Write("</td></tr>"


                //} else {

                if (CStr(mp_vetHeight[1]) != "0")
                {


                    //'-- Invoco il ViewerGriglia non pi� tramite un iframe ma ne 'sparata' in una div
                    _response.Write(@"<tr><td class=""height_100_percent width_100_percent"">");
                    _response.Write(@"<div id=""Div_CubeGriglia"" class=""height_100_percent width_100_percent"">");


                    CubeGrid objCubeGrid = new CubeGrid(_context, _session, _response);


                    //29/07/2022

                    objCubeGrid.run(_response);





                    //Set objCubeGrid = Nothing


                    _response.Write("</div>");
                    _response.Write("</td></tr>");


                }



            }



            //'-- in caso si abbia il permesso di aggiungere righe viene aggiunta l'area di ADD / UPD
            _response.Write("</table>");
            mp_strcause = "disegna div dei comandi";
            _response.Write(@"<div style=""display:none"">");
            //'_response.Write(HTML_iframe("CUBE_Command", "CUBE_Command.asp?" & mp_queryString, , " style=""display:none"" ")
            _response.Write(HTML.Basic.HTML_iframe("CUBE_Command", "", 0, @" style=""display:none"" "));
            _response.Write("</div>");


            // TODO
            //    Set win = Nothing
            //    Exit Function


            //HError:

            //            RaiseError mp_strcause




        }

        private void InitLocal()
        {

            mp_ObjSession = _session;

            // TODO On Error Resume Next
            string manuale = string.Empty;
            string pagina = string.Empty;
            string riga = string.Empty;
            string kit = string.Empty;
            int PosSuperUser = 0;
            string strHeight = string.Empty;
            mp_Permission = CStr(_session[SessionProperty.SESSION_PERMISSION]);


            mp_Suffix = CStr(_session[SessionProperty.SESSION_SUFFIX]);
            if (!string.IsNullOrEmpty(mp_Suffix)) { mp_Suffix = "I"; }
            mp_User = CLng(_session[Session.SessionProperty.SESSION_USER]);


            mp_strConnectionString = Application.ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);



            mp_Toolbar = GetParamURL(Request_QueryString, "Toolbar");
            if (string.IsNullOrEmpty(mp_Toolbar))
            {
                mp_Toolbar = "CUBE_Toolbar";
            }

            string strPosPerAdd = GetParamURL(Request_QueryString, "AddPermission");
            if (!string.IsNullOrEmpty(strPosPerAdd))
            {
                mp_PosPerAdd = Convert.ToInt32(strPosPerAdd);
            }



            mp_Caption = GetParamURL(Request_QueryString, "Caption");
            if (string.IsNullOrEmpty(mp_Caption))
            {
                mp_Caption = "CUBE / Definizione CUBE";
            }


            mp_Table = GetParamURL(Request_QueryString, "Table");
            mp_AreaAdd = GetParamURL(Request_QueryString, "AreaAdd");
            mp_AreaUpd = GetParamURL(Request_QueryString, "AreaUpd");


            strHeight = GetParamURL(Request_QueryString, "Height");
            strHeight = Replace(strHeight, "*", "%");
            if (string.IsNullOrEmpty(strHeight))
            {
                strHeight = "160,100%,440";
            }

            mp_vetHeight = strHeight.Split(",");


            mp_CUBEMode = GetParamURL(Request_QueryString, "CUBEMode");
            if (string.IsNullOrEmpty(mp_CUBEMode))
            {
                mp_CUBEMode = "def";
            }


            mp_ModuleCUBE = GetParamURL(Request_QueryString, "MODULE");


            if (mp_CUBEMode.ToLower() == "storico")
            {


                //'-- recupera il CUBE in definizione
                //            Dim mp_objDB As Object
                //            Dim rs As ADODB.Recordset
                //Set mp_objDB = MyCreateObject("CUBEEntity.CUBE", mp_ObjSession)
                //            Set rs = mp_objDB.GetRSCUBE(mp_ModuleCUBE, mp_CUBEMode, mp_strConnectionString)
                //            Set mp_objDB = Nothing



                //mp_Periodo = Trim(rs.Fields("BDG_Periodo"))
                //        }
                //        else { }
                mp_Periodo = GetParamURL(Request_QueryString, "PERIOD");
            }




            //'-- azzero le caratteristiche di visualizzazione
            _session["CUBE_Sort"] = "";


            //Set rs = Nothing


            mp_queryString = CStr(Request_QueryString);
            mp_queryString = MyReplace(mp_queryString, "&PERIOD=" + GetParamURL(Request_QueryString, "PERIOD"), "");
            mp_queryString = MyReplace(mp_queryString, "PERIOD=" + GetParamURL(Request_QueryString, "PERIOD"), "");
            mp_queryString = MyReplace(mp_queryString, "PERIOD=", "");


            //'-- verifica se il primo carattere � un & e lo elimina
            if (CommonModule.Basic.Left(mp_queryString, 1) == "&") { mp_queryString = MidVb6(mp_queryString, 2); }



            InitLocal_DefineFilteredDomain();


            //'-- azzero eventuali filtri o settaggi utente precedenti
            mp_ObjSession["CUBE_Filter"] = "";
            mp_ObjSession["CUBE_Selection"] = null;   /// TODO VERIFICARE CON EMPTY
            mp_ObjSession["CUBE_Sort"] = "";


            mp_AreaFiltro = GetParamURL(Request_QueryString, "AreaFiltro");
            mp_AreaFiltroWin = GetParamURL(Request_QueryString, "AreaFiltroWin");



        }

        private void InitLocal_DefineFilteredDomain()
        {
            //        '-- recupero le informazioni di configurazione dell'utente
            //'-- recupero il modello di attributi su cui filtrare l'utente
            //'-- per ogni attributo definisco
        }

        //'-- inizializzo gli oggetti dell'interfaccia ed eseguo i controlli sui dati
        private void InitGUIObject()
        {
            mp_strcause = "recupero la toolbar";
            //'Set mp_objDB = CreateObject("ctldb.lib_dbfunction")
            //'Set mp_objToolbar = mp_objDB.GetHtmlToolbar(mp_Toolbar, mp_Permission, mp_Suffix, mp_strConnectionString)
            //'Set mp_objDB = Nothing
        }

        public bool checkHackSecurity(HttpContext httpContext, Session.ISession session)
        {
            bool result = false;

            BlackList mp_objDB = new BlackList();
            Dictionary<string, string> attackerInfo = new Dictionary<string, string>();

            //checkHackSecurity = False

            if (!mp_objDB.isDevMode(session) && !isValid(CStr(mp_Table), 1))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                result = true;
                return result;
            }

            if (!mp_objDB.isDevMode(session) && !isValid(CStr(mp_ModuleCUBE), 1))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_MODCUBE), session, mp_strConnectionString);
                result = true;
                return result;
            }

            if (!mp_objDB.isDevMode(session) && !isValid(CStr(mp_CUBEMode), 1))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_CUBEMODE), session, mp_strConnectionString);
                result = true;
                return result;
            }

            string mp_strTable = GetParamURL(Request_QueryString.ToString(), "Table");
            if (!string.IsNullOrEmpty(mp_strTable) && !mp_objDB.isDevMode(session) && !checkPermission(mp_strTable, session, mp_strConnectionString))
            {
                // Controllo se l'utente è autorizzato ad accedere allo specifico oggetto sql(tabella, vista)
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_CONTROLLO_PERMESSI, "##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
                result = true;
            }

            return result;
        }
    }
}
