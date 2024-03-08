using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.Core.Storage;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
	internal class ClsDownloader : ProcessBase
	{
		private readonly CommonDbFunctions cdf = new();
		private Dictionary<string, string>? mp_collParameters = null!;

		private const string MODULE_NAME = "CtlProcess.ClsDownloader";

		private const string NOME_FILE_DEFAULT = "temp.pdf";

		//-- parametri da configurare sull'azione del processo
		private const string URL_FILE = "URL_FILE";            //-- Url dal quale fare il download
															   //                       -- Ci sostituiremo (replace):
															   //                       -- <ID_DOC>
															   //                       -- <ID_USER>
															   //                       -- Tutti i valori che ritorna il parametro VIEW_URL_PARAMS
		private const string SYS_FILE_DOWNLOAD = "SYS_FILE_DOWNLOAD";   //-- percorso dove mettere il file scaricato
		private const string BACKUP = "BACKUP";                 //-- (opz.) yes , no. Se backup = yes storicizzare il vecchio file invece di sovrascriverlo con il nuovo
		private const string URL_CHECK = "URL_CHECK";           //-- (opz.) url (pagina asp o aspx) con interfaccia standard :
																//                               * input  : 1 parametro (il percorso del file)
																//                               * output : 0, 1  (0 non scaricare il nuovo file, 1 scaricalo)

		private const string QUERY_UPDATE = "QUERY_UPDATE";     //-- (opz.) Query di update alla quale andremo a sostituire
																//                                        -- <ID_DOC>
																//                                        -- <ID_USER>
																//                                        -- <KEY_ATTACH>

		private const string NOME_FILE = "NOME_FILE";           //-- (obbligatorio se viene passato QUERY_UPDATE) nome del file
																//                               -- che si vuole finisca in base dati

		//-- Eventuali parametri da passare alla pagina che ci compiler il pdf
//		private const string PDF_DATA_VIEW = "PDF_DATA_VIEW"      //-- Vista che conterr i dati da caricare nel pdf (pdf acro fields / moduli pdf )
//		private const string PDF_DATA_VIEW_ID = "PDF_DATA_VIEW_ID" //-- ID tabellare per filtrare sui dati che la vista ritorna

		private const string VIEW_URL_PARAMS = "VIEW_URL_PARAMS";   //-- (opz.) Vista che ritorna N parametri i cui valori vanno a sostituirsi
																	//                                              -- ai vari <NOME_COLONNA> trovati nel parametro URL_FILE

		//-- SET di parametri che permette di scaricare un file dal parametro URL_FILE applicando le sostituzioni
		//-- sopra citate, questo file scaricato viene inserito nella tabella indicata dal parametro TABLE_TO_UPDATE
		//-- nella colonna COLUMN_TO_UPDATE facendo una where per COLUMN_ID_TO_UPDATE = <ID_DOC>.
		//-- Questo comportamento si attiva in presenza del parametro TABLE_TO_UPDATE e di URL_FILE.
		//-- Ma in assenza del parametro QUERY_UPDATE (che fa scattare un altro giro)
		private const string TABLE_TO_UPDATE = "TABLE_TO_UPDATE";
		private const string COLUMN_TO_UPDATE = "COLUMN_TO_UPDATE";
		private const string COLUMN_ID_TO_UPDATE = "COLUMN_ID_TO_UPDATE";
		private const string GENERATE_RANDOM_FILENAME = "GENERATE_RANDOM_FILENAME"; //--(opz.)  YES, NO. Faccio genere un nome file random per essere sicuro che  un nome univoco quando passer dalla cartella
																					//                                                                      --         degli allegati (anche in modo temporaneo rischio andare in collisione con file gia presenti)

		private const string TAGLIA_MINIMA = "TAGLIA_MINIMA";                       //--(opz.)  Numero minimo di byte che si vuole abbia il file scaricato. Sotto questa soglia viene restituito un errore di download

		private int iTimeout = -1;

		public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
		{
			ELAB_RET_CODE strReturn = ELAB_RET_CODE.RET_CODE_ERROR;
			string strCause = string.Empty;
			string nomeFileCreato = string.Empty;
			SqlConnection? cnLocal = null!;
			iTimeout = timeout;

			try
			{
				string urlDwn = string.Empty;
				string nomeFile = string.Empty;
				string pathDownload = string.Empty;
				string strSql = string.Empty;
				string keyAttach = string.Empty;
				string viewParams = string.Empty;

				cnLocal = SetConnection(connection, cdf);

				strCause = "Lettura dei parametri che determinano le azioni";

				if (GetParameters(strParam, ref strDescrRetCode))
				{
					//-- Se non si  richiesto il download di un pdf per inserirci dei dati
					//-- dentro e salvarlo in base dati ( Verifico questo comportamento dall'assenza del parametro query_update)
					if (GetParamValue(QUERY_UPDATE) == "")
					{
						urlDwn = GetParamValue(URL_FILE);
						string[] v = urlDwn.Split("/");

						pathDownload = GetParamValue(SYS_FILE_DOWNLOAD);

						var sqlParams = new Dictionary<string, object?>();
						sqlParams.Add("@PathDownload", Trim(pathDownload));
						strSql = "select dzt_valuedef from lib_dictionary where dzt_name = @PathDownload";

						strCause = $"recupero il valore della sys configurata {pathDownload}";
						TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

						if (rs.RecordCount > 0)
						{
							rs.MoveFirst();
							pathDownload = CStr(rs["dzt_valuedef"]);
						}
						else
						{ 
							throw new Exception($"1 - FUNZIONE : {MODULE_NAME}.Elaborate. Non esiste nel dizionario la sys {Trim(pathDownload)}");
						}

						if (Right(pathDownload, 1) != @"\")
						{ 
							pathDownload = $@"{pathDownload}\";
						}

						strCause = "Recupero il nome del file che si vuole scaricare";

						if (UCase(GetParamValue(GENERATE_RANDOM_FILENAME)) == "YES")
						{ 
							nomeFile = $"Tmp_downloader_{CStr(strDocKey)}.tmp";
						}
						else
						{
							nomeFile = v[v.GetUpperBound(0)];

							//-- Se  stato chiesto un nome specifico per il fileName
							if (Trim(GetParamValue(NOME_FILE)) != string.Empty)
							{ 
								nomeFile = GetParamValue(NOME_FILE);
							}

							//-- sostituisco al 'nomeFile' iduser e iddoc
							nomeFile = Replace(nomeFile, "<ID_USER>", CStr(lIdPfu));
							nomeFile = Replace(nomeFile, "<ID_DOC>", CStr(strDocKey));
						}

						try
						{
							string urlCheck = GetParamValue(URL_CHECK);
							string resp = string.Empty;
							bool bDownload = true;
							long lRet = 0;

							//-- Se viene passata la pagina di controllo ed esiste un file precedente con lo stesso nome di quello che
							//-- che stiamo per scaricare
							if (Len(Trim(urlCheck)) > 0 && File.Exists(pathDownload + nomeFile))
							{
								if (Right(urlCheck, 1) != "?")
								{ 
									urlCheck = $"{urlCheck}?";
								}

								strCause = "invoco la pagina di verifica del download";

								//-- Inviamo alla pagina il riferimento al file precedente per vedere se scaricarne uno nuovo o meno
								urlCheck = $"{urlCheck}file={URLEncode(pathDownload + nomeFile)}";

								resp = invokeUrl(urlCheck);

								bDownload = (resp != "0");
							}
							else
							{
								if (File.Exists(pathDownload + nomeFile))
								{
									File.Delete(pathDownload + nomeFile);
								}
							}

							//-- se  stato richiesto il backup dei file precedenti
							if (bDownload && (UCase(GetParamValue(BACKUP)) == "SI" || UCase(GetParamValue(BACKUP)) == "YES"))
							{
								strCause = "backup del vecchio file";

								if (File.Exists(pathDownload + nomeFile))
								{
									File.Copy($"{pathDownload}{nomeFile}", $"{pathDownload}{Convert.ToDateTime(DateTime.Now):yyyyMMddhhmmss}_{nomeFile}");
								}
							}

							//                err.Clear

							//-- invoco la cnv_estesa sul urlDwn per risolvere eventuali ML e SYS
							//-- es di chiave: http://localhost/#SYS.SYS_nomeappportale#/downloader.asp

							sqlParams.Clear();
							sqlParams.Add("@UrlDwn", urlDwn);
							strSql = "select dbo.CNV_ESTESA(@UrlDwn,'I') as valore";

							strCause = "Applico la funzione sql cnv_estesa sul parametro URL_FILE";
							rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

							if (rs.RecordCount > 0)
							{
								rs.MoveFirst();
								urlDwn = CStr(rs["valore"]);
							}

							urlDwn = Replace(urlDwn, "<ID_USER>", CStr(lIdPfu));
							urlDwn = Replace(urlDwn, "<ID_DOC>", CStr(strDocKey));

							viewParams = GetParamValue(VIEW_URL_PARAMS);

							if (!string.IsNullOrEmpty(viewParams))
							{ 
								urlDwn = replaceDinamicParams(urlDwn, viewParams, CStr(strDocKey), cnLocal, transaction);
							}

							//                On Error GoTo err

							strCause = "download del file richiesto";

							Task<long> task = Task.Run(() => DownloadFileFromWebAsync(urlDwn, pathDownload + nomeFile));
							task.Wait();
							lRet = task.Result;

							if (lRet != 0)
								throw new Exception($"Errore di download RetCode={lRet} - FUNZIONE : {MODULE_NAME}.Elaborate");

							if (!File.Exists(pathDownload + nomeFile))
								throw new Exception($"Errore nel download - FUNZIONE : {MODULE_NAME}.Elaborate");

							//-- Se  richiesta la verifica rispetto ad una taglia minima del file
							if (GetParamValue(TAGLIA_MINIMA) != string.Empty && IsNumeric(GetParamValue(TAGLIA_MINIMA)))
							{
								FileInfo FileProps = new FileInfo($"{pathDownload}{nomeFile}");
								if (FileProps.Length < CLng(GetParamValue(TAGLIA_MINIMA)))
								{
									throw new Exception($"Taglia minima del file non raggiunta - FUNZIONE : {MODULE_NAME}.Elaborate");
								}
							}

							if (GetParamValue(TABLE_TO_UPDATE) != string.Empty)
							{
								sqlParams = new Dictionary<string, object?>();
								sqlParams.Add("@DocKey", CInt(strDocKey));

								strSql = $"select {GetParamValue(COLUMN_ID_TO_UPDATE)},{GetParamValue(COLUMN_TO_UPDATE)} from {GetParamValue(TABLE_TO_UPDATE)} where {GetParamValue(COLUMN_ID_TO_UPDATE)} = @DocKey";

								strCause = $"Eseguo la query {strSql}";

								SqlConnection tmpCnLocal = SetConnection(cnLocal.ConnectionString, cdf);
								tmpCnLocal.Open();

								rs = new TSRecordSet();
								rs.Open(strSql, tmpCnLocal.ConnectionString, sqlParams, timeout: iTimeout);

								if (!(rs.EOF && rs.BOF))
								{
									strCause = $"Inserisco il blob nella colonna {GetParamValue(COLUMN_TO_UPDATE)}";

									DataRow dr = rs.Fields!;
									//dr[GetParamValue(COLUMN_TO_UPDATE)] = GetBytes(pathDownload + nomeFile)

									CommonDB.Basic.SaveToRecordset(GetParamValue(COLUMN_TO_UPDATE), GetParamValue(TABLE_TO_UPDATE), GetParamValue(COLUMN_ID_TO_UPDATE), CInt(strDocKey), pathDownload + nomeFile, cnLocal.ConnectionString);

									strCause = "Effettuo la rs.update sulla tabella per inserire il blob";
									rs.Update(dr, GetParamValue(COLUMN_ID_TO_UPDATE), GetParamValue(TABLE_TO_UPDATE));

									if (File.Exists(pathDownload + nomeFile))
									{
										File.Delete(pathDownload + nomeFile);
									}
								}
								else
								{
									throw new Exception("Impossibile aggiornare la tabella. la query non ha restituito record");
								}
							}

						}
						catch (Exception)
						{
							throw;
						}

					}
					else
					{
						urlDwn = GetParamValue(URL_FILE);
						urlDwn = Replace(urlDwn, "<ID_USER>", CStr(lIdPfu));
						urlDwn = Replace(urlDwn, "<ID_DOC>", CStr(strDocKey));

						strSql = "select dzt_valuedef from lib_dictionary where dzt_name = 'SYS_PathFolderAllegati'";

						strCause = "recupero il valore della sys configurata SYS_PathFolderAllegati";
						TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

						if (rs.RecordCount > 0)
						{
							rs.MoveFirst();
							pathDownload = CStr(rs["dzt_valuedef"]); //-- Recupero il path della directory allegati
						}
						else
						{
							if (!(connection is SqlConnection))
								CloseConnection(cnLocal);

							throw new Exception($"Manca SYS SYS_PathFolderAllegati - FUNZIONE : {MODULE_NAME}.Elaborate");
						}

						strCause = "recupero parametro NOME_FILE";

						//-- Recupero il nome del file che si vuole scaricare a partire
						//-- dal parametro URL_FILE
						nomeFile = string.Empty;
						nomeFile = GetParamValue(NOME_FILE);

						//-- Se non possiamo recuperare il parametro NOME_FILE ne creiamo uno di default.
						//-- Ma non dovrebbe mai accadere
						if (Len(Trim(nomeFile)) == 0)
							nomeFile = NOME_FILE_DEFAULT;

						//-- invoco la cnv_estesa sul pathdownload per risolvere eventuali ML e SYS
						//-- es di chiave: http://localhost/#SYS.SYS_nomeappportale#/downloader.asp

						var sqlParams = new Dictionary<string, object?>();
						sqlParams.Add("@UrlDwn", urlDwn);
						strSql = "select dbo.CNV_ESTESA(@UrlDwn,'I') as valore";

						strCause = "Applico la funzione sql cnv_estesa sul parametro URL_FILE";

						rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, iTimeout, sqlParams);

						if (rs.RecordCount > 0)
						{
							rs.MoveFirst();
							urlDwn = CStr(rs["valore"]);
						}

						viewParams = CStr(GetParamValue(VIEW_URL_PARAMS));

						if (Len(Trim(viewParams)) > 0)
							urlDwn = replaceDinamicParams(urlDwn, viewParams, CStr(strDocKey), cnLocal, transaction);

						strCause = "Compongo il nomeFileTemporaneo per il pdf";

						//-- sostituisco al 'nomeFile' iduser e iddoc
						nomeFile = Replace(nomeFile, "<ID_USER>", CStr(lIdPfu));
						nomeFile = Replace(nomeFile, "<ID_DOC>", CStr(strDocKey));

                        //nomeFileCreato = $"{pathDownload}{Replace(CommonStorage.GetTempName(), ".", "")}_{nomeFile}";
                        nomeFileCreato = $"{pathDownload}{CommonStorage.GetTempName()}_{nomeFile}";

                        strCause = $"Invoco il metodo DownloadFileFromWeb passandoci come url : {urlDwn} . e come file tmp:{nomeFileCreato}";

						Task<long> task = Task.Run(() => DownloadFileFromWebAsync(urlDwn, nomeFileCreato));
						task.Wait();
						long lRet = task.Result;

						if (lRet != 0)
						{
							//-- chiudiamo la connessione solo se non ci troviamo nel caso di connessione/transazione unica
							if (!(connection is SqlConnection))
							{
								CloseConnection(cnLocal);
							}

							throw new Exception($"Errore nel download del file da clsDownloader, pagina invocata : {urlDwn} - FUNZIONE : {MODULE_NAME}.Elaborate");
						}

						//            On Error GoTo err

						long fileSizeGenerato = 0;

						strCause = "Verifico se il file esiste";

						//-- Controllo se il file  stato creato
						if (!File.Exists(nomeFileCreato))
							throw new Exception($"Errore nel download del file da clsDownloader, pagina invocata : {urlDwn} - FUNZIONE : {MODULE_NAME}.Elaborate");

						strCause = "Recupero la size del file";
						FileInfo FileProps = new FileInfo(nomeFileCreato);
						fileSizeGenerato = FileProps.Length;

						//-- Controllo se il file  a taglia 0
						if (fileSizeGenerato == 0)
							throw new Exception($"Errore nella generazione del file da clsDownloader.File a taglia 0.Pagina invocata: {urlDwn} - FUNZIONE : {MODULE_NAME}.Elaborate");

						strCause = "Recupero il parametro taglia_minima";

						//-- Se  richiesta la verifica rispetto ad una taglia minima del file
						if (GetParamValue(TAGLIA_MINIMA) != string.Empty && IsNumeric(GetParamValue(TAGLIA_MINIMA)))
						{
							strCause = "Verifico se la taglia del file rispetta la taglia minima";
							if (fileSizeGenerato < CLng(GetParamValue(TAGLIA_MINIMA)))
							{
								File.Delete(nomeFileCreato);
								throw new Exception($"Taglia minima del file non raggiunta - FUNZIONE : {MODULE_NAME}.Elaborate");
							}
						}

						strCause = "Invoco InsertCTL_Attach_FromFile";

						// Allego il file generato nella tabella degli allegati e mi faccio restituire
						// la chiave dell'allegato
						LibDbAttach lda = new();
						keyAttach = lda.InsertCTL_Attach_FromFile(nomeFileCreato, cnLocal.ConnectionString, nomeFile);

						strCause = $"Cancello {nomeFileCreato}";

						//--cancello il file allegato dal filesystem
						File.Delete(nomeFileCreato);

						strSql = GetParamValue(QUERY_UPDATE);
						strSql = Replace(strSql, "<ID_USER>", CStr(lIdPfu));
						strSql = Replace(strSql, "<ID_DOC>", CStr(strDocKey));
						strSql = Replace(strSql, "<KEY_ATTACH>", keyAttach);

						//-- applico la sostituzione dei parametri dinamici anche sulla query da eseguire
						viewParams = CStr(GetParamValue(VIEW_URL_PARAMS));
						if (!string.IsNullOrEmpty(viewParams))
						{
							strSql = replaceDinamicParams(strSql, viewParams, CStr(strDocKey), cnLocal, transaction);
						}

						strCause = $"Eseguo la query con execSql : {strSql}";

						cdf.ExecuteWithTransaction(CStr(strSql), cnLocal.ConnectionString, cnLocal, transaction, iTimeout);

						if (!(connection is SqlConnection))
						{
							CloseConnection(cnLocal);
						}
					}

					strReturn = ELAB_RET_CODE.RET_CODE_OK;
				}

				//err:

				return strReturn;
			}
			catch (Exception ex)
			{
				strReturn = ELAB_RET_CODE.RET_CODE_ERROR;

				CommonDB.Basic.TraceErr(ex, cnLocal.ConnectionString, MODULE_NAME);

				if (Len(Trim(nomeFileCreato)) > 0 && CommonStorage.FileExists(nomeFileCreato))
				{
					CommonStorage.DeleteFile(nomeFileCreato);
				}

				strDescrRetCode = $"{strCause} - {ex.Message} - FUNZIONE : {MODULE_NAME}.Elaborate";
				throw new Exception(strDescrRetCode, ex);
			}
		}

		private bool GetParameters(string strParam, ref string strDescrRetCode)
		{
			bool bReturn = false;
			//    ' I parametri vengono passati come Field1=Valore1&Field2=Valore2....

			try
			{
				mp_collParameters = GetCollectionExt(strParam);

				//    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
				//    ' controlli sui parametri passati
				//    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
				if (!mp_collParameters.ContainsKey(URL_FILE) && !mp_collParameters.ContainsKey(SYS_FILE_DOWNLOAD))
				{
					strDescrRetCode = $"Manca il parametro input {URL_FILE} ed anche {SYS_FILE_DOWNLOAD}";
					return bReturn;
				}

				bReturn = true;
			}
			catch (Exception ex)
			{
				throw new Exception($"{ex.Message} - FUNZIONE : {MODULE_NAME}.GetParameters", ex);
			}
			return bReturn;
		}

		private string GetParamValue(dynamic strKey)
		{
			try
			{
				return mp_collParameters![strKey];
			}
			catch (Exception)
			{
				return string.Empty;
			}
		}

		private string replaceDinamicParams(string inputString, string viewParams, string strDocKey, SqlConnection conn, SqlTransaction trans)
		{
			string strSql = string.Empty;
			string strCause = string.Empty;
			string outputString = string.Empty;
			string valore = string.Empty;

			try
			{
				var sqlParams = new Dictionary<string, object?>();
				sqlParams.Add("@DocKey", CInt(strDocKey));

				strSql = $"select * from {viewParams} where id = @DocKey";
				outputString = inputString;
				strCause = $"Eseguo la query {strSql}";

				TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction(strSql, conn.ConnectionString, conn, trans, iTimeout, sqlParams);

				if (rs.RecordCount > 0)
				{
					rs.MoveFirst();
					strCause = $"Sostituisco i parametri in URL_FILE rispetto alla vista {viewParams}";

					try
					{
						foreach (DataColumn dc in rs.Columns!)
						{
							valore = CStr(rs.Fields![dc]);

							//-- Sostituisco alla stringa urlDown tutte le ricorrenze nella forma <NOME_COLONNA>
							//-- Con il relativo valore recupero dalla vista
							outputString = Replace(outputString, $"<{UCase(dc.ColumnName)}>", valore);

							//            err.Clear
						}
					}
					catch { }
				}
			}
			catch (Exception ex)
			{
				throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + ".replaceDinamicParams", ex);
			}

			return outputString;
		}
	}
}
