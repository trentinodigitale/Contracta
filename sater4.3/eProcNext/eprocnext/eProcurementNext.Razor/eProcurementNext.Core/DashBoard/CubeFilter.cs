using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;


namespace eProcurementNext.DashBoard
{
	public class CubeFilter
	{
		private dynamic mp_ObjSession; //'-- oggetto che contiene il vettore base con gli elementi della libreria

		private string mp_Suffix = string.Empty;
		private long mp_User = 0;
		private string mp_Nome = string.Empty;
		private string mp_Cognome = string.Empty;
		private string mp_Permission = string.Empty;
		private string mp_strConnectionString = string.Empty;

		private Form mp_objForm = new Form();
		private Model mp_objModel = new Model();
		private ButtonBar mp_ObjButtonBar = new ButtonBar();
		private Fld_Label mp_objCaption = new Fld_Label();
		private string mp_strModelloFiltro = string.Empty;

		//'private mp_Columns As Collection
		//'private mp_ColumnsProperty As Collection

		private LibDbModelExt mp_objDB; 


		private string mp_strcause = string.Empty;
		private string mp_strTable = string.Empty;
		private string mp_queryString = string.Empty;

		private string Request_QueryString = string.Empty;
		private IFormCollection Request_Form;
		private string mp_strAutoSel = string.Empty;
		private string mp_Filter = string.Empty;
		private string mp_strStoredSQL = string.Empty;
		private string mp_LockFiltered = string.Empty;

		private string mp_accessible = string.Empty;

		private HttpContext? _context;
		private eProcurementNext.Session.ISession? _session;
		private IEprocResponse? _response;
		public IConfiguration configuration;

		public CubeFilter(HttpContext httpContext, Session.ISession session, IEprocResponse response)
		{
			_context = httpContext;
			_session = session;
			_response = response;
		}

		public string run(IEprocResponse _response)
		{
			Dictionary<string, string> JS = new Dictionary<string, string>();

			// TODO  On Error GoTo HError

			//'-- recupero variabili di sessione
			InitLocal();

			//'-- Controlli di sicurezza
			if (checkHackSecurity(_context, _session))
			{
				//'Se � presente NOMEAPPLICAZIONE nell'application
				if (!string.IsNullOrEmpty(CStr(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
				{
					_context.Response.Redirect("/" + Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp");
					return null;
				}
				else
				{
					_context.Response.Redirect("/application/blocked.asp");
					return null;
				}

			}

			//'-- Inizializzo gli oggetti dell'interfaccia
			InitGUIObject();

			//'----------------------------------
			//'-- avvia la scrittura della pagina
			//'----------------------------------


			_response.Write(@"<table class=""width_100_percent""");
			_response.Write(@" border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td>");


			//'-- apre il form di ricerca
			_response.Write(mp_objForm.OpenForm());

			//If UCase(session(OBJAPPLICATION)("ACCESSIBLE")) <> "YES" Then
			//    Response.Write "<table width=""100%"" height=""100%"""
			//Else
			//'Response.Write "<table class=""height_100_percent width_100_percent"""
			_response.Write(@"<table class=""width_100_percent""");
			//End If

			_response.Write(@" border=""0"" cellspacing=""0"" cellpadding=""0"">");



			if (GetParamURL(Request_QueryString, "HIDEBUTTON").ToLower() != "yes")
			{
				_response.Write("<tr><td >" + Environment.NewLine);

				//If UCase(session(OBJAPPLICATION)("ACCESSIBLE")) <> "YES" Then
				//        Response.Write "<table width=""100%"" height=""100%"""
				//    Else
				_response.Write(@"<table class=""width_100_percent""");
				//End If


				_response.Write(@" border=""0"" cellspacing=""0"" cellpadding=""0"">" + Environment.NewLine);
				_response.Write("<tr><td>" + Environment.NewLine);


				//'-- aggiungo la caption all'area
				mp_objCaption.Html(_response);



				_response.Write("</td><td >" + Environment.NewLine);


				//'-- disegna la toolbar
				mp_ObjButtonBar.Html(_response);

                
                _response.Write("</td></tr>" + Environment.NewLine);
                _response.Write("</table>" + Environment.NewLine);
                _response.Write("</td></tr>" + Environment.NewLine);
            }


			//'-- disegna il modello di ricerca
			mp_strcause = "disegna il modello di ricerca";
			_response.Write(@"<tr><td width=""100%"" >");
			mp_objModel.Html(_response);
			_response.Write("</td></tr>");

            if (IsMasterPageNew())
            {
                _response.Write(@"<tr><td class=""rowButtonsFaseII"">" + Environment.NewLine);
                mp_ObjButtonBar.Html(_response);
                _response.Write(@"</td></tr>" + Environment.NewLine);
            }
            else
            {

            }

            _response.Write("</table>");


			//'-- chiude il form di ricerca
			_response.Write(mp_objForm.CloseForm());

			_response.Write(@"</td></tr><tr>");

            _response.Write(@"<td height=""100%""></td></tr></table>");

			//Set JS = Nothing

			//TODO
			//    Exit Function


			//HError:

			//            Set JS = Nothing
			//    RaiseError mp_strcause

			return _response.Out();

		}

		private void InitLocal()
		{
			mp_ObjSession = _session;

			// TODO On Error Resume Next

			mp_accessible = CStr(Application.ApplicationCommon.Application["ACCESSIBLE"]);

			mp_Suffix = CStr(_session["SESSION_SUFFIX"]);
			if (string.IsNullOrEmpty(mp_Suffix)) { mp_Suffix = "I"; }

			mp_strConnectionString = Application.ApplicationCommon.Application.ConnectionString; // _session["SESSION_CONNECTIONSTRING"];
			Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
			Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;

			mp_User = CInt(_session[SessionProperty.SESSION_USER]);
			mp_Permission = CStr(_session[SessionProperty.SESSION_PERMISSION]);
			mp_Nome = CStr(_session["SESSION_NOME"]);
			mp_Cognome = CStr(_session["SESSION_COGNOME"]);

			mp_strAutoSel = UCase(GetParamURL(Request_QueryString, "AUTO"));

			mp_strTable = GetParamURL(Request_QueryString, "Table");
			mp_strModelloFiltro = GetParamURL(Request_QueryString, "ModelloFiltro");
			if (string.IsNullOrEmpty(mp_strModelloFiltro)) { mp_strModelloFiltro = mp_strTable + "Filtro"; }

			mp_queryString = "&ClearNew=" + GetParamURL(Request_QueryString, "ClearNew") + "&CaptionAdd=" + GetParamURL(Request_QueryString, "CaptionAdd") + "&CaptionUpd=" + GetParamURL(Request_QueryString, "CaptionUpd") + "&RowForPage=" + GetParamURL(Request_QueryString, "RowForPage") + "&IDENTITY=" + GetParamURL(Request_QueryString, "IDENTITY");
			mp_Filter = GetParamURL(Request_QueryString, "Filter");
			mp_strStoredSQL = "";
			if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "STORED_SQL")))
			{
				mp_strStoredSQL = GetParamURL(Request_QueryString, "STORED_SQL");
			}
			mp_LockFiltered = GetParamURL(Request_QueryString, "L_F");
		}

		//'-- inizializzo gli oggetti dell'interfaccia
		private void InitGUIObject()
		{
			string strFilter = string.Empty;
			dynamic v;
			dynamic p;
			int i = 0;

			bool sessionFilter = false;

			//mp_objForm = new Form();
			//mp_objModel = new Model();
			//ButtonBar mp_ObjButtonBar = new ButtonBar();

			//'-- inizializzo il form
			mp_objForm.id = "FormViewerFiltro";

			dynamic tmpVet;
			string mp_StrToolbar = string.Empty;
			string mp_idViewer = string.Empty;
			//bool sessionFilter = false
			string tempQS = string.Empty;

			mp_StrToolbar = GetParamURL(Request_QueryString, "TOOLBAR");
			//sessionFilter = false

			tmpVet = mp_StrToolbar.Split(",");
			if (tmpVet.GetUpperBound(0) > 0)
			{
				mp_StrToolbar = tmpVet[0];
			}

			mp_idViewer = CStr(GetParamURL(Request_QueryString, "ModGriglia")) + "_" + CStr(mp_strModelloFiltro) + "_" + CStr(mp_strTable) + "_" + CStr(GetParamURL(Request_QueryString, "OWNER")) + "_" + CStr(mp_StrToolbar);

			if (!string.IsNullOrEmpty(CStr(mp_ObjSession[mp_idViewer])))
			{
				mp_Filter = mp_ObjSession[mp_idViewer];
				sessionFilter = true;
			}

			tempQS = Request_QueryString;


			tempQS = MyReplace(tempQS, "MODE=Filtra&", "");
			tempQS = MyReplace(tempQS, "&nPag=" + GetParamURL(Request_QueryString, "nPag"), "");


			tempQS = MyReplace(tempQS, "&Filter=" + URLEncode(GetParamURL(Request_QueryString, "Filter")), "");
			tempQS = MyReplace(tempQS, "&Filter=" + GetParamURL(Request_QueryString, "Filter"), "");



			tempQS = tempQS + "&Filter=" + URLEncode(mp_Filter);


			mp_objForm.Action = "Cube.asp?MODE=Filtra&amp;" + HtmlEncode(CStr(tempQS));


			//'-- barra dei bottoni
			mp_ObjButtonBar.CaptionSubmit = Application.ApplicationCommon.CNV("Filtra", mp_ObjSession);
			mp_ObjButtonBar.CaptionReset = Application.ApplicationCommon.CNV("Pulisci", mp_ObjSession);



			mp_ObjButtonBar.id = "ViewerFiltro";



			mp_ObjButtonBar.OnSubmit = GetParamURL(Request_QueryString, "ONSUBMIT");



			//'-- inizializzo la caption
			mp_strcause = "inizializzo la caption";
			//Fld_Label mp_objCaption = new Fld_Label();

			mp_objCaption.Style = "SinteticHelp";
			mp_objCaption.Value = Application.ApplicationCommon.CNV("Filtra il contenuto della griglia", mp_ObjSession);
			mp_objCaption.Image = "Filter.gif";

			//'-- recupero il modello di ricerca
			mp_strcause = "recupero il modello di ricerca";
			//Set mp_objDB = CreateObject("ctldb.lib_dbmodelext")
			mp_objDB = new LibDbModelExt();
			mp_objModel = mp_objDB.GetFilteredModel(mp_strModelloFiltro, mp_Suffix, mp_User, 0, mp_strConnectionString, true, mp_ObjSession);

			//'-- nel caso di auto selezione al cambio di valore scattta automaticamente il submit
			if (mp_strAutoSel.ToUpper() == "YES")
			{
				for (i = 1; i <= mp_objModel.Fields.Count; i++)
				{
					mp_objModel.Fields.ElementAt(i - 1).Value.setOnChange(@" getObj('FormViewerFiltro').submit(); ");
				}
			}

			//'-- nascondo le colonne richieste
			if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "HIDE_COL")))
			{
				v = GetParamURL(Request_QueryString, "HIDE_COL").Split(",");
				for (i = 0; i < v.GetUpperBound(0); i++)
				{
					mp_objModel.Fields.Remove(v[i]);
				}
			}

			mp_objModel.UpdFieldsValue(Request_Form);

			//'-- verifica se � passato un filtro per default

			string strTestFilter = GetParamURL(Request_QueryString, "Filter");

			if (!string.IsNullOrEmpty(strTestFilter) || sessionFilter)
			{

				if (mp_strStoredSQL != "yes")
				{

					v = mp_Filter.Split("and");
					for (i = 0; i < v.GetUpperBound(0); i++)
					{
						strFilter = v[i];
						strFilter = strFilter.Trim();
						p = strFilter.Split("=");



						p[1] = p[1].Trim().Replace("'", "").Trim();
						//'-- inserisce il valore sull'attributo

						mp_objModel.Fields[p[0]].Value = p[1];
						if (!string.IsNullOrEmpty(mp_LockFiltered))
						{
							//mp_objModel.Fields(Trim(p(0))).Value = p(1)
							//If mp_LockFiltered<> "" Then mp_objModel.Fields(Trim(p(0))).SetEditable False


							mp_objModel.Fields[p[0]].SetEditable(false); // Ma Trim COSA????????????????
						}
					}
				}
				else
				{
					string[] vAtt = new string[] { };
					string[] vVal = new string[] { };
					string[] vCond = new string[] { };

					v = mp_Filter.Split("#~#");
					vAtt = v[0].Split("#@#");
					vVal = v[1].Split("#@#");
					vCond = v[2].Split("#@#");
					for (i = 0; i < vAtt.GetUpperBound(0); i++)
					{
						//p = Replace(Trim(vVal(i)), "'", "")
						p = vVal[i].Replace("'", "").Trim();
						//'-- inserisce il valore sull'attributo
						mp_objModel.Fields[vAtt[i]].Value = p;
						if (!string.IsNullOrEmpty(mp_LockFiltered))
						{
							mp_objModel.Fields[vAtt[i]].SetEditable(false);
						}
					}

				}

			}

			//'-- verifica se � passato un filtro nascosto per default

			string strTestFilterHide = GetParamURL(Request_QueryString, "FilterHide");

			if (!string.IsNullOrEmpty(strTestFilterHide))
			{


				v = GetParamURL(Request_QueryString, "FilterHide").Split("and");
				for (i = 0; i < v.GetUpperBound(0); i++)
				{
					strFilter = v[i];
					strFilter = strFilter.Trim();
					strFilter = strFilter.Replace("'", "");
					p = strFilter.Split("=");


					//'-- inserisce il valore sull'attributo e lo blocca
					mp_objModel.Fields[p[0]].Value = p[1];
					mp_objModel.Fields[p[0]].SetEditable(false);
				}
			}

		}

		public bool checkHackSecurity(HttpContext httpContext, Session.ISession session)
		{

			bool result = false;

			BlackList mp_objDBBL = new BlackList();
			Dictionary<string, string> attackerInfo = new Dictionary<string, string>();

			// TODO On Error Resume Next

			//'table
			if (!mp_objDBBL.isDevMode(session) && !DashBoard.Basic.isValid(mp_strTable, 1))
			{

				mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
				result = true;
				return result;

			}

			//'filterhide
			if (!mp_objDBBL.isDevMode(session) && !DashBoard.Basic.isValidaSqlFilter(GetParamURL(Request_QueryString, "FilterHide"), mp_strConnectionString))
			{

				mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), session, mp_strConnectionString);
				result = true;
				return result;
			}

			//'filter
			if (!mp_objDBBL.isDevMode(session) && !DashBoard.Basic.isValidaSqlFilter(CStr(mp_Filter), mp_strConnectionString))
			{

				mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTER), session, mp_strConnectionString);
				result = true;
				return result;

			}

			//'mp_strModelloFiltro
			if (!string.IsNullOrEmpty(mp_strModelloFiltro) && !mp_objDBBL.isDevMode(session) && !DashBoard.Basic.isValid(mp_strModelloFiltro, 1))
			{
				mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_MODFILTRO), session, mp_strConnectionString);
				result = true;
				return result;
			}

			//' Controllo se l'utente � autorizzato ad accedere allo specifico oggetto sql(tabella, vista)
			if (!mp_objDBBL.isDevMode(session) && !DashBoard.Basic.checkPermission(mp_strTable, session, mp_strConnectionString))
			{
				mp_objDBBL.addIp(mp_objDBBL.getAttackInfo(httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_CONTROLLO_PERMESSI, "##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
				result = true;
				return result;
			}

			return result;  // <---- TODO VERIFICARE
		}
	}
}
