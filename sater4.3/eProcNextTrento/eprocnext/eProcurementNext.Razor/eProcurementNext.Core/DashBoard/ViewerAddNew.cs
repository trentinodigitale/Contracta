using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.DashBoard
{
    public class ViewerAddNew
    {
        private HttpContext _httpContext;
        private Session.ISession _session;
        private IEprocResponse _response;

        private Session.ISession mp_ObjSession; //'-- oggetto che contiene il vettore base con gli elementi della libreria

        private string mp_Suffix;
        private long mp_User;
        private string mp_Nome;
        private string mp_Cognome;
        private string mp_Permission;
        private string mp_strConnectionString;
        private string mp_strModelloAdd;

        private Form mp_objForm;
        private Model mp_objModel;
        private ButtonBar mp_ObjButtonBar;
        private Fld_Label mp_objCaption;
        private Toolbar mp_objToolbar;


        private Dictionary<string, Field> mp_Columns;
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty;
        private LibDbModelExt mp_objDB;

        private string mp_Filter;
        private string mp_NumeroPagina;
        private string mp_Sort;
        private string mp_queryString;
        private string mp_IDENTITY;

        private string mp_strcause;

        private string Request_QueryString;
        private IFormCollection? Request_Form = null;

        private string mp_strTable;
        private string mp_RSConnectionString;



        public ViewerAddNew(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this._httpContext = httpContext;
            this._session = session;
            this._response = response;
        }

        public void run(EprocResponse Response)
        {
            try
            {

                Dictionary<string, string> JS = new Dictionary<string, string>();

                //On Error GoTo HError

                //'-- recupero variabili di sessione
                InitLocal(_session);

                //'-- Controlli di sicurezza

                if (checkHackSecurity(_session, Response) == true)
                {

                    //'Se � presente NOMEAPPLICAZIONE nell'application
                    if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
                    {

                        throw new ResponseRedirectException("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp", _httpContext.Response);
                        //Exit Function


                    }
                    else
                    {

                        throw new ResponseRedirectException("/application/blocked.asp", _httpContext.Response);
                        //Exit Function


                    }


                }

                //'-- Inizializzo gli oggetti dell'interfaccia
                InitGUIObject();

                //'----------------------------------
                //'-- avvia la scrittura della pagina
                //'----------------------------------

                //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";
                mp_objForm.JScript(JS);
                mp_objModel.JScript(JS);
                mp_ObjButtonBar.JScript(JS);


                //'-- inserisce i java script necessari
                mp_strcause = "inserisce i java script necessari";
                Response.Write(JavaScript(JS));


                Response.Write($@"</head><body>" + Environment.NewLine);


                Response.Write($@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td>");

                //'-- apre il form di ricerca
                Response.Write(mp_objForm.OpenForm());

                Response.Write($@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"">");


                //'-- aggiungo la caption all'area di nuovo record o aggiornamento
                //'-- e la toolbar
                Response.Write($@"<tr><td >");
                //'Response.write Table2C(mp_objCaption.Html(), mp_objToolbar.Html(), "100%", "")
                //'Response.Write Table2C(, "", "100%", "")
                mp_objCaption.Html(Response);
                Response.Write($@"</td></tr>" + Environment.NewLine);


                //'-- disegna il modello di ricerca
                mp_strcause = "disegna il modello di ricerca";
                Response.Write($@"<tr><td width=""100%"" >");
                mp_objModel.Html(Response);
                Response.Write($@"</td></tr>");


                //'-- disegna i bottoni del form
                mp_strcause = "disegna i bottoni del form";
                Response.Write($@"<tr><td width=""100%"" >");
                mp_ObjButtonBar.Html(Response);
                Response.Write($@"</td></tr>");



                Response.Write($@"</table>");

                //'-- chiude il form di ricerca
                Response.Write(mp_objForm.CloseForm());

                Response.Write($@"</td></tr><tr><td height=""100%""></td></tr></table>");

                //'-- setto il fuoco sul primo campo del form
                Response.Write($@"<script>");

                //'Response.Write($@"       debugger;"
                Response.Write($@"       try{{ document.forms[0].elements[0].focus();}}catch( e ){{}};");
                //'var obj;"
                //'Response.Write($@"       obj = getObj( '" & mp_objModel.Fields(1).Name & "' );"


                Response.Write($@"</script>" + Environment.NewLine);

                //Set JS = Nothing


                return;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + mp_strcause, ex);
            }


        }

        private void InitLocal(Session.ISession session)
        {

            mp_ObjSession = session;

            //On Error Resume Next
            int PosSuperUser;

            dynamic mp_Suffix = session[Session.SessionProperty.SESSION_SUFFIX];
            if (string.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }


            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];//session[Session.SessionProperty.SESSION_CONNECTIONSTRING]
            Request_QueryString = GetQueryStringFromContext(_httpContext.Request.QueryString);//session[Session.SessionProperty.RequestQueryString]
            Request_Form = _httpContext.Request.HasFormContentType ? _httpContext.Request.Form : null;//session(Session.SessionProperty.RequestForm)


            mp_User = CLng(session["IdPfu"]);
            mp_Permission = CStr(session["Funzionalita"]);
            mp_Nome = CStr(session["IDAZI"]);
            mp_Cognome = CStr(session["IDAZI_Master"]);


            mp_NumeroPagina = GetParamURL(Request_QueryString.ToString(), "nPag");
            mp_Filter = GetParamURL(Request_QueryString.ToString(), "Filter");
            mp_Sort = GetParamURL(Request_QueryString.ToString(), "Sort");


            mp_strTable = GetParamURL(Request_QueryString.ToString(), "Table");
            mp_strModelloAdd = GetParamURL(Request_QueryString.ToString(), "ModelloAdd");
            if (string.IsNullOrEmpty(mp_strModelloAdd))
            {
                mp_strModelloAdd = mp_strTable + "AddNew";
            }
            mp_queryString = "&ClearNew=" + GetParamURL(Request_QueryString.ToString(), "ClearNew") + "&CaptionAdd=" + GetParamURL(Request_QueryString.ToString(), "CaptionAdd") + "&CaptionUpd=" + GetParamURL(Request_QueryString.ToString(), "CaptionUpd") + "&RowForPage=" + GetParamURL(Request_QueryString.ToString(), "RowForPage");

            mp_IDENTITY = GetParamURL(Request_QueryString.ToString(), "IDENTITY");
            if (string.IsNullOrEmpty(mp_IDENTITY))
            {
                mp_IDENTITY = "id";
            }
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "ConnectionString")))
            {
                mp_RSConnectionString = session[GetParamURL(Request_QueryString.ToString(), "ConnectionString")];
            }
            if (string.IsNullOrEmpty(mp_RSConnectionString))
            {
                mp_RSConnectionString = mp_strConnectionString;
            }

        }

        //'-- inizializzo gli oggetti dell'interfaccia
        private void InitGUIObject()
        {

            TSRecordSet rs;
            mp_objForm = new Form();
            //'Set mp_objModel = New CtlHtml.Model
            mp_ObjButtonBar = new ButtonBar();

            string tempQS;
            tempQS = CStr(Request_QueryString);
            tempQS = tempQS.Replace("&MODE=" + GetParamURL(Request_QueryString, "MODE"), "");
            tempQS = tempQS.Replace("MODE=" + GetParamURL(Request_QueryString, "MODE"), "");
            tempQS = tempQS.Replace("&IDROW=" + GetParamURL(Request_QueryString, "IDROW"), "");
            tempQS = tempQS.Replace("IDROW=" + GetParamURL(Request_QueryString, "IDROW"), "");
            if (Strings.Left(tempQS, 1) == "&")
            {
                tempQS = Strings.Mid(tempQS, 2);
            }

            //'-- inizializzo il form
            mp_objForm.id = "FormViewerAddNew";
            //'mp_objForm.Action = "ViewerGriglia.asp?MODE=ADD&Table=" & mp_strTable & HtmlEncode(mp_queryString)
            mp_objForm.Action = "ViewerGriglia.asp?MODE=ADD&" + HtmlEncode(tempQS);
            mp_objForm.Target = "ViewerGriglia";

            //'-- barra dei bottoni
            mp_ObjButtonBar.CaptionSubmit = ApplicationCommon.CNV("Aggiungi", mp_ObjSession);
            mp_ObjButtonBar.CaptionReset = ApplicationCommon.CNV("Pulisci", mp_ObjSession);




            mp_ObjButtonBar.OnReset = "self.location='" + "ViewerAddNew.asp?MODE=ADD&" + tempQS.Replace(@"'", @"\'") + "';";

            //'mp_ObjButtonBar.OnReset = "self.location='" & "ViewerAddNew.asp? MODE = ADD & Table = " & mp_strTable & Replace(mp_queryString, "'", "\'") & "';"
            mp_ObjButtonBar.OnSubmit = $@"try{{ document.forms[0].elements[0].focus(); }}catch( e ) {{}};"; //'& IIf(Request_QueryString("ClearNew") = "1", "document.forms[0].reset();", "")

            //'-- inizializzo la caption
            mp_strcause = "inizializzo la caption";
            mp_objCaption = new Fld_Label();
            mp_objCaption.PathImage = "../images/";
            mp_objCaption.Style = "SinteticHelp";



            //'-- recupero il modello di ricerca
            mp_strcause = "recupero il modello di ricerca";
            mp_objDB = new LibDbModelExt();
            //'Set mp_objModel = mp_objDB.GetModel(mp_strTable & "AddNew", mp_Suffix, , mp_strConnectionString)
            //'Set mp_objModel = mp_objDB.GetModel(mp_strModelloAdd, mp_Suffix, , mp_strConnectionString)
            mp_objModel = mp_objDB.GetFilteredModel(mp_strModelloAdd, mp_Suffix, 0, 0, mp_strConnectionString, true, mp_ObjSession);
            mp_objModel.NumberColumn = 2;
            //Set mp_objDB = Nothing


            //'-- nel caso sia indicato un record preciso carico i campi del modello con quel record
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "IDROW")))
            {

                mp_strcause = "recupero il recordset del Viewer dal database";
                //'Set mp_objDB = CreateObject("AFListeEntity.Viewer")
                rs = GetRSElem(mp_strTable, " " + mp_IDENTITY + " = " + GetParamURL(Request_QueryString, "IDROW"), mp_RSConnectionString);
                //'Set mp_objDB = Nothing

                //'-- modifico i campi del modello con i valori del RS
                mp_objModel.SetFieldsValue(rs.Fields);


            }


            //'-- nel caso si tratta di un update modifico l'azionde del form per eseguire l'aggiornamento del record
            if (GetParamURL(Request_QueryString, "MODE") == "UPD")
            {

                //'-- cambio la toolbar
                mp_ObjButtonBar.CaptionSubmit = ApplicationCommon.CNV("Aggiorna", mp_ObjSession);
                mp_ObjButtonBar.ShowButtons = ButtonBar.SubmitButton;

                //'-- cambio l'azione del form per eseguire l'aggiornamento
                //'mp_objForm.Action = "ViewerGriglia.asp?MODE=UPD&IDROW= " & Request_QueryString("IDROW") & "&nPag=" & mp_NumeroPagina & "&Filter=" & mp_Filter & "&Sort=" & mp_Sort & "&Table=" & mp_strTable & HtmlEncode(mp_queryString)
                mp_objForm.Action = "ViewerGriglia.asp?MODE=UPD&IDROW=" + GetParamURL(Request_QueryString, "IDROW") + "&" + HtmlEncode(tempQS);


                //'-- setto la caption per la modifica
                mp_objCaption.Value = ApplicationCommon.CNV(GetParamURL(Request_QueryString, "CaptionUpd"), mp_ObjSession);
                mp_objCaption.Image = "update.gif";


                //'-- inizializzo la toolbar per la modifica
                mp_strcause = "inizializzo la toolbar per la modifica";
                //Set mp_objDB = CreateObject("ctldb.lib_dbFunction")

                mp_objToolbar = Lib_dbFunctions.GetHtmlToolbar(mp_strTable + "ToolbarUpd", mp_Permission, mp_Suffix, mp_strConnectionString);
                //Set mp_objToolbar = mp_objDB.GetHtmlToolbar(mp_strTable + "ToolbarUpd", mp_Permission, mp_Suffix, mp_strConnectionString)
                mp_objModel.NumberColumn = 2;
                //Set mp_objDB = Nothing



            }
            else
            {

                //'-- setto la caption per l'inserimento
                mp_objCaption.Value = ApplicationCommon.CNV(GetParamURL(Request_QueryString, "CaptionAdd"), mp_ObjSession);
                mp_objCaption.Image = "Create.gif";

                //'-- inizializzo la toolbar per l'inserimento
                mp_strcause = "inizializzo la toolbar  per l'inserimento";
                //mp_objDB = CreateObject("ctldb.lib_dbFunction")
                mp_objToolbar = Lib_dbFunctions.GetHtmlToolbar(mp_strTable + "ToolbarAdd", mp_Permission, mp_Suffix, mp_strConnectionString);
                mp_objModel.NumberColumn = 2;
                //Set mp_objDB = Nothing



            }



            if (GetParamURL(Request_QueryString, "InitAdd") == "1" && string.IsNullOrEmpty(GetParamURL(Request_QueryString, "MODE")))
            {

                //'-- verifica se � passato un filtro nascosto per default
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "FilterHide")))
                {

                    string[] v, p;
                    int i;
                    string strFilter;
                    v = Strings.Split(GetParamURL(Request_QueryString, "FilterHide"), "and");
                    for (i = 0; i <= (v.Length - 1); i++)
                    {
                        strFilter = v[i];
                        strFilter = strFilter.Trim();
                        strFilter = strFilter.Replace("'", "");
                        p = Strings.Split(strFilter, "=");

                        //'-- inserisce il valore sull'attributo e lo blocca
                        mp_objModel.Fields[p[0]].Value = p[1];
                        mp_objModel.Fields[p[0]].SetEditable(false);
                    }


                }

            }

        }

        //'-- ritorna un recordset con la lista dei ricambi disponibili eventualmente filtrata con dal criterio richiesto
        public TSRecordSet GetRSElem(string strTable, string strFilter, string strConnectionString)
        {
            string strSql = "";

            try
            {

                //Dim mp_objDB As Object
                TSRecordSet rs;

                strSql = "select * from " + strTable;


                if (!string.IsNullOrEmpty(strFilter))
                {
                    strSql = strSql + " where " + strFilter;
                }


                //Set mp_objDB = CreateObject("ctldb.clsTabManage")
                CommonDbFunctions cdf = new CommonDbFunctions();
                rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString);
                //Set mp_objDB = Nothing



                return rs;



            }
            catch (Exception ex)
            {

                throw new Exception(" DashBoard.ViewerAddNew.GetRSElem( " + strSql + " )", ex);

            }

        }

        public bool checkHackSecurity(Session.ISession session, EprocResponse Response)
        {



            BlackList mp_objDB = new BlackList();
            bool result = false;

            if (!mp_objDB.isDevMode())
            {
                try
                {
                    // table
                    if (!Basic.isValid(mp_strTable, 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }

                    // 'filter
                    if (!Basic.isValid(mp_strTable, 1))
                    {
                        if (!Basic.isValidaSqlFilter(CStr(mp_Filter)))
                        {
                            mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_FILTER), session, mp_strConnectionString);
                            result = true;
                            return result;
                        }
                    }

                    //'mp_strModelloAdd
                    if (!string.IsNullOrEmpty(CStr(mp_strModelloAdd)))
                    {
                        if (!Basic.isValid(mp_strModelloAdd, 1))
                        {
                            mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_MODADD), session, mp_strConnectionString);
                            result = true;
                            return result;
                        }
                    }

                    //'identity

                    if (!string.IsNullOrEmpty(CStr(mp_IDENTITY)) && !Basic.isValid(mp_IDENTITY, 1))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, CStr(session[SessionProperty.IdPfu]), ATTACK_QUERY_IDENTITY), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }

                    //' Controllo se l'utente � autorizzato ad accedere allo specifico oggetto sql(tabella, vista)
                    if (!Basic.checkPermission(mp_strTable, session, mp_strConnectionString))
                    {
                        mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, CStr(session[SessionProperty.IdPfu]), ATTACK_CONTROLLO_PERMESSI.Replace("##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
                        result = true;
                        return result;
                    }
                }
                catch
                {

                }
            }

            return result;

        }

    }
}
