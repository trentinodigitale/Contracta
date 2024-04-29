using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;


namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class importCSVModel : PageModel
    {
        public void OnGet()
        {
        }

        //'-- *********************************************************************
        //'-- * Versione=1&data=2012-01-23&Attvita=41252&Nominativo=FedericoLeone *
        //'-- *********************************************************************
        //
        //'test: call ReadMatriceFromCsv( "c:\filecsv.csv", ";" )
        //'on error resume next
        //'call ImportCsvInTable( "c:\GaraToner_F007.csv",  "CTL_IMPORT", "", "idpfu", "666", application("connectionstring") )
        //'Response.Write err.Description 
        //
        //
        //'--importa un file CSV in una tabella
        //'-- strPathFile=path file csv
        //'-- strTable=nome tabella in cui importare
        //'-- strParam= nPosFoglio#TypeImport#connectionstringexecel 
        //'--		* dove nPosFoglio � il foglio da importare ( parametro da ignorare )
        //'--     * TypeImport=posizionale indica che le colonne del file csv verranno importate nelle colonne di stessa posizione della tabella
        //'         e TypeImport=nominativo     indica che le colonne del file csv verranno importate nelle colonne della tabella con lo stesso nome
        //'-- strNomeLink=nome colonna discriminante da associare alle righe importate
        //'--	strValueLink=valore del discriminante da salvare per ogni riga importata nella tabella
        public static void ImportCsvInTable(string strPathFile, string strTable, string strParam, string strNomeLink, string strValueLink, string strConnectionString, eProcurementNext.Session.ISession session)
        {
            // on error resume next

            // stop 
            int nRowsLimit;
            string strConn;
            SqlConnection conn = new SqlConnection(strConnectionString);
            conn.Open();

            string strcause = "Effettuo la trace nella ctl_log_utente";
            addTraceLog("INIT metodo ImportExcelInTable", conn, session);
            if (string.IsNullOrEmpty(strParam))
            {
                strParam = "#posizionale#";
            }
            string[] aInfo = strParam.Split("#");
            strcause = "imposto connessione csv" + strPathFile;
            if (aInfo.Length < 2)
            {
                strConn = "bla bla bla";

            }
            else
            {
                strConn = aInfo[2];

            }
            strcause = "Recupero la matrice di dati dal file CSV";
            string[,] matrice = null;
            try
            {
                matrice = ReadMatriceFromCsv(strPathFile, ";");
            }
            catch (Exception ex)
            {
                conn.Close();
                // errNum = err.Number
                string errDesc = ex.Message;
                //on error goto 0
                throw new Exception("ImportCsvInTable," + errDesc + " - " + strcause);
            }


            if (aInfo.Length > 2)
            {
                if (!(string.IsNullOrEmpty(CStr(aInfo[3]))))
                {
                    nRowsLimit = (int)CLng(aInfo[3]);

                }
                else
                {
                    nRowsLimit = (int)CLng(-1);

                }
            }
            else
            {
                nRowsLimit = (int)CLng(-1);

            }
            try
            {
                if (string.Equals(aInfo[1].ToLower(), "posizionale"))
                {

                    addTraceLog("Metodo impostato per import : posizionale", conn, session);
                    strcause = "importposizionale in " + strTable + " - nomelink=" + strNomeLink + " - valorelink=" + strValueLink;
                    importMatricePosizionale(matrice, strTable, conn, strNomeLink, strValueLink, strConn, nRowsLimit, session);

                }
                else
                {

                    addTraceLog("Metodo impostato per import : nominale", conn, session);
                    strcause = "importnominale in " + strTable + " - nomelink=" + strNomeLink + " - valorelink=" + strValueLink;
                    importMatriceNominale(matrice, strTable, conn, strNomeLink, strValueLink, nRowsLimit, session);

                }
            }
            catch (Exception ex)
            {
                addTraceLog("Import della Matrice di dati inserita nella tabella senza errori", conn, session);
                conn.Close();
                //conn = Nothing;
                string errDesc = ex.Message;
                //on error goto 0
                throw new Exception("ImportCsvInTable," + errDesc + " - " + strcause);
            }

            conn.Close();

        }
        public static void ExecSql(string strSql, SqlConnection conn)
        {
            SqlCommand cmd = new SqlCommand(strSql, conn);
            if (conn.State != System.Data.ConnectionState.Open)
            {
                conn.Open();
            }
            cmd.ExecuteNonQuery();
            conn.Close();
        }

        public static string[,] ReadMatriceFromCsv(string strPathFile, string separatore)
        {
            string strCause;
            //'-- variabili per leggere il file

            // string fso;
            // string ts;
            //'-- output
            string[,] matriceOutput = null;
            strCause = "Init delle dimensioni della matrice";
            //'-- inizializzo la matrice in un passo separato per non dover fare N volte redim preserve e rallentare il tutto
            //'-- preferisco leggere 2 volte il file

            matriceOutput = initMatrice(strPathFile, separatore);

            //'-- variabili utili all'estrazione
            bool inUnaStringa = false;// '-- booleana, true se sono in un field
            bool isNewRiga;//    '-- true se dobbiamo inserire una nuova riga in tabella ( non combacia con il newLine del file)
            string strColonna;
            string carattere;
            string strLine;
            int posCorrente;  //'-- carattere appena letto
            int totCaratteriLinea;//'-- len di strLine
            //'  dim separatore	 '-- indica il separatore da utilizzare
            int numeroColonne;
            int nummeroRighe;

            const int ForReading = 1;
            strCause = "Apertura del file " + strPathFile;
            //IEnumerable<string> lines = System.IO.File.ReadLines(fileName);

            //fso = Server.CreateObject("Scripting.FileSystemObject")

            inUnaStringa = false;
            strColonna = "";
            numeroColonne = 0;
            nummeroRighe = 0;
            using (StreamReader ts = System.IO.File.OpenText(strPathFile))
            {
                while ((strLine = ts.ReadLine()) != null)
                {
                    strCause = "Leggo la linea " + nummeroRighe + " dal file CSV";
                    if (nummeroRighe != 0)
                    {
                        //'-- Scrivo strColonna nella matrice
                        matriceOutput[nummeroRighe - 1, numeroColonne - 1] = strColonna;


                    }
                    if (string.IsNullOrEmpty(strLine.Trim()))
                    {
                        //--se non si sta continuando un campo con all'interno un vbcrlf
                        if (inUnaStringa == false)
                        {
                            nummeroRighe = nummeroRighe + 1;
                            numeroColonne = 1;
                            strColonna = "";

                        }
                        else
                        {

                            strColonna = strColonna + System.Environment.NewLine;

                        }
                        posCorrente = 1;
                        totCaratteriLinea = strLine.Length;
                        //'-- scorro la riga
                        do
                        {
                            carattere = eProcurementNext.CommonModule.Basic.MidVb6(strLine, posCorrente, 1);
                            //'-- Se non mi trovo in una stringa
                            if (inUnaStringa == false)
                            {
                                if (carattere == separatore)
                                {
                                    //'-- Scrivo strColonna nella matrice

                                    matriceOutput[nummeroRighe - 1, numeroColonne - 1] = strColonna;
                                    //'-- passo alla colonna successiva!
                                    numeroColonne = numeroColonne + 1;
                                    //'-- resetto strColonna
                                    strColonna = "";

                                }
                                else
                                {
                                    //'-- Se non stavo in una stringa e incontro il carattere " vuol dire che si sta aprendo una stringa
                                    if (string.IsNullOrEmpty(carattere))
                                    {
                                        inUnaStringa = true;

                                    }
                                    else
                                    {
                                        strColonna = strColonna + carattere;
                                        //'-- se 

                                    }

                                }

                            }
                            else
                            {
                                //'-- Se stavo in una stringa e incontro il carattere " vuol dire che si sta chiudendo la stringa

                                //'-- oppure se dopo " c'� un altro " vuol dire che si sta inserendo un " nella colonna
                                if (string.IsNullOrEmpty(carattere) && !(string.Equals(posCorrente, totCaratteriLinea)) && string.IsNullOrEmpty(eProcurementNext.CommonModule.Basic.MidVb6(strLine, posCorrente + 1, 1)))
                                {
                                    strColonna = strColonna + "";
                                    posCorrente = posCorrente + 1;//  '-- salto al carattere dopo il "

                                }
                                else
                                {
                                    if (string.IsNullOrEmpty(carattere))
                                    {
                                        inUnaStringa = false;


                                    }
                                    else
                                    {
                                        // '-- aggiungo il carattere alla stringa, anche se un separatore di colonna			

                                        strColonna = strColonna + carattere;

                                    }
                                }

                            }

                            posCorrente = posCorrente + 1;

                        } while (posCorrente <= totCaratteriLinea);

                    }
                }

                ts.Close();
            }


            matriceOutput[nummeroRighe - 1, numeroColonne - 1] = strColonna;
            return matriceOutput;

        }

        public static string[,] initMatrice(string strPathFile, string separatore)
        {

            string[,] mp_Matrix;
            //'-- variabili per leggere il file
            // fso;
            // ts;
            //'-- output
            string[,] matriceOutput;

            //--variabili utili all'estrazione

            bool inUnaStringa = false; //'-- booleana, true se sono in un field
            bool isNewRiga;  //  '-- true se dobbiamo inserire una nuova riga in tabella ( non combacia con il newLine del file)
            string strColonna;
            string carattere;
            string strLine;
            int posCorrente;//     '-- carattere appena letto
            int totCaratteriLinea;// '-- len di strLine
                                  //'dim separatore	 '-- indica il separatore da utilizzare
            int numeroColonne;
            int nummeroRighe;
            const int ForReading = 1;

            // fso = Server.CreateObject("Scripting.FileSystemObject");
            // ts = fso.OpenTextFile(strPathFile, ForReading, false);
            inUnaStringa = false;
            strColonna = "";
            numeroColonne = 0;
            nummeroRighe = 0;
            string fileName = @"C:\some\path\file.txt";
            using (StreamReader file = new StreamReader(fileName))
            {
                while ((strLine = file.ReadLine()) != null)
                {
                    if (!(string.IsNullOrEmpty(strLine.Trim())))
                    {
                        //'-- se non si sta continuando un campo con all'interno un vbcrlf
                        if (inUnaStringa == false)
                        {
                            nummeroRighe = nummeroRighe + 1;
                            numeroColonne = 1;

                        }
                        posCorrente = 1;
                        totCaratteriLinea = strLine.Length;
                        //'-- scorro la riga
                        do
                        {
                            carattere = eProcurementNext.CommonModule.Basic.MidVb6(strLine, posCorrente, 1);
                            //'-- Se non mi trovo in una stringa
                            if (inUnaStringa == false)
                            {
                                if (carattere == separatore)
                                {
                                    // '-- passo alla colonna successiva!
                                    numeroColonne = numeroColonne + 1;

                                }
                                else
                                {
                                    //'-- Se non stavo in una stringa e incontro il carattere " vuol dire che si sta aprendo una stringa
                                    if (string.IsNullOrEmpty(carattere))
                                    {
                                        inUnaStringa = true;
                                    }
                                }

                            }
                            else
                            {
                                //'-- Se stavo in una stringa e incontro il carattere " vuol dire che si sta chiudendo la stringa
                                //'-- oppure se dopo " c'� un altro " vuol dire che si sta inserendo un " nella colonna
                                if (string.IsNullOrEmpty(carattere) && posCorrente != totCaratteriLinea && string.IsNullOrEmpty(eProcurementNext.CommonModule.Basic.MidVb6(strLine, posCorrente + 1, 1)))
                                {
                                    posCorrente = posCorrente + 1;//-- salto al carattere dopo il "

                                }
                                else
                                {
                                    if (string.IsNullOrEmpty(carattere))
                                    {
                                        inUnaStringa = false;

                                    }


                                }
                                posCorrente = posCorrente + 1;
                            }

                        } while (posCorrente <= totCaratteriLinea);

                    }
                }
                file.Close();
            }

            mp_Matrix = new string[nummeroRighe - 1, numeroColonne - 1];

            return mp_Matrix;

        }

        public static void importMatricePosizionale(string[,] dati, string strTable, SqlConnection conn, string strNomeLink, string strValueLink, string strConn, int rowsLimit, eProcurementNext.Session.ISession session)
        {
            string strcause;
            long col;
            long row;
            long cols;
            long rows;
            long startRow;
            string strSql = "";
            TSRecordSet rsDest = null;

            //'On Error GoTo eh   
            addTraceLog("Sto per fare la delete di vecchi record nella tabella de;gli import", conn, session);
            strcause = "elimino le righe associate al discriminanti " + strNomeLink + "=" + strValueLink;
            ExecSql("delete from " + strTable + " where " + strNomeLink + "='" + strValueLink + "'", conn);

            addTraceLog("delete eseguita correttamente di vecchi record nella tabella degli import", conn, session);
            //'HDR=NO;
            if (strConn.ToUpper().Contains("HDR=NO", StringComparison.Ordinal))
            {
                startRow = 0;
            }
            else
            {
                startRow = 1;
            }
            //'-- se c'� almeno 1 riga di dati

            if (dati[1, 1].Length - 1 > startRow)
            {
                strcause = "inserisco le righe del foglio associate al discriminante " + strNomeLink + "=" + strValueLink;

                const int adUseClient = 3;
                const int adUseServer = 2;

                const int adStateOpen = 1;
                const int adStateClosed = 0;
                const int adStateConnecting = 2;
                const int adStateExecuting = 4;
                const int adStateFetching = 8;

                const int adOpenDynamic = 2;
                const int adOpenForwardOnly = 0;
                const int adOpenKeyset = 1;
                const int adOpenStatic = 3;

                const int adLockBatchOptimistic = 4;
                const int adLockOptimistic = 3;
                const int adLockPessimistic = 2;
                const int adLockReadOnly = 1;


                //rsDest.CursorLocation = adUseClient;
                //rsDest.CursorType = adOpenKeyset;
                //rsDest.LockType = adLockOptimistic;
                //rsDest.ActiveConnection = conn;
                strSql = "select * from " + strTable + " where " + strNomeLink + "='" + strValueLink + "'";
                try
                {
                    rsDest.Open(strSql, ApplicationCommon.Application["ConnectionString"]);
                }
                catch (Exception ex)
                {
                    ExecSql("delete from " + strTable + " where " + strNomeLink + "='" + strValueLink + "'", conn);
                    addTraceLog("ERRORE IMPORT. strCause:" + strcause + ". err.message:" + ex.Message, conn, session);
                    //rsDest = Nothing;
                    string errDesc = ex.Message;
                    //on error goto 0
                    throw new Exception("ImportCsvInTable," + errDesc + " - " + strcause);

                }

                cols = dati[2, 2].Length - 1;
                rows = dati[1, 1].Length - 1;

                //'-- Se � stato passato il rowsLimit e il numero di righe del foglio excel supera questo limite

                if (rowsLimit > 0 && rows > rowsLimit)
                {
                    rows = rowsLimit;
                }
                //'--copio tutte le colonne che nella tabella destinazione sono sfasate di 1 come posizione
                //'  per la presenza della colonna discriminante in 1� posizione
                for (row = startRow; row < rows; row++)
                {
                    // '--aggiungo nuovo record
                    DataRow dr = rsDest.AddNew();
                    string v; //'As Variant
                    //'--colonna discriminante

                    strValueLink = CStr(GetValueFromRS(rsDest.Fields["strNomeLink"]));

                    for (col = 0; col < cols; col++)
                    {
                        //'-- Se il numero di colonne del foglio excel � coerente con il numero di colonne della tabella
                        //'-- di appoggio ok, altrimenti scartiamo le colonne in esubero del foglio excel (l'utente sta passando
                        //'-- un foglio excel non corretto o modificato rispetto alla struttura che gli abbiamo inviato)
                        if (rsDest._Fields.Count >= (col + 2))
                        {
                            v = dati[row, col];
                            strcause = "valorizzo colonnna " + CStr(GetValueFromRS(rsDest._Fields[(int)col + 1])) + " con valore=" + CStr(v);
                            if (!(IsEmpty(v)))
                            {
                                rsDest.Fields[(int)col + 2] = v;
                            }
                            else
                            {
                                return;
                            }
                        }
                    }
                    //stop
                    //'--rendo i dati persistenti
                    try
                    {
                        rsDest.Update(dr, strValueLink, strTable);
                    }
                    catch (Exception e)
                    {
                        ExecSql("delete from " + strTable + " where " + strNomeLink + "='" + strValueLink + "'", conn);
                        addTraceLog("ERRORE IMPORT. strCause:" + strcause + ". err.message:" + e.Message, conn, session);
                        string errDesc = e.Message;
                        //on error goto 0
                        throw new Exception("ImportCsvInTable," + errDesc + " - " + strcause);
                    }

                }


            }
            else
            {
                // on error goto 0


                throw new Exception("-1" + "ImportCsvInTable" + "Il file non contiene righe dati");

            }
            try
            {
                addTraceLog("Record scritti correttamente sulla tab di import", conn, session);
                //rsDest.Close;
                //Set rsDest = Nothing
            }
            catch (Exception e)
            {
                ExecSql("delete from " + strTable + " where " + strNomeLink + "='" + strValueLink + "'", conn);
                addTraceLog("ERRORE IMPORT. strCause:" + strcause + ". err.message:" + e.Message, conn, session);
                //rsDest = Nothing
                //errNum = err.Number
                string errDesc = e.Message;
                // on error goto 0
                throw new Exception("ImportCsvInTable" + errDesc + " - " + strcause);
            }

        }
        //'-- METODO DA TESTARE.
        public static void importMatriceNominale(string[,] dati, string strTable, SqlConnection conn, string strNomeLink, string strValueLink, int rowsLimit, eProcurementNext.Session.ISession session)
        {
            addTraceLog("ERRORE IMPORT. Metodo importMatriceNominale non supportato da importCSV", conn, session);
            ApplicationCommon.CNV("METODO importMatriceNominale NON SUPPORTATO");

        }

        public static void SetRsWrite(TSRecordSet rs, SqlConnection cn)
        {
            const int adUseClient = 3;
            const int adUseServer = 2;

            const int adStateOpen = 1;
            const int adStateClosed = 0;
            const int adStateConnecting = 2;
            const int adStateExecuting = 4;
            const int adStateFetching = 8;

            const int adOpenDynamic = 2;
            const int adOpenForwardOnly = 0;
            const int adOpenKeyset = 1;
            const int adOpenStatic = 3;

            const int adLockBatchOptimistic = 4;
            const int adLockOptimistic = 3;
            const int adLockPessimistic = 2;
            const int adLockReadOnly = 1;

            if (rs != null)
            {
                rs = null;
            }
            else
            {



            }

            //rs.CursorLocation = adUseClient
            //rs.CursorType = adOpenKeyset
            //rs.LockType = adLockOptimistic
            //rs.ActiveConnection = cn;

        }
        public static void addTraceLog(string msg, SqlConnection conn, eProcurementNext.Session.ISession session)
        {

            string idpfu = CStr(session[eProcurementNext.Session.SessionProperty.IdPfu]);

            if (string.IsNullOrEmpty(idpfu))
            {
                idpfu = "NULL";
            }
            ExecSql("INSERT INTO CTL_LOG_UTENTE(idpfu, form,browserUsato) VALUES ( " + idpfu + ", '" + msg.Replace("'", "''") + "','import-excel')", conn);
        }

    }
}

