using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.DashBoard
{
    public class ViewerCommand
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


        private long mp_idDoc;

        private string mp_StrMsgBox;
        private string mp_ICONMSG;
        private string mp_StrMsg;

        private string[] mp_vetId;




        public ViewerCommand(HttpContext httpContext, Session.ISession session, IEprocResponse response)
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
                bool ret;


                //'-- recupero variabili di sessione
                InitLocal(_session);


                
				Response.Write($@"</head><body>" + Environment.NewLine);
				

				//'-- inserisce i java script necessari
				mp_strcause = "inserisce i java script necessari";
                JS.Add("ExecFunction", $@"<script src=""../CTL_Library/jscript/ExecFunction.js"" ></script>");
                JS.Add("getObj", $@"<script src=""../CTL_Library/jscript/getObj.js"" ></script>");


                Response.Write(JavaScript(JS));


                //'-- nel caso di selezione singola si esegue il comando direttamente
                if (mp_vetId.GetUpperBound(0) == 0 && !string.IsNullOrEmpty(GetParamURL(Request_QueryString, "SHOW_MSG_INFO")))
                {

                    ret = ExecuteProcess();

                    //'-- se si � chiesto di visualizzare il messaggio informazione
                    //'-- oppure � un errore
                    if (GetParamURL(Request_QueryString, "SHOW_MSG_INFO") == "yes" || mp_ICONMSG != MSG_INFO.ToString())
                    {


                        //'-- se c'� stato un eccezione di runtime dal processo e non un errore 'funzionale'
                        if (!string.IsNullOrEmpty(CStr(mp_StrMsgBox)) && mp_StrMsgBox.Contains("Numero :", StringComparison.Ordinal))
                        {

                            if (string.IsNullOrEmpty(CStr(ApplicationCommon.Application["dettaglio-errori"])) || CStr(ApplicationCommon.Application["dettaglio-errori"]).ToLower() == "yes")
                            {
                                //mp_StrMsgBox = mp_StrMsgBox;
                            }
                            else
                            {
                                mp_StrMsgBox = CStr(ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", mp_ObjSession) + CStr(DateAndTime.Now));
                            }


                        }


                        Response.Write(ShowMessageBox(mp_StrMsgBox, ApplicationCommon.CNV(mp_StrMsg, mp_ObjSession), "../ctl_library/", CInt(mp_ICONMSG)));


                    }

                    //'-- si invoca il refresch della lista
                    if (ret)
                    {
                        Response.Write($@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);


                        if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "REFRESH_OBJ")))
                        {
                            Response.Write($@"try{{ " + GetParamURL(Request_QueryString, "REFRESH_OBJ") + ".location = " + GetParamURL(Request_QueryString, "REFRESH_OBJ") + $@".location ;}} catch( e ) {{}};" + Environment.NewLine);
                        }
                        else
                        {


                            Response.Write($@"try{{ parent.RefreshContent(); }} catch( e ) {{" + Environment.NewLine);
                            Response.Write($@"try{{ parent.location = parent.location; }} catch( e ) {{}}; }};" + Environment.NewLine);



                        }


                        Response.Write($@"</script>" + Environment.NewLine);
                    }


                }
                else
                { //'-- altrimenti si attiva la maschera per la selezione multipla


                    Response.Write($@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);
                    Response.Write($@"var w = 600;");
                    Response.Write($@"var h = 400;");
                    Response.Write($@"var Left;");
                    Response.Write($@"var Top;");
                    Response.Write($@"Left = (screen.availWidth-w)/2;");
                    Response.Write($@"Top  = (screen.availHeight-h)/2;");
                    if (IsMasterPageNew())
                    {
						Response.Write($@"var isFaseII = true; ");
						Response.Write($@"try{{ ExecFunction( 'ViewerExecProcess.asp?" + Request_QueryString + $@"','self' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h); }} catch( e ) {{}};" + Environment.NewLine);

					}
					else
                    {
					    Response.Write($@"try{{ ExecFunction( 'ViewerExecProcess.asp?" + Request_QueryString + $@"','PROCESS' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h); }} catch( e ) {{}};" + Environment.NewLine);
                    }
                    Response.Write($@"</script>" + Environment.NewLine);


				}

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
            Request_QueryString = GetQueryStringFromContext(_httpContext.Request.QueryString);//session[Session.SessionProperty.RequestQueryString]

            try
            {
                mp_idDoc = CLng(GetParamURL(Request_QueryString, "IDLISTA"));

            }
            catch
            {

            }
            mp_vetId = Strings.Split(GetParamURL(Request_QueryString, "IDLISTA"), "~~~");

        }

        //'-- esegue un processo legato al documento


        private bool ExecuteProcess()
        {


            string[] vP;
            int msgIcon = 0;//TODO questa assegnazione va eliminata e va rivisto il passaggio dei parametri nel DashBoardMod.ExecuteProcess vanno messi dei ref?

            vP = Strings.Split(CStr(GetParamURL(Request_QueryString, "PROCESS_PARAM")), ",");


            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "DOCLISTA")))
            {
                return DashBoardMod.ExecuteProcess(mp_ObjSession, CStr(GetParamURL(Request_QueryString, "DOCLISTA")), CStr(vP[0]), mp_idDoc, mp_User, ref mp_StrMsg, ref msgIcon, ref mp_StrMsgBox, mp_strConnectionString);
            }
            else
            {
                return DashBoardMod.ExecuteProcess(mp_ObjSession, CStr(vP[1]), CStr(vP[0]), mp_idDoc, mp_User, ref mp_StrMsg, ref msgIcon, ref mp_StrMsgBox, mp_strConnectionString);
            }
            //mp_ICONMSG = msgIcon

        }
    }
}
