using ClosedXML.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Security;
using Microsoft.VisualBasic;
using System.Collections;
using System.Data.SqlClient;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using FileAccess = System.IO.FileAccess;

namespace eProcurementNext.Razor.Pages.Report
{
    public class prospettoconfronto_NewModel
    {
        public void OnGet()
        {
        }

        const int TIPO_PARAMETRO_STRING = 1;
        const int TIPO_PARAMETRO_INT = 2;
        const int TIPO_PARAMETRO_FLOAT = 3;
        const int TIPO_PARAMETRO_NUMERO = 4;
        const int TIPO_PARAMETRO_DATA = 5;

        const int SOTTO_TIPO_PARAMETRO_CUSTOM = 0;
        const int SOTTO_TIPO_PARAMETRO_NESSUNO = 0;
        const int SOTTO_TIPO_VUOTO = 0;
        const int SOTTO_TIPO_PARAMETRO_TABLE = 1;
        const int SOTTO_TIPO_PARAMETRO_PAROLASINGOLA = 1;
        const int SOTTO_TIPO_PARAMETRO_SORT = 2;
        const int SOTTO_TIPO_PARAMETRO_FILTROSQL = 3;
        const int SOTTO_TIPO_PARAMETRO_LISTANUMERI = 4;

        private static string strConnectionString = ApplicationCommon.Application.ConnectionString;
        private static string paginaChiamata = "Report/ProspettoConfronto_new.aspx";
        private static int mp_idpfu = -20;
        private static eProcurementNext.Session.ISession _session;


        public static void Page_Load(HttpContext HttpContext, EprocResponse htmlToReturn, eProcurementNext.Session.ISession session)
        {
            Microsoft.AspNetCore.Http.HttpResponse Response = HttpContext.Response;
            Microsoft.AspNetCore.Http.HttpRequest Request = HttpContext.Request;
            _session = session;
            // response.write (Request.QueryString())
            // response.end

            int ColStart = 7;
            int Row = 0;
            int k = 0;
            int i = 0;
            int j = 0;
            int NumForn = 0;
            int conta = 0;
            string[] resSplit;
            string[] resSplit2;
            int Row1 = 0;
            int RowTot = 0;
            int NumArticoli = 0;
            double bestOffer = 0;
            double valTmp = 0;
            int EndRows = 0;

            int indCol = 0;
            int indRow = 0;
            string idpfu = GetParamURL(Request.QueryString.ToString(), "UFP");
            string strCause = "";
            string strSQL = "";

            string listaColonne = "";
            string listaColonneSQL = "";

            string listaColonneRic = "";
            string listaColonneRicSQL = "";

            string strfilename = GetParamURL(Request.QueryString.ToString(), "TitoloFile");
            SqlConnection sqlConn1 = null;
            SqlConnection sqlConn2 = null;

            ArrayList listTotal = new ArrayList();
            ArrayList listAumentaColonne = new ArrayList();

            ArrayList listQtRdO = new ArrayList();
            ArrayList listPrzBestOffer = new ArrayList();
            double TotalBestOffer = 0;
            double TotaleRibasso = 0;


            string P_Titolo;
            P_Titolo = GetParamURL(Request.QueryString.ToString(), "TitoloFile");
            validaInput("TitoloFile", P_Titolo, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_VUOTO), HttpContext);

            string P_UFP;
            P_UFP = GetParamURL(Request.QueryString.ToString(), "UFP");
            validaInput("UFP", P_UFP, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_VUOTO), HttpContext);

            string P_IDDOC;
            P_IDDOC = GetParamURL(Request.QueryString.ToString(), "IDDOC");
            validaInput("IDDOC", P_IDDOC, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_VUOTO), HttpContext);



            strSQL = "select * from LIB_Dictionary where dzt_name='SYS_dettaglio-errori'";

            strCause = "Apro la connessione con il db";
            sqlConn1 = new SqlConnection(strConnectionString);
            sqlConn1.Open();


            try
            {

                if (string.IsNullOrEmpty(GetParamURL(Request.QueryString.ToString(), "IDDOC")))
                {
                    htmlToReturn.Write($@"Parametro IDDOC obbligatorio");
                    throw new ResponseEndException(htmlToReturn.Out(), Response, "");
                }

                if (!IsNumeric(CStr(GetParamURL(Request.QueryString.ToString(), "IDDOC"))))
                {
                    htmlToReturn.Write($@"Parametro IDDOC non valido");
                    throw new ResponseEndException(htmlToReturn.Out(), Response, "");
                }

                string idDoc = CStr(CLng(GetParamURL(Request.QueryString.ToString(), "IDDOC")));


                if (string.IsNullOrEmpty(strfilename))
                    strfilename = "Prospetto_Confronto_Offerte";

                strfilename = strfilename + ".xlsx";

                strfilename = Strings.Replace(strfilename, "..", ""); // -- replace per evitare Path Traversal
                strfilename = Strings.Replace(strfilename, "/", "");  // -- replace per evitare Path Traversal
                strfilename = Strings.Replace(strfilename, @"\", "");  // -- replace per evitare Path Traversal

                // -- recupero la stringa di connessione dal web.config dell'application
                string connectionString = ApplicationCommon.Application.ConnectionString;


                // ------------------------------------
                // --- APRO LA CONNESSIONE CON IL DB --
                // ------------------------------------

                strCause = "Apro la connessione con il db";
                sqlConn1 = new SqlConnection(strConnectionString);
                sqlConn1.Open();

                //sqlConn2 = new SqlConnection(strConnectionString);
                //sqlConn2.Open();

                string strVisualValue = "";
                int dztType = 0;
                string strFormat = "";
                string strTechValue = "";

                // ------------------------------------
                // ------- INIZIALIZZO L'XSLX ---------
                // ------------------------------------


                strCause = "Inizializzo excelpackage";

                XLWorkbook pck = new XLWorkbook();


                strCause = "Aggiungo il foglio di lavoro dati";

                //'Aggiugo lo sheet 'Dati'
                //Dim ws As ExcelWorksheet
                IXLWorksheet ws;
                ws = pck.Worksheets.Add("Prospetto");
                //ws = pck.Workbook.Worksheets.Add("Prospetto")
                ws.PageSetup.ShowGridlines = true;

                int idBandoFabbisogni = 0;
                int totFornitori = 0;

                strCause = "Eseguo la select per la vista View_ProspettoConfronto_Valutazione";
                // strSQL = "select linkeddoc from ctl_doc with(nolock) where id = " & idDoc

                strSQL = "select * from View_ProspettoConfronto_Valutazione where id =" + idDoc + " order by codart,aziragionesociale ";

                SqlCommand sqlComm = new SqlCommand(strSQL, sqlConn1);
                SqlDataReader rsDati = sqlComm.ExecuteReader();

                SqlDataReader rs;

                string letteraExcel = "";
                int totRighe = 0;
                // Dim listIdAzi As New ArrayList()
                // Dim listRagSocForn As New ArrayList()

                string dztName = "";

                if (rsDati.HasRows)
                {

                    rsDati.Read();

                    //''''''''''''''''''''''''''''''''''''''
                    //'' DATI DI INTESTAZIONE RDO
                    //''''''''''''''''''''''''''''''''''''''
                    ws.Cell("B2").Value = "Prospetto di Confronto Offerte";
                    ws.Cell("B2").Style.Font.Bold = true;
                    ws.Cell("B2").Style.Font.FontSize = 16;
                    ws.Cell("B2").Style.Font.FontColor = XLColor.Red;


                    ws.Cell("B4").Value = "RDO";
                    ws.Cell("C4").Value = rsDati["Name"];
                    ws.Cell("C4").Style.Font.Bold = true;
                    ws.Cell("C4").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                    ws.Cell("B5").Value = "del";
                    ws.Cell("C5").Style.NumberFormat.Format = "dd/mm/yyyy";
                    ws.Cell("C5").Value = rsDati["DataInvio"];
                    ws.Cell("C5").Style.Font.Bold = true;
                    ws.Cell("C5").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                    ws.Cell("B6").Value = "Committente";
                    ws.Cell("C6").Value = rsDati["Committente"];
                    ws.Cell("C6").Style.Font.Bold = true;
                    ws.Cell("C6").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                    ws.Cell("B7").Value = "Protocollo";
                    ws.Cell("C7").Value = rsDati["Protocol"];
                    ws.Cell("C7").Style.Font.Bold = true;
                    ws.Cell("C7").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                    ws.Cell("B8").Value = "Numero RDO";
                    ws.Cell("C8").Value = rsDati["numerordo"];
                    ws.Cell("C8").Style.Font.Bold = true;
                    ws.Cell("C8").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);



                    rsDati.Close();
                    //rsDati = Nothing  
                    //sqlComm	= Nothing  

                    //'''''''''''''''''''''''''''''''''''''''''''''''''
                    //'' CONTA I FORNITORI
                    //'''''''''''''''''''''''''''''''''''''''''''''''''
                    strCause = "CONTA I FORNITORI";
                    strSQL = "select count(distinct idaziforn) as cnt from View_ProspettoConfronto_Valutazione where id = " + idDoc;
                    sqlComm = new SqlCommand(strSQL, sqlConn1);
                    rsDati = sqlComm.ExecuteReader();

                    if (rsDati.HasRows)
                    {

                        rsDati.Read();

                        NumForn = CInt(rsDati["cnt"]);

                    }

                    rsDati.Close();

                    EndRows = 3;

                    if (NumForn > 4)
                    {

                        //' per ogni fornitore oltre il 4° aggiungiamo 3 righe in coda
                        EndRows = EndRows + 3 * (NumForn - 4);

                    }

                    //'''''''''''''''''''''''''''''''''''''''''''''''''
                    //'' CHIAMA LA STORED PER I DATI DA VISUALIZZARE
                    //'''''''''''''''''''''''''''''''''''''''''''''''''
                    strCause = "chiama la stored ProspettoConfronto_Valutazione_GetDati";
                    strSQL = "EXEC ProspettoConfronto_Valutazione_GetDati " + idDoc;
                    sqlComm = new SqlCommand(strSQL, sqlConn1);
                    rsDati = sqlComm.ExecuteReader();

                    object strTempVal;
                    object strTempVal_1;
                    object strTempVal_2;

                    if (rsDati.HasRows)
                    {

                        rsDati.Read();




                        strCause = "imposta la Row";

                        Row1 = 10;

                        //' ciclo principale sui dati
                        do
                        {

                            strCause = "ciclo sui dati";

                            conta = conta + 1;

                            //' la prima riga contiene i dati di articolo
                            if (conta == 1)
                            {

                                strCause = "prima riga letta";

                                //' stampa i dati di articolo
                                resSplit = Strings.Split(CStr(rsDati["Dati"]), "###");
                                NumArticoli = resSplit.Length;

                                ws.Cell("B12").Value = "Nr.Tariffa";
                                ws.Cell("B12").Style.Font.Bold = true;
                                ws.Cell("B12").Style.Font.FontColor = XLColor.Blue;
                                ws.Cell("B12").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                ws.Cell("C12").Value = "Descrizione";
                                ws.Cell("C12").Style.Font.Bold = true;
                                ws.Cell("C12").Style.Font.FontColor = XLColor.Blue;
                                ws.Cell("C12").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                ws.Cell("D12").Value = "Unita di Misura";
                                ws.Cell("D12").Style.Font.Bold = true;
                                ws.Cell("D12").Style.Font.FontColor = XLColor.Blue;
                                ws.Cell("D12").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                ws.Cell("E12").Value = "Quantità";
                                ws.Cell("E12").Style.Font.Bold = true;
                                ws.Cell("E12").Style.Font.FontColor = XLColor.Blue;
                                ws.Cell("E12").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                Row = 14;

                                for (k = 0; j <= resSplit.Length - 1; k++)
                                {  //To resSplit.Length - 1

                                    resSplit2 = Strings.Split(resSplit[k], ";;;");

                                    for (j = 0; j <= resSplit2.Length - 1; j++)
                                    { //To resSplit2.Length - 1

                                        //' formatta l'articolo come testo
                                        if (j == 0)
                                        {
                                            ws.Cell(Row, j + 2).Style.NumberFormat.Format = "@";
                                        }

                                        //' formatta la qty come numero
                                        if (j == resSplit2.Length - 1)
                                        {

                                            ws.Cell(Row, j + 2).Style.NumberFormat.Format = "###,###,##0.00###"; //''"######"	

                                            strTempVal = resSplit2[j];

                                            if (Strings.InStr(1, CStr(0.5), ",") > 0)
                                            {
                                                strTempVal = Replace(CStr(strTempVal), ".", ",");
                                            }

                                            ws.Cell(Row, j + 2).Value = CDbl(strTempVal);
                                            //' memorizza in un array le qty RDO
                                            listQtRdO.Insert(k, CDbl(strTempVal));

                                        }
                                        else
                                        {
                                            //' questo è il valore in tutti gli altri casi
                                            ws.Cell(Row, j + 2).Value = CStr(resSplit2[j]);
                                        }

                                        //''ws.Cell(Row,j+2).Value = cstr(resSplit2(j)) 
                                        ws.Cell(Row, j + 2).Style.Font.FontColor = XLColor.Blue;
                                        ws.Cell(Row, j + 2).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                    }

                                    Row = Row + 2;

                                }

                                ws.Cell(Row, 3).Value = "TOTALE OFFERTA";
                                ws.Cell(Row, 3).Style.Font.Bold = true;
                                ws.Cell(Row, 3).Style.Font.FontSize = 13;
                                ws.Cell(Row, 3).Style.Font.Underline = XLFontUnderlineValues.Single; //true;
                                ws.Cell(Row, 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                ws.Cell("C" + Row + ":E" + Row).Style.Fill.PatternType = XLFillPatternValues.Solid;//OfficeOpenXml.Style.ExcelFillStyle.Solid; //''ExcelFillStyle.Solid
                                ws.Cell("C" + Row + ":E" + Row).Style.Fill.BackgroundColor = XLColor.Cyan;

                                Row = Row + 6;

                                ws.Cell(Row, 3).Value = "DIFFERENZA OFFERTE";
                                ws.Cell(Row, 3).Style.Font.Bold = true;
                                ws.Cell(Row, 3).Style.Font.FontSize = 13;
                                ws.Cell(Row, 3).Style.Font.Underline = XLFontUnderlineValues.Single;// true;
                                ws.Cell(Row, 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                //' imposta i colori di sfondo
                                ws.Cell("C" + (Row - 4) + ":E" + Row + EndRows).Style.Fill.PatternType = XLFillPatternValues.Solid; //OfficeOpenXml.Style.ExcelFillStyle.Solid; //''ExcelFillStyle.Solid
                                ws.Cell("C" + (Row - 4) + ":E" + Row + EndRows).Style.Fill.BackgroundColor = XLColor.LightGreen;
                                //' imposta i bordi
                                ws.Range(10, 2, 10, 5).Style.Border.TopBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                                ws.Range(10, 2, Row + EndRows, 2).Style.Border.LeftBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                                ws.Range(10, 5, Row + EndRows, 5).Style.Border.RightBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                                ws.Range(Row + EndRows, 2, Row + EndRows, 5).Style.Border.BottomBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

                            }
                            else
                            {

                                strCause = "riga letta n. " + conta;

                                //' le altre righe contengono i dati per ogni fornitore in ciclo sugli articoli					
                                //' ragsoc;;;totale;;;prezzo1;;;importo1;;;prezzo2;;;importo2;;;...							


                                resSplit = Strings.Split(CStr(rsDati["Dati"]), ";;;");


                                //' controllo di coerenza dei dati
                                if (resSplit.Length == (NumArticoli * 2) + 2)
                                {

                                    //' stampa il fornitore i-esimo


                                    //' ragione sociale usata come label								
                                    if (("Fornitore " + (conta - 1) + "_" + resSplit[0]).Length > 22)
                                    {
                                        listAumentaColonne.Add(ColStart);
                                    }

                                    ws.Range(10, ColStart, 10, ColStart + 1).Merge();// = true;
                                    ws.Range(10, ColStart, 10, ColStart + 1).Value = "Fornitore " + (conta - 1) + "_" + resSplit[0];
                                    ws.Cell(10, ColStart).Style.Font.Bold = true;
                                    ws.Cell(10, ColStart).Style.Font.FontSize = 14;
                                    ws.Cell(10, ColStart).Style.Font.Underline = XLFontUnderlineValues.Single; //true;
                                    ws.Cell(10, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                    ws.Cell(10, ColStart).Style.Font.FontColor = XLColor.Red;


                                    //' label Prezzo Unitario
                                    ws.Cell(12, ColStart).Value = "Prezzo Unitario";
                                    ws.Cell(12, ColStart).Style.Font.Bold = true;
                                    ws.Cell(12, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                    //' label Importo
                                    ws.Cell(12, ColStart + 1).Value = "Importo";
                                    ws.Cell(12, ColStart + 1).Style.Font.Bold = true;
                                    ws.Cell(12, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                    //' ciclo per quanti sono gli articoli
                                    Row = 14;

                                    for (i = 1; i <= NumArticoli; i++)
                                    { //to NumArticoli

                                        //' valore Prezzo Unitario

                                        ws.Cell(Row, ColStart).Style.NumberFormat.Format = "€ ###,###,##0.00###";

                                        strTempVal = resSplit[2 * i];

                                        if (Strings.InStr(1, CStr(0.5), ",") > 0)
                                        {
                                            strTempVal = Strings.Replace(CStr(strTempVal), ".", ",");
                                        }

                                        ws.Cell(Row, ColStart).Value = CDbl(strTempVal);
                                        ws.Cell(Row, ColStart).Style.Font.Bold = true;
                                        ws.Cell(Row, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                        //' valore Importo
                                        ws.Cell(Row, ColStart + 1).Style.NumberFormat.Format = "€ ###,###,##0.00###";

                                        strTempVal_1 = resSplit[2 * i + 1];

                                        if (Strings.InStr(1, CStr(0.5), ",") > 0)
                                        {
                                            strTempVal_1 = Strings.Replace(CStr(strTempVal_1), ".", ",");
                                        }

                                        ws.Cell(Row, ColStart + 1).Value = CDbl(strTempVal_1);
                                        ws.Cell(Row, ColStart + 1).Style.Font.Bold = true;
                                        ws.Cell(Row, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                        //' memorizza i prezzi della migliore offerta in un array
                                        if (conta == 2)
                                        {
                                            listPrzBestOffer.Insert(i - 1, CDbl(strTempVal));
                                        }


                                        Row = Row + 2;

                                    }

                                    //' stampa del totale per fornitore
                                    ws.Cell(Row, ColStart).Value = "Totale Fornitore " + CStr(conta - 1);
                                    ws.Cell(Row, ColStart).Style.Font.Bold = true;
                                    ws.Cell(Row, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                    ws.Cell(Row, ColStart).Style.Font.Underline = XLFontUnderlineValues.Single;//true;
                                    ws.Cell(Row, ColStart).Style.Font.FontSize = 13;

                                    ws.Cell(Row, ColStart + 1).Style.NumberFormat.Format = "€ ###,###,##0.00###";

                                    strTempVal = resSplit[1];

                                    if (Strings.InStr(1, CStr(0.5), ",") > 0)
                                    {
                                        strTempVal = Replace(CStr(strTempVal), ".", ",");
                                    }

                                    ws.Cell(Row, ColStart + 1).Value = CDbl(strTempVal);
                                    ws.Cell(Row, ColStart + 1).Style.Font.Bold = true;
                                    ws.Cell(Row, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                    ws.Cell(Row, ColStart + 1).Style.Font.Underline = XLFontUnderlineValues.Single;//true;
                                    ws.Cell(Row, ColStart + 1).Style.Font.FontSize = 13;

                                    //' memorizza totale della migliore offerta
                                    if (conta == 2)
                                    {
                                        TotalBestOffer = CDbl(strTempVal);
                                    }

                                    if (RowTot == 0)
                                    {
                                        RowTot = Row;
                                    }

                                    //' imposta i colori di sfondo								
                                    ws.Range(Row + 2, ColStart, Row + EndRows + 6, ColStart + 1).Style.Fill.PatternType = XLFillPatternValues.Solid;//OfficeOpenXml.Style.ExcelFillStyle.Solid; //''ExcelFillStyle.Solid
                                    ws.Range(Row + 2, ColStart, Row + EndRows + 6, ColStart + 1).Style.Fill.BackgroundColor = XLColor.LightGreen;
                                    //' imposta i bordi
                                    ws.Range(10, ColStart, 10, ColStart + 1).Style.Border.TopBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                                    ws.Range(10, ColStart, Row + EndRows + 6, ColStart).Style.Border.LeftBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                                    ws.Range(10, ColStart + 1, Row + EndRows + 6, ColStart + 1).Style.Border.RightBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                                    ws.Range(Row + EndRows + 6, ColStart, Row + EndRows + 6, ColStart + 1).Style.Border.BottomBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

                                    //' memorizza i totali di ogni fornitore
                                    //'listTotal.Add(cdbl( resSplit(1)))
                                    strCause = "memorizza il totale per il fornitore n. " + (conta - 1);
                                    //'listTotal.Insert(conta-1 , cdbl( resSplit(1)) )

                                    //'strTempVal_2 = resSplit(1)

                                    //'if instr( 1 , cstr( 0.5 ) , "," ) > 0 then 
                                    //'			strTempVal_2 = Replace ( strTempVal_2 , "." , "," )
                                    //'end if

                                    listTotal.Insert(conta - 2, CDbl(strTempVal));



                                    //' stampa le differenze rispetto alle offerte precedenti								
                                    if (conta > 2)
                                    {

                                        //' sono sul fornitoe i-esimo con i = conta-1 e > 1
                                        Row = Row + 2;

                                        for (i = 0; i <= conta - 3; i++)
                                        { //to conta-3									


                                            //' differenza offerta
                                            ws.Cell(Row, ColStart).Value = "Differenza Offerta";
                                            //'ws.Cells(Row,ColStart).Style.Font.Bold = True
                                            ws.Cell(Row, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                            //'ws.Cells(Row,ColStart).Style.Font.Underline = True	
                                            if ((i % 2) == 0)
                                            {
                                                ws.Cell(Row, ColStart).Style.Font.FontColor = XLColor.Brown;
                                            }
                                            else
                                            {
                                                ws.Cell(Row, ColStart).Style.Font.FontColor = XLColor.Purple;
                                            }

                                            strCause = "calcola differenza per il fornitore " + (conta - 1);
                                            //'valTmp = cdbl( resSplit(1)) - cdbl(listTotal.Item(i))
                                            valTmp = CDbl(strTempVal) - CDbl(listTotal[i]);

                                            ws.Cell(Row, ColStart + 1).Style.NumberFormat.Format = "€ ###,###,##0.00###";
                                            ws.Cell(Row, ColStart + 1).Value = valTmp;
                                            ws.Cell(Row, ColStart + 1).Style.Font.Bold = true;
                                            ws.Cell(Row, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                            ws.Cell(Row, ColStart + 1).Style.Font.Underline = XLFontUnderlineValues.Single;//true;
                                            if ((i % 2) == 0)
                                            {
                                                ws.Cell(Row, ColStart + 1).Style.Font.FontColor = XLColor.Brown;
                                            }
                                            else
                                            {
                                                ws.Cell(Row, ColStart + 1).Style.Font.FontColor = XLColor.Purple;
                                            }

                                            //' rapporto tra i totali
                                            ws.Cell(Row + 1, ColStart).Value = "Forn" + (i + 1) + " - Forn" + (conta - 1);
                                            //'ws.Cells(Row,ColStart).Style.Font.Bold = True
                                            ws.Cell(Row + 1, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                            //'ws.Cells(Row,ColStart).Style.Font.Underline = True	
                                            if ((i % 2) == 0)
                                            {
                                                ws.Cell(Row + 1, ColStart).Style.Font.FontColor = XLColor.Brown;
                                            }
                                            else
                                            {
                                                ws.Cell(Row + 1, ColStart).Style.Font.FontColor = XLColor.Purple;
                                            }

                                            if (CDbl(strTempVal) == 0)
                                            {
                                                valTmp = 0;
                                            }
                                            else
                                            {
                                                valTmp = 1 - (CDbl(listTotal[i]) / CDbl(strTempVal));
                                            }

                                            ws.Cell(Row + 1, ColStart + 1).Style.NumberFormat.Format = "###,###,##0.000 %";
                                            ws.Cell(Row + 1, ColStart + 1).Value = valTmp;
                                            ws.Cell(Row + 1, ColStart + 1).Style.Font.Bold = true;
                                            ws.Cell(Row + 1, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                                            ws.Cell(Row + 1, ColStart + 1).Style.Font.Underline = XLFontUnderlineValues.Single;//true;
                                            if ((i % 2) == 0)
                                            {
                                                ws.Cell(Row + 1, ColStart + 1).Style.Font.FontColor = XLColor.Brown;
                                            }
                                            else
                                            {
                                                ws.Cell(Row + 1, ColStart + 1).Style.Font.FontColor = XLColor.Purple;
                                            }


                                            Row = Row + 3;

                                        }

                                    }


                                    //' incrementa la colonna per il prossimo fornitore
                                    ColStart = ColStart + 3;

                                }


                            }


                        } while (rsDati.Read());




                    }

                    strCause = "chiude il recordset";

                    rsDati.Close();


                    //'''''''''''''''''''''''''''''''''''''''''''''''''''
                    //' STAMPA DEI TOTALI (fuori ciclo)
                    //'''''''''''''''''''''''''''''''''''''''''''''''''''
                    if (NumForn > 0)
                    {


                        ws.Range(10, ColStart, 11, ColStart + 4).Merge();// = true;
                        ws.Range(10, ColStart, 10, ColStart + 4).Value = "Differenza Migliore Offerta e Miglior Prezzo";
                        ws.Cell(10, ColStart).Style.Font.Bold = true;
                        ws.Cell(10, ColStart).Style.Font.FontSize = 16;
                        ws.Cell(10, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                        ws.Cell(10, ColStart).Style.Alignment.SetVertical(XLAlignmentVerticalValues.Center);
                        ws.Cell(10, ColStart).Style.Font.FontColor = (XLColor.Red);

                        ws.Range(10, ColStart, 11, ColStart + 4).Style.Fill.PatternType = XLFillPatternValues.Solid;//OfficeOpenXml.Style.ExcelFillStyle.Solid; //''ExcelFillStyle.Solid
                        ws.Range(10, ColStart, 11, ColStart + 4).Style.Fill.BackgroundColor = (XLColor.LightGreen);

                        listAumentaColonne.Add(ColStart);
                        listAumentaColonne.Add(ColStart + 2);

                        ws.Cell(12, ColStart).Value = "Miglior Prezzo";
                        ws.Cell(12, ColStart).Style.Font.Bold = true;
                        ws.Cell(12, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                        ws.Range(12, ColStart + 1, 12, ColStart + 3).Merge();// = true;
                        ws.Range(12, ColStart + 1, 12, ColStart + 3).Value = "Differenza tra Migliore Offerta e Miglior Prezzo";
                        ws.Range(12, ColStart + 1, 12, ColStart + 3).Style.Font.Bold = true;
                        ws.Range(12, ColStart + 1, 12, ColStart + 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                        ws.Cell(13, ColStart + 1).Value = "€URO";
                        ws.Cell(13, ColStart + 1).Style.Font.Bold = true;
                        ws.Cell(13, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                        ws.Cell(13, ColStart + 2).Value = "%";
                        ws.Cell(13, ColStart + 2).Style.Font.Bold = true;
                        ws.Cell(13, ColStart + 2).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                        ws.Cell(13, ColStart + 3).Value = "Importo";
                        ws.Cell(13, ColStart + 3).Style.Font.Bold = true;
                        ws.Cell(13, ColStart + 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                        //' imposta i bordi parziali
                        ws.Range(12, ColStart + 1, 12, ColStart + 3).Style.Border.TopBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

                        ws.Range(12, ColStart + 1, 13, ColStart + 1).Style.Border.LeftBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                        ws.Range(12, ColStart + 3, 13, ColStart + 3).Style.Border.RightBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

                        //' imposta i bordi totali
                        Row = RowTot;
                        ws.Range(10, ColStart, 10, ColStart + 4).Style.Border.TopBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                        ws.Range(10, ColStart, Row + EndRows + 6, ColStart).Style.Border.LeftBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                        ws.Range(10, ColStart + 4, Row + EndRows + 6, ColStart + 4).Style.Border.RightBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                        ws.Range(Row + EndRows + 6, ColStart, Row + EndRows + 6, ColStart + 4).Style.Border.BottomBorder = XLBorderStyleValues.Thin;//OfficeOpenXml.Style.ExcelBorderStyle.Thin;

                        //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                        //' select per recuperare il prezzo migliore di ciascun articolo
                        //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
                        strCause = "select per recuperare il prezzo migliore di ciascun articolo";
                        strSQL = "select codart,min(isnull(PrzUnOfferta,0 )) as PrzUnOfferta from View_ProspettoConfronto_Valutazione where id = " + idDoc + " group by codart order by codart";
                        sqlComm = new SqlCommand(strSQL, sqlConn1);
                        rsDati = sqlComm.ExecuteReader();

                        if (rsDati.HasRows)
                        {

                            rsDati.Read();

                            Row = 14;

                            i = 0;
                            TotaleRibasso = 0;

                            //' ciclo sui dati
                            do
                            {

                                //' miglior prezzo
                                ws.Cell(Row, ColStart).Style.NumberFormat.Format = "€ ###,###,##0.00###";
                                ws.Cell(Row, ColStart).Value = CDbl(rsDati["PrzUnOfferta"]);
                                ws.Cell(Row, ColStart).Style.Font.Bold = true;
                                ws.Cell(Row, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                //'Differenza tra Migliore Offerta e Miglior Prezzo in €
                                ws.Cell(Row, ColStart + 1).Style.NumberFormat.Format = "€ ###,###,##0.00###";
                                ws.Cell(Row, ColStart + 1).Value = CDbl(listPrzBestOffer[i]) - CDbl(rsDati["PrzUnOfferta"]);
                                ws.Cell(Row, ColStart + 1).Style.Font.Bold = true;
                                ws.Cell(Row, ColStart + 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                //'Differenza tra Migliore Offerta e Miglior Prezzo in %
                                ws.Cell(Row, ColStart + 2).Style.NumberFormat.Format = "###,###,##0.000 %";

                                if (CDbl(listPrzBestOffer[i]) == 0)
                                {
                                    ws.Cell(Row, ColStart + 2).Value = 0;
                                }
                                else
                                {
                                    ws.Cell(Row, ColStart + 2).Value = CDbl(1 - (CDbl(rsDati["PrzUnOfferta"]) / CDbl(listPrzBestOffer[i])));
                                }

                                ws.Cell(Row, ColStart + 2).Style.Font.Bold = true;
                                ws.Cell(Row, ColStart + 2).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                //' Importo (prodotto tra qty RDO e Differenza tra Migliore Offerta e Miglior Prezzo in €
                                ws.Cell(Row, ColStart + 3).Style.NumberFormat.Format = "€ ###,###,##0.00###";
                                ws.Cell(Row, ColStart + 3).Value = CDbl(listQtRdO[i]) * (CDbl(listPrzBestOffer[i]) - CDbl(rsDati["PrzUnOfferta"]));
                                ws.Cell(Row, ColStart + 3).Style.Font.Bold = true;
                                ws.Cell(Row, ColStart + 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                                //' totale dell'ultima colonna
                                TotaleRibasso = TotaleRibasso + CDbl(listQtRdO[i]) * (CDbl(listPrzBestOffer[i]) - CDbl(rsDati["PrzUnOfferta"]));

                                i = i + 1;
                                Row = Row + 2;

                            } while (rsDati.Read());


                            //' ultimo totale
                            ws.Range(Row, ColStart, Row, ColStart + 2).Merge();// = true;
                            ws.Range(Row, ColStart, Row, ColStart + 2).Value = "Totale Ribasso Miglior Offerta";
                            ws.Cell(Row, ColStart).Style.Font.Bold = true;
                            ws.Cell(Row, ColStart).Style.Font.FontSize = 16;
                            ws.Cell(Row, ColStart).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                            ws.Cell(Row, ColStart).Style.Font.FontColor = XLColor.Red;

                            ws.Range(Row, ColStart, Row, ColStart + 4).Style.Fill.PatternType = XLFillPatternValues.Solid;//OfficeOpenXml.Style.ExcelFillStyle.Solid; //''ExcelFillStyle.Solid
                            ws.Range(Row, ColStart, Row, ColStart + 4).Style.Fill.BackgroundColor = (XLColor.LightGreen);

                            //' TotaleRibasso
                            ws.Cell(Row, ColStart + 3).Style.NumberFormat.Format = "€ ###,###,##0.00###";
                            ws.Cell(Row, ColStart + 3).Value = TotaleRibasso;
                            ws.Cell(Row, ColStart + 3).Style.Font.Bold = true;
                            ws.Cell(Row, ColStart + 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                            ws.Cell(Row, ColStart + 3).Style.Font.FontSize = 16;
                            ws.Cell(Row, ColStart + 3).Style.Font.FontColor = XLColor.Red;

                            //' TotaleRibasso / TotalBestOffer
                            ws.Cell(Row, ColStart + 4).Style.NumberFormat.Format = "% ###,###,##0.000";
                            if (TotalBestOffer != 0)
                            {
                                ws.Cell(Row, ColStart + 4).Value = CDbl(TotaleRibasso / TotalBestOffer);
                            }
                            ws.Cell(Row, ColStart + 4).Style.Font.Bold = true;
                            ws.Cell(Row, ColStart + 4).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                            ws.Cell(Row, ColStart + 4).Style.Font.FontSize = 16;
                            ws.Cell(Row, ColStart + 4).Style.Font.FontColor = XLColor.Red;

                        }

                        rsDati.Close();

                        ColStart = ColStart + 4;

                    }




                    //' imposta il ridimensionamento automatico delle colonne stampate
                    strCause = "imposta il ridimensionamento automatico delle colonne stampate fino a " + CStr(ColStart);


                    //' imposta autofit sulle colonne
                    for (k = 2; k <= ColStart; k++)
                    { //to ColStart

                        try
                        {
                            ws.Column(k).AdjustToContents();
                        }
                        catch (Exception ex2) { }
                    }

                    //' aumenta la lunghezza per le colonne merged dove il testo supera 20 chr.
                    for (i = 0; i <= listAumentaColonne.Count - 1; i++)
                    {//To listAumentaColonne.Count - 1

                        try
                        {

                            ws.Column(CInt(listAumentaColonne[i])).Width = ws.Column(CInt(listAumentaColonne[i])).Width + 10;
                            ws.Column(CInt(listAumentaColonne[i]) + 1).Width = ws.Column(CInt(listAumentaColonne[i]) + 1).Width + 10;
                        }
                        catch (Exception ex3)
                        {

                        }
                    }

                }
                else
                {

                    rsDati.Close();

                    throw new Exception("ID " + idDoc + " nessun dato trovato");

                }

                strCause = "Chiudo i recordset";

                //'rsDati.Close()
                //'rsDati = Nothing

                strCause = "Chiudo le connessioni";
                sqlConn1.Close();
                //'sqlConn2.Close()

                strCause = "Imposto il contentype di output";
                Response.ContentType = "application/XLSX";
                Response.Headers.TryAdd("content-disposition", "attachment; filename=" + Replace(strfilename, " ", "_"));

                strCause = "Porto in output l'xlsx";
                //Response.BinaryWrite(pck.GetAsByteArray());

                string tempPath = $"{CStr(ApplicationCommon.Application["PathFolderAllegati"])}{CommonStorage.GetTempName()}.xlsx";

                pck.SaveAs(tempPath);

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

                //htmlToReturn.BinaryWrite(HttpContext, pck.GetAsByteArray());

                pck.Dispose();

            }
            catch (Exception ex)
            {
                string msgError = "Si è verificato un errore di sistema.<br/>";
                msgError = msgError + "Occorre ripetere l'operazione, nel caso in cui il problema si dovesse ripresentare si può contattare il supporto per avere maggiori informazioni.<br/>";
                msgError = msgError + "Il riferimento é :" + DateAndTime.Now + " - " + strCause + " - " + ex.Message;

                bool isProd =
                    !(ApplicationCommon.Application["debug-mode"].ToLower() == "yes" ||
                    ApplicationCommon.Application["debug-mode"].ToLower() == "si" ||
                    ApplicationCommon.Application["debug-mode"].ToLower() == "true");

                if (isProd)
                {
                    htmlToReturn.Write(msgError);
                }
                else
                {
                    htmlToReturn.Write(strCause + $@" -- " + ex.ToString());
                }


                //'-- Chiudo e riapro la connection 1 per buttare giu i datareader e i comandi lasciati aperti
                sqlConn1.Close();
                sqlConn1.Open();

                traceError(sqlConn1, idpfu, strCause + " -- " + ex.Message, Request.Path);

                if (sqlConn1 != null)
                {
                    sqlConn1.Close();
                }

                //'If Not sqlConn2 Is Nothing Then
                // '   sqlConn2.Close()
                //'End If
            }
        }

        private static void traceError(SqlConnection sqlConn, string idpfu, string descrizione, string querystring)
        {
            string strSQL = "";
            var contesto = "Generazione XLSX";
            string typeTrace = "TRACE-ERROR";

            string sSource;
            string sLog;
            string sEvent;
            string sMachine;

            if (string.IsNullOrEmpty(idpfu))
                idpfu = "-1";

            sEvent = Strings.Left("Errore nella generazione del file XLSX.URL:" + querystring + " --- Descrizione dell'errore : " + descrizione, 4000);

            strSQL = "INSERT INTO CTL_LOG_UTENTE (idpfu,datalog,paginaDiArrivo,querystring,descrizione) " + Environment.NewLine;
            strSQL = strSQL + " VALUES(" + idpfu + ", getdate(), '" + contesto + "', '" + Strings.Replace(typeTrace, "'", "''") + "', '" + Strings.Replace(sEvent, "'", "''") + "')";

            var sqlComm = new SqlCommand(strSQL, sqlConn);
            sqlComm.ExecuteNonQuery();

            WriteToEventLog(sEvent);

        }

        // -- ritorna tre stringhe contenenti separatamente la lista degli attributi, la lista delle condizioni e la lista dei valori
        // -- da passare alla stored per il recupero dati

        public static void validaInput(string nomeParametro, string valoreDaValidare, int tipoDaValidare, string sottoTipoDaValidare, HttpContext HttpContext, string regExp = "")
        {
            Validation objSecurityLib;
            bool isAttacked = false;

            //if (Information.Err.Number != 0)
            //{
            //    htmlToReturn.Write($@"ERRORE DI REGISTRAZIONE NELLA DLL CtlSecurity");
            //    throw new ResponseEndException(htmlToReturn.Out(), Response, "");
            //}

            if (string.IsNullOrEmpty(sottoTipoDaValidare.Trim()))
                sottoTipoDaValidare = CStr(0);

            if (!string.IsNullOrEmpty(valoreDaValidare.Trim()))
            {
                try
                {
                    objSecurityLib = new Validation();//Server.CreateObject("CtlSecurity.Validation");
                }
                catch (Exception ex)
                {
                    return;
                }

                try
                {
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB;", "");
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.1;", "");
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.2;", "");
                    strConnectionString = strConnectionString.Replace("Provider=SQLOLEDB.3;", "");
                }
                catch (Exception ex)
                {
                }

                switch (tipoDaValidare)
                {
                    case TIPO_PARAMETRO_FLOAT:
                    case TIPO_PARAMETRO_INT:
                    case TIPO_PARAMETRO_NUMERO:
                        {
                            if (Information.IsNumeric(valoreDaValidare) == false)
                                isAttacked = true;
                            break;
                        }

                    case TIPO_PARAMETRO_DATA:
                        {
                            if (Information.IsDate(valoreDaValidare) == false)
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
                                        if (objSecurityLib.isValidValue(valoreDaValidare, 1) == false)
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_SORT:
                                    {
                                        if (objSecurityLib.isValidSqlSort(valoreDaValidare, "") == false)
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_FILTROSQL:
                                    {
                                        if (objSecurityLib.isValidFilterSql(valoreDaValidare, "") == false)
                                            isAttacked = true;
                                        break;
                                    }

                                case SOTTO_TIPO_PARAMETRO_LISTANUMERI:
                                    {
                                        if (objSecurityLib.isValidValue(valoreDaValidare, 4) == false)
                                            isAttacked = true;
                                        break;
                                    }
                            }

                            break;
                        }
                }

                objSecurityLib = null;

                if (isAttacked == true)
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

        public static void sendBlock(string paginaAttaccata, string motivo, Microsoft.AspNetCore.Http.HttpContext HttpContext)
        {
            addSecurityBlockTrace(paginaAttaccata, motivo, HttpContext);
            throw new ResponseRedirectException("../blocked.asp", HttpContext.Response);
        }

        public static void addSecurityBlockTrace(string paginaAttaccata, string motivo, HttpContext HttpContext)
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
    }
}

