using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Calendar
    {
        public string AnnoMese = string.Empty;
        public string FieldData = string.Empty;
        public string FieldStyle = string.Empty;
        public int MesiShow = 0;

        private dynamic mp_session;
        private long r, c = 0;



        public new string Caption = string.Empty; // titolo della griglia
        public string Style = string.Empty; // classe associata alla Griglia
        public string StyleCaption = string.Empty; // classe associata alla riga di testa delle colonne
        public string StyleRow0 = string.Empty; // classe associata alla riga par dispari
        public string StyleRow1 = string.Empty;

        public string id = string.Empty; // identificativo della griglia

        public Dictionary<string, Field> Columns = new Dictionary<string, Field>();
        public Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

        public string width = string.Empty;
        public string Height = string.Empty;

        public bool Editable = false; // indica se la griglia è editabile per default non lo è
        public int DrawMode = 0; // Indica la modalità di disegno della griglia 1 = griglia, 2 = schede

        private dynamic mp_Matrix; // matrice dei valori contenuti nella
                                   // deve essere in stretta relazione con le colonne
                                   // si condiera zero based (riga, colonna)

        private dynamic mp_vIdRow; // contiene un array con gli identificativi di riga se avvalorato
        private long mp_numRow = 0;
        private int mp_numCol = 0;

        private TSRecordSet mp_RS; // recordset associato alla griglia in alternativa alla matrice
        private TSRecordSet mp_RSFestivity; // recordset associato alla griglia in alternativa alla matrice
        private string mp_strFieldKey = string.Empty; // nel caso ci sia il recordset contiene il campo che fa da chiave per i record

        // usatre per paginare la griglia
        private long mp_CurPage = 0; // se avvalorato indica la pagina corrente a partie da 1
        private long mp_RowPage = 0; // indica il numero di righe da visualizzare in una pagina

        private string mp_TotalTitle = string.Empty; //  '--stringa per la descrizione del totale della griglia
        private int mp_ColSpanTotal = 0; // '-- numero colonne su cui esprimere il totale
        private bool mp_ShowTotal = default;
        //private string mp_ShowTotal = String.Empty;
        private List<string> mp_rowCondition = new List<string>();

        public string URL = string.Empty; // '-- indirizzo da chiamare quando si richiede il sort di una colonna
        public string Sort = string.Empty; // '-- nome della colonna su cui mettere la bitmap del sort
                                           //'-- E' A CURA DELL'APPLICAZIONE FARE IL SORT DEL RECORDSET O DELLA MATRICE
        public string SortOrder = string.Empty; // '-- Verso su cui � espresso il sort
        private bool AutoSort = false;
        private bool SortAll = false;

        public bool PrintMode = false; //'-- indica che la griglia � visualizzata per una stampa quindi non vanno messi
                                       //'-- i meccanismi di eventi come onclick

        //'-- variabili per il lock della tabella
        private bool mp_Locked = false;
        private int mp_RowLocked = 0; //'-- quante righe devono essere fisse sullo schermo
        private int mp_ColLocked = 0; //'-- quante colonne devono essere fisse sullo schermo


        //'-- oggetto per personalizzare la visualizzazione delle celle
        private dynamic mp_OBJCustomCellDraw;

        private bool mp_RowCol = false; //'-- indica se la matrice � ricga colonna o colonna riga
        private bool mp_SingleLock = false; //'-- attiva il lock della riga di testata
        public int ActiveSelection = 0; //'-- 0 selezione disattiva , 1 singola 2 multipla,3 multipla ma con selezione
                                        //'-- attivata solo su click della prima colonna

        private string mp_strIdRowOrder = string.Empty; // '-- contiene gli indici delle righe ordinato secondo il criterio richiesto
                                                        // '-- gli indici delle righe sono separate da # esempio : "1#3#2"

        public bool ShowSintetic = false; // '-- se true indica la visualizzazione in forma ridotta
        public string OnClickDay = string.Empty;



        public dynamic objModelPositional; //  '--se presente � l'oggetto del modello posizionale per disegnare righe della griglia


        public int UseNameGridOnField = 0; // '-- nel differenziare i campi della griglia usa anche il nome oltre alla riga

        public string mp_accessible = string.Empty;

        public string mp_ColFieldNotEditable = string.Empty; // '-- nome della colonna nel RS che contiene i nomi dei campi non editabili

        public bool mp_Show_NumRow = false; // '-- si/no si visualizza numero righe altrimenti no
        public string mp_str_Label_NumRow = string.Empty; // '--stringa da anteporre a numero righe se da visualizzare
        private string[] giorniSettimana = new string[] { "Lunedi", "Martedi", "Mercoledi", "Giovedi", "Venerdi", "Sabato", "Domenica" };
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            try
            {
                int numCol = 0;
                int c = 0;

                JS.Add($"checkbrowser", $"<script src='{Path}jscript/checkbrowser.js' ></script>");
                JS.Add($"getObj", $"<script src='{Path}jscript/getObj.js' ></script>");
                JS.Add("ExecFunction", $"<script src='{Path}jscript/ExecFunction.js' ></script>");
                JS.Add("setClassName", $"<script src='{Path}jscript/setClassName.js' ></script>");
                JS.Add("GetIdRow", $"<script src='{Path}jscript/grid/GetIdRow.js' ></script>");
                JS.Add("grid", $"<script src='{Path}jscript/grid/grid.js' ></script>");
                JS.Add("GetPosition", $"<script src='{Path}jscript/GetPosition.js' ></script>");
                JS.Add("lockedGrid", $"<script src='{Path}jscript/grid/lockedGrid.js' ></script>");
                JS.Add("GetCheckedRows", $"<script src='{Path}jscript/grid/GetCheckedRows.js' ></script>");

                numCol = Columns.Count - 1;

                foreach (KeyValuePair<string, Field> col in Columns)
                {
                    col.Value.JScript(JS, Path);
                }
            }
            catch
            {

            }
        }

        public Calendar()
        {
            Style = "Calendar";
            StyleCaption = "_RowCaption";
            StyleRow0 = "GR0";
            StyleRow1 = "GR1";
            //mp_Matrix = Empty;
            //mp_vIdRow = Empty
            width = "100%";

            //Editable = False
            DrawMode = 1;
            //mp_ShowTotal = False
            mp_TotalTitle = "";
            mp_ColSpanTotal = 1;
            mp_RowCol = true;


            mp_accessible = "";
            mp_ColFieldNotEditable = "";


            mp_Show_NumRow = false;
            mp_str_Label_NumRow = "Numero Righe";
        }

        //public void SetMatrix(dynamic[] m, dynamic? vIdRow)
        //{

        //    mp_Matrix = m;

        //    if (m.Length > 0)
        //    {
        //        if (mp_RowCol)
        //        {
        //            mp_numRow = mp_Matrix.GetUpperBound(0, 1);
        //            mp_numCol = mp_Matrix.GetUpperBound(0, 2);
        //        }
        //        else
        //        {
        //            mp_numCol = mp_Matrix.GetUpperBound(0, 1);
        //            mp_numRow = mp_Matrix.GetUpperBound(0, 2);
        //        }


        //        mp_vIdRow = vIdRow;
        //    }
        //    else
        //    {
        //        mp_numRow = -1;
        //    }
        //}

        public string Html(IEprocResponse objResp)
        {
            long EndRow = 0;
            long StartRow = 0;

            if (mp_RS != null && mp_RS.RecordCount > 0)
            {
                if (!String.IsNullOrEmpty(FieldData))
                {
                    mp_RS.Sort(FieldData + " asc");
                }
            }

            if (mp_RSFestivity != null)
            {
                mp_RSFestivity.Sort("Data asc");
            }

            // div che racchiude la tabella

            objResp.Write($"<div id='div_{id}' ");
            objResp.Write($"class='height_100_percent'");

            objResp.Write($" width='{width}' ");


            objResp.Write(">" + Environment.NewLine);

            //   '-- controlla la presenza della griglia

            if (Columns == null)
            {
                objResp.Write("Il calendario non è stato avvalorato ");
                objResp.Write(Caption);
                objResp.Write("</div>" + Environment.NewLine);
                return objResp.Out(); ;
            }

            //'-- aggiunge le variabili per la selezione
            objResp.Write(@"<script type=""text/javascript"" > " + Environment.NewLine);
            objResp.Write($"var {id}_StyleRow = new Array({mp_numRow + 1} );" + Environment.NewLine);
            objResp.Write($"var {id}_SelectedRow = new Array( {mp_numRow + 1});" + Environment.NewLine);
            objResp.Write($"var {id}_NumRow = {mp_numRow};" + Environment.NewLine);


            objResp.Write($"var {id}_StyleRow0 = '{StyleRow0}' ;" + Environment.NewLine);
            objResp.Write($"var {id}_StyleRow1 = '{StyleRow1}' ;" + Environment.NewLine);
            objResp.Write($"var {id}_ActiveSelection = '{ActiveSelection}' ;" + Environment.NewLine);
            objResp.Write("</script> ");

            //'-- metto il titolo alla tabella nel caso sia presente
            if (!String.IsNullOrEmpty(Caption))
            {
                objResp.Write($"<table class='{Style}_Title'  id='{id}_Caption' cellspacing='0' cellpadding='0'>" + Environment.NewLine);
                objResp.Write($"<tr><td class='{Style}_TitleCell' >");
                objResp.Write(Caption + "</td></tr><tr><td>" + Environment.NewLine);
            }

            //'-- se ho chiesto il lock predispongo le div per il disegno e poi il contenuto
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

            return objResp.Out();
        }


        private void DrawLockedGridHtml(IEprocResponse objResp)  // verificare objResponse
        {
            //'-- disegno la div per la posizione sullo schermo
            objResp.Write(@"<div id=""" + id + @"_ShowedDiv"" width=""100%"" ");
            objResp.Write(@"class=""height_100_percent"">");
            objResp.Write(@"<table border=""0"" id=""" + id + @"_Showed"" width=""100%"" ");
            objResp.Write(@"height=""100%"" ");

            objResp.Write(@"onresize=""javascript: try { ResizeGrid( '" + id + @"' ); }   catch(  e ){  ; };"" >");
            objResp.Write("<tr>");
            objResp.Write(@"<td width=""100%"" height=""100%"" valign=""middle"" align=""center"" >");

            objResp.Write("</td>");
            objResp.Write("</tr>");
            objResp.Write("</table>");
            objResp.Write("</div>");
        }

        private void DrawLockedHtml(IEprocResponse objResp)
        {
            //'-- disegno la div con il contenuto
            objResp.Write(@"<div id=""" + id + @"_Content"" ");
            objResp.Write(@"class=""calendar_div_content""");
            objResp.Write(@" onscroll=""javascript:ScrollLockedInfo( '" + id + @"' );"" > ");


            DrawGridHtml(objResp);
            objResp.Write("</div>");

            //'-- disegno la div per le righe fisse
            objResp.Write(@"<div id=""" + id + @"_LockedRow"" ");
            objResp.Write(@" class=""calendar_div_content_overflowhidden"">");
            objResp.Write("</div>");

            //'-- disegno la div per le colonne fisse
            objResp.Write(@"<div id=""" + id + @"_LockedCol"" ");
            objResp.Write(@" class=""calendar_div_content_overflowhidden"">");
            objResp.Write("</div>");

            //'-- disegno la div per l'angolo fisso se necessario
            objResp.Write(@"<div id=""" + id + @"_LockedCorner""");
            objResp.Write(@" class=""calendar_div_content_overflowhidden"">");

            objResp.Write("</div>");

            //'-- js per disegnare e posizionare la prima volta la griglia
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
            string strWithd = !String.IsNullOrEmpty(width) || mp_Locked ? @" width=""" + width + @""" " : "";
            objResp.Write(@"<table class=""" + Style + @"""  id=""" + id + @""" name=""" + id + @""" " + strWithd + @" cellspacing=""0"" cellpadding=""0"" ");
            objResp.Write(@" numrow=""" + mp_numRow + @""" >" + Environment.NewLine);


            //'-- determina il giorno della settimana del primo del mese
            DateTime d;
            int w, i = default;
            DateTime StartDate;
            int MyWeekDay = default;

            int Anno = DateTime.Now.Year;
            string mese = DateTime.Now.Month.ToString("d2");  // mese nel formato a 2 cifre

            if (String.IsNullOrEmpty(AnnoMese))
            {
                AnnoMese = Anno + "/" + mese;
            }

            int myMese = Convert.ToInt32(AnnoMese.Substring(5, 2));  // nel caso AnnoMese sia già valorizzato

            string capMese = strMese(myMese);
            capMese = char.ToUpper(capMese[0]) + capMese.Substring(1);
            string cnvMese = Application.ApplicationCommon.CNV(capMese);

            objResp.Write(@"<tr><td id=""" + id + @"_CAL_CAPTION"" name=""" + id + @"_CAL_CAPTION"" colspan=""7"" class=""CAPTION_" + Style + @" nowrap"" width=""100%"" ");


            objResp.Write(">");


            if (ShowSintetic)
            {
                objResp.Write(cnvMese.Substring(0, 3) + " " + AnnoMese.Substring(0, 4));
            }
            else
            {
                objResp.Write(cnvMese + " " + AnnoMese.Substring(0, 4));
            }
            objResp.Write("</td></tr>" + Environment.NewLine);


            DrawCaption(objResp);

            int meseOrig, AnnoOrig = default;

            //mese = CInt(Mid(AnnoMese, 6, 2))
            meseOrig = myMese;
            //If MesiShow<> 1 Then
            //    mese = mese - MesiShow + 1
            //End If

            if (MesiShow != 1)
            {
                myMese = myMese - MesiShow;
            }

            Anno = Convert.ToInt16(AnnoMese.Substring(0, 4));  //CInt(Left(AnnoMese, 4))
            AnnoOrig = Anno;


            //If mese< 1 Then
            //    mese = mese + 12
            //    Anno = Anno - 1
            //End If

            if (myMese < 1)
            {
                myMese = myMese + 12;
                Anno = Anno - 1;
            }

            d = new DateTime(Anno, myMese, 1);
            string strData = d.ToString("dd/MM/yyyy");

            MyWeekDay = (int)d.DayOfWeek; // Weekday(d) - 1
            //If MyWeekDay = 0 Then MyWeekDay = 7
            if (MyWeekDay == 0)
            {
                MyWeekDay = 7;
            }


            //StartDate = DateAdd("d", -MyWeekDay + 1, d)
            StartDate = d.AddDays(-MyWeekDay + 1);

            string[] vetStyle = new string[7];

            // vetStyle(7) As String
            vetStyle[0] = "DAY_CELL_";
            vetStyle[1] = "DAY_CELL_";
            vetStyle[2] = "DAY_CELL_";
            vetStyle[3] = "DAY_CELL_";
            vetStyle[4] = "DAY_CELL_";
            vetStyle[5] = "SATURDAY_CELL_";
            vetStyle[6] = "SUNDAY_CELL_";


            //'-- disegna tante righe per quante settimane entrano nel mese
            long cmax = default;
            string CellStyle = string.Empty;
            string CapCellStyle = string.Empty;
            string strCapText = string.Empty;
            string strCapTextTip = string.Empty;
            string strOnClickDay = string.Empty;

            cmax = 0;

            //Loop While Anno * 12 + mese < AnnoOrig * 12 + meseOrig + MesiShow   'CInt(Mid(AnnoMese, 6, 2)) And cmax < 10000

            //Do

            do
            {
                objResp.Write("<tr>");


                for (i = 0; i < 7; i++)
                {


                    CellStyle = vetStyle[i];

                    if (StartDate.Month != meseOrig)
                    {
                        CellStyle = $"OUT_{CellStyle}";
                    }

                    if (StartDate.ToString("yyyy-MM-dd") == DateTime.Now.ToString("yyyy-MM-dd"))
                    {
                        CellStyle = "TODAY_" + CellStyle;
                    }

                    strOnClickDay = OnClickDay + "( '" + StartDate.ToString("yyyy-MM-dd") + "' );";
                    strCapText = StartDate.Day.ToString();

                    if (StartDate.Month != StartDate.AddDays(-1).Month || StartDate.Month != StartDate.AddDays(1).Month)
                    {
                        strCapText += " - " + Application.ApplicationCommon.CNV(strMese(StartDate.Month), mp_session);
                    }
                    if (mp_RSFestivity != null)
                    {
                        CapCellStyle = StyleFestivo(StartDate, ref strCapText);
                    }

                    strCapTextTip = "";

                    if (ShowSintetic && strCapText.Length > 2)
                    {
                        strCapTextTip = strCapText;
                        strCapText = StartDate.Day.ToString();
                    }
                    else
                    {
                        if (strCapText.Length > 18)
                        {
                            strCapTextTip = strCapText;
                            strCapText = strCapText.Substring(0, 18) + "...";
                        }
                    }


                    if (ShowSintetic)
                    {
                        if (Occupato(StartDate))
                        {
                            //'-- caption della cella
                            objResp.Write(@"<td class=""" + CellStyle + Style + @"Used"" onclick=""" + strOnClickDay + @""" ");
                            objResp.Write(@" style=""" + CapCellStyle + @""" title=""" + HtmlEncode(strCapTextTip) + @""" >");
                        }
                        else
                        {
                            //'-- caption della cella
                            objResp.Write(@"<td class=""" + CellStyle + Style + @""" onclick=""" + strOnClickDay + @""" ");
                            objResp.Write(@" style=""" + CapCellStyle + @""" title=""" + HtmlEncode(strCapTextTip) + @""" >");
                        }
                        objResp.Write(HtmlEncode(strCapText));
                        objResp.Write("</td>");
                    }
                    else
                    {
                        if (!String.IsNullOrEmpty(OnClickDay))
                        {
                            objResp.Write(@"<td class=""" + CellStyle + Style + @""" onclick=""" + strOnClickDay + @""" >");
                        }
                        else
                        {
                            objResp.Write(@"<td class=""" + CellStyle + Style + @""">");
                        }


                        objResp.Write("<table ");


                        objResp.Write(@"width=""100%"" cellspacing=""0"" cellpadding=""0"" >" + Environment.NewLine);


                        //           '-- caption della cella
                        objResp.Write("<tr><td");

                        objResp.Write(@" class=""CAP_CELL" + Style + @" nowrap"" style=""" + CapCellStyle + @""" title=""" + HtmlEncode(strCapTextTip) + @""" >");
                        if (IsMasterPageNew())
                        {
                            objResp.Write(@"<span>" + HtmlEncode(strCapText) + "</span>");
                        }
                        else
                        {
							objResp.Write(HtmlEncode(strCapText));
						}
						objResp.Write(@"</td></tr><tr><td width=""100%"">");


                        //            '-- disegna le righe del contenuto
                        objResp.Write(@"<div style=""MARGIN: 0px auto; overflow: auto; WIDTH: 100%; HEIGHT: 100%"" >");
                        DrawRows(objResp, StartDate);
                        objResp.Write("</div>");
                        objResp.Write("</td></tr></table></td>");
                    }
                    //        End If

                    StartDate = StartDate.AddDays(1); // DateAdd("d", 1, StartDate)


                    //    Next
                }

                objResp.Write("</tr>");
                cmax++; // = cmax + 1


                myMese = StartDate.Month;
                Anno = StartDate.Year;
            }
            // Loop While Anno * 12 + mese < AnnoOrig * 12 + meseOrig + MesiShow   'CInt(Mid(AnnoMese, 6, 2)) And cmax < 10000
            while (Anno * 12 + myMese < AnnoOrig * 12 + meseOrig + MesiShow); //   'CInt(Mid(AnnoMese, 6, 2)) And cmax < 10000)



            objResp.Write("</table>");


            mp_numRow = r;


            //'-- aggiunge le variabili per la selezione
            objResp.Write(@"<script type=""text/javascript"" > " + Environment.NewLine);
            objResp.Write(@"var " + id + "_StyleRow = new Array( " + mp_numRow + " + 1 );" + Environment.NewLine);
            objResp.Write(@"var " + id + @"_SelectedRow = new Array( " + mp_numRow + " + 1);" + Environment.NewLine);
            objResp.Write(@"var " + id + "_NumRow = " + mp_numRow + " ;" + Environment.NewLine);


            long StartRow = default;
            long EndRow = default;

            StartRow = 0;
            EndRow = mp_numRow;


            objResp.Write(@"var " + id + "_StartRow = " + StartRow + " ;" + Environment.NewLine);
            objResp.Write(@"var " + id + "_EndRow = " + EndRow + " ;" + Environment.NewLine);


            objResp.Write("var " + id + "_StyleRow0 = '" + StyleRow0 + "' ;" + Environment.NewLine);
            objResp.Write("var " + id + "_StyleRow1 = '" + StyleRow0 + "' ;" + Environment.NewLine);
            objResp.Write("var " + id + "_ActiveSelection = '" + ActiveSelection + "' ;" + Environment.NewLine);
            objResp.Write("</script> ");
        }

        private string BubbleSortNumbers(dynamic iArray)
        {
            string result = string.Empty;
            int lLoop1, lLoop2, nR = 0;
            string lTemp = string.Empty;
            dynamic[] index;

            nR = iArray.GetUpperBound(0);

            index = new dynamic[nR];

            for (lLoop1 = 0; lLoop1 < nR; lLoop1++)
            {
                index[lLoop1] = lLoop1;
            }

            for (lLoop1 = nR; lLoop1 > 0; lLoop1--)
            {
                for (lLoop2 = 2; lLoop2 < lLoop1; lLoop2++)
                {
                    if (iArray(lLoop2 - 1) > iArray(lLoop2))
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
                for (lLoop1 = nR; lLoop1 > 0; lLoop1--)
                {
                    if (String.IsNullOrEmpty(result))
                    {
                        result = index[lLoop1];
                    }
                    else
                    {
                        result += "#" + index[lLoop1];
                    }
                }

                if (String.IsNullOrEmpty(result))
                {
                    result = index[lLoop1];
                }
                else
                {
                    result += "#" + index[lLoop1];
                }


            }
            else
            {
                for (lLoop1 = 0; lLoop1 < nR; lLoop1++)
                {
                    if (String.IsNullOrEmpty(result))
                    {
                        result = index[lLoop1];
                    }
                    else
                    {
                        result += "#" & index[lLoop1];
                    }
                }

            }

            return result;
        }

        // '-- disegna la testata della griglia con le descrittive delle colonne
        private void DrawCaption(IEprocResponse objResp)
        {
            int c = default;

            // '-- apro la riga
            objResp.Write("<tr>" + Environment.NewLine);

            for (c = 1; c <= 7; c++)
            {
                // '-- apro la cella
                objResp.Write("<td");
                objResp.Write(@$" width='15%'  id='DAY_{c}' class='DAY_CAP_{Style} nowrap' >");


                objResp.Write(Application.ApplicationCommon.CNV(strGiorno(c), mp_session));

                //'-- chiudo la cella
                objResp.Write("</td>" + Environment.NewLine);
            }

            //'-- chiudo la riga
            objResp.Write("</tr>" + Environment.NewLine);
        }

        private void DrawRows(IEprocResponse objResp, DateTime CurDate)
        {
            string strStyle = string.Empty;
            long r1 = default;
            long c = default;
            string n = string.Empty;
            Grid_ColumnsProperty prop;
            long rowCounter = default;
            long StartRow = 0;
            string strVal = string.Empty;
            dynamic v;
            bool bDrawed = default;
            string strProp = string.Empty;
            bool bDrawLoading = default;
            double passo = default;
            double PercLoading = default;
            long TotRecord = 0;
            string rn = string.Empty;
            dynamic vPropColR1;
            dynamic vPropColR2;
            Field obj;
            bool bPersonalStyle = false;
            dynamic aOrderRow;
            long nIndRow = 0;
            string strId = string.Empty;

            mp_numCol = Columns.Count;

            vPropColR1 = new dynamic[mp_numCol];
            vPropColR2 = new dynamic[mp_numCol];


            for (c = 0; c < mp_numCol; c++)
            {
                obj = Columns.ElementAt((int)c).Value;
                vPropColR1[c] = SetCellProperty(r, c, obj.Name, StyleRow0);
                vPropColR2[c] = SetCellProperty(r, c, obj.Name, StyleRow0);
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

            //'-- ciclo sulle righe della matrice
            long countNumCicle = 0;
            r1 = 0;

            if (mp_RS.RecordCount > 0 && !mp_RS.EOF)
            {
                //while (Convert.ToDateTime(mp_RS.Fields[FieldData].ToString()) < CurDate)
                while ((CurDate - Convert.ToDateTime(mp_RS.Fields[FieldData].ToString())).TotalDays > 0)
                {
                    mp_RS.MoveNext();
                    if (mp_RS.EOF)
                    {
                        break;
                    }
                }

                if (!mp_RS.EOF)
                {
                    objResp.Write(@"<table width=""100%"" cellspacing=""0"" cellpadding=""0"" >" + Environment.NewLine);
                    rowCounter = 0;

                    //while (Convert.ToDateTime(mp_RS.Fields[FieldData].ToString()) == CurDate)
                    while ((CurDate - Convert.ToDateTime(mp_RS.Fields[FieldData].ToString())).TotalDays == 0)
                    {
                        //'-- determina lo stile da applicare ala riga
                        bPersonalStyle = false;
                        if (r1 % 2 == 0)
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

                        if (!String.IsNullOrWhiteSpace(FieldStyle))
                        {
                            strStyle += mp_RS.Fields[FieldStyle].ToString();
                        }

                        //'-- apro la riga ed imposto gli eventi per la selezione se necessari
                        objResp.Write(@"<!--      RIGA " + r + "                      -->");
                        if (!String.IsNullOrEmpty(mp_strFieldKey))
                        {
                            strId = id + "_idRow_" + r;
                            objResp.Write(@"<input type=""hidden"" name=""" + strId + @"""  id=""" + strId + @""" ");
                            objResp.Write(@" value=""" + mp_RS.Fields[mp_strFieldKey].ToString() + @"""/>" + Environment.NewLine);
                        }

                        if (DrawMode == 1)
                        {
                            rn = id + "R" + r;
                            if (!PrintMode)
                            {
                                objResp.Write(@"<tr id=""" + rn + @""" name=""" + rn + @""" class=""" + strStyle + @""" " + Environment.NewLine);

                                if (ActiveSelection > 0)
                                {
                                    objResp.Write(@" onMouseOver=""G_SetRC('" + id + "', 'GR_OverRow' , " + r + @" );"" ");
                                    objResp.Write(@" onMouseOut=""G_SetRC( '" + id + @"', '" + strStyle + @"' , " + r + @" );"" ");
                                }

                                if (ActiveSelection == 2 || ActiveSelection == 3)
                                {
                                    objResp.Write(@" onclick=""G_ClickRow( '" + id + @"', " + r + @" );"" >");
                                    objResp.Write(@"<td class=""" + strStyle + @""" ><input type=""checkbox"" name=""" + id + @"_SEL""  id=""" + id + @"_SEL"" >");
                                }
                                else
                                {
                                    objResp.Write(" >");
                                }
                            }
                            else
                            {
                                objResp.Write(@"<tr class=""" + strStyle + @""" >" + Environment.NewLine);
                            }
                        }

                        for (c = 0; c < mp_numCol; c++)
                        {
                            //obj = Columns.ElementAt((int)c + 1).Value;
                            obj = Columns.ElementAt((int)c).Value;
                            if (DrawMode == 2)
                            {
                                objResp.Write("<tr>" + Environment.NewLine);
                            }

                            //'-- verifico se la colonna è presente nel recordset
                            try
                            {
                                v = mp_RS.Fields[obj.Name].ToString();
                                obj.Value = v;
                            }
                            catch
                            {

                            }

                            //'-- identifico il campo sulla riga
                            obj.SetRow(r);
                            if (!bPersonalStyle)
                            {
                                strProp = r % 2 == 0 ? vPropColR2[c] : vPropColR1[c];
                            }
                            else
                            {
                                strProp = SetCellProperty(r, c, obj.Name, strStyle);
                            }

                            strProp = strProp.Replace("<ID_ROW>", r.ToString());

                            if (strProp != "HIDE")
                            {
                                bDrawed = false;
                                if (mp_OBJCustomCellDraw != null)
                                {
                                    bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(this, 0, obj, r, c, strProp, objResp);
                                }

                                if (!bDrawed)
                                {
                                    //'-- apro la cella
                                    objResp.Write(@"<td " + strProp + ">");

                                    //'-- scrivo il valore
                                    if (!Editable)
                                    {
                                        obj.umValueHtml(objResp, false);
                                        obj.ValueHtml(objResp, false);
                                    }
                                    else
                                    {
                                        obj.umValueHtml(objResp);
                                        obj.ValueHtml(objResp);
                                    }

                                    //'-- chiudo la cella
                                    objResp.Write("</td>" + Environment.NewLine);
                                }
                            }
                            else
                            {
                                //'--se una colonna è nascosta allora disegno un campo nascosto
                                HTML_HiddenField(objResp, "R" + r + "_" + obj.Name, obj.TechnicalValue());
                            }

                            //'-- chiudo la riga
                            if (DrawMode == 2)
                            {
                                objResp.Write("</tr>" + Environment.NewLine);
                            }
                        }

                        r = r + 1;
                        r1 = r + 1;

                        mp_RS.MoveNext();


                        //-- chiudo la riga
                        if (DrawMode == 1 || mp_RS.EOF)
                        {
                            objResp.Write("</tr>" + Environment.NewLine);
                        }
                        else
                        {
                            objResp.Write("</tr><tr><td>&nbsp;</td></tr>" + Environment.NewLine);
                        }

                        rowCounter++;

                        //'-- inserisco los cript per aggiornare il loading su griglie molto grandi

                        if (bDrawLoading && r > PercLoading)
                        {
                            PercLoading = PercLoading + passo;
                            objResp.Write("<script>try{" + id + "_loading.innerText='Loading... " + Strings.Format((rowCounter / TotRecord) * 100, "0") + "%';}catch(e){};</script>");
                        }

                        //'-- nel caso la griglia sia paginata verifica che non vengano inserite più righe di quelle richieste
                        if (mp_RS.EOF)
                        {
                            break;
                        }
                    }
                    if (bDrawLoading)
                    {
                        objResp.Write(@"<script>try{" + id + "_loading.innerText='Wait...';}catch(e){};</script>");
                    }
                    else
                    {
                        objResp.Write("</table>");
                    }
                }
            }
        }

        private string strMese(int i)
        {
            return System.Globalization.CultureInfo.CreateSpecificCulture("it").DateTimeFormat.GetMonthName(i).ToUpper(); //.GetAbbreviatedMonthName(i);
        }

        private string strGiorno(int i)
        {
            string dayOfTheWeek = giorniSettimana[i - 1]; // System.Globalization.CultureInfo.CreateSpecificCulture("en-EN").DateTimeFormat.DayNames[i-1];
            //dayOfTheWeek;// = FirstDayOfWeek.Monday;
            string result = ShowSintetic == true ? dayOfTheWeek.Substring(0, 3) : dayOfTheWeek;
            result = char.ToUpper(result[0]) + result.Substring(1);
            return result;
        }

        private string StyleFestivo(DateTime CurDate, ref string Caption)
        {
            string result = string.Empty;

            DateTime StartDate;

            if (mp_RSFestivity.RecordCount > 0 && !mp_RSFestivity.EOF)
            {
                int comparision = String.Compare(mp_RSFestivity.Fields["Data"].ToString(), CurDate.ToString("yyyy-MM-dd"), StringComparison.OrdinalIgnoreCase);

                while (comparision < 0) // Curdate è minore del dato fornito dal recordset
                {
                    mp_RSFestivity.MoveNext();
                    if (mp_RSFestivity.EOF)
                    {
                        return null;
                    }
                }

                if (!mp_RSFestivity.EOF)
                {
                    if (comparision == 0)  // le due date sono uguali
                    {
                        result = mp_RSFestivity.Fields["Stile"].ToString();
                        Caption += " - " + mp_RSFestivity.Fields["Descrizione"].ToString();
                    }
                }
            }

            return result;
        }

        private bool Occupato(DateTime CurDate)
        {
            bool check = default;

            if (mp_RS.RecordCount > 0 && !mp_RS.EOF)
            {
                //     string mydata = mp_RS.Fields[FieldData].ToString();

                System.Data.DataRow[] found = mp_RS.dt.Select("DataRiferimento = '" + CurDate.ToString() + "'");
                if (found.Length > 0)
                {
                    check = true;
                }
            }
            return check;
        }

        private string SetCellProperty(long row, long col, string colName, string strStyle)
        {
            Grid_ColumnsProperty propCol = new Grid_ColumnsProperty();
            string strApp = string.Empty;

            try
            {
                propCol = ColumnsProperty[colName];

                if (!String.IsNullOrEmpty(propCol.Alignment))
                {
                    strApp += " align='" + propCol.Alignment + "' ";
                }


                if (!String.IsNullOrEmpty(Columns[colName].Style))
                {
                    strApp += @" class=""nowrap " + strStyle + "_" + Columns[colName].Style + @"""  ";
                }
                else
                {
                    strApp += @" class=""nowrap " + strStyle + @"""  ";
                }


                if (!String.IsNullOrEmpty(propCol.OnClickCell) && !PrintMode)
                {
                    strApp += @" onclick=""" + propCol.OnClickCell + "('" + id + "' , <ID_ROW> , " + col + @" );"" ";
                }


                if (propCol.Hide)
                {
                    strApp = "HIDE";
                }
            }
            catch
            {
                strApp += @" class=""nowrap " + strStyle;
                if (!String.IsNullOrEmpty(Columns[colName].Style))
                {
                    strApp += "_" + Columns[colName].Style;
                }

                strApp += @""" ";
            }


            return strApp;
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

            string result = st;

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

                    if (GetValueFromRS(mp_RS.Fields[f]) == v)
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

        public void ActiveSingleLockRow(bool bActive)
        {
            mp_SingleLock = bActive;
        }

        //'-- aggiunge una condizione alla collezione
        public void AddRowCondition(string strRowStyle, string strcondition)
        {
            mp_rowCondition.Add(strRowStyle + "#@#" + strcondition);
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
                    prop = ColumnsProperty[obj.Value.Name];
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
                            if (strCaption.Length > prop.Length)
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

            mp_numCol = Columns.Count;

            if (mp_RS == null)
            {
                if (mp_Matrix.Length == 0)
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

                        for (c = 0; c <= mp_numCol; c++)
                        {
                            obj = Columns.ElementAt((int)c).Value;
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

                            if (strProp != "HIDE")
                            {
                                // apro la cella
                                objResp.Write("<td>");

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

                        }
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
                            obj = Columns.ElementAt((int)c).Value;

                            if (DrawMode == 2)
                            {
                                objResp.Write("<tr>" + Environment.NewLine);
                            }

                            // -- verifico se la colonna � presente nel recordset
                            if (mp_RS.ColumnExists(obj.Name))
                            {
                                v = mp_RS[obj.Name];
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

                            strProp = SetCellProperty(r, c, obj.Name, strStyle);
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
                        }
                    }
                }
            }
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

            mp_numCol = Columns.Count;
            vetTotal = new double[Columns.Count];

            if (mp_RS == null)
            {
                StartRow = 0;

                // ciclo sulle righe della matrice
                for (r = StartRow; r < mp_numRow; r++)
                {
                    nIndRow = r;
                    int c1 = 0;
                    foreach (KeyValuePair<string, Field> col in Columns)
                    {
                        st = false;
                        st = ColumnsProperty[col.Value.Name].Total;

                        if (st)
                        {
                            if (mp_RowCol)
                            {
                                totale = 0;
                                totale = (double)mp_Matrix[nIndRow, c1];
                                vetTotal[c1] = vetTotal[c1] + totale;
                            }
                            else
                            {
                                totale = 0;
                                totale = (double)mp_Matrix[c1, nIndRow];

                                vetTotal[c1] = vetTotal[c1] + totale;
                            }
                        }
                        c1++;
                    }
                }
            }
            else
            {
                // calcola i totali
                if (mp_RS.RecordCount > 0)
                {
                    mp_RS.MoveFirst();
                    while (!mp_RS.EOF)
                    {

                        for (c = 0; c < mp_numRow; c++)
                        {
                            obj = Columns.ElementAt((int)c).Value;
                            st = false;
                            st = ColumnsProperty[obj.Name].Total;
                            if (st)
                            {
                                vetTotal[c] = vetTotal[c] + (double)GetValueFromRS(mp_RS.Fields[obj.Name]);  // VERIFICARE!
                            }
                        }

                        mp_RS.MoveNext();
                    }
                }
            }

            int cSpan = 0;
            for (c = 1; c < mp_ColSpanTotal; c++)
            {
                obj = Columns.ElementAt((int)c).Value;
                st = false;
                st = ColumnsProperty[obj.Name].Hide;
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
                obj = Columns.ElementAt((int)c + 1).Value;
                st = false;
                st = ColumnsProperty[obj.Name].Hide;

                if (!st)
                {
                    objResp.Write("<td");
                    objResp.Write($@" class=""{Style}_Total_{obj.Style} nowrap"">");
                    st = false;
                    st = ColumnsProperty[obj.Name].Total;
                    if (st)
                    {
                        obj.Value = vetTotal[c];
                        obj.SetRow2("Tot");

                        bDrawed = false;

                        mp_OBJCustomCellDraw = null;  // Eliminare

                        if (mp_OBJCustomCellDraw != null)
                        {
                            //bDrawed = mp_OBJCustomCellDraw
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
                }
                objResp.Write("</td>" + Environment.NewLine);
            }
            objResp.Write("</tr>" + Environment.NewLine);
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


        public void RecordSet(TSRecordSet rs, string strFieldKey = "", bool bAutoCol = true)
        {
            int i;
            mp_strFieldKey = strFieldKey;

            if (bAutoCol)
            {
                Field objFld;
                string strFormat = string.Empty;
                int fldType;

                Columns = new Dictionary<string, Field>();

                //for (i = 0; i < rs.Fields.Count; i++)//TODO <= for
                //{
                //    if (rs.Fields[i].Name != strFieldKey)
                //    {
                //        objFld = new Field();
                //        strFormat = ""; // format per le string
                //        fldType = 1;

                //        switch (rs.Fields[i].Type)
                //        {
                //            case DataTypeEnum.adInteger:
                //            case DataTypeEnum.adSmallInt:
                //            case DataTypeEnum.adTinyInt:
                //            case DataTypeEnum.adUnsignedBigInt:
                //            case DataTypeEnum.adUnsignedInt:
                //            case DataTypeEnum.adUnsignedSmallInt:
                //            case DataTypeEnum.adUnsignedTinyInt:
                //                strFormat = "###,###,##0"; // -- con NUMERI INTERI
                //                fldType = 2;
                //                break;
                //            case DataTypeEnum.adDecimal:
                //            case DataTypeEnum.adDouble:
                //            case DataTypeEnum.adNumeric:
                //            case DataTypeEnum.adSingle:
                //                strFormat = "###,###,##0,00##"; // con virgola
                //                fldType = 2;
                //                break;
                //            default:
                //                strFormat = "";
                //                fldType = 1;
                //                break;

                //        }
                //        fldType = 1;
                //        strFormat = "";
                //        objFld.Init(fldType, rs.Fields[i].Name, null, null, null, strFormat);
                //        Columns.Add(objFld.Name, objFld);
                //    }
                //}

                for (i = 0; i < rs.Columns.Count; i++)
                {
                    if (rs.Columns[i].ColumnName != strFieldKey)
                    {
                        objFld = new Field();
                        strFormat = ""; // format per le string
                        fldType = 1;

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
                        fldType = 1;
                        strFormat = "";
                        objFld.Init(fldType, rs.Columns[i].ColumnName, null, null, null, strFormat);
                        Columns.Add(objFld.Name, objFld);
                    }
                }


            }

            //'-- memorizzo il recordset nella variabile membro
            mp_RS = rs;
            mp_numRow = mp_RS.RecordCount - 1;
        }


        public void ReloadUnfilteredDomain()
        {
            eProcurementNext.HTML.BasicFunction.ReloadUnfilteredDomain(Columns, Editable);
        }

        public void RsFestivity(TSRecordSet rs)
        {
            mp_RSFestivity = rs;
        }

        public void SetCustomDrawer(dynamic obj)
        {
            mp_OBJCustomCellDraw = obj;
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

            mp_RowLocked = row; // '-- quante righe devono essere fisse sullo schermo
            mp_ColLocked = col; // '-- quante colonne devono essere fisse sullo schermo

        }


        public void SetMatrixDisposition(bool RowCol)
        {

            mp_RowCol = RowCol;

        }

        //'-- indica alla griglia che deve visualizzare la pagina CurPage
        //'-- le pagine partono da 1, zero indica che non è paginata
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


            //string test = string.Empty;

            //test = tryToGetValueFromDictionary(col, "Sort");

            //Sort = test;

            //test = tryToGetValueFromDictionary(col, "SortOrder");
            //SortOrder = test;
            Sort = col["Sort"].ToString();
            SortOrder = col["SortOrder"].ToString();

            //URL = $"{StrUrl}?{strQueryString}";
            URL = $"{StrUrl}?{strQueryString}";

            //""-- tolgo dall""url i prametri di sort
            URL = MyReplace(URL, $"&Sort={col["Sort"]}", "");
            URL = MyReplace(URL, $"&SortOrder={col["SortOrder"]}", "");

            //""-- se il sort � su tutte le colonne automaticamente imposto il valore
            SortAll = bAll;

            //""-- imposto il valore per l""auto sort della tabella
            AutoSort = bAutoSort;

        }

        public void ShowTotal(string Title, int colspan)
        {

            mp_TotalTitle = Title;
            mp_ColSpanTotal = colspan;
            mp_ShowTotal = true;

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

                mp_strIdRowOrder = BubbleSortNumbers(VetKey);
            }
        }
    }
}