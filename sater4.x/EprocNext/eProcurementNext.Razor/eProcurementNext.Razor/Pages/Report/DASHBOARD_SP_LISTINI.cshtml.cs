using ClosedXML.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Security;
//using Microsoft.VisualBasic;
using System.Collections.Specialized;
//using System.Data.SqlClient;
//using System.Text.RegularExpressions;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
//using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.securityModel;
using static eProcurementNext.Razor.Pages.CTL_LIBRARY.functions.DocumentPermissionModel;
using FileAccess = System.IO.FileAccess;
//using DocumentFormat.OpenXml.InkML;
//using MongoDB.Bson;
//using DocumentFormat.OpenXml.Spreadsheet;
using System.Collections;
//using DocumentFormat.OpenXml.Bibliography;
//using StackExchange.Redis;
//using System.Runtime.InteropServices.ObjectiveC;
//using eProcurementNext.HTML;
//using System.Drawing;
//using DocumentFormat.OpenXml.EMMA;
//using DocumentFormat.OpenXml.Wordprocessing;
//using Chilkat;

namespace eProcurementNext.Razor.Pages.Report
{
    public class DASHBOARD_SP_LISTINIModel
    {

        public DASHBOARD_SP_LISTINIModel()
        {
        }
        public void OnGet()
        {
        }


        private int mp_idpfu = -20;
        private string mp_sessionID = "";

        private string strConnectionString = ApplicationCommon.Application.ConnectionString;
        
            

		private string paginaChiamata = "Report/DASHBOARD_SP_LISTINI.aspx";

        //private string lngSuffix = "I";
        
        //private string strPermission = "";

        private string strMotivoBlocco;

        //private string MODEL = "";
        private string ufp = "";
        //private string GENERAFOGLIODOMINI;

        private CommonDbFunctions cdf = new();

        private eProcurementNext.Session.ISession session;

        private TSRecordSet? rsDati;
        private TSRecordSet? rsTestata;
		private TSRecordSet? rsRighe;

		public void Page_Load(HttpContext HttpContext, EprocResponse htmlToReturn, eProcurementNext.Session.ISession _session)
        {
            
            Microsoft.AspNetCore.Http.HttpResponse Response = HttpContext.Response;
			Microsoft.AspNetCore.Http.HttpRequest Request = HttpContext.Request;

            session = _session;

            var strQueryString = Request.QueryString.ToString();

			var filter = GetParamURL(strQueryString, "FILTER");

            var debug = GetParamURL(strQueryString, "DEBUG");

            
            var guid = GetParamURL(strQueryString, "acckey");  // --access key tramite guid

            

            int indCol = 0;
            int indRow = 0;
            string strCause = "";
            string strSQL = "";
            string strSQLExec = "";
            string strfilename = GetParamURL(strQueryString, "TitoloFile");
            //SqlConnection sqlConn1 = null
            //SqlConnection? sqlConn2 = null;

            bool inoutput = true;
            string pathFile = "";

            
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
				validaInput("FILTER", filter, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_FILTROSQL), HttpContext);
                validaInput("TitoloFile", strfilename, TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);
				validaInput("acckey", guid.Replace("-", "") ?? "", TIPO_PARAMETRO_STRING, CStr(SOTTO_TIPO_PARAMETRO_TABLE), HttpContext);

                //setto il file name del foglio excel xlsx
				if (string.IsNullOrEmpty(strfilename))
				{
					strfilename = "listini";
					
				}

				strfilename = strfilename + ".xlsx";

				strfilename = strfilename.Replace("..", "").Replace("/", "").Replace(@"\", ""); // -- replace per evitare Path Traversal

				
                string motivo = string.Empty;
                string strSQLwhereStored = string.Empty;

                
                if (!string.IsNullOrEmpty(guid))
                {

                    getIdpfuFromGuid(guid);

                    if ( mp_idpfu < 0 )
                    {

                        motivo = "ermesso di accesso negato al download XLSX dei listini. Idpfu non valido";
                        sendBlock(paginaChiamata, motivo, HttpContext);

                    }

                }
                else
                {
                    //'-- se non sto passando da una chiamata con access guid e mp_idpfu è -20 e tra i parametri ho UFP, uso momentaneamente il valore di ufp per effettuare un test
                    //'--		di accesso al documento tramite le stored di permesso e poi torno a rimettere la variabile mp_idpfu a -20 ( per non rischiare di creare una falla usando l'idpfu passato come parametro per altri scopi )
                    motivo = "Permesso di accesso negato al download XLSX dei listini. Guid vuoto";
                    sendBlock(paginaChiamata, motivo, HttpContext);
                }

                // -----------------------------
                // --- FINE SICUREZZA. ---------
                // -----------------------------


                // ------------------------------------
                // --- APRO LA CONNESSIONE CON IL DB --
                // ------------------------------------

                logDB("Inizio elaborazione. Superati i controlli di sicurezza", false, HttpContext);

                //sqlConn2 = cdf.SetConnection(strConnectionString);
                //sqlConn2.Open();

 
                //sqlComm = new SqlCommand(strSQL, sqlConn1)
                //// Dim rsDati As TSRecordSet = sqlComm.ExecuteReader()

                //sqlComm.CommandTimeout = 180;

                //rsDati = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, lTime: 180); // sqlComm.ExecuteReader()

                Dictionary<string,object?> paramS = new();
                paramS.Add("@mp_idpfu", CStr(mp_idpfu));
                paramS.Add("@filter", filter);

                // -- compongo la select per recuperare le colonne da inserire nel foglio di lavoro
                strCause = "Eseguo la select per il recupero dei modelli per calcolare le colonne";
                strSQL = $"exec DASHBOARD_SP_LISTINI_SUB @mp_idpfu , 'MODELLI', @filter,'','',0,0 ";
				rsTestata = cdf.GetRSReadFromQuery_(strSQL, strConnectionString,paramS);  //sqlComm2.ExecuteReader()
                

                string strVisualValue = "";
                int dztType = 0;
                string strFormat = "";

                // ------------------------------------
                // ------- INIZIALIZZO L'XSLX ---------
                // ------------------------------------

                strCause = "Inizializzo excelpackage";
                XLWorkbook wb;

                wb = new XLWorkbook();

               
                strCause = "Aggiungo il foglio di lavoro Listini";

				// Aggiugo lo sheet 'Listini'
				IXLWorksheet ws;
                ws = wb.Worksheets.Add("Listini");

                //ws.View.ShowGridLines = true // mostro la griglia
                ws.PageSetup.ShowGridlines = true;

                // --------------------------------------
                // -- CASO D'USO CON MODELLO DI OUTPUT --
                // --------------------------------------

                string listaColonne = "id,StatoRiga,NumeroLotto,Voce,Cig,Subordinato,ArticoliPrimari,TipoAcquisto,NumeroRiga,Erosione";
                string listaColonneType = "";
                string listaColonneFormat = "";
                int m = 0;

                //Dim attributiDominio As New ArrayList()
                //Dim attributiFissi As New ArrayList()
                //StringDictionary attributiFormat = new StringDictionary();

				Dictionary<string, string> attributiFormat = new();
				ArrayList attributiDominio = new ArrayList();
				ArrayList attributiFissi = new ArrayList();

                attributiFissi.Add("numeroConvenzioneCompleta");
                attributiFissi.Add("rspic");
                attributiFissi.Add("Macro_Convenzione");
                attributiFissi.Add("ragioneSociale");
                attributiFissi.Add("codiceFiscale");
                attributiFissi.Add("DataDecorrenza");


				// --------------------------------------------------
				// -- CICLO SULLE COLONNE PER GENERARE LA TESTATA --
				// --------------------------------------------------

				//if (rsColonne.Read())
				if (rsTestata is not null && rsTestata.RecordCount > 0)
                {

					string attributo  = "";
                    string descrizione   = "";
                    int  dominio  = 0;
					string attributoSQL = "";

                    //
                    //StringDictionary attributi = new StringDictionary();
                    Dictionary<string, string> attributi = new();
					//-- Aggiungo gli attributi 'fissi' di testata

					//Dim attributiFormat As New Dictionary(Of String, String)

					attributi.Add("numeroConvenzioneCompleta", "Numero Convenzione completa");
			        attributi.Add("rspic", "Numero Repertorio Speciale IC");
					attributi.Add("Macro_Convenzione", "Macro Convenzione");
					attributi.Add("ragioneSociale", "Ragione Sociale");
					attributi.Add("codiceFiscale", "Codice Fiscale");
					attributi.Add("StatoRiga", "Stato Riga");
					attributi.Add("DataDecorrenza", "Data Decorrenza");
					attributi.Add("Subordinato", "Subordinato");
					attributi.Add("ArticoliPrimari", "Articoli Primari");
					attributi.Add("TipoAcquisto", "Tipo Acquisto");
					attributi.Add("NumeroRiga", "Numero Riga");
					attributi.Add("NumeroLotto", "NumeroLotto");
					attributi.Add("Voce", "Voce");
					attributi.Add("Cig", "CODICE CIG");
					attributi.Add("Erosione", "Erosione");

					

					rsTestata.MoveFirst();
                    do
                    {

                        Dictionary<string, object?> paramsSql = new();
                        paramsSql.Add("@idModello", rsTestata["idModello"]);

						//-- Primo ciclo sulle convenzioni per recuperarmi l'insieme univoco di tutti i modelli utilizzati

						strSQL = "select * from XLSX_MODELLI_ESPORTA_LISTINI_VIEW where idheader = @idModello order by riga";
                        strCause = "Eseguo la query " + strSQL;

						rsRighe = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, paramsSql);
						if (rsRighe is not null && rsRighe.RecordCount > 0)
						{
                            rsRighe.MoveFirst(); 
							do
						    {
                                descrizione = rsRighe["descrizione"]!.ToString()!;
                                dominio = (int)rsRighe["dominio"]!; //'-- 1 se l'attributo è un dominio 0 altrimenti
                                attributo = rsRighe["attributo"]!.ToString()!;

                                if ( dominio == 1 )
								{
                                    attributoSQL = "dbo.GetDescsValuesFromDztDom ('" + attributo + "', [" + attributo + "],'I') as [" + attributo + "]";

								}
                                else
								{
									attributoSQL = "[" + attributo + "]";
								}

								//'-- Se l'attributo è nuovo lo aggiungo e basta.Altrimenti vado a vedere se la descrizione è cambiata. in questo caso
                                //'-- concateno la nuova descrizione alla vecchia, altrimenti non faccio niente
                                if ( ! attributi.ContainsKey (attributo) )
								{

									attributi.Add(attributo , descrizione);
                                    listaColonne = listaColonne + "," + attributoSQL;

									if ( dominio == 1 )
									{
                                       attributiDominio.Add(attributo);

								    }

								}
                                else
								{
                                    String DescTemp = attributi[attributo];

									//if  (DescTemp.ToLower() != descrizione.ToLower() )
                                    if ( ! DescTemp.ToLower().Contains (descrizione.ToLower()) )
                                    {

                                        attributi[attributo] = attributi[attributo] + "/" + descrizione;
									}

							    }


								//'--costruisco mappa per la format per ogni attributo

								try
								{
                                    attributiFormat.Add(attributo, rsRighe["DZT_Type"]+ "@@@" + rsRighe["dzt_dec"] + "@@@" + rsRighe["DZT_Format"]);
							    }
								catch
								{

								}


								rsRighe.MoveNext();
							}
							while (!rsRighe.EOF);

						}

					    rsTestata.MoveNext();
                    }
                    while (!rsTestata.EOF);




					//'--------------------------------------------------
					//'-- Una volta composta la collection univoca di attributi utilizzati tra gli N modelli vado a disegnare le caption 
					//'-- per le colonne del foglio excel
					//'--------------------------------------------------
					//'-- CICLO SULLE COLONNE PER GENERARE LA TESTATA --

					//'--------------------------------------------------
					//KeyValuePair<string, string> colonna = new();

                    indCol = 1;
                    string strInfoFormat;
					string[] ainfo;
                    

					foreach (KeyValuePair<string, string>  colonna in attributi)
                    {

                        strCause = "Disegno la testata. Lavoro la colonna " + colonna.Key;
                        ws.Cell(1, indCol).Value = colonna.Value;
						ws.Cell(1, indCol).Style.Font.Bold = true;
						ws.Cell(1, indCol).Style.Protection.SetLocked(true);
						ws.Column(indCol).AdjustToContents();

						strCause = "Disegno la testata. recupero la format della colonna \"" + colonna.Key + "\"" ;

						strInfoFormat = "";

                        if ( attributiFormat.ContainsKey (colonna.Key) )
						{
                            strInfoFormat = attributiFormat[colonna.Key];
							ainfo = strInfoFormat.Split("@@@");
                            dztType = CInt(ainfo[0]);
                            strFormat = ainfo[2];

						}


						// se è una data e non ha una format specifica ne applico una di default
						if ( dztType == 6 && strFormat == "" )
						{
                            strFormat = "dd/mm/yyyy";
						}

						switch (dztType)
						{
                            case 2:
                            case 6:
                            case 7:
								{
                                    strFormat = strFormat.Replace("~", "");
									break;
								}

							default:
								{
									// String
									strFormat = "@";
									break;
								}
						}


						//tratto il campo fisso DataDecorrenza come data
						if (colonna.Key == "DataDecorrenza" )
						{
							strFormat = "dd/mm/yyyy";
						}

						ws.Column(indCol).Style.NumberFormat.SetFormat(strFormat);

                        indCol = indCol + 1;
					}



					//'--------------------------------------------------
					//'-- Secondo ciclo sulle convenzioni per recuperare i dati
					//'--------------------------------------------------
					//'-- CICLO SULLE RIGHE DEI PRODOTTI  --
					//'--------------------------------------------------

                    int riga = 2;
                    int idRow = 0;

                    int posCol;
                    string typeCol;
					object strTempVal;


					strCause = "Eseguo la select per il recupero delle convenzioni";

					Dictionary<string, object?> paramD = new();
					paramD.Add("@mp_idpfu", CStr(mp_idpfu));
					paramD.Add("@filter", filter);

					
					strCause = "Eseguo la select per il recupero dei dati";
					strSQL = $"exec DASHBOARD_SP_LISTINI_SUB @mp_idpfu , '', @filter,'','',0,0";
					rsDati = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, paramS);  //sqlComm2.ExecuteReader()

					if (rsDati is not null && rsDati.RecordCount > 0)
					{
                        rsDati.MoveFirst(); 
						do
						{

                            idRow = CInt(rsDati["idRow"]);

							Dictionary<string, object?> paramRow = new();
							//paramRow.Add("@listacolonne", listaColonne );
							paramRow.Add("@idrow", idRow);

							//'-- Itero sulle convenzioni e per ognuna recupero tutti i prodotti
							strSQL = $"select " + listaColonne + " from document_microlotti_dettagli with(nolock) where tipoDoc = 'CONVENZIONE' and id =@idrow ";
							rsRighe = cdf.GetRSReadFromQuery_(strSQL, strConnectionString, paramRow);  //sqlComm2.ExecuteReader()


							if (rsRighe is not null && rsRighe.RecordCount > 0)
							{
								do
								{
                                    indCol = 1;

									//'-- Visualizzo soltanto le colonne dei prodotti riportate negli N modelli lavorati prima.

									foreach (KeyValuePair<string, string> colonna in attributi)
									{

										strCause = "Disegno la riga " + CStr(riga) + " colonna " + colonna.Key ;

                                        if ( colonna.Key == "StatoRiga" )
										{

                                            if ( rsRighe["StatoRiga"] == "Saved" )
											{
                                                ws.Cell(riga, indCol).Value = "";
											}
                                            else
											{
                                                ws.Cell(riga, indCol).Value = rsRighe["StatoRiga"];
											}
										}
                                        else
										{
											//'-- Se mi trovo su un attributo fisso lo prendo dal recordset di testata. altrimenti dalle righe
                                            if ( attributiFissi.Contains(colonna.Key) )
											{
												ws.Cell(riga, indCol).Value = rsDati[colonna.Key];
											}
                                            else
											{
                                                //'--per attributi numerici, se il tipo della colonna non è coerente con il dizionario lo trasformo in numerico
                                                posCol = -1;
                                                posCol = rsRighe.Columns[colonna.Key].Ordinal;
												typeCol = rsRighe.Columns[posCol].DataType.Name;
                                               
                                                strInfoFormat = "";
                                                dztType = 0;
                                                strFormat = "";

												if (attributiFormat.ContainsValue(colonna.Key))
												{
													strInfoFormat = attributiFormat[colonna.Key];
													ainfo = strInfoFormat.Split("@@@");
													dztType = CInt(ainfo[0]);
													strFormat = ainfo[2];

												}


                                                strTempVal = "";
                                                strTempVal = rsRighe[colonna.Key];

                                                if (CStr(dztType) == "2" &&  typeCol != "INT32" &&  typeCol != "DOUBLE" )
												{
													strTempVal = "";
													strTempVal = CStr(rsDati[colonna.Key]);
													strCause = "typeCol=" + typeCol + " converto " + strTempVal + " da stringa in double tipo dizionario = " + CStr(dztType);
													
                                                    if (CStr(0.5).Contains(","))
													{
														strTempVal = CStr(strTempVal).Replace(".", ",");
													}


													if (!string.IsNullOrEmpty(CStr(strTempVal)))
														ws.Cell(riga, indCol).Value = CDbl(strTempVal);


												}
                                                else
												{



													if ( CStr(dztType) == "6" && strFormat == "" )
													{
														strFormat = "dd/MM/yyyy";

													}

                                                    if ( CStr(dztType) == "6" ) 
													    strTempVal = DateTime.Parse( CStr(strTempVal)) .ToString(strFormat);

													ws.Cell(riga, indCol).Value = strTempVal ; 

												}

                                                
											}
										}


                                        indCol = indCol + 1;

									}


									rsRighe.MoveNext();

									riga = riga + 1;

								}
							    while (!rsRighe.EOF) ;

							
							}

							rsDati.MoveNext();

						}
						while (!rsDati.EOF);

					}

				}
				else
				{
                    throw new Exception(strCause + "Metadati per le colonne mancanti");
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


                    wb.SaveAs(pathFile, new SaveOptions
                    {
                        ValidatePackage = false,
                        EvaluateFormulasBeforeSaving = false,
                        GenerateCalculationChain = true,
                        ConsolidateDataValidationRanges = false
                    });

                wb.Dispose();


            }
            catch (Exception ex) when (ex is not EprocNextException)
            {
                traceError(strCause + " -- " + ex.ToString(), strQueryString);
                throw new Exception($"Errore generazione XLSX, {strCause} - {ex.Message}", ex);
            }
            finally
            {
                

               
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

        /*
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
        */

        /*
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
        */

		/*
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
        */

        /*
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
        */

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

        /*
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
        */
        /*
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
        */

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
           
            mp_idpfu = session["idpfu"];//rs.Fields["idpfu"];
            mp_sessionID = session.SessionID;// rs.Fields["sessionid"];
                                             //}

           
        }

        /*
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
        */
        /*
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
                    string test = "test";
                    strcondition = Trim(CStr(rsAttributi["Condition"]));
                    FType = CInt(rsAttributi["DZT_Type"]);

                    int dzt_multivalue = CInt(rsAttributi["DZT_MultiValue"]);
                    //bool dzt_format = InStr(1, CStr(rsAttributi["DZT_Format"]), "M") > 0;
                    bool dzt_format = CStr(rsAttributi["DZT_Format"]).ToUpper().Contains("M");

                    // -- Se � un dominio normale, esteso o gerarchico ed � multivalue
                    //if ((FType == 4 || FType == 5 || FType == 8) && (CInt(rsAttributi["DZT_MultiValue"]) == 1 || InStr(1, CStr(rsAttributi["DZT_Format"]), "M") > 0))
                    if ((FType == 4 || FType == 5 || FType == 8) && (dzt_multivalue == 1 || dzt_format))
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

        */

        /*
        public string StripTags(string html)
        {

            // Remove HTML tags.

            string replacementstring = "";
            string matchpattern = @"<(?:[^>=]|='[^']*'|=""[^""]*""|=[^'""][^\s>]*)*>";
            return Regex.Replace(html, matchpattern, replacementstring, RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Multiline | RegexOptions.Singleline);
        }
        */

        /*
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

        */

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
                                        if (!objSecurityLib.isValidFilterSql(valoreDaValidare))
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
        //private void ValidationRow(IXLWorksheet? wsDominio, int numero_colonna, string DZT_Name, string titolo, ref int numeroRigheProcessate)
        //{
        //    try
        //    {
        //        string filter = GetModelAttributePropertiesFilter(DZT_Name);

        //        Dictionary<string, object> param = new Dictionary<string, object>();
        //        param.Add("@DZT_Name", DZT_Name.Replace("'", "''"));
        //        param.Add("@filter", filter.Replace("'", "''"));

        //        string strSQL = "exec GetDomFromDztName @DZT_Name , @filter, 'I' , '' ";

        //        TSRecordSet rsColonne = cdf.GetRSReadFromQuery_(strSQL, ApplicationCommon.Application.ConnectionString, param);

        //        int inc = 2;

        //        wsDominio.Cell(1, numero_colonna).Value = titolo;
        //        wsDominio.Cell(1, numero_colonna).Style.Font.Bold = true;
        //        wsDominio.Cell(1, numero_colonna).Style.Protection.Locked = true;

        //        rsColonne.MoveFirst();
        //        string elem = string.Empty;

        //        while (!rsColonne.EOF)
        //        {
        //            elem = CStr(rsColonne["DMV_DescML"]);
        //            wsDominio.Cell(inc, numero_colonna).Value = elem;
        //            inc++;
        //            rsColonne.MoveNext();
        //        }

        //        numeroRigheProcessate = inc - 1;
        //    }
        //    catch
        //    {

        //    }
        //}

        
        //string GetModelAttributePropertiesFilter(string DZT_Name)
        //{
        //    string esito = " IsNull(DMV_Deleted, 0) = 0 ";
        //    string stringaFiltro = string.Empty;

        //    if (!String.IsNullOrEmpty(MODEL))
        //    {
        //        Dictionary<string, object> param = new Dictionary<string, object>();
        //        param.Add("@MODEL", MODEL);
        //        param.Add("@DZT_name", DZT_Name);
        //        string libSQL = "select MAP_Value from LIB_ModelAttributeProperties where MAP_Propety = 'Filter' and MAP_MA_MOD_ID = @MODEL and MAP_MA_DZT_Name = @DZT_Name";
        //        string ctlSQL = "select MAP_Value from CTL_ModelAttributeProperties where MAP_Propety = 'Filter' and MAP_MA_MOD_ID = @MODEL and MAP_MA_DZT_Name = @DZT_Name";
        //        try
        //        {
        //            string obj = (string)cdf.ExecuteScalar_(libSQL, strConnectionString, parCollection: param);
        //            if (!String.IsNullOrEmpty(obj))
        //            {
        //                stringaFiltro = obj.Substring(10).Replace("<ID_USER>", ufp);

        //            }
        //            else
        //            {
        //                obj = (string)cdf.ExecuteScalar_(ctlSQL, strConnectionString, parCollection: param);
        //                stringaFiltro = obj.Substring(10).Replace("<ID_USER>", ufp);
        //            }
        //            if (!String.IsNullOrEmpty(obj))
        //            {
        //                esito += "and " + stringaFiltro;
        //            }

        //        }
        //        catch
        //        {

        //        }

        //    }
        //    return esito;
        //}

    }
}

