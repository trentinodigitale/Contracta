using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System.Web;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.DashBoard
{
    public class ViewerFiltro
    {
        private HttpContext _httpContext;
        private Session.ISession _session;
        private IEprocResponse _response;


        private Session.ISession mp_ObjSession;
        private string mp_Suffix = string.Empty;
        private long mp_User = 0;
        private string mp_strConnectionString = string.Empty;

        private Form mp_objForm = new Form();
        private Model mp_objModel = new Model();
        private ButtonBar mp_ObjButtonBar = new ButtonBar();
        private Fld_Label mp_objCaption = new Fld_Label();
        private string mp_strModelloFiltro = string.Empty;

        private LibDbModelExt mp_objDB;// = new LibDbModelExt()

        private string mp_strTable = string.Empty;

        private string Request_QueryString;
        private IFormCollection Request_Form;

        private string mp_Filter = string.Empty;
        private string mp_strStoreSQL = string.Empty;
        private string mp_LockFiltered = string.Empty;

        private string mp_Filter_new = string.Empty;

        private Fld_Hidden mp_fldCurFiltro = new Fld_Hidden();
        private string mp_ModGriglia = string.Empty;

        public ViewerFiltro(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this._httpContext = httpContext;
            this._session = session;
            this._response = response;
        }

        public void run()
        {
            InitLocal();

            //controlli di sicurezza
            if (checkHackSecurity(_httpContext, _session))
            {
                // se è presente NOMEAPPLICAZIONE nell'application
                if (!String.IsNullOrEmpty(Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]))
                {
                    _httpContext.Response.Redirect($"/{Application.ApplicationCommon.Application["NOMEAPPLICAZIONE"]}/blocked.asp");
                    return;
                }
                else
                {
                    _httpContext.Response.Redirect($@"{Application.ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp");
                }
            }

            // Inizializzo gli oggetti dell'interfaccia
            InitGUIObject();

            if (mp_objModel.Fields.Count > 0)
            {

                _response.Write(@"<table class=""width_100_percent""");

                _response.Write(@" border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td>");

                // apre il form di ricerca
                _response.Write(mp_objForm.OpenForm());

                _response.Write(@"<table class=""width_100_percent""");
                _response.Write(@" border=""0"" cellspacing=""0"" cellpadding=""0"">");

                if (GetParamURL(Request_QueryString, "HIDEBUTTON").ToLower() != "yes")
                {
                    _response.Write("<tr><td>" + Environment.NewLine);

                    _response.Write(@"<table class=""width_100_percent""");


                    _response.Write(@" border=""0"" cellspacing=""0"" cellpadding=""0"">" + Environment.NewLine);
                    _response.Write(@"<tr><td>" + Environment.NewLine);

                    if (GetParamURL(Request_QueryString, "FilterCaption").ToLower() != "no")
                    {
                        mp_objCaption.Html(_response);
                    }

                    if(IsMasterPageNew()){
                        _response.Write("</td>");
                        if (string.IsNullOrEmpty(GetParamURL(Request_QueryString, "FILTER_BUTTON")) && !IsMasterPageNew())
                        {
                            _response.Write("<td>" + Environment.NewLine);
                            // disegna la toolbar
                            mp_ObjButtonBar.Html(_response);
                            _response.Write("</td>");
                        }
                        _response.Write("</tr>" + Environment.NewLine);

                    }else{

                        _response.Write("</td><td>" + Environment.NewLine);
                        if (string.IsNullOrEmpty(GetParamURL(Request_QueryString, "FILTER_BUTTON")))
                        {
                            // disegna la toolbar
                            mp_ObjButtonBar.Html(_response);
                        }
                        _response.Write("</td></tr>" + Environment.NewLine);

                    }

                    _response.Write("</table>" + Environment.NewLine);

                    _response.Write(Environment.NewLine + "</td></tr>" + Environment.NewLine);
                }

                // disegna il modello di ricerca
                //mp_strCause = "disegna il modello di ricerca";
                _response.Write("<tr><td>");
                mp_objModel.Html(_response);
                _response.Write("</td>");

                if (GetParamURL(Request_QueryString, "FILTER_BUTTON").ToLower() == "right" && !IsMasterPageNew())
                {
                    // disegna la toolbar
                    _response.Write($"<td width=\"100%\" align=\"left\" walign=\"top\" >" + Environment.NewLine);
                    mp_ObjButtonBar.Html(_response);
                    _response.Write("</td>" + Environment.NewLine);


                    //_response.Write("<tr><td>" + Environment.NewLine);
                    //mp_ObjButtonBar.Html(_response);
                    //_response.Write("</td></tr >" + Environment.NewLine);
                }

                _response.Write("</tr>");

                if (GetParamURL(Request_QueryString, "FILTER_BUTTON").ToLower() == "bottom" && !IsMasterPageNew())
                {
                    // disegna la toolbar
                    _response.Write("<tr><td>" + Environment.NewLine);
                    mp_ObjButtonBar.Html(_response);
                    _response.Write("</td></tr >" + Environment.NewLine);
                }

                if (IsMasterPageNew())
                {
                    _response.Write($@"<td class=""rowButtonsFaseII"" >" + Environment.NewLine);
                    mp_ObjButtonBar.Html(_response);
                    _response.Write("</td>" + Environment.NewLine);
                }

                _response.Write("</table>");

                mp_fldCurFiltro.Html(_response);

                // chiudo il form di ricerca 
                _response.Write(mp_objForm.CloseForm());

                _response.Write(@"</td></tr><tr><td></td></tr></table>");
            }
            else
            {
                /*
                 *  '-- se siamo in versione accessibile e il modello di ricerca non esiste o è vuoto
                    '-- disegno soltanto il form per permettere al viewer griglia di far scattare un submit
                    '-- ( per fare l'ordinamento )
    
                        '-- apre il form di ricerca
                 */
                _response.Write(mp_objForm.OpenForm());


                //'-- chiude il form di ricerca
                _response.Write(mp_objForm.CloseForm());
            }

        }

        public bool checkHackSecurity(HttpContext httpContext, Session.ISession session)
        {
            BlackList mp_objDB = new BlackList();

            //dynamic attackerInfo = null;

            bool result = false;  // valore che la funzione restituisce

            // table
            if (!mp_objDB.isDevMode() && !Basic.isValid(mp_strTable, 1))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                result = true;
                return result;
            }

            // filterhide
            if (!mp_objDB.isDevMode() && !Basic.isValidaSqlFilter(GetParamURL(Request_QueryString, "FilterHide"), mp_strConnectionString))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTERHIDE), session, mp_strConnectionString);
                result = true;
                return result;
            }

            // filter 
            if (!mp_objDB.isDevMode() && !Basic.isValidaSqlFilter(mp_Filter, mp_strConnectionString))
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_FILTER), session, mp_strConnectionString);
                result = true;
                return result;
            }

            // mp_strModelloFiltro
            if (!String.IsNullOrEmpty(mp_strModelloFiltro))
            {
                if (!mp_objDB.isDevMode() && !Basic.isValid(mp_strModelloFiltro, 1))
                {
                    mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_MODFILTRO), session, mp_strConnectionString);
                    result = true;
                    return result;
                }
            }

            // Controllo se l'utente è autorizzato ad accedere allo specifico oggetto sql (tabella, vista)
            if (!mp_objDB.isDevMode() && Basic.checkPermission(mp_strTable, _session, Application.ApplicationCommon.Application["ConnectionString"]) == false)
            {
                mp_objDB.addIp(mp_objDB.getAttackInfo(httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_CONTROLLO_PERMESSI, "##nome-parametro##", mp_strTable)), session, mp_strConnectionString);
                result = true;
                return result;

            }

            return result;
        }
        private void InitLocal()
        {
            mp_ObjSession = _session;

            int PosSuperUser = 0;

            mp_Suffix = Application.ApplicationCommon.Application[SessionProperty.SESSION_SUFFIX];
            if (String.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            mp_strConnectionString = Application.ApplicationCommon.Application["ConnectionString"];
            Request_QueryString = GetQueryStringFromContext(_httpContext.Request.QueryString);

            Request_Form = _httpContext.Request.HasFormContentType ? _httpContext.Request.Form : null;


            //if (_httpContext.Request.HasFormContentType)
            //{
            //    Request_Form = _httpContext.Request.Form;
            //}

            mp_User = CLng(_session[SessionProperty.SESSION_USER]);

            //mp_Permission = CStr(_session[SessionProperty.SESSION_PERMISSION]);

            mp_strTable = GetParamURL(Request_QueryString, "Table");

            mp_strModelloFiltro = GetParamURL(Request_QueryString, "ModelloFiltro");

            if (String.IsNullOrEmpty(mp_strModelloFiltro))
            {
                mp_strModelloFiltro = mp_strTable + "Filtro";
            }

            //mp_queryString = "&ClearNew=" + GetParamURL(Request_QueryString, "ClearNew") + "&CaptionAdd=" + GetParamURL(Request_QueryString, "CaptionAdd") + "&CaptionUpd=" + GetParamURL(Request_QueryString, "CaptionUpd") + "&RowForPage=" + GetParamURL(Request_QueryString, "RowForPage") + "&IDENTITY=" + GetParamURL(Request_QueryString, "IDENTITY");
            mp_Filter = GetParamURL(Request_QueryString, "Filter");
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "STORED_SQL")))
            {
                mp_strStoreSQL = GetParamURL(Request_QueryString, "STORED_SQL");
            }

            mp_LockFiltered = GetParamURL(Request_QueryString, "L_F");
            //mp_accessible = CStr(Application.ApplicationCommon.Application["ACCESSIBILE"]);

            mp_ModGriglia = GetParamURL(Request_QueryString, "ModGriglia");
            if (String.IsNullOrEmpty(mp_ModGriglia))
            {
                mp_ModGriglia = mp_strTable + "Griglia";
            }

        }

        private void InitGUIObject()
        {
            string strFilter = string.Empty;
            string[] v;
            dynamic p;
            int i = 0;
            string tempQS = string.Empty;

            mp_objForm = new Form();
            mp_objModel = new Model();
            mp_ObjButtonBar = new ButtonBar();
            bool sessionFilter = false;

            // inizializza il form
            mp_objForm.id = "FormViewerFiltro";

            // barra dei bottoni
            mp_ObjButtonBar.CaptionSubmit = Application.ApplicationCommon.CNV("Filtra", mp_ObjSession);
            mp_ObjButtonBar.CaptionReset = Application.ApplicationCommon.CNV("Pulisci", mp_ObjSession);

            mp_ObjButtonBar.id = "ViewerFiltro";

            mp_ObjButtonBar.OnSubmit = HttpUtility.HtmlEncode(GetParamURL(Request_QueryString, "onsubmit"));

            // Inizializza la caption

            //mp_strCause = "Inizializzo la caption";
            mp_objCaption.Style = "SinteticHelp";

            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "FilterCaption")))
            {
                mp_objCaption.Value = Application.ApplicationCommon.CNV(GetParamURL(Request_QueryString, "FilterCaption"), mp_ObjSession);
            }
            else
            {
                mp_objCaption.Value = Application.ApplicationCommon.CNV("Filtra il contenuto della griglia", mp_ObjSession);
            }

            mp_objCaption.Image = "Filter.gif";

            // recupero il modello di ricerca

            mp_objDB = new LibDbModelExt();

            //mp_strCause = "recupero il modello di ricerca";
            mp_objModel = mp_objDB.GetFilteredModel(mp_strModelloFiltro, mp_Suffix, mp_User, 0, mp_strConnectionString, true, mp_ObjSession);

            //essendo un modello per un filtro di ricerca disattivo la validazione formale dei campi
            mp_objModel.disattivaValidazioneFormale = true;

            // nascondo le colonne richieste
            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "HIDE_COL")))
            {

                v = GetParamURL(Request_QueryString, "HIDE_COL").Split(',');
                for (i = 0; i <= v.Length - 1; i++)
                {
                    try
                    {
                        mp_objModel.Fields.Remove(v[i]);

                    }
                    catch
                    {

                    }
                }

            }
            if (GetParamURL(Request_QueryString, "FILTERCOLUMNFROMMODEL") != "yes")
            {
                mp_objModel.NumberColumn = 2;
            }

            if (string.IsNullOrEmpty(GetParamURL(Request_QueryString, "PAGEDEST")))
            {
                string[] tmpVet; // = string.Empty;
                string mp_StrToolbar = string.Empty;
                string mp_idViewer = string.Empty;


                mp_StrToolbar = GetParamURL(Request_QueryString, "TOOLBAR");
                sessionFilter = false;

                tmpVet = mp_StrToolbar.Split(',');
                if (tmpVet.Length - 1 > 0)
                {
                    mp_StrToolbar = tmpVet[0];
                }

                mp_idViewer = mp_ModGriglia + "_" + mp_strModelloFiltro + "_" + mp_strTable + "_" + GetParamURL(Request_QueryString, "OWNER") + "_" + mp_StrToolbar;

                if (!string.IsNullOrEmpty(CStr(_session[mp_idViewer])))
                {
                    mp_Filter = _session[mp_idViewer];
                    sessionFilter = true;
                }

                tempQS = Request_QueryString;
                tempQS = ReplaceInsensitive(tempQS, "MODE=Filtra&", "");//tempQS = tempQS.Replace("MODE=Filtra&", "");
                tempQS = ReplaceInsensitive(tempQS, "&nPag=" + GetParamURL(Request_QueryString, "nPag"), ""); //tempQS.Replace("&nPag=" + GetParamURL(Request_QueryString, "nPag"), "");
                tempQS = ReplaceInsensitive(tempQS, "&Filter=" + URLEncode(GetParamURL(Request_QueryString, "Filter")), ""); //tempQS.Replace("&Filter=" + URLEncode(GetParamURL(Request_QueryString, "Filter")), "");
                tempQS = ReplaceInsensitive(tempQS, "&Filter=" + GetParamURL(Request_QueryString, "Filter"), ""); //tempQS.Replace("&Filter=" + GetParamURL(Request_QueryString, "Filter"), "");
                tempQS = tempQS + $"&Filter={URLEncode(mp_Filter)}";

                mp_objForm.Action = $"Viewer.asp?MODE=Filtra&amp;{HtmlEncode(tempQS)}";
            }
            else
            {
                tempQS = Request_QueryString;
                tempQS = ReplaceInsensitive(tempQS, "MODE=Filtra&", ""); //tempQS.Replace("MODE=Filtra&", "");
                tempQS = ReplaceInsensitive(tempQS, "&nPag=" + GetParamURL(Request_QueryString, "nPag"), "");//tempQS.Replace("&nPag=" + GetParamURL(Request_QueryString, "nPag"), "");

                mp_objForm.Action = GetParamURL(Request_QueryString, "PAGEDEST") + "?MODE=Filtra&" + HtmlEncode(tempQS);

                if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "FolderField")))
                {
                    mp_objForm.Target = "ViewerGriglia";
                }
                else
                {
                    mp_objForm.Target = "_self";
                }
            }

            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "TARGET_OUTPUT")))
            {
                mp_objForm.Target = GetParamURL(Request_QueryString, "TARGET_OUTPUT");
            }

            string ValueField = string.Empty;
            string NameField = string.Empty;

            // verifica se è passato un filtro per default

            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "Filter")) || sessionFilter)
            {
                if (mp_strStoreSQL.ToLower() != "yes")
                {
                    v = mp_Filter.Split("and");
                    for (i = 0; i <= v.Length - 1; i++)
                    {
                        strFilter = v[i];
                        ValueField = CommonModule.Basic.GetValue_FromAttrib_Filter(strFilter, ref NameField);

                        if (mp_objModel.Fields.ContainsKey(NameField))
                        {

                            mp_objModel.Fields[NameField].Value = ValueField;

                            if (!string.IsNullOrEmpty(mp_LockFiltered))
                            {
                                mp_objModel.Fields[NameField].SetEditable(true);
                            }
                        }
                    }
                }
                else
                {
                    //EP KPF 541335  aggiunto per evitare eccezione se il filtro per la stored non passato nella
                    //sintassi giusta (in VB c'è on error resume next più sopra , cioè dopo la riga 421)
                    try
                    {
                        string[] vAtt;
                        string[] vVal;
                        string[] vCond;

                        v = mp_Filter.Split("#~#");
                        vAtt = v[0].Split("#@#");

                        vVal = v[1].Split("#@#");
                        vCond = v[2].Split("#@#");

                        //for (i = 0; i < vAtt.Length; i++)
                        for (i = 0; i <= vAtt.Length - 1; i++)
                        {
                            p = vVal[i].Trim().Replace("'", "");
                            // inserisce il valore sull'attributo
                            // mp_objModel.Fields[vAtt[i]].Value = p; //<--- rimosso come da modifiche ai sorgenti come indicato da Federico 05/08/2022
                            if (Left(p, 1) == "%" && vCond[i].ToLower() == " like ")
                            {
                                p = Right(p, Len(p) - 1);
                            }
                            if (Right(p, 1) == "%" && vCond[i].ToLower() == " like ")
                            {
                                p = Left(p, Len(p) - 1);
                            }


                            mp_objModel.Fields[vAtt[i]].Value = p; //<--- modifiche ai sorgenti come indicato da Federico 05/08/2022
                            if (!String.IsNullOrEmpty(mp_LockFiltered))
                            {
                                mp_objModel.Fields[vAtt[i]].SetEditable(false);
                            }


                        }
                    }
                    catch
                    {

                    }
                }
            }

            // prendere il filtro anche dal form che sovrascriverà quello da url

            mp_objModel.UpdFieldsValue(Request_Form);

            // recupera la condizione di ricerca
            if (mp_strStoreSQL != "yes")
            {
                mp_Filter_new = mp_objModel.GetSqlWhere();
            }
            else
            {
                mp_Filter_new = mp_objModel.GetSqlWhereList();
            }

            mp_fldCurFiltro = new Fld_Hidden();

            mp_fldCurFiltro.Name = "hiddenViewerCurFilter";
            mp_fldCurFiltro.Value = mp_Filter_new;


            if (!String.IsNullOrEmpty(GetParamURL(Request_QueryString, "FilterHide")))
            {
                v = GetParamURL(Request_QueryString, "FilterHide").Split("and");
                for (i = 0; i < v.Length; i++)
                {

                    strFilter = v[i].Trim().Replace("'", "");
                    p = strFilter.Split("=");

                    // inserisce il valore sull'attributo e lo blocca
                    if (mp_objModel.Fields.ContainsKey(p[0]))
                    {
                        mp_objModel.Fields[p[0].Trim()].Value = p[1];
                        mp_objModel.Fields[p[0].Trim()].SetEditable(false);
                    }
                }
            }

        }

    }
}
