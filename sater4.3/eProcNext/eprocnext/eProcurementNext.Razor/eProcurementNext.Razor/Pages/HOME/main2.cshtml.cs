using Microsoft.AspNetCore.Mvc;
using System.Net;
using Microsoft.AspNetCore.Mvc.RazorPages;
using EprocNext.Authentication;
using EprocNext.Session;
using Microsoft.AspNetCore.Http;

namespace eProcurementNext.Razor.Pages.HOME
{
    public class main2Model : PageModel
    {

        private EprocNext.Session.ISession _session;
        
        public string versioneAflink { get; set; }
        public string portaleCliente { get; set; }
        public string PATH_STYLE { get; set; }  
        public string layout { get; set; }

        public string title { get; set; }
        public string path_root { get; set; }
        public dynamic idPfu { get; set; }
        public dynamic idAzi { get; set; }
        public dynamic logoutIAM { get; set; }
        public string retUrl { get; set; }
        public dynamic idToken { get; set; }


        private IHttpContextAccessor Accessor;

        //CODICE TEMPORANEO SESSION, APPLICATION DA ELIMINARE
        public  Dictionary<String, dynamic> session = new Dictionary<String, dynamic>();
        public  Dictionary<String, dynamic> application = new Dictionary<String, dynamic>();
        public string FaseDiTest = "";
        public main2Model(EprocNext.Session.ISession mySession, IHttpContextAccessor accessor)
        {
            _session = mySession;
            Accessor = accessor;
            
            HttpContext context = this.Accessor.HttpContext;

            var token = context.User.Claims.First(item => item.Type == "JWT_Token").Value;
            _session.Load(token);
            string email = _session["Email"].ToString();

            path_root = "../";

            session["GROUPS_NAME"] = "";
            session["strMnemonicoMP"] = "";
            session["STRURLPARTECIPA"] = "";
            session["PATH_STYLE"] = "";
            application["ACCESSIBLE"] = "";
            application["SITO_ISTITUZIONALE_CLIENTE"] = "";
            application["VERSIONE_AFLINK"] = "";
            session["idpfu"] = "";
            session["IDAZI"] = "";
            session["OPEN_ID_TOKEN"] = "";

            application["ATTIVA_FASE_DI_TEST"] = "";
            application["AVVISO_SESSIONE_MINUTI"] = "60";
            application["NOMEAPPLICAZIONE"] = "";
            application["LoadFromFrame"] = "";
            application["SINGLEWIN"] = "";
            application["OPENID_REDIRECT_URI"] = "";
            application["OPENID_URL_LOGOUT"] = "";

            string versioneTest = WebUtility.UrlEncode(application["VERSIONE_AFLINK"]);
            versioneAflink = versioneTest == "" ? "0" : versioneTest;

            if (application["ATTIVA_FASE_DI_TEST"].ToString().ToUpper() != "")
            {
                FaseDiTest = @"try {
					        document.onmousedown='if (event.button==2) return false'; 
					        document.oncontextmenu=new Function('return false');
                        }
				        catch(e){}
                    ";
            }

            idPfu = session["idpfu"].ToString();

            if (idPfu == "")
            {
                idPfu = -20;
            }

            idAzi = session["IDAZI"].ToString();
            if (idAzi == "")
            {
                idAzi = -20;
            }


            idToken = session["OPEN_ID_TOKEN"].ToString();

            if (application["OPENID_URL_LOGOUT"].ToString() != "" && idToken != "")
            {

                logoutIAM = application["OPENID_URL_LOGOUT"].ToString();

                if (logoutIAM.indexOf('?') != -1)
                {
                    logoutIAM = logoutIAM + "?";
                }

                logoutIAM = $"{logoutIAM}state=xx123321yyy&id_token_hint={WebUtility.UrlEncode(idToken)}";

                retUrl = application["OPENID_REDIRECT_URI"].ToString();

                if (retUrl != "")
                {
                    logoutIAM = $"{logoutIAM}&post_logout_redirect_uri={WebUtility.UrlEncode(retUrl)}";
                }

            }
            Accessor = accessor;
        }

        public void OnGet()
        {

        }
    }
}
