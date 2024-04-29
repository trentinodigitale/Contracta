using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EprocNext.CommonDB;
using EprocNext.Response;

namespace EprocNext.HTML
{
    public class MultiDimensionalGrid
    {
        public string _Caption = string.Empty;       //'-- Titolo della griglia

        public string Style = string.Empty;

        public string StyleCaption = string.Empty;  //'-- Classe associata alla riga di testata delle colonne
        public string StyleRow0 = string.Empty;     //'-- Classe associata alla riga par dispari
        public string StyleRow1 = string.Empty;   //'

        public string Id = string.Empty;        //'-- identificativo della griglia

        public Dictionary<string, Field> Columns = new Dictionary<string, Field>();
        //'public LenCol As Variant
        public Grid_ColumnsProperty ColumnsProperty = new Grid_ColumnsProperty(); // o sempre un dictionary string,Field?

        public string width = string.Empty;
        public string Height = string.Empty;



        public bool Editable = false;  //'-- indica se la giglia � editabile per default non lo �
        public int DrawMode = 0;  //'-- indica la modalit� di disegno della griglia 1 = griglia , 2 = schede


        private dynamic[] mp_Matrix; //'-- matrice dei valori contenuti nella
                                     //'-- deve essere in stretta relazione con le colonne
                                     //'-- si considera zero based ( riga, colonna)

        private int mp_numRow = 0;
        private int mp_numCol = 0;

        private TSRecordSet mp_RS = new TSRecordSet(); //'-- recordset associato alla griglia in alternativa alla matrice

        //'-- usatre per paginare la griglia
        private long mp_CurPage = 0;   //'-- se avvalorato indica la pagina corrente a partie da 1
        private long mp_RowPage = 0;   //'-- indica il numero di righe da visualizzare in una pagina
                                       //private Response As Object


        public string URL = string.Empty; //'-- indirizzo da chiamare quando si richiede il sort di una colonna
        public string Sort = string.Empty; //'-- nome della colonna su cui mettere la bitmap del sort
                                           //'-- E' A CURA DELL'APPLICAZIONE FARE IL SORT DEL RECORDSET O DELLA MATRICE
        public string SortOrder = string.Empty; //'-- Verso su cui � espresso il sort
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

        bool mp_ShowTotalRow = false;
        bool mp_ShowTotalCol = false;
        string mp_TotalTitleCol = "";
        string mp_TotalTitleRow = "";

        //'Type Cond
        //'    Style As String
        //'    Field As String
        //'    Operator As String
        //'    Value As String
        //'End Type

        //'
        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            // TODO On Error Resume Next
            int numCol = 0;
            int c = 0;


            JS.Add("getObj", @"<script src=""" + Path + @"jscript/getObj.js"" ></script>");
            JS.Add("ExecFunction", @"<script src=""" + Path + @"jscript/ExecFunction.js"" ></script>");
            JS.Add("GetIdRow", @"<script src=""" + Path + @"jscript/grid/GetIdRow.js"" ></script>");
            JS.Add("GetPosition", @"<script src=""" + Path + @"jscript/GetPosition.js"" ></script>");
            JS.Add("lockedGrid", @"<script src=""" + Path + @"jscript/grid/lockedGrid.js"" ></script>");
            JS.Add("GetCheckedRows", @"<script src=""" + Path + @"jscript/grid/GetCheckedRows.js"" ></script>");
            // TODO  If err.number > 0 Then err.Clear

            //'-- aggiungo i js dei campi utilizzati sulla griglia
            numCol = Columns.Count - 1;


            for (c = 0; c <= numCol; c++)
            {
                Columns.ElementAt(c + 1).Value.JScript(JS, Path);
            }
            // TODO If err.number > 0 Then err.Clear

        }


        private void Class_Initialize()
        {

            Style = "Grid";
            StyleCaption = "_RowCaption";
            StyleRow0 = "GR0";
            StyleRow1 = "GR1";
            //mp_Matrix = Empty
            width = "100%";
            //Set ColumnsProperty = New Collection
            Editable = false;
            mp_ShowTotalRow = false;
            mp_ShowTotalCol = false;
            mp_TotalTitleCol = "";
            mp_TotalTitleRow = "";
        }


        public void SetMatrix(dynamic m)
        {

            // TODO On Error Resume Next
            mp_Matrix = m;

            if (m.Lenght > 0)
            {
                mp_numRow = mp_Matrix.GetUpperBound(1);
                mp_numCol = mp_Matrix.GetUpperBound(2);
            }
            else
            {
                mp_numRow = -1;
            }

        }


        //'-- ritorna il codice html DELLA GRIGLIA
        public string Html(EprocResponse objResp)
        {

            //'Dim strApp As String
            if (AutoSort)
            {
                // TODO On Error Resume Next
                try
                {
                    if (!string.IsNullOrEmpty(Sort))
                    {
                        mp_RS.Sort(Sort + @" " + SortOrder);
                    }
                }
                catch
                {
                    // TODO If err.number Then
                    Sort = "";
                    SortOrder = "";
                    // TODO err.Clear
                }
            }
            // TODO On Error GoTo 0



            //'-- div che racchiude la tabella
            objResp.Write(@"<div id=""div_" + Id + @""" >" + Environment.NewLine);

            //'-- controlla la presenza della griglia
            //'If IsEmpty(mp_Matrix) Or Columns Is Nothing Then
            if (Columns == null)
            {
                objResp.Write("La griglia non � stata avvalorata ");
                objResp.Write(_Caption);
                objResp.Write("</div>" + Environment.NewLine);
                //'Html = strApp
                return objResp.Out();
            }


            //'-- inserisce gli identificativi di riga --


            // TODO  VERIFICARE LA FUNZIONE WriteIdRow che non si da dove esce fuori!!

            //WriteIdRow(objResp);

            //'-- metto il titolo alla tabella nel caso sia presente
            if (!string.IsNullOrEmpty(_Caption))
            {
                //'objResp.Write "<table class=""" & Style & "_Title""  id=""" & Id & """ name=""" & Id & """ width=""100%"" cellspacing=""0"" cellpadding=""0"" >" + Environment.NewLine);
                objResp.Write(@"<table class=""" + Style + @"_Title""  id=""" + Id + @""" name=""" + Id + @""" cellspacing=""0"" cellpadding=""0"" >" + Environment.NewLine);
                objResp.Write(@"<tr><td class=""" + Style + @"_TitleCell"" >");
                objResp.Write(_Caption + "</td></tr><tr><td>" + Environment.NewLine);
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
            if (!string.IsNullOrEmpty(_Caption))
            {
                objResp.Write("</td></tr></table>");

            }

            objResp.Write("</div>" + Environment.NewLine);


            //'Html = strApp

            return objResp.Out();

        }


        //'-- disegna la tabella con i lock di righe e colonne
        private void DrawLockedGridHtml(EprocResponse objResp)
        {

            //'-- disegno la div per la posizione sullo schermo
            objResp.Write(@"<div id=""" + Id + @"_ShowedDiv"" width=""100%"" height=""100%"">");
            objResp.Write(@"<table border=""0"" id=""" + Id + @"_Showed"" width=""100%"" height=""100%"" onResize=""javascript: try { ResizeGrid( '" + Id + @"' ); }   catch(  e ){  ; };"" >");
            //'objResp.Write "<table id=""" & Id & "_Showed"" width=""100%"" height=""100%"" onResize=""javascript: try { MoveGrid( '" & Id & "' ); }   catch(  e ){  ; };"" >"
            objResp.Write("<tr>");
            objResp.Write(@"<td width=""100%"" height=""100%"" valign=""center"" align=""center"" ><img src=""../ctl_library/images/grid/clessidra.gif"" border=""0"" >&nbsp;<label id=""" + Id + @"_loading"" name=""" + Id + @"_loading"" >Loading... 0%</label>");
            objResp.Write("</td>");
            objResp.Write("</tr>");
            objResp.Write("</table>");
            objResp.Write("</div>");

        }


        public void DrawLockedHtml(EprocResponse objResp)
        {

            //'-- disegno la div con il contenuto
            objResp.Write(@"<div id=""" + Id + @"_Content"" style=""position: absolute; overflow: auto; display: none;"" onScroll=""javascript:ScrollLockedInfo( '" + Id + @"' );"" > ");
            //'objResp.Write "<div id=""" + Id + "_Content"" style=""position: absolute; overflow: auto; display: none;"" onScroll=""javascript:ScrollCaption( '" + Id + "' );"" > "
            DrawGridHtml(objResp);
            objResp.Write("</div>");


            //'-- disegno la div per le righe fisse
            objResp.Write(@"<div id=""" + Id + @"_LockedRow"" style=""position: absolute; overflow: hidden; display: none; ""  rows=""" + mp_RowLocked + @""" > ");

            objResp.Write(@"</div>");


            //'-- disegno la div per le colonne fisse
            objResp.Write(@"<div id=""" + Id + @"_LockedCol"" style=""position: absolute; overflow: hidden; display: none; "" cols=""" + mp_ColLocked + @""" > ");
            objResp.Write(@"</div>");

            //'-- disegno la div per l'angolo fisso se necessario
            objResp.Write(@"<div id=""" + Id + @"_LockedCorner"" style=""position: absolute; overflow: hidden; display: none;"" cols=""" + mp_ColLocked + @""" > ");
            objResp.Write(@"</div>");


            //'-- js per disegnare e posizionare la prima volta la griglia
            objResp.Write(@"<script type=""text/javascript"" > StartScrolledGrid( '" + Id + "' ); ");
            //'objResp.Write(@"<script type=""text/javascript"" > MoveGrid( '" + Id + "' ); "
            objResp.Write(@"</script>");
        }


        private void DrawGridHtml(EprocResponse objResp)
        {

            // IIf(width <> "" Or mp_Locked = True, " width=""" + width + @""" ", "")

            string strTest = (!string.IsNullOrEmpty(width) || mp_Locked) ? @" width=""" + width + @""" " : @"";
            //'-- apertura della tabella HTML
            objResp.Write(@"<table class=""Grid""  id=""" + Id + @""" name=""" + Id + @""" " + strTest + @" cellspacing=""0"" cellpadding=""0"" ");


            objResp.Write(@" numrow=""" + mp_numRow + @""" >" + Environment.NewLine);

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

        }



        //'-- disegna la testata della griglia con le descrittive delle colonne
        private string DrawCaption(EprocResponse objResp)
        {
            //'Dim strApp As String
            Field obj = new Field();
            int c = 0;
            string strCaption = string.Empty;
            Grid_ColumnsProperty prop = new Grid_ColumnsProperty();
            bool bSortCol = false;
            // TODO On Error Resume Next

            //'-- apro la riga
            objResp.Write("<tr>" + Environment.NewLine);

            mp_numCol = Columns.Count - 1;


            for (c = 0; c < mp_numCol; c++)
            {


                obj = Columns.ElementAt(c + 1).Value;

                //'-- se la griglia non � editabile tutte le colonne saranno non editabili
                //'        If Editable = False Then
                //'            obj.SetEditable False
                //'        End If


                strCaption = obj.Caption;

                //'-- apro la cella
                objResp.Write("<td ");
                objResp.Write(@" id=""" + Id + "_" + obj.Name + @""" column=""" + c + @""" ");


                bSortCol = false;
                //'-- determino la larghezza delle colonne per troncare alla larghezza desiderata
                prop = ColumnsProperty[obj.Name].Value;
                try
                {

                    //'-- numero di caratteri da visualiizare sulla caption
                    if (prop.Length > 0)
                    {
                        if (strCaption.Length > prop.Length)
                        {
                            objResp.Write(@" title=""" + strCaption + @""" ");
                            strCaption = CommonModule.Basic.Left(strCaption, prop.Length - 3) + @"...";
                        }
                    }

                    //'-- numero di pixel della colonna
                    if (!string.IsNullOrEmpty(prop.width))
                    {
                        objResp.Write(@" nowrap width=""" + prop.width + @""" ");

                    }
                    else if (obj.width > 0)
                    {
                        objResp.Write(@" width=""" + obj.width * 7 + @""" ");
                    }

                    if (prop.Sort) { bSortCol = true; }

                }
                catch
                {
                    prop = null;
                }

                if (obj.width > 0)
                {
                    objResp.Write(@" width=""" + obj.width * 7 + @""" ");
                }



            }
            // TODO err.Clear

            //'-- se la colonna ha il sort aggiunge il link per l'ordinamento
            if ((bSortCol || SortAll) && !PrintMode)
            {
                // IIf(SortOrder = "asc", "desc", "asc")
                string strTest2 = SortOrder.ToLower() == "asc" ? "desc" : "asc";
                //IIf(Sort <> obj.Name
                string strTest = Sort != obj.Name ? "asc" : strTest2;
                objResp.Write(@" onclick=""javascript:self.location='" + URL + "&Sort=" + obj.Name + "&SortOrder=" + strTest + @"';"" ");
                objResp.Write(@" class=""" + Style + StyleCaption + @"_Sort"" ");


            }
            else
            {
                objResp.Write(@" class=""" + Style + StyleCaption + @""" ");
            }


            objResp.Write(">");

            //'-- nel caso la colonna sia quella con il sort metto l'icona che indica l'ordinamento
            if (obj.Name == Sort)
            {
                // IIf(SortOrder = "asc", "asc.gif", "desc.gif")
                string strTest = SortOrder == "asc" ? "asc.gif" : "desc.gif";
                objResp.Write(@" <img border=""0"" src=""../CTL_Library/images/Grid/" + strTest + @""" >");
            }

            //'-- scrivo il valore
            //'objResp.Write strCaption 'CaptionHtml()
            obj.CaptionHtml(objResp);

            //'-- chiudo la cella
            objResp.Write("</td>" + Environment.NewLine);




            //Set obj = Nothing

            //'-- chiudo la riga
            objResp.Write("</tr>" + Environment.NewLine);

            //'DrawCaption = strApp
            return objResp.Out();

        }



        private string DrawRows(EprocResponse objResp)
        {


            string strStyle = string.Empty;
            //'Dim strApp As String
            int r = 0;
            int c = 0;
            string n = string.Empty;
            Grid_ColumnsProperty propCol = new Grid_ColumnsProperty();
            int rowCounter = 0;
            int StartRow = 0;
            string strVal = string.Empty;
            // TODO On Error Resume Next
            dynamic v;
            bool bDrawed = false;
            string strProp = string.Empty;
            bool bDrawLoading = false;
            double passo = default;
            double PercLoading = default;
            int TotRecord = 0;

            mp_numCol = Columns.Count - 1;
            Field obj = new Field();
            bDrawLoading = false;

            //'-- determina se � necessario inserire lo script di aggiornamento % per loading
            //'If DrawMode = 1 And PrintMode = False And mp_CurPage = 0 Then
            if (DrawMode == 1 && !PrintMode && mp_Locked)
            {
                bDrawLoading = true;
                if (mp_RS == null)
                {

                    if (mp_CurPage > 0)
                    {
                        TotRecord = (int)mp_RowPage;
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
                        TotRecord = (int)mp_RowPage;
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

                if (mp_Matrix.Length == 0)
                {
                    mp_numRow = -1;
                }

                StartRow = 0;
                rowCounter = 0;

                //'-- se la griglia � paginata
                if (mp_CurPage > 0)
                {
                    StartRow = (int)(mp_RowPage * (mp_CurPage - 1));
                }

                //'-- ciclo sulle righe della matrice
                for (r = StartRow; r < mp_numRow; r++)
                {

                    if (r % 2 == 0)
                    {
                        strStyle = StyleRow0;
                    }
                    else
                    {
                        strStyle = StyleRow1;
                    }

                    //'-- apro la riga
                    objResp.Write(@"<!--      RIGA " + r + "                      -->");


                    if (DrawMode == 1) { objResp.Write("<tr>" + Environment.NewLine); }

                    for (c = 0; c < mp_numCol; c++)
                    {

                        if (DrawMode == 2) { objResp.Write("<tr>" + Environment.NewLine); }

                        obj = Columns.ElementAt(c + 1).Value;
                        obj.Value = mp_Matrix(r, c);

                        //'-- identifico il campo sulla riga


                        obj.SetRow(r);
                        strProp = SetCellProperty(r, c, obj.Name, strStyle);
                        bDrawed = false;
                        if (mp_OBJCustomCellDraw != null)
                        {
                            bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(this, 0, obj, r, c, strProp, objResp);
                        }

                        if (!bDrawed)
                        {

                            //'-- apro la cella
                            objResp.Write("<td ");
                            objResp.Write(@" id=""" + Id + "_r" + r + "_c" + c + @""" ");
                            objResp.Write(strProp);
                            objResp.Write(">");

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
                        if (DrawMode == 2) { objResp.Write("</tr>" + Environment.NewLine); }

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
            {  //'-- altrimenti scorro il recordset


                //'-- ciclo sulle righe della matrice
                r = 0;
                if (mp_RS.RecordCount > 0)
                {
                    mp_RS.MoveFirst();

                    rowCounter = 0;

                    //'-- se la griglia � paginata
                    if (mp_CurPage > 0)
                    {
                        mp_RS.AbsolutePosition = (int)(mp_RowPage * (mp_CurPage - 1) + 1);
                        r = (int)(mp_RowPage * (mp_CurPage - 1));
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

                        // mp_RowCondition da dove esce fuori???

                        if (mp_rowCondition.Count > 0) { strStyle = CheckRowCondition(strStyle, r); }

                        //'-- apro la riga
                        objResp.Write(@"<!--      RIGA " + r + @"                      -->");
                        if (DrawMode == 1)
                        {
                            objResp.Write("<tr>" + Environment.NewLine);

                            for (c = 0; c < mp_numCol; c++)
                            {
                                obj = Columns.ElementAt(c + 1).Value;

                                if (DrawMode == 2) { objResp.Write("<tr>" + Environment.NewLine); }

                                //'-- verifico se la colonna � presente nel recordset
                                // TODO err.Clear
                                try
                                {
                                    v = mp_RS.Fields[obj.Name];
                                    obj.Value = v;
                                }
                                catch
                                {
                                }

                                //                If err.number Then
                                //                                                err.Clear
                                //Else

                                //                                            End If

                                //'-- identifico il campo sulla riga
                                obj.SetRow(r);

                                strProp = SetCellProperty(r, c, obj.Name, strStyle);

                                bDrawed = false;
                                if (mp_OBJCustomCellDraw != null)
                                {
                                    bDrawed = mp_OBJCustomCellDraw.Grid_DrawCell(this, 0, obj, r, c, strProp, objResp);
                                }


                                if (!bDrawed)
                                {


                                    //'-- apro la cella
                                    objResp.Write("<td ");
                                    objResp.Write(strProp);
                                    objResp.Write(">");

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

                                //'-- chiudo la riga
                                if (DrawMode == 2)
                                {
                                    objResp.Write("</tr>" + Environment.NewLine);

                                }



                                r = r + 1;
                                mp_RS.MoveNext();

                                //'-- chiudo la riga
                                if (DrawMode == 1 || mp_RS.EOF)
                                {
                                    objResp.Write("</tr>" + Environment.NewLine);
                                }
                                else
                                {
                                    objResp.Write("</tr><tr><td>&nbsp;</td></tr>" + Environment.NewLine);
                                }

                                rowCounter = rowCounter + 1;
                                //'-- inserisco los cript per aggiornare il loading su griglie molto grandi
                                if (bDrawLoading && r > PercLoading)
                                {
                                    PercLoading = PercLoading + passo;
                                    objResp.Write("<script>try{" + Id + "_loading.innerText='Loading... " + Microsoft.VisualBasic.Strings.Format((rowCounter / TotRecord) * 100, "0") + "%';}catch(e){};</script>");
                                }

                                //'-- nel caso la griglia sia paginata verifica che non vengano inserite pi� righe di quelle richieste
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
                                objResp.Write("<script>try{" + Id + "_loading.innerText='Wait...';}catch(e){};</script>");
                            }


                        }
                    }

                }
            }

            return objResp.Out();
        }

        private string SetCellProperty(string colName, string strStyle, int row = 0, int col = 0)
        {

            Grid_ColumnsProperty propCol = new Grid_ColumnsProperty();
            string strApp = string.Empty;


            // TODO On Error Resume Next


            propCol = ColumnsProperty[colName];

            try
            {
                if (!string.IsNullOrEmpty(propCol.Alignment))
                {
                    strApp = strApp + " align='" + propCol.Alignment + @"' ";
                }


                if (!string.IsNullOrEmpty(Columns[colName].Style))
                {
                    strApp = strApp + @" class=""" + strStyle + "_" + Columns[colName].Style + @"""  ";
                }
                else
                {
                    strApp = strApp + @" class=""" + strStyle + @"""  ";
                }


                if (!string.IsNullOrEmpty(propCol.OnClickCell) && !PrintMode)
                {
                    strApp = strApp + @" onclick=""" + propCol.OnClickCell + "('" + Id + "' , " + row + " , " + col + @" );"" ";
                }


                if (!propCol.Wrap)
                {
                    strApp = strApp + " nowrap  ";
                }
            }
            catch
            {
                strApp = strApp + @" class=""" + strStyle;

                if (Columns[colName].Style != "")
                {
                    strApp = strApp + "_" + Columns[colName].Style;
                }
                strApp = strApp + @""" ";
                strApp = strApp + " nowrap  ";
            }


            //If err.number Then
            //    err.Clear

            //    strApp = strApp & " class=""" & strStyle

            //    If Columns(colName).Style <> "" Then
            //        strApp = strApp & "_" & Columns(colName).Style
            //    End If


            //    strApp = strApp & """ "
            //    strApp = strApp & " nowrap  "


            //Else

            //    If propCol.Alignment <> "" Then
            //        strApp = strApp & " align='" & propCol.Alignment & "' "
            //    End If


            //    If Columns(colName).Style <> "" Then
            //        strApp = strApp & " class=""" & strStyle & "_" & Columns(colName).Style & """  "
            //    Else
            //        strApp = strApp & " class=""" & strStyle & """  "
            //    End If


            //    If propCol.OnClickCell <> "" And PrintMode = False Then
            //        strApp = strApp & " onclick=""" & propCol.OnClickCell & "('" & Id & "' , " & row & " , " & col & " );"" "
            //    End If


            //    If propCol.Wrap = False Then
            //        strApp = strApp & " nowrap  "
            //    End If



            //End If


            return strApp;

        }


        //'-- Setta il recordset dal quale verranno prese le informazioni per il disegno della griglia
        public void RecordSet(TSRecordSet rs, string strFieldKey = "", bool bAutoCol = true)
        {

            int i = 0;

            mp_strFieldKey = strFieldKey;

            //'-- creo la collezione di colonne
            if (bAutoCol)
            {
                Field objFld;
                Columns = new Dictionary<string, Field>();

                //'-- per ogni colonna
                for (i = 0; i <= (rs.RecordCount - 1); i++)
                {

                    //'-- se non � la colonna chiave
                    if (rs.Fields[i] != strFieldKey)
                    {

                        //'-- inserisco la colonna nella griglia
                        objFld = new Field();

                        objFld.Init(CommonModule.Const.TypeField.FldStatic, rs.Fields[i].Name);
                        Columns.Add(objFld.Name, objFld);

                    }
                }


            }

            //'-- memorizzo il recordset nella variabile membro
            mp_RS = rs;
            mp_numRow = mp_RS.RecordCount - 1;

        }


        public void ShowTotal(string Title, int colspan = 0)
        {
            // TODO  PROVARE A TOGLIERE I COMMENTI E VEDERE DA DOVE ARRIVANO STE VARIABILI

            //mp_TotalTitle = Title;
            //mp_ColSpanTotal = colspan;
            //mp_ShowTotal = true;

        }





        //'-- determina quante righe e colonne blocacre sullo schermo
        public void SetLockedInfo(int row = 0, int col = 0)
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



        public void SetCustomDrawer(dynamic obj)
        {
            mp_OBJCustomCellDraw = obj;
        }

    }
}

