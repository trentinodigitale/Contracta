using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using System.Web;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.DashBoard
{
	public class Viewer : IViewer
	{
		private IHttpContextAccessor _accessor;
		private HttpContext _context;
		private eProcurementNext.Session.ISession _session;
		public string response;
		private string mp_Suffix;
		private long mp_User;
		private string mp_Permission;
		private string mp_strConnectionString;

		private string mp_AreaAdd;
		private string mp_Caption;
		private Caption mp_objCaption;


		private string mp_strcause;
		private string mp_Table;
		private string[] mp_vetHeight;

		private string mp_AreaUpd;

		private string mp_AreaFiltro;
		private string mp_AreaInfo;
		private string mp_Title;

		private dynamic Request_QueryString; //As Object
		private string mp_AreaFiltroWin;


		private string mp_strTable;
		private string mp_StrToolbar;
		private string mp_ModGriglia;
		private string mp_ModFiltro;
		private string mp_OWNER;
		private string mp_idViewer;
		public IConfiguration configuration;
		private EprocResponse _response;

		private CommonDB.CommonDbFunctions cdf = new();

		public Viewer(IConfiguration configuration, IHttpContextAccessor accessor, eProcurementNext.Session.ISession session)
		{
			this.configuration = configuration;
			this._accessor = accessor;
			//this._context = context
			this._session = session;
			_response = new EprocResponse(GetParamURL(this._accessor.HttpContext.Request.QueryString.ToString(), "XML_ATTACH_TYPE"));
		}

		//public dynamic run(IEprocResponse _response)
		public string run()
		{
			EprocResponse _response = new EprocResponse(GetParamURL(this._accessor.HttpContext.Request.QueryString.ToString(), "XML_ATTACH_TYPE"));

			this._context = this._accessor.HttpContext;

			Dictionary<string, string> JS = new Dictionary<string, string>();
			Window win = new Window();

			// Recupero variabili di sessione
			InitLocal();

			//'-- Controlli di sicurezza 
			if (checkHackSecurity(_session))
			{
				//'Se � presente NOMEAPPLICAZIONE nell'application
				if (!String.IsNullOrEmpty(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]))
				{
					this._context.Response.Redirect("/" + Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp");
					return string.Empty;
				}
				else
				{
					this._context.Response.Redirect($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp");
					return string.Empty;
				}
			}

			mp_objCaption = new Caption();

			HTML_HiddenField(_response, "IDLISTA", GetParamURL(Request_QueryString, "IDLISTA"));

			_response.Write($@"<table class=""height_100_percent width_100_percent""  border=""0"" cellspacing=""0"" cellpadding=""0"">");

			if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "BANNER")))
			{
				_response.Write($@"<tr><td>{ApplicationCommon.CNV(HttpUtility.HtmlEncode(GetParamURL(Request_QueryString, "BANNER")), _session)}");
				_response.Write($@"</td></tr>");
			}

            if (!String.IsNullOrEmpty(mp_Caption))
            {
                if (IsMasterPageNew())
                {
                    _response.Write(@"<tr class=""pageTitle""><td>");
                }
                else
                {
                    _response.Write("<tr><td>");

                }

                if (GetParamURL(Request_QueryString, "ShowExit") == "0")
                {
                    mp_objCaption.ShowExit = false;
                }

				mp_objCaption.Init(_session);
				if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "CaptionNoML")))
				{
					_response.Write($@"{mp_objCaption.SetCaption(Trim(mp_Caption))}");
				}
				else
				{
					string caption = ApplicationCommon.CNV(Trim(mp_Caption), _session);
					_response.Write($@"{mp_objCaption.SetCaption(caption)}");
					//_response.Write($@"{mp_objCaption.SetCaption(CNV(Strings.Trim(mp_Caption), _session, LibDbMultiLanguage.gl_KeyLanguage))}")
				}
				_response.Write($@"</td></tr>");
			}

			if (mp_AreaInfo.ToLower() == "yes" && (!string.IsNullOrEmpty((GetParamURL(Request_QueryString, "INFO_H"))) ? GetParamURL(Request_QueryString, "INFO_H") : (mp_vetHeight[0] != "0")))
			{
				//'-- Invoco il viewerInfo non pi� tramite un iframe ma ne 'sparata' in una div
				_response.Write($@"<tr><td class=""height_100_percent width_100_percent"">");
				_response.Write($@"<div id=""Div_ViewerInfo"" class=""height_100_percent width_100_percent"">");

				ViewerInfo objViewerInfo = new(configuration);
				objViewerInfo.run(_context, _session, _response);
				objViewerInfo = null;

				_response.Write($@"</div>");
				_response.Write($@"</td></tr>");
			}

			if (mp_AreaFiltro.ToLower() != "no")
			{
				ViewerFiltro objViewerFiltro = new ViewerFiltro(_context, _session, _response);

				//'--se richiesto disegno l'area di filtro in una win apri e chiudi
				if (mp_AreaFiltroWin == "1" || mp_AreaFiltroWin == "open" || mp_AreaFiltroWin == "close" || mp_AreaFiltroWin == "hide")
				{
					win.JScript(JS);
					bool filOpen = false;
					if (mp_AreaFiltroWin == "open" || mp_AreaFiltroWin == "hide")
					{
						filOpen = true;
					}

					if (_session["ShowImages"] != "0")
					{
						if (GetParamURL(Request_QueryString, "FiltroWin") != "")
						{
							win.Init("WinFilter", Application.ApplicationCommon.CNV("Filtra", _session), filOpen, CInt(GetParamURL(Request_QueryString, "FiltroWin")));
						}
						else
						{
							win.Init("WinFilter", ApplicationCommon.CNV("Filtra", _session), filOpen, Window.Group);
						}
					}
					else
					{
						win.Init("WinFilter", ApplicationCommon.CNV("Filtra", _session), filOpen, Window.NOIMAGES);
					}

					win.PositionAbsolute = false;
					win.Height = mp_vetHeight[0];
					if (mp_AreaFiltroWin.ToLower() == "hide")
					{
						_response.Write($@"<tr><td id=""Group_WinFilter"" class=""display_none"">");

						win.SubWin = true;
					}
					else
					{
						_response.Write($@"<tr><td id=""Group_WinFilter"">");
					}

					//'-- Invoco il viewerFiltro non pi� tramite un iframe ma ne 'sparata' in una div
					//'Response.Write "<div id=""Div_ViewerFiltro"" class=""height_100_percent width_100_percent"">"
					_response.Write($@"<div id=""Div_ViewerFiltro"" class=""width_100_percent"">");

					objViewerFiltro.run();
					_response.Write($@"</div>");

					_response.Write($@"</td></tr>");

					if (mp_AreaFiltroWin == "hide")
					{
						//'-- nasconde la finestra
						//'Response.Write "<script>setVisibility( getObj( 'Group_Open_WinFilter' ) , 'none' );</script>"
					}
				}
				else
				{
					if (CStr(mp_vetHeight[0]) != "0")
					{
						//'-- Invoco la viwerFiltro non pi� tramite un iframe ma ne 'sparata' in una div
						//'Response.Write "<tr><td class=""height_100_percent width_100_percent"">"
						_response.Write($@"<tr><td class=""width_100_percent"">");

						//'Response.Write "<div id=""Div_ViewerFiltro"" class=""height_100_percent width_100_percent"">"
						_response.Write($@"<div id=""Div_ViewerFiltro"" class=""width_100_percent"">");

						objViewerFiltro.run();
						//Set objViewerFiltro = Nothing

						_response.Write($@"</div>");
						_response.Write($@"</td></tr>");
					}
				}
			}

			if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "CALENDAR")) && GetParamURL(Request_QueryString, "CAL_H") != "0")
			{
				//'-- Invoco il ViewerCalendar non pi� tramite un iframe ma ne 'sparata' in una div
				_response.Write($@"<tr><td class=""height_100_percent width_100_percent"">");
				_response.Write($@"<div id=""Div_ViewerCalendar"" class=""height_100_percent width_100_percent"">");

				ViewerCalendar objViewerCalendar = new ViewerCalendar(configuration, _context, _session, _response);
				objViewerCalendar.run(_response);

				_response.Write($@"</div>");
				_response.Write($@"</td></tr>");
			}

			if (string.IsNullOrEmpty(GetParamURL(Request_QueryString, "CENTER_PAGE")))
			{
				if (mp_vetHeight[1] != "0")
				{
					//'-- Invoco il ViewerGriglia non pi� tramite un iframe ma ne 'sparata' in una div
					if (IsMasterPageNew())
					{
						bool isCalendar = !string.IsNullOrEmpty(GetParamURL(Request_QueryString, "CALENDAR")) && GetParamURL(Request_QueryString, "CAL_H") != "0";
						_response.Write($@"<tr><td class=""height_100_percent width_100_percent {(isCalendar ? "CalendarFaseII" : "")}"">");
					}
					else
					{
						_response.Write($@"<tr><td class=""height_100_percent width_100_percent"">");
					}

					_response.Write($@"<div id=""Div_ViewerGriglia"" class=""height_100_percent width_100_percent"">");

					ViewerGriglia objViewerGriglia = new ViewerGriglia(configuration, _context, _session, _response);
					objViewerGriglia.run(_response);

					_response.Write($@"</div>");
					_response.Write($@"</td></tr>");
				}
			}
			else
			{
				_response.Write($@"{HTML_iframeTR("ViewerGriglia", mp_vetHeight[1], $@"{GetParamURL(Request_QueryString, "CENTER_PAGE")}?{Request_QueryString}", 1, @"scrolling=""no""")}");
			}

			if (mp_AreaAdd.ToLower() != "no")
			{
				if (GetParamURL(Request_QueryString, "AreaAddWin") == "1")
				{
					//string pippo = _response.Out()
					win.JScript(JS);

					if (_session["ShowImages"] != "0")
					{
						win.Init("WinAdd", ApplicationCommon.CNV("ADD_AREA", _session), false, Window.Group);
					}
					else
					{
						win.Init("WinAdd", ApplicationCommon.CNV("ADD_AREA", _session), false, Window.NOIMAGES);
					}

					win.PositionAbsolute = false;
					win.Height = mp_vetHeight[2];
					_response.Write($@"<tr><td width=""100%"">");
					win.Html(_response, HTML_iframe("ViewerAddNew", $"ViewerAddNew.asp?{Request_QueryString}"));
					_response.Write($@"</td></tr>");
					//string pippo2 = _response.Out()
				}
				else
				{
					_response.Write($@"{HTML_iframeTR("ViewerAddNew", mp_vetHeight[2], $"ViewerAddNew.asp?{Request_QueryString}")}");
				}
			}

			//'-- se � prevista un'area di aggiornamento specifica
			if (!string.IsNullOrEmpty(mp_AreaUpd))
			{
				_response.Write($@"{HTML_iframeTR(mp_AreaUpd, mp_vetHeight[2], $"{mp_AreaUpd}.asp?{Request_QueryString}")}");
			}

			_response.Write($@"</table>");

			//'--inserisco il frame per i comandi
			_response.Write($@"{HTML_iframe("Viewer_Command", "../ctl_library/loading.html", 0, @" style=""display:none"" ")}");
			ActiveExtendedAttrib Ext = new ActiveExtendedAttrib();
			Ext.Html(_response);

			return _response.Out();
		}

		public void InitLocal()
		{
			mp_Permission = CStr(_session["Funzionalita"]);

			string mp_Suffix = CStr(_session[SessionProperty.SESSION_SUFFIX]);

			if (string.IsNullOrEmpty(mp_Suffix))
			{
				mp_Suffix = "I";
			}
			try
			{
				mp_User = Convert.ToInt64(_session[SessionProperty.SESSION_USER]);
			}
			catch
			{
			}

			//mp_strConnectionString = configuration.GetConnectionString("DefaultConnection")

			Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);

			mp_Caption = GetParamURL(Request_QueryString, "Caption");
			mp_Table = GetParamURL(Request_QueryString, "Table");
			mp_AreaAdd = GetParamURL(Request_QueryString, "AreaAdd");
			mp_AreaUpd = GetParamURL(Request_QueryString, "AreaUpd");
			mp_AreaFiltro = GetParamURL(Request_QueryString, "AreaFiltro");
			mp_AreaInfo = GetParamURL(Request_QueryString, "AreaInfo");
			mp_Title = GetParamURL(Request_QueryString, "Title");

			string strHeight = GetParamURL(Request_QueryString, "Height");
			strHeight = Replace(strHeight, "*", "%");
			if (string.IsNullOrEmpty(strHeight))
			{
				strHeight = "160,100%,440";
			}

			mp_vetHeight = Strings.Split(strHeight, ",");

			mp_AreaFiltroWin = GetParamURL(Request_QueryString, "AreaFiltroWin");

			//'-- azzero un precedente filtro dei dati conservato in sessione
			mp_strTable = GetParamURL(Request_QueryString, "Table");
			mp_StrToolbar = GetParamURL(Request_QueryString, "TOOLBAR");
			mp_ModGriglia = GetParamURL(Request_QueryString, "ModGriglia");
			if (string.IsNullOrEmpty(mp_ModGriglia))
			{
				mp_ModGriglia = $"{mp_strTable}Griglia";
			}
			if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "ModelloFiltro")))
			{
				mp_ModFiltro = GetParamURL(Request_QueryString, "ModelloFiltro");
			}
			else
			{
				mp_ModFiltro = $"{mp_strTable}Filtro";
			}
			mp_OWNER = GetParamURL(Request_QueryString, "OWNER");
			mp_idViewer = $"{mp_ModGriglia}_{mp_ModFiltro}_{mp_strTable}_{mp_OWNER}_{mp_StrToolbar}";

			//'-- Se non sto provenendo dalle molliche di pane
			//if (Strings.LCase(cstr(GetParamURL(Request_QueryString, "brcrumb"))) != "yes") <-- modifca sorgenti come da segnalazione di Federico

			//'-- Aggiunto anche il controllo della QS per evitare di perdere il filtro quando esegue un processo
			if (LCase(GetParamURL(Request_QueryString, "brcrumb")) != "yes" && _session["mp_idViewer" + "_location"] != CStr(Request_QueryString)) // || ApplicationCommon.Application["ACCESSIBLE"].ToUpper() != "YES")
			{
				_session[mp_idViewer] = "";
				_session[$"{mp_idViewer}_CALENDAR"] = "";
				_session[$"{mp_idViewer}_DATA_CALENDAR"] = "";
			}
		}

		// GetNumNotRead commentata: usata solo in RefreshNumMsg.asp

		//Attenzione, nel caso in cui si dovesse usare la seguente funzione OCCHIO ai return
		public int GetNumNotRead(string paramurl, dynamic session)
		{
			string[] arr;
			dynamic arr2;
			dynamic mp_strcause;
			dynamic FilterHide;

			InitLocal();
			arr = paramurl.Split('?');

			if (UCase(arr[0]) != "DASHBOARD/VIEWER.ASP")
			{
				mp_strcause = "Errore:parametro viewer non presente";
				return mp_strcause;
			}

			string OWNER = GetParamURL(paramurl, "OWNER");
			FilterHide = GetParamURL(paramurl, "FILTERHIDE");
			string NOTREAD = GetParamURL(paramurl, "NOTREAD");
			string TABLE = GetParamURL(paramurl, "TABLE");

			if (string.IsNullOrEmpty(OWNER) || string.IsNullOrEmpty(NOTREAD) || string.IsNullOrEmpty(TABLE))
			{
				mp_strcause = "Errore:nei parametri ";
				return mp_strcause;
			}

			int count = 0;
			if (string.IsNullOrEmpty(FilterHide))
			{
				FilterHide = "";
			}

			count = cdf.GetRSCountNotRead(configuration, CStr(OWNER), CLng(mp_User), CStr(TABLE), "", CStr(FilterHide), CStr(mp_strConnectionString));

			return count;
		}

		public bool checkHackSecurity(Session.ISession session)
		{
			BlackList mp_objDB = new BlackList();

			//dynamic attackerInfo = null

			bool result = false;  // valore che la funzione restituisce

			if (!mp_objDB.isDevMode() && !Basic.isValid(mp_Table, 1))
			{
				mp_objDB.addIp(mp_objDB.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
				result = true;
				return result;
			}

			if (!mp_objDB.isDevMode() && (mp_objDB.isOwnerObblig(mp_Table) && String.IsNullOrEmpty(mp_OWNER)))
			{
				mp_objDB.addIp(mp_objDB.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_OWNER), session, mp_strConnectionString);
				result = true;
				return result;
			}

			string FilterHide = string.Empty;
			FilterHide = GetParamURL(Request_QueryString, "FilterHide");

			if (!mp_objDB.isDevMode() && (!Basic.isValidaSqlFilter(FilterHide, mp_strConnectionString)))
			{
				mp_objDB.addIp(mp_objDB.getAttackInfo(_context, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), session, mp_strConnectionString);
				result = true;
				return result;
			}

			return result;
		}

		#region "VB6 non convertito"
		//Public Function isValidParam(strvalue As String, tipo As Integer, Optional strRegExp As String, Optional ignoreCase As Boolean = True) As Boolean
		//    isValidParam = isValid(strvalue, tipo, strRegExp, ignoreCase, mp_strConnectionString)
		//End Function

		//Public Function isValidFilterSql(ByVal strFilter As String) As Boolean
		//    isValidFilterSql = isValidSqlFilter(strFilter, mp_strConnectionString)
		//End Function
		#endregion
	}
}
