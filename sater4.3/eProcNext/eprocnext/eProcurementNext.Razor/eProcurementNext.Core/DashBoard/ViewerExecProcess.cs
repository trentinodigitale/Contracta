using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.DashBoard
{
    public class ViewerExecProcess
    {

        private HttpContext _httpContext;
        private Session.ISession _session;
        private IEprocResponse _response;

        private Session.ISession mp_ObjSession; //////'-- oggetto che contiene il vettore base con gli elementi della libreria

        private string mp_Suffix;
        private long mp_User;
        private string mp_Nome;
        private string mp_Cognome;
        private string mp_Permission;
        private string mp_strConnectionString;
        private string mp_strModelloAdd;

        private Form mp_objForm;
        private Model mp_objModel;
        private ButtonBar mp_ObjButtonBar;
        private Caption mp_objCaption;
        private Toolbar mp_objToolbar;


        private Dictionary<string, Field> mp_Columns;
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty;
        private LibDbModelExt mp_objDB;

        private string mp_Filter;
        private string mp_NumeroPagina;
        private string mp_Sort;
        private string mp_queryString;
        private string mp_IDENTITY;

        private string mp_strcause;

        private string Request_QueryString;
        private IFormCollection? Request_Form = null;

        private string mp_strTable;
        private string mp_RSConnectionString;


        private long mp_idDoc;

        private string mp_StrMsgBox;
        private string mp_ICONMSG;
        private string mp_StrMsg;

        private string[] mp_vetId;

        private Grid mp_objGrid;
        private Fld_Label mp_objHelp;

        private TSRecordSet mp_Rs;

        private string mp_Document;
        private string mp_Process;

        private string mp_strField;
        private string mp_strKey;
        private string mp_idDocType;

        private string[] mp_vetDocType;

        private string mp_Command;
        private string mp_idRow;

        private int mp_Row_For_Page;
        private long mp_numRec;
        //private mp_SelectionRow As Variant  //////'-- array di interi per definire le selezioni della griglia // non usato nel file

        private int mp_Ico;
        private string mp_StrTitle;
        private string mp_JSUpdateScreen;
        private string mp_strErrAdd;//////'-- contiene la motivazione di errore sull'inserimento in tabella della lista
        private int idRow;
        private dynamic[,] mp_Matrix = new dynamic[0, 0];
        private bool mp_DrawProgressBar;


        CommonDbFunctions cdf = new CommonDbFunctions();

        public ViewerExecProcess(HttpContext httpContext, Session.ISession session, IEprocResponse response)
        {
            this._httpContext = httpContext;
            this._session = session;
            this._response = response;
        }

        public void run(EprocResponse response)
        {
            //DebugTrace dt = new DebugTrace();
            //dt.Write("Passaggio a ViewerExecProcess.run");
            ////'-- recupero variabili di sessione
            InitLocal(_session);

            ////'-- Controlli di sicurezza
            if ((checkHackSecurity(_session, response) == true))
            {

                //'Se � presente NOMEAPPLICAZIONE nell'application
                if ((!string.IsNullOrEmpty(CStr(ApplicationCommon.Application["NOMEAPPLICAZIONE"]))))
                {

                    throw new ResponseRedirectException("/" + ApplicationCommon.Application["NOMEAPPLICAZIONE"] + "/blocked.asp", this._httpContext.Response);
                    //Exit Function


                }
                else
                {

                    throw new ResponseRedirectException("/application/blocked.asp", this._httpContext.Response);
                    //Exit Function


                }


            }

            if (GetParamURL(Request_QueryString, "MODE") == "Execute")
            {
                ////'-- in questa fase deve eseguire singolarmente il processo ed aggiornare la griglia

                if (InitGUIObject() == true)
                {
                    Draw_Execute(_session, "", response);  // verificare html se contiene il reload della pagina 
                }
                else
                {
                    response.Write($@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);



                    ////'--aggiunto parametri per far capire al parent cosa aggiornare
                    response.Write($@"try{{ parent.opener.parent.RefreshContent('ViewerExecProcess','" + GetParamURL(Request_QueryString, "PROCESS_PARAM") + $@"'); }} catch( e ) {{" + Environment.NewLine);
                    if (IsMasterPageNew())
                    {
                        response.Write($@"try{{ parent.parent.location = parent.parent.location; }} catch( e ) {{ }};" + Environment.NewLine);
                    }
                    response.Write($@"try{{ parent.opener.parent.location = parent.opener.parent.location; }} catch( e ) {{}}; }};" + Environment.NewLine);
                    

                    response.Write("</script>" + Environment.NewLine);

                }

            }
            else
            {

                ////'-- Inizializzo gli oggetti dell'interfaccia
                InitGUIObject();


                ////'-- disegna la lista dei ricambi
                Draw(_session, "", response);
                return;

            }


            return;

        }

        public void Draw(Session.ISession session, string Filter, EprocResponse response)
        {

            try
            {

                ////'----------------------------------
                ////'-- avvia la scrittura della pagina
                ////'----------------------------------


                switch (CStr(GetParamURL(Request_QueryString, "OPERATION")))
                {


                    //'        Case "PRINT"
                    //'
                    //'            Call Draw_Print(session, Filter, response)
                    //'
                    //'        Case "EXCEL"
                    //'
                    //'            Call Draw_Excel(session, Filter, response)

                    default:
                        Draw_Layout(session, Filter, response);
                        break;

                }

            }
            catch (Exception ex)
            {
                throw new Exception(mp_strcause + ex.Message, ex);
            }

        }

        public void Draw_Layout(Session.ISession session, string Filter, EprocResponse response)
        {

            Dictionary<string, string> JS = new Dictionary<string, string>();

            try
            {
                Window win = new Window();

                ////'----------------------------------
                ////'-- avvia la scrittura della pagina
                ////'----------------------------------


                ////'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";
                mp_objGrid.JScript(JS, "../CTL_Library/");



                ////'-- inserisce i java script necessari
                mp_strcause = "inserisce i java script necessari";
                response.Write(JavaScript(JS));


                response.Write(Title(ApplicationCommon.CNV("Esecuzione processo", mp_ObjSession)));

                if (IsMasterPageNew())
                {
					response.Write($@"</head><body style=""background:white"">" + Environment.NewLine);

				}
				else
                {
                    response.Write("</head><body>" + Environment.NewLine);
                }

                response.Write("<table width='100%' height='100%'>");



                ////'-- disegna la caption
                mp_strcause = "disegna la caption";
                response.Write("<tr  ><td width='100%'>");
                mp_objCaption = new Caption();
                mp_objCaption.Init(mp_ObjSession);
                mp_objCaption.Style = "Caption_Fixed";
                response.Write(mp_objCaption.SetCaption(ApplicationCommon.CNV(GetParamURL(Request_QueryString, "CAPTION"), mp_ObjSession)));
                response.Write("</td></tr>");



                ////'--se richiesto disegno la progressbar
                if (mp_DrawProgressBar)
                {
                    if (IsMasterPageNew())
                    {
						
                    }
                    else
                    {
					    response.Write("<tr><td class='Sep_Row_ProgressBar' width='100%'  >&nbsp;" + Environment.NewLine);
                        response.Write("</td></tr>");


                        ////'-- disegna la progress bar
                        mp_strcause = "disegna la progress bar";
                        response.Write("<tr><td id='Div_ProgressBar' class='cellProgressBar' width='100%'  >" + Environment.NewLine);



                        //'response.Write($@"<div  id=""Div_ProgressBar""  class=""progress""></div>"


                        response.Write("</td></tr>");
                    }


                }






                ////'-- disegna la griglia
                mp_strcause = "disegna la griglia";
                response.Write($"<tr  ><td width='100%' class='cellGridExecProcess' >");
                mp_objGrid.Html(response);
                response.Write($"</td></tr>");



                response.Write("<tr><td height='100%'>&nbsp;" + Environment.NewLine);
                response.Write("</td></tr>");



                response.Write("</table>");


                ////'--inserisco il frame nascosto per eseguire i processi
                response.Write(HTML_iframe("Viewer_Command", $@"ViewerExecProcess.asp?MODE=Execute&" + Request_QueryString, 0, " style='display:none' "));

                ////'-- inserisco il JS per copiare la riga nella tabella
                response.Write("<script type='text/javascript' language='javascript'>" + Environment.NewLine);
                response.Write($@"function SetHtml( objName , html ){{");
                response.Write($@"var obj = getObj( objName );");


                response.Write($@"alert( objName );");
                response.Write($@"alert( obj.innerHTML );");
                response.Write($@"obj.innerHTML = html;}}" + Environment.NewLine);
                response.Write($@"</script>" + Environment.NewLine);



                //'mp_objGrid.DrawLockedHtml Response


                //Set JS = Nothing


            }
            catch (Exception ex)
            {
                //Set JS = Nothing
                throw new Exception(ex.Message + mp_strcause);
                //RaiseError mp_strcause


            }


        }

        private void InitLocal(Session.ISession session)
        {

            string sort;
            mp_ObjSession = session;

            //On Error Resume Next
            int PosSuperUser;

            mp_Suffix = CStr(session[Session.SessionProperty.SESSION_SUFFIX]);
            if (string.IsNullOrEmpty(mp_Suffix))
            {
                mp_Suffix = "I";
            }

            mp_strConnectionString = ApplicationCommon.Application["ConnectionString"];//session[Session.SessionProperty.SESSION_CONNECTIONSTRING]
            Request_QueryString = GetQueryStringFromContext(_httpContext.Request.QueryString);//session[Session.SessionProperty.RequestQueryString]
            Request_Form = _httpContext.Request.HasFormContentType ? _httpContext.Request.Form : null;//session(Session.SessionProperty.RequestForm)


            mp_User = CLng(session["IdPfu"]);
            mp_Permission = CStr(session["Funzionalita"]);



            mp_queryString = CStr(Request_QueryString);



            //'mp_Caption = Request_QueryString("CAPTION")

            try
            {
                mp_idDoc = CLng(GetParamURL(Request_QueryString, "IDLISTA"));
            }
            catch { }

            mp_vetId = Strings.Split(GetParamURL(Request_QueryString, "IDLISTA"), "~~~");


            mp_idDocType = GetParamURL(Request_QueryString, "DOCLISTA");
            mp_vetDocType = Strings.Split(GetParamURL(Request_QueryString, "DOCLISTA"), "~~~");


            try
            {
                mp_idDoc = CLng(GetParamURL(Request_QueryString, "IDLISTA").Replace("~~~", ","));
            }
            catch
            {

            }



            string[] vP;

            //vP = Strings.Split(CStr(GetParamURL(Request_QueryString, "PROCESS_PARAM")), ",");
            vP = Strings.Split(GetParamURL(Request_QueryString, "PROCESS_PARAM"), ",");

            mp_Document = vP[1];
            mp_Process = vP[0];

            mp_strTable = GetParamURL(Request_QueryString, "TABLE");
            mp_strField = GetParamURL(Request_QueryString, "FIELD");
            mp_strKey = GetParamURL(Request_QueryString, "KEY");





        }

        private bool InitGUIObject()
        {

            //Dim objDBFunction As Object
            //Dim objDB As Object
            TSRecordSet rs = null;
            bool bAllColumn;
            bAllColumn = true;
            string strSort;
            Field objfield;
            string[] v;
            string[] v1;
            int i;
            int R;
            int c;

            bool intToReturn = true;


            //'Set mp_objForm = New CtlHtml.Form
            //'Set mp_ObjButtonBar = New CtlHtml.ButtonBar



            mp_objGrid = new Grid();
            Grid_ColumnsProperty objProp;




            ////'-- creo la collezione di colonne per la griglia
            mp_Columns = new Dictionary<string, Field>();
            mp_ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();



            ////'-- aggiungo il nome
            v = Strings.Split(mp_strField, ",");
            for (i = 0; i <= (v.Length - 1); i++)
            {
                //objfield = new Field();
                v1 = Strings.Split(v[i], ":");
                if ((v1.Length - 1) > 0)
                {
                    objfield = eProcurementNext.HTML.BasicFunction.getNewField(1);
                    objfield.Init(1, CStr(v1[0]), "");
                    objfield.Caption = ApplicationCommon.CNV(CStr(v1[0]), mp_ObjSession);
                    mp_Columns.Add(CStr(v1[0]), objfield); //'mp_strKey
                    if (!string.IsNullOrEmpty(v1[1]))
                    {
                        objProp = new Grid_ColumnsProperty();
                        objProp.width = v1[1];
                        mp_ColumnsProperty.Add(v1[0], objProp);
                    }
                }
                else
                {
                    objfield = eProcurementNext.HTML.BasicFunction.getNewField(1);
                    objfield.Init(1, CStr(v[i]), "");
                    objfield.Caption = ApplicationCommon.CNV(CStr(v[i]), mp_ObjSession);
                    mp_Columns.Add(CStr(v[i]), objfield); //'mp_strKey
                }
            }




            ////'-- aggiungo l'icona
            objfield = eProcurementNext.HTML.BasicFunction.getNewField(11);
            objfield.Init(11, "ICO", "wait.gif", null, null, "I");
            objfield.Caption = " ";
            objProp = new Grid_ColumnsProperty();
            objProp.width = "15";
            mp_ColumnsProperty.Add("ICO", objProp);



            mp_Columns.Add("ICO", objfield);



            ////'-- aggiungo il messaggio di esito
            //Set objfield = New CtlHtml.field
            objfield = eProcurementNext.HTML.BasicFunction.getNewField(1);
            objfield.Init(1, "MSG", "");
            objfield.Caption = ApplicationCommon.CNV("Esito", mp_ObjSession);


            mp_Columns.Add("MSG", objfield);

            //'Dim objProp As Grid_ColumnsProperty
            objProp = new Grid_ColumnsProperty();
            objProp.Wrap = true;
            objProp.width = "100%";
            mp_ColumnsProperty.Add("MSG", objProp);


            ////'-- l'indice del messaggio per cui far l'operazione
            if (string.IsNullOrEmpty(GetParamURL(Request_QueryString, "IndexToProcess")))
            {


                ////'-- creo una matrice per contenere tutti gli elementi
                //mp_Matrix = new dynamic[mp_Columns.Count + 1, mp_vetId.Length]; // - 1];
                mp_Matrix = new dynamic[mp_Columns.Count + 1, mp_vetId.Length - 1 + 1]; // - 1];


                ////'-- recupero il recordset degli elementi selezionati
                if (!string.IsNullOrEmpty(mp_idDocType))
                {
                    mp_Rs = GetRSGridDoc(GetParamURL(Request_QueryString, "IDLISTA"), GetParamURL(Request_QueryString, "DOCLISTA"));  
                }
                else
                {
                    mp_Rs = GetRSGrid(GetParamURL(Request_QueryString, "IDLISTA"));
                }


                ////'-- carico la matrice con il RS
                for (R = 1; R <= mp_Rs.RecordCount; R++)
                {

                    for (c = 0; c <= v.Length - 1; c++)
                    {
                        string vName = mp_Columns.ElementAt(c + 1 - 1).Value.Name;
                        mp_Matrix[c, R - 1] = mp_Rs.Fields[vName];
                    }
                    ////'-- memorizzo l'id del documento
                    mp_Matrix[v.Length - 1 + 1, R - 1] = "wait.gif";
                    mp_Matrix[mp_Columns.Count, R - 1] = mp_Rs.Fields[mp_strKey];
                    mp_Rs.MoveNext();

                }

                _session["MATRICE_PROCESSO"] = mp_Matrix;
                mp_queryString = mp_queryString + "&IndexToProcess=0";

                ////'--lettura parametro per vedere se disegnare la progressbar
                mp_DrawProgressBar = false;

                //Dim objDBParam As Object
                TSRecordSet rs1;
                string strSql;
                int nSogliaProcessi;

                strSql = "select dbo.PARAMETRI('VIEWER_EXECPROCESS','SOGLIA_PROGRESSBAR','DefaultValue',5,-1) as SogliaProcessi";


                //Set objDBParam = CreateObject("ctldb.clsTabManage")
                rs1 = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);
                //Set objDBParam = Nothing



                if (rs1.RecordCount > 0)
                {
                    rs1.MoveFirst();
                    nSogliaProcessi = CInt(rs1.Fields["SogliaProcessi"]);


                    if ((mp_vetId.Length - 1 + 1) > nSogliaProcessi)
                    {


                        mp_DrawProgressBar = true;


                    }


                }


                //CloseRecordset(rs1);



            }
            else
            {

                string strICO;
                mp_Matrix = _session["MATRICE_PROCESSO"];


                ////'-- l'indice del messaggio per cui faer l'operazione
                idRow = CInt(GetParamURL(Request_QueryString, "IndexToProcess"));


                ////'-- controllo se ho gi� eseguito tutti i processi
                if (idRow > (mp_vetId.Length - 1))
                {
                    intToReturn = false;
                    return intToReturn;
                }


                mp_queryString = ReplaceInsensitive(mp_queryString, "&IndexToProcess=" + idRow, "");
                mp_queryString = mp_queryString + "&IndexToProcess=" + (idRow + 1);


                ////'-- recupero il record del documento processato
                if (string.IsNullOrEmpty(mp_idDocType))
                {
                    ////'-- eseguo il processo iesimo
                    DashBoardMod.ExecuteProcess(mp_ObjSession, mp_Document, mp_Process, CLng(mp_Matrix[mp_Columns.Count, idRow]), mp_User, ref mp_StrTitle, ref mp_Ico, ref mp_StrMsg, mp_strConnectionString);

                }
                else
                {
                    ////'-- eseguo il processo iesimo
                    DashBoardMod.ExecuteProcess(mp_ObjSession, CStr(mp_vetDocType[idRow]), mp_Process, CLng(mp_Matrix[mp_Columns.Count, idRow]), mp_User, ref mp_StrTitle, ref mp_Ico, ref mp_StrMsg, mp_strConnectionString);
                }


                ////'-- inserisco l'esito nella griglia
                switch (mp_Ico)
                {
                    case 1:             //'"info.gif"
                        strICO = "State_OK.gif";
                        break;
                    case 2:                 //'"err.gif"
                        strICO = "State_Err.gif";
                        break;
                    case 3:             //'"ask.gif"
                        strICO = "ask.gif";
                        break;
                    case 4:             //'"ask.gif"
                        strICO = "State_Warning.gif";
                        break;

                    default:

                        strICO = "State_OK.gif";
                        break;


                }


                //mp_Matrix[v.Length - 1 + 1, idRow] = strICO;
                // mp_Matrix[v.Length -1 +1, idRow] = strICO;
                mp_Matrix[v.Length - 1 + 1, idRow] = strICO;

                //On Error Resume Next


                ////'-- se c'� stato un eccezione di runtime dal processo e non un errore 'funzionale'
                if (!string.IsNullOrEmpty(CStr(mp_StrMsg)) && mp_StrMsg.Contains("Numero :", StringComparison.Ordinal))
                {

                    if (string.IsNullOrEmpty(CStr(ApplicationCommon.Application["dettaglio-errori"])) || CStr(ApplicationCommon.Application["dettaglio-errori"]).ToLower() == "yes")
                    {
                        mp_Matrix[v.Length - 1 + 2, idRow] = mp_StrMsg;
                    }
                    else
                    {
                        mp_Matrix[v.Length - 1 + 2, idRow] = CStr(ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", mp_ObjSession) + CStr(DateAndTime.Now));
                    }

                }
                else
                {

                    mp_Matrix[v.Length - 1 + 2, idRow] = mp_StrMsg;

                }

                //On Error GoTo 0

                _session["MATRICE_PROCESSO"] = mp_Matrix;

            }



            ////'-- inizializzo la griglia
            mp_strcause = "inizializzo la griglia del catalogo";
            mp_objGrid.Columns = mp_Columns;
            mp_objGrid.ColumnsProperty = mp_ColumnsProperty;

            mp_objGrid.SetMatrixDisposition(false);
            mp_objGrid.SetMatrix(mp_Matrix);
            mp_objGrid.id = "Grid";
            mp_objGrid.width = "100%";

            mp_objGrid.Editable = false;

            mp_Rs = rs;

            return intToReturn;


        }

        public TSRecordSet GetRSGrid(string ListId)
        {
            string strSql = "";
            try
            {

                //Dim mp_objDB As Object
                TSRecordSet rs;



                strSql = "select * from " + mp_strTable + " where " + mp_strKey + " in ( " + ListId.Replace("~~~", ",") + " ) order by " + mp_strKey;


                //Set mp_objDB = CreateObject("ctldb.clsTabManage")
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);
                //Set mp_objDB = Nothing





                return rs;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + "DashBoard.ViewerExecProcess.GetRSGrid( " + strSql + " )");
            }

        }

        public TSRecordSet GetRSGridDoc(string ListId, string ListDOC)
        {
            string strSql = "";
            TSRecordSet? RSToReturn = null;

            try
            {

                if (string.IsNullOrEmpty(ListDOC))
                {
                    RSToReturn = GetRSGrid(ListId);
                }
                else
                {
                    //Dim mp_objDB As Object
                    TSRecordSet rs;
                    //Dim strSql As String

                    string[] v_id;
                    string[] v_Doc;

                    v_id = Strings.Split(ListId, "~~~");
                    v_Doc = Strings.Split(ListDOC, "~~~");


                    int i;


                    strSql = "select * from " + mp_strTable + " where ( " + mp_strKey + " =  " + v_id[0] + " and OPEN_DOC_NAME = '" + v_Doc[0] + "' ) ";
                    for (i = 1; i <= v_id.Length - 1; i++)
                    {
                        strSql = strSql + " or ( " + mp_strKey + " =  " + v_id[i] + " and OPEN_DOC_NAME = '" + v_Doc[i] + "' ) ";
                    }


                    strSql = strSql + " order by " + mp_strKey + " , OPEN_DOC_NAME ";


                    //Set mp_objDB = CreateObject("ctldb.clsTabManage")
                    rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);
                    //Set mp_objDB = Nothing



                    RSToReturn = rs;


                    return RSToReturn;
                }
            }
            catch (Exception ex)
            {
                //Set mp_objDB = Nothing
                throw new Exception(ex.Message + "DashBoard.ViewerExecProcess.GetRSGrid( " + strSql + " )");
                //RaiseError "DashBoard.ViewerExecProcess.GetRSGrid( " & strSql & " )"
            }

            return RSToReturn;

        }

        private void InitGUIObject_Execute()
        {
            throw new NotImplementedException("Funzione non usata nei sorgenti");
        }

        public void Draw_Execute(Session.ISession session, string Filter, EprocResponse response)
        {

            Dictionary<string, string> JS = new Dictionary<string, string>();


            try
            {
                //'Dim win As New CtlHtml.Window
                int i;


                int rimanenti;
                int percentage;
                int TotElements;
                Field objfield;


                //'----------------------------------
                //'-- avvia la scrittura della pagina
                //'----------------------------------


                //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";


                JS.Add("getObj", @"<script src=""../ctl_library/jscript/getObj.js"" ></script>");
                mp_objGrid.JScript(JS, "../CTL_Library/");



                //'-- inserisce i java script necessari
                mp_strcause = "inserisce i java script necessari";
                response.Write(JavaScript(JS));




                response.Write("</head><body>" + Environment.NewLine);


                //'-- disegno la grigli aggiornata
                //'--mp_objGrid.Html response


                //'--calcolo il numero di field visualizzati
                string[] v;
                v = Strings.Split(mp_strField, ",");


                //'--disegno il campo icona
                //objfield = New CtlHtml.field
                objfield = eProcurementNext.HTML.BasicFunction.getNewField(11);
                objfield.Init(11, "ICO", "", null, null, "I");
                objfield.Caption = " ";
                //objfield.Value = mp_Matrix[(v.Length - 1) + 1, idRow];
                objfield.Value = mp_Matrix[(v.Length - 1 + 1), idRow];
                response.Write(@"<div id=""Div_ICO"">");
                objfield.ValueHtml(response, false);
                response.Write("</div>");


                //'--disegno il campo esito
                //Set objfield = New CtlHtml.field
                objfield = eProcurementNext.HTML.BasicFunction.getNewField(11);
                objfield.Init(1, "MSG", "");
                objfield.Caption = ApplicationCommon.CNV("Esito", mp_ObjSession);
                //objfield.Value = mp_Matrix[(v.Length - 1) + 2, idRow];
                objfield.Value = mp_Matrix[v.Length - 1 + 2, idRow];
                response.Write(@"<div id=""Div_Esito"">");
                objfield.ValueHtml(response, false);
                response.Write("</div>");


                //'-- inserisco il JS per copiare la riga nella tabella
                response.Write(@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);


                //'--aggiorno tutta la griglia
                //'response.Write "parent.getObj( 'div_Grid' ).innerHTML = getObj( 'div_Grid' ).innerHTML; "




                //'--aggiorno la colonna icona
                //'--recupero la posizione della colonna icona
                int nPosColIco;
                nPosColIco = (v.Length - 1) + 1;
                //'--il nome del campo da aggiornare � fatto in questo modo Grid_r0_c1
                string strNameObjIco;
                strNameObjIco = "Grid_r" + idRow + "_c" + nPosColIco;
                response.Write($@"parent.getObj( '" + strNameObjIco + $@"' ).innerHTML = getObj( 'Div_ICO' ).innerHTML;");



                //'--aggiorno la colonna Esito
                int nPosCol_Esito;
                nPosCol_Esito = nPosColIco + 1;
                string strNameObjEsito;
                strNameObjEsito = "Grid_r" + idRow + "_c" + nPosCol_Esito;
                response.Write("parent.getObj( '" + strNameObjEsito + $@"' ).innerHTML = getObj( 'Div_Esito' ).innerHTML;");



                //'--calcolo percentuale rimanente della progressbar
                TotElements = (mp_vetId.Length - 1) + 1;
                rimanenti = TotElements - (idRow + 1);
                percentage = CInt((100 - ((rimanenti / TotElements) * 100)));



                //'Dim strHtmlProgress  As String
                //'strHtmlProgress = "<div class=""progress-bar progress-bar-success active progress-bar-striped"" role=""progressbar"" aria-valuenow=""40"" aria-valuemin=""0"" aria-valuemax=""100"" style=""width:" & percentage & "%"">" & percentage & "% Completata</div>"



                //'--aggiorno la barra percentuale
                response.Write($@"try{{ ");


                //'response.Write "parent.getObj( 'Div_ProgressBar' ).innerHTML='" & strHtmlProgress & "';"
                response.Write($@"parent.getObj( 'Div_ProgressBar' ).innerHTML = HTML_Progress_Bar (" + percentage + ");");


                response.Write($@"}}catch( e ) {{}}; ");


                response.Write($@"try{{ ");
                //'-- riavvio la pagina per eseguire il prossimo processo
                response.Write($@"document.location = 'ViewerExecProcess.asp?" + mp_queryString + $@"'; }} catch( e ) {{}};" + Environment.NewLine);
                response.Write($@"</script>" + Environment.NewLine);

            }
            catch (Exception ex)
            {

                //Set JS = Nothing
                throw new Exception(ex.Message + mp_strcause, ex);


            }

        }

        public bool checkHackSecurity(Session.ISession session, EprocResponse response)
        {


            BlackList mp_objDB = new BlackList();

            bool result = false;

            //Set mp_objDB = CreateObject("ctldb.BlackList")

            if ((!mp_objDB.isDevMode(session)) && (!Basic.isValid(mp_strTable, 1)))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, session[SessionProperty.IdPfu], ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                result = true;
                return result;

            }

            if ((!mp_objDB.isDevMode(session)) && (!Basic.isValid(mp_strKey, 1)))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_QUERY_SQLINJECTION, "##nome-parametro##", "KEY")), session, mp_strConnectionString);
                result = true;
                return result;

            }

            if ((!mp_objDB.isDevMode(session)) && (!Basic.isValid(mp_idDoc.ToString(), 4)))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_QUERY_SQLINJECTION, "##nome-parametro##", "IDLISTA")), session, mp_strConnectionString);
                result = true;
                return result;

            }



            //'-- Prima di validare il parametro field faccio la replace del ":" per non bloccare le configurazioni
            //'-- in cui si passa la width nella forma nomeField:100
            if ((!mp_objDB.isDevMode(session)) && (!Basic.isValid(Replace(mp_strField, ":", ""), 1)))
            {

                mp_objDB.addIp(mp_objDB.getAttackInfo(_httpContext, session[SessionProperty.IdPfu], Replace(ATTACK_QUERY_SQLINJECTION, "##nome-parametro##", "FIELD")), session, mp_strConnectionString);
                result = true;
                return result;

            }

            //Set mp_objDB = Nothing
            return result;

        }

    }
}
