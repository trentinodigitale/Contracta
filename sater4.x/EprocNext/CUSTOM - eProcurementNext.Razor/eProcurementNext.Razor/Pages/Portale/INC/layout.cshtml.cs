using Microsoft.AspNetCore.Mvc.RazorPages;
namespace eProcurementNext.Razor.Pages.Portale.INC
{
    public class layoutModel : PageModel
    {

        public void OnGet()
        {
        }
        /*
		public static string virtualDirectoryPortale = "";
		public static string tsCache = "";
		public static string urlPortale = "";
		public static  void drawLayout(string titlePagina, EprocResponse htmlToReturn, HttpResponse Response, HttpRequest Request)
		{
			//'-- per far funzionare correttamente il bilanciatore di intercenter :
			//'if cstr(Session("AFLINKFIXATION")) = "" then
			//'	AntiFixationInit()
			//'end if
			
			
			drawHtmlHead(titlePagina,htmlToReturn, Response, Request);

			drawBodyHeader(titlePagina, htmlToReturn,Response,Request);

			drawHtmlFooter(htmlToReturn);

		}
		public static void drawHtmlHead(string titlePagina,EprocResponse htmlToReturn,HttpResponse Response,HttpRequest Request)
		{
			//'Response.ContentType = "text/html"

			Response.Headers.TryAdd("Content-Type", "text/html;charset=UTF-8");
			//Response.CodePage = 65001;
			//Response.CharSet = "UTF-8";

			virtualDirectoryPortale = CStr(CStr(Request.HttpContext.GetServerVariable("PATH_INFO").Split("/")[1]));
			//= CStr(split( cstr(Request.ServerVariables("PATH_INFO")), "/" )(1));

			urlPortale = CStr(ApplicationCommon.Application["WEBSERVERPORTALE"]) + "/" + virtualDirectoryPortale + "/index.asp";

			//tsCache = getTimeStamp();

			htmlToReturn.Write("<!DOCTYPE html>");
			htmlToReturn.Write($@"<html lang=""it-it"" dir=""ltr"">");
			htmlToReturn.Write("<head>");
			htmlToReturn.Write($@"<meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />");
			htmlToReturn.Write($@"<meta http-equiv=""X-UA-Compatible"" content=""IE=9""/>");
			htmlToReturn.Write($@"<meta charset=""utf-8"" />");
			htmlToReturn.Write($@"<meta http-equiv=""Content-Type"" content=""text/html;charset=UTF-8""/>");

			htmlToReturn.Write($@"<title>" + HtmlEncode(titlePagina) + "$@</title>");

			htmlToReturn.Write($@"<link href=""/" + virtualDirectoryPortale + $@"/favicon.ico?nocache=" + tsCache + $@""" rel=""shortcut icon"" type=""image/vnd.microsoft.icon"" />");
			htmlToReturn.Write($@"<link href=""/" + virtualDirectoryPortale + $@"/CSS/layout.css?nocache=" + tsCache + $@""" rel=""stylesheet"" />");
			htmlToReturn.Write($@"<link href=""/" + virtualDirectoryPortale + $@"/CSS/template.css?nocache=" + tsCache + $@""" rel=""stylesheet"" />");
			htmlToReturn.Write($@"<link href=""/" + virtualDirectoryPortale + $@"/CSS/general.css?nocache=" + tsCache + $@""" rel=""stylesheet"" />");
			htmlToReturn.Write($@"<link href=""/" + virtualDirectoryPortale + $@"/CSS/personal.css?nocache=" + tsCache + $@""" rel=""stylesheet"" />");
			htmlToReturn.Write($@"<link href=""/" + virtualDirectoryPortale + $@"/CSS/modal.css?nocache=" + tsCache + $@""" rel=""stylesheet"" />");

			htmlToReturn.Write($@"<link rel=""stylesheet"" href=""/" + virtualDirectoryPortale + $@"/CSS/aflink_style.css?nocache=" + tsCache + $@""" type=""text/css"" media=""screen,projection""  />");
			htmlToReturn.Write($@"<link rel=""stylesheet"" href=""/" + virtualDirectoryPortale + $@"/CSS/aflink_style_print.css?nocache=" + tsCache + $@""" type=""text/css"" media=""print"" />");
			htmlToReturn.Write($@"<link rel=""stylesheet"" href=""/" + virtualDirectoryPortale + $@"/CSS/aflink_style_chromefix.css?nocache=" + tsCache + $@""" type=""text/css"" media=""screen,projection"" />");
			htmlToReturn.Write($@"<link rel=""stylesheet"" href=""/" + virtualDirectoryPortale + "$@/CSS/last_style.css?nocache=" + tsCache + $@""" type=""text/css"" />");

			//<link href="//fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet" />
			htmlToReturn.Write("<link href='https://fonts.googleapis.com/css?family=Titillium Web' rel='stylesheet'>");

			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/jui/js/jquery.min.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/jui/js/jquery-noconflict.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/jui/js/jquery-migrate.min.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/jui/js/bootstrap.min.js?nocache=" + tsCache + $@"""></script>");

			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/system/caption.js?nocache=" + tsCache + $@"""></script>");

			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/template.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/system/core.js?nocache=" + tsCache + $@"""></script>");

			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/system/mootools-core.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/system/mootools-more.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script src=""/" + virtualDirectoryPortale + $@"/js/system/modal.js?nocache=" + tsCache + $@"""></script>");

			//<!--[if lt IE 9]><script src="/<%=virtualDirectoryPortale%>/JS/jui/js/html5.js"></script><![endif]-->
			htmlToReturn.Write($@"<script type=""text/javascript"" src=""/" + virtualDirectoryPortale + $@"/js/md_stylechanger.js?nocache=" + tsCache + $@"""></script>");
			htmlToReturn.Write($@"<script>

			jQuery(window).on('load',  function() {{
				new JCaption('img.caption');
			}});

			jQuery(function($) {{
				SqueezeBox.initialize({{}});
				SqueezeBox.assign($('a.modal').get(), {{
				parse: 'rel'
				}});
			}});

			window.jModalClose = function () {{
				SqueezeBox.close();
			}};

			// Add extra modal close functionality for tinyMCE-based editors
			document.onreadystatechange = function () {{
				if (document.readyState == 'interactive' && typeof tinyMCE != 'undefined' && tinyMCE)
				{{
					if (typeof window.jModalClose_no_tinyMCE === 'undefined')
					{{	
						window.jModalClose_no_tinyMCE = typeof(jModalClose) == 'function'  ?  jModalClose  :  false;

						jModalClose = function () {{
						if (window.jModalClose_no_tinyMCE) window.jModalClose_no_tinyMCE.apply(this, arguments);
						tinyMCE.activeEditor.windowManager.close();
						}};
					}}

					if (typeof window.SqueezeBoxClose_no_tinyMCE === 'undefined')
					{{
						if (typeof(SqueezeBox) == 'undefined')  SqueezeBox = {{}};
						window.SqueezeBoxClose_no_tinyMCE = typeof(SqueezeBox.close) == 'function'  ?  SqueezeBox.close  :  false;

						SqueezeBox.close = function () {{
							if (window.SqueezeBoxClose_no_tinyMCE)  window.SqueezeBoxClose_no_tinyMCE.apply(this, arguments);
							tinyMCE.activeEditor.windowManager.close();
						}};
					}}
				}}
			}};

			jQuery(function($){{ $("".hasTooltip"").tooltip({{""html"":"" true"",""container: ""body""}}); }});

		</script>");
			htmlToReturn.Write("</head>");
		}
		public static void drawBodyHeader(string pagina,EprocResponse htmlToReturn, HttpResponse Response, HttpRequest Request)
		{
			htmlToReturn.Write($@"<body class=""site com_content view-featured no-layout no-task itemid-101"">");


			//< !--link accessibilit�-- >
			htmlToReturn.Write($@"<ul class=""skiplinks"">");
			htmlToReturn.Write($@"<li><a href=""#main"" class=""u2"">Vai ai contenuti</a></li>");
			htmlToReturn.Write($@"<li><a href=""#nav"" class=""u2"">Vai al menu</a></li>");
			htmlToReturn.Write("</ul>");


			//< !--Body-- >
			htmlToReturn.Write($@"<div class=""body"">");

			htmlToReturn.Write($@"<div class=""container"">");

			//< !--Header-- >
	
			Draw_Body_Head(htmlToReturn);

			drawBreadCrumb(pagina,htmlToReturn);

			drawMenu(htmlToReturn,Response,Request);
			htmlToReturn.Write($@"<div id=""main"">");
			htmlToReturn.Write($@"<main id=""content"" role=""main"" class=""span9"">");
			//< !--Begin Content-- >

			htmlToReturn.Write($@"<div id=""system-message-container""></div>");

			htmlToReturn.Write($@"<div class=""blog-featured"" itemscope itemtype=""https://schema.org/Blog"">");

			htmlToReturn.Write($@"<div class=""items-leading clearfix"">");
			htmlToReturn.Write($@"<div class=""leading-0 clearfix"" itemprop=""blogPost"" itemscope itemtype=""https://schema.org/BlogPosting"">");

			drawContent(htmlToReturn);
			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</div>");

			//< !--End Content-- >
			htmlToReturn.Write("</main>");

			htmlToReturn.Write("</div>");

			htmlToReturn.Write("</div>");

			htmlToReturn.Write("</div>");
		}
		public static  void drawBodyFooter()
		{

		}
		public static void drawMenu(EprocResponse htmlToReturn, HttpResponse Response, HttpRequest Request)
		{
			htmlToReturn.Write($@"<div class=""row-fluid"" id =""nav"">");
			//< !--Begin Sidebar-- >
			htmlToReturn.Write($@"<div id=""sidebar"" class=""span3"">");
			htmlToReturn.Write($@"<div class=""sidebar-nav"">");
			htmlToReturn.Write($@"<div class=""moduletable"">");
			htmlToReturn.Write($@"<h3>" + ApplicationCommon.CNV("Area Privata") + $@"</h3>");
			htmlToReturn.Write($@"<script type=""text/javascript"">
			function vacio(q) {{ 
			for ( i = 0; i < q.length; i++ ) {{   
					if ( q.charAt(i) != "" "" ) {{
							return true   
					}}   
			}}  
			return false   
			}}  

			function evidenziaCampo(obj)
			{{
				obj.setAttribute(""class"",""txt required fieldError"");
			}}


			function resetCampo(obj)
			{{
				obj.style.background="""";
				obj.setAttribute(""class"",""txt required"");
			}}

			// Tutto il campi completi.   

		   function valida(form) 
		   {{ 
				var totCampiOk = 0;

				try
				{{
					document.getElementById('msg-errore-login').style.display = 'none';
				}}
				catch(e)
				{{
				}}

				if( vacio(document.getElementById('login_idazienda').value) == false) 
				{{   
					evidenziaCampo(document.getElementById('login_idazienda'));
				}} 
				else
				{{
					totCampiOk++;
					resetCampo(document.getElementById('login_idazienda'));
				}}

				if( vacio(document.getElementById('login_username').value) == false) 
				{{   
					evidenziaCampo(document.getElementById('login_username'));
				}} 
				else
				{{   
					resetCampo(document.getElementById('login_username'));
					totCampiOk++;
				}}  	

				if( vacio(document.getElementById('login_password').value) == false) 
				{{   
					evidenziaCampo(document.getElementById('login_password'));
				}}
				else
				{{   
					resetCampo(document.getElementById('login_password'));
					totCampiOk++;
				}} 	

				if (totCampiOk == 3)
				{{
					return true;
				}}
				else
				{{
					document.getElementById('messaggio_errore').innerHTML = ""<b>Attenzione</b>: I campi evidenziati non sono stati compilati correttamente!"";
					return false;  
				}}   	
			}}

			function TomaCampo(obj)
			{{
				document.write (totCampiOK);
			}}


			</script> ");
			htmlToReturn.Write($@"<form name=""form"" action=""/Application/login.asp?redirectback=yes&amp;chiamante=" + urlPortale + $@""" method=""post"" id=""login"" autocomplete=""off"" onSubmit=""return valida(this);"" >");

			htmlToReturn.Write("<div>");

			htmlToReturn.Write($@"<span id=""messaggio_errore"">");
			if (!string.IsNullOrEmpty(GetParamURL(Request.QueryString.ToString(), "Errore")))
			{
				//'--non accettiamo una stringa superiore a 150 caratteri
				//'--o che inizia con "<script". In questo caso non faccio uscire niente a video
				if (GetParamURL(Request.QueryString.ToString(), "Errore").Length < 150 && string.Equals(Strings.Left(GetParamURL(Request.QueryString.ToString(), "Errore"), 7).ToLower(), "<script"))
				{
					htmlToReturn.Write("<strong id='msg-errore-login'>" + HtmlEncode(CStr(GetParamURL(Request.QueryString.ToString(), "Errore"))) + "</strong>");
				}
			}
			htmlToReturn.Write("</span");
			htmlToReturn.Write("</div>");
			htmlToReturn.Write("<div>");
			if (!string.IsNullOrEmpty(ApplicationCommon.Application["URL_LOGIN_SSO"]))
			{
				htmlToReturn.Write($@"<div id=""FORM_LOGIN"" name=""FORM_LOGIN"" >");
			}
			htmlToReturn.Write($@"<label for=""login_idazienda""><" + ApplicationCommon.CNV("Codice di accesso") + "</label>");
			htmlToReturn.Write($@"<input type=""text"" name=""IDAZIENDA"" class=""txt required"" id=""login_idazienda"" style=""""/>");
			htmlToReturn.Write($@"<label for=""login_username"">" + ApplicationCommon.CNV("Nome Utente") + "</label>");
			htmlToReturn.Write($@"<input type=""text"" name=""USERNAME"" class=""txt required"" id=""login_username"" style=""""/>");
			htmlToReturn.Write($@"<label for=""login_password"">" + ApplicationCommon.CNV("Password") + "</label>");
			htmlToReturn.Write($@"<input type=""password"" name=""PASSWORD"" class=""txt required"" id=""login_password"" style=""""/>");
			htmlToReturn.Write($@"<input type=""submit"" value=""" + ApplicationCommon.CNV("Accedi") + $@""" class=""button"" id=""submit1"" name=""submit1""/>");
			if (!string.IsNullOrEmpty(ApplicationCommon.Application["URL_LOGIN_SSO"]))
			{
				htmlToReturn.Write("</div>");
			}
			if (!string.IsNullOrEmpty(ApplicationCommon.Application["URL_LOGIN_SSO"]))
			{
				htmlToReturn.Write($@"<input type=""button"" value=""" + ApplicationCommon.CNV("Accedi con Login SSO") + $@""" class=""button"" id=""submit2"" name=""submit2"" onclick=""document.location='" + ApplicationCommon.Application["URL_LOGIN_SSO"] + $@"'"" />");
			}
			htmlToReturn.Write($@"<input type=""hidden"" name=""strMnemonicoMP"" value=""PA""/>");
			htmlToReturn.Write($@"<input type=""hidden"" value=""1"" name=""strCheckIscrizione""/>");


			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</form>");

			htmlToReturn.Write($@"<div class=""moduletable_menu"">");
			htmlToReturn.Write($@"<ul class=""nav menu"">");

			htmlToReturn.Write($@"<li id=""moduletable_menu_1"" >");
			htmlToReturn.Write($@"<a class=""modal""  rel=""{{handler: 'iframe', size: {{x: 600, y: 400}}""  href=""/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + $@"/modal/recuperopwd_joomla.asp"" title=""Hai dimenticato la password?"">");
			htmlToReturn.Write(ApplicationCommon.CNV("Hai dimenticato la password?") + "</a>");
			htmlToReturn.Write("</li>");

			htmlToReturn.Write($@"<li id=""moduletable_menu_2"" >");
			htmlToReturn.Write($@"<a class=""modal""  rel=""{{handler: 'iframe', size: {{x: 600, y: 400}}"" href=""/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + $@"/modal/recuperouser_joomla.asp"" title=""Hai dimenticato Codice di Accesso e Nome Utente ?"">");
			htmlToReturn.Write(ApplicationCommon.CNV("Hai dimenticato Codice di Accesso e Nome Utente ?") + "</a>");
			htmlToReturn.Write("</li>");

			htmlToReturn.Write($@"<li id=""moduletable_menu_3"" >");
			htmlToReturn.Write($@"<a href=""registrazione_oe.asp"">");
			htmlToReturn.Write($@"<h2>" + ApplicationCommon.CNV("Registrazione Operatore Economico") + $@"</h2></a>");
			htmlToReturn.Write("</li>");

			htmlToReturn.Write($@"<li id=""moduletable_menu_4"" >");

			htmlToReturn.Write($@"<a href=""registrazione_ente.asp"">");
			htmlToReturn.Write("<h2>");
			htmlToReturn.Write(ApplicationCommon.CNV("Registrazione utente P.A."));
			htmlToReturn.Write("</h2>");
			htmlToReturn.Write("</a>");
			htmlToReturn.Write("</li>");

			//'--se richiesto inserisco bottone per accesso SPID

			if (ApplicationCommon.Application["PORTALE_ACCESSO_SPID"].ToUpper() == "YES")
			{
				htmlToReturn.Write(ApplicationCommon.CNV("Portale Punto di Accesso Spid"));
			}

			htmlToReturn.Write("</ul>");

			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</div>");
		//< !--End Sidebar-- >
		}
		public static void drawBreadCrumb(string pagina,EprocResponse htmlToReturn)
		{
			int addItem = 0;
			string extraHtml = $@"class=""active""";

			if (pagina.ToLower() != "home")
			{
				addItem = 1;
				extraHtml = "";
			}
			htmlToReturn.Write($@"<div id=""breadcrumbs"">");
			htmlToReturn.Write("<table>");
			htmlToReturn.Write("<tr>");
			htmlToReturn.Write($@"<td class=""ERLinkTD"">");
			htmlToReturn.Write($@"<ul class=""breadcrumb"">");
			htmlToReturn.Write($@"<li><a href=""" + urlPortale + $@""">" + ApplicationCommon.CNV("Agenzia per lo sviluppo dei mercati telematici") + $@"</a> |</li>");

			htmlToReturn.Write("</ul>");
			htmlToReturn.Write("</td>");
			htmlToReturn.Write("<td>");
			htmlToReturn.Write($@"<div class=""moduletable"">");

			htmlToReturn.Write($@"<ul itemscope itemtype=""https://schema.org/BreadcrumbList"" class=""breadcrumb"">");
			htmlToReturn.Write($@"<li class=""active"">");
			htmlToReturn.Write($@"<span class=""divider icon-location""></span>");
			htmlToReturn.Write("</li>");

			htmlToReturn.Write($@"<li itemprop=""itemListElement"" itemscope itemtype=""https://schema.org/ListItem"" " + extraHtml + ">");
			htmlToReturn.Write($@"<span itemprop=""name"">Home</span>");

			if (addItem == 1)
			{
				htmlToReturn.Write($@"<span class=""divider""><img src=""/" + virtualDirectoryPortale + $@"/images/arrow.png""></span>");
			}
			htmlToReturn.Write($@"<meta itemprop=""position"" content=""1"">");
			htmlToReturn.Write("</li>");

			if (addItem == 1)
			{
				htmlToReturn.Write($@"<li itemprop=""itemListElement"" itemscope="""" itemtype=""https://schema.org/ListItem"" class=""active"">");
				htmlToReturn.Write($@"<span itemprop=""name"">");
				htmlToReturn.Write(pagina);
				htmlToReturn.Write("</span>");
				htmlToReturn.Write($@"<meta itemprop=""position"" content=""2"">");
				htmlToReturn.Write("</li>");
			}
			htmlToReturn.Write("</ul>");
			htmlToReturn.Write("</div>");
			htmlToReturn.Write("</td>");
			htmlToReturn.Write("</tr>");
			htmlToReturn.Write("</table>");
			htmlToReturn.Write("</div>");

		}
		//'--disegna il footer della pagina
		public static void drawHtmlFooter(EprocResponse htmlToReturn)
		{
			string[] COOKIE_BANNER = null;
			if (ApplicationCommon.Application["COOKIE_BANNER"].ToUpper() == "YES")
			{
				//COOKIE_BANNER
				htmlToReturn.Write(COOKIE_BANNER[""]);
			}

			htmlToReturn.Write(ApplicationCommon.CNV("Contenuto html footer portale"));


			htmlToReturn.Write("</body>");
			htmlToReturn.Write("</html>");
		}
		public static void Draw_Body_Head(EprocResponse htmlToReturn)
		{
			htmlToReturn.Write(ApplicationCommon.CNV("Contenuto html head body"));
		}


*/


    }
}
