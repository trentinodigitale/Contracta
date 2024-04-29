using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.BizDB
{
    public class UpdateFieldVisual
    {
        private IHttpContextAccessor _accessor;
        private readonly HttpContext _context;
        private readonly Session.ISession _session;

        private string mp_Suffix;
        private long mp_User;
        private string mp_Nome;
        private string mp_Cognome;
        private string mp_Permission;
        private string mp_strConnectionString;

        private Form mp_objForm;
        private Model mp_objModel;
        private ButtonBar mp_ObjButtonBar;
        private Fld_Label mp_objCaption;
        private string mp_strModelloFiltro;
        private LibDbModelExt mp_objDB;


        private string mp_strcause;
        private string mp_strTable;
        private string mp_queryString;

        private string Request_QueryString;
        private IFormCollection Request_Form;
        private bool mp_RetrieveInfo;

        private readonly CommonDbFunctions cdf = new();

        public UpdateFieldVisual(HttpContext context, eProcurementNext.Session.ISession session)
        {
            this._context = context;
            this._session = session;
        }

        public void run(IEprocResponse Response)
        {
            Dictionary<string, string> JS = new Dictionary<string, string>();

            try
            {
                //'-- recupero variabili di sessione
                InitLocal(_session);

                //'-- Controlli di sicurezza
                if ((checkHackSecurity(_session, _context)))
                {

                    //'Se � presente NOMEAPPLICAZIONE nell'application
                    if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
                    {
                        throw new ResponseRedirectException("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp", _context.Response);
                    }
                    else
                    {
                        throw new ResponseRedirectException($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp", _context.Response);
                    }
                }

                //'-- Inizializzo gli oggetti dell'interfaccia
                InitGUIObject();

                //'----------------------------------
                //'-- avvia la scrittura della pagina
                //'----------------------------------

                //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";

                mp_objModel.JScript(JS);

                //'-- inserisce i java script necessari

                mp_objModel.UpdateFieldVisual(Response, CLng(GetParamURL(Request_QueryString, "Row")), GetParamURL(Request_QueryString, "strDocument"));

                if (!mp_RetrieveInfo)
                {
                    //'--javascript per evidenziare che non sono stati trovati valori
                    Response.Write($@"<script language=""JavaScript"">" + Environment.NewLine);
                    Response.Write($@"try {{" + Environment.NewLine);

                    if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "strDocument")))
                    {
                        Response.Write(GetParamURL(Request_QueryString, "strDocument") + @".getObj('" + GetParamURL(Request_QueryString, "AttribSource") + @"').className='fld_Evidence';" + Environment.NewLine);
                        Response.Write(GetParamURL(Request_QueryString, "strDocument") + @".getObj('" + GetParamURL(Request_QueryString, "AttribSource") + @"_V').className='fld_Evidence';" + Environment.NewLine);
                    }
                    else
                    {
                        Response.Write($@"getObj('" + GetParamURL(Request_QueryString, "AttribSource") + "').className='fld_Evidence';" + Environment.NewLine);
                        Response.Write($@"getObj('" + GetParamURL(Request_QueryString, "AttribSource") + "_V').className='fld_Evidence';" + Environment.NewLine);
                    }

                    Response.Write($@"}}" + Environment.NewLine);
                    Response.Write($@"catch(e) {{}}" + Environment.NewLine);
                    Response.Write($@"</script>" + Environment.NewLine);
                }
            }
            catch (Exception e)
            {
                throw new Exception(mp_strcause);
            }
        }

        private void InitLocal(Session.ISession session)
        {


            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];

            int PosSuperUser;

            mp_Suffix = CStr(_session[SessionProperty.SESSION_SUFFIX]);
            if (string.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
            //IFormCollection? Request_Form = null;
            //if (_context.Request.HasFormContentType)
            //{
            //    Request_Form = _context.Request.Form;
            //}

            mp_User = CLng(session[Session.SessionProperty.SESSION_USER]);
            mp_Permission = CStr(session[Session.SessionProperty.SESSION_PERMISSION]);

            mp_strTable = GetParamURL(Request_QueryString, "Table");
            mp_strModelloFiltro = GetParamURL(Request_QueryString, "Model");


        }

        private void InitGUIObject()
        {

            string strFilter = "";
            //Dim v As Variant
            //Dim p As Variant
            int i;
            TSRecordSet rs;
            string strSql = "";

            mp_objModel = new Model();

            //'-- recupero il modello di ricerca
            mp_strcause = "recupero il modello di ricerca";
            LibDbModelExt mp_objDB = new LibDbModelExt();
            mp_objModel = mp_objDB.GetFilteredModel(mp_strModelloFiltro, mp_Suffix, mp_User, 0, mp_strConnectionString, true, _session);



            //'--recupero i dati
            switch (GetParamURL(Request_QueryString, "SqlOperator").ToLower())
            {


                case "like":

                    strSql = $@"select * from " + mp_strTable + $@" where id like '%" + GetParamURL(Request_QueryString, "Value").Replace("'", "''") + $@"%'";
                    break;

                case "liker":

                    strSql = $@"select * from " + mp_strTable + $@" where id like '" + GetParamURL(Request_QueryString, "Value").Replace("'", "''") + $@"%'";
                    break;


                case "likel":

                    strSql = $@"select * from " + mp_strTable + $@" where id like '%" + GetParamURL(Request_QueryString, "Value").Replace("'", "''") + $@"'";
                    break;

                default:

                    if (GetParamURL(Request_QueryString, "SqlOperator") == ">" || GetParamURL(Request_QueryString, "SqlOperator") == "<" || GetParamURL(Request_QueryString, "SqlOperator") == "=")
                    {
                        strSql = "select * from " + mp_strTable + " where id " + GetParamURL(Request_QueryString, "SqlOperator") + "'" + GetParamURL(Request_QueryString, "Value").Replace(@"'", @"''") + @"'";
                    }
                    break;

            }

            strSql = strSql + @" and Lingua='" + mp_Suffix.Replace(@"'", @"''") + @"'";

            rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);

            mp_RetrieveInfo = false;

            if (rs.RecordCount > 0)
            {

                rs.MoveFirst();
                mp_objModel.SetFieldsValue(rs.Fields);

                mp_RetrieveInfo = true;

            }

            mp_objModel.SetFieldValue(GetParamURL(Request_QueryString, "AttribSource"), GetParamURL(Request_QueryString, "Value"));

        }

        public bool checkHackSecurity(Session.ISession session, HttpContext httpContext)
        {

            bool boolToReturn = false;
            bool isAttacked;


            //'-- Controlli di sicurezza
            Security.Validation objSecurityLib = new Security.Validation();

            BlackList mp_objDBBL = new();

            isAttacked = objSecurityLib.validate(session, CStr("Table"), Trim(CStr(mp_strTable)), CInt(1), CInt(1), CStr(""));


            if ((ApplicationCommon.Application["debug-mode"] != "SI") && isAttacked)
            {

                mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(httpContext, session, Const.ATTACK_QUERY_TABLE), session, mp_strConnectionString);

                boolToReturn = true;

                return boolToReturn;


            }
            return boolToReturn;

        }

    }
}
