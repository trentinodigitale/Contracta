
using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{
    public class masterPageToolsModel : PageModel
    {

        public void OnGet()
        {

        }

        //public static string GetParam(string? str, string? param)
        //{
        //    if(str == null || param == null)
        //    {
        //        return "";
        //    }

        //    dynamic ind, a, sa, pa;
        //    sa = Strings.UCase(str);
        //    pa = Strings.UCase(param);
        //    ind = Strings.InStr(1, sa, $"{pa}=");

        //    if (ind > 0)
        //    {
        //        a = Strings.Mid(str, ind + Strings.Len(param) + 1);
        //        ind = Strings.InStr(1, a, "&");
        //        if (ind > 0)
        //        {
        //            a = Strings.Left(a, ind - 1);
        //        }
        //        return a;
        //    }
        //    else
        //    {
        //        return "";
        //    }

        //}




        public static dynamic getStackKey(dynamic key, dynamic url)
        {
            String stack_key = "null";
            switch (Strings.UCase(key))
            {
                case "DOCUMENT":
                    stack_key = $"{GetParam(url, "document")}_{GetParam(url, "IDDOC")}";
                    break;

                case "VIEWER":
                    stack_key = $"{GetParam(url, "ModGriglia")}_{GetParam(url, "ModelloFiltro")}_{GetParam(url, "Table")}_{GetParam(url, "OWNER")}_{GetParam(url, "TOOLBAR")}";
                    break;

                case "MAIN":
                    stack_key = "MAIN";
                    break;

                case "PRN_DOC_PORTALE":
                    stack_key = $"{GetParam(url, "document")}_{GetParam(url, "IDDOC")}";
                    break;

                case "REPORT":
                    stack_key = $"{GetParam(url, "TYPEDOC")}_{GetParam(url, "IDDOC")}";
                    break;

                case "GROUP_VIEW":
                    stack_key = "_FITTIZIO_";
                    break;

                default:
                    //Response.Write("ENTITA RICHIESTA DA IMPLEMENTARE PER LO STACK")
                    //Response.end
                    break;
            }

            return stack_key;
        }

        public static HtmlString drawContent()
        {
            return new HtmlString(@"
            <table width=""100%"" class=""Caption"" border=""0"" cellspacing=""0"" cellpadding=""0""><tbody><tr><td>Centrale Acquisti</td></tr></tbody></table>

                <script type=""text/javascript"">
                    document.cookie = ""openGroup=;"";
                </script >

            <div id=""access_div_splash_masterpage"" class=""access_div_splash_masterpage"">
            </div>");
        }


        public static HtmlString drawLogo(String path)
        {
            return new HtmlString($@"<img alt=""logo"" src=""{path}images/logo-er.png""/>");
        }

        public static string addZero(dynamic str)
        {
            if (str != "")
            {
                if (CInt(str) <= 9)
                {
                    return $@"0{str}";
                }
                else
                {
                    return str;
                }
            }
            else
            {
                return str;
            }
        }


        public static void stackUpdateCurrentPosition(string key, string url, string title, eProcurementNext.Session.ISession _session, HttpContext _context)
        {
            //if (_session["stack_path"] == null || string.IsNullOrEmpty(url.Trim())) 
            //    return;

            if (string.IsNullOrEmpty(url.Trim()))
                return;

            string lo = GetParamURL(url.Substring(url.IndexOf("?", StringComparison.Ordinal)), "lo");

            // --se sto aggiornando l'ultima posizione dello stack con un layout non coerente. esco senza lavorare lo stack
            if (UCase(lo) != "BASE" && UCase(lo) != "LISTA_ATTIVITA")
            {
                return;
            }
            dynamic[,] mp_stackMatrix;
            // -- non c'era ancora l'oggetto in sessione quindi lo creo e poi lo carico
            if (_session["stack_path"] == null)
            {
                mp_stackMatrix = new dynamic[50, 4];
            }
            else
            {
                mp_stackMatrix = _session["stack_path"];
            }
            int posCorrente = CInt(_session["stack_index"]);

            dynamic stack_key = getStackKey(key, url);

            // -- se stiamo inserendo nello stack una chiamata di tipo document
            // -- ricomponiamo l'url da inserire nello stack per permettere sempre l'apertura
            // -- del documento ed evitare che si ri-eseguano processi o operazioni non volute
            if (UCase(key) == "DOCUMENT")
            {
                dynamic tmpUrl = $"ctl_library/document/userdocument.asp?MODE=SHOW&lo={GetParam(url, "lo")}&JScript={GetParam(url, "JScript")}";
                tmpUrl = $"{tmpUrl}&DOCUMENT={GetParam(url, "DOCUMENT")}&IDDOC={GetParam(url, "IDDOC")}";
                url = tmpUrl;
            }


            mp_stackMatrix[posCorrente, 0] = stack_key;
            mp_stackMatrix[posCorrente, 1] = url;
            mp_stackMatrix[posCorrente, 2] = title;
            mp_stackMatrix[posCorrente, 3] = key;

            // -- aggiorno la sessione con lo stack aggiornato
            _session["stack_index"] = posCorrente;
            _session["stack_path"] = mp_stackMatrix;
            _session.Save();

            #region /api/v1/UserHistory/Add

            if (IsMasterPageNew())
            {
				string breadCrumb = "";
				for (int i = 0; i < posCorrente + 1; i++)
				{
					bool skip;
					try
					{
						if (i == 0)
						{
							skip = mp_stackMatrix[0, 3] == "main" && mp_stackMatrix[0, 2] == mp_stackMatrix[1, 2] && mp_stackMatrix[0, 3] == mp_stackMatrix[1, 3];
						}
						else
						{
							skip = false;
						}
					}
					catch
					{
						skip = false;
					}
					if (skip)
					{
						continue;
					}
					breadCrumb += ApplicationCommon.CNV(CStr(mp_stackMatrix[i, 2])) + ((i == posCorrente) ? "" : " > ");
				}


				if (_context.Request.PathBase.Value != null)
                {
                    if (_context.Request.PathBase.Value != "")
                    {
                        url = _context.Request.PathBase.Value.ToString().Replace("/", "") + "/" + url;
                    }

                }
                else if (ApplicationCommon.Application["NOMEAPPLICAZIONE"] != null && ApplicationCommon.Application["NOMEAPPLICAZIONE"] != "")
                {
                    url = ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/" + url;
                }

                if (url.ToLower().Contains("lo=lista_attivita"))
                {
                    return;
                }

                if(title == "Home_breadcrumb")
                {
                    title = ApplicationCommon.CNV("Dashboard");
                    if (string.IsNullOrEmpty(title) || (title.StartsWith("???") && title.EndsWith("???")))
                    {
                        title = "Home";
                    }
                }

                var json = JsonSerializer.Serialize(new
                {
                    Link = url,
                    Title = title,
                    Breadcrumb = breadCrumb,
                    Date = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss"),
                    IsFavorite = false
                });
                var data = new StringContent(json, Encoding.UTF8, "application/json");
                string? CookieValue;
                _context.Request.Cookies.TryGetValue(eProcurementNext.Session.SessionMiddleware.Cookie_Auth_Name, out CookieValue);
                using var client = new HttpClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", CookieValue);
                string uri = "";
                try
                {
                    uri = ConfigurationServices.GetKey("WebApiServer", "") + "/api/v1/UserHistory/Add";
                    DebugTrace dt = new DebugTrace();
                    dt.Write($@"stackUpdateCurrentPosition ConfigurationServices.GetKey(""WebApiServer"", """"):" + ConfigurationServices.GetKey("WebApiServer", "") + " |||||| ");
                    dt.Write($@"stackUpdateCurrentPosition uri:" + uri + " |||||| ");
                    if (!Uri.IsWellFormedUriString(uri, UriKind.Absolute))
                    {
                        dt.Write($@"stackUpdateCurrentPosition if (!Uri.IsWellFormedUriString(uri, UriKind.Absolute)):");
                        dt.Write($@"stackUpdateCurrentPosition WEBSERVERAPPLICAZIONE_INTERNO:" + ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + " |||||| ");
                        uri = ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"] + uri;
                        dt.Write($@"stackUpdateCurrentPosition uri:" + uri + " |||||| ");
                    }
                    var result = client.PostAsync(uri, data).Result.Content.ReadAsStringAsync();
                    dt.Write($@"stackUpdateCurrentPosition uri:" + uri + " |||||| ");
                    dt.Write($@"stackUpdateCurrentPosition: " + result.Result + " |||||| " + json.ToString() + "|" + "" + "|");
                }
                catch(Exception ex)
                {
					DebugTrace dt = new DebugTrace();
                    dt.Write($@"stackUpdateCurrentPosition uri:" + uri + " |||||| ");
                    dt.Write($@"stackUpdateCurrentPosition Exception: " + ex + " |||||| ");
				}
            }

            #endregion

        }

        public static void popBreadCrumb(string pathRoot, eProcurementNext.Session.ISession _session, HttpResponse response)
        {

            if (IsEmpty(_session["stack_path"]))
            {
                return;
            }
            dynamic[,] mp_stackMatrix;

            mp_stackMatrix = _session["stack_path"];
            int posCorrente = CInt(_session["stack_index"]);

            _session["stack_index"] = posCorrente - 1;

            throw new ResponseRedirectException(pathRoot + CStr(mp_stackMatrix[posCorrente - 1, 1]), response);

        }

        public static void toBreadCrumb(string pathRoot, int livelli, eProcurementNext.Session.ISession _session, HttpResponse response)
        {

            if (IsEmpty(_session["stack_path"]))
            {
                return;
            }
            dynamic[,] mp_stackMatrix;
            mp_stackMatrix = _session["stack_path"];
            int posCorrente = CInt(_session["stack_index"]);

            response.Redirect(pathRoot + mp_stackMatrix[posCorrente - livelli, 1]);

        }

        public static HtmlString drawTitle(eProcurementNext.Session.ISession session)
        {
            return new HtmlString($@"
            <div class=""right"" id=""main_top_right_div"">

				<div class=""main_top_1"">
						<ul class=""ul_main_top_elements"">
							<li class=""li_main_top_element_Title"">
								" + ApplicationCommon.Application["NOMEPORTALE"] + $@"
							</li>
							<li class=""li_main_top_element_RagSociale"">
								<strong> " + ApplicationCommon.CNV("Azienda") + $@": </strong>
				                " + (!string.IsNullOrEmpty(CStr(session["RagSociale"])) ? $@"<span>" + HtmlEncode(session["RagSociale"]) + $@"</span>" : "") + $@"

							</li>	
							<li class=""li_main_top_element_UserName"">
								<strong>" + ApplicationCommon.CNV("Utente") + $@": </strong> 
				                " + (!string.IsNullOrEmpty(CStr(session["UserName"])) ? $@"<span>" + HtmlEncode(session["UserName"]) + $@"</span>" : "") + $@"

							</li>
							<li class=""li_main_top_element_logout last"">
									<a href=""#logout"" onclick=""logout();"" class=""link_logout""><strong>" + ApplicationCommon.CNV("Logout") + $@"</strong></a>
							</li>
						</ul>
					</div>

			</div>");
        }

    }
}
