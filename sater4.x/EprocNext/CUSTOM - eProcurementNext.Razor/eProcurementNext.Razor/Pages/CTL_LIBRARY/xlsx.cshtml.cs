using ClosedXML.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Security;
using Microsoft.VisualBasic;
using System.Collections.Specialized;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.securityModel;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.DocumentPermissionModel;
using FileAccess = System.IO.FileAccess;
using DocumentFormat.OpenXml.InkML;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY
{
    public class xlxsModel
    {

        public xlxsModel()
        {
        }
        public void OnGet()
        {
        }

        private int mp_idpfu = -20;
        private string mp_sessionID = "";

        private string strConnectionString = ApplicationCommon.Application.ConnectionString;
        private string paginaChiamata = "ctl_library/xlsx.aspx";

        private string lngSuffix = "I";
        private string strPermission = "";

        private string strMotivoBlocco;

        private string MODEL = "";
        private string ufp = "";
        private string GENERAFOGLIODOMINI; //TODO: Federico. in questa pagina manca tutta la gestione di questa 'GENERAFOGLIODOMINI'. vedere tutto quello che manca per questa gestione rispetto alla xlsx.aspx originale

        private CommonDbFunctions cdf = new();

        private eProcurementNext.Session.ISession session;

        private TSRecordSet? rsDati;
        private TSRecordSet? rsColonne;

        public void Page_Load(HttpContext HttpContext, EprocResponse htmlToReturn, eProcurementNext.Session.ISession _session)
        {
            HttpResponse Response = HttpContext.Response;
            HttpRequest Request = HttpContext.Request;
            session = _session;

            var strQueryString = Request.QueryString.ToString();

            var TIPODOC = UCase(GetParamURL(strQueryString, "TIPODOC"));
            var idDoc = GetParamURL(strQueryString, "IDDOC");
            var HIDECOL = GetParamURL(strQueryString, "HIDECOL");
            var HIDE_COL = GetParamURL(strQueryString, "HIDE_COL");
            var MODEL = GetParamURL(strQueryString, "MODEL"); // -- se il model non è passato porto in output tutte le colonne ritornate dal recordset
            var POSITIONALMODELGRID = GetParamURL(strQueryString, "POSITIONALMODELGRID"); // --se passato ricopre il valore di MODEL
            var View = GetParamURL(strQueryString, "View");
            var OPERATION = UCase(GetParamURL(strQueryString, "OPERATION"));
            var TEMP_FOLDER_DOWNLOAD = GetParamURL(strQueryString, "fld");
            var ufp = GetParamURL(strQueryString, "UFP");
            var attivaStored = GetParamURL(strQueryString, "STORED_SQL");

            // --mi serve a capire se ho cambiato modo di recuperare i dati (se prima usavo una stored il filtro mi arriva in forma diversa)
            var OldSTORED_SQL = GetParamURL(strQueryString, "OldSTORED_SQL");

            var debug = GetParamURL(strQueryString, "DEBUG");

            View = View.Replace(" ", "").Replace("'", "''");

            var legend = GetParamURL(strQueryString, "LEGEND"); // -- Se passato conterr� il modello di filtro utilizzato per generare il foglio di lavoro di legenda
            var vexcel = GetParamURL(strQueryString, "vexcel");

            var mp_Info_User_Profile = Trim(CStr(GetParamURL(strQueryString, "FILTER_USER_PROFILE")));

            var mp_Sort = GetParamURL(strQueryString, "Sort");

            var guid = GetParamURL(strQueryString, "acckey");  // --access key tramite guid

            var filter = GetParamURL(strQueryString, "FILTER");
            var FilterHide = GetParamURL(strQueryString, "FilterHide");
            var owner = GetParamURL(strQueryString, "OWNER");

            var identity = GetParamURL(strQueryString, "IDENTITY");

            var HIDE_IDENTITY = GetParamURL(strQueryString, "HIDE_IDENTITY");

            if (string.IsNullOrEmpty(HIDE_IDENTITY.Trim()))
            {
                HIDE_IDENTITY = "YES";
            }

            var SortOrder = CStr(GetParamURL(strQueryString, "SortOrder"));

            if (string.IsNullOrEmpty(SortOrder.Trim()))
            {
                SortOrder = "asc";
            }

            if (string.IsNullOrEmpty(View))
            {
                View = GetParamURL(strQueryString, "table");
            }

            // -- se il parametro IDENTITY non è passato, assegno ID come default
            if (string.IsNullOrEmpty(identity.Trim()))
            {
                identity = "id";
            }

            // ----------------------------------
            // -- CASO D'USO XLSX DEL VIEWER ----
            // ----------------------------------
            if (vexcel == "1")
            {
                MODEL = GetParamURL(strQueryString, "ModGriglia");
                if (string.IsNullOrEmpty(MODEL))
                {
                    MODEL = View + "Griglia";
                }

                // --se passato ricopre il modello delle colonne da visualizzare
                // if POSITIONALMODELGRID <> "" Then
                // MODEL = POSITIONALMODELGRID
                // End If

                // Response.Write("MODEL=" & MODEL)
                // Response.end

                legend = GetParamURL(strQueryString, "ModelloFiltro");
                if (string.IsNullOrEmpty(legend))
                {
                    legend = View + "Filtro";
                }
            }

            int indCol = 0;
            int indRow = 0;
            string strCause = "";
            string strSQL = "";
            string strSQLExec = "";
            string strfilename = GetParamURL(strQueryString, "TitoloFile");
            //SqlConnection sqlConn1 = null
            SqlConnection? sqlConn2 = null;

            bool inoutput = true;
            string pathFile = "";

            // -- iniazializzo parametro SHOW_ATTACH per capire se gestire o meno i campi di tipo attach
            // -- il default è SI 
            string SHOW_ATTACH = "SI";

            if (!string.IsNullOrEmpty(GetParamURL(strQueryString, "SHOW_ATTACH")))
            {
                SHOW_ATTACH = GetParamURL(strQueryString, "SHOW_ATTACH");
            }

            string dettError = CStr(ApplicationCommon.Application["dettaglio-errori"]);

            debug = "YES";

            if (UCase(dettError) != "YES" && UCase(dettError) != "SI")
            {
                debug = "NO";
            }

            try
            {

                // ------------------------------------------
                // --- SICUREZZA. VALIDAZIONE INPUT ---------
                // ------------------------------------------

                validaInput("TIPODOC", TIPODOC, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("GENERAFOGLIODOMINI", GENERAFOGLIODOMINI, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("IDDOC", idDoc, TIPO_PARAMETRO_INT, "", HttpContext);
                validaInput("HIDECOL", HIDECOL.Replace(",", "") ?? "", TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("HIDE_COL", HIDE_COL.Replace(",", "") ?? "", TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("MODEL", MODEL, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("ModGriglia", MODEL, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("POSITIONALMODELGRID", POSITIONALMODELGRID, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("VIEW", View, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("table", View, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("OPERATION", OPERATION, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("UFP", ufp, TIPO_PARAMETRO_NUMERO, "", HttpContext);
                validaInput("STORED_SQL", attivaStored, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("LEGEND", legend, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("ModelloFiltro", legend, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("vexcel", vexcel, TIPO_PARAMETRO_NUMERO, "", HttpContext);
                string? tempStr = mp_Info_User_Profile.Replace(",", "").Replace(".", "").Replace(":", "");
                tempStr = tempStr ?? "";
                validaInput("FILTER_USER_PROFILE", tempStr, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("Sort", mp_Sort, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_SORT), HttpContext);
                validaInput("FILTER", filter, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_FILTROSQL), HttpContext);
                validaInput("FilterHide", FilterHide, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_FILTROSQL), HttpContext);
                validaInput("OWNER", owner, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("IDENTITY", identity, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("HIDE_IDENTITY", HIDE_IDENTITY, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("SortOrder", SortOrder, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("TitoloFile", strfilename, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("acckey", guid.Replace("-", "") ?? "", TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
                validaInput("SHOW_ATTACH", SHOW_ATTACH, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);

                string motivo = string.Empty;
                string strSQLwhereStored = string.Empty;

                // -------------------------------------------------------------------------------
                // -- SE L'OWNER MANCA MA PER L'OGGETTO SQL RICHIESTO è OBBLIGATORIO. BLOCCHIAMO -
                // -------------------------------------------------------------------------------

                if (string.IsNullOrEmpty(owner) && isOwnerObblig(View))
                {
                    motivo = "Privilege escalation : Tenativo di rimozione dell'owner";
                    sendBlock(paginaChiamata, motivo, HttpContext);
                }

                if (!string.IsNullOrEmpty(guid))
                {

                    getIdpfuFromGuid(guid);

                    if (documentPermission(TIPODOC, CStr(mp_idpfu), idDoc) == false)
                    {

                        motivo = "Permesso di accesso negato al download XLSX. Motivazione: [[" + strMotivoBlocco + "]] ";
                        sendBlock(paginaChiamata, motivo, HttpContext);

                    }

                }
                else
                {
                    //'-- se non sto passando da una chiamata con access guid e mp_idpfu è -20 e tra i parametri ho UFP, uso momentaneamente il valore di ufp per effettuare un test
                    //'--		di accesso al documento tramite le stored di permesso e poi torno a rimettere la variabile mp_idpfu a -20 ( per non rischiare di creare una falla usando l'idpfu passato come parametro per altri scopi )
                    if (!string.IsNullOrEmpty(ufp) && CInt(mp_idpfu) < 0)
                    {

                        mp_idpfu = CInt(ufp);

                        if (documentPermission(TIPODOC, CStr(mp_idpfu), idDoc) == false)
                        {

                            motivo = "Permesso di accesso negato al download XLSX. Motivazione: [[" + strMotivoBlocco + "]] ";
                            sendBlock(paginaChiamata, motivo, HttpContext);

                        }

                        mp_idpfu = -20;

                    }

                }

                getInfoUser();

                //'-- PER CAPIRE SE PROVENGO DA UN INVOCAZIONE PUBBLICA/PORTALE VERIFICO CHE :
                //'--     idpfu non presente
                //'--     parametro tipodoc con valori ( 'BANDO_GARA', 'BANDO_SDA', 'BANDO_FABBISOGNI', 'CONVENZIONE' , 'QUESTIONARIO_FABBISOGNI', 'LISTINO_CONVENZIONE','RICHIESTA_CODIFICA_PRODOTTI','CODIFICA_PRODOTTI', 'ANALISI_FABBISOGNI' )

                if (mp_idpfu < 0 && (TIPODOC == "QUESTIONARIO_PROGRAMMAZIONE" || TIPODOC == "BANDO_PROGRAMMAZIONE" || TIPODOC == "OFFERTA" || TIPODOC == "RDO" || TIPODOC == "BANDO_GARA" || TIPODOC == "BANDO_SEMPLIFICATO" || TIPODOC == "BANDO_SDA" || TIPODOC == "BANDO_FABBISOGNI" || TIPODOC == "CONVENZIONE" || TIPODOC == "CATALOGO_MEA" || TIPODOC == "QUESTIONARIO_FABBISOGNI" || TIPODOC == "LISTINO_CONVENZIONE" || TIPODOC == "RICHIESTA_CODIFICA_PRODOTTI" || TIPODOC == "CODIFICA_PRODOTTI" || TIPODOC == "ANALISI_FABBISOGNI" || TIPODOC == "SUB_QUESTIONARIO_FABBISOGNI" || TIPODOC == "LISTINO_ORDINI" || TIPODOC == "LISTINO_ORDINI_OE"))
                { //'And View = "" Then

                    mp_idpfu = -20;

                }
                else
                {

                    //'-- Se la provenienza della chiamata non è da portale, do un blocco per sessione non valida
                    if (mp_idpfu < 0)
                    {
                        htmlToReturn.Write("<h2>Sessione non valida</h2>");
                        sendBlock(paginaChiamata, "Session hijacking : Tentativo di accesso senza access guid", HttpContext);
                    }

                    if (checkPermission(View) == false)
                    {
                        motivo = "Privilege escalation : Accesso non consentito all'oggetto sql '" + View + "'";
                        sendBlock(paginaChiamata, motivo, HttpContext);
                    }

                }

                if (string.IsNullOrEmpty(strfilename))
                {
                    if (vexcel == "1")
                    {
                        strfilename = "List";
                    }
                    else
                    {
                        strfilename = "Articoli";
                    }
                }

                strfilename = strfilename + ".xlsx";

                strfilename = strfilename.Replace("..", "").Replace("/", "").Replace(@"\", ""); // -- replace per evitare Path Traversal

                // -----------------------------
                // --- FINE SICUREZZA. ---------
                // -----------------------------

                if (string.IsNullOrEmpty(OPERATION) || OPERATION == "DISPLAY" || OPERATION == "EXCEL")
                {
                    inoutput = true;
                }
                else
                {
                    inoutput = false;

                    strCause = "La directory di lavoro - campo fld in querystring - non valorizzato";

                    pathFile = TEMP_FOLDER_DOWNLOAD + strfilename;
                }

                // ------------------------------------
                // --- APRO LA CONNESSIONE CON IL DB --
                // ------------------------------------

                logDB("Inizio elaborazione. Superati i controlli di sicurezza", false, HttpContext);

                sqlConn2 = cdf.SetConnection(strConnectionString);
                sqlConn2.Open();

                if (HIDE_IDENTITY == "NO")
                {
                    HIDECOL = $",{CStr(HIDECOL).ToUpper()},IDROW,ID,NOTEDITABLE,TIPODOC,FNZ_DEL,FNZ_UDP,FNZ_ADD,OPEN_DOC_NAME,FNZ_OPEN,";
                }
                else
                {
                    HIDECOL = $",{CStr(HIDECOL).ToUpper()},IDROW,ID,NOTEDITABLE,TIPODOC,FNZ_DEL,FNZ_UDP,FNZ_ADD,OPEN_DOC_NAME,FNZ_OPEN,{identity.ToUpper()},";
                }

                // --parametro passato dal viewer
                if (!string.IsNullOrEmpty(HIDE_COL))
                {
                    HIDECOL += HIDE_COL + ",";
                }
                string strTableInput = string.Empty;

                if (attivaStored.ToUpper().Trim() == "YES")
                {
                    IFormCollection? form = Request.HasFormContentType ? Request.Form : null;

                    string strHiddenViewerCurFilter = GetParamURL(strQueryString, "hiddenViewerCurFilter");
                    string strHiddenViewerCurFilterFromForm = GetValueFromForm(Request, "hiddenViewerCurFilter");

                    if (!string.IsNullOrEmpty(strHiddenViewerCurFilter))
                    {
                        strSQLwhereStored = strHiddenViewerCurFilter;
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(strHiddenViewerCurFilterFromForm))
                        {
                            strSQLwhereStored = strHiddenViewerCurFilterFromForm;
                        }
                        else
                        {
                            if (form != null && form.Count > 0)
                            {
                                strSQLwhereStored = GetSqlWhereList(form);
                            }
                            else
                            {
                                strSQLwhereStored = filter;
                            }
                        }
                    }

                    string[] v;
                    strCause = "faccio la split #~#";
                    v = strSQLwhereStored.Split("#~#");

                    if ((v.Length - 1) > 1)
                    {
                        strSQLExec = $"exec {View}  {mp_idpfu} , '{v[0].Replace("'", "''")}' , '{v[1].Replace("'", "''")}' , '{v[2].Replace("'", "''")}' ";
                    }
                    else
                    {
                        strSQLExec = $"exec {View}  {mp_idpfu} , '' , '' , ''";
                    }

                    // response.write( strSQL)
                    // response.end
                    if (!string.IsNullOrEmpty(mp_Sort))
                    {
                        strSQLExec += $" , '{FilterHide.Replace("'", "''")}' , '{mp_Sort} {SortOrder}' , -1, 1";
                    }
                    else
                    {
                        strSQLExec += $" , '{FilterHide.Replace("'", "''")}', '', -1,  1";
                    }

                    //'--se passato un ulteriore parametro in querystring allora nella stored devo aggiungere colonne ad hoc per il foglio excel
                    if (GetParamURL(strQueryString, "ADD_COL_FOR_EXCEL") == "1")
                    {
                        strSQLExec += ", 1";
                    }

                    // --response.write(  strSQL )
                    // --response.end

                    // --chiamo la stored per risolvere passando il parametro STORED a YES
                    strSQL = $" if exists ( select name as tabella from sysobjects where name = '{View}_XLSX' ) ";
                    strSQL += " begin ";
                    strSQL += " 	set NOCOUNT ON ";
                    strSQL += $" 	select * into  #{View}_XLSX  from {View}_XLSX ";
                    strSQL += $" 	insert into #{View}_XLSX ";
                    strSQL += "	" + strSQLExec;
                    strSQL += $"       exec SP_XSLX_DECODIFICA_FOR_EXPORT '#{View}_XLSX' , '{MODEL.Replace("'", "''")}' , '' , '{lngSuffix}' , {mp_idpfu},'{HIDECOL.Replace("'", "''")}' , '' , '{mp_Sort}', '' , '{SHOW_ATTACH}'";
                    strSQL += " end ";
                    strSQL += " else ";
                    strSQL += " begin ";
                    strSQL += "	" + strSQLExec;
                    strSQL += " end ";

                    //'--response.write(  strSQL )
                    //'--response.end
                }
                else
                {
                    // -- compongo la select per il recupero dati
                    string sqlWhere = "";

                    // -- Se non sono su un viewer excel
                    if (vexcel != "1")
                    {
                        strTableInput = "Document_MicroLotti_Dettagli";

                        if (!string.IsNullOrEmpty(TIPODOC))
                        {
                            sqlWhere = $"tipodoc = '{TIPODOC.Replace("'", "''")}' and IdHeader = " + CStr(CLng(idDoc));
                        }
                        else
                        {
                            sqlWhere = "IdHeader = " + CStr(CLng(idDoc));
                        }
                        if (!string.IsNullOrEmpty(View))
                        {
                            strSQL = $"select * from {View} where tipodoc = '{TIPODOC.Replace("'", "''")}' and IdHeader = " + CStr(CLng(idDoc));

                            // TODO: attenzione qui a chiarire perchè qui sotto non c'é replace su View

                            strTableInput = View;
                        }
                        else
                            strSQL = $"select * from Document_MicroLotti_Dettagli with(nolock) where tipodoc = '{TIPODOC.Replace("'", "''")}' and IdHeader = " + CStr(CLng(idDoc));

                        if (!string.IsNullOrEmpty(FilterHide) && FilterHide != ",")
                        {
                            strSQL += " and " + FilterHide;
                            sqlWhere += " and " + FilterHide;
                        }

                        // -- accoda le condizione di sort 
                        // If Trim(mp_Sort) <> "" Then
                        // strSQL = strSQL & " order by " & mp_Sort
                        // sqlWhere = sqlWhere & " order by " & mp_Sort
                        // else
                        // strSQL = strSQL & " order by id"
                        // sqlWhere = sqlWhere & " order by id"
                        // End If

                        // -- gestione sort di default
                        if (string.IsNullOrEmpty(mp_Sort))
                        { 
                            mp_Sort = "id asc";
                        }
                    }
                    else
                    {
                        // TODO: verificare perché qui non è stato fatto il Replace in View
                        strTableInput = View;

                        strSQL = $"select * from {View}";

                        if (!string.IsNullOrEmpty(filter))
                        {
                            // --se mi arriva la filter nella forma per la stored (atttributi#~#valore#~#operatori) la converto nella forma per la vista
                            // --ad esempio: Titolo#@#Protocollo#~#'%Ordinativo %'#@#'%PI003885%'#~# like #@# like 

                            if (filter.Contains("#~#") && OldSTORED_SQL.ToUpper() == "YES")
                            {
                                string[] vFilter;
                                string[] listAttr;
                                string[] listVal;
                                string[] listOp;
                                int k = 0;

                                string filterNew;

                                filterNew = "";

                                vFilter = filter.Split("#~#");

                                if (vFilter.Length == 3)
                                {
                                    listAttr = vFilter[0].Split("#@#");
                                    listVal = vFilter[1].Split("#@#");
                                    listOp = vFilter[2].Split("#@#");

                                    for (k = 0; k <= listAttr.Length - 1; k++)
                                    {
                                        if (!string.IsNullOrEmpty(filterNew))
                                            filterNew = filterNew + " and ";

                                        filterNew += GetSqlWhere(legend, listAttr[k], listOp[k], listVal[k], sqlConn2);   // <---- verificare sto sqlConn2
                                    }

                                    filter = filterNew;
                                }
                            }

                            // response.write (filter)		
                            // response.end()

                            if (!string.IsNullOrEmpty(filter))
                            {
                                strSQL += " where " + filter;
                                sqlWhere = filter;
                            }

                            if (!string.IsNullOrEmpty(owner))
                            {
                                strSQL += $" and {owner} = '{mp_idpfu}'";
                                sqlWhere += $" and {owner} = '{mp_idpfu}'";
                            }
                        }
                        else if (!string.IsNullOrEmpty(owner))
                        {
                            strSQL += $" where {owner} = '{mp_idpfu}'";
                            sqlWhere = $"{owner} = '{mp_idpfu}'";
                        }

                        // -- accoda alla query il filtro implicito non visibile

                        // Response.Write("sqlWhere = " + sqlWhere + " - FilterHide = " & FilterHide & " - ")
                        // Response.end

                        if (!string.IsNullOrEmpty(FilterHide) && FilterHide != ",")
                        {
                            if (!strSQL.Contains(" where "))
                            {
                                strSQL += $" where {FilterHide}";
                                sqlWhere = FilterHide;
                            }
                            else
                            {
                                strSQL += $" and {FilterHide}";
                                sqlWhere += $" and ({FilterHide})";
                            }
                        }

                        if (!string.IsNullOrEmpty(mp_Info_User_Profile))
                        {
                            string filterUserProfile = Get_Filter_User_Profile(mp_Info_User_Profile, mp_idpfu, sqlConn2);  // <---- verificare sto sqlConn2

                            if (!string.IsNullOrEmpty(filterUserProfile))
                            {
                                if (!strSQL.Contains(" where "))
                                {
                                    strSQL += " where " + filterUserProfile;
                                    sqlWhere = filterUserProfile;
                                }
                                else
                                {
                                    strSQL += " and " + filterUserProfile;
                                    sqlWhere += " and " + filterUserProfile;
                                }
                            }
                        }

                        // -- aggiungo al sort la colonna identity per evitare ordinamenti errati sulle pagine

                        string strId1 = $" {mp_Sort.ToUpper()} ";
                        string strId2 = $" {identity.ToUpper()} ";

                        if (!string.IsNullOrEmpty(identity.Trim()))
                        {
                            if (!string.IsNullOrEmpty(mp_Sort.Trim()))
                            {
                                // -- se l'identity non � presente nel sort lo aggiungo

                                if (!strId1.Contains(strId2))
                                {
                                    // se non c'� il sortorder nel sort, lo aggiungiamo
                                    if (!strId1.Contains(" ASC ") && !strId1.Contains(" DESC "))
                                    {
                                        mp_Sort += " " + SortOrder;
                                        mp_Sort += $" , {identity} {SortOrder} ";
                                    }
                                }
                            }
                            else
                            {
                                mp_Sort = $" {identity} {SortOrder} ";// --& " asc"
                            }
                        }

                        // Response.Write(" SortOrder = " + SortOrder + " --- ")
                        // Response.end

                        if (!string.IsNullOrEmpty(mp_Sort.Trim()))
                        {
                            if (Strings.InStr(1, " " + Strings.UCase(mp_Sort) + " ", " " + "ASC" + " ") == 0 & Strings.InStr(1, " " + Strings.UCase(mp_Sort) + " ", " " + "DESC" + " ") == 0)
                            {
                                mp_Sort += " " + SortOrder;
                            }
                        }

                        // Response.Write(mp_Sort + " - ??? --- ")
                        // Response.end

                        // -- accoda le condizione di sort 
                        if (!string.IsNullOrEmpty(mp_Sort.Trim()))
                        {
                            strSQL += $" order by {mp_Sort}";
                        }
                    }

                    // Response.Write (HIDECOL)
                    // response.end

                    strSQL = $"exec SP_XSLX_DECODIFICA_FOR_EXPORT '{strTableInput}' , '{MODEL.Replace("'", "''")}' , '{sqlWhere.Replace("'", "''")}' , '{lngSuffix}' , {mp_idpfu},'{HIDECOL.Replace("'", "''")}' , '' , '{mp_Sort}', '' , '{SHOW_ATTACH}'";
                }

                // Response.write("A---" & strSQL & "---B<br>" & HIDECOL )
                // response.end

                strCause = "Eseguo query per recuperare i dati: " + strSQL;

                //sqlComm = new SqlCommand(strSQL, sqlConn1)
                //// Dim rsDati As TSRecordSet = sqlComm.ExecuteReader()

                //sqlComm.CommandTimeout = 180;

                rsDati = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, lTime: 180); // sqlComm.ExecuteReader()

                //SqlCommand sqlComm2 = null
                //SqlDataReader rsColonne = null

                if (!string.IsNullOrEmpty(MODEL.Trim()))
                {
                    // -- compongo la select per recuperare le colonne da inserire nel foglio di lavoro
                    strCause = "Eseguo la select per recuperare le colonne";
                    strSQL = $"exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV '{MODEL.Replace("'", "''")}' , '{HIDECOL.Replace("'", "''")}', 1 ,'{SHOW_ATTACH}','{strTableInput}'"; // --penultimo parametro ad 1 mi fa ritornare le descrizioni delle colonne gia in CNV																																															   
                    rsColonne = cdf.GetRSReadFromQuery_(strSQL, strConnectionString);  //sqlComm2.ExecuteReader()
                }

                string strVisualValue = "";
                int dztType = 0;
                string strFormat = "";

                // ------------------------------------
                // ------- INIZIALIZZO L'XSLX ---------
                // ------------------------------------

                strCause = "Inizializzo excelpackage";

                XLWorkbook wb;

                wb = new XLWorkbook();

                strCause = "Cancello il file precedente se presente";

                if (CommonStorage.ExistsFile(pathFile))
                {
                    CommonStorage.DeleteFile(pathFile);
                }

                strCause = "Aggiungo il foglio di lavoro dati";

                // Aggiugo lo sheet 'Dati'
                IXLWorksheet ws;
                ws = wb.Worksheets.Add("Dati");

                //ws.View.ShowGridLines = true // mostro la griglia
                ws.PageSetup.ShowGridlines = true;

                // --------------------------------------
                // -- CASO D'USO CON MODELLO DI OUTPUT --
                // --------------------------------------

                string listaColonne = "";
                string listaColonneType = "";
                string listaColonneFormat = "";
                int m = 0;

                if (!string.IsNullOrEmpty(MODEL.Trim()))
                {
                    // --------------------------------------------------
                    // -- CICLO SULLE COLONNE PER GENERARE LA TESTATA --
                    // --------------------------------------------------

                    //if (rsColonne.Read())
                    if (rsColonne is not null && rsColonne.RecordCount > 0)
                    {
                        GENERAFOGLIODOMINI = "NO"; //TODO: Federico, togliere questa riga. è stata inserita momentaneamente solo per risolvere tutti gli errori che stanno uscendo su puglia produzione

                        //'creo il foglio con i valori dei domini
                        if(GENERAFOGLIODOMINI.ToUpper() == "YES")
                        {
                            wb.Worksheets.Add("Domini");
                            
                        }

                        indCol = 1;
                        rsColonne.MoveFirst();
                        do
                        {
                            listaColonne = listaColonne + "###" + rsColonne["DZT_Name"];
                            listaColonneType = listaColonneType + "###" + rsColonne["DZT_Type"];
                            listaColonneFormat = listaColonneFormat + "@@@" + rsColonne["DZT_Format"];
                            strCause = "Lavoro la colonna " + CStr(indCol);
                            strVisualValue = CStr(rsColonne["Caption"]);
                            dztType = CInt(rsColonne["DZT_Type"]!);
                            strFormat = CStr(rsColonne["DZT_Format"]);
                            ws.Cell(1, indCol).Value = strVisualValue;

                            // -- se � una data e non ha una format specifica ne applico una di default
                            if (dztType == 6 && string.IsNullOrEmpty(strFormat))
                            {
                                strFormat = "dd/MM/yyyy";
                            }

                            // ---  IMPOSTO LA FORMAT SULLA COLONNA 
                            switch (dztType)
                            {
                                case 2:
                                case 6:
                                case 7:
                                    {
                                        strCause = "Imposto la format";
                                        strFormat = strFormat.Replace("~", "");
                                        ws.Column(indCol).Style.NumberFormat.SetFormat(strFormat);
                                        break;
                                    }

                                default:
                                    {
                                        // -- imposto il formato cella testo
                                        ws.Column(indCol).Style.NumberFormat.SetFormat("@");
                                        break;
                                    }
                            }

                            //'se il tipo è un dominio mi popolo il foglio con i valori DZT_Name

                            if((dztType == 4 || dztType == 5 || dztType == 8) && GENERAFOGLIODOMINI.ToUpper() == "YES")
                            {
                                string dtz_name = CStr(rsColonne["DZT_Name"]!);
                                int numeroRigheProcessate = 0;

                                //'popolo il foglio domini
                                // alla funzione ValidationRow, rispetto alla versione aspx, si trasmette l'intero workbook e il nome del foflio su ui lavorare)
                            }

                            strCause = "Imposto lo stile";
                            ws.Cell(1, indCol).Style.Font.Bold = true;
                            ws.Cell(1, indCol).Style.Protection.SetLocked(true);
                            ws.Column(indCol).AdjustToContents();
                            indCol = indCol + 1;
                            rsColonne.MoveNext();
                        }
                        //while (rsColonne.Read());// SE number, date , colored number// AD ESEMPIO "#,##0.00" o "dd/mm/yyyy"
                        while (!rsColonne.EOF);
                    }
                    else
                    {
                        throw new Exception(strCause + "Metadati per le colonne mancanti");
                    }
                }
                else
                {
                    indCol = 1;

                    // ----------------------------------------------
                    // -- CASO D'USO SENZA MODELLO DI OUTPUT --------
                    // -- L'OUTPUT 1:1 CON IL RECORDSET -------------
                    // ----------------------------------------------
                    for (int k = 0; k <= rsDati.Columns.Count - 1; k++)
                    {
                        strCause = "Generazione riga di intestazione. Lavoro la colonna " + CStr(k);

                        // -- recupero dinamicamente la natura della colonna restituita dal recordset ed in base al suo tipo utilizzo una format specifica
                        string nomeColonna = rsDati.Columns[k].ColumnName; //.GetName(k)
                                                                           //Type tipoColonna = rsDati.Columns[k].DataType //     .GetFieldType(k)
                                                                           //string strTipoColonna = Strings.UCase(CStr(tipoColonna.Name))
                        string strTipoColonna = rsDati.Columns[k].DataType.Name;

                        string strFormatCol = "@"; // -- il default lo lascio a stringa

                        switch (strTipoColonna)
                        {
                            case "INT32":
                                {
                                    strFormatCol = "#.##0"; // "###,###,##0" '#,##0.00
                                    break;
                                }

                            case "DOUBLE":
                                {
                                    strFormatCol = "#,##0.00"; // "###,###,##0.00###"
                                    break;
                                }

                            case "DATETIME":
                                {
                                    strFormatCol = "dd/mm/yyyy";
                                    break;
                                }

                            default:
                                {
                                    // String
                                    strFormatCol = "@";
                                    break;
                                }
                        }

                        // -- se la colonna sulla quale stiamo iterando non � presente nella lista di colonne da nascondere
                        //if (!HIDECOL.Contains("," + Strings.UCase(nomeColonna) + ",", StringComparison.Ordinal))
                        if (!HIDECOL.Contains("," + nomeColonna.ToUpper() + ",", StringComparison.Ordinal))
                        {
                            strCause = "Setto il formato stringa per la colonna " + CStr(k);

                            // -- imposto il formato della colonna 
                            ws.Column(indCol).Style.NumberFormat.SetFormat(strFormatCol);

                            ws.Cell(1, indCol).Value = nomeColonna;

                            strCause = "Imposto lo stile";
                            ws.Cell(1, indCol).Style.Font.Bold = true;
                            ws.Cell(1, indCol).Style.Protection.SetLocked(true);
                            ws.Column(indCol).AdjustToContents();

                            indCol = indCol + 1;
                        }
                    }
                }

                // --------------------------------------------------
                // --------------------- CICLO SUI DATI -------------
                // --------------------------------------------------
                object strTempVal;
                int posCol;
                string typeCol;

                string[] resSplit;
                string[] resSplitType;
                string[] resSplitFormat;

                resSplit = listaColonne.Split("###");
                resSplitType = listaColonneType.Split("###");
                resSplitFormat = listaColonneFormat.Split("@@@");

                // Response.write("A---" & listaColonne & "---B<br>")
                // Response.write("A---" & listaColonneType & "---B")

                //'response.end

                //'stampo la lista delle colonne del rsDati

                //' For k As Integer = 0 To rsDati.FieldCount - 1
                //'	response.write (rsDati.GetName(k) & "<br>")
                //'	response.end
                //' Next

                //if (rsDati.Read())
                if (rsDati != null && rsDati.RecordCount > 0)
                {
                    indRow = 2;
                    rsDati.MoveFirst();
                    do
                    {
                        // -- CICLO DELLE RIGHE

                        // --------------------------------------
                        // -- CASO D'USO CON MODELLO DI OUTPUT --
                        // --------------------------------------
                        if (!string.IsNullOrEmpty(CStr(MODEL.Trim())))
                        {
                            indCol = 1;

                            // -- non potendo fare una movefirst per ritornare all'inizio del recordset, rieseguo la query
                            // --sqlComm2.Dispose()
                            // --rsColonne.Close()

                            // --strCause = "Recupero le informazioni delle colonne"
                            // --strSQL = "exec GET_COLUMN_LOTTI_TO_EXTRACT_CSV '" & Replace(MODEL, "'", "''") & "' , '" & Replace(HIDECOL, "'", "''") & "', 1"
                            // --sqlComm2 = New SqlCommand(strSQL, sqlConn2)
                            // --rsColonne = sqlComm2.ExecuteReader()

                            // --rsColonne.Read()

                            for (m = 1; m <= resSplit.Length - 1; m++)
                            {
                                // --Do
                                // -- ciclo delle colonne

                                strVisualValue = "";

                                // Response.write("SCRIVO LA COLONNA " & resSplit(m))
                                // Response.Write(rsDati(resSplit(m)))

                                strCause = $"Lavoro la colonna {CStr(indCol)} - Nome = {resSplit[m]} e la riga {CStr(indRow)}";

                                // -- setto il valore nella cella
                                // --If Not IsDbNull(rsDati(rsColonne("DZT_Name"))) Then

                                // dim tmpStrTestVal as Object = rsDati(resSplit(m))

                                strCause = "Lavorobis la colonna  " + CStr(indCol) + " - Nome = [" + resSplit[m] + "] e la riga " + CStr(indRow) + " value =[" + rsDati[resSplit[m]] + "]";
                                if (!IsDbNull(rsDati[resSplit[m]]))
                                {
                                    // --posCol = rsDati.GetOrdinal(rsColonne("DZT_Name"))
                                    strCause = "Lavorotris la posCol " + m + " - typeCol = " + resSplit[m] + " e la riga " + CStr(indRow);

                                    //posCol = rsDati.GetOrdinal(resSplit[m])
                                    posCol = rsDati.Columns[resSplit[m]].Ordinal;
                                    //typeCol = UCase(rsDati.GetFieldType(posCol).Name)
                                    typeCol = UCase(rsDati.Columns[posCol].DataType.Name);

                                    // Response.write("A---" & typeCol & "---B")
                                    // Response.write("<br/>")
                                    // --per attributi numerici, se il tipo della colonna non � coerente con il dizionario lo trasformo in numerico
                                    // --if ( rsColonne("DZT_Type") = "2"  and  typeCol <> "INT32" and typeCol <> "DOUBLE" and Not IsDbNull( rsDati(rsColonne("DZT_Name")) ) )  then
                                    if ((resSplitType[m] == "2" & typeCol != "BOOLEAN" & typeCol != "INT32" & typeCol != "DOUBLE" & typeCol != "DECIMAL" & typeCol != "BYTE" & !IsDbNull(rsDati[resSplit[m]])))
                                    {
                                        strTempVal = "";

                                        // --strTempVal = rsDati(rsColonne("DZT_Name"))
                                        // long longValue = Convert.ToInt64(doubleValue)

                                        strTempVal = CStr(rsDati[resSplit[m]]);
                                        strCause = "typeCol=" + typeCol + " converto " + strTempVal + " da stringa in double tipo dizionario = " + resSplitType[m];

                                        // -- TEST PER IL REGIONAL SETTINGS
                                        //if (Strings.InStr(1, CStr(0.5), ",") > 0)
                                        //	strTempVal = Strings.Replace(CStr(strTempVal), ".", ",")

                                        if (CStr(0.5).Contains(","))
                                        {
                                            strTempVal = CStr(strTempVal).Replace(".", ",");
                                        }


                                        if (!string.IsNullOrEmpty(CStr(strTempVal)))
                                            ws.Cell(indRow, indCol).Value = System.Convert.ToDouble(strTempVal);
                                    }
                                    else if (resSplitType[m] == "6")
                                    {
                                        strCause = "tratto le date valore cella ='" + rsDati[resSplit[m]] + "' -- tipo dizionario=" + resSplitType[m];
                                        if (typeCol == "DATETIME")
                                            ws.Cell(indRow, indCol).Value = rsDati[resSplit[m]];
                                        else
                                            ws.Cell(indRow, indCol).Value = StrToDate(CStr(rsDati[resSplit[m]]));
                                    }
                                    else
                                    {
                                        strCause = "tratto gli altri tipi valore cella ='" + rsDati[resSplit[m]] + "' -- tipo dizionario=" + resSplitType[m];

                                        // --ws.Cells(indRow, indCol).Value = rsDati(rsColonne("DZT_Name"))
                                        // --ws.Cells(indRow, indCol).IsRichText = true
                                        // --se la format contiene la H allora applico la StripTags
                                        // --per togliere i tag html

                                        if (!resSplitFormat[m].ToUpper().Contains("H"))
                                        {
                                            ws.Cell(indRow, indCol).Value = rsDati[resSplit[m]];
                                        }
                                        else
                                        {
                                            ws.Cell(indRow, indCol).Value = StripTags(CStr(rsDati[resSplit[m]]));
                                        }
                                    }
                                }

                                // -- setto il valore nella cella
                                // ws.Cells(indRow, indCol).Value = strVisualValue

                                indCol = indCol + 1;
                            }
                        }
                        else
                        {
                            // ----------------------------------------
                            // -- CASO D'USO SENZA MODELLO DI OUTPUT --
                            // -- L'OUTPUT 1:1 CON IL RECORDSET -------
                            // ----------------------------------------

                            indCol = 1;
                            for (int k = 0; k <= rsDati.Columns.Count - 1; k++)
                            {
                                strCause = "Itero sulla colonna " + CStr(k);
                                string nomeColonna = rsDati.Columns[k].ColumnName;

                                // -- se la colonna sulla quale stiamo iterando non � presente nella lista di colonne da nascondere
                                //if (!HIDECOL.Contains("," + Strings.UCase(nomeColonna) + ",", StringComparison.Ordinal))
                                if (!HIDECOL.Contains($", {nomeColonna.ToUpper()},", StringComparison.Ordinal))
                                {
                                    strCause = "Inserisco nella griglia l'elemento di colonna " + CStr(indCol) + " e riga " + CStr(indRow);

                                    // -- setto il valore nella cella
                                    if (!IsDbNull(rsDati[nomeColonna]))
                                        // strVisualValue = rsDati(nomeColonna)
                                        ws.Cell(indRow, indCol).Value = rsDati[nomeColonna];

                                    // ws.Cells(indRow, indCol).Value = strVisualValue

                                    indCol = indCol + 1;
                                }
                            }
                        }

                        indRow = indRow + 1;
                        rsDati.MoveNext();
                    }
                    while (!rsDati.EOF);
                }

                // response.end()

                strCause = "Dispose dell'oggetto excel";
                strCause = "Chiudo i recordset";

                // -- se � stato richiesto lo sheet per la legenda
                // If (CStr(legend) <> "" And Request.Form.Count > 0) Or (CStr(legend) <> "" And vexcel = "1") Then
                if (!string.IsNullOrEmpty(legend))
                {
                    string msgElab = "";

                    strCause = "Creo lo sheet di legenda";

                    System.Text.StringBuilder strS = new System.Text.StringBuilder();

                    strS.AppendLine("SELECT        MA_DZT_Name AS                     field ," + Environment.NewLine);
                    strS.AppendLine("     dbo.CNV(MA_DescML , 'I') AS fldDesc ," + Environment.NewLine);
                    strS.AppendLine("     DZT_Type ," + Environment.NewLine);
                    strS.AppendLine("     ISNULL(DZT_DM_ID , '') AS          dominio," + Environment.NewLine);
                    strS.AppendLine("     isnull( isnull(c.MAP_Value,b.DZT_Format) ,'') as dztFormat," + Environment.NewLine);
                    strS.AppendLine("     dbo.CNV('Legenda.Data Elaborazione Excel', 'I') AS elabMlg" + Environment.NewLine);
                    strS.AppendLine(" FROM  LIB_ModelAttributes A" + Environment.NewLine);
                    strS.AppendLine("         INNER JOIN LIB_Dictionary B ON MA_DZT_Name = DZT_Name" + Environment.NewLine);
                    strS.AppendLine("         LEFT JOIN LIB_ModelAttributeProperties C ON C.MAP_MA_MOD_ID = MA_MOD_ID and c.MAP_MA_DZT_Name = a.MA_DZT_Name and c.MAP_Propety = 'format'" + Environment.NewLine);
                    strS.AppendLine("         LEFT JOIN LIB_ModelAttributeProperties D ON D.MAP_MA_MOD_ID = MA_MOD_ID and D.MAP_MA_DZT_Name = a.MA_DZT_Name and D.MAP_Propety = 'Hide'" + Environment.NewLine);
                    strS.AppendLine(" WHERE MA_MOD_ID = '" + legend.Replace("'", "''") + "' and isnull(d.map_value,'0') = '0'" + Environment.NewLine);
                    strS.Append(" ORDER BY MA_Order");

                    // response.write(strSQL)
                    // response.end()

                    //sqlComm2 = new SqlCommand(strSQL, sqlConn2)
                    //rsColonne = sqlComm2.ExecuteReader()

                    rsColonne = cdf.GetRSReadFromQuery_(strS.ToString(), strConnectionString);

                    //if (rsColonne.Read())
                    if (rsColonne is not null && rsColonne.RecordCount > 0)
                    {
                        rsColonne.MoveFirst();

                        IXLWorksheet/*ExcelWorksheet*/ wsLegend;
                        int indice;
                        int fieldType;
                        string val;
                        string nomeDominio;
                        string dztFormat;

                        indice = 1;
                        fieldType = 0;

                        wsLegend = wb.Worksheets.Add("Legenda");
                        // non mostro la griglia
                        wsLegend.PageSetup.ShowGridlines = false;

                        StringDictionary collFiltro = new();

                        strCause = "genero la collezione per i dati di legenda";

                        // If vexcel = "1" Then

                        // response.write( filter & "aaa<br>" & attivaStored)
                        // response.end()
                        if (!string.IsNullOrEmpty(strSQLwhereStored))
                        { 
                            collFiltro = getFormColl(attivaStored, strSQLwhereStored);
                        }
                        else
                        { 
                            collFiltro = getFormColl(attivaStored, filter);
                        }

                        do
                        {
                            strCause = "Ciclo sull'attributo : " + CStr(indice);
                            fieldType = CInt(rsColonne["DZT_Type"]!);
                            dztFormat = CStr(rsColonne["dztFormat"]);

                            // -- se non � un HR
                            if (fieldType != 16)
                            {
                                nomeDominio = CStr(rsColonne["dominio"]);
                                wsLegend.Cell(indice, 1).Value = rsColonne["fldDesc"] + " : ";
                                wsLegend.Cell(indice, 1).Style.Font.Bold = true;

                                strCause = "chiamata a getFilterVAlue per recuperare il valore di ricerca - colonna " + rsColonne["field"] + " - tipo=" + fieldType;
                                val = CStr(getFilterVAlue(CStr(rsColonne["field"]), Request.HasFormContentType ? Request.Form : null, collFiltro));

                                // response.write( rsColonne("field") & "=" & val & "<br>")

                                // -- se � un dominio
                                if ((fieldType == 4 || fieldType == 5 || fieldType == 8) && !string.IsNullOrEmpty(nomeDominio) && !string.IsNullOrEmpty(val))
                                {
                                    strCause = "Recupero il dominio dalla LIB_Domain";
                                    strSQL = "select isnull(dm_query,'') as query from LIB_Domain with(nolock) where dm_id = '" + Strings.Replace(nomeDominio, "'", "''") + "'";
                                    //sqlComm = new SqlCommand(strSQL, sqlConn1)
                                    //rsDati = sqlComm.ExecuteReader()

                                    rsDati = cdf.GetRSReadFromQuery_(strSQL, strConnectionString);

                                    //if (rsDati.Read())
                                    if (rsDati is not null && rsDati.RecordCount > 0)
                                    {
                                        string strQueryDom = CStr(rsDati["query"]);
                                        //rsDati.Close()

                                        // -- se non � presente la query sul dominio
                                        if (string.IsNullOrEmpty(strQueryDom.Trim()))
                                            strSQL = "select dbo.cnv_estesa(DMV_DescML,'I') as descml from LIB_DomainValues with(nolock) where DMV_DM_ID = '" + Strings.Replace(nomeDominio, "'", "''") + "' and ";
                                        else
                                        {
                                            string oldSql = strQueryDom;
                                            int ind = oldSql.ToUpper().IndexOf("ORDER BY");

                                            // -- tolgo la order by
                                            if (ind > -1)
                                            {
                                                oldSql = oldSql.Substring(0, ind);
                                            }

                                            strQueryDom = oldSql;
                                            strQueryDom = strQueryDom.Replace("#LNG#", "I");
                                            strSQL = "select dbo.cnv_estesa(DMV_DescML,'I') as descml from ( " + strQueryDom + " ) a where ";
                                        }

                                        // -- se il dominio � a valore singolo
                                        if (!val.Contains("###", StringComparison.Ordinal))
                                        {
                                            strSQL += $" DMV_Cod = '{val.Replace("'", "''")}'";
                                        }
                                        else
                                        {
                                            strSQL += $" DMV_Cod in ( select items from dbo.split('{val.Replace("'", "''")}','###'))";
                                        }
                                        strCause = "sto per eseguire la select '" + strSQL + "'";
                                        //sqlComm = new SqlCommand(strSQL, sqlConn1)
                                        //rsDati = sqlComm.ExecuteReader()
                                        rsDati = cdf.GetRSReadFromQuery_(strSQL, strConnectionString);
                                        //if (rsDati.Read())
                                        if (rsDati.RecordCount > 0)
                                        {
                                            rsDati.MoveFirst();
                                            do
                                            {
                                                // -- aggiungo per ogni elemento una riga in pi� cos� da mostrare l'elenco dei valori multipli selezionati su pi� righe
                                                val = CStr(rsDati["descml"]);
                                                wsLegend.Cell(indice, 2).Value = val;
                                                indice = indice + 1;
                                                rsDati.MoveNext();
                                            }
                                            //while (rsDati.Read());
                                            while (!rsDati.EOF);
                                            indice = indice - 1;
                                        }

                                        //rsDati.Close();
                                    }
                                }
                                else if (fieldType == 2 | fieldType == 6 | fieldType == 7)
                                {
                                    strFormat = "";
                                    if (fieldType == 6 & string.IsNullOrEmpty(dztFormat))
                                        strFormat = "dd/MM/yyyy";
                                    if ((fieldType == 2 | fieldType == 7) & string.IsNullOrEmpty(dztFormat))
                                        strFormat = "###,###,##0.00###";
                                    if (string.IsNullOrEmpty(strFormat))
                                        strFormat = dztFormat;
                                    //strFormat = Strings.Replace(CStr(strFormat), "mm", "MM");
                                    //strFormat = Strings.Replace(CStr(strFormat), "~", "");
                                    strFormat = CStr(strFormat).Replace("mm", "MM");
                                    strFormat = CStr(strFormat).Replace("~", "");
                                    //if (!_Information.IsDBNull(val))
                                    if (!IsDbNull(val))
                                    {
                                        strCause = "Ciclo sull'attributo per vari casi : colonna = " + rsColonne["field"] + " - Tipo = " + CStr(fieldType) + " - Valore = [" + CStr(val) + "]";
                                        if (fieldType == 6)
                                        {
                                            // --response.write (strFormat & "---"& val & "<br>" )

                                            if (!IsDate(val))
                                            {
                                                val = "";
                                            }
                                            else
                                            {
                                                // --if val.Length = 10 then
                                                // --	val = val & " 00:00:00.000"
                                                // --end if

                                                val = DateTime.Parse(val).ToString(strFormat);
                                            }
                                        }
                                        else
                                            try
                                            {
                                                val = double.Parse(val).ToString(strFormat);
                                            }
                                            catch (Exception ex5)
                                            {
                                                val = CStr(val);
                                            }
                                    }
                                    else
                                        val = "";
                                }
                                else
                                    strFormat = "@";
                                strCause = "Posiziono il valore nella cella";

                                // -- imposto indice formato della colonna 
                                wsLegend.Cell(indice, 2).Style.NumberFormat.SetFormat(strFormat);
                                if (fieldType != 4 & fieldType != 5 & fieldType != 8)
                                    wsLegend.Cell(indice, 2).Value = val;
                            }

                            indice = indice + 1;
                            msgElab = CStr(rsColonne["elabMlg"]);
                            rsColonne.MoveNext();
                        }
                        //while (rsColonne.Read());
                        while (!rsColonne.EOF);

                        strCause = "Aggiungo la data di elaborazione";

                        indice = indice + 1;

                        wsLegend.Cell(indice, 1).Value = msgElab;
                        wsLegend.Cell(indice, 2).Value = DateTime.Now.ToString("dd/MM/yyyy");

                        wsLegend.Column(1).AdjustToContents();
                        wsLegend.Column(2).AdjustToContents();
                    }

                    //rsColonne.Close();
                }

                // response.end()

                //rsColonne = null;
                //rsDati = null;

                strCause = "Chiudo le connessioni";

                //try
                //{
                //    sqlConn1.Close();
                //    sqlConn2.Close();
                //}
                //catch (Exception ex3)
                //{
                //}

                try
                {
                    //Nuovo codice
                    foreach (IXLWorksheet wsTemp in wb.Worksheets)
                    {
                        wsTemp.Columns().AdjustToContents();
                    }
                }
                catch
                {

                }

                if (inoutput)
                {
                    strCause = "Imposto il contentype di output";
                    Response.ContentType = "application/XLSX";

                    strCause = "aggiunto il content-disposition";
                    Response.Headers.TryAdd("content-disposition", "attachment; filename=" + strfilename.Replace(" ", "_"));

                    strCause = "effettuo il binaryWrite";

                    string tempPath = $"{CStr(ApplicationCommon.Application["PathFolderAllegati"])}{CommonStorage.GetTempName()}.xlsx";

                    wb.SaveAs(tempPath);

                    //Open the File into file stream

                    //Create and populate a memorystream with the contents of the
                    using FileStream fs = new System.IO.FileStream(tempPath, FileMode.Open, FileAccess.Read);
                    byte[] b = new byte[1024];
                    int len;
                    int counter = 0;
                    while (true)
                    {
                        len = fs.Read(b, 0, b.Length);
                        byte[] c = new byte[len];
                        b.Take(len).ToArray().CopyTo(c, 0);
                        htmlToReturn.BinaryWrite(HttpContext, c);
                        if (len == 0 || len < 1024)
                        {
                            break;
                        }
                        counter++;
                    }
                    fs.Close();

                    // delete the file when it is been added to memory stream
                    CommonStorage.DeleteFile(tempPath);

                    // Clear all content output from the buffer stream

                    //htmlToReturn.BinaryWrite(Response, pck.GetAsByteArray())
                    // Write the data out to the client.
                }
                else
                    //wb.Save()
                    wb.SaveAs(pathFile);

                wb.Dispose();
            }
            catch (Exception ex) when (ex is not EprocNextException)
            {
                traceError(strCause + " -- " + ex.ToString(), strQueryString);
                throw new Exception($"Errore generazione XLSX, {strCause} - {ex.Message}", ex);
            }
            finally
            {
                //if (sqlConn1 is not null)
                //    sqlConn1.Close()

                if (sqlConn2 is not null)
                    sqlConn2.Close();
            }
        }

        //private void traceError(SqlConnection sqlConn, string idpfu, string descrizione, string querystring)
        private void traceError(string descrizione, string querystring)
        {
            string sEvent;

            string strSEvent = $"Errore nella generazione del file XLSX.URL:{querystring} --- Descrizione dell'errore : {descrizione}";

            //sEvent = Strings.Left("Errore nella generazione del file XLSX.URL:" + querystring + " --- Descrizione dell'errore : " + descrizione, 4000)
            sEvent = TruncateMessage(strSEvent);

            ////strSQL = "INSERT INTO CTL_LOG_UTENTE (idpfu,datalog,paginaDiArrivo,querystring,descrizione) " + Environment.NewLine;
            ////strSQL = strSQL + " VALUES(" + idpfu + ", getdate(), '" + contesto + "', '" + Strings.Replace(typeTrace, "'", "''") + "', '" + Strings.Replace(sEvent, "'", "''") + "')";

            //////var sqlComm = new SqlCommand(strSQL, sqlConn);

            //////if (sqlConn.State != System.Data.ConnectionState.Open)
            //////{
            //////    sqlConn.Open();
            //////}
            //////sqlComm.ExecuteNonQuery();

            ////cdf.Execute(strSQL,strConnectionString, sqlConn);


            WriteToEventLog(sEvent);
        }

        // -- ritorna tre stringhe contenenti separatamente la lista degli attributi, la lista delle condizioni e la lista dei valori
        // -- da passare alla stored per il recupero dati
        public string GetSqlWhereList(IFormCollection form)
        {
            int nf;
            int i;
            string ListAtt;
            string ListCond;
            string ListVal;
            string condition = "="; // non serve rendarla dinamica. metto come condition fissa l'uguaglianza

            ListAtt = "";
            ListCond = "";
            ListVal = "";

            nf = form.Count;

            for (i = 0; i <= nf - 1; i++)
            {
                if (!string.IsNullOrEmpty(form.ElementAt(i).Value))
                {
                    ListAtt = ListAtt + "#@#" + form.Keys.ElementAt(i);
                    ListCond = ListCond + "#@#" + condition;
                    ListVal = ListVal + "#@#" + ("'" + form.ElementAt(i).Value + "'"); // -- tratto tutti i campi come stringa. lascio alla stored il compito di gestirlo nel modo + appropriato per il contesto d'uso
                }
            }

            //if (!string.IsNullOrEmpty(ListAtt))
            //	ListAtt = Strings.Mid(ListAtt, 4)
            //if (!string.IsNullOrEmpty(ListCond))
            //	ListCond = Strings.Mid(ListCond, 4)
            //if (!string.IsNullOrEmpty(ListVal))
            //	ListVal = Strings.Mid(ListVal, 4)


            // VB mid in base 1
            // substring in base 0

            if (!string.IsNullOrEmpty(ListAtt)) ListAtt = ListAtt.Substring(3);
            if (!string.IsNullOrEmpty(ListCond)) ListCond = ListCond.Substring(3);
            if (!string.IsNullOrEmpty(ListVal)) ListVal = ListVal.Substring(3);

            return ListAtt + "#~#" + ListVal + "#~#" + ListCond;
        }

        public StringDictionary getFormColl(string stored, string mp_Filter)
        {
            // response.write (mp_Filter & "<br>") 

            string[] v;
            string strFilter = "";
            string[] p;
            StringDictionary collezione = new StringDictionary();
            int i;

            if (!string.IsNullOrEmpty(mp_Filter))
            {
                if (Trim(UCase(stored)) != "YES")
                {
                    // If stored <> "yes" Then

                    v = Strings.Split(Strings.LCase(mp_Filter), " and ");

                    for (i = 0; i <= v.GetUpperBound(0); i++)
                    {
                        strFilter = v[i];
                        strFilter = strFilter.Trim();

                        strFilter = strFilter.Replace("'", "");

                        if (strFilter.Contains("="))
                            p = strFilter.Split("=");
                        else
                        {
                            strFilter = strFilter.Replace("%", "");
                            p = strFilter.ToLower().Split(" like ");
                        }

                        p[1] = p[1].Trim().Replace("'", "");
                        p[1] = p[1].Trim().Replace(")", "");

                        // -- Aggiunto attributo e valore

                        // --ripulisco nome attributo di eventuale convert applicate alle date come ad es.:
                        // --convert( varchar(10) , DataScadenzaOfferta , 121 ) >= '2018-05-05' and convert( varchar(10) , DataScadenzaA , 121 ) <= '2018-05-10' 
                        //p[0] = Strings.Replace(p[0], "convert( varchar(10) , ", "");
                        //p[0] = Strings.Replace(p[0], " , 121 ) ", "");
                        //p[0] = Strings.Replace(p[0], ">", "");
                        //p[0] = Strings.Replace(p[0], "<", "");
                        //p[0] = Strings.Replace(p[0], "#", "");
                        //p[0] = Strings.Replace(p[0], "(", "");
                        //p[0] = Strings.Replace(p[0], "+", "");


                        p[0] = p[0].Replace("convert( varchar(10) , ", "");
                        p[0] = p[0].Replace(" , 121 ) ", "");
                        p[0] = p[0].Replace(">", "");
                        p[0] = p[0].Replace("<", "");
                        p[0] = p[0].Replace("#", "");
                        p[0] = p[0].Replace("(", "");
                        p[0] = p[0].Replace("+", "");

                        // response.write (Trim(p(0)).ToLower & "------" &  p(1) & "<br>")
                        //collezione.Add(Strings.Trim(p[0]).ToLower(), p[1]);
                        collezione.Add(p[0].Trim().ToLower(), p[1]);
                    }
                }
                else
                {
                    string[] vAtt;
                    string[] vVal;
                    string[] vCond;
                    string p2 = "";

                    v = mp_Filter.Split("#~#");
                    vAtt = v[0].Split("#@#");
                    vVal = v[1].Split("#@#");
                    vCond = v[2].Split("#@#");

                    for (i = 0; i <= vAtt.GetUpperBound(0); i++)
                    {
                        p2 = vVal[i].Trim().Replace("'", "");

                        // -- Aggiunto attributo e valore
                        collezione.Add(vAtt[i].Trim().ToLower(), p2);
                    }
                }
            }

            return collezione;
        }

        public string getFilterVAlue(string key, IFormCollection? form, StringDictionary coll)
        {
            string @out = "";

            key = key.ToLower();

            // If vexcel = "1" Then
            if (form == null || form.Count == 0)
            {
                @out = coll[key];
            }
            else
            {
                @out = form[key];
            }

            return @out;
        }

        // --restituisce il pezzo di statement relativo al filtro basato sulla profilazione utente
        private string Get_Filter_User_Profile(string mp_Info_User_Profile, int mp_User, SqlConnection sqlConn2)
        {
            string tempFilterProfile = string.Empty;
            string[] aInfo;
            string[] aInfo1;
            int nNumAttrib = 0;
            int i = 0;
            string strSql = string.Empty;
            TSRecordSet? rs = new TSRecordSet();
            string strColMyMessage = string.Empty;

            if (!string.IsNullOrEmpty(mp_Info_User_Profile))
            {
                aInfo1 = mp_Info_User_Profile.Split(':');
                if (aInfo1.GetUpperBound(0) == 1)
                {
                    strColMyMessage = aInfo1[1];
                }

                aInfo = aInfo1[0].Split(',');
                nNumAttrib = aInfo.GetUpperBound(0);

                for (i = 0; i <= nNumAttrib; i++)
                {
                    string mp_strcause = "costruzione filter user profile idpfu=" + mp_User + " attrib=" + aInfo[i];
                    strSql = $"select attvalue from profiliutenteattrib where idpfu={mp_User} and dztnome='{aInfo[i].Replace("'", "''")} '";

                    rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString);

                    if (rs is not null)
                    {
                        if (rs.RecordCount > 0)
                        {
                            if (!string.IsNullOrEmpty(tempFilterProfile))
                            {
                                tempFilterProfile = tempFilterProfile + " and ";
                            }

                            tempFilterProfile += "( " + aInfo[i] + " in (select attvalue from profiliutenteattrib where idpfu=" + mp_User + " and dztnome='" + aInfo[i].Replace("'", "''") + "' )";
                            //'--se indicata la colonna per prendere comunque i documenti fatti dall'utente collegato
                            if (!String.IsNullOrEmpty(strColMyMessage))
                            {
                                tempFilterProfile = tempFilterProfile + " or " + strColMyMessage + "=" + mp_User;
                            }

                            tempFilterProfile = tempFilterProfile + " )";
                        }
                    }
                }
            }

            return tempFilterProfile;
        }

        public void sendBlock(string paginaAttaccata, string motivo, Microsoft.AspNetCore.Http.HttpContext HttpContext)
        {
            addSecurityBlockTrace(paginaAttaccata, motivo, HttpContext);
            throw new ResponseRedirectException("../blocked.asp", HttpContext.Response);
        }

        public void addSecurityBlockTrace(string paginaAttaccata, string motivo, HttpContext HttpContext)
        {
            const int MAX_LENGTH_ip = 97;
            const int MAX_LENGTH_paginaAttaccata = 294;
            const int MAX_LENGTH_motivoBlocco = 3994;

            string ipChiamante = string.Empty;
            string strQueryString = string.Empty;

            try
            {
                ipChiamante = eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.net_utilsModel.getIpClient(HttpContext.Request);/*Request.UserHostAddress;*/
                strQueryString = GetQueryStringFromContext(HttpContext.Request.QueryString);//Request.QueryString;
            }
            catch (Exception ex)
            {
                ipChiamante = string.Empty;
            }

            try
            {
                var sqlParams = new Dictionary<string, object?>()
                {
                    { "@ip", TruncateMessage(ipChiamante, MAX_LENGTH_ip)},
                    {"@paginaAttaccata", TruncateMessage(paginaAttaccata, MAX_LENGTH_paginaAttaccata)},
                    {"@queryString", strQueryString},
                    {"@idpfu", mp_idpfu},
                    { "@motivoBlocco",  TruncateMessage(motivo, MAX_LENGTH_motivoBlocco)}
                };
                string strsql = "INSERT INTO [CTL_blacklist] ([ip],[statoBlocco],[dataBlocco],[dataRefresh],[numeroRefresh],[paginaAttaccata],[queryString],[idPfu],[form],[motivoBlocco])";
                strsql = strsql + " VALUES (@ip, 'log-attack', getdate(), null, 0, @paginaAttaccata, @queryString, @idpfu, null, @motivoBlocco)";
                
                CommonDbFunctions cdf = new();
                cdf.Execute(strsql, strConnectionString, parCollection: sqlParams);
            }
            catch (Exception ex)
            {
            }
        }

        public bool checkPermission(string strSqlTable)
        {
            string strSql;
            bool ret;
            string permesso;

            ret = true; //'autorizzato

            //'se non c'è la stringa dei permessi utente
            if (string.IsNullOrEmpty(strPermission))
            {
                //checkPermission = True
                return true;
            }

            if (!string.IsNullOrEmpty(strSqlTable))
            {
                SqlConnection sqlConn = new SqlConnection(strConnectionString);
                try
                {
                    sqlConn.Open();

                    strSql = "select lfn_paramtarget + '&' as params, ISNULL(lfn_pospermission,'-1') as permesso from lib_functions with(nolock) where lfn_paramtarget like '%TABLE=" + strSqlTable.Replace("'", "''") + "&%'";

                    SqlCommand sqlComm = new SqlCommand(strSql, sqlConn);
                    SqlDataReader rs = sqlComm.ExecuteReader();

                    if (!(rs.Read()))
                    {
                        ret = false; //'non autorizzato
                    }
                    else
                    {
                        rs.Close();

                        sqlComm = new SqlCommand(CStr(strSql + " and permesso = '-1'"), sqlConn);
                        rs = sqlComm.ExecuteReader();

                        //' Se c'è almeno un permesso a NULL allora l'utente è autorizzato, altrimenti controlliamo il permesso
                        if (!(rs.Read()))
                        {
                            rs.Close();

                            sqlComm = new SqlCommand(CStr(strSql + " and permesso <> '-1'"), sqlConn);
                            rs = sqlComm.ExecuteReader();

                            ret = false; //'fino a che non trovo un permesso per l'utente rispetto all'oggetto sql a cui vuole accedere, lo considero non autorizzato

                            bool forzaUscita = false;

                            while (!rs.Read() && !forzaUscita)
                            {
                                permesso = CStr(rs["permesso"]);

                                //'-- Se il permesso è 0 è autorizzato per chiunque
                                if (CLng(permesso) > 0)
                                {
                                    //' Se il permesso non è disabilitato
                                    if (strPermission.Substring(CInt(permesso) - 1, 1) != "0")
                                    {
                                        ret = true;

                                        forzaUscita = true; //'forzo l'uscita dal ciclo
                                    }
                                }
                                else
                                {
                                    ret = true;
                                    forzaUscita = true; //'forzo l'uscita dal ciclo
                                }
                            }
                        }
                    }

                    rs.Close();
                }
                catch (Exception ex)
                {
                    ret = true; //'autorizzato
                }
                finally
                {
                    sqlConn.Close();
                }
            }

            return ret;

        }

        public bool isOwnerObblig(string oggettoSQL)
        {
            try
            {
                oggettoSQL = UCase(oggettoSQL);
                if (ApplicationCommon.Application[APPLICATION_OWNERLIST].ContainsKey(oggettoSQL))
                {
                    return true;
                }
            }
            catch 
            { 
            }

            return false;
        }

        public void logDB(string messaggio, bool errore, HttpContext HttpContext, string browser = "ASPX")
        {
            try
            {
                string ip = "";
                string strSql = "";
                string level = "INFO";
                string queryString = "";

                if (errore)
                {
                    level = "ERROR";
                }
                ip = eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.net_utilsModel.getIpClient(HttpContext.Request);
                queryString = GetQueryStringFromContext(HttpContext.Request.QueryString);

                strSql = "INSERT INTO CTL_LOG_UTENTE(ip,idpfu,datalog,paginaDiArrivo,paginaDiPartenza,querystring,form,browserUsato,sessionID) VALUES ('" + ip.Replace("'", "''") + "'," + CStr(CLng(mp_idpfu)) + ",getdate(),'LOG-" + level + "','" + paginaChiamata.Replace("'", "''") + "','" + queryString.Replace("'", "''") + "','" + messaggio.Replace("'", "''") + "','" + browser.Replace("'", "''") + "','" + mp_sessionID.Replace("'", "''") + "')";
                cdf.Execute(strSql, strConnectionString);
            }
            catch (Exception ex)
            {
            }
        }

        public void getIdpfuFromGuid(string guid)
        {
            //var sqlConn = new SqlConnection(strConnectionString);
            //sqlConn.Open();

            //string strSql = "select * from CTL_ACCESS_BARRIER with(nolock) where guid = '" + Strings.Replace(guid, "'", "''") + "' and datediff(SECOND, data,getdate()) <= 30";

            //SqlCommand sqlComm = new SqlCommand(strSql, sqlConn);
            //TSRecordSet rs = sqlComm.ExecuteReader();

            //if ((rs.Read))
            //{
            mp_idpfu = session["idpfu"];//rs.Fields["idpfu"];
            mp_sessionID = session.SessionID;// rs.Fields["sessionid"];
                                             //}

            //rs.Close();
            //sqlConn.Close();

        }

        public bool documentPermission(string tipoDocumento, string idpfu, string IDDOC)
        {
            bool bEsito = true;

            if (string.IsNullOrEmpty(tipoDocumento) || string.IsNullOrEmpty(idpfu))
            { 
                return true;
            }

            string strSql = "select isnull(DOC_DocPermission,'') as DOC_DocPermission from LIB_DOCUMENTS with(nolock) where DOC_ID = @tipoDocumento";

            Dictionary<string, object?> sqlParams = new() { { "@tipoDocumento", tipoDocumento } };

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, sqlParams);

            if (rs is not null && rs.RecordCount > 0)
            {
                rs.MoveFirst();

                string nomeStored = CStr(rs["DOC_DocPermission"]);

                if (!string.IsNullOrEmpty(nomeStored))
                {
                    strSql = "exec " + nomeStored + " @idpfu , @IDDOC";

                    strMotivoBlocco = strSql;

                    sqlParams.Clear();
                    sqlParams.Add("@idpfu", CInt(idpfu));
                    sqlParams.Add("@IDDOC", IDDOC);

                    rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, sqlParams);

                    if (rs is not null && rs.RecordCount == 0)
                        bEsito = false;
                }
            }

            return bEsito;
        }

        // --ritorna la forma clausola where per un attributo	
        public string GetSqlWhere(string strModello, string strAttributo, string strOperatore, string strValore, SqlConnection sqlConn2)
        {
            int nf;
            int i;
            string strWhere;
            string v;
            int k;
            string[] alistvalue;
            int FType;
            string strSQL;
            string strcondition;

            if (!string.IsNullOrEmpty(strModello))
            {
                // --carico le info dell'attributo  dal modello
                strSQL = "SELECT        top 1 MA_DZT_Name," + Environment.NewLine;
                strSQL = strSQL + "     DZT_Type ,isnull(DZT_MultiValue,0) as DZT_MultiValue," + Environment.NewLine;
                strSQL = strSQL + "     isnull( isnull(F.MAP_Value,b.DZT_Format) ,'') as DZT_Format," + Environment.NewLine;
                strSQL = strSQL + "     isnull(C.MAP_Value,'=') as Condition" + Environment.NewLine;
                strSQL = strSQL + " FROM  LIB_ModelAttributes A" + Environment.NewLine;
                strSQL = strSQL + "         INNER JOIN LIB_Dictionary B ON MA_DZT_Name = DZT_Name" + Environment.NewLine;
                strSQL = strSQL + "         LEFT JOIN LIB_ModelAttributeProperties F ON F.MAP_MA_MOD_ID = MA_MOD_ID and F.MAP_MA_DZT_Name = B.DZT_Name and F.MAP_Propety = 'format'" + Environment.NewLine;
                strSQL = strSQL + "         LEFT JOIN LIB_ModelAttributeProperties C ON C.MAP_MA_MOD_ID = MA_MOD_ID and c.MAP_MA_DZT_Name = B.DZT_Name and c.MAP_Propety = 'SQLCondition'" + Environment.NewLine;
                strSQL = strSQL + " WHERE MA_MOD_ID = '" + strModello.Replace("'", "''") + "' and MA_DZT_Name='" + strAttributo.Replace("'", "''") + "'" + Environment.NewLine;
                strSQL = strSQL + " ORDER BY MA_Order";
            }
            else
            {
                // --carico le info dell'attributo dal dizionario
                strSQL = "SELECT        top 1 DZT_Name," + Environment.NewLine;
                strSQL = strSQL + "     DZT_Type ,isnull(DZT_MultiValue,0) as DZT_MultiValue," + Environment.NewLine;
                strSQL = strSQL + "     isnull(DZT_Format ,'') as DZT_Format," + Environment.NewLine;
                strSQL = strSQL + "     '=' as Condition" + Environment.NewLine;
                strSQL = strSQL + "     FROM LIB_Dictionary " + Environment.NewLine;
                strSQL = strSQL + " 	WHERE DZT_Name='" + strAttributo.Replace("'", "''") + "'" + Environment.NewLine;
            }

            // response.write(strSQL)
            // response.end()

            SqlCommand? sqlComm3 = null;
            SqlDataReader? rsAttributi = null;
            sqlComm3 = new SqlCommand(strSQL, sqlConn2);
            rsAttributi = sqlComm3.ExecuteReader();

            strWhere = strAttributo + strOperatore + strValore;

            if (rsAttributi.Read())
            {
                strWhere = "";

                if (!string.IsNullOrEmpty(strValore))
                {
                    strcondition = Trim(CStr(rsAttributi["Condition"]));
                    FType = CInt(rsAttributi["DZT_Type"]);

                    // -- Se � un dominio normale, esteso o gerarchico ed � multivalue
                    if ((FType == 4 || FType == 5 || FType == 8) && (CInt(rsAttributi["DZT_MultiValue"]) == 1 || InStr(1, CStr(rsAttributi["DZT_Format"]), "M") > 0))
                    {
                        // --per i multivalore faccio tanti OR sui valori selezionati
                        string tempvale;
                        tempvale = strValore.Replace("'", "");
                        alistvalue = tempvale.Split("###");

                        string strSql1;
                        string stroperator;
                        string strFieldName;

                        if (strcondition.ToLower().Contains("like"))
                        {
                            strcondition = " like ";
                        }
                        strSql1 = "";
                        stroperator = " OR ";

                        if (strcondition.ToLower() == "likeand")
                        {
                            stroperator = " AND ";
                        }


                        for (k = 0; k <= alistvalue.GetUpperBound(0); k++)
                        {
                            if (!string.IsNullOrEmpty(alistvalue[k]))
                            {
                                strFieldName = strAttributo;

                                if (strcondition.Trim() == "like" || strcondition.Trim() == "=")
                                {
                                    strFieldName = " '###' + " + strFieldName + " + '###' ";
                                }

                                if (string.IsNullOrEmpty(strSql1))
                                {
                                    strSql1 = strSql1 + strFieldName + " " + strcondition + " ";
                                }
                                else
                                {
                                    strSql1 = strSql1 + stroperator + strFieldName + " " + strcondition + " ";
                                }

                                if (Strings.Trim(strcondition) == "like")
                                {
                                    v = alistvalue[k].Replace("*", "%");
                                    v = "'%###" + v + "###%'";
                                    strSql1 = strSql1 + v;
                                }
                                else
                                {
                                    strSql1 = strSql1 + "'###" + alistvalue[k] + "###'";
                                }
                            }
                        }

                        strWhere = strWhere + " ( " + strSql1 + " ) ";
                    }
                    else if (FType == 6 || FType == 22)
                    {

                        // -- per gli attributi di tipo data se la formattazione della data � dd/mm/yyyy si taglia l'orario
                        if (LCase(CStr(rsAttributi["DZT_Format"])) == "dd/mm/yyyy" || LCase(CStr(rsAttributi["DZT_Format"])) == "mm/dd/yyyy")
                        {
                            strWhere = strWhere + " convert( varchar(10) , " + strAttributo + " , 121 ) ";
                            strWhere = strWhere + " " + strcondition + " ";
                            strWhere = strWhere + strValore.Substring(0, 11) + "'";
                        }
                        else
                        {
                            strWhere = strWhere + strAttributo;
                            strWhere = strWhere + " " + strcondition + " ";
                            strWhere = strWhere + strValore;
                        }
                    }
                    else
                    {
                        strWhere = strWhere + strAttributo;


                        // -- Se testo ,textarea o email
                        if (FType == 1 | FType == 3 | FType == 14)
                        {
                            strcondition = "like";

                            strWhere = strWhere + " " + strcondition + " ";

                            string specialCharLeft;
                            string specialCharRight;

                            specialCharLeft = "%";
                            specialCharRight = "%";

                            v = strValore.Replace("*", "%");

                            if (strcondition.ToUpper() == "LIKE")
                            {

                                // -- Se la condizione � di like e nel valore che si � inserito
                                // -- c'� all'inizio o alla fine della stringa la parantesi quadra,
                                // -- vuol dire che si sta cercando una parola che inizia o finisce
                                // -- nel modo richiesto e non si vuole cercare all'interno della stringa
                                // -- utilizzando cio� il % ( che rimane il default ). Se invece
                                // -- si scrive [xxx] vuol dire che si sta cercando solo le parole esatte xxx
                                // -- e non verranno messi i % ne prima ne dopo

                                if (v.Length >= 3)
                                {
                                    if (v.Substring(1, 1) == "[")
                                    {
                                        specialCharLeft = "";

                                        // -- tolgo il [ all'inizio
                                        v = "'" + Strings.Right(v, Strings.Len(v) - 2);
                                    }

                                    if (Strings.Left(Strings.Right(v, 2), 1) == "]")
                                    {
                                        specialCharRight = "";

                                        // -- tolgo il ] alla fine
                                        v = Strings.Left(v, Strings.Len(v) - 2) + "'";
                                    }
                                }
                            }

                            v = "'" + specialCharLeft + Strings.Mid(v, 2, Strings.Len(v) - 2) + specialCharRight + "'";

                            strWhere = strWhere + v;
                        }
                        else
                        {
                            strWhere = strWhere + " " + strcondition + " ";
                            strWhere = strWhere + strValore;
                        }
                    }
                }
            }

            rsAttributi.Close();


            return strWhere;
        }


        public string StripTags(string html)
        {

            // Remove HTML tags.

            string replacementstring = "";
            string matchpattern = @"<(?:[^>=]|='[^']*'|=""[^""]*""|=[^'""][^\s>]*)*>";
            return Regex.Replace(html, matchpattern, replacementstring, RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Multiline | RegexOptions.Singleline);
        }

        // --converte la data dal formato tecnico in una data
        public DateTime StrToDate(string strValue)
        {

            // --esempio data formato tecnico 2012-03-22T11:00:00
            if (strValue.Length == 10)
                strValue = strValue + " 00:00:00";

            if (strValue.Length == 19)
                return new DateTime(CInt(strValue.Substring(0, 4)), CInt(strValue.Substring(5, 2)), CInt(strValue.Substring(8, 2)), CInt(strValue.Substring(11, 2)), CInt(strValue.Substring(14, 2)), CInt(strValue.Substring(17, 2)));

            return new DateTime();
        }

        public void getInfoUser()
        {
            if (mp_idpfu > 0)
            {

            }
            else
            {

                SqlConnection sqlConn = new SqlConnection(strConnectionString);
                sqlConn.Open();

                string strSql = "select isnull(lngSuffisso,'I') as suffisso, pfuFunzionalita from profiliutente with(nolock) left join lingue ON idlng = pfuidlng where idpfu = " + CStr(CLng(mp_idpfu));



                SqlCommand sqlComm = new SqlCommand(strSql, sqlConn);
                SqlDataReader rs = sqlComm.ExecuteReader();

                if (rs.Read())
                {

                    lngSuffix = CStr(rs["suffisso"]);
                    strPermission = CStr(rs["pfuFunzionalita"]);

                }
            }
        }

        public void validaInput(string nomeParametro, string valoreDaValidare, int tipoDaValidare, string sottoTipoDaValidare, HttpContext HttpContext, string regExp = "")
        {
            Validation objSecurityLib;
            bool isAttacked = false;

            //if (_Information.Err.Number != 0)
            //{
            //    htmlToReturn.Write($@"ERRORE DI REGISTRAZIONE NELLA DLL CtlSecurity");
            //    throw new ResponseEndException(htmlToReturn.Out(), Response, "");
            //}

            if (string.IsNullOrEmpty(sottoTipoDaValidare.Trim()))
                sottoTipoDaValidare = CStr(0);

            if (!string.IsNullOrEmpty(CStr(valoreDaValidare).Trim()))
            {
                try
                {
                    objSecurityLib = new Validation(); //Server.CreateObject("CtlSecurity.Validation")
                }
                catch (Exception ex)
                {
                    return;
                }

                //try
                //{
                //	strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB;", "");
                //	strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.1;", "");
                //	strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.2;", "");
                //	strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.3;", "");
                //}
                //catch (Exception ex)
                //{
                //}

                switch (tipoDaValidare)
                {
                    case TIPO_PARAMETRO_FLOAT:
                    case TIPO_PARAMETRO_INT:
                    case TIPO_PARAMETRO_NUMERO:
                        {
                            if (!IsNumeric(valoreDaValidare))
                                isAttacked = true;
                            break;
                        }

                    case TIPO_PARAMETRO_DATA:
                        {
                            if (!IsDate(valoreDaValidare))
                                isAttacked = true;
                            break;
                        }

                    default:
                        {
                            switch (CInt(sottoTipoDaValidare))
                            {
                                //case SOTTO_TIPO_PARAMETRO_TABLE:
                                case SOTTO_TIPO_PARAMETRO_PAROLASINGOLA:
                                    {
                                        if (!objSecurityLib.isValidValue(valoreDaValidare, 1))
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_SORT:
                                    {
                                        if (!objSecurityLib.isValidSqlSort(valoreDaValidare, ""))
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_FILTROSQL:
                                    {
                                        if (!objSecurityLib.isValidFilterSql(valoreDaValidare, ""))
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_LISTANUMERI:
                                    {
                                        if (!objSecurityLib.isValidValue(valoreDaValidare, 4))
                                            isAttacked = true;
                                        break;
                                    }
                            }

                            break;
                        }
                }

                if (isAttacked)
                {

                    // Response.Write("BLOCCO!Parametro:" & nomeParametro)
                    // Response.Write("Valore:" & valoreDaValidare)
                    // Response.End()

                    string motivo = "";

                    try
                    {
                        motivo = "Injection, CtlSecurity.validate() : Tenativo di modifica del parametro '" + nomeParametro + "'";
                    }
                    catch (Exception ex)
                    {
                    }

                    sendBlock(paginaChiamata, motivo, HttpContext);
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="wb">Il workBook su cui lavorare in quanto non è possibile passare il foglio di lavoro Domini come in passato</param>
        /// <param name="worksheet">Nome del worksheet su cui lavorare</param>
        /// <param name="numero_colonna"></param>
        /// <param name="DZT_Name"></param>
        /// <param name="titolo"></param>
        /// <param name="numeroRigheProcessate"></param>
        private void ValidationRow(XLWorkbook wb, string worksheet, int numero_colonna, string DZT_Name, string titolo, ref int numeroRigheProcessate)
        {
            // attenzione: per impostare la cella di un worksheet va passato prima il parametro della colonna e poi il valore della cella
            try
            {

            }
            catch (Exception ex)
            {

            }
        }

        string GetModelAttributePropertiesFilter(string DZT_Name)
        {
            string esito = " IsNull(DMV_Deleted, 0) = 0 ";
            string stringaFiltro = string.Empty;

            if (!String.IsNullOrEmpty(MODEL))
            {
                Dictionary<string, object> param = new Dictionary<string, object>();
                param.Add("@MODEL", MODEL);
                param.Add("@DZT_name", DZT_Name);
                string libSQL = "select MAP_Value from LIB_ModelAttributeProperties where MAP_Propety = 'Filter' and MAP_MA_MOD_ID = @MODEL and MAP_MA_DZT_Name = @DZT_Name";
                string ctlSQL = "select MAP_Value from CTL_ModelAttributeProperties where MAP_Propety = 'Filter' and MAP_MA_MOD_ID = @MODEL and MAP_MA_DZT_Name = @DZT_Name";
                try
                {
                    string obj = (string)cdf.ExecuteScalar_(libSQL, strConnectionString, parCollection: param);
                    if (!String.IsNullOrEmpty(obj))
                    {
                        stringaFiltro = obj.Substring(10).Replace("<ID_USER>", ufp);

                    }
                    else
                    {
                        obj = (string)cdf.ExecuteScalar_(ctlSQL, strConnectionString, parCollection: param);
                        stringaFiltro = obj.Substring(10).Replace("<ID_USER>", ufp);
                    }
                    if (!String.IsNullOrEmpty(obj))
                    {
                        esito += "and " + stringaFiltro;
                    }

                }
                catch
                {

                }
                
            }
            return esito;
        }

    }
}

