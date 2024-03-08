using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.BasicFunction;


namespace eProcurementNext.HTML
{
    public class Grid
    {
        public string accessible = string.Empty;
        public string Caption; // -- titolo della griglia
        public string Style; // -- Classe css associata alla griglia
        public string StyleCaption; // -- classe css associata alla riga di testata delle colonne
        public string StyleRow0; // -- classe css associata alla riga pr disapri
        public string StyleRow1; // --

        public string id; // -- identificativo della griglia

        public Dictionary<string, Field> Columns = new Dictionary<string, Field>();
        public Dictionary<string, Grid_ColumnsProperty> ColumnsProperty;

        public string width, Height;

        private bool _Editable = false;

        public bool Editable
        {
            get { return _Editable; }
            set { _Editable = value; }
        } // indica se la griglia è editabile per default non lo è
        public int DrawMode;  // indica la modalità di disegno della griglia: 1= griglia, 2 = schede

        private dynamic[,] mp_Matrix; // matrice dei valori contenuti nella ?
                                      // deve essere in stretta relazione con le colonne
                                      // si considera zero based (riga,c olonna)

        private dynamic mp_vIdRow; // -- contiene un array con gli identificativi di riga, se valorizzato

        private long mp_numRow;
        private int mp_numCol;

        // -------------------------------------------------------------
        // - rivedere come gestire questi Recordset
        // -------------------------------------------------------------

        private TSRecordSet mp_RS;
        private string mp_strFieldKey; // __ nel caso ci sia il recrdset contine eil campo che fa da chiave per i record

        // usate per paginazione griglia
        private long mp_CurPage; // se valorizzato indica la pagina corrente a partire da 1
        private long mp_RowPage; // indica il numero di righe da visualizzare in una pagina

        // anche questo è da correggere secondo la nuova gestione Response
        private dynamic Response;

        private string mp_TotalTitle; // stringa per la descrizione del totale della griglia
        private int mp_ColSpanTotal;  // numero colonne su cui esprimere il totale
        private bool mp_ShowTotal;

        private List<string> mp_rowCondition = new List<string>(); // collezione che contiene condizioni per
                                                                   // impostare style in funzione della condizione

        public string URL; // -- indirizzo da chiamare quando si richiede il sort di una colonna
        public string Sort; // -- nome della colonna su cui mettere la bitmap del sort
                            // -- E"" A CURA DELL""APPLICAZIONE FARE IL SORT DEL RECORDSET O DELLA MATRICE

        public string SortOrder; // verso su cui è espresso il sort
        private bool AutoSort;
        private bool SortAll;

        public bool PrintMode; // indica che la griglia è visualizzata per una stampa quindi vanno messi i meccanismi di eventi come onclick

        // variabili per il lock della tabella
        private bool mp_Locked;
        private int mp_RowLocked; //-- quante righe devono essere fisse sullo schermo
        private int mp_ColLocked; //-- quante colonne devono essere fisse sullo schermo

        //-- oggetto per personalizzare la visualizzazione delle celle
        private dynamic? mp_OBJCustomCellDraw;

        private bool mp_RowCol; //-- indica se la matrice è ricga colonna o colonna riga
        private bool mp_SingleLock; //-- attiva il lock della riga di testata
        public int ActiveSelection; //-- 0 selezione disattiva , 1 singola 2 multipla,3 multipla ma con selezione
                                    //-- attivata solo su click della prima colonna

        private string mp_strIdRowOrder; //-- contiene gli indici delle righe ordinato secondo il criterio richiesto
                                         //-- gli indici delle righe sono separate da # esempio : "1#3#2"

        public string FieldStyle;

        public dynamic objModelPositional; //--se presente è l""oggetto del modello posizionale per disegnare righe della griglia


        public int UseNameGridOnField; //-- nel differenziare i campi della griglia usa anche il nome oltre alla riga

        public string mp_accessible;

        public string mp_ColFieldNotEditable; //-- nome della colonna nel RS che contiene i nomi dei campi non editabili

        public bool mp_Show_NumRow; //-- si/no si visualizza numero righe altrimenti no
        public string mp_str_Label_NumRow; //--stringa da anteporre a numero righe se da visualizzare

        public Grid()
        {
            Style = "Grid";
            StyleCaption = "_RowCaption";
            StyleRow0 = "GR0";
            StyleRow1 = "GR1";
            //mp_Matrix = Empty;
            //mp_vIdRow = Empty;
            width = "100%";
            ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
            Editable = false;
            DrawMode = 1;
            mp_ShowTotal = false;
            mp_TotalTitle = "";
            mp_ColSpanTotal = 1;
            mp_RowCol = true;



            mp_accessible = "";
            mp_ColFieldNotEditable = "";


            mp_Show_NumRow = false;
            mp_str_Label_NumRow = "Numero Righe";
        }
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {

            int numCol, c;

            Field obj = new Field();
            if (!JS.ContainsKey("checkbrowser"))
            {
                JS.Add("checkbrowser", $@"<script src=""{Path}jscript/checkbrowser.js""></script>");
            }
            if (!JS.ContainsKey("getObj"))
            {
                JS.Add("getObj", $@"<script src=""{Path}jscript/getObj.js""></script>");
            }
            if (!JS.ContainsKey("ExecFunction"))
            {
                JS.Add("ExecFunction", $@"<script src=""{Path}jscript/ExecFunction.js""></script>");
            }
            if (!JS.ContainsKey("setClassName"))
            {

                JS.Add("setClassName", $@"<script src=""{Path}jscript/setClassName.js""></script>");
            }
            if (!JS.ContainsKey("GetIdRow"))
            {
                JS.Add("GetIdRow", $@"<script src=""{Path}jscript/grid/GetIdRow.js""></script>");
            }
            if (!JS.ContainsKey("grid"))
            {

                JS.Add("grid", $@"<script src=""{Path}jscript/grid/grid.js""></script>");
            }
            if (!JS.ContainsKey("GetPosition"))
            {
                JS.Add("GetPosition", $@"<script src=""{Path}jscript/GetPosition.js""></script>");
            }
            if (!JS.ContainsKey("lockedGrid"))
            {
                JS.Add("lockedGrid", $@"<script src=""{Path}jscript/grid/lockedGrid.js""></script>");
            }
            if (!JS.ContainsKey("GetCheckedRows"))
            {
                JS.Add("GetCheckedRows", $@"<script src=""{Path}jscript/grid/GetCheckedRows.js""></script>");
            }
            //-- aggiungo i js dei campi utilizzati sulla griglia
            numCol = Columns.Count - 1;

            foreach (KeyValuePair<string, Field> col in Columns)
            {
                col.Value.JScript(JS, Path);
            }

            //For c = 0 To numCol
            //    Columns.Item(c + 1).JScript JS, Path
            //Next
        }

        private void Class_Initialize()
        {

        }

        //'-- determina quante righe e colonne blocacre sullo schermo
        public void SetLockedInfo(int row, int col = 0)
        {

            if (row != 0 || col != 0)
            {
                mp_Locked = true;
            }
            else
            {
                mp_Locked = false;
            }

            mp_RowLocked = row; //'-- quante righe devono essere fisse sullo schermo
            mp_ColLocked = col; //'-- quante colonne devono essere fisse sullo schermo

        }

        public void SetMatrix(dynamic[,] m, long[]? vIdRow = null)
        {

            mp_Matrix = m;

            if (!IsEmpty(m))
            {
                if (mp_RowCol)
                {
                    mp_numRow = mp_Matrix.GetUpperBound(0);
                    mp_numCol = mp_Matrix.GetUpperBound(1);
                }
                else
                {
                    mp_numCol = mp_Matrix.GetUpperBound(0);
                    mp_numRow = mp_Matrix.GetUpperBound(1);
                }


                mp_vIdRow = vIdRow;
            }
            else
            {
                mp_numRow = -1;
            }
        }

        public string Html(IEprocResponse _response, IEprocResponse? toolbarHtml = null)
        {
            long EndRow;
            long StartRow;

            if (AutoSort)
            {
                try
                {
                    if (mp_RS != null)
                    {
                        if (!String.IsNullOrEmpty(Sort))
                        {
                            mp_RS.Sort(Sort + " " + SortOrder);
                        }
                    }
                    else
                    {
                        if (!String.IsNullOrEmpty(Sort))
                        {
                            SortMatrix();
                        }
                    }
                }
                catch
                {
                    Sort = "";
                    SortOrder = "";
                }
            }


            if (mp_Locked)
            {
                _response.Write("<div");
                if (IsMasterPageNew())
                {
					_response.Write(@" class=""access_width_max_width height_100_percent GrigliaFaseII""");
                }
                else
                {
				    _response.Write(@" class=""access_width_max_width height_100_percent""");
                }
                _response.Write(@$" id=""div_{id}"" ");
            }
            else
            {
                if (IsMasterPageNew())
                {
                    _response.Write(@$"<div id=""div_{id}"" class=""access_width_max_width GrigliaFaseII"" ");
                }
                else
                {
					_response.Write(@$"<div id=""div_{id}"" class=""access_width_max_width"" ");
				}
			}

            if (mp_SingleLock)
            {
                _response.Write($@" width=""{width}"" style=""height:{Height}"" ");
            }

            // DA CONTROLLARE!!!!

            _response.Write(">" + Environment.NewLine);
            if (Columns == null)
            {
                _response.Write("La griglia non è stata avvalorata");
                _response.Write(Caption);
                _response.Write("</div>" + Environment.NewLine);
                return _response.Out();
            }

            //-- aggiunge le variabili per la selezione
            _response.Write($"<script type=\"text/javascript\"> " + Environment.NewLine);
            _response.Write($"var {id}_StyleRow = new Array({mp_numRow} + 1 );" + Environment.NewLine);
            _response.Write($"var {id}_SelectedRow = new Array({mp_numRow}  + 1);" + Environment.NewLine);
            _response.Write($"var {id}_NumRow = {mp_numRow};" + Environment.NewLine);

            // se la griglia è paginata
            if (mp_CurPage > 0)
            {
                StartRow = mp_RowPage * (mp_CurPage - 1);
                EndRow = StartRow + mp_RowPage;
            }
            else
            {
                StartRow = 0;
                EndRow = mp_numRow;
            }

            _response.Write($"var {id}_StartRow = {StartRow};" + Environment.NewLine);
            _response.Write($"var {id}_EndRow = {EndRow};" + Environment.NewLine);


            _response.Write($"var {id}_StyleRow0 = '{StyleRow0}' ;" + Environment.NewLine);
            _response.Write($"var {id}_StyleRow1 = '{StyleRow1}' ;" + Environment.NewLine);
            _response.Write($"var {id}_ActiveSelection = '{ActiveSelection}' ;" + Environment.NewLine);
            _response.Write("</script> ");

            HTML_HiddenField(_response, id + "_CurPage", mp_CurPage.ToString());

            _response.Write(WriteIdRow());

            if (!String.IsNullOrEmpty(Caption) || mp_Show_NumRow)
            {
                _response.Write($@"<table class=""{Style}_Title""  id=""{id}_Caption"" cellspacing=""0"" cellpadding=""0"">");
                _response.Write("<tr>");

                if (mp_Show_NumRow)
                {
                    _response.Write($@"<td class=""Cell_NumRow_Grid""><span class=""dettagli_label_numerorighe"">{mp_str_Label_NumRow} </span><span class=""dettagli_numerorighe"" id=""{id}_dettagli_numerorighe"" >{mp_numRow + 1}</span></td>");
                }

                if (!String.IsNullOrEmpty(Caption))
                {
                    _response.Write($@"<td class=""{Style}_TitleCell"" >");
                    _response.Write(Caption + "</td>");
                }

                _response.Write("</tr>");
                if (IsMasterPageNew() && toolbarHtml != null)
                {
                    _response.Write("<tr><td>");
                    _response.Write(toolbarHtml.Out());
                    _response.Write("</tr></td>");
                }
                _response.Write("<tr>");

                if (mp_Show_NumRow && !String.IsNullOrEmpty(Caption))
                {
                    _response.Write(@"<td colspan=2>" + Environment.NewLine);
                }
                else
                {
                    _response.Write("<td>" + Environment.NewLine);
                }
            }
            else
            {
                if (IsMasterPageNew() && toolbarHtml != null)
                {
                    _response.Write(toolbarHtml.Out());
                }
            }

            if (mp_Locked && !PrintMode)
            {
                DrawLockedGridHtml(_response);
            }
            else
            {
                DrawGridHtml(_response);
            }

            if (!String.IsNullOrEmpty(Caption) || mp_Show_NumRow)
            {
                _response.Write("</td></tr></table>");
            }

            _response.Write("</div>" + Environment.NewLine);

            return _response.Out();
        }

        private void DrawLockedGridHtml(IEprocResponse objResp)  // verificare objResponse
        {
            objResp.Write($@"<div id=""{id}_ShowedDiv"" width=""100%"" style=""height:100%"" >");
            objResp.Write(@"<table border=""0"" id=""" + id + @"_Showed"" width=""100%"" height=""100%"" onresize=""javascript: try { ResizeGrid(""" + id + @"""); } catch( e ){  ; }; > ");

            objResp.Write("<tr>");
            objResp.Write(@"<td width=""100%"" height=""100%"" valign=""middle"" align=""center""><img alt=""wait"" src=""../CTL_LIBRARY/images/GRID/clessidra.gif"" />&nbsp;<span id=""" + id + @"_loading"">Loading... 0%</span>");
            objResp.Write("</td>");
            objResp.Write("</tr>");
            objResp.Write("</table>");
            objResp.Write("</div>");
        }

        private void DrawLockedHtml(IEprocResponse objResp)
        {
            objResp.Write($@"div id=""{id}_Content"" ");
            objResp.Write($@" class=""div_grid_multi_dim_overflow_auto""");

            objResp.Write(">");

            DrawGridHtml(objResp);

            objResp.Write(">");

            // '-- disegno la div per le righe fisse
            objResp.Write($"<div id=\"{id}_LockedRow\" ");

            objResp.Write($" class=\"div_grid_multi_dim_overflow_hidden\"");
            objResp.Write(">");
            objResp.Write("</div>");

            // '-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
            // '-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
            // '-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
            objResp.Write($"<input type=\"hidden\" id=\"{id}_LockedRow_extraAttrib\" value=\"Rows#=#{CStr(mp_RowLocked)}\"/>");

            //'-- disegno la div per le colonne fisse
            objResp.Write($"<div id=\"{id}_LockedCol\" ");


            objResp.Write($" class=\"div_grid_multi_dim_overflow_hidden\"");
            objResp.Write($" cols = \"{mp_ColLocked}\">");
            objResp.Write("</div>");

            //'-- disegno la div per l'angolo fisso se necessario
            objResp.Write($"<div id=\"{id}_LockedCorner\"");
            objResp.Write($" class=\"div_grid_multi_dim_overflow_hidden\"");

            objResp.Write($" cols = \"{mp_ColLocked}\">");
            objResp.Write("</div>");

            //'-- js per disegnare e posizionare la prima volta la griglia
            objResp.Write($"<script type=\"text/javascript\">" + Environment.NewLine);
            objResp.Write($" StartScrolledGrid( '{id}' ); " + Environment.NewLine);
            objResp.Write($" var OldFunc{id} = window.onresize;" + Environment.NewLine);
            objResp.Write($" window.onresize = NewRes{id};" + Environment.NewLine);
            objResp.Write($" function NewRes{id}(){{" + Environment.NewLine);
            objResp.Write($" try{{ResizeGrid( '{id}' );" + Environment.NewLine);
            objResp.Write($" OldFunc{id}(); }}catch(e) {{}} }}" + Environment.NewLine);
            objResp.Write("</script>");

        }

        private void DrawGridHtml(IEprocResponse objResp)
        {
            if (mp_SingleLock && mp_Locked == false && PrintMode == false)
            {
                objResp.Write(@"<style type=""text/css"">");
                objResp.Write(@"DIV.Container_" + id + "{");
                objResp.Write(@"    MARGIN: 0px auto; OVERFLOW: auto; width: """ + width + @""" height: """ + Height + @"""");
                objResp.Write(@"}");
                objResp.Write(@"THEAD TD {");
                objResp.Write(@"    POSITION: relative; ; TOP: expression(document.getElementById(""DIVLOCKSINGLE_" + id + @""").scrollTop-2);");
                objResp.Write(@"}");
                objResp.Write(@"</style>");

                objResp.Write($@"<div class=""Container_" + id + @""" id=""DIVLOCKSINGLE_" + id + @""" > ");
            }

            //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
            //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
            //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
            objResp.Write(@"<input type=""hidden"" id=""" + id + @"_extraAttrib"" value=""numrow#=#" + CStr(mp_numRow) + @"""/>");

            //'-- apertura della tabella HTML
			objResp.Write($@"<table class=""Grid""  id=""" + id + @""" " + IIF(!string.IsNullOrEmpty(width) || mp_Locked == true, @" width=""" + width + @""" ", "") + @" cellspacing=""0"" cellpadding=""0"" ");
			
			objResp.Write($@">" + Environment.NewLine);

            //'-- disegna le caption
            if (DrawMode == 1)
            {
                DrawCaption(objResp);
            }

            //'-- disegna le righe
            DrawRows(objResp);

            //'-- disegno la riga di totale
            if (mp_ShowTotal)
            {
                DrawTotal(objResp);
            }

            objResp.Write("</table>");

            if (mp_SingleLock == true && mp_Locked == false && PrintMode == false)
            {
                objResp.Write("<div>");
            }
        }

        public void ShowTotal(string Title, int colspan)
        {

            mp_TotalTitle = Title;
            mp_ColSpanTotal = colspan;
            mp_ShowTotal = true;

        }

        public void DrawTotal(IEprocResponse objResp)
        {
            Field obj;
            long r, c;
            string strCaption;
            Grid_ColumnsProperty prop;

            double[] vetTotal;
            bool st;
            bool bDrawed;

            long rowCounter;
            long StartRow;
            long nIndRow;
            double totale;

            // apro la riga
            objResp.Write($"<tr>" + Environment.NewLine);

            if ((ActiveSelection == 2 || ActiveSelection == 3) && !PrintMode && DrawMode == 1)
            {
                objResp.Write($@"<td class=""{Style}_Total"">&nbsp;</td>" + Environment.NewLine);
            }

            mp_numCol = Columns.Count - 1;
            vetTotal = new double[Columns.Count + 1];

            if (mp_RS == null)
            {
                StartRow = 0;

                // ciclo sulle righe della matrice
                for (r = StartRow; r <= mp_numRow; r++)
                {
                    nIndRow = r;
                    //int c1 = 0;
                    for (c = 0; c <= mp_numCol; c++)
                    {// To mp_numCol

                        obj = Columns.ElementAt((int)c + 1 - 1).Value;
                        st = false;
                        st = ColumnsProperty[obj.Name].Total;

                        if (st)
                        {
                            if (mp_RowCol)
                            {
                                totale = 0;
                                totale = CDbl(mp_Matrix[nIndRow, c]);
                                vetTotal[c] = vetTotal[c] + totale;
                            }
                            else
                            {
                                totale = 0;
                                totale = CDbl(mp_Matrix[c, nIndRow]);

                                vetTotal[c] = vetTotal[c] + totale;
                            }
                        }
                    }
                }
            }
            else
            {
                // calcola i totali
                if (mp_RS != null && mp_RS.RecordCount > 0)
                {
                    mp_RS.MoveFirst();
                    while (!mp_RS.EOF)
                    {

                        for (c = 0; c <= mp_numCol; c++)
                        {
                            obj = Columns.ElementAt((int)c + 1 - 1).Value;
                            st = false;
                            try
                            {
                                st = ColumnsProperty[obj.Name].Total;
                            }
                            catch { }
                            if (st)
                            {
                                vetTotal[c] = vetTotal[c] + CDbl(GetValueFromRS(mp_RS.Fields[obj.Name]));
                            }
                        }

                        mp_RS.MoveNext();
                    }
                }
            }

            int cSpan = 0;
            for (c = 1; c <= mp_ColSpanTotal; c++)
            {
                obj = Columns.ElementAt((int)c - 1).Value;
                st = false;
                try
                {
                    st = ColumnsProperty[obj.Name].Hide;
                }
                catch { }
                if (!st)
                {
                    cSpan++;
                }
            }

            // disegna la caption dei totali
            if (cSpan > 0)
            {
                objResp.Write("<td");

                objResp.Write($@" class=""{Style}_Total nowrap"" ");
                objResp.Write($@" colspan=""{cSpan}"" >");
                objResp.Write(mp_TotalTitle);
                objResp.Write("</td>");
            }

            // disegna i totali
            for (c = mp_ColSpanTotal; c <= mp_numCol; c++)
            {
                obj = Columns.ElementAt((int)c + 1 - 1).Value;
                st = false;
                try
                {
                    st = ColumnsProperty[obj.Name].Hide;
                }
                catch
                {
                    st = false;
                }

                if (!st)
                {
                    objResp.Write("<td");
                    objResp.Write($@" class=""{Style}_Total_{obj.Style} nowrap"">");
                    st = false;
                    try
                    {
                        st = ColumnsProperty[obj.Name].Total;
                    }
                    catch
                    {
                        st = false;
                    }
                    if (st)
                    {
                        obj.Value = vetTotal[c];
                        obj.SetRow2("Tot");

                        bDrawed = false;

                        if (mp_OBJCustomCellDraw != null)
                        {
                            try
                            {
                                bDrawed = mp_OBJCustomCellDraw.Grid_DrawTotal(this, 0, obj, c, objResp);
                            }
                            catch
                            {

                            }
                        }

                        if (!bDrawed)
                        {
                            obj.ValueHtml(objResp, false);
                        }
                    }
                    else
                    {
                        objResp.Write("&nbsp;");
                    }
                    objResp.Write("</td>" + Environment.NewLine);
                }
            }

            objResp.Write("</tr>" + Environment.NewLine);
        }
        public void DrawCaption(IEprocResponse objResp)
        {

            Field obj;
            int c;
            string strCaption;
            Grid_ColumnsProperty prop = null;
            bool bSortCol;
            bool bShowSort;
            string strCssTempClassCaption;

            bool bHide;

            strCssTempClassCaption = "";

            if (IsMasterPageNew())
            {
                if (Columns.Count == 0)
                {
                    return;
                }
            }

            if (IsMasterPageNew())
            { 
                objResp.Write(@"<tr class=""firstRowGridFaseII"">" + Environment.NewLine);
            }
            else
            {
                // -- apro la riga
                objResp.Write("<tr>" + Environment.NewLine);
            }

            if ((ActiveSelection == 2 || ActiveSelection == 3) && !PrintMode && DrawMode == 1)
            {
                objResp.Write("<th ");


                objResp.Write($@"class=""{Style + StyleCaption}"" >&nbsp;");

                objResp.Write("</th>" + Environment.NewLine);

            }



            mp_numCol = Columns.Count;

            for (c = 0; c < mp_numCol; c++)
            {
                strCssTempClassCaption = "";
                obj = Columns.ElementAt(c).Value;
                bHide = false;
                if (ColumnsProperty != null)
                {
                    if (ColumnsProperty.ContainsKey(obj.Name))
                    {
                        prop = ColumnsProperty[obj.Name];
                        bHide = prop.Hide;
                    }

                }

                if (bHide)
                {
                    objResp.Write(@"<th class=""display_none"" ");
                    objResp.Write(@" id=""" + id + "_" + obj.Name + @""" ");
                    objResp.Write(">");

                    objResp.Write($@"<input type=""hidden"" id=""{id}_{obj.Name}_extraAttrib"" value=""column#=#{c}"" />");
                    objResp.Write("</th>");
                }
                else
                {
                    strCaption = obj.Caption;

                    // -- apro la cella

                    objResp.Write("<th");
                    objResp.Write($@" id=""{id}_{obj.Name}"" ");

                    bSortCol = false;

                    //-- determino la larghezza delle colonne per troncare alla larghezza desiderata
                    if (ColumnsProperty != null && ColumnsProperty.ContainsKey(obj.Name))
                    {
                        prop = ColumnsProperty[obj.Name];

                        if (prop.Length > 0)
                        {
                            //Se la stringa contenuta in strCaption è più lunga della dimensione richiesta, la spezziamo aggiungendoci i "..."
                            if (!IsMasterPageNew() && strCaption.Length > prop.Length && prop.Length >= 3)
                            {
                                objResp.Write($@" title=""{strCaption}"" ");
                                strCaption = strCaption.Substring(0, prop.Length - 3) + "...";
                            }
                        }

                        if (!String.IsNullOrEmpty(prop.width))
                        {
                            strCssTempClassCaption = $" nowrap " + getWidthAccessibile(prop.width, "width") + " ";
                        }
                        else if (obj.width > 0)
                        {
                            strCssTempClassCaption = " " + getWidthAccessibile((obj.width * 7).ToString(), "width") + " ";
                        }

                        if (prop.Sort) { bSortCol = true; }
                    }
                    else
                    {

                        if (obj.width > 0)
                        {
                            strCssTempClassCaption = " " + getWidthAccessibile((obj.width * 7).ToString(), "width") + " ";
                        }
                    }

                    string strOnClickOrder = "";

                    bShowSort = true;


                    if (mp_RS != null && (bSortCol || SortAll) && !PrintMode)
                    {
                        if (!mp_RS.Columns.Contains(obj.Name))
                        {
                            bShowSort = false;
                        }

                    }

                    //-- se la colonna ha il sort aggiunge il link per l""ordinamento
                    if ((bSortCol || SortAll) && !PrintMode && bShowSort)
                    {
                        string iifDue = SortOrder == "asc" ? "desc" : "asc";
                        string iifUno = Sort != obj.Name ? "asc" : iifDue;
                        //strOnClickOrder = $" onclick=\"javascript:self.location='{WebUtility.UrlEncode(URL + "&Sort=" + obj.Name + "&SortOrder=" + iifUno)}';return false;\"";
                        strOnClickOrder = $" onclick=\"javascript:self.location='{URL + "&Sort=" + obj.Name + "&SortOrder=" + iifUno}';return false;\"";
                        objResp.Write($@" class=""{strCssTempClassCaption}{Style}{StyleCaption}_Sort"" ");
                    }
                    else
                    {
                        objResp.Write($@" class=""{strCssTempClassCaption}{Style}{StyleCaption}""");
                    }

                    objResp.Write(">");

                    objResp.Write($@"<input type=""hidden"" id=""{id}_{obj.Name}_extraAttrib"" value=""column#=#{c}"" />");

                    if (obj.Name == Sort)
                    {
                        string picName = SortOrder == "asc" ? "asc.gif" : "desc.gif";
                        objResp.Write($@" <img alt="""" src=""../CTL_Library/images/Grid/{picName}"" />");
                    }

                    if (strOnClickOrder != "")
                    {
                        objResp.Write(@"<a class=""link_grid_order"" href=""#"" ");
                        objResp.Write(strOnClickOrder);
                        objResp.Write(">");
                    }

                    // scrivo il valore
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@"<span title=""{ExtractTextFromHtml(strCaption)}"">{strCaption}</span>");
                    }
                    else
                    {
                        objResp.Write(strCaption);
                    }

                    if (strOnClickOrder != "")
                    {
                        objResp.Write("</a>");
                    }

                    //chiudo la cella
                    objResp.Write("</th>" + Environment.NewLine);
                }
            }

            obj = null;
            objResp.Write("</tr>" + Environment.NewLine);

        }


        public void DrawRows(IEprocResponse objResp)
        {
            string strStyle;
            //Dim strApp As String
            long r, c;
            string n;
            Grid_ColumnsProperty propCol;
            long rowCounter;
            long StartRow;
            string strVal;
            // On Error Resume Next
            dynamic v; // As Variant
            bool bDrawed;
            string strProp;
            bool bDrawLoading;
            double passo;
            double PercLoading;
            long TotRecord;
            string rn;
            dynamic[] vPropColR1;
            dynamic[] vPropColR2;
            Field obj;
            bool bPersonalStyle;
            dynamic[] aOrderRow;
            long nIndRow;
            string strOnClickCel;
            bool bNotEdit;
            string strColNotEditable;

            TotRecord = 0;
            PercLoading = 0;
            passo = 0f;
            r = 0;
            // verificare se Column == null 

            aOrderRow = new dynamic[] { };

            mp_numCol = Columns.Count - 1;

            vPropColR1 = new dynamic[mp_numCol + 1];
            vPropColR2 = new dynamic[mp_numCol + 1];
            try
            {
                for (c = 0; c <= mp_numCol; c++)
                {
                    obj = Columns.ElementAt((int)c).Value;
                    vPropColR1[c] = SetCellProperty(r, obj.Name, StyleRow1);
                    vPropColR2[c] = SetCellProperty(r, obj.Name, StyleRow0);
                }

                bDrawLoading = false;

                //'-- determina se è necessario inserire lo script di aggiornamento % per loading
                //'If DrawMode = 1 And PrintMode = False And mp_CurPage = 0 Then
                if (DrawMode == 1 && !PrintMode && mp_Locked)
                {
                    bDrawLoading = true;
                    if (mp_RS == null)
                    {
                        if (mp_CurPage > 0)
                        {
                            TotRecord = mp_RowPage;
                        }
                        else
                        {
                            TotRecord = mp_numRow;
                        }
                        passo = TotRecord / 10;
                    }
                    else
                    {
                        if (mp_CurPage > 0)
                        {
                            TotRecord = mp_RowPage;
                        }
                        else
                        {
                            TotRecord = mp_RS.RecordCount;
                        }
                        passo = TotRecord / 10;
                    }
                    PercLoading = passo;
                }
                if (mp_RS == null)
                {
                    if (IsEmpty(mp_Matrix))
                    {
                        mp_numRow = -1;
                    }

                    StartRow = 0;
                    rowCounter = 0;

                    // se la griglia è paginata 

                    if (mp_CurPage > 0)
                    {
                        StartRow = mp_RowPage * (mp_CurPage - 1);
                    }

                    if (!String.IsNullOrEmpty(mp_strIdRowOrder))
                    {
                        aOrderRow = mp_strIdRowOrder.Split('#');
                    }


                    // ciclo sulle righe della matrice
                    for (r = StartRow; r <= mp_numRow; r++)
                    {
                        nIndRow = r;
                        //se è stato fatto un ordinamento stampo secondo l'ordine richiesto
                        if (!String.IsNullOrEmpty(mp_strIdRowOrder))
                        {
                            nIndRow = aOrderRow[r];
                        }

                        bPersonalStyle = false;

                        if (r % 2 == 0)
                        {
                            strStyle = StyleRow0;
                        }
                        else
                        {
                            strStyle = StyleRow1;
                        }

                        //-- attivaDbProfiler la riga

                        objResp.Write("<!--      RIGA " + nIndRow + "                      -->" + Environment.NewLine);

                        if (DrawMode == 1)
                        {
                            rn = id + "R" + nIndRow;
                            if (!PrintMode)
                            {
                                objResp.Write($@"<tr id='{rn}' class='{strStyle}' ");
                                if (ActiveSelection > 0)
                                {
                                    objResp.Write($" onmouseover=\"G_SetRC('{id}', 'GR_OverRow' ,{nIndRow} );\" ");
                                    objResp.Write($" onmouseout=\"G_SetRC( '{id}', '{strStyle}' , {nIndRow} );\" ");
                                }
                                if (ActiveSelection == 2 || ActiveSelection == 3)
                                {
                                    objResp.Write($" onclick=\"G_ClickRow( '{id}', {nIndRow} );\" >" + Environment.NewLine);
                                    objResp.Write($"<td class=\"{strStyle}\">" + Environment.NewLine);
                                    objResp.Write($"<label for=\"{id}_SEL_{CStr(nIndRow)}\" class=\"display_none\">Seleziona</label>");
                                    objResp.Write($"<input type=\"checkbox\" name=\"{id}_SEL\" id=\"{id}_SEL_{CStr(nIndRow)}\"/>");
                                }
                                else
                                {
                                    objResp.Write(" >" + Environment.NewLine);
                                }
                            }
                            else
                            {
                                objResp.Write($"<tr class=\"{strStyle}\">" + Environment.NewLine);
                            }
                        }

                        for (c = 0; c <= mp_numCol; c++)
                        {
                            //obj = Columns.ElementAt((int)c).Value;
                            if (DrawMode == 2)
                            {
                                objResp.Write("<tr>" + Environment.NewLine);
                            }

                            obj = Columns.ElementAt((int)c + 1 - 1).Value;

                            if (mp_RowCol)
                            {
                                obj.Value = mp_Matrix[nIndRow, c];
                            }
                            else
                            {
                                obj.Value = mp_Matrix[c, nIndRow];
                            }

                            // identifico il campo sulla riga
                            if (UseNameGridOnField == 1)
                            {
                                obj.SetRow2(id + "_" + nIndRow);
                            }
                            else
                            {
                                obj.SetRow(nIndRow);
                            }

                            if (!bPersonalStyle)
                            {
                                strProp = (r % 2) == 0 ? vPropColR2[c] : vPropColR1[c];
                            }
                            else
                            {
                                strProp = SetCellProperty(nIndRow, obj.Name, strStyle);
                            }

                            strProp = Strings.Replace(strProp, "<ID_ROW>", CStr(nIndRow));

                            if (strProp != "HIDE")
                            {
                                bDrawed = false;
                                if (mp_OBJCustomCellDraw != null)
                                {
                                    bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(this, CInt(0), obj, CLng(nIndRow), CLng(c), CStr(strProp), objResp);
                                }
                                if (bDrawed == false)
                                {
                                    // apro la cella
                                    objResp.Write($"<td id=\"{id}_r{nIndRow}_c{c}\" {strProp} >" + Environment.NewLine);

                                    if (PrintMode)
                                    {
                                        obj.toPrint(objResp, false);  // VERIFICARE!!!
                                    }
                                    else
                                    {
                                        //'-- recupero la proprietà di onClick sulla cella se presente
                                        //'-- e la utilizzo su un ancora per permetterne la raggiungibilità
                                        //'-- da tastiera

                                        strOnClickCel = getCellPropertyOnClick(r, c, obj.Name);
                                        //'If obj.getType = 9 Then
                                        //'-- annullo il click sulla checkbox essendo 'spuntata' dalla funzione
                                        //'-- presente sull'ancora
                                        //'    obj.setOnClick ("try{ window.event.preventDefault();}catch(e){} try{ window.event.stopPropagation(); }catch(e){}")
                                        //'End If

                                        if (!String.IsNullOrEmpty(strOnClickCel) && !PrintMode)
                                        {
                                            objResp.Write(@"<a class=""link_grid"" href=""#""");
                                            objResp.Write(strOnClickCel);
                                            objResp.Write(">");
                                        }

                                        if (Editable == false)
                                        {
                                            obj.umValueHtml(objResp, false);
                                            obj.ValueHtml(objResp, false);
                                        }
                                        else
                                        {
                                            obj.umValueHtml(objResp);
                                            obj.ValueHtml(objResp);
                                        }

                                        if (!String.IsNullOrEmpty(strOnClickCel) && !PrintMode)
                                        {
                                            objResp.Write("</a>");
                                        }
                                    }
                                    //'-- chiudo la cella
                                    objResp.Write("</td>" + Environment.NewLine);
                                }
                            }
                            else
                            {
                                // se una colonna è nascosta allora disegno un campo nascosto
                                objResp.Write("<td class=\"display_none\">" + Environment.NewLine);

                                if (UseNameGridOnField == 1)
                                {
                                    HTML_HiddenField(objResp, $"R{id}_{nIndRow}_{obj.Name}", obj.TechnicalValue());
                                }
                                else
                                {
                                    HTML_HiddenField(objResp, "R" + nIndRow + "_" + obj.Name, obj.TechnicalValue());
                                }
                                objResp.Write("</td>" + Environment.NewLine);
                            }

                            if (DrawMode == 2)
                            {
                                objResp.Write("</tr>" + Environment.NewLine);
                            }
                        }

                        //'-- chiudo la riga
                        if (DrawMode == 1)
                        {
                            objResp.Write("</tr>" + Environment.NewLine);
                        }
                        else
                        {
                            objResp.Write("</tr><tr><td>&nbsp;</td></tr>" + Environment.NewLine);
                        }


                        //'-- nel caso la griglia sia paginata verifica che non vengano inserite pi� righe di quelle richieste
                        if (mp_CurPage > 0)
                        {
                            rowCounter = rowCounter + 1;
                            if (rowCounter >= mp_RowPage)
                            {
                                break;
                            }
                        }

                    }

                }
                else
                {
                    // altrimenti scorro il recordset

                    // ciclo sulle righe della matrice

                    r = 0;

                    if (mp_RS.RecordCount > 0)
                    {
                        mp_RS.MoveFirst();
                        rowCounter = 0;

                        // se la griglia è paginata
                        if (mp_CurPage > 0)
                        {

                            //mp_RS.AbsolutePosition = (int)(mp_RowPage * (mp_CurPage - 1) + 1);
                            mp_RS.position = (int)(mp_RowPage * (mp_CurPage - 1));
                            r = mp_RowPage * (mp_CurPage - 1);
                        }


                        strOnClickCel = "";

                        while (!mp_RS.EOF)
                        {
                            // recupero colonne non editabili 
                            strColNotEditable = "";
                            if (!String.IsNullOrEmpty(mp_ColFieldNotEditable))
                            {
                                strColNotEditable = UCase(GetValueFromRS(mp_RS.Fields[mp_ColFieldNotEditable]).ToString());
                            }
                            bPersonalStyle = false;

                            if ((r % 2) == 0)
                            {
                                strStyle = StyleRow0;
                            }
                            else
                            {
                                strStyle = StyleRow1;
                            }

                            if (mp_rowCondition.Count > 0)
                            {
                                strStyle = CheckRowCondition(strStyle);
                                bPersonalStyle = true;
                            }

                            if (!string.IsNullOrEmpty(FieldStyle))
                            {
                                strStyle = strStyle + GetValueFromRS(mp_RS.Fields[FieldStyle]);
                            }

                            // '-- apro la riga ed imposto gli eventi per la selezione se necessari
                            objResp.Write("<!--      RIGA " + r + "                      -->" + Environment.NewLine);
                            if (DrawMode == 1)
                            {
                                rn = id + "R" + r;
                                if (!PrintMode)
                                {
                                    objResp.Write($"<tr id=\"{rn}\" class=\"{strStyle}\" ");
                                    if (ActiveSelection > 0)
                                    {
                                        objResp.Write($" onmouseover=\"G_SetRC('{id}', 'GR_OverRow' , {r});\" ");
                                        objResp.Write($" onmouseout=\"G_SetRC( '{id}', '{strStyle}' , {r});\" ");
                                    }

                                    if (ActiveSelection == 2 || ActiveSelection == 3)
                                    {
                                        objResp.Write($" onclick=\"G_ClickRow( '{id}', {r} );\" >" + Environment.NewLine);

                                        objResp.Write($"<td class=\"{strStyle}\" >");
                                        objResp.Write($"<label for=\"{id}_SEL_{CStr(r)}\" class=\"display_none\">Seleziona</label>");
                                        objResp.Write($"<input type=\"checkbox\" name=\"{id}_SEL\"  id=\"{id}_SEL_{CStr(r)}\"/></td>");
                                    }
                                    else
                                    {
                                        strOnClickCel = "";
                                        objResp.Write(" >" + Environment.NewLine);
                                    }
                                }
                                else
                                {
                                    objResp.Write($"<tr class=\"{strStyle}\" >" + Environment.NewLine);
                                }
                            }

                            for (c = 0; c <= mp_numCol; c++)
                            {

                                obj = Columns.ElementAt((int)c).Value;

                                if (DrawMode == 2)
                                {
                                    objResp.Write("<tr>" + Environment.NewLine);
                                }


                                if (!String.IsNullOrEmpty(obj.Name))
                                {
                                    try
                                    {
                                        v = GetValueFromRS(mp_RS.Fields[obj.Name]);
                                        obj.Value = v;
                                    }
                                    catch
                                    {

                                    }
                                }

                                if (UseNameGridOnField == 1)
                                {
                                    obj.SetRow2(id + "_" + r);
                                }
                                else
                                {
                                    obj.SetRow(r);
                                }

                                if (!bPersonalStyle)
                                {
                                    strProp = (r % 2) == 0 ? vPropColR2[c] : vPropColR1[c];
                                }
                                else
                                {
                                    strProp = SetCellProperty(r, obj.Name, strStyle);
                                }

                                strProp = strProp.Replace("<ID_ROW>", r.ToString());

                                if (strProp != "HIDE")
                                {
                                    bDrawed = false;
                                    if (mp_OBJCustomCellDraw != null)
                                    {
                                        bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(this, CInt(0), obj, CLng(r), CLng(c), CStr(strProp), objResp);
                                    }

                                    if (!bDrawed)
                                    {
                                        //'-- apro la cella
                                        objResp.Write("<td " + strProp + ">");

                                        //'-- recupero la proprietà di onClick sulla cella se presente
                                        //'-- e la utilizzo su un ancora per permetterne la raggiungibilità
                                        //'-- da tastiera
                                        strOnClickCel = getCellPropertyOnClick(r, c, obj.Name);


                                        if (!String.IsNullOrEmpty(strOnClickCel) && !PrintMode)
                                        {
                                            objResp.Write("<a  class=\"link_grid\" href=\"#\"");
                                            objResp.Write(strOnClickCel);
                                            objResp.Write(">");
                                        }

                                        //'-- gestione colonne non editabili

                                        bNotEdit = false;
                                        if (Strings.InStr(strColNotEditable, " " + UCase(obj.Name) + " ") > 0)
                                        {
                                            bNotEdit = true;
                                        }

                                        //-- scrivo il valore
                                        if (!Editable || bNotEdit)
                                        {
                                            obj.umValueHtml(objResp, false);
                                            obj.ValueHtml(objResp, false);
                                        }
                                        else
                                        {
                                            obj.umValueHtml(objResp);
                                            obj.ValueHtml(objResp);
                                        }

                                        if (!String.IsNullOrEmpty(strOnClickCel) && !PrintMode)
                                        {
                                            objResp.Write("</a>");
                                        }
                                        //'-- chiudo la cella
                                        objResp.Write("</td>" + Environment.NewLine);
                                    }
                                }
                                else
                                {


                                    //'--se una colonna è nascosta allora disegno un campo nascosto
                                    objResp.Write("<td class=\"display_none\">");

                                    if (UseNameGridOnField == 1)
                                    {
                                        HTML_HiddenField(objResp, "R" + id + "_" + r + "_" + obj.Name, obj.TechnicalValue());
                                    }
                                    else
                                    {
                                        HTML_HiddenField(objResp, "R" + r + "_" + obj.Name, obj.TechnicalValue());
                                    }

                                    objResp.Write("</td>");
                                }

                                if (DrawMode == 2)
                                {
                                    objResp.Write("</tr>" + Environment.NewLine);
                                }
                            }

                            //string pippo3 = objResp.Out();

                            r = r + 1;

                            //-- chiudo la riga
                            if (DrawMode == 1 || mp_RS.EOF)
                            {
                                objResp.Write("</tr>" + Environment.NewLine);
                            }
                            else
                            {
                                objResp.Write("</tr><tr><td>&nbsp;</td></tr>" + Environment.NewLine);
                            }
                            if (objModelPositional != null)
                            {
                                objResp.Write($"<tr><td align=\"center\" colspan=\"{mp_numCol + 2}\">");
                                //'--inizializzo i campi del modello posizionale con il record corrente
                                objModelPositional.SetFieldsValue(mp_RS.Fields);

                                //'--disegno il modello
                                objModelPositional.Html(objResp);
                                objResp.Write("</td></tr>");
                            }

                            mp_RS.MoveNext();
                            rowCounter++;

                            //'-- inserisco los cript per aggiornare il loading su griglie molto grandi
                            if (bDrawLoading && r > PercLoading)
                            {
                                PercLoading = PercLoading + passo;
                                objResp.Write(@"<script>try{" + id + "_loading.innerText='Loading... " + Strings.Format((rowCounter / TotRecord) * 100, "0") + "%';}catch(e){};</script>");
                            }


                            //'-- nel caso la griglia sia paginata verifica che non vengano inserite più righe di quelle richieste
                            if (mp_CurPage > 0)
                            {
                                if (rowCounter >= mp_RowPage)
                                {
                                    break;
                                }
                            }
                        }

                        if (bDrawLoading)
                        {
                            objResp.Write(@"<script type=""text/javascript"">try{" + id + "_loading.innerText='Wait...';}catch(e){};</script>");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message, ex);
            }
        }



        //'-- attualmente la funzione funziona solo con i Recordset è da estendere per le matrici
        //'-- verifica se la riga rispetta una delle condizioni passate, ritorna lo stile associato
        private string CheckRowCondition(string st)
        {
            int c;
            int n;
            int p;
            string[] s;
            string f;
            string v;

            string result = st; //valore di ritorno di default

            n = mp_rowCondition.Count;

            for (c = 0; c < n; c++)
            {

                s = mp_rowCondition[c].ToString().Split("#@#");
                p = InStrVb6(1, s[1], "=");

                if (p > 0)
                {

                    f = Strings.Left(s[1], p - 1);
                    v = Strings.Mid(s[1], p + 1);

                    //Se non troviamo la colonna si esce dalla funzione ( in linea con quanto faceva vb6 che invece andava in errore ma risalendo sul chiamante con on error resume next )
                    if (!mp_RS.ColumnExists(f))
                        return result;

                    if (CStr(GetValueFromRS(mp_RS.Fields[f])) == v)
                    {
                        result = s[0];
                        return result;
                    }
                }

                p = InStrVb6(1, s[1], "<");
                if (p > 0)
                {
                    f = Strings.Left(s[1], p - 1);
                    v = Strings.Mid(s[1], p + 1);

                    //Se non troviamo la colonna si esce dalla funzione ( in linea con quanto faceva vb6 che invece andava in errore ma risalendo sul chiamante con on error resume next )
                    if (!mp_RS.ColumnExists(f))
                        return result;

                    dynamic valRS = GetValueFromRS(mp_RS.Fields[f]);

                    if (valRS is string)
                    {
                        string strValRs = CStr(valRS);

                        if (strValRs.CompareTo(v) < 0)
                        {
                            result = s[0];
                            return result;
                        }
                    }
                }

                p = InStrVb6(1, s[1], ">");
                if (p > 0)
                {
                    f = Strings.Left(s[1], p - 1);
                    v = Strings.Mid(s[1], p + 1);

                    //Se non troviamo la colonna si esce dalla funzione ( in linea con quanto faceva vb6 che invece andava in errore ma risalendo sul chiamante con on error resume next )
                    if (!mp_RS.ColumnExists(f))
                        return result;

                    dynamic valRS = GetValueFromRS(mp_RS.Fields[f]);

                    if (valRS is string)
                    {
                        string strValRs = CStr(valRS);

                        if (strValRs.CompareTo(v) > 0)
                        {
                            result = s[0];
                            return result;
                        }
                    }

                }

            }

            return result;
        }

        private string getCellPropertyOnClick(long row, long col, string colName)
        {
            Grid_ColumnsProperty propCol;
            string strApp;
            string result = string.Empty;

            try
            {
                if (ColumnsProperty.ContainsKey(colName))
                {
                    propCol = ColumnsProperty[colName];
                    if (!String.IsNullOrEmpty(propCol.OnClickCell) && !PrintMode)
                    {
                        result = $" onclick=\"{propCol.OnClickCell}('{id}' , {CStr(row)}, {CStr(col)});return false;\" ";
                    }
                }
                else
                {
                    result = "";
                }

            }
            catch
            {
                result = "";
            }
            return result;
        }

        private string SetCellProperty(long row, string colName, string strStyle)
        {
	        string strApp = string.Empty;

            if (ColumnsProperty.Count == 0) return strApp;

            if (!ColumnsProperty.ContainsKey(colName))
            {
				/* Se non ho delle proprietà per la colonna richiesta, la rappresento con dei default */
				strApp = strApp + @" class=""" + strStyle;

                //bugfix n° 535 e 543 su Seduta Virtuale
				if (Columns.ContainsKey(colName) && !string.IsNullOrEmpty(Columns[colName].Style))
				{
					strApp = strApp + "_" + Columns[colName].Style;
				}

				strApp += @" nowrap"" ";
            }
            else
            {
	            var propCol = ColumnsProperty[colName];
	            if (!string.IsNullOrEmpty(propCol.Alignment))
	            {
		            strApp = strApp + @" align='" + propCol.Alignment + "' ";
	            }

				//bugfix n° 535 e 543 su Seduta Virtuale
				if (Columns.ContainsKey(colName) && !string.IsNullOrEmpty(Columns[colName].Style))
	            {
		            strApp = strApp + @" class=""" + strStyle + "_" + Columns[colName].Style;
	            }
	            else
	            {
		            strApp = strApp + @" class=""" + strStyle;
	            }

	            //'-- aggiunto la classe nowrap
	            if (!propCol.Wrap)
	            {
		            strApp += @" nowrap"" ";
	            }
	            else
	            {
		            strApp += @""" ";
	            }


	            if (propCol.Hide)
	            {
		            strApp = "HIDE";
	            }

			}

            return strApp;
        }

        public void HTML_HiddenField(IEprocResponse objResp, string strFieldName, string strValue)
        {

            objResp.Write($@"<input type=""hidden"" name=""{strFieldName}"" id=""{strFieldName}""");
            objResp.Write($@" value=""{eProcurementNext.HTML.Basic.HtmlEncodeValue(strValue)}"" ");
            objResp.Write("/>" + Environment.NewLine);
            //return objResp.Out();
        }

        public string WriteIdRow()
        {
            EprocResponse objResp = new EprocResponse();
            string strId;
            long r;
            string idrow;
            string n;

            //if (mp_strFieldKey == "" && mp_Matrix.LongLength == 0 || mp_vIdRow == null)  // mp_vIdRow is Missing?
            if (string.IsNullOrEmpty(mp_strFieldKey) && (IsEmpty(mp_Matrix) || IsEmpty(mp_vIdRow)))
            {
                return "";
            }

            //'-- ciclo sulle righe
            if (mp_RS == null)
            {


                for (r = 0; r <= mp_numRow; r++)
                {
                    strId = id + "_idRow_" + r;
                    //objResp.Write($@"<input type=""hidden"" name=""{strId}""  id=""{strId}"" ");

                    objResp.Write($@"<input type=""hidden"" name=""" + strId + @"""  id=""" + strId + @""" ");
                    objResp.Write(@" value=""");
                    try
                    {
                        if (mp_vIdRow.Length > r)
                            objResp.Write(CStr(mp_vIdRow[r]));
                    }
                    catch
                    {

                    }
                    objResp.Write(@""" ");
                    objResp.Write("/>" + Environment.NewLine);
                }

            }
            else
            {
                if (mp_RS.RecordCount > 0)
                {
                    int rowCounter = 0;
                    mp_RS.MoveFirst();
                    r = 0;

                    // se la griglia è paginata

                    if (mp_CurPage > 0)
                    {

                        //mp_RS.AbsolutePosition = (PositionEnum)(mp_RowPage * (mp_CurPage - 1) + 1);
                        mp_RS.AbsolutePosition = (int)(mp_RowPage * (mp_CurPage - 1));
                        mp_RS.position = (int)(mp_RowPage * (mp_CurPage - 1));
                        r = mp_RowPage * (mp_CurPage - 1);
                        rowCounter = 0;
                    }

                    while (!mp_RS.EOF)
                    {
                        strId = id + "_idRow_" + r;
                        objResp.Write($@"<input type=""hidden"" name=""{strId}"" id=""{strId}"" ");
                        if (mp_strFieldKey == null)
                        {
                            idrow = r.ToString();  // verificare se corretto. Da VB6: idrow = r
                        }
                        else
                        {
                            idrow = CStr(GetValueFromRS(mp_RS.Fields[mp_strFieldKey]));
                        }
                        objResp.Write($@" value=""{idrow}"" />");

                        r = r + 1;
                        mp_RS.MoveNext();

                        if (mp_CurPage > 0)
                        {
                            rowCounter = rowCounter + 1;
                            if (rowCounter >= mp_RowPage)
                            {
                                break;
                            }

                        }
                    }
                }
            }

            return objResp.Out();
        }

        public void AddRowCondition(string strRowStyle, string strcondition)
        {

            mp_rowCondition.Add($"{strRowStyle}#@#{strcondition}");

        }

        public void SetCustomDrawer(dynamic? obj)
        {
            mp_OBJCustomCellDraw = obj;
        }

        public void SetPage(long CurPage, long RowForPage)
        {

            mp_CurPage = CurPage;
            mp_RowPage = RowForPage;

        }

        //""-- imposta i parametri
        public void SetSort(string strQueryString, string StrUrl, bool bAll = false, bool bAutoSort = false)
        {

            int numCol;
            int c;
            var comparer = StringComparer.OrdinalIgnoreCase;
            Dictionary<string, string> col = new Dictionary<string, string>(comparer);

            strQueryString = strQueryString.Replace("?&?", "");  // <<----------

            col = GetCollection(strQueryString);
            //col = EprocNext.BizDB.BasicFunction.GetCollection(strQueryString); 


            string test = string.Empty;

            test = tryToGetValueFromDictionary(col, "Sort");

            Sort = test;

            test = tryToGetValueFromDictionary(col, "SortOrder");
            SortOrder = test;
            Sort = tryToGetValueFromDictionary(col, "Sort"); //col["Sort"].ToString();
            SortOrder = tryToGetValueFromDictionary(col, "SortOrder"); //col["SortOrder"].ToString();

            //Sort = col["Sort"].ToString();
            //SortOrder = col["SortOrder"].ToString();

            //URL = $"{StrUrl}?{strQueryString}";
            URL = $"{StrUrl}?{strQueryString}";

            //""-- tolgo dall""url i prametri di sort
            // URL = MyReplace(URL, $"&Sort={col["Sort"]}", "");
            // URL = MyReplace(URL, $"&Sort={Sort}", "");

            string sortToFilter = System.Web.HttpUtility.UrlPathEncode($"&Sort={Sort}");
            string sortOrderToFilter = System.Web.HttpUtility.UrlPathEncode($"&SortOrder={SortOrder}");

            URL = URL.Replace(sortToFilter, "", true, System.Globalization.CultureInfo.CurrentCulture);


            //URL = MyReplace(URL, $"&SortOrder={col["SortOrder"]}", "");
            //URL = MyReplace(URL, $"&SortOrder={SortOrder}", "");

            URL = URL.Replace(sortOrderToFilter, "", true, System.Globalization.CultureInfo.CurrentCulture);

            //""-- se il sort � su tutte le colonne automaticamente imposto il valore
            SortAll = bAll;

            //""-- imposto il valore per l""auto sort della tabella
            AutoSort = bAutoSort;

        }

        public string tryToGetValueFromDictionary(Dictionary<string, string> dict, string key)
        {

            string result = string.Empty;
            if (dict.ContainsKey(key))
            {
                result = dict[key];
                return result;
            }

            if (dict.ContainsKey(key.ToLower()))
            {
                result = dict[key.ToLower()];
                return result;
            }

            if (dict.ContainsKey(key.ToLowerInvariant()))
            {
                result = dict[key.ToLowerInvariant()];
                return result;
            }

            if (dict.ContainsKey(key.ToUpperInvariant()))
            {
                result = dict[key.ToUpperInvariant()];
                return result;
            }

            if (dict.ContainsKey(key.ToUpper()))
            {
                result = dict[key.ToUpper()];
                return result;
            }


            return result;
        }
        public void SortMatrix()
        {
            string strToEval;
            string[] VetKey;
            Field obj;
            int i;
            int c;
            string strVal;

            mp_strIdRowOrder = "";

            if (mp_numRow >= 0)
            {
                VetKey = new string[mp_numRow];
                for (i = 0; i < mp_numRow; i++)
                {
                    obj = new Field();
                    strToEval = Sort.ToLower();
                    for (c = 0; c < mp_numCol; c++)
                    {

                        obj = Columns.ElementAt(c).Value;
                        strVal = mp_RowCol == true ? mp_Matrix[i, c] : mp_Matrix[c, i];

                        strToEval = strToEval.Replace(obj.Name.ToLower(), strVal);
                    }

                    VetKey[i] = strToEval;
                }

                mp_strIdRowOrder = BubbleSortNumber(VetKey);
            }
        }


        private string BubbleSortNumber(string[] iArray)
        {
            string result = string.Empty;
            int lLoop1, lLoop2, nr;
            string lTemp;
            List<dynamic> index = new List<dynamic>();

            nr = iArray.Length;

            for (lLoop1 = 0; lLoop1 <= nr; lLoop1++)
            {
                index[lLoop1] = lLoop1;
            }

            for (lLoop1 = nr - 1; lLoop1 >= nr; lLoop1--)
            {
                for (lLoop2 = 2; lLoop2 <= lLoop1; lLoop2++)
                {
                    int checkString = String.Compare(iArray[lLoop2 - 1], iArray[lLoop2]);
                    if (checkString > 0)
                    //if (String.Compare(iArray[lLoop2 - 1],iArray[lLoop2] )
                    {
                        lTemp = iArray[lLoop2 - 1];
                        iArray[lLoop2 - 1] = iArray[lLoop2];
                        iArray[lLoop2] = lTemp;
                        lTemp = index[lLoop2 - 1];
                        index[lLoop2 - 1] = index[lLoop2];
                        index[lLoop2] = lTemp;
                    }
                }
            }

            if (SortOrder.ToLower() == "desc")
            {
                for (lLoop1 = nr - 1; lLoop1 >= nr; lLoop1--)
                {
                    if (String.IsNullOrEmpty(result))
                    {
                        result = index[lLoop1];
                    }
                    else
                    {
                        result = result + "#" + index[lLoop1];
                    }
                }
            }
            else
            {
                for (lLoop1 = 0; lLoop1 < nr; lLoop1++)
                {
                    if (String.IsNullOrEmpty(result))
                    {
                        result = index[lLoop1];
                    }
                    else
                    {
                        result = result + "#" + index[lLoop1];
                    }
                }
            }

            return result;
        }

        public void RecordSet(TSRecordSet rs, string strFieldKey = "", bool bAutoCol = true)
        {

            mp_strFieldKey = strFieldKey;

            if (bAutoCol)
            {
	            Columns = new Dictionary<string, Field>();

                for (int i = 0; i < rs.Columns.Count; i++)
                {
                    if (rs.Columns[i].ColumnName != strFieldKey)
                    {
	                    Field objFld;

                        int fldType;
                        string strFormat;
                        switch (rs.Columns[i].DataType.Name)
                        {
                            case "Int16":
                            case "Int32":
                            case "Int64":
                            case "UInt16":
                            case "UInt32":
                            case "UInt64":
                            case "SByte":
                            case "USByte":
                                strFormat = "###,###,##0"; // -- con NUMERI INTERI
                                fldType = 2;
                                break;
                            case "Decimal":
                            case "Double":
                            case "Numeric":
                            case "Single":
                                strFormat = "###,###,##0,00##"; // con virgola
                                fldType = 2;
                                break;
                            default:
                                strFormat = "";
                                fldType = 1;
                                break;

                        }

                        objFld = BasicFunction.getNewField(fldType);

						objFld.Init(fldType, rs.Columns[i].ColumnName, oFormat: strFormat);
                        Columns.Add(objFld.Name, objFld);
                    }
                }


            }

            //'-- memorizzo il recordset nella variabile membro
            mp_RS = rs;
            mp_numRow = mp_RS.RecordCount - 1;
        }

        public void ActiveSingleLockRow(bool bActive)
        {
            mp_SingleLock = bActive;
        }

        private void DrawExcelCaption(IEprocResponse objResp)
        {
            Field obj;
            int c = 0;
            string strCaption = string.Empty;
            Grid_ColumnsProperty prop = new Grid_ColumnsProperty();
            bool bHide = false;

            objResp.Write("<tr>" + Environment.NewLine);
            mp_numCol = Columns.Count;

            for (c = 0; c < mp_numCol; c++)
            {
                obj = Columns.ElementAt(c).Value;
                bHide = false;

                try
                {
                    prop = ColumnsProperty[obj.Name];
                    bHide = prop.Hide;
                }
                catch (Exception ex)
                {
                    prop = null;
                }

                if (!bHide)
                {
                    strCaption = obj.Caption;

                    // apro la cella
                    objResp.Write($"<td class=\"nowrap\" ");

                    // -- determino la larghezza delle colonne per troncare alla larghezza desiderata
                    if (prop != null)
                    {
                        if (prop.Length > 0)
                        {
                            if (!IsMasterPageNew() && strCaption.Length > prop.Length)
                            {
                                objResp.Write($" title=\"{strCaption}\" ");
                                strCaption = strCaption.Substring(0, prop.Length - 3) + "...";
                            }
                        }

                        if (!String.IsNullOrEmpty(prop.width))
                        {
                            objResp.Write($" width=\"{prop.width}\" ");
                        }
                        else if (obj.width > 0)
                        {
                            objResp.Write($" width=\"{obj.width}\" ");
                        }
                    }
                    else
                    {
                        if (obj.width > 0)
                        {
                            objResp.Write($" width=\"{obj.width}\" ");
                        }
                    }

                    objResp.Write(">");
                    objResp.Write(strCaption);

                    // -- chiudo la cella
                    objResp.Write("</td>" + Environment.NewLine);

                }
            }

            objResp.Write("</tr>" + Environment.NewLine);
        }

        private void DrawExcelRows(IEprocResponse objResp)
        {
            String strStyle = String.Empty;
            long r, c = 0;
            Grid_ColumnsProperty propCol = new Grid_ColumnsProperty();
            long rowCounter = 0;
            long StartRow = 0;
            string strVal = string.Empty;
            dynamic v;
            string strProp = string.Empty;

            int rowFlush = 0;

            Field obj = new Field();

            mp_numCol = Columns.Count - 1;

            if (mp_RS == null)
            {
                if (IsEmpty(mp_Matrix))
                {
                    mp_numRow = -1;
                }

                // se la griglia è paginata
                if (mp_CurPage > 0) { StartRow = mp_CurPage - mp_RowPage * (mp_CurPage - 1); }

                // ciclo sulle righe della matrice
                for (r = 0; r <= mp_numRow; r++)
                {
                    if ((r % 2) == 0)
                    {
                        strStyle = StyleRow0;
                    }
                    else
                    {
                        strStyle = StyleRow1;
                    }


                    // apro la riga
                    objResp.Write($"<!--      RIGA {r}                      -->");

                    if (DrawMode == 1)
                    {
                        objResp.Write("<tr>" + Environment.NewLine);
                    }

                    for (c = 0; c <= mp_numCol; c++)
                    {
                        if (DrawMode == 2)
                        {
                            objResp.Write("<tr>" + Environment.NewLine);
                        }

                        obj = Columns.ElementAt((int)c + 1 - 1).Value;
                        if (mp_RowCol)
                        {
                            obj.Value = mp_Matrix[r, c];
                        }
                        else
                        {
                            obj.Value = mp_Matrix[c, r];
                        }

                        // identifico il campo sulla riga

                        if (UseNameGridOnField == 1)
                        {
                            obj.SetRow2($"{id}_{r}");
                        }
                        else
                        {
                            obj.SetRow(r);
                        }

                        strProp = SetCellProperty(r, obj.Name, strStyle);
                        strProp = Strings.Replace(strProp, "<ID_ROW>", CStr(r));

                        if (strProp != "HIDE")
                        {
                            // apro la cella
                            objResp.Write("<td>");

                            //'-- scrivo il valore
                            if (!Editable)
                            {
                                obj.umValueHtml(objResp, false);
                                obj.ValueExcel(objResp, false);
                            }
                            else
                            {
                                obj.umValueHtml(objResp);
                                obj.ValueExcel(objResp);
                            }

                            // chiudo la cella
                            objResp.Write("</td>" + Environment.NewLine);
                        }

                        if (DrawMode == 2) { objResp.Write("</tr>" + Environment.NewLine); }
                    }

                    // chiudo la riga
                    if (DrawMode == 1)
                    {
                        objResp.Write("</tr>" + Environment.NewLine);
                    }
                    else
                    {
                        objResp.Write("</tr><tr><td>&nbsp;</td></tr>" + Environment.NewLine);
                    }

                    //-- nel caso la griglia sia paginata verifica che non vengano inserite pi� righe di quelle richieste
                    if (mp_CurPage > 0)
                    {
                        rowCounter = rowCounter + 1;
                        if (rowCounter >= mp_RowPage)
                        {
                            break;
                        }
                    }

                    rowFlush++;
                    if (rowFlush > 500)
                    {
                        rowFlush = 0;
                        // TODO: objResp.Flush
                        // objResp.Flush();
                    }

                }
            }
            else  // altrimenti scorro il recordset
            {
                // '-- ciclo sulle righe della matrice
                r = 0;
                if (mp_RS.RecordCount > 0)
                {
                    mp_RS.MoveFirst();

                    rowCounter = 0;

                    // se la griglia è paginata
                    if (mp_CurPage > 0)
                    {

                        //mp_RS.AbsolutePosition = (PositionEnum)(mp_RowPage * (mp_CurPage - 1) + 1);
                        mp_RS.AbsolutePosition = (int)(mp_RowPage * (mp_CurPage - 1));
                        mp_RS.position = (int)(mp_RowPage * (mp_CurPage - 1));
                        r = mp_RowPage * (mp_CurPage - 1);
                    }

                    while (!mp_RS.EOF)
                    {
                        if (r % 2 == 0)
                        {
                            strStyle = StyleRow0;
                        }
                        else
                        {
                            strStyle = StyleRow1;
                        }

                        // apro la riga

                        objResp.Write($"<!--      RIGA {r}                      -->");
                        if (DrawMode == 1)
                        {
                            objResp.Write("<tr>" + Environment.NewLine);
                        }

                        for (c = 0; c < mp_numCol; c++)
                        {
                            obj = Columns.ElementAt((int)c + 1 - 1).Value;

                            if (DrawMode == 2)
                            {
                                objResp.Write("<tr>" + Environment.NewLine);
                            }

                            // -- verifico se la colonna è presente nel recordset
                            if (mp_RS.ColumnExists(obj.Name))
                            {
                                v = GetValueFromRS(mp_RS.Fields[obj.Name]);
                                obj.Value = v;
                            }

                            //'-- identifico il campo sulla riga
                            if (UseNameGridOnField == 1)
                            {
                                obj.SetRow2(id + "_" + r);
                            }
                            else
                            {
                                obj.SetRow(r);
                            }

                            strProp = SetCellProperty(r, obj.Name, strStyle);
                            strProp = strProp.Replace("<ID_ROW>", r.ToString());

                            if (strProp != "HIDE")
                            {
                                // -- apro la cella
                                objResp.Write("<td>");

                                // -- scrivo il valore

                                if (!Editable)
                                {
                                    obj.umValueHtml(objResp, false);
                                    obj.ValueExcel(objResp, false);
                                }
                                else
                                {
                                    obj.umValueHtml(objResp);
                                    obj.ValueExcel(objResp);
                                }

                                // -- chiudo la cella 
                                objResp.Write("</td>" + Environment.NewLine);

                            }

                            // -- chiudo la riga
                            if (DrawMode == 2)
                            {
                                objResp.Write("</tr>");
                            }
                        }

                        r++;
                        mp_RS.MoveNext();

                        // -- chiudo la riga

                        if (DrawMode == 1 || mp_RS.EOF)
                        {
                            objResp.Write("</tr>" + Environment.NewLine);
                        }
                        else
                        {
                            objResp.Write("</tr><tr><td>&nbsp;</td></tr>" + Environment.NewLine);
                        }

                        // '-- nel caso la griglia sia paginata verifica che non vengano inserite pi� righe di quelle richieste
                        if (mp_CurPage > 0)
                        {
                            rowCounter++;
                            if (rowCounter >= mp_RowPage)
                            {
                                break;
                            }
                        }

                        rowFlush++;

                        if (rowFlush > 500)
                        {
                            rowFlush = 0;
                            // TODO:  gestire il flush
                            // objResp.Flush;
                        }
                    }
                }
            }
        }

        /// <summary>
        /// disegna i campi delle colonne nascoste della griglia
        /// </summary>
        /// <param name="objResp"></param>
        private void DrawRowsHidden(IEprocResponse objResp)
        {
            String strStyle = string.Empty;
            long r = 0;
            long c = 0;
            String n = string.Empty;
            Grid_ColumnsProperty propCol = new Grid_ColumnsProperty();
            long rowCounter = 0;
            long StartRow = 0;
            string strVal = string.Empty;
            //On Error Resume Next
            dynamic v;
            Boolean bDrawed = false;
            String strProp = string.Empty;
            bool bDrawLoading = false;
            Double passo = 0f;
            Double PercLoading = 0f;
            long TotRecord = 0;
            String rn = string.Empty;
            dynamic[] vPropColR1;
            dynamic[] vPropColR2;
            Field obj = new Field();
            bool bPersonalStyle = false;
            dynamic[] aOrderRow;
            long nIndRow = 0;

            mp_numCol = Columns.Count - 1;

            vPropColR1 = new dynamic[mp_numCol + 1];
            vPropColR2 = new dynamic[mp_numCol + 1];

            aOrderRow = new dynamic[] { };
            try
            {
                for (c = 0; c <= mp_numCol; c++)
                {
                    obj = obj = Columns.ElementAt((int)c).Value;
                    vPropColR1[c] = SetCellProperty(r, obj.Name, StyleRow1);
                    vPropColR2[c] = SetCellProperty(r, obj.Name, StyleRow0);
                }

                bDrawLoading = false;

                // '-- determina se è necessario inserire lo script di aggiornamento % per loading

                if (DrawMode == 1 && !PrintMode && mp_Locked)
                {
                    bDrawLoading = true;
                    if (mp_RS != null)
                    {
                        if (mp_CurPage > 0)
                        {
                            TotRecord = mp_RowPage;
                        }
                        else
                        {
                            TotRecord = mp_numRow;
                        }

                        passo = TotRecord / 10;
                    }
                    else
                    {
                        if (mp_CurPage > 0)
                        {
                            TotRecord = mp_RowPage;
                        }
                        else
                        {
                            TotRecord = mp_RS.RecordCount;
                        }

                        passo = TotRecord / 10;
                    }

                    if (mp_RS != null)
                    {
                        if (mp_Matrix.Length > 0)
                        {
                            mp_numRow = -1;
                        }

                        StartRow = 0;
                        rowCounter = 0;

                        // '-- se la griglia � paginata

                        if (mp_CurPage > 0) { StartRow = mp_RowPage * (mp_CurPage - 1); }

                        if (!String.IsNullOrEmpty(mp_strIdRowOrder))
                        {
                            aOrderRow = mp_strIdRowOrder.Split('#');
                        }

                        for (r = StartRow; r <= mp_numRow; r++)
                        {
                            nIndRow = r;
                            //'--se � stato fatto un ordinamento stampo secondo l'ordine richiesto
                            if (!String.IsNullOrEmpty(mp_strIdRowOrder))
                            {
                                nIndRow = aOrderRow[r];
                            }

                            bPersonalStyle = false;

                            if ((r % 2) == 0)
                            {
                                strStyle = StyleRow0;
                            }
                            else
                            {
                                strStyle = StyleRow1;
                            }

                            for (c = 0; c <= mp_numCol; c++)
                            {
                                obj = Columns.ElementAt((int)c).Value;
                                if (mp_RowCol)
                                {
                                    obj.Value = mp_Matrix[nIndRow, c];
                                }
                                else
                                {
                                    obj.Value = mp_Matrix[c, nIndRow];
                                }

                                // -- identifico il campo sulla riga
                                if (UseNameGridOnField == 1)
                                {
                                    obj.SetRow2($"{id}_{nIndRow}");
                                }
                                else
                                {
                                    obj.SetRow(nIndRow);
                                }

                                if (!bPersonalStyle)
                                {
                                    strProp = (r % 2) == 0 ? vPropColR2[c] : vPropColR1[c];
                                }
                                else
                                {
                                    strProp = SetCellProperty(nIndRow, obj.Name, strStyle);
                                }

                                if (strProp == "HIDE")
                                {
                                    HTML_HiddenField(objResp, "R" + nIndRow + "_" + obj.Name, obj.TechnicalValue());
                                }
                            }

                            //'-- nel caso la griglia sia paginata verifica che non vengano inserite pi� righe di quelle richieste
                            if (mp_CurPage > 0)
                            {
                                rowCounter = rowCounter + 1;
                                if (rowCounter >= mp_RowPage)
                                {
                                    break;
                                }
                            }
                        }
                    }
                    else // '-- altrimenti scorro il recordset
                    {
                        // '-- ciclo sulle righe della matrice
                        r = 0;
                        if (mp_RS.RecordCount > 0)
                        {
                            mp_RS.MoveFirst();

                            rowCounter = 0;

                            // '-- se la griglia � paginata
                            if (mp_CurPage > 0)
                            {
                                //mp_RS.AbsolutePosition = (PositionEnum)(mp_RowPage * (mp_CurPage - 1) + 1);
                                mp_RS.AbsolutePosition = (int)(mp_RowPage * (mp_CurPage - 1));
                                mp_RS.position = (int)(mp_RowPage * (mp_CurPage - 1));
                                r = mp_RowPage * (mp_CurPage - 1);
                            }

                            while (!mp_RS.EOF)
                            {
                                //'-- determina lo stile da applicare ala riga
                                bPersonalStyle = false;
                                if ((r % 2) == 0)
                                {
                                    strStyle = StyleRow0;
                                }
                                else
                                {
                                    strStyle = StyleRow1;
                                }

                                if (mp_rowCondition.Count > 0)
                                {
                                    strStyle = CheckRowCondition(strStyle);
                                    bPersonalStyle = true;
                                }

                                if (!String.IsNullOrEmpty(FieldStyle))
                                {
                                    strStyle = GetValueFromRS(mp_RS.Fields[FieldStyle]);
                                }

                                for (c = 0; c <= mp_numCol; c++)
                                {
                                    obj = Columns.ElementAt((int)c).Value;

                                    // '-- verifico se la colonna � presente nel recordset
                                    try
                                    {
                                        v = GetValueFromRS(mp_RS.Fields[obj.Name]);
                                        obj.Value = v;
                                    }
                                    catch (Exception ex)
                                    {
                                        // gestione errore? 
                                    }

                                    //'-- identifico il campo sulla riga
                                    if (UseNameGridOnField == 1)
                                    {
                                        obj.SetRow2($"{id}_{r}");
                                    }
                                    else
                                    {
                                        obj.SetRow(r);
                                    }

                                    if (!bPersonalStyle)
                                    {
                                        strProp = (r % 2) == 0 ? vPropColR2[c] : vPropColR1[c];
                                    }
                                    else
                                    {
                                        strProp = SetCellProperty(r, obj.Name, strStyle);
                                    }

                                    if (strProp == "HIDE")
                                    {
                                        HTML_HiddenField(objResp, "R" + r + "_" + obj.Name, obj.TechnicalValue());
                                    }
                                }

                                r = r++;
                                //'-- nel caso la griglia sia paginata verifica che non vengano inserite pi� righe di quelle richieste
                                if (mp_CurPage > 0)
                                {
                                    if (rowCounter > mp_RowPage)
                                    {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // valutare errore
            }
        }

        public void Excel(IEprocResponse objResp)
        {
            // '-- div che racchiude la tabella
            objResp.Write($"<div id=\"div_{id}\">" + Environment.NewLine);

            // '-- controlla la presenza della griglia
            if (Columns == null)
            {
                objResp.Write("La griglia non è stata avvalorata ");
                objResp.Write(Caption);
                objResp.Write("</div>" + Environment.NewLine);
                return;
            }

            //'-- metto il titolo alla tabella nel caso sia presente

            if (!String.IsNullOrEmpty(Caption))
            {
                objResp.Write("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" >" + Environment.NewLine);
                objResp.Write("<tr><td>");
                objResp.Write(Caption + "</tr></td><tr><td>" + Environment.NewLine);
            }

            //'-- apertura della tabella HTML
            String strWitdhTest = String.IsNullOrEmpty(width) ? string.Empty : width;
            objResp.Write($"<table  {strWitdhTest} cellspacing=\"0\" cellpadding=\"0\" ");
            objResp.Write($" numrow=\"{mp_numRow}\">" + Environment.NewLine);

            //'-- disegna le caption
            if (DrawMode == 1)
            {
                DrawExcelCaption(objResp);
            }

            // -- disegno le righe
            DrawExcelRows(objResp);

            // -- disegno la riga di totale
            if (mp_ShowTotal)
            {
                DrawExcelTotal(objResp);
            }

            objResp.Write("</table>");

            // -- chiudo la tabella aper per il titolo 
            if (!string.IsNullOrEmpty(Caption))
            {
                objResp.Write("</td></tr></table>");
            }

            objResp.Write("</div>" + Environment.NewLine);
        }

        private void DrawExcelTotal(IEprocResponse objResp)
        {
            Field obj = new Field();
            int c = 0;
            string strCaption = string.Empty;
            Grid_ColumnsProperty prop = new Grid_ColumnsProperty();
            // dim error resume next
            double[] vetTotal = new double[] { };
            bool st = false;

            // -- paro la riga
            objResp.Write("<tr>" + Environment.NewLine);

            mp_numCol = Columns.Count;

            //-- calcola i totali
            if (mp_RS.RecordCount > 0)
            {
                mp_RS.MoveFirst();
                while (!mp_RS.EOF)
                {
                    for (c = 0; c <= mp_numCol; c++)
                    {
                        obj = Columns.ElementAt(c).Value;
                        st = false;
                        try
                        {
                            st = ColumnsProperty[obj.Value.Name].Total;
                            if (st)
                            {
                                vetTotal[c] = vetTotal[c] + GetValueFromRS(mp_RS.Fields[obj.Name]);
                            }
                        }
                        catch (Exception ex)
                        {

                        }
                        mp_RS.MoveNext();
                    }
                }
            }

            //'-- verifico se nella colspan del totale ci sono colonne nascoste

            int cSpan = 0;
            for (c = 1; c < mp_numCol; c++)
            {
                obj = Columns.ElementAt(c).Value;
                st = false;
                try
                {
                    st = ColumnsProperty[obj.Value.Name].Total;
                    if (!st)
                    {
                        cSpan = cSpan++;
                    }
                }
                catch (Exception ex) { }

            }

            // '-- disegna la caption dei totali

            if (cSpan > 0)
            {
                objResp.Write("<td class=\"nowrap\" ");
                objResp.Write($" colspan=\"{cSpan}\" >");
                objResp.Write(mp_TotalTitle);
                objResp.Write("</td>");
            }

            // -- DISEGNA I TOTALI

            for (c = mp_ColSpanTotal; c <= mp_numCol; c++)
            {
                obj = Columns.ElementAt(c).Value;
                st = false;
                try
                {

                    st = ColumnsProperty[obj.Value.Name].Hide;
                    if (!st)
                    {
                        // -- apro la cella
                        objResp.Write($"<td class=\"nowrap\" >");

                        st = false;
                        try
                        {
                            st = ColumnsProperty[obj.Value.Name].Total;
                            if (st)
                            {
                                // -- scrive il valore
                                obj.Value = vetTotal[c];
                                obj.ValueExcel(objResp, false);
                            }
                            else
                            {
                                objResp.Write("&nbsp;");
                            }

                            // -- chiudo la cella

                            objResp.Write("</td>" + Environment.NewLine);
                        }
                        catch (Exception ex) { }
                    }

                }
                catch (Exception ex) { }
            }

            objResp.Write("</tr>" + Environment.NewLine);
        }

        public long getNumRow()
        {
            return mp_numRow;
        }

        public void RecordSetWeb(TSRecordSet rs, string strFieldKey, bool bAutocCol)
        {
            RecordSet(rs, strFieldKey, bAutocCol);
        }

        public void ReloadUnfilteredDomain()
        {
            eProcurementNext.HTML.BasicFunction.ReloadUnfilteredDomain(Columns, Editable);
        }

        public void SetMatrixDisposition(bool RowCol)
        {
            mp_RowCol = RowCol;
        }

        public void xml(IEprocResponse objResp, string testata)
        {
            Field obj = new Field();
            mp_numCol = Columns.Count - 1;
            long r = 0;
            long c = 0;

            if (mp_Matrix != null && mp_Matrix.Length > 0)
            {
                objResp.Write($"<{UCase(testata)}>" + Environment.NewLine);
                objResp.Write("<ROWS>" + Environment.NewLine);

                // ciclo sulle righe della matrice

                for (r = 0; r <= mp_numRow; r++)
                {
                    objResp.Write($"<ROW index=\"{r + 1}\">" + Environment.NewLine);
                    for (c = 0; c <= mp_numCol; c++)
                    {
                        obj = Columns.ElementAt((int)c + 1 - 1).Value;
                        obj.Value = mp_Matrix[c, r];
                        obj.xml(objResp, "");
                    }
                    objResp.Write("</ROW>" + Environment.NewLine);
                }
                objResp.Write("</ROWS>" + Environment.NewLine);
                objResp.Write($"</{UCase(testata)}>" + Environment.NewLine);
            }
            else
            {
                string v = string.Empty;
                bool errore = false;
                r = 0;

                objResp.Write($"<{UCase(testata)}>" + Environment.NewLine);

                objResp.Write("<ROWS>" + Environment.NewLine);

                if (mp_RS != null)
                {
                    if (mp_RS.RecordCount > 0 && !mp_RS.EOF)
                    {
                        try
                        {
                            mp_RS.MoveNext();
                            while (!mp_RS.EOF)
                            {
                                objResp.Write($"<ROW index=\"{r + 1}\">" + Environment.NewLine);
                                for (c = 0; c <= mp_numCol; c++)
                                {
                                    obj = Columns.ElementAt((int)c).Value;
                                    if (GetValueFromRS(mp_RS.Fields[obj.Name]) != null)
                                    {
                                        try
                                        {
                                            errore = false;
                                            v = GetValueFromRS(mp_RS.Fields[obj.Name]);
                                            if (!string.IsNullOrEmpty(v))
                                            {
                                                obj.Value = v;
                                            }
                                            else
                                            {
                                                errore = true;

                                            }
                                        }
                                        catch (Exception ex)
                                        {
                                            // gestire errore?
                                        }
                                    }
                                    else
                                    {
                                        v = "";
                                    }

                                    if (!errore)
                                    {
                                        obj.xml(objResp, "");
                                    }
                                }
                                objResp.Write("</ROW>" + Environment.NewLine);
                                r++;
                                mp_RS.MoveNext();
                            }
                        }
                        catch (Exception ex)
                        {

                        }
                    }
                }

                objResp.Write("</ROWS>" + Environment.NewLine);
                objResp.Write($"</{UCase(testata)}>" + Environment.NewLine);

            }
        }
    }
}
