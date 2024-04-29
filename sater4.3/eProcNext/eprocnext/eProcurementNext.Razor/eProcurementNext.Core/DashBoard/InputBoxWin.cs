using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.DashBoard
{
    public class InputBoxWin
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
        private Caption mp_objCaption;
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




        private string mp_SitenticHelp;
        private string mp_Caption;
        private Fld_Label mp_objHelp;

        private string mp_Modello;
        private string mp_Height;
        private string mp_Command;
        private string mp_Icon;



        private string mp_Form;


        public InputBoxWin(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this._httpContext = httpContext;
            this._session = session;
            this._response = response;
        }

        public void run(EprocResponse Response)
        {
            try
            {
                //On Error GoTo HError


                string fldName;
                int i;
                Dictionary<string, string> JS = new Dictionary<string, string>();


                //'-- recupero variabili di sessione
                InitLocal(_session);


                InitGUIObject();

                mp_objCaption = new Caption();


                //Ext = new ActiveExtendedAttrib
                //Ext.JScript JS

                JS.Add("ExecFunction", @"<script src=""" + "../CTL_Library/" + @"jscript/ExecFunction.js"" ></script>");
                JS.Add("getObj", @"<script src=""" + "../CTL_Library/" + @"jscript/getObj.js"" ></script>");
                JS.Add("ExtendedAttrib", @"<script src=""" + "../CTL_Library/" + @"jscript/Field/ExtendedAttrib.js"" ></script>");
                JS.Add("SearchDocumentForExtendeAttrib", @"<script src=""" + "../CTL_Library/" + @"jscript/Field/SearchDocumentForExtendeAttrib.js"" ></script>");


                //'-- js di jquery
                JS.Add("jquery", @"<script src=""" + "../CTL_Library/" + @"jscript/jquery/jquery-1.9.1.js"" ></script>");
                JS.Add("jqueryUI", @"<script src=""" + "../CTL_Library/" + @"jscript/jquery/jquery-ui-1.10.1.custom.min.js"" ></script>");
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";


                //On Error Resume Next
                //JS.Add("getObj", @"<script src=""" + @"jscript/getObj.js"" ></script>");


                mp_objForm.JScript(JS);
                //On Error GoTo HError
                mp_objModel.JScript(JS);
                mp_ObjButtonBar.JScript(JS);


                //'-- setta il titolo della finestra
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "TITLE")))
                {
                    Response.Write(Title(GetParamURL(Request_QueryString.ToString(), "TITLE")));
                }
                else
                {
                    Response.Write(Title(mp_Caption));
                }

                Response.Write($@"</head><body>" + Environment.NewLine);

                Response.Write(JavaScript(JS));


                //'-- aggiunge i campi nascosti per il funzionamento


                //'-- apre il form
                if (!string.IsNullOrEmpty(mp_Form))
                {
                    Response.Write(mp_objForm.OpenForm());
                }



                Response.Write($@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"">");


                if (!string.IsNullOrEmpty(mp_Caption))
                {
                    Response.Write($@"<tr><td>");
                    mp_objCaption.Init(mp_ObjSession);
                    Response.Write(mp_objCaption.SetCaption(ApplicationCommon.CNV(mp_Caption, mp_ObjSession)));
                    Response.Write($@"</td></tr>");
                }



                //'-- aggiungo l'help
                if (!string.IsNullOrEmpty(mp_SitenticHelp))
                {
                    Response.Write($@"<tr><td >" + Environment.NewLine);
                    mp_objHelp.Html(Response);
                    Response.Write($@"</td><td >" + Environment.NewLine);
                }



                //'-- disegna il modello di input
                mp_strcause = "disegna il modello di input";
                Response.Write($@"<tr><td width=""100%"" align=""center"" >");
                mp_objModel.Html(Response);
                Response.Write($@"</td></tr>");



                //'    Response.Write($@"<tr><td ><hr>"
                //'    Response.Write($@"</td></tr>"


                //'-- disegna i bottoni per conferma o annulla
                mp_strcause = "disegna i bottoni del form";
                Response.Write($@"<tr><td width=""100%"" ><br/>");
                mp_ObjButtonBar.Html(Response);
                Response.Write($@"</td></tr>");


                //'-- disegna uan riga per allineare la pagina
                mp_strcause = "disegna uan riga per allineare la pagina";
                Response.Write($@"<tr><td height=""100%"" >");
                Response.Write($@"</td></tr>");



                Response.Write($@"</table>");




                //'-- chiude il form di ricerca
                if (!string.IsNullOrEmpty(mp_Form))
                {
                    Response.Write(mp_objForm.CloseForm());
                }





                //'-- inserisco lo script per copiare sul chiamate i campi previsti
                if (!string.IsNullOrEmpty(mp_Command))
                {

                    Response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);
                    Response.Write($@"        function OnOk()" + Environment.NewLine);
                    Response.Write($@"        {{  " + Environment.NewLine);

                    Response.Write($@"            try{{" + Environment.NewLine);
                    for (i = 0; i < mp_objModel.Fields.Count; i++)
                    { //To mp_objModel.Fields.count

                        fldName = mp_objModel.Fields.ElementAt(i).Value.Name;


                        Response.Write($@"               try{{ opener.getObj('" + fldName + "' ).value = getObj('" + fldName + "' ).value; }}catch( e ){{}};" + Environment.NewLine);

                    }


                    if (GetParamURL(Request_QueryString.ToString(), "CheckResult") == "yes")
                    {
                        Response.Write($@"               if( opener." + mp_Command + " == 0 ){{ return 0; }}" + Environment.NewLine);
                    }
                    else
                    {
                        Response.Write($@"               opener." + mp_Command + "; " + Environment.NewLine);
                    }

                    Response.Write($@"            }}catch( e ) {{}};" + Environment.NewLine);
                    Response.Write($@"        return 1;" + Environment.NewLine);
                    Response.Write($@"        }}" + Environment.NewLine);



                    Response.Write($@"</script >");
                }



                //'-- se richiesto ricopio dall'opener i valori dei campi
                if (GetParamURL(Request_QueryString.ToString(), "CopyFromSource") == "yes")
                {
                    Response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);

                    for (i = 0; i < mp_objModel.Fields.Count; i++)
                    {

                        fldName = mp_objModel.Fields.ElementAt(i).Value.Name;


                        Response.Write($@"             try{{getObj('" + fldName + "').value = opener.getObj('" + fldName + "').value ;}}catch( e ) {{ }};" + Environment.NewLine);

                    }


                    Response.Write($@"</script >");


                }




                //'Ext.Html Response


                //Set Ext = Nothing
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
            string manuale;
            string pagina;
            string riga;
            string kit;
            int PosSuperUser;
            string strHeight;
            mp_Permission = session["Funzionalita"];


            mp_Suffix = session[Session.SessionProperty.SESSION_SUFFIX];
            if (string.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }
            mp_User = session["IdPfu"];


            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(_httpContext.Request.QueryString);


            mp_Caption = GetParamURL(Request_QueryString.ToString(), "Caption");
            mp_Modello = GetParamURL(Request_QueryString.ToString(), "Modello");
            mp_SitenticHelp = GetParamURL(Request_QueryString.ToString(), "SitenticHelp");
            mp_Command = GetParamURL(Request_QueryString.ToString(), "Command");


            mp_Height = GetParamURL(Request_QueryString.ToString(), "Height");
            mp_Icon = GetParamURL(Request_QueryString.ToString(), "Icon");


            mp_Form = GetParam(CStr(Request_QueryString), "FORM");



        }


        //////'-- inizializzo gli oggetti dell'interfaccia
        private void InitGUIObject()
        {

            string strFilter;
            string[] v;
            string[] p;
            int i;



            mp_objForm = new Form();
            mp_objModel = new Model();
            mp_ObjButtonBar = new ButtonBar();

            if (!string.IsNullOrEmpty(mp_Form))
            {
                //'-- inizializzo il form
                v = Strings.Split(mp_Form, "#");


                mp_objForm.id = "InputBoxWin";
                mp_objForm.Action = v[0];
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "FORM_TARGET")))
                {
                    mp_objForm.Target = GetParamURL(Request_QueryString.ToString(), "FORM_TARGET");
                }
                else
                {
                    mp_objForm.Target = "";
                }


            }

            //'-- barra dei bottoni
            mp_ObjButtonBar.CaptionSubmit = ApplicationCommon.CNV("Ok", mp_ObjSession);
            mp_ObjButtonBar.CaptionReset = ApplicationCommon.CNV("Annulla", mp_ObjSession);
            if (string.IsNullOrEmpty(mp_Form))
            {
                mp_ObjButtonBar.OnSubmit = $@"if( OnOk() == 1 ){{ self.close();}}";
            }
            mp_ObjButtonBar.OnReset = "self.close();";


            //'-- inizializzo la caption
            mp_strcause = "inizializzo la caption";
            mp_objHelp = new Fld_Label();
            mp_objHelp.PathImage = "../images/";
            mp_objHelp.Style = "SinteticHelp";
            mp_objHelp.Value = ApplicationCommon.CNV(mp_SitenticHelp, mp_ObjSession);
            mp_objHelp.Image = mp_Icon;



            //'-- recupero il modello
            mp_strcause = "recupero il modello di ricerca";
            mp_objDB = new LibDbModelExt();
            //Set mp_objDB = CreateObject("ctldb.lib_dbmodelext")
            mp_objModel = mp_objDB.GetFilteredModel(mp_Modello, mp_Suffix, mp_User, 0, mp_strConnectionString, true, mp_ObjSession);
            //Set mp_objDB = Nothing


            //On Error Resume Next
            //'-- verifica se � passato un default
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "DefaultValue")))
            {


                v = Strings.Split(GetParamURL(Request_QueryString.ToString(), "DefaultValue"), ",");
                for (i = 0; i <= v.Length - 1; i++)
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


            //'-- verifica se � passato un default
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "DefaultValueEdit")))
            {


                v = Strings.Split(GetParamURL(Request_QueryString.ToString(), "DefaultValueEdit"), ",");
                for (i = 0; i < v.Length - 1; i++)
                {
                    strFilter = v[i];
                    strFilter = strFilter.Trim();
                    strFilter = strFilter.Replace("'", "");
                    p = Strings.Split(strFilter, "=");

                    //'-- inserisce il valore sull'attributo e lo blocca
                    mp_objModel.Fields[p[0]].Value = p[1];
                    //'mp_objModel.Fields(p(0)).SetEditable False
                }


            }




        }
    }
}
