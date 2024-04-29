using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.DashBoard
{
    public class Message
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




        private string mp_MsgText;
        private long mp_MP;




        private string mp_Form;


        public Message(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this._httpContext = httpContext;
            this._session = session;
            this._response = response;
        }

        public void run(EprocResponse Response)
        {

            try
            {
                MsgBox ObjMsgBox = new MsgBox();

                //On Error GoTo HError

                //'-- recupero variabili di sessione
                InitLocal(_session);



                Response.Write(ObjMsgBox.Init(mp_MsgText, CInt(Constants.vbOK), ApplicationCommon.CNV("Attenzione", mp_ObjSession)));



                return;

            }
            catch (Exception ex)
            {
                //HError:

                //    RaiseError mp_strcause
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
            mp_Permission = session["Funzionalita"];


            mp_Suffix = session[Session.SessionProperty.SESSION_SUFFIX];
            if (string.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }
            mp_User = session["IdPfu"];


            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(_httpContext.Request.QueryString);



            mp_MsgText = GetParamURL(Request_QueryString.ToString(), "MSG");


        }



    }
}
