using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor.ViewComponents
{
    public class HeadersViewComponent : ViewComponent
    {
        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;

        private Model.CommonHeaders headers;
        public HeadersViewComponent(IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;

            HttpContext context = this._accessor.HttpContext;

            LoadSession(context, _session);
            headers = new Model.CommonHeaders();
            headers.path_root = context.Request.Path;
            headers.session["GROUPS_NAME"] = "";
            headers.session["strMnemonicoMP"] = "";
            headers.session["STRURLPARTECIPA"] = "";
            headers.session["PATH_STYLE"] = "";
            headers.session["idpfu"] = "";
            headers.session["IDAZI"] = "";
            headers.session["OPEN_ID_TOKEN"] = "";

            headers.application["ACCESSIBLE"] = "";
            headers.application["SITO_ISTITUZIONALE_CLIENTE"] = "";
            headers.application["VERSIONE_AFLINK"] = "";
            headers.application["ATTIVA_FASE_DI_TEST"] = "";
            headers.application["AVVISO_SESSIONE_MINUTI"] = "60";
            headers.application["NOMEAPPLICAZIONE"] = "";
            headers.application["LoadFromFrame"] = "";
            headers.application["SINGLEWIN"] = "";
            headers.application["OPENID_REDIRECT_URI"] = "";
            headers.application["OPENID_URL_LOGOUT"] = "";

            string versioneTest = WebUtility.UrlEncode(headers.application["VERSIONE_AFLINK"]);
            headers.versioneAflink = versioneTest == "" ? "0" : versioneTest;

            if (headers.application["ATTIVA_FASE_DI_TEST"].ToString().ToUpper() != "")
            {
                headers.FaseDiTest = @"try {
					        document.onmousedown='if (event.button==2) return false'; 
					        document.oncontextmenu=new Function('return false');
                        }
				        catch(e){}
                    ";
            }

            headers.idPfu = headers.session["idpfu"].ToString();

            if (headers.idPfu == "")
            {
                headers.idPfu = -20;
            }

            headers.idAzi = headers.session["IDAZI"].ToString();
            if (headers.idAzi == "")
            {
                headers.idAzi = -20;
            }


            headers.idToken = headers.session["OPEN_ID_TOKEN"].ToString();

            if (headers.application["OPENID_URL_LOGOUT"].ToString() != "" && headers.idToken != "")
            {

                headers.logoutIAM = headers.application["OPENID_URL_LOGOUT"].ToString();

                if (headers.logoutIAM.indexOf('?') != -1)
                {
                    headers.logoutIAM = headers.logoutIAM + "?";
                }

                headers.logoutIAM = $"{headers.logoutIAM}state=xx123321yyy&id_token_hint={WebUtility.UrlEncode(headers.idToken)}";

                headers.retUrl = headers.application["OPENID_REDIRECT_URI"].ToString();

                if (headers.retUrl != "")
                {
                    headers.logoutIAM = $"{headers.logoutIAM}&post_logout_redirect_uri={WebUtility.UrlEncode(headers.retUrl)}";
                }

            }
        }
        public IViewComponentResult Invoke()
        {
            var item = GetHtmlCode();
            HtmlString menu = new HtmlString(item.ToString());
            headers.headersRows = menu;
            return View(headers);
        }


        private System.Text.StringBuilder GetHtmlCode()
        {

            System.Text.StringBuilder righe = new System.Text.StringBuilder();
            righe.Append(String.Format("<link rel='stylesheet' href='{0}jscript/jquery/jquery-ui.css?v={1}' />", headers.path_root, headers.versioneAflink));
            righe.Append(String.Format("<link rel='icon' href='{0}favicon.ico?v={1}' />", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/checkbrowser.js?v={1}' type=ìtext/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/getObj.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/setClassName.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/Grid/LockedGrid.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/Grid/GetIdSelectedRow.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/PROPERTYSELECTOR/PropertySelector.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/GetPosition.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/Grid/Grid.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/Grid/GetIdRow.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/ExecFunction.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/OpenCloseSubMenu.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/toolbar/toolbar.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/DOCUMENT/document.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/DOCUMENT/sec_Dettagli.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/jscript/DOCUMENT/Sec_Dettagli_AddRow.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_Attach.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_mail.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_Quiz.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_Text.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_TextArea.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_VD.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ck_VN.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/ExtendedAttrib.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/FldDom.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/FldExtDom.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/FldHierarchy.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/SearchDocumentForExtendeAttrib.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/JScript/FIELD/UpdateFieldVisual.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/replaceExtended.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/jscript/jquery/js/jquery-3.6.0.min.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/jscript/jquery/js/jquery-ui.min.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/jscript/jquery.rte.AFS.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/setVisibility.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerDel.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerUpd.js?v={1}' type='text/javascript''></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerDelConfirm.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/Dash_ExecProcess.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerPrint.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerFilter.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/DashBoardOpenFunc.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerExcel.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/ViewerGrigliaXml.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/CubeGrid.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}DASHBOARD/jsapp/Dash_DocCopy.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/jscript/DOCUMENT/Print.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));
            righe.Append(@String.Format("<script src='{0}CTL_LIBRARY/jscript/ScrollPage/ScrollPage.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));


            righe.Append(@String.Format("<script src='{0}CTL_Library/JScript/main.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            righe.Append(@String.Format("<script src='{0}CTL_Library/Chat/chat.js?v={1}' type='text/javascript'></script>", headers.path_root, headers.versioneAflink));

            // Variabili globali
            righe.Append("<script type='text/javascript'>");
            righe.Append($"var singleWin = '{headers.application["SINGLEWIN"]}';");
            righe.Append($"var ApplicationAccessible = '{headers.application["ACCESSIBLE"]}';");
            righe.Append($"var pathRoot = '{headers.path_root}';");
            righe.Append($"var dDateStart = new Date();");
            righe.Append("var BrowseInPage = 1;");
            righe.Append($"var LoadFromFrame = '{headers.application["LoadFromFrame"].ToString().ToUpper()}';");
            righe.Append($"var urlPortale = '/{headers.application["NOMEAPPLICAZIONE"].ToString().ToLower()}';");
            righe.Append($"var urlLogoutIAM = '{headers.logoutIAM}';");
            righe.Append($"var layout = '{WebUtility.HtmlEncode(@Request.Query["lo"].ToString().Replace("'", "\'"))}';");
            righe.Append($"var idpfuUtenteCollegato = {headers.idPfu};");
            righe.Append($"var idaziAziendaCollegata = {headers.idAzi};");
            righe.Append("var start = +new Date(), diff, minutes, seconds;");
            righe.Append($"var minAvvisoSessione = {headers.application["AVVISO_SESSIONE_MINUTI"]} - 1;");

            righe.Append("var avvisaSessione = true;");
            righe.Append("var continuaConteggio = true;");
            //@*@Model.FaseDiTest *@
            righe.Append("</script>");
            return righe;
        }
    }
}

