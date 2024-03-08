using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class GridMultiDimension
    {
        public string Caption = string.Empty;      //'-- Titolo della griglia

        public string Style = string.Empty;        //'-- Classe associata alla griglia

        public string StyleCaption = string.Empty; //'-- Classe associata alla riga di testata delle colonne
        public string StyleCaptionTotal = string.Empty; //'-- classse per le caption dei totali di riga e di colonna
        public string StyleValueTotal = string.Empty;//'-- classse per i valori dei totali di riga e di colonna
        public string StyleCaptionData = string.Empty;//'--classe intestazione dati

        public string StyleRow0 = string.Empty;    //'-- Classe associata alla riga par dispari
        public string StyleRow1 = string.Empty;    //'

        public string id = string.Empty;        //'-- identificativo della griglia

        //'public Columns As Collection
        //'public LenCol As Variant
        public Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

        public string width = string.Empty;
        public string Height = string.Empty;


        public bool Editable = default;  //'-- indica se la giglia è editabile per default non lo è
        public int DrawMode = 0;  //'-- indica la modalità di disegno della griglia 1 = griglia , 2 = schede


        private dynamic mp_Matrix; //'-- matrice dei valori contenuti nella
                                   //'-- deve essere in stretta relazione con le colonne
                                   //'-- si considera zero based ( riga, colonna)

        //'private mp_vIdRow As Variant //'-- contiene un array con gli identificativi di riga
        //'-- se avvalorato

        private int mp_numRow = 0;
        private int mp_numCol = 0;

        private TSRecordSet mp_RS = new TSRecordSet(); //'-- recordset associato alla griglia in alternativa alla matrice
                                                       //'private mp_strFieldKey = string.empty;//'-- nel caso ci sia il recordset contiene il campo che fa da chiave per i record


        //'-- usatre per paginare la griglia
        //'private mp_CurPage = default;   //'-- se avvalorato indica la pagina corrente a partie da 1
        //'private mp_RowPage = default;   //'-- indica il numero di righe da visualizzare in una pagina

        //private response As Object

        //'private mp_TotalTitle = string.Empty; //'--stringa per la descrizione del totale della griglia
        //'private mp_ColSpanTotal = 0; //'-- numero colonne su cui esprimere il totale

        //'--proprietà per visualizzare la riga con i totali di colonna
        public bool ShowTotalCol = default;

        //'--proprietà per la caption della riga dei totali di colonna
        public string CaptionTotalCol = string.Empty;

        //'--proprietà per visualizzare la colonna con i totali di riga
        public bool ShowTotalRow = default;

        //'--proprietà per la caption della colonna dei totali di riga
        public string CaptionTotalRow = string.Empty;


        private dynamic mp_rowCondition; //'-- collezione che contiene condizioni per impostare style in funzione della condizione

        public string URL = string.Empty;//'-- indirizzo da chiamare quando si richiede il sort di una colonna
                                         //'public Sort = string.empty;//'-- nome della colonna su cui mettere la bitmap del sort
                                         //'-- E' A CURA DELL'APPLICAZIONE FARE IL SORT DEL RECORDSET O DELLA MATRICE
                                         //'public SortOrder = string.empty;//'-- Verso su cui è espresso il sort
                                         //'private AutoSort = default;
                                         //'private SortAll = default;

        public bool PrintMode = default; //'-- indica che la griglia è visualizzata per una stampa quindi non vanno messi
                                         //'-- i meccanismi di eventi come onclick

        //'-- variabili per il lock della tabella
        private bool mp_Locked = default;
        private int mp_RowLocked = 0; //'-- quante righe devono essere fisse sullo schermo
        private int mp_ColLocked = 0; //'-- quante colonne devono essere fisse sullo schermo


        //'-- oggetto per personalizzare la visualizzazione delle celle
        private dynamic mp_OBJCustomCellDraw;

        //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        //'-- Variabili per mantenere i dati in memoria
        //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        //' collezione dei domini
        private Dictionary<string, ClsDomain> mp_collDomainDimension = new Dictionary<string, ClsDomain>();

        //' collezione dei field
        private Dictionary<string, Field> mp_collFields = new Dictionary<string, Field>();

        //' collezione delle posizoni nella dimensione
        private Dictionary<dynamic, dynamic> mp_collDomainsPosDim = new Dictionary<dynamic, dynamic>();

        //' array dei valori
        private dynamic[] mp_ArrValues;

        private long lSizeArrValues = 0;
        private long lSizeDomains = 0;

        private int[] mp_arrSfasamento = new int[] { };

        private int mp_NumDimRow = 0;
        private int mp_NumDimCol = 0;
        private dynamic[] mp_VetDimRow = new dynamic[20 + 1];
        private ClsDomain[] mp_VetDimCol = new ClsDomain[20 + 1];
        private long[] mp_VetScostCol = new long[20 + 1];
        private long[] mp_VetScostRow = new long[20 + 1];
        private int[] mp_VetRelSfafamentoAssolutoRow = new int[20 + 1];
        private int[] mp_VetRelSfafamentoAssolutoCol = new int[20 + 1];


        private dynamic[] mp_VetTotalCol = null!; // = new dynamic[0];
        public bool bDrawText = default;

        //'
        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo

        public void JScript(Dictionary<string, string> JS, string Path = "")
        {
            int numCol = 0;
            int c = 0;
            JS.Add("checkbrowser", @"<script src=""" + Path + @"jscript/checkbrowser.js"" ></script>");
            JS.Add("getObj", @"<script src=""" + Path + @"jscript/getObj.js"" ></script>");
            JS.Add("ExecFunction", @"<script src=""" + Path + @"jscript/ExecFunction.js"" ></script>");

            JS.Add("GetPosition", @"<script src=""" + Path + @"jscript/GetPosition.js"" ></script>");
            JS.Add("lockedGrid", @"<script src=""" + Path + @"jscript/grid/lockedGrid.js"" ></script>");

            //'-- aggiunge i JS necessari per la gestione dei dati lato client
            JS.Add("UseDimInfo", @"<script src=""" + Path + @"jscript/GridMultiDim/UseDimInfo.js"" ></script>");

            //'-- aggiungo i js dei campi utilizzati sulla griglia
            numCol = mp_collFields.Count;

            for (c = 1; c <= numCol; c++)
            {
                mp_collFields.ElementAt(c - 1).Value.JScript(JS, Path);
            }
        }

        public GridMultiDimension()
        {
            Style = "Grid";
            StyleCaption = "_RowCaption";
            StyleCaptionData = "_CaptionData";
            StyleCaptionTotal = "_TotalCaption";
            StyleValueTotal = "_TotalValue";
            StyleRow0 = "GR0";
            StyleRow1 = "GR1";
            //mp_Matrix = Empty
            //mp_VetTotalCol = Empty
            //'mp_vIdRow = Empty
            width = "100%";
            ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
            Editable = false;
            DrawMode = 1;
            //'mp_ShowTotal = False
            //'mp_TotalTitle = ""
            //'mp_ColSpanTotal = 1
            ShowTotalRow = false;
            ShowTotalCol = false;
            CaptionTotalRow = string.Empty;
            CaptionTotalCol = string.Empty;
        }


        //'-- ritorna il codice html DELLA GRIGLIA
        public string Html(IEprocResponse objResp)
        {
            //'-- div che racchiude la tabella
            objResp.Write("<div");

            objResp.Write(@" style=""height:100%""");
            objResp.Write($@" id=""div_" + id + @""">" + Environment.NewLine);

            //'-- controlla la presenza della griglia
            if (mp_collFields == null)
            {
                objResp.Write("La griglia non è stata avvalorata ");
                objResp.Write(Caption);
                objResp.Write(@"</div>" + Environment.NewLine);
                //'Html = strApp
                return null;
            }

            //'-- metto il titolo alla tabella nel caso sia presente
            if (!String.IsNullOrEmpty(Caption))
            {
                objResp.Write(@"<table class=""" + Style + @"_Title""  id=""" + id + @""" name=""" + id + @""" cellspacing=""0"" cellpadding=""0"" >" + Environment.NewLine);
                objResp.Write(@"<tr><td class=""" + Style + @"_TitleCell"" >");
                objResp.Write(Caption + @"</td></tr><tr><td>" + Environment.NewLine);
            }

            // '-- se ho chiesto il lock predispongo le div per il disegno e poi il contenuto
            if (mp_Locked && !PrintMode)
            {
                DrawLockedGridHtml(objResp);
            }
            else
            {
                //'-- altrimenti disegna la tabella
                DrawGridHtml(objResp);
            }

            //'-- chiudo la tabella aperta per il titolo
            if (!String.IsNullOrEmpty(Caption))
            {
                objResp.Write("</td></tr></table>");
            }


            objResp.Write("</div>" + Environment.NewLine);

            return objResp.Out();
        }




        //'-- disegna la tabella con i lock di righe e colonne
        private void DrawLockedGridHtml(IEprocResponse objResp)
        {

            //'-- disegno la div per la posizione sullo schermo
            //'If UCase(accessible) = "YES" Then
            //'    objResp.Write("<div id=""" + id + "_ShowedDiv"" class=""height_100_percent width_100_percent"">"
            //'    objResp.Write("<table border=""0"" id=""" + id + "_Showed"" width=""100%"" onresize=""javascript: try { ResizeGrid( '" + id + "' ); }   catch(  e ){  ; };"" >"
            //'Else
            objResp.Write(@"<div id=""" + id + @"_ShowedDiv"" width=""100%"" style=""height:100%"">");
            objResp.Write(@"<table border=""0"" id=""" + id + @"_Showed"" width=""100%"" height=""100%"" onresize=""javascript: try { ResizeGrid( '" + id + @"' ); }   catch(  e ){  ; };"" >");
            //'End If

            objResp.Write("<tr>");
            objResp.Write(@"<td width=""100%"" height=""100%"" valign=""middle"" align=""center"" ><img src=""../ctl_library/images/grid/clessidra.gif""/>&nbsp;<span id=""" + id + @"_loading"" name=""" + id + @"_loading"" >Loading... 0%</span>");
            objResp.Write("</td>");
            objResp.Write("</tr>");
            objResp.Write("</table>");
            objResp.Write("</div>");
        }


        //'-- funzione chiamata per il disegno della griglia quando questa prevede il blocco dei riquadri
        public void DrawLockedHtml(IEprocResponse objResp)
        {

            //'-- disegno la div con il contenuto
            objResp.Write(@"<div id=""" + id + @"_Content"" ");


            //'If UCase(accessible) <> "YES" Then
            objResp.Write(@"style=""position: absolute; overflow: auto; display: none;""");
            //'Else
            //'    objResp.Write("class=""div_grid_multi_dim_overflow_auto"""
            //'End If


            objResp.Write(@" onscroll=""javascript:ScrollLockedInfo( '" + id + @"' );"" >");


            DrawGridHtml(objResp);
            objResp.Write("</div>");

            //'-- disegno la div per le righe fisse
            objResp.Write(@"<div id=""" + id + @"_LockedRow"" ");


            //'If UCase(accessible) <> "YES" Then
            objResp.Write(@" style=""position: absolute; overflow: hidden; display: none; """);
            //'Else
            //'    objResp.Write(" class=""div_grid_multi_dim_overflow_hidden"""
            //'End If

            objResp.Write(@" Rows = """ + mp_RowLocked + @""">");
            objResp.Write("</div>");

            //'-- disegno la div per le colonne fisse
            objResp.Write(@"<div id=""" + id + @"_LockedCol"" ");


            //'If UCase(accessible) <> "YES" Then
            objResp.Write(@" style=""position: absolute; overflow: hidden; display: none; """);
            //'Else
            //'    objResp.Write(" class=""div_grid_multi_dim_overflow_hidden"""
            //'End If


            objResp.Write(@" cols = """ + mp_ColLocked + @""">");
            objResp.Write(@"</div>");

            //'-- disegno la div per l'angolo fisso se necessario
            objResp.Write(@"<div id=""" + id + @"_LockedCorner""");


            //'If UCase(accessible) <> "YES" Then
            objResp.Write(@" style=""position: absolute; overflow: hidden; display: none;""");
            //'Else
            //'    objResp.Write(" class=""div_grid_multi_dim_overflow_hidden"""
            //'End If


            objResp.Write(@" cols = """ + mp_ColLocked + @""">");
            objResp.Write(@"</div>");

            //'-- js per disegnare e posizionare la prima volta la griglia
            //'objResp.Write("<script type=""text/javascript"">"+ Environment.NewLine);
            //'objResp.Write("StartScrolledGrid( '" + id + "' );"+ Environment.NewLine);
            //'objResp.Write("</script>"+ Environment.NewLine);


            //'  -- js per disegnare e posizionare la prima volta la griglia
            objResp.Write(@"<script type=""text/javascript"">" + Environment.NewLine);
            objResp.Write(@" StartScrolledGrid( '" + id + "' ); " + Environment.NewLine);
            objResp.Write(@" var OldFunc" + id + " = window.onresize;" + Environment.NewLine);
            objResp.Write(@" window.onresize = NewRes" + id + ";" + Environment.NewLine);
            objResp.Write(@" function NewRes" + id + "(){" + Environment.NewLine);
            objResp.Write(@" try{ResizeGrid( '" + id + "' );" + Environment.NewLine);
            objResp.Write(@" OldFunc" + id + "(); }catch(e) {} }" + Environment.NewLine);
            objResp.Write("</script>");



        }

        private void DrawGridHtml(IEprocResponse objResp)
        {

            //'-- apertura della tabella HTML
            if (IsMasterPageNew())
            {
				objResp.Write(@"<table class=""Grid GrigliaCubeFaseII""  id=""" + id + @""" name=""" + id + @"""  cellspacing=""0"" cellpadding=""0"" ");
            }
            else
            {
    			objResp.Write(@"<table class=""Grid""  id=""" + id + @""" name=""" + id + @"""  cellspacing=""0"" cellpadding=""0"" ");
            }

            objResp.Write(@" numrow=""" + mp_numRow + @""" " + Environment.NewLine);
            objResp.Write(@" numcol=""" + mp_numCol + @""" >" + Environment.NewLine);

            //'-- disegna le caption
            DrawCaption(objResp);

            //'-- disegna le righe
            DrawRows(objResp, 0);

            objResp.Write("</table>");

        }

        //'-- ritorna il codice html DELLA GRIGLIA
        public string Excel(IEprocResponse objResp)
        {
            return DrawGridExcel(objResp);

        }

        //'-- determina sulle dimensioni di riga e colonna gli scostamenti relativi per la corretta visualizzazione
        private void CalculateRowAndColDimension()
        {

            int nD = 0;
            int i = 0;
            nD = mp_collDomainDimension.Count();

            Grid_ColumnsProperty prop; // = new Grid_ColumnsProperty();

            mp_NumDimRow = 0;
            mp_NumDimCol = 0;

            //'-- determino il numero di dimensioni sulle colonne
            for (i = 1; i <= mp_collDomainDimension.Count(); i++)
            {
                ClsDomain colDom = mp_collDomainDimension.ElementAt(i - 1).Value;

                if (ColumnsProperty.ContainsKey(colDom.Id))
                {

                    prop = ColumnsProperty[colDom.Id];

                    if (prop.Dimension.ToLower() == "col")
                    {
                        mp_NumDimCol = mp_NumDimCol + 1;
                        mp_VetDimCol[mp_NumDimCol] = colDom;
                        mp_VetRelSfafamentoAssolutoCol[mp_NumDimCol] = i;
                    }



                    if (prop.Dimension.ToLower() == "row")
                    {
                        mp_NumDimRow = mp_NumDimRow + 1;
                        mp_VetDimRow[mp_NumDimRow] = colDom;
                        mp_VetRelSfafamentoAssolutoRow[mp_NumDimRow] = i;
                    }

                }

            }

            long nC = 0;
            nC = mp_collFields.Count;
            //'-- calcolo gli scostamenti per le colonne
            for (i = mp_NumDimCol; i >= 1; i--)
            {
                mp_VetScostCol[i] = nC;
                nC = nC * mp_VetDimCol[i].Elem.Count;
            }

            mp_numCol = (int)nC;
            nC = 1;
            //'-- calcolo gli scostamenti per le righe
            for (i = mp_NumDimRow; i >= 1; i--)
            {
                mp_VetScostRow[i] = nC;
                nC = nC * mp_VetDimRow[i].Elem.Count;
            }

            mp_numRow = (int)nC;


            //'-- determino il blocco dei dati a video
            mp_Locked = true;

            mp_RowLocked = mp_NumDimCol + 1;
            mp_ColLocked = 1;

        }


        //'-- disegna la testata della griglia con le descrittive delle colonne
        private string DrawCaption(IEprocResponse objResp)
        {
            //'Dim strApp = string.Empty;
            Field obj;
            //'Dim c As Integer
            string strCaption = String.Empty;
            Grid_ColumnsProperty prop;
            bool bSortCol = default;
            //On Error Resume Next
            Dictionary<string, dynamic>? el;  // <--------------
            long nds = default;
            long i = 0;
            long r = 0;
            long c = 0;
            nds = 1;



            //'--disegno tante righe per quante dimensioni ho in colonna più una riga per i dati



            for (i = 1; i <= mp_NumDimCol; i++)
            {
                //'-- apro la riga
                objResp.Write("<tr>" + Environment.NewLine);

                //'-- disegno la cella che contiene la descrizione della dimensione
                objResp.Write("<td");

                //If UCase(accessible) <> "YES" Then
                //            objResp.Write(" nowrap"
                //        End If



                objResp.Write(@" colspan=""" + mp_NumDimRow + @"""  class=""" + Style + StyleCaption + @"_DimColDesc nowrap"" >" + Environment.NewLine);
                objResp.Write(mp_VetDimCol.ElementAt((int)i).Desc);
                objResp.Write("</td>");




                el = mp_VetDimCol[i].Elem;



                //'-- ripeto enne volte il disegnop delle celle per il numero di elementi delle dimensioni superiori
                for (r = 1; r <= nds; r++)
                {
                    //'-- disegno tutte le colonne di quel dominio
                    for (c = 1; c <= el.Count; c++)
                    {
                        DomElem de = el.ElementAt((int)c - 1).Value;
                        DrawIntestazione(objResp, de.Desc, mp_VetDimCol[i].Id, de.Image, mp_VetScostCol[i], 1, StyleCaption + "_DimColValue_" + i);
                    }
                }

                nds = nds * el.Count;
                //'-- chiudo la riga
                objResp.Write("</tr>" + Environment.NewLine);

            }



            //'----------------------------------------------------------------------------
            //'-- disegno la riga per le intestazione delle dimensioni in riga e per i dati
            //'----------------------------------------------------------------------------



            //'-- apro la riga
            objResp.Write("<tr>" + Environment.NewLine);


            for (i = 1; i <= mp_NumDimRow; i++)
            {



                //'-- disegno la cella che contiene la descrizione della dimensione
                objResp.Write("<td");



                //If UCase(accessible) <> "YES" Then
                //            objResp.Write(" nowrap"
                //        End If

                objResp.Write(@" class=""" + Style + StyleCaption + @"_DimRowDesc nowrap"">" + Environment.NewLine);
                objResp.Write(mp_VetDimRow[i].Desc);
                objResp.Write("</td>");
            }



            //'-- disegno le intestazioni dei dati
            //'-- ripeto enne volte il disegno delle celle per il numero di elementi delle dimensioni superiori
            for (r = 1; r <= nds; r++)
            {

                //'-- disegno tutte le colonne di quel dominio
                for (c = 1; c <= mp_collFields.Count; c++)
                {

                    DrawIntestazione(objResp, mp_collFields.ElementAt((int)c - 1).Value.Caption, mp_collFields.ElementAt((int)c - 1).Value.Name, "", 1, 1, StyleCaptionData);

                }
            }

            //'-- chiudo la riga
            objResp.Write("</tr>" + Environment.NewLine);

            return objResp.Out();

        }

        private string DrawIntestazione(IEprocResponse objResp, string strCaption, string Name, string Image, long col, long row, string StyleCell = "")
        {

            Grid_ColumnsProperty prop;
            //On Error Resume Next


            //'-- apro la cella
            objResp.Write("<td");


            //If UCase(accessible) <> "YES" Then
            //    objResp.Write(" nowrap"
            //End If


            objResp.Write(@" rowspan=""" + row + @""" colspan=""" + col + @""" class=""" + Style + StyleCell + @" nowrap"" " + Environment.NewLine);


            //'-- determino la larghezza delle colonne per troncare alla larghezza desiderata
            prop = ColumnsProperty[Name];
            //If err.number = 0 Then


            //'-- numero di caratteri da visualiizare sulla caption
            if (prop.Length > 0)
            {
                if (strCaption.Length > prop.Length)
                {
                    objResp.Write(@" title=""" + strCaption + @""" ");
                    strCaption = CommonModule.Basic.Left(strCaption, prop.Length - 3) + "...";
                }
            }


            //'-- numero di pixel della colonna
            if (!String.IsNullOrEmpty(prop.width))
            {

                //If UCase(accessible) <> "YES" Then
                //    objResp.Write(" nowrap"
                //End If


                objResp.Write(@" width=""" + prop.width + @""" ");
            }


            else
            {
                prop = null;


            }
            //err.Clear

            objResp.Write(">");


            //'-- nel caso la colonna contiene un'immaggine
            if (!String.IsNullOrEmpty(Image))
            {
                objResp.Write(@" <img src=""../CTL_Library/images/domain/" + Image + @"""/>");
            }



            //'-- scrivo il valore
            objResp.Write(strCaption);



            //'-- chiudo la cella
            objResp.Write("</td>" + Environment.NewLine);

            return objResp.Out();

        }

        private string DrawRows(IEprocResponse objResp, int dimensione)
        {

            string strStyle = string.Empty;
            //'Dim strApp = string.Empty;
            long r, c = default;
            string n = string.Empty;
            Grid_ColumnsProperty propCol;
            long rowCounter = default;
            long StartRow = default;
            string strVal = string.Empty;

            //On Error Resume Next
            dynamic v;
            bool bDrawed = default;
            string strProp = string.Empty;
            bool bDrawLoading = default;
            double passo = default;
            double PercLoading = default;
            long TotRecord = default;

            Dictionary<string, dynamic> el; // = new Dictionary<string, DomElem>();
            //dynamic el;
            long nct = default;
            long nC = default;
            nct = mp_numCol / mp_collFields.Count;
            nC = mp_collFields.Count;


            int[] vetScostRel = new int[21]; //'-- indice relativo al numero di elementi per riga per verificaer se è scatatta la cella successiva
            int[] vetIndDimRow = new int[21]; //'-- contiene, per le dimensioni delle righe l'indice relativo della dimensione
            int[] vetScostRelCol = new int[21]; // '-- indice relativo al numero di elementi per riga per verificaer se è scatatta la cella successiva
            int[] vetIndDimCol = new int[21]; //'-- contiene, per le dimensioni delle righe l'indice relativo della dimensione
            dynamic[] VetTotalCol; //'-- contiene per ogni colonna il totale


            VetTotalCol = new dynamic[(nC * nct) + 1];


            long IndScost = default;
            long StartScost = default;
            long i = default;
            long d = default;
            int k = 0;
            string vs = string.Empty;

            Field obj;

            bDrawLoading = false;
            strStyle = StyleRow0;


            long[] VetScostRow = new long[21];
            //'-- disegna tutte le righe della griglia

            for (r = 1; r <= mp_numRow; r++)
            {

                //'-- apro la riga
                objResp.Write(@"<!--      RIGA " + r + "                      -->");

                objResp.Write(@"<tr  class=""" + strStyle + @""" >" + Environment.NewLine);

                //'-- azzero l'indice dello scostamento
                IndScost = 0;

                //'-- disegna le intestazione delle dimensioni sulle righe
                for (i = 1; i <= mp_NumDimRow; i++)
                {
                    ClsDomain cls = new ClsDomain();
                    cls = mp_VetDimRow[i];

                    //'-- prendo gli elementi presenti sulla dimensione
                    el = cls.Elem;


                    //'-- se ho superato il numero delle righe devo ripetere l'intestazione ed azzero il contatore
                    if (vetScostRel[i] >= mp_VetScostRow[i])
                    {
                        vetScostRel[i] = 0;
                    }

                    //'-- verifico se è necessario disegnare la cella di intestazione
                    if (vetScostRel[i] == 0)
                    {

                        //'-- disegno l'intestazione
                        int indVetIndDimRow = vetIndDimRow[i];
                        string elDesc = el.ElementAt(indVetIndDimRow).Value.Desc;
                        DrawIntestazione(objResp, elDesc, cls.Id, el.ElementAt((int)i - 1).Value.Image, 1, mp_VetScostRow[i], StyleCaption + "_DimRowValue_" + mp_NumDimRow);
                        VetScostRow[i] = vetIndDimRow[i] * mp_arrSfasamento[mp_VetRelSfafamentoAssolutoRow[i]];

                        //'-- aggiorno l'indice che sto visualizzando per quella dimensione
                        vetIndDimRow[i] = vetIndDimRow[i] + 1;

                        //'-- verifico che l'indice non abbia superato il numero di elementi della dimensione
                        //if (vetIndDimRow[i] >= mp_VetDimRow[i].elem.Count)
                        if (vetIndDimRow[i] >= el.Count)
                        {
                            vetIndDimRow[i] = 0;
                        }

                    }

                    //'-- calcolo lo scostamento relativo
                    //'IndScost = IndScost + ((vetIndDimRow(i)) * mp_arrSfasamento(mp_VetRelSfafamentoAssolutoRow(i)))
                    IndScost = IndScost + VetScostRow[i];

                    vetScostRel[i] = vetScostRel[i] + 1;

                }

                k = 0;
                //'-- disegno tutte le celle di una riga
                for (i = 1; i <= nct; i++)     // nct è il numero delle colonne
                {

                    //'-- azzero lo scostamento per le colonne
                    StartScost = IndScost;

                    //'-- CALCOLO IL POSIZIONAMENTO IN MEMORIA PER RECUPERARE IL VALORE DELLA CELLA DA DISEGNARE
                    for (d = 1; d <= mp_NumDimCol; d++)  // SONO DUE LE COLONNE (Regione e Estero?) 
                    {

                        //'-- se ho superato il numero delle celle azzero il contatore
                        if (vetScostRelCol[d] >= mp_VetScostCol[d])
                        {

                            vetScostRelCol[d] = 0;


                            //'-- incremento l'indice della dimensione
                            vetIndDimCol[d] = vetIndDimCol[d] + 1;   //'-- vetIndDimCol contiene, per le dimensioni delle righe l'indice relativo della dimensione
                                                                     //    qualunque cosa voglia dire 

                            //'-- verifico che l'indice non abbia superato il numero di elementi della dimensione
                            if (vetIndDimCol[d] >= mp_VetDimCol.ElementAt((int)d).Elem.Count)
                            {
                                vetIndDimCol[d] = 0;
                            }

                        }

                        //'-- calcolo lo scostamento relativo
                        StartScost = StartScost + (vetIndDimCol[d] * mp_arrSfasamento[mp_VetRelSfafamentoAssolutoCol[d]]);

                    }


                    //'-- ciclo sui dati per la visualizzazione
                    for (c = 1; c <= nC; c++)
                    {

                        //'-- incremento GLI INDICI SULLE VARIE DIMENSIONI DI COLONNA PER CALCOLARE GLI SCOSTAMENTI
                        for (d = 1; d <= mp_NumDimCol; d++)
                        {
                            vetScostRelCol[d] = vetScostRelCol[d] + 1;
                        }

                        obj = mp_collFields.ElementAt((int)c - 1).Value;
                        //obj.Value = ""; //mp_ArrValues(StartScost + c - 1).Value;
                        obj.Value = mp_ArrValues[StartScost + c - 1];
                        k = k + 1;
                        //'--aggiorno il totale di colonna

                        if (mp_VetTotalCol == null && obj.Value != null)
                        {
                            if (VetTotalCol[k] is null)
                            {
                                VetTotalCol[k] = obj.Value;
                            }
                            else
                            {
                                VetTotalCol[k] = VetTotalCol[k] + obj.Value;
                            }
                        }

                        //'-- identifico il campo sulla riga

                        long tempStartScost = StartScost + c - 1;

                        //obj.SetRow(StartScost + c - 1);
                        obj.SetRow(tempStartScost);

                        //strProp = SetCellProperty(StartScost + c - 1, obj.Name, strStyle);
                        strProp = SetCellProperty(tempStartScost, obj.Name, strStyle);
                        bDrawed = false;
                        //'                If Not mp_OBJCustomCellDraw Is Nothing Then
                        //'                    bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(Me, 0, obj, r, c, strProp, objResp)
                        //'                End If

                        if (!bDrawed)
                        {

                            //'-- apro la cella
                            objResp.Write("<td ");
                            //'objResp.Write(" id=""" + Id + "_r" + r + "_c" + c + """ "


                            objResp.Write(strProp);

                            objResp.Write(">");

                            //'-- scrivo il valore
                            if (bDrawText)
                            {
                                vs = obj.TxtValue();
                                //if (Convert.ToInt32(vs.ToString()) == 0)
                                //{
                                //    objResp.Write("&nbsp;");
                                //}
                                //else
                                //{
                                //    objResp.Write(vs);
                                //}

                                if (String.IsNullOrEmpty(vs))
                                {
                                    objResp.Write("&nbsp;");
                                }
                                else
                                {
                                    objResp.Write(vs);
                                }


                            }
                            else
                            {
                                obj.umValueHtml(objResp, false);
                                obj.ValueHtml(objResp, false);
                            }



                            //'-- chiudo la cella
                            objResp.Write("</td>" + Environment.NewLine);

                        }

                    }



                }

                //'-- prima di chiudere la riga vanno disegnati i totale se presenti

                //'-- chiudo la riga
                objResp.Write("</tr>" + Environment.NewLine);

            }

            //'--disegno la riga dei totali di colonna
            if (mp_VetTotalCol == null)
            {
                DrawTotalCol(ref objResp, ref vetScostRelCol, ref vetIndDimCol, ref VetTotalCol, nct, nC, strStyle);
            }
            else
            {
                DrawTotalCol(ref objResp, ref vetScostRelCol, ref vetIndDimCol, ref mp_VetTotalCol, nct, nC, strStyle);
            }

            return objResp.Out();

        }

        private string SetCellProperty(long cell, string colName, string strStyle)
        {

            Grid_ColumnsProperty propCol;
            string strApp = string.Empty;
            string strStyleLoc = string.Empty;
            // TODO On Error Resume Next

            propCol = new Grid_ColumnsProperty();
            propCol = ColumnsProperty[colName];

            try
            {
                if (!String.IsNullOrEmpty(propCol.Alignment))
                {
                    strApp = strApp + " align='" + propCol.Alignment + "' ";
                }



                if (!String.IsNullOrEmpty(propCol.FormatCondition))
                {
                    strStyleLoc = strStyle + CheckCondition(propCol.FormatCondition, mp_ArrValues, cell);
                }
                else
                {
                    strStyleLoc = strStyle;
                }

                if (!String.IsNullOrEmpty(mp_collFields[colName].Style))
                {
                    strApp = strApp + @" class=""" + strStyleLoc + "_" + mp_collFields[colName].Style;
                }
                else
                {
                    strApp = strApp + @" class=""" + strStyleLoc;
                }

                if (!propCol.Wrap)
                {
                    strApp = strApp + @" nowrap""  ";
                }
                else
                {
                    strApp = strApp + @"""  ";
                }

                if (!String.IsNullOrEmpty(propCol.OnClickCell) && !PrintMode)
                {
                    strApp = strApp + @" onclick=""" + propCol.OnClickCell + "('" + id + "' , '" + colName + "' , " + cell + @" );"" ";
                }

                //        If propCol.Wrap = False And UCase(accessible) <> "YES" Then
                //            strApp = strApp & " nowrap  "
                //End If
            }
            catch
            {
                strApp = strApp + @" class=""" + strStyle;

                if (!String.IsNullOrEmpty(mp_collFields[colName].Style))
                {
                    strApp = strApp + "_" + mp_collFields[colName].Style;
                }

                strApp = strApp + @" nowrap"" ";


                //If UCase(accessible) <> "YES" Then
                //    strApp = strApp & " nowrap  "
                //End If
            }



            return strApp;

        }

        public void SetCustomDrawer(Field obj)
        {
            mp_OBJCustomCellDraw = obj;
        }

        //' Imposta i dati della griglia dall'esterno
        public void InitGridValues(Dictionary<string, ClsDomain> collDomainDimension, Dictionary<string, Field> collFields, Dictionary<string, Grid_ColumnsProperty> collFieldsProperty, dynamic collDomainsPosDim, dynamic? ArrValues = null)
        {
            mp_collDomainDimension = collDomainDimension;
            mp_collFields = collFields;
            mp_collDomainsPosDim = collDomainsPosDim;
            ColumnsProperty = collFieldsProperty;
            if (ArrValues != null)
            {
                mp_ArrValues = ArrValues;
            }
            CalculateRowAndColDimension();
        }

        //' carica i valori dal recordset
        public void LoadGridValuesFromRS(TSRecordSet rs)
        {
            //logRecordSet(rs);

            //' vettore contenente lo sfasamento per i fields e per ogni dominio
            mp_RS = rs;
            //CommonDbFunctions.checkSort(rs.dt, "LoadGridValuesFromRS.txt", false);

            // mp_arrSfasamento.Clear(0, mp_collDomainDimension.Count);
            mp_arrSfasamento = new int[mp_collDomainDimension.Count + 1];
            //' il primo elemento è lo sfasamento dei fields = 1
            //' l'elemento i-esimo è lo sfasamento del dominio i-esimo
            mp_arrSfasamento[0] = 1;


            //' -- calcola la size dell'array dei valori
            //' -- moltiplicando il numero di elementi di ogni dominio X il numero di fields
            //' -- avvalora anche il vettore dello sfasamento
            lSizeDomains = GetSizeOfDomains();
            lSizeArrValues = lSizeDomains * mp_collFields.Count;


            mp_ArrValues = new dynamic[lSizeArrValues];

            long lDomSfasamento = 0;



            //' -- scorre il recordset per popolare il vettore dei valori
            if (mp_RS != null)
            {
                if (!(mp_RS.EOF && mp_RS.BOF))
                {
                    mp_RS.MoveFirst();


                    //' per ogni record
                    while (!mp_RS.EOF)
                    {


                        //' calcola lo sfasamento dei domini
                        lDomSfasamento = GetSfasamentoDomini();


                        //' se lo sfasamento dei domini non ha avuto anomalie
                        //' memorizza i valori dei fields
                        if (lDomSfasamento >= 0)
                        {
                            StoreValuesFields(lDomSfasamento);
                        }


                        mp_RS.MoveNext();

                    }
                }
            }


            //'-- effettua le espressioni dei dati  calcolati
            ExecCalculatedField(mp_ArrValues, 0);


            //'-- il calcolo della riga dei totali viene fatto prima della stampa
            //'-- poichè la somma delle celle viene fatta durante il disegno



        }

        // ' --  calcola il massimo numero di elementi di un dominio nella collezione
        private long GetSizeOfDomains()
        {

            long result = 1;
            //GetSizeOfDomains = 1


            ClsDomain cDom; // = new ClsDomain();
            long i = default;

            for (i = 1; i <= mp_collDomainDimension.Count; i++)
            {
                cDom = new ClsDomain();

                cDom = mp_collDomainDimension.ElementAt((int)i - 1).Value;

                result = result * cDom.Elem.Count;
                if (i == 1)
                {
                    mp_arrSfasamento[i] = mp_arrSfasamento[i - 1] * mp_collFields.Count;  // -->  mp_arrSfasamento[0] = 1 
                }
                else
                {
                    mp_arrSfasamento[i] = mp_arrSfasamento[i - 1] * mp_collDomainDimension.ElementAt((int)i - 2).Value.Elem.Count;
                    //mp_arrSfasamento[i] = mp_arrSfasamento[i - 1] * cDom.Elem.Count;
                }
            }

            return result;

        }

        //' --  calcola lo sfasamento della collezione dei domini sul record corrente
        private long GetSfasamentoDomini()
        {

            long result = 0;

            ClsDomain cDom;
            DomElem? cDomElem;
            dynamic? valore;
            long i = 0;

            for (i = 1; i <= mp_collDomainDimension.Count; i++)
            {
                cDom = new ClsDomain();
                cDom = mp_collDomainDimension.ElementAt((int)i - 1).Value;
                //' per ogni dominio prende il valore dal recordset
                valore = GetValueFromRS(mp_RS.Fields[cDom.Id]);


                if (valore != null)
                {

                    //' cerca quel valore nell'interno del dominio
                    cDomElem = null;

                    if (cDom.Elem.ContainsKey(CommonModule.Basic.CStr(valore)))
                    {
                        cDomElem = cDom.Elem[CommonModule.Basic.CStr(valore)];
                    }


                    //' se non trovato deve scartare il record
                    if (cDomElem == null)
                    {
                        result = -1;
                        break;
                    }
                    else
                    {
                        //' se trovato usa la proprietà Sort per
                        //' stabilirne la posizione nel dominio
                        result = (long)(result + (cDomElem.Sort * mp_arrSfasamento[i]));
                    }
                }
                else
                {
                    result = -1;
                    break;
                }
            }
            return result;

        }


        //' -- memorizza i valori dei campi in memoria per il record corrente
        private void StoreValuesFields(long lDomSfasamento)
        {


            long i = 0;
            long lIndex = 0;
            Field cField;
            dynamic? valore;

            //' scorre la collezione dei fields
            int n = 0;
            n = mp_collFields.Count;
            for (i = 1; i <= n; i++)
            {

                cField = mp_collFields.ElementAt((int)i - 1).Value;

                if (mp_RS.Columns.Contains(cField.Name))
                {
                    //' prende il valore di quel field dal recordset
                    valore = GetValueFromRS(mp_RS.Fields[cField.Name]);

                    if (valore != null)
                    {
                        //' memorizza il valore nell'array
                        lIndex = lDomSfasamento + i - 1;
                        if (lIndex >= 0 && lIndex < lSizeArrValues)
                        {
                            if (mp_ArrValues[lIndex] is null)
                                mp_ArrValues[lIndex] = valore;
                            else
                                mp_ArrValues[lIndex] = mp_ArrValues[lIndex] + valore;
                        }
                    }

                }


            }

        }




        //'-- disegna tutte le informazioni necessarie per interaggire con la griglia multidimensionale lato client

        public void Html_DrawDimensionInfo(IEprocResponse response)
        {
            ClsDomain cDom = new ClsDomain();
            long i = default;
            long n = default;

            response.Write("<script>");


            //'-- nella posizione zero troviamo i campi da 1 tutte le altre dimensioni


            //'-- numero di dimensioni presenti
            response.Write(@" var " + id + "_numDim = " + mp_collDomainDimension.Count + ";" + Environment.NewLine);

            //'-- nome di ogni dimensione
            response.Write(" var " + id + "_vetDimName = [ ");
            for (i = 1; i <= mp_collDomainDimension.Count; i++)
            {
                response.Write(@" '" + mp_collDomainDimension.ElementAt((int)i - 1).Value.Id + @"' ");
                if (i < mp_collDomainDimension.Count) { response.Write(" , "); }
            }
            response.Write(" ];" + Environment.NewLine);


            //'-- Scostamento di ogni dimensione
            response.Write(@" var " + id + @"_vetDimScost = [ ");
            for (i = 1; i <= mp_collDomainDimension.Count; i++)
            {
                response.Write(mp_arrSfasamento[i].ToString());
                if (i < mp_collDomainDimension.Count)
                {
                    response.Write(" , ");
                }
            }
            response.Write(" ];" + Environment.NewLine);


            //'-- numero elementi di ogni dimensione
            response.Write(" var " + id + "_vetDimLen = [ ");
            for (i = 1; i <= mp_collDomainDimension.Count; i++)
            {
                response.Write(mp_collDomainDimension.ElementAt((int)i - 1).Value.Elem.Count.ToString());                        //.Value.Elem.Count);
                if (i < mp_collDomainDimension.Count)
                {
                    response.Write(" , ");
                }
            }
            response.Write(" ];" + Environment.NewLine);


            response.Write("var " + id + @"_vetDimElem = new Array( " + mp_collDomainDimension.Count + " );" + Environment.NewLine);


            string v = String.Empty;

            //'-- crea le variabili contenente i valori di ogni dominio rappresentato
            for (i = 1; i <= mp_collDomainDimension.Count; i++)
            {


                cDom = mp_collDomainDimension.ElementAt((int)i - 1).Value;


                //'-- nome di ogni dimensione
                response.Write(@" " + id + @"_vetDimElem[" + (i - 1) + "] = [ ");
                for (n = 1; n <= cDom.Elem.Count; n++)
                {
                    v = Strings.Replace(cDom.Elem.ElementAt((int)n - 1).Value.id, @"\", @"\\");
                    v = Strings.Replace(v, @"'", @"\'");


                    response.Write(@" '" + v + "' ");


                    if (n < cDom.Elem.Count)
                    {
                        response.Write(" , ");
                    }


                }

                response.Write(" ];" + Environment.NewLine);



            }

            response.Write("</script>");


        }



        private void DrawTotalCol(ref IEprocResponse objResp, ref int[] vetScostRelCol, ref int[] vetIndDimCol, ref dynamic[] VetTotalCol, long nct, long nC, string strStyle)
        {



            int k = 0;
            int i = 0;
            int d = 0;
            int IndScost = 0;
            int StartScost = 0;
            int c = 0;
            Field obj;
            string strProp = string.Empty;
            Grid_ColumnsProperty propCol;
            bool bShowCellCaption;
            string strStyleCon = string.Empty;


            IndScost = 0;
            bShowCellCaption = false;


            //'--controllo che almeno una colonna ammette il totale
            foreach (KeyValuePair<string, Field> obj2 in mp_collFields)
            {

                propCol = ColumnsProperty[obj2.Key];



                if (propCol.Total)
                {
                    bShowCellCaption = true;
                    break;
                }



            }

            if (ShowTotalCol && bShowCellCaption)
            {


                //'-- eseguo le espressioni per le celle calcolate
                ExecCalculatedField(VetTotalCol, 1);



                //'--disegno la riga dei totali di colonna
                objResp.Write("<tr>" + Environment.NewLine);


                //'--disegno la cella intestione della riga dei totali di colonna
                objResp.Write("<td ");



                objResp.Write(@"colspan=""" + mp_NumDimRow + @""" class=""" + Style + StyleCaptionTotal + @"""");


                objResp.Write(">");

                //'--caption
                objResp.Write(CaptionTotalCol);

                //'-- chiudo la cella
                objResp.Write("</td>" + Environment.NewLine);


                k = 0;
                for (i = 1; i <= nct; i++)
                {

                    //'-- azzero lo scostamento per le colonne
                    StartScost = IndScost;



                    //'-- CALCOLO IL POSIZIONAMENTO IN MEMORIA PER RECUPERARE IL VALORE DELLA CELLA DA DISEGNARE
                    for (d = 1; d <= mp_NumDimCol; d++)
                    {



                        //'-- se ho superato il numero delle celle azzero il contatore
                        if (vetScostRelCol[d] >= mp_VetScostCol[d])
                        {


                            vetScostRelCol[d] = 0;


                            //'-- incremento l'indice della dimensione
                            vetIndDimCol[d] = vetIndDimCol[d] + 1;


                            //'-- verifico che l'indice non abbia superato il numero di elementi della dimensione
                            if (vetIndDimCol[d] >= mp_VetDimCol.ElementAt(d).Elem.Count)
                            {
                                vetIndDimCol[d] = 0;
                            }


                        }




                        //'-- calcolo lo scostamento relativo
                        StartScost = StartScost + (vetIndDimCol[d] * mp_arrSfasamento[mp_VetRelSfafamentoAssolutoCol[d]]);


                    }


                    //'-- ciclo sui dati per la visualizzazione
                    for (c = 1; c <= nC; c++)
                    {

                        //'-- incremento GLI INDICI SULLE VARIE DIMENSIONI DI COLONNA PER CALCOLARE GLI SCOSTAMENTI
                        for (d = 1; d <= mp_NumDimCol; d++)
                        {
                            vetScostRelCol[d] = vetScostRelCol[d] + 1;
                        }

                        obj = mp_collFields.ElementAt(c - 1).Value;
                        k = k + 1;
                        obj.Value = VetTotalCol[k];


                        strStyleCon = "";
                        propCol = ColumnsProperty[obj.Name];


                        //        If err.number Then
                        //            err.Clear
                        //Else
                        try
                        {
                            if (!String.IsNullOrEmpty(propCol.FormatCondition))
                            {
                                strStyleCon = CheckCondition(propCol.FormatCondition, VetTotalCol, CommonModule.Basic.CLng(k));
                            }
                            //End If
                        }
                        catch
                        {

                        }

                        //'-- apro la cella
                        objResp.Write(@"<td class=""" + Style + StyleValueTotal + strStyleCon + @"""");
                        objResp.Write(">");

                        //'--valore
                        if (propCol.Total)
                        {
                            obj.umValueHtml(objResp, false);
                            obj.ValueHtml(objResp, false);
                        }


                        //'-- chiudo la cella
                        objResp.Write("</td>" + Environment.NewLine);

                    }


                }


                objResp.Write("</tr>" + Environment.NewLine);

            }


        }

        private string DrawGridExcel(IEprocResponse objResp)
        {


            //'-- apertura della tabella HTML
            //'objResp.Write "<table class=""Grid""  id=""" & Id & """ name=""" & Id & """ " & IIf(width <> "" Or mp_Locked = True, " width=""" & width & """ ", "") & " cellspacing=""0"" cellpadding=""0"" "
            objResp.Write("<table >");



            //'-- disegna le caption
            DrawCaptionExcel(objResp);


            try
            {
                //'-- disegna le righe
                DrawRowsExcel(objResp, 0);

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message, ex);
            }



            objResp.Write("</table>");

            return objResp.Out();

        }

        private string DrawCaptionExcel(IEprocResponse objResp)
        {
            //'Dim strApp As String
            Field obj;
            //'Dim c As Integer
            string strCaption = String.Empty;
            Grid_ColumnsProperty prop; // As Grid_ColumnsProperty
            bool bSortCol = default;
            // TODO On Error Resume Next
            Dictionary<string, dynamic>? el = new Dictionary<string, dynamic>();
            long nds = 0;
            long i = 0;
            long r = 0;
            long c = 0;
            nds = 1;
            //'--disegno tante righe per quante dimensioni ho in colonna più una riga per i dati

            for (i = 1; i <= mp_NumDimCol; i++)
            {

                //'-- apro la riga
                objResp.Write("<tr>" + Environment.NewLine);



                //'-- disegno la cella che contiene la descrizione della dimensione
                objResp.Write(@"<td class=""nowrap"" ");


                //If UCase(accessible) <> "YES" Then
                //        objResp.Write "nowrap"
                //    End If


                objResp.Write(@" colspan = """ + mp_NumDimRow + @""">" + Environment.NewLine);
                objResp.Write(mp_VetDimCol[i].Desc);
                objResp.Write("</td>");



                el = mp_VetDimCol[i].Elem;

                //'-- ripeto enne volte il disegnop delle celle per il numero di elementi delle dimensioni superiori
                for (r = 1; r <= nds; r++)
                {

                    //'-- disegno tutte le colonne di quel dominio
                    for (c = 1; c <= el.Count; c++)
                    {
                        DrawIntestazioneExcel(objResp, el.ElementAt((int)c - 1).Value.Desc, mp_VetDimCol[i].Id, el.ElementAt((int)c - 1).Value.Image, mp_VetScostCol[i], 1, StyleCaption + "_DimColValue_" + i);

                    }

                }

                nds = nds * el.Count;

                //'-- chiudo la riga
                objResp.Write("</tr>" + Environment.NewLine);

            }


            //'----------------------------------------------------------------------------
            //    '-- disegno la riga per le intestazione delle dimensioni in riga e per i dati
            //    '----------------------------------------------------------------------------


            //'-- apro la riga
            objResp.Write(@"<tr>" + Environment.NewLine);

            for (i = 1; i <= mp_NumDimRow; i++)
            {

                //'-- disegno la cella che contiene la descrizione della dimensione
                objResp.Write(@"<td class=""nowrap"" ");

                //If UCase(accessible) <> "YES" Then
                //        objResp.Write "nowrap"
                //    End If

                objResp.Write(">" + Environment.NewLine);
                objResp.Write(mp_VetDimRow[i].Desc);
                objResp.Write("</td>");

            }

            //'-- disegno le intestazioni dei dati
            //    '-- ripeto enne volte il disegno delle celle per il numero di elementi delle dimensioni superiori
            for (r = 1; r <= nds; r++)
            {
                //'-- disegno tutte le colonne di quel dominio
                for (c = 1; c <= mp_collFields.Count; c++)
                {

                    DrawIntestazioneExcel(objResp, mp_collFields.ElementAt((int)c - 1).Value.Caption, mp_collFields.ElementAt((int)c - 1).Value.Name, "", 1, 1, StyleCaptionData);

                }

            }

            //'-- chiudo la riga
            objResp.Write("</tr>" + Environment.NewLine);

            return objResp.Out();
        }

        private string DrawIntestazioneExcel(IEprocResponse objResp, string strCaption, string Name, string Image, long col, long row, string StyleCell = "")
        {

            Grid_ColumnsProperty prop;
            // TODO On Error Resume Next


            //'-- apro la cella
            objResp.Write(@"<td class=""nowrap"" ");


            //If UCase(accessible) <> "YES" Then
            //    objResp.Write "nowrap"
            //End If


            objResp.Write(@" rowspan=""" + row + @""" colspan=""" + col + @""" >");



            //'-- nel caso la colonna contiene un'immaggine
            if (!String.IsNullOrEmpty(Image))
            {
                objResp.Write(@" <img src=""../CTL_Library/images/domain/" + Image + @"""/>");
            }



            //'-- scrivo il valore
            objResp.Write(strCaption);



            //'-- chiudo la cella
            objResp.Write("</td>" + Environment.NewLine);

            return objResp.Out();
        }


        private string DrawRowsExcel(IEprocResponse objResp, int dimensione)
        {

            string strStyle = string.Empty;
            long r, c = 0;
            string n = string.Empty;
            Grid_ColumnsProperty propCol;
            long rowCounter = 0;
            long StartRow = 0;
            string strVal = string.Empty;
            //On Error Resume Next
            dynamic v;
            bool bDrawed = default;
            string strProp = string.Empty;
            bool bDrawLoading = default;
            double passo = 0;
            double PercLoading = 0;
            long TotRecord = 0;
            Dictionary<string, dynamic> el = new Dictionary<string, dynamic>();
            long nct = 0;
            long nC = 0;
            nct = (mp_numCol / mp_collFields.Count);
            nC = mp_collFields.Count;


            int[] vetScostRel = new int[20]; //'-- indice relativo al numero di elementi per riga per verificaer se è scatatta la cella successiva
            int[] vetIndDimRow = new int[20]; //'-- contiene, per le dimensioni delle righe l'indice relativo della dimensione
            int[] vetScostRelCol = new int[20]; //'-- indice relativo al numero di elementi per riga per verificaer se è scatatta la cella successiva
            int[] vetIndDimCol = new int[20]; //'-- contiene, per le dimensioni delle righe l'indice relativo della dimensione
            dynamic[] VetTotalCol; //'-- contiene per ogni colonna il totale


            VetTotalCol = new dynamic[nC * nct + 1];


            long IndScost = 0;
            long StartScost = 0;
            long i = 0;
            long d = 0;
            int k = 0;

            Field obj;

            bDrawLoading = false;
            strStyle = StyleRow0;


            long[] VetScostRow = new long[28];


            //'-- disegna tutte le righe della griglia
            for (r = 1; r <= mp_numRow; r++)
            {



                //'-- apro la riga
                objResp.Write("<!--      RIGA " + r + "                      -->");

                objResp.Write("<tr>" + Environment.NewLine);



                //'-- azzero l'indice dello scostamento
                IndScost = 0;


                //'-- disegna le intestazione delle dimensioni sulle righe
                for (i = 1; i <= mp_NumDimRow; i++)
                {


                    //'-- prendo gli elementi presenti sulla dimensione
                    el = mp_VetDimRow[i].Elem;



                    //'-- se ho superato il numero delle righe devo ripetere l'intestazione ed azzero il contatore
                    if (vetScostRel[i] >= mp_VetScostRow[i])
                    {
                        vetScostRel[i] = 0;
                    }



                    //'-- calcolo lo scostamento relativo
                    //'IndScost = IndScost + ((vetIndDimRow(i)) * mp_arrSfasamento(mp_VetRelSfafamentoAssolutoRow(i)))



                    //'-- verifico se è necessario disegnare la cella di intestazione
                    if (vetScostRel[i] == 0)
                    {


                        //'-- disegno l'intestazione
                        DrawIntestazione(objResp, el.ElementAt(vetIndDimRow[i] + 1 - 1).Value.Desc, mp_VetDimRow[i].Id, el.ElementAt(vetIndDimRow[i] + 1 - 1).Value.Image, 1, mp_VetScostRow[i], StyleCaption + "_DimRowValue_" + mp_NumDimRow);
                        VetScostRow[i] = vetIndDimRow[i] * mp_arrSfasamento[mp_VetRelSfafamentoAssolutoRow[i]];


                        //'-- aggiorno l'indice che sto visualizzando per quella dimensione
                        vetIndDimRow[i] = vetIndDimRow[i] + 1;


                        //'-- verifico che l'indice non abbia superato il numero di elementi della dimensione
                        if (vetIndDimRow[i] >= mp_VetDimRow[i].Elem.Count)
                        {
                            vetIndDimRow[i] = 0;
                        }


                    }


                    IndScost = IndScost + VetScostRow[i];


                    vetScostRel[i] = vetScostRel[i] + 1;



                }

                k = 0;
                //'-- disegno tutte le celle di una riga
                for (i = 1; i <= nct; i++)
                {




                    //'-- azzero lo scostamento per le colonne
                    StartScost = IndScost;



                    //'-- CALCOLO IL POSIZIONAMENTO IN MEMORIA PER RECUPERARE IL VALORE DELLA CELLA DA DISEGNARE
                    for (d = 1; d <= mp_NumDimCol; d++)
                    {



                        //'-- se ho superato il numero delle celle azzero il contatore
                        if (vetScostRelCol[d] >= mp_VetScostCol[d])
                        {

                            vetScostRelCol[d] = 0;


                            //'-- incremento l'indice della dimensione
                            vetIndDimCol[d] = vetIndDimCol[d] + 1;


                            //'-- verifico che l'indice non abbia superato il numero di elementi della dimensione
                            if (vetIndDimCol[d] >= mp_VetDimCol[d].Elem.Count)
                            {
                                vetIndDimCol[d] = 0;
                            }


                        }




                        //'-- calcolo lo scostamento relativo
                        StartScost = StartScost + (vetIndDimCol[d] * mp_arrSfasamento[mp_VetRelSfafamentoAssolutoCol[d]]);


                    }



                    //'-- ciclo sui dati per la visualizzazione
                    for (c = 1; c <= nC; c++)
                    {


                        //'-- incremento GLI INDICI SULLE VARIE DIMENSIONI DI COLONNA PER CALCOLARE GLI SCOSTAMENTI
                        for (d = 1; d <= mp_NumDimCol; d++)
                        {
                            vetScostRelCol[d] = vetScostRelCol[d] + 1;
                        }

                        obj = mp_collFields.ElementAt((int)c - 1).Value;
                        obj.Value = mp_ArrValues[StartScost + c - 1];
                        k = k + 1;
                        //'--aggiorno il totale di colonna
                        VetTotalCol[k] = VetTotalCol[k] + obj.Value;

                        //'-- identifico il campo sulla riga

                        obj.SetRow(StartScost + c - 1);
                        strProp = SetCellProperty(StartScost + c - 1, obj.Name, strStyle);
                        bDrawed = false;
                        //'                If Not mp_OBJCustomCellDraw Is Nothing Then
                        //'                    bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(Me, 0, obj, r, c, strProp, objResp)
                        //'                End If

                        if (!bDrawed)
                        {

                            //'-- apro la cella
                            objResp.Write("<td ");
                            //'objResp.Write(" id=""" + Id + "_r" + r + "_c" + c + """ "

                            //'objResp.Write(strProp

                            objResp.Write(">");

                            //'-- scrivo il valore
                            obj.umValueHtml(objResp, false);
                            obj.ValueExcel(objResp, false);


                            //'-- chiudo la cella
                            objResp.Write("</td>" + Environment.NewLine);

                        }

                    }



                }


                //'-- prima di chiudere la riga vanno disegnati i totale se presenti




                //'-- chiudo la riga
                objResp.Write("</tr>" + Environment.NewLine);

            }


            //'--disegno la riga dei totali di colonna
            DrawTotalCol(ref objResp, ref vetScostRelCol, ref vetIndDimCol, ref VetTotalCol, nct, nC, strStyle);


            return objResp.Out();

        }


        //'-- la funzione esegue le espressioni dei campi calcolati
        //'-- il presuposto è che le colonne delle info sono sul livello più basso
        //'-- la funzione va bene anche per il calcolo dei totali
        private void ExecCalculatedField(dynamic[] ArrValues, long sfasa)
        {


            long TotLen = default;
            long i = default;
            long x = default;
            long lIndex = default;
            Field cField;
            dynamic valore;
            long lDomSfasamento = default;
            //Dim scpript As Object //'New ScriptControl
            string strExp = string.Empty;
            int y = 0;

            // TODO On Error Resume Next


            string[] ArF2C;
            Grid_ColumnsProperty prop = new Grid_ColumnsProperty();
            dynamic v;

            int n = 0;
            bool bFound = default;
            int m = 0;

            bFound = false;
            n = mp_collFields.Count;
            m = n - 1;
            TotLen = ((ArrValues.GetUpperBound(0) + 1) / n) - 1;


            ArF2C = new string[n + 1];


            //'-- verifica quali colonne devono essere calcolate
            //'-- e conservo le espressioni per il calcolo
            for (i = 1; i <= n; i++)
            {


                cField = mp_collFields.ElementAt((int)i - 1).Value;
                prop = ColumnsProperty[cField.Name];
                if (!String.IsNullOrEmpty(prop.Expr))
                {
                    ArF2C[i - 1] = prop.Expr;
                    bFound = true;
                }
                else
                {
                    ArF2C[i - 1] = "";
                }

                //'-- se non ci sono colonne esce
                if (!bFound) { return; }

                //Set scpript = CreateObject("ScriptControl")
                //        scpript.Language = "VBscript"

                for (x = 0; x < TotLen; x++)
                {

                    lDomSfasamento = x * n + sfasa;

                    //' scorre la collezione dei fields
                    for (y = 0; y < n; i++)
                    {


                        //'-- se il campo prevede un'epressione
                        if (!String.IsNullOrEmpty(ArF2C[y]))
                        {

                            strExp = ArF2C[y];
                            for (i = 1; i <= n; i++)
                            {
                                cField = mp_collFields.ElementAt((int)i).Value;
                                strExp = strExp.Replace(cField.Name, ArrValues[lDomSfasamento + i - 1].Replace(",", "."));
                            }

                            try
                            {
                                ArrValues[lDomSfasamento + y] = CommonModule.Basic.ComputeEval(strExp);
                            }
                            catch
                            {
                                ArrValues[lDomSfasamento + y] = null!;
                            }

                        }

                    }
                }


            }
        }

        private string CheckCondition(string FormatCondition, dynamic ArrValues, long cell)
        {

            string[] v;
            string[] s;
            int vn = 0;
            int i = 0;

            string result = string.Empty;

            if (!String.IsNullOrEmpty(ArrValues[cell])) { return result; }

            v = FormatCondition.Split("#");
            vn = v.GetUpperBound(0);

            for (i = 0; i < vn; i++)
            {
                s = v[i].Split("~");



                if (s[1] == ">")
                {

                    s[2] = setValue(s[2]);

                    //if (CommonModule.Basic.CStr(0.5).Contains("."))
                    //{
                    //    s[2] = s[2].Replace(",", ".");
                    //}
                    //else
                    //{
                    //    s[2] = s[2].Replace(".", ",");
                    //}



                    if (ArrValues[cell] > CommonModule.Basic.CDbl(s[2]))
                    {
                        result = s[0];
                    }

                }
                else if (s[1] == ">=")
                {
                    s[2] = setValue(s[2]);

                    //if (CommonModule.Basic.CStr(0.5).Contains("."))
                    //{
                    //    s[2] = s[2].Replace(",", ".");
                    //}
                    //else
                    //{
                    //    s[2] = s[2].Replace(".", ",");
                    //}



                    if (ArrValues[cell] >= CommonModule.Basic.CDbl(s[2]))
                    {
                        result = s[0];
                    }




                }
                else if (s[1] == "<")
                {
                    s[2] = setValue(s[2]);

                    //    If InStr(CStr(0.5), ".") > 0 Then
                    //    s(2) = Replace(s(2), ",", ".")
                    //Else
                    //    s(2) = Replace(s(2), ".", ",")
                    //End If



                    if (ArrValues[cell] < CommonModule.Basic.CDbl(s[2]))
                    {
                        result = s[0];
                    }



                }
                else if (s[1] == "=")
                {
                    s[2] = setValue(s[2]);

                    //If InStr(CStr(0.5), ".") > 0 Then
                    //    s(2) = Replace(s(2), ",", ".")
                    //Else
                    //    s(2) = Replace(s(2), ".", ",")
                    //End If


                    if (ArrValues[cell] == s[2])
                    {
                        result = s[0];
                    }


                }


            }
            return result;
        }

        public void SetExternalValues(ref dynamic[] ArrValues, dynamic VetTotalCol)
        {
            //' il primo elemento è lo sfasamento dei fields = 1
            //' l'elemento i-esimo è lo sfasamento del dominio i-esimo

            mp_arrSfasamento = new int[mp_collDomainDimension.Count + 1];
            //mp_arrSfasamento = new int[mp_collDomainDimension.Count];

            mp_arrSfasamento[0] = 1;


            //' -- calcola la size dell'array dei valori
            //' -- moltiplicando il numero di elementi di ogni dominio X il numero di fields
            //' -- avvalora anche il vettore dello sfasamento
            lSizeDomains = GetSizeOfDomains();
            lSizeArrValues = lSizeDomains * mp_collFields.Count;



            mp_ArrValues = ArrValues;
            mp_VetTotalCol = VetTotalCol;


        }

        private string setValue(string strToCheck)
        {
            string result = string.Empty;
            string value = (0.5).ToString();
            if (value.Contains(".", StringComparison.Ordinal))
            {
                result = strToCheck.Replace(".", ",");
            }
            else if (value.Contains(",", StringComparison.Ordinal))
            {
                result = strToCheck.Replace(",", ".");
            }
            return result;
        }
        //'--disegna la riga dei totali di colonna

    }
}
