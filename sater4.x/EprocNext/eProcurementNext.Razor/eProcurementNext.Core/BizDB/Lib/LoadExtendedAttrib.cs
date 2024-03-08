using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.BizDB
{
    public class LoadExtendedAttrib
    {
        private IHttpContextAccessor _accessor;
        private HttpContext _context;
        private Session.ISession _session;

        private string mp_strcause;
        private string mp_Attrib;
        private string mp_Suffix;
        private string mp_Filter;
        private long? mp_User;
        private string mp_Num;
        private string mp_IdDomain;
        private string mp_TypeAttrib;
        private int mp_MultiValue;
        private string mp_Value;
        private string mp_strConnectionString;
        private eProcurementNext.HTML.Field mp_ObjHtml;
        private string Request_QueryString;
        private string mp_Editable;
        private string mp_format;
        private string titoloFinestra;
        private ClsDomain objdom;
        private string mp_accessible;
        private bool isLazy;

        public LoadExtendedAttrib(HttpContext context, eProcurementNext.Session.ISession session)
        {
            this._context = context;
            this._session = session;
        }

        public void run(IEprocResponse response)
        {

            Dictionary<string, string> JS = new Dictionary<string, string>();
            string JavaScript = "";
            string strMlg = "";

            //'-- recupero variabili di sessione
            InitLocal(_session, GetQueryStringFromContext(_context.Request.QueryString));

            //'-- Controlli di sicurezza
            if (checkHackSecurity(_session))
            {

                //'Se è presente NOMEAPPLICAZIONE nell'application
                if (!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"])))
                {

                    _context.Response.Redirect("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp");
                    return;

                }
                else
                {

                    _context.Response.Redirect($@"{ApplicationCommon.Application["strVirtualDirectory"]}/blocked.asp");
                    return;

                }

            }


            if (GetParamURL(Request_QueryString, "MODE") == "null")
            {


            }
            else
            {

                string senzaModali;
                string versioneAFLink;

                senzaModali = ApplicationCommon.Application["DISATTIVA_MODALE_MULTIVALORE"];
                versioneAFLink = ApplicationCommon.Application["VERSIONE_AFLINK"];

                response.Write($@"<script src='./jscript/jquery/jquery.js?v=" + versioneAFLink + @"' type='text/javascript'></script>" + Environment.NewLine);
                response.Write($@"<script src='./jscript/jquery/jquery-ui.custom.js?v=" + versioneAFLink + @"' type='text/javascript'></script>" + Environment.NewLine);

                response.Write($@"<link rel='stylesheet' type='text/css' href='./jscript/jquery/jquery-ui.css?v=" + versioneAFLink + @"'>" + Environment.NewLine);


                response.Write($@"<link rel='stylesheet' type='text/css' href='./jscript/skin/ui.dynatree.css?v=" + versioneAFLink + @"' >" + Environment.NewLine);
                response.Write($@"<script src='./jquery.dynatree.js?v=" + versioneAFLink + @"' type='text/javascript'></script>" + Environment.NewLine);
                response.Write($@"<script src='./jscript/multiselezione.js?v=" + versioneAFLink + @"' type='text/javascript'></script>" + Environment.NewLine);
                response.Write($@"<link rel='stylesheet' type='text/css' href='./themes/domini_estesi.css?v=" + versioneAFLink + @"' >" + Environment.NewLine);

                if (IsMasterPageNew())
                {
                    response.Write($@"<link rel='stylesheet' type='text/css' href='../css/vapor/vapor.css?v=" + versioneAFLink + @"' >" + Environment.NewLine);
					response.Write($@"<link rel='stylesheet' type='text/css' href='../css/vapor/customColor.css?v=" + versioneAFLink + @"' >" + Environment.NewLine);
				}

				response.Write($@"<script type='text/javascript'>" + Environment.NewLine);

                response.Write($@"$(function(){{" + Environment.NewLine);
                response.Write($@"    $('#tree').dynatree({{" + Environment.NewLine);

                if (mp_MultiValue == 1)
                {
                    response.Write($@"    checkbox: true,");
                    response.Write($@"    selectMode: 3,");
                }

                //'-- se � stato richiesto il caricamento pigro (caricamento ritardato dei nodi all'apertura dei singoli) del dominio
                if (isLazy)
                {
                    response.Write($@"    onLazyRead: function(node){{ " + Environment.NewLine);
                    response.Write($@"          node.appendAjax({{");
                    response.Write($@"                url: '../ctl_library/getLazyNodes.asp', " + Environment.NewLine);
                    response.Write($@"                data: {{'key': node.data.key," + Environment.NewLine);
                    response.Write($@"                       'level': node.data.level," + Environment.NewLine);
                    response.Write($@"                       'father': node.data.father," + Environment.NewLine);
                    response.Write($@"                       'mode': 'all'," + Environment.NewLine);
                    response.Write($@"                       'dominio': document.getElementById('id_domain').value, " + Environment.NewLine);
                    response.Write($@"                       'format': document.getElementById('format').value, " + Environment.NewLine);
                    response.Write($@"                       'editable': document.getElementById('editable').value, " + Environment.NewLine);
                    response.Write($@"                       'filter': document.getElementById('filter').value" + Environment.NewLine);
                    response.Write($@"                      }}," + Environment.NewLine);
                    response.Write($@"                cache: false , " + Environment.NewLine);
                    response.Write($@"                dataType: 'json', " + Environment.NewLine);
                    response.Write($@"              }});" + Environment.NewLine);
                    response.Write($@"        }}, " + Environment.NewLine);
                }

                response.Write($@"        imagePath: '../CTL_Library/images/Domain/'  " + Environment.NewLine);
                response.Write($@"        ,onDblClick: function(node, event) {{ addToSelezionati(node,'selezionati'); }}  ");
                response.Write($@"        ,OnClick: function(node, event) {{ callBackOnActivate(node); }}  ");
                response.Write($@"        ,onKeypress: function(node, event) {{ keyPressOnTree(node,event); }}");
                response.Write($@"        ,onSelect: function(flag, node) {{" + Environment.NewLine);
                response.Write($@"            selezionaNodo(node,'selezionati',flag);" + Environment.NewLine);
                response.Write($@"        }}, " + Environment.NewLine);
                response.Write($@"        onActivate: function(node) {{" + Environment.NewLine);
                response.Write($@"            callBackOnActivate(node);" + Environment.NewLine);
                response.Write($@"        }}" + Environment.NewLine);
                response.Write($@"    }});" + Environment.NewLine);

                response.Write($@"   $('#selezionati').dynatree({{ ");
                response.Write($@"          checkbox: true ");
                response.Write($@"          ,onDblClick: function(node, event) {{ removeToSelezionati(node,'selezionati'); }}  ");
                response.Write($@"    }}); " + Environment.NewLine);

                //'--- il caricamento del #tree-find quando stiamo in modalit� lazy lo faccio nel javascript multiselezione.js quando scatta la ricerca
                if (!isLazy)
                {

                    response.Write($@"   $('#tree-find').dynatree({{ ");

                    if (mp_MultiValue == 1)
                    {
                        response.Write($@"        checkbox: true ");
                        response.Write($@"        ,onDblClick: function(node, event) {{ node.select(true); addToSelezionati(node,'selezionati'); }}  ");
                    }
                    else
                    {
                        response.Write($@"        checkbox: false ");
                        response.Write($@"        ,onDblClick: function(node, event) {{ addToSelezionati(node,'selezionati'); }}  ");
                        response.Write($@"        ,onActivate: function(node, event) {{ callBackOnActivate(node); }}  ");
                    }

                    response.Write($@"        ,onKeypress: function(node, event) {{ keyPressOnTree(node,event); }}");
                    response.Write($@"        ,onSelect: function(flag, node) {{ selezionaNodo(node,'selezionati',flag); }} " + Environment.NewLine);
                    response.Write($@"    }}); " + Environment.NewLine);

                }

                response.Write($@"}});" + Environment.NewLine);

                response.Write($@" $(document).ready(function() {{" + Environment.NewLine);
                response.Write($@"             chiama_onLoad('tree','selezionati');" + Environment.NewLine);
                response.Write($@"            }});" + Environment.NewLine);

                response.Write($@"</script>" + Environment.NewLine);

                string classeTree;
                string classeTreeFind;
                string classeTreeSelezionati;
                string tree_div_sx;
                string tree_div_dx;

                //'-- Imposto le classi da dare alle div principali in base alla presenza o meno della format per gli incrementali
                if (mp_TypeAttrib == "8" && mp_format.Contains("I", StringComparison.Ordinal))
                {

                    classeTree = "tree_I";
                    classeTreeFind = "tree-find_I";
                    classeTreeSelezionati = "selezionati_I";
                    tree_div_sx = "tree_div_sx_I";
                    tree_div_dx = "tree_div_dx_I";

                }
                else
                {

                    classeTree = "tree";
                    classeTreeFind = "tree-find";
                    classeTreeSelezionati = "selezionati";
                    tree_div_sx = "tree_div_sx";
                    tree_div_dx = "tree_div_dx";

                }


                response.Write($@"<div class=""top-div"">");

                response.Write($@"<div class=""help"">");

                response.Write($@"<p class=""suggerimenti_title"">" + ApplicationCommon.CNV("Suggerimenti", _session) + "</p>");

                if (mp_Editable == "False")
                {

                    strMlg = ApplicationCommon.CNV("help_newdom_nonEditabile", _session);

                }
                else
                {

                    string tmpKey = "";
                    tmpKey = "help_dominio_" + mp_Attrib;

                    strMlg = ApplicationCommon.CNV(tmpKey, _session);

                    //'-- Se l'help specifico per l'attributo non � presente nel multilinguismo
                    //'-- allora utiliziamo quello base
                    if (tmpKey == strMlg || strMlg.Contains("???", StringComparison.Ordinal))
                    {


                        string strKeyMlgHelp = "";

                        //'-- Multilinguismo per il dominio esteso incrementale
                        if (mp_TypeAttrib == "8" && mp_format.Contains("I", StringComparison.Ordinal))
                        {

                            strKeyMlgHelp = "help_domext_incrementale";

                        }
                        else
                        {

                            if (mp_TypeAttrib == "4" || mp_TypeAttrib == "8")
                            {
                                strKeyMlgHelp = "help_domext";
                            }
                            else
                            {
                                strKeyMlgHelp = "help_gerarchico";
                            }

                            if (mp_MultiValue == 1)
                            {
                                strKeyMlgHelp = strKeyMlgHelp + "_multivalore";
                            }
                            else
                            {
                                strKeyMlgHelp = strKeyMlgHelp + "_singolovalore";
                            }

                        }

                        strMlg = ApplicationCommon.CNV(strKeyMlgHelp, _session);

                    }

                }

                response.Write(strMlg);

                response.Write($@"</div>");

                response.Write($@"</div>");

                //'--     CAMPI TECNICI NASCOSTI
                response.Write($@"<input id=""multivalue"" type=""hidden"" value=""" + this.HtmlEncode(CStr(mp_MultiValue)) + $@""" />");
                response.Write($@"<input id=""value"" type=""hidden"" value=""" + mp_Value + $@""" />");
                response.Write($@"<input id=""editable"" type=""hidden"" value=""" + this.HtmlEncode(CStr(mp_Editable)) + $@""" />");
                response.Write($@"<input id=""nome_campo"" type=""hidden"" value=""" + this.HtmlEncode(CStr(mp_Attrib)) + $@""" />");
                response.Write($@"<input id=""format"" type=""hidden"" value=""" + this.HtmlEncode(CStr(mp_format)) + $@""" />");
                response.Write($@"<input id=""id_domain"" type=""hidden"" value=""" + this.HtmlEncode(CStr(mp_IdDomain)) + $@""" />");
                response.Write($@"<input id=""lazy"" type=""hidden"" value=""" + IIF(isLazy == true, "true", "false") + $@""" />");
                response.Write($@"<input id=""filter"" type=""hidden"" value=""" + this.HtmlEncode(CStr(mp_Filter)) + $@""" />");


                //'-- Se � un dominio esteso e si � richiesta la modalit� 'incrementale' tramite la format
                if (mp_TypeAttrib == "8" && mp_format.Contains("I", StringComparison.Ordinal))
                {

                    response.Write($@"<input id=""incrementale"" type=""hidden"" value=""SI"" />");

                }
                else
                {

                    response.Write($@"<input id=""incrementale"" type=""hidden"" value=""NO"" />");

                }


                response.Write($@"<div class=""main-div"">");

                //'-- Se c'� la multiselezione compongo la pagina come due div una per l'albero
                //'-- e l'altra per le selezioni effettuate
                if (mp_MultiValue == 1)
                {

                    response.Write($@"<div id=""tree_div_sx"" class=""" + tree_div_sx + $@""">");

                }

                response.Write($@"<p class=""p-title"">" + ApplicationCommon.CNV("Elenco", _session) + "</p>");

                //'-- area di ricerca
                response.Write($@"<div id=""area-ricerca"" class=""area-ricerca"">");
                response.Write($@"<input class=""text-grafica"" type=""text"" id=""text-cerca"" name=""text-cerca"" onKeypress=""search(event);"" placeholder=""" + ApplicationCommon.CNV("Cerca") + @"""/>");
                response.Write($@"<input class=""button-grafica"" id=""cerca-button"" type=""button"" value=""" + ApplicationCommon.CNV("Cerca", _session) + @""" onClick=""search();""/>");
                response.Write($@"<input class=""button-grafica"" id=""reset-button"" type=""button"" value=""" + ApplicationCommon.CNV("Indietro", _session) + @""" onClick=""document.getElementById('text-cerca').value='';search();""/>");


                response.Write($@"</div>");


                response.Write($@"<div id=""tree"" class=""" + classeTree + @""">");
                mp_ObjHtml.HtmlExtended3(response, Request_QueryString, _session);
                response.Write($@"</div>");

                //'-- Div per i risultati della ricerca
                response.Write($@"<div id=""tree-find"" style=""display:none"" class=""" + classeTreeFind + @""">");
                response.Write($@"</div>");

                if (mp_MultiValue == 1)
                {

                    response.Write($@"</div>");
                    response.Write($@"<div id=""tree_div_dx"" class=""" + tree_div_dx + @""">");

                    response.Write($@"<p  class=""p-title"">" + ApplicationCommon.CNV("Elementi selezionati", _session) + @"</p>");

                    //'-- div per i comandi di selezione
                    response.Write($@"<div class=""tree_div_center"">");
                    response.Write($@"<input id=""button_elimina"" class=""button-grafica""  type=""button"" onClick=""clickDel('selezionati');"" value=""" + ApplicationCommon.CNV("Elimina", _session) + @""" />");
                    response.Write($@"<input id=""button_svuota"" class=""button-grafica"" type=""button"" onClick=""clickClear('selezionati');"" value=""" + ApplicationCommon.CNV("Svuota", _session) + @""" />");
                    response.Write($@"</div>");

                    response.Write($@"<div id=""selezionati"" class=""" + classeTreeSelezionati + $@""">");

                    //'-- Se non � editabile � il server ad disegnare il riepilogo della selezione
                    if (mp_Editable == "False")
                    {
                        response.Write($@"<ul>" + Environment.NewLine);
                        response.Write(getListOfValues());
                        response.Write($@"</ul>" + Environment.NewLine);
                    }

                    response.Write($@"</div>");

                    response.Write($@"</div>");

                }

                response.Write($@"</div>");

                if (mp_TypeAttrib == "8" && mp_format.Contains("I", StringComparison.Ordinal))
                {

                    //'-- Disegno la text per l'incrementale
                    response.Write($@"<div class=""div_incrementale"">");
                    response.Write($@"<p><label class=""label-grafica"">" + ApplicationCommon.CNV("Altro", _session) + $@"</label></p>");
                    response.Write($@"<input class=""text-grafica-incrementale"" type=""text"" id=""text-incrementale"" name=""text-incrementale"" onKeyup=""evidenzia(event);""/>");
                    response.Write($@"</div>");

                }

                //'-- In assenza della modale disegnamo la toolbar dei comandi del popup dentro la finestra
                if (senzaModali == "1")
                {

                    if (mp_Editable == "False")
                    {

                        response.Write($@"<div class=""div_pulsanti_finestra"">");
                        response.Write($@"<input onClick=""annulla()"" type=""button"" class=""button-grafica"" value=""" + ApplicationCommon.CNV("Chiudi", _session) + @"""/>");
                        response.Write($@"</div>");


                    }
                    else
                    {

                        response.Write($@"<div class=""div_pulsanti_finestra"">");

                        response.Write($@"        <input onClick=""conferma()"" type=""button"" class=""button-grafica"" value=""" + ApplicationCommon.CNV("Conferma", _session) + @"""/>");
                        response.Write($@"        <input onClick=""svuota_chiudi()"" type=""button"" class=""button-grafica"" value=""" + ApplicationCommon.CNV("Svuota", _session) + @"""/>");
                        response.Write($@"        <input onClick=""annulla()"" type=""button"" class=""button-grafica"" value=""" + ApplicationCommon.CNV("Annulla", _session) + @"""/>");

                        response.Write($@"</div>");

                    }

                }





            }

            //Set objdom = Nothing


        }

        private void InitLocal(eProcurementNext.Session.ISession session, string _Request_QueryString)
        {

            string strMultivalue;
            Request_QueryString = _Request_QueryString;
            IFormCollection? Request_Form = null;
            if (_context.Request.HasFormContentType)
            {
                Request_Form = _context.Request.Form;
            }

            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;

            mp_Attrib = GetParamURL(Request_QueryString, "Attrib");
            mp_Suffix = _session[SessionProperty.SESSION_SUFFIX];

            if (string.IsNullOrEmpty(mp_Suffix))
                mp_Suffix = "I";

            //'-- recupero il Filter prima dal form. se non lo trovo passo a recuperarlo dalla querystring
            mp_Filter = Request_Form != null ? Request_Form["Filter"] : "";

            if (string.IsNullOrEmpty(CStr(mp_Filter)))
            {
                mp_Filter = GetParamURL(Request_QueryString, "Filter");
            }

            mp_User = _session[Session.SessionProperty.SESSION_USER];
            mp_Num = GetParamURL(Request_QueryString, "Num");

            mp_TypeAttrib = GetParamURL(Request_QueryString, "TypeAttrib");
            mp_IdDomain = GetParamURL(Request_QueryString, "IdDomain");

            //'-- recupero il value prima dal form. se non lo trovo passo a recuperarlo dalla querystring
            mp_Value = Request_Form != null ? Request_Form["value"] : "";

            if (string.IsNullOrEmpty(mp_Value))
            {
                mp_Value = GetParamURL(Request_QueryString, "Value");
            }

            mp_Editable = GetParamURL(Request_QueryString, "Editable");

            mp_format = GetParamURL(Request_QueryString, "Format");

            titoloFinestra = CStr(GetParamURL(Request_QueryString, "titoloFinestra"));
            if (string.IsNullOrEmpty(titoloFinestra) || titoloFinestra.ToUpper() == "UNDEFINED")
            {
                titoloFinestra = "-";
            }

            strMultivalue = GetParamURL(Request_QueryString, "MultiValue");


            mp_MultiValue = 0;
            if (CStr(strMultivalue) == "1")
            {
                mp_MultiValue = 1;
            }

            isLazy = false;
            if (UCase(CStr(GetParamURL(Request_QueryString, "lazy"))) == "YES" || isLazy || mp_format.Contains("J", StringComparison.Ordinal))
            {
                isLazy = true;
            }

            //'-- crea l'oggetto

            //'--recupero l'attributo attraverso il tipo attributo e il dominio e non pi� attraverso il field
            LibDBDomains objLib = new LibDBDomains();



            objdom = objLib.GetFilteredDomExt(mp_IdDomain, mp_Suffix, CLng(mp_User), mp_Filter, 0, mp_strConnectionString, session);

            HTML.Field objField = getNewField((int)CLng(mp_TypeAttrib)); //new HTML.Field();

            objField.MultiValue = mp_MultiValue;

            objField.isLazy = isLazy;

            objField.Init((int)CLng(mp_TypeAttrib), mp_IdDomain + "_" + mp_TypeAttrib, mp_Value, objdom, oFormat: GetParamURL(Request_QueryString, "FORMAT"));


            objField.SetSelectDescription(ApplicationCommon.CNV("-- Effettuare una selezione --", session));
            objField.SetPrintDescription(ApplicationCommon.CNV("Vedi allegato", session));
            objField.SetSelezionatiDescription(ApplicationCommon.CNV("Selezionati", session));
            objField.SetSenzaModali(CStr(ApplicationCommon.Application["DISATTIVA_MODALE_MULTIVALORE"]));

            mp_ObjHtml = objField;

            //mp_accessible = UCase(session(OBJAPPLICATION)("ACCESSIBLE"))

        }

        public bool checkHackSecurity(Session.ISession session)
        {

            bool boolToReturn;
            boolToReturn = false;

            BlackList blacklist = new BlackList();

            //'-- Controlli di sicurezza
            if (!string.IsNullOrEmpty(mp_Num) && !IsNumeric(mp_Num))
            {

                blacklist.addIp(blacklist.getAttackInfo(_context, session[SessionProperty.IdPfu], "modifica del parametro 'mp_Num' sulla loadExtendedAttrib"), session, ApplicationCommon.Application.ConnectionString);
                boolToReturn = true;
            }


            return boolToReturn;

        }

        private string HtmlEncode(string str)
        {

            string s;

            s = (str.Replace(@"&", @"&amp;"));
            s = (s.Replace(@"<", @"&lt;"));
            s = (s.Replace(@">", @"&gt;"));
            s = (s.Replace(@"""", @"&quot;"));

            return s;

        }

        private string getListOfValues()
        {

            string stringToReturn;
            string[] aInfo;
            int i;
            int n;
            string strDesc = "";
            DomElem? elem;

            //On Error Resume Next


            stringToReturn = "";

            if (string.IsNullOrEmpty(mp_Value))
            {
                return stringToReturn;
            }


            if (!mp_Value.Contains("###", StringComparison.Ordinal))
            {

                strDesc = mp_Value;

            }

            aInfo = mp_Value.Split("###");

            n = aInfo.Length;

            for (i = 1; i < n; i++)
            { //i = 1 To n - 1

                try
                {
                    elem = (DomElem?)objdom.FindCode(CStr(aInfo[i]));

                    if (elem != null)
                    {
                        strDesc = strDesc + @"<li id=""" + this.HtmlEncode(elem.id) + @""" title=""" + this.HtmlEncode(elem.Desc) + @""">" + elem.Desc + Environment.NewLine;
                    }

                    elem = null;
                }
                catch (Exception e)
                {

                }


            }

            stringToReturn = strDesc;

            return stringToReturn;

        }



    }
}
