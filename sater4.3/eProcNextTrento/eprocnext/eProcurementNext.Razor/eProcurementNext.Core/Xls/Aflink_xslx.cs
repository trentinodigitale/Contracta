using ClosedXML.Excel;
using eProcurementNext.Core.Storage;
using eProcurementNext.HTML;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using eProcurementNext.CommonDB;
using System.Data.SqlClient;
using eProcurementNext.Application;

namespace eProcurementNext.Xls
{
    public class Aflink_xslx
    {
        //'- La funzione che verrà invocata deve avere tutti i parametri e il valore di ritorno come tipo String

        public string import_xlsx_intable_posizionale(string file, string table, string strNomeLink, string strValueLink, string strParams, string connectionString)
        {
            string import_xlsx_intable_posizionaleRet = string.Empty;
            CommonDbFunctions cdf = new CommonDbFunctions();

            string strcause = "";
            int startRow = 0;
            var db = new Database(connectionString);
            int i;
            bool multiSheet = false;

            SqlConnection? cnLocal = null;
            SqlTransaction? trans = null;

            if (!CommonStorage.FileExists(file))
            {
                return $"Il file {file} non esiste";
            }
            try
            {

                if(connectionString ==  null)
                {
                    connectionString = ApplicationCommon.Application.ConnectionString;
                }

                cnLocal = cdf.SetConnection(connectionString);
                cnLocal.Open();

                trans = cnLocal.BeginTransaction();

                if (strParams.ToUpper().Contains("MULTISHEET=YES"))
                {
                    multiSheet = true;
                }

                strNomeLink = Replace(strNomeLink, " ", "");
                table = Replace(table, " ", "");

                string strSql = "";

                System.Text.StringBuilder sb = new System.Text.StringBuilder();

                strcause = "elimino le righe associate al discriminanti " + strNomeLink + "=" + strValueLink;

                sb.Append($"delete from {table} where {strNomeLink} = '{Strings.Replace(strValueLink, "'", "''")}';");

                cdf.ExecuteWithTransaction(sb.ToString(),connectionString,cnLocal, trans);


                strcause = "Compongo la select fittizia sulla tabella di destinazione per averne i metadati ";
                strSql = $"select * from {table} where {strNomeLink} = '-10000'";

                
                strcause = $"eseguo la select per ottenere i metadati della tabella: {strSql}";

                TSRecordSet rs = new();

                rs = cdf.GetRSReadFromQueryWithTransaction(strSql,connectionString,cnLocal, trans);
                //'Dim metaDati As DataTable
                string strSqlInsertBase;
                int totColRecordset;

                int totColInInsert = 0;

                strcause = "Inizio a comporre la INSERT";
                strSqlInsertBase = $"INSERT INTO {table} ({strNomeLink},";

                //totColRecordset = reader.FieldCount;
                totColRecordset = rs.Columns.Count;

                //'-- La prima colonna � la chiave primaria, la seconda � la colonna
                //'-- che chiave dell'import e quindi partiamo dalla terza
                string col;
                for (i = 2; i < totColRecordset; i++)
                {
                    //col = "[" + reader.GetName(i) + "]";

                    col = "[" + rs.Columns[i].ColumnName + "]";

                    strcause = "aggiungo alla insert la colonna " + col;
                    strSqlInsertBase = strSqlInsertBase + col;

                    totColInInsert = totColInInsert + 1;

                    //'-- se � stata richiesta un importazione multi foglio e non siamo sul primo foglio, aggiungiamo un record di demarcazione
                    if (i != totColRecordset - 1)
                    {
                        strSqlInsertBase = strSqlInsertBase + ",";
                    }

                }

                //strcause = "Effettuo la Close del recordset";
                //reader.Close();

                strSqlInsertBase = strSqlInsertBase + ") VALUES( '" + Strings.Replace(strValueLink, "'", "''") + "',";

                // HDR=NO;
                if (strParams.ToUpper().Contains("HDR=NO"))
                {
                    startRow = 0;
                }
                else
                {
                    startRow = 1;
                }

                strcause = "Apro il file XLSX";

                var wb = new XLWorkbook(file);

                IXLWorksheet ws;

                int numSheet = -1;

                strcause = "Recupero il foglio di lavoro";

                // Dim ws As Net.SourceForge.Koogra.Excel2007.Worksheet = wb.GetWorksheet(0)
                int xx;
                //uint r;
                //uint c;
                int r;
                int c;
                object value;
                IXLRow row1;
                foreach (IXLWorksheet currentWs in wb.Worksheets)
                {
                    ws = currentWs;

                    numSheet = numSheet + 1;

                    //'-- se è stata richiesta un importazione multi foglio e non siamo sul primo foglio, aggiungiamo un record di demarcazione
                    if (multiSheet & numSheet > 0)
                    {
                        string strMarkSqlDiRiga = strSqlInsertBase;

                        strcause = "Compongo la insert per il record di demarcazione tra i fogli di lavoro";
                        for (xx = 0; xx < totColInInsert; xx++)
                        {

                            string strVal = "###NEW_SHEET###" + numSheet.ToString() + "###" + ws.Name;
                            strMarkSqlDiRiga = strMarkSqlDiRiga + "N'" + Strings.Replace(strVal, "'", "''") + "'";
                            strMarkSqlDiRiga = strMarkSqlDiRiga + ",";

                        }

                        strMarkSqlDiRiga = Strings.Left(strMarkSqlDiRiga, Len(strMarkSqlDiRiga) - 1);
                        strMarkSqlDiRiga = strMarkSqlDiRiga + ")";

                        strcause = "sto per eseguire la query di insert " + strMarkSqlDiRiga;
                        //db.executeQuery(strMarkSqlDiRiga);

                        cdf.ExecuteWithTransaction(strMarkSqlDiRiga, connectionString, cnLocal, trans);

                    }

                    strcause = "Lavoro il foglio di lavoro " + numSheet.ToString();

                    if (ws.LastRowUsed().RowNumber() >= startRow)
                    {

                        strcause = "Entro nell'IF ws.CellMap.LastRow >= startRow";

                        var lastRow = ws.LastRowUsed().RowNumber();
                        //for (r = (uint)startRow; r <= lastRow; r++)
                        try
                        {
                            for (r = startRow; r <= lastRow; r++)
                            {
                                string strSqlDiRiga = strSqlInsertBase;

                                strcause = "Recupero la riga " + r;

                                //row1 = ws.Row((int)r);
                                row1 = ws.Row(r);

                                // For c = ws.CellMap.FirstCol To ws.CellMap.LastCol Step 1
                                for (c = 1; c <= totColInInsert; c++)
                                {

                                    //'-- Se il numero di colonne del foglio excel è coerente con il numero di colonne della tabella
                                    //'-- di appoggio ok, altrimenti scartiamo le colonne in esubero del foglio excel (l'utente sta passando
                                    //'-- un foglio excel non corretto o modificato rispetto alla struttura che ci aspettiamo)
                                    //'If totColRecordset >= (c + 2) Then

                                    strcause = "Recupero il valore della riga " + r + " e della colonnna " + c;

                                    // -- prendo il valore 'grezzo' della colonna
                                    //'-- le date vengono recuperate nel loro valore tecnico. quindi
                                    //'-- una data del tipo 12/11/2014 sarà recuperate come un numero.
                                    //'-- calcato come giorni dal primo gennaio 1900.
                                    //'-- vedi http://office.microsoft.com/it-it/excel-help/cambiare-il-sistema-di-data-il-formato-delle-date-o-la-modalita-di-interpretazione-degli-anni-a-due-cifre-HP010054141.aspx

                                    //value = row1.Cell((int)c).Value;

                                    string tipo = row1.Cell(c).DataType.ToString();

                                    value = row1.Cell(c).Value;

                                    if (value is null)
                                    {
                                        value = "";
                                    }

                                    strcause = "Inserisco il valore " + value + " nella query di insert ";

                                    string strValue = string.Empty;

                                    //if (Xls.Basic.IsNumber(value) && (double)value == 0)
                                    if (IsNumeric(value) && (double)value == 0)      // cast a double per verificare se = a 0 ???
                                    {
                                        //strValue = row1.Cell((int)c).GetFormattedString();
                                        strValue = row1.Cell(c).GetFormattedString();
                                    }
                                    else
                                    {
                                        strValue = ValueToString(value);
                                    }

                                    //strValue = row1.Cell((int)c).GetFormattedString();
                                    //if (Xls.Basic.IsNumber(value) && (double)value != 0)
                                    //{
                                    //    strValue = strValue.Replace(",", "");
                                    //}

                                    strSqlDiRiga = strSqlDiRiga + "N'" + Strings.Replace(strValue, "'", "''") + "'";
                                    //strSqlDiRiga = strSqlDiRiga + "N'" + Strings.Replace(EprocNext.Xls.Basic.ValueToString(value), "'", "''") + "'";

                                    strSqlDiRiga = strSqlDiRiga + ",";

                                    //'-- Se non è l'ultima colonna 
                                    //'If c <> ws.CellMap.LastCol Then
                                    //'strSqlDiRiga = strSqlDiRiga & ","
                                    //'End If

                                    // End If

                                }


                                strSqlDiRiga = Strings.Left(strSqlDiRiga, Strings.Len(strSqlDiRiga) - 1);


                                //'If ws.CellMap.LastCol < (totColRecordset - 2) Then
                                //'For c = (ws.CellMap.LastCol + 1) To (totColRecordset - 3)
                                //'strSqlDiRiga = strSqlDiRiga & ",NULL"
                                //'Next
                                //'End If

                                strSqlDiRiga = strSqlDiRiga + ")";

                                strcause = "sto per eseguire la query di insert " + strSqlDiRiga;

                                cdf.ExecuteWithTransaction(strSqlDiRiga, connectionString, cnLocal, trans);

                                //db.executeQuery(strSqlDiRiga);

                            }
                        }
                        catch (Exception ex)
                        {

                        }

                    }

                    if (multiSheet == false)
                    {
                        break;
                    }

                }

                wb = default;
                ws = default;

                //}

                strcause = "Eseguo il commit della transazione";
                //db.commit();
                trans.Commit();

                import_xlsx_intable_posizionaleRet = "1#Tutto ok";
            }

            catch (Exception ex)
            {

                //db.rollback();
                trans.Rollback();
                import_xlsx_intable_posizionaleRet = "0#ERR:" + ex.Message + "..StrCause:" + strcause;

                // Console.WriteLine(import_xlsx_intable_posizionale)

            }

            cnLocal.Close();

            return import_xlsx_intable_posizionaleRet;
        }

        public string import_xlsx_intable_nominale(string file, string table, string strNomeLink, string strValueLink, string strParams, string connectionString)
        {
            string import_xlsx_intable_nominaleRet = String.Empty;
            return import_xlsx_intable_nominaleRet;
        }

        public Aflink_xslx()
        {

        }

    }
}