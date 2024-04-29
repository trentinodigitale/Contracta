using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.DashBoard
{
    public class ViewerInfo
    {
        private IConfiguration _configuration;
        public ViewerInfo(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        private dynamic mp_ObjSession;

        private string mp_Suffix;
        private long mp_User;
        private string mp_Nome;
        private string mp_Cognome;
        private string mp_Permission;
        private string mp_strConnectionString;

        //private CtlHtml.form mp_objForm; non viene usato nel codice (?)
        private Model mp_objModel;
        //private CtlHtml.ButtonBar mp_ObjButtonBar; non viene usato nel codice(?)
        private Caption mp_ObjCaption;

        private string mp_strModelloInfo;

        private dynamic mp_objDB;


        private string mp_strcause;
        private string mp_strTable;
        private string mp_queryString;
        private string mp_OWNER;
        private string mp_Filter;
        private string mp_FilterHide;
        private string mp_Top;
        private string mp_Sort;
        private string mp_SortOrder;
        private bool mp_displayInfo;
        private string mp_Caption;

        private dynamic Request_QueryString;
        private IFormCollection? Request_Form;
        private string mp_alert;

        private string mp_strStoredSQL;

        public dynamic run(HttpContext context, eProcurementNext.Session.ISession session, eProcurementNext.CommonModule.IEprocResponse response)
        {

            Dictionary<string, string> JS = new Dictionary<string, string>();

            //'-- recupero variabili di sessione
            InitLocal(context, session);


            //'-- Inizializzo gli oggetti dell'interfaccia
            InitGUIObject();


            //'----------------------------------
            //'-- avvia la scrittura della pagina
            //'----------------------------------

            //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
            mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";

            mp_objModel.JScript(JS);


            JS.Add("ExecFunction", @"<script src=""../CTL_Library/jscript/ExecFunction.js"" ></script>");


            //'-- inserisce i javascript necessari
            mp_strcause = "inserisce i java script necessari";
            response.Write(JavaScript(JS));


            response.Write("</head><body> ");

            response.Write(@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td>");

            Caption mp_ObjCaption = new Caption();

            if (mp_Caption != "")
            {
                response.Write(@"<tr><td>");
                if (Request_QueryString("Exit") != "si")
                {
                    mp_ObjCaption.OnExit = "top.location='../login.asp';";
                }


                mp_ObjCaption.Init(mp_ObjSession);
                response.Write(@$"{mp_ObjCaption.SetCaption(Application.ApplicationCommon.CNV(mp_Caption.Trim(), mp_ObjSession))}");
                response.Write(@$" </td></tr>");
            }



            //'-- disegna il modello di ricerca
            mp_strcause = "disegna il modello di ricerca";
            response.Write(@$"<tr><td width=""100%"" >");
            if (mp_displayInfo)
            {

                mp_objModel.Html(response);

            }
            else
            {

                response.Write(@$"{CommonModule.Basic.ShowMessageBox(mp_alert, Application.ApplicationCommon.CNV("Attenzione", mp_ObjSession))}");

                response.Write(@$"<script type=""text/javascript"" > ");
                response.Write(@$"top.close(); ");
                response.Write(@$"</script> ");

            }
            response.Write(@$"</td></tr>");




            response.Write(@$"</table>");

            //'-- chiude il form di ricerca
            //'Response.Write mp_objForm.CloseForm()

            response.Write(@$"</td></tr><tr><td height=""100%""></td></tr></table>");

            //'Ext.Html Response

            //'Set Ext = Nothing
            JS = null;

            return response;

        }




        private void InitLocal(HttpContext context, Session.ISession session)
        {

            mp_ObjSession = session;

            int PosSuperUser;

            mp_Suffix = session[SessionProperty.SESSION_SUFFIX];
            if (String.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(context.Request.QueryString);
            Request_Form = context.Request.HasFormContentType ? context.Request.Form : null;

            mp_User = session[SessionProperty.SESSION_USER];
            mp_Permission = session[SessionProperty.SESSION_PERMISSION];
            //mp_Nome = session["SESSION_NOME"];
            //mp_Cognome = session(SESSION_COGNOME);

            mp_strTable = GetParamURL(Request_QueryString, "Table");

            mp_strModelloInfo = CommonModule.Basic.GetParamURL(Request_QueryString, "MODELLO");
            if (String.IsNullOrEmpty(mp_strModelloInfo))
            {
                mp_strModelloInfo = $"{mp_strTable} Info";
            }

            mp_Caption = CommonModule.Basic.GetParamURL(Request_QueryString, "CAPTIONINFO");


            mp_queryString = $"&ClearNew={CommonModule.Basic.GetParamURL(Request_QueryString, "ClearNew")}";
            mp_queryString += $"&CaptionAdd={CommonModule.Basic.GetParamURL(Request_QueryString, "CaptionAdd")}";
            mp_queryString += $"&CaptionUpd={CommonModule.Basic.GetParamURL(Request_QueryString, "CaptionUpd")}";
            mp_queryString += $"&RowForPage={CommonModule.Basic.GetParamURL(Request_QueryString, "RowForPage")}";
            mp_queryString += $"&IDENTITY={CommonModule.Basic.GetParamURL(Request_QueryString, "IDENTITY")}";


            mp_OWNER = CommonModule.Basic.GetParamURL(Request_QueryString, "OWNER");

            if (CommonModule.Basic.GetParamURL(Request_QueryString, "URLDECODE").ToLower() == "yes")
            {
                mp_Filter = CommonModule.Basic.GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = CommonModule.Basic.GetParamURL(Request_QueryString, "FilterHide");
            }
            else
            {
                mp_Filter = CommonModule.Basic.GetParamURL(Request_QueryString, "Filter");
                mp_FilterHide = CommonModule.Basic.GetParamURL(Request_QueryString, "FilterHide");
            }
            mp_Sort = CommonModule.Basic.GetParamURL(Request_QueryString, "Sort");
            mp_SortOrder = CommonModule.Basic.GetParamURL(Request_QueryString, "SortOrder");

            if (!String.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString, "TOP")))
            {
                mp_Top = CommonModule.Basic.GetParamURL(Request_QueryString, "TOP");
            }

            mp_alert = CommonModule.Basic.GetParamURL(Request_QueryString, "Alert");
            if (String.IsNullOrEmpty(mp_alert))
            {
                mp_alert = "retroazioni non presenti per item selezionato";
            }

            mp_strStoredSQL = "";
            if (!String.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString, "STORED_SQL")))
            {
                mp_strStoredSQL = CommonModule.Basic.GetParamURL(Request_QueryString, "STORED_SQL");
            }

        }

        //'-- inizializzo gli oggetti dell'interfaccia
        private void InitGUIObject()
        {
            mp_objDB = new LibDbModelExt(_configuration);
            string strFilter;
            string[] v;
            dynamic p;
            int i;

            mp_objModel = new Model();

            //'-- recupero il modello verticale
            mp_strcause = "recupero il modello di ricerca";

            mp_objModel = mp_objDB.GetFilteredModel(mp_strModelloInfo, mp_Suffix, mp_User, 0, mp_strConnectionString, true, mp_ObjSession);

            //'-- nascondo le colonne richieste
            if (!String.IsNullOrEmpty(CommonModule.Basic.GetParamURL(Request_QueryString, "HIDE_COL")))
            {
                v = CommonModule.Basic.GetParamURL(Request_QueryString, "HIDE_COL").Split(",");

                //v = Split(Request_QueryString("HIDE_COL"), ",")
                //For i = 0 To UBound(v)
                //mp_objModel.Fields.Remove v(i)
                //Next

                for (i = 0; i < v.GetUpperBound(0); i++)
                {
                    mp_objModel.Fields.Remove(v[i]);
                }
            }

            //'--valorizzo il modello con la prima riga del recordset della griglia
            TSRecordSet GetRSGrid = new TSRecordSet();
            mp_Top = "1";
            GetRSGrid = DashBoardMod.GetRSGrid(mp_OWNER, mp_User, mp_strTable, mp_Filter, mp_FilterHide, mp_strConnectionString, mp_Top, "", 0, mp_strStoredSQL);


            GetRSGrid.Sort($"{mp_Sort} {mp_SortOrder}");


            //'--inizializzo i campi del modello con i valori del dettaglio
            mp_displayInfo = false;
            if (GetRSGrid.RecordCount > 0)
            {
                mp_displayInfo = true;
                mp_objModel.SetFieldsValue(GetRSGrid.Fields);
            }

            // inizializzo i campi del modello con i valori del dettaglio

            mp_displayInfo = false;
            if (GetRSGrid.RecordCount > 0)
            {
                mp_displayInfo |= true;
                mp_objModel.SetFieldsValue(GetRSGrid.Fields);
            }

        }


    }
}
