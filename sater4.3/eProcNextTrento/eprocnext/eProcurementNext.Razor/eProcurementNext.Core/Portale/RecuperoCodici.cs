
using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Portale
{
    public class RecuperoCodici
    {
        public IConfiguration configuration;
        private EprocResponse _response;
        private IHttpContextAccessor _accessor;
        private HttpContext _context;
        private eProcurementNext.Session.ISession _session;
        private Session.Session mp_ObjSession;// '-- oggetto che contiene il vettore base con gli elementi della libreria
        private string mp_Suffix;
        private long mp_User;
        private string mp_Nome;
        private string mp_Cognome;
        private string mp_Permission;
        private string mp_strConnectionString;
        private Form mp_objForm;
        private Model mp_objModel;
        private ButtonBar mp_ObjButtonBar;
        private Fld_Button mp_ObjButton;
        private Fld_Button mp_ObjButtonReset;
        private Fld_Label mp_objCaption;
        private Caption mp_objCaption1;
        private string mp_strModelloFiltro;
        private dynamic mp_objDB;
        private string mp_strcause;
        private string mp_strTable;
        private string mp_queryString;
        private IFormCollection? Request_Form;
        private dynamic Request_QueryString;

        public RecuperoCodici(IConfiguration configuration, IHttpContextAccessor accessor, eProcurementNext.Session.ISession session)
        {
            this.configuration = configuration;
            this._accessor = accessor;
            //this._context = context;
            this._session = session;

            _response = new EprocResponse(GetParamURL(this._accessor.HttpContext.Request.QueryString.ToString(), "XML_ATTACH_TYPE"));
        }
        public void run(dynamic Response)
        {
            dynamic JS = null;
            try
            {

                mp_objCaption1 = new Caption();
                //'-- recupero variabili di sessione
                InitLocal();
                //'-- Inizializzo gli oggetti dell'interfaccia
                InitGUIObject();


                // '----------------------------------
                // '-- avvia la scrittura della pagina
                // '----------------------------------


                //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";
                mp_objForm.JScript(JS);
                mp_objModel.JScript(JS);

                JS.Add($@"<script src=""../CTL_Library/JScript/getObj.js""></script>", "getObj");
                JS.Add($@"<script src=""jscript/CheckRecuperoCodici.js""></script>", "RiferimentiContesto");

                //'-- inserisce i java script necessari
                mp_strcause = "inserisce i java script necessari";
                _response.Write(JavaScript(JS));
                //'-- Metto la pagina in primo piano e cambio il titolo
                _response.Write($@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);
                //'Response.write "debugger;" & vbCrLf
                _response.Write($@"document.title = '" + ApplicationCommon.CNV(mp_strModelloFiltro, mp_ObjSession) + "';" + Environment.NewLine);
                _response.Write($@"window.focus();" + Environment.NewLine);
                _response.Write("" + Environment.NewLine);
                _response.Write("</script>" + Environment.NewLine);
                _response.Write("</head><body>" + Environment.NewLine);

                _response.Write($@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td>");
                _response.Write($@"<tr><td width=""100%"">");

                mp_objCaption1.Init(mp_ObjSession);
                _response.Write(mp_objCaption1.SetCaption(ApplicationCommon.CNV(mp_strModelloFiltro, mp_ObjSession)));
                _response.Write("</td></tr>");

                //'-- aggiungo la caption all'area
                _response.Write("<tr><td>" + Environment.NewLine); ;
                //'mp_objCaption.Html Response
                _response.Write($@"<table class=""SinteticHelp_Tab"" ><tr><td title= >");
                _response.Write("</td>");
                _response.Write($@"<td class=""SinteticHelp_label"" id=""_label"" >" + ApplicationCommon.CNV("help_" + mp_strModelloFiltro, mp_ObjSession) + "</td></tr>");
                //'Response.Write "<td class=""SinteticHelp_label"" id=""_label"" >" & CNV("Compila i campi sottostanti e premi invia", mp_ObjSession) & "</td></tr>"

                _response.Write("</table>");
                _response.Write("</td><td >" + Environment.NewLine);

                //'--riga vuota
                _response.Write($@"<tr><td>&nbsp;</td></tr>");

                //'-- apre il form di ricerca
                _response.Write(mp_objForm.OpenForm());

                //'-- disegna il modello di ricerca
                mp_strcause = "disegna il modello di ricerca";
                _response.Write($@"<tr><td width=""100%"" >");
                mp_objModel.Html(Response);
                _response.Write("</td></tr>");

                //'--riga vuota
                _response.Write($@"<tr><td height=""100%""></td></tr>");

                //'-- disegna i bottoni del form
                //'    Response.Write "<tr><td width=""100%"" >"
                //'    mp_ObjButtonBar.Html Response
                //'    Response.Write "</td></tr>"

                //'-- disegna i bottoni del form
                mp_strcause = "disegna i bottoni del form";
                _response.Write("<tr>");
                _response.Write("<td >");
                mp_ObjButton.Html(Response);
                _response.Write("&nbsp;&nbsp;");
                mp_ObjButtonReset.Html(Response);
                _response.Write("</td>");
                _response.Write("</tr>");
                //'-- chiude il form di ricerca
                _response.Write(mp_objForm.CloseForm());


                _response.Write("</table>");



                //'Ext.Html Response


                //'Set Ext = Nothing
                //Exit Function

            }
            catch (Exception ex)
            {
                throw new Exception(mp_strcause);
            }
        }

        private void InitLocal()
        {
            mp_ObjSession = (Session.Session)_session;

            ///On Error Resume Next // da capire
            try
            {
                mp_Suffix = CStr(_session["SESSION_SUFFIX"]);

                if (string.IsNullOrEmpty(mp_Suffix))
                {
                    mp_Suffix = "I";
                }

                mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
                Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
                Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;

                mp_User = CLng(_session["SESSION_USER"]);
                mp_Permission = CStr(_session["SESSION_PERMISSION"]);
                //'mp_Nome = session(SESSION_NOME)
                //'mp_Cognome = session(SESSION_COGNOME)
                string mp_strTable = GetParamURL(Request_QueryString, "Table");
                string mp_strModelloFiltro = GetParamURL(Request_QueryString, "Modello");
                if (string.IsNullOrEmpty(mp_strModelloFiltro))
                {
                    mp_strModelloFiltro = mp_strTable + "Filtro";
                }

                mp_queryString = "&ClearNew=" + GetParamURL(Request_QueryString, "ClearNew") + "&CaptionAdd=" + GetParamURL(Request_QueryString, "CaptionAdd") + "&CaptionUpd=" + GetParamURL(Request_QueryString, "CaptionUpd") + "&RowForPage=" + GetParamURL(Request_QueryString, "RowForPage") + "&IDENTITY=" + GetParamURL(Request_QueryString, "IDENTITY");
            }
            catch
            {

            }
        }

        //'-- inizializzo gli oggetti dell'interfaccia
        //DA CAPIRE IL TIPO
        private void InitGUIObject()
        {
            mp_objForm = new Form();
            mp_objModel = new Model();
            //'Set mp_ObjButtonBar = New CtlHtml.ButtonBar

            mp_ObjButton = new Fld_Button();
            mp_ObjButtonReset = new Fld_Button();

            //'-- inizializzo il form
            mp_objForm.id = "FormRecuperoCodici";
            //'mp_objForm.Action = "ViewerGriglia.asp?MODE=Filtra&Table=" & mp_strTable & mp_queryString
            mp_objForm.Action = "RichiestaCodici.asp?" + HtmlEncode(CStr(Request_QueryString));
            mp_objForm.Target = "RecuperoCodici";

            //'-- barra dei bottoni
            //'    mp_ObjButtonBar.OnSubmit = "check" & mp_strModelloFiltro & "();"
            //'    mp_ObjButtonBar.CaptionSubmit = CNV("Invia la richiesta", mp_ObjSession)
            //'    mp_ObjButtonBar.CaptionReset = CNV("Pulisci", mp_ObjSession)
            mp_ObjButton.Value = ApplicationCommon.CNV("Invia la richiesta", mp_ObjSession);
            mp_ObjButton.setOnClick("Check" + mp_strModelloFiltro + "();");
            mp_ObjButtonReset.Value = ApplicationCommon.CNV("Pulisci", mp_ObjSession);
            mp_ObjButtonReset.setOnClick("document.FormRecuperoCodici.reset();");

            //'-- inizializzo la caption
            mp_strcause = "inizializzo la caption";
            mp_objCaption = new Fld_Label();
            //'mp_objCaption.PathImage = "../images/"
            mp_objCaption.Style = "SinteticHelp";
            mp_objCaption.Value = ApplicationCommon.CNV("Compila i campi sottostanti e premi invia", mp_ObjSession);
            mp_objCaption.Image = "Filter.gif";

            //'-- recupero il modello di ricerca
            mp_strcause = "recupero il modello di ricerca";
            mp_objDB = new LibDbModelExt();
            mp_objModel = mp_objDB.GetFilteredModel(mp_strModelloFiltro, mp_Suffix, mp_User, 0, mp_strConnectionString, true, mp_ObjSession);
        }
    }
}