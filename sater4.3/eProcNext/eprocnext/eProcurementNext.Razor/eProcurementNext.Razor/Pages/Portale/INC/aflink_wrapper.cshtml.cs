using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Primitives;
using Microsoft.VisualBasic;
using System.Net;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.securityModel;

namespace eProcurementNext.Razor.Pages.Portale.INC
{
	public class aflink_wrapperModel : PageModel
	{
		public void OnGet()
		{
		}
		public static async void wrapperPage(string pageToInvoke, EprocResponse htmlToReturn, HttpRequest Request, eProcurementNext.Session.ISession session, HttpContext HttpContext)
		{
			if (CStr(GetParamURL(Request.QueryString.ToString(), "reset_cookie")) == "1")
			{
				session["COOKIE_WRAPPER"] = "";
			}

			string webServerInterno = CStr(ApplicationCommon.Application["WEBSERVERAPPLICAZIONE_INTERNO"]);

			string nomeApp = CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"]);
			string frm_upld_fname = string.Empty;

			int bUploadFile = 0;
			//vbTextCompare --->CompareMethod.Text
			//'-- SE LA PAGINA STA PASSANDO UN FILE ( RICONOSCIUTO DAL PARAMETRO 'ACTION' = 'UPLOAD' IN QUERY STRING ED IL CONTENT TYPE � DI TIPO MULTI PART FORM ADATA
			if (CStr(GetParamURL(Request.QueryString.ToString(), "action")).ToLower() == "upload" && Strings.InStr(1, Request.HttpContext.GetServerVariable("HTTP_CONTENT_TYPE"), "multipart", CompareMethod.Text) == 1)
			{
				string nomeFile = GetParamURL(Request.QueryString.ToString(), "rnd");
				if (!string.IsNullOrEmpty(nomeFile))
				{
					validate("RND", nomeFile, TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_TABLE, "", 0, HttpContext, session);
					bUploadFile = 1;

					//Upload = Server.CreateObject("Persits.Upload.1")
					//Upload.CodePage = 65001
					string directoryLavoro = CStr(ApplicationCommon.Application["PathFolderAllegati"]);
					if (Strings.Right(directoryLavoro, 1) != $@"\")
					{
						directoryLavoro = $@"{directoryLavoro}\";
					}
					//TODO:Verificare uploadFile dalla request.form
					//Upload.OverwriteFiles = False
					//Upload.Save(directoryLavoro)
					//
					var filePath = "";
					if (Request.HasFormContentType)
					{
						foreach (IFormFile file in Request.Form.Files)
						{
							if (file.Length > 0)
							{
								filePath = $"{directoryLavoro}{file.FileName}";

								using Stream fileStream = new FileStream(filePath, FileMode.Create);
								file.CopyTo(fileStream);
							}
						}
					}
					if (Request.HasFormContentType && Request.Form.Files.Count > 0)
					{
						using FileStream ObjFile = System.IO.File.Open(filePath, FileMode.Open);

						string[] fv = Request.Form.Files[0].FileName.Split(@"\");
						string fileOriginal = fv[fv.Length - 1];

						string estensione = Strings.Right(fileOriginal, 3).ToLower();

						if (estensione != "pdf" && estensione != "p7m")
						{
							ObjFile.Close();
							CommonStorage.DeleteFile(Request.Form.Files[0].FileName);
						}
						else
						{

							if (ObjFile.Length > (CDbl(ApplicationCommon.Application["MAX_SIZE_ATTACH"]) * 1024 * 1024))
							{
								ObjFile.Close();
								CommonStorage.DeleteFile(Request.Form.Files[0].FileName);
							}
							else
							{
								frm_upld_fname = nomeFile + "." + estensione;

								if (CommonStorage.ExistsFile(directoryLavoro + frm_upld_fname))
								{
									CommonStorage.DeleteFile(directoryLavoro + frm_upld_fname);
								}
								ObjFile.Close();
								System.IO.File.Move(directoryLavoro + fileOriginal, directoryLavoro + frm_upld_fname);
							}
						}
					}
				}
			}

			var cookieContainer = new CookieContainer();
			string? CookieValue = null;
			if (Request.Cookies.TryGetValue(eProcurementNext.Session.SessionMiddleware.Cookie_Auth_Name, out CookieValue) ||
				Request.Cookies.TryGetValue(eProcurementNext.Session.SessionMiddleware.Cookie_Anon_Name, out CookieValue))
			{
				cookieContainer.Add(new Uri(Request.Scheme + "://" + Request.Host + "/"), new Cookie(eProcurementNext.Session.SessionMiddleware.Cookie_Auth_Name, CookieValue));
			}
			else if (session != null && !string.IsNullOrEmpty(session.SessionIDMinimal))
			{
				CookieValue = session.SessionID;
				cookieContainer.Add(new Uri(Request.Scheme + "://" + Request.Host + "/"), new Cookie(eProcurementNext.Session.SessionMiddleware.Cookie_Auth_Name, CookieValue));

			}
			var handler = new HttpClientHandler() { CookieContainer = cookieContainer };

			HttpClient obj = new HttpClient(handler);

			dynamic noCache = getTimeStamp();
			string page = "";
			string urlToInvoke = "";
			string cookie;

			//'//Controllo se mi � stato chiesto un redirect automatico 
			if (GetParamURL(Request.QueryString.ToString(), "page") != "")
			{
				page = GetParamURL(Request.QueryString.ToString(), "page");
			}
			else
			{
				if (bUploadFile != 1 && !string.IsNullOrEmpty(GetValueFromForm(Request, "hidden_page")))
				{
					page = GetValueFromForm(Request, "hidden_page");
				}
			}
			if (string.IsNullOrEmpty(page))
			{
				urlToInvoke = $"{webServerInterno}/{nomeApp}/{pageToInvoke}";
			}
			else
			{
				bool blockPageRedirect;

				blockPageRedirect = true;
				//'-- CONTROLLO DI SICUREZZA A WHITE LIST
				if (page.ToLower() == "ctl_library/gerarchici.asp")//	'-- per il momento viene passata solo 1 pagina
				{
					blockPageRedirect = false;
				}
				//'-- 	qui aggiungere futuri elementi di white list
				if (blockPageRedirect)
				{
					htmlToReturn.Write("NON CONSENTITO");
					throw new ResponseEndException(htmlToReturn.Out(), HttpContext.Response, "NON CONSENTITO");
				}
				urlToInvoke = $"{webServerInterno}/{nomeApp}/{page}";

			}
			obj.Timeout = Timeout.InfiniteTimeSpan;

			//Questo codice commentato è stato gestito nelle righe successive (form.Add(*))
			//'-- Se il chiamante sta effettuando un upload di un file non verranno pi� recepiti i dati in post ( limite di ASP CLASSIC ).
			//'--		mi verranno quindi passati in query string e qui verranno convertiti in dati in POST, cos� massimizzare la retrocompatibilit� con vecchio wrapper php / joomla
			//if (bUploadFile == 1)
			//{

			//	postData = GetQueryStringFromContext(Request.QueryString) + "&frm_upld_fname=" + frm_upld_fname;

			//	urlToInvoke = urlToInvoke + "?nocache=" + noCache;
			//}
			//else
			//{

			//	urlToInvoke = urlToInvoke + "?nocache=" + noCache + "&" + GetQueryStringFromContext(Request.QueryString);
			//	//'-- aggiungo in post un campo custom per indicare la provenienza

			//	postData = "CUSTOM_CALLBACK=" + UrlEncode(CStr(Request.HttpContext.GetServerVariable("PATH_INFO"))) + "&";
			//	if (Request.HasFormContentType)
			//	{
			//		foreach (var item in Request.Form)
			//		{
			//			postData = postData + item + " = " + UrlEncode(GetValueFromForm(Request, item.Key)) + "&";
			//		}
			//	}

			//}
			//if (!string.IsNullOrEmpty(postData))
			//{
			//	if (Strings.Right(postData, 1) == "&")
			//	{
			//		//'-- tolgo il & finale
			//		postData = Strings.Left(postData, postData.Length - 1);
			//	}


			//}

			//obj.open("POST", urlToInvoke, false);

			HttpResponseMessage responseMessage = null;
			//questi dopo
			string? output = null;
			byte[]? outputByte = null;
			try
			{
				obj.DefaultRequestHeaders.TryAddWithoutValidation("Content-Type", "application/x-www-form-urlencoded");
				//obj.DefaultRequestHeaders.Add("Content-Type", "application/x-www-form-urlencoded");

				//'-- SE NON E' LA PRIMA CHIAMATA CHE EFFETTUA IL WRAPPER, RECUPERO I COOKIE RESTITUITI DALLA PRECEDENTE E LI RIPASSO ( COSI' DA MANTENERE LA SESSIONE DI LAVORO )
				if (!string.IsNullOrEmpty(CStr(session["COOKIE_WRAPPER"])))
				{
					cookie = CStr(session["COOKIE_WRAPPER"]);
					//'response.write "<h1> recupero : " & cookie & "</h1>"
					//setRequestHeader -->DefaultRequestHeaders.Add
					obj.DefaultRequestHeaders.TryAddWithoutValidation("COOKIE", Strings.Left(cookie, InStrVb6(1, cookie, ";") - 1));
				}
				//'if lcase(cstr(request.querystring("action"))) = "upload" then
				//'	response.write "URL_TO_INVOKE:" & urlToInvoke
				//'	response.write "POST_DATA:" & postData
				//'	response.end
				//'end if

				Dictionary<string, string> form = new Dictionary<string, string>();

				if (Request.HasFormContentType)
				{
					foreach (KeyValuePair<string, StringValues> item in Request.Form)
					{
						form.Add(item.Key, GetValueFromForm(Request, item.Key));
					}
				}

				string requestPath = getPathRequest(Request);

				form.Add("CUSTOM_CALLBACK", requestPath);
				form.Add("frm_upld_fname", frm_upld_fname);

				urlToInvoke = urlToInvoke + "?nocache=" + noCache + "&" + Request.QueryString.ToString();

				FormUrlEncodedContent formUrlEncodedContent = new FormUrlEncodedContent(form);

				responseMessage = obj.PostAsync(urlToInvoke, formUrlEncodedContent/*new StringContent(postData)*/).Result;

				//in caso di esito http negativo lanciamo un eccezione con lo status code e l'eventuale output ottenuto
				if (responseMessage == null || !responseMessage.IsSuccessStatusCode)
				{
					if (responseMessage == null)
						throw new Exception("Response null");
					else
						throw new Exception($"ResponseStatusCode: {responseMessage.StatusCode}");
				}

				//	'-- Dobbiamo mantenere la sessione sulla pagina chiamata tra una request e l'altra, recuperando i dati di sessione/cookie che la pagina chiamata ha generato
				if (string.IsNullOrEmpty(CStr(session["COOKIE_WRAPPER"])))
				{
					IEnumerable<string> temp;
					responseMessage.Headers.TryGetValues("Set-Cookie", out temp);
					cookie = temp != null ? temp.First() : "";
					//'response.write "<h1> settaggio : " & cookie & "</h1>"

					session["COOKIE_WRAPPER"] = cookie;

					//'sID = mid(cookie,instr(1,cookie,"=")+1,instr(1,cookie,";")-(instr(1,cookie,"=")+1))
				}
				IEnumerable<string> valore;
				//	'-- SE LA PAGINA MI STA RESTITUENDO UN FILE
				if (responseMessage.Headers.TryGetValues("Content-Type", out valore) && Strings.Left(CStr(valore.First().ToUpper()), 12) == "APPLICATION/")
				{
					outputByte = responseMessage.Content.ReadAsByteArrayAsync().Result;
					//	'size  = obj.getResponseHeader("Content-Length")
				}
				else
				{
					//obj.ResponseText;
					output = responseMessage.Content.ReadAsStringAsync().Result;
				}
			}
			catch (Exception e)
			{
				output = $"wrapperPage().ERRORE NELL'INVOCAZIONE DELLA PAGINA {urlToInvoke} : " + e.ToString();
			}

			if (output != null && outputByte != null)
			{
				htmlToReturn.Write(output);
			}
			else if (outputByte != null)
			{
				htmlToReturn.BinaryWrite(HttpContext, outputByte);
			}
			else
			{
				htmlToReturn.Write(output);
			}
		}
		public static long getTimeStamp()
		{
			DateTime temp = DateTime.ParseExact("01/01/1970 00:00:00", "dd/MM/yyyy HH:mm:ss", null);
			long _getTimeStamp = DateDiff("s", temp, DateTime.Now);
			return _getTimeStamp;
		}
	}
}
