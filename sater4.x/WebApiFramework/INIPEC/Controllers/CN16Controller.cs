using INIPEC.Library;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http;

namespace INIPEC.Controllers
{
	public class CN16Controller : ApiController
    {

	    private static readonly string BasePath = AppDomain.CurrentDomain.BaseDirectory;
		private readonly EformUtils _utils = new EformUtils();

        private static string GetCurrentPath()
		{
            /*var assembly = typeof(CN16Controller).Assembly;
            var assemblyLocation = assembly.Location;
            var assemblyDirectory = Path.GetDirectoryName(assemblyLocation);
			return assemblyDirectory;*/
            return BasePath;
		}

		private string getLotti(SqlConnection connection, int idProc, string xmlBase)
		{
            var output = "";
            const string strSql = "EXEC E_FORMS_CN16_DATI_LOTTI @idProc";

            var templateCriterio = @"<efac:SelectionCriteria>
					                        <cbc:CriterionTypeCode listName=""selection-criterion"">@@@CODE_CRIT@@@</cbc:CriterionTypeCode>
					                     </efac:SelectionCriteria>";

            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idProc", idProc);

			List<string> colToExclude = new List<string>
			{
				"LOTTO_CRITERI"
			};

			using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
					output += _utils.ElabXmlDb(rs, xmlBase, colToExclude);

					//Gestiamo manualmente il multi valore LOTTO_CRITERI
					var lottoCriteri = (string)rs["LOTTO_CRITERI"];
					var xmlListaCriteri = "";

					if (string.IsNullOrEmpty(lottoCriteri))
					{
						throw new ApplicationException("Criteri di selezione assenti");
					}

					foreach (var criterio in lottoCriteri.Split(new string[] { "###" },  StringSplitOptions.None))
					{
						if (string.IsNullOrEmpty(criterio)) continue;

						var xmlCriterio = templateCriterio.Replace("@@@CODE_CRIT@@@", HttpUtility.HtmlEncode(criterio));
						xmlListaCriteri += xmlCriterio;
					}

					output = output.Replace("@@@LOTTO_CRITERI@@@", xmlListaCriteri);

				}

			}

			if (string.IsNullOrEmpty(output))
			{
				throw new ApplicationException("Lotti assenti");
			}

			return output;
        }

        private string GetTenderReq(SqlConnection connection,int idProc)
		{
			var output = "";

			const string xmlBase = @"<cac:SpecificTendererRequirement>
						<cbc:TendererRequirementTypeCode listName=""exclusion-ground"">@@@EXLUSION_CODE@@@</cbc:TendererRequirementTypeCode>
						<cbc:Description languageID=""ITA"">@@@EXLUSION_DESCR@@@</cbc:Description>
					 </cac:SpecificTendererRequirement>";

            const string strSql = "EXEC E_FORMS_CN16_MOTIVO_ESCLUSIONE @idProc";

            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idProc", idProc);

            using (var rs = cmd1.ExecuteReader())
            {
                //Itero sugli N criteri di esclusione andandoli ad accodare all'xml complessivo
                while (rs.Read())
                {
                    //Aggiungiamo gli N SpecificTendererRequirement
                    output += _utils.ElabXmlDb(rs, xmlBase);
                }
            }

            if (string.IsNullOrEmpty(output))
            {
	            throw new ApplicationException("Criteri di esclusione essenti");
            }

			return output;

        }

        [HttpGet]
	    public HttpResponseMessage GenerateXml(string id = "", int idpfu = -20, string operation = "")
	    {
		    var esito = "";
		    var strCause = "";
		    var connectionString = ConfigurationManager.AppSettings["db.conn"];
		    XMLValidation xmlVal;
		    XMLValidationOutput xmlResult;

			try
			{

				if (id == "")
					throw new ApplicationException("Parametro 'id' obbligatorio");

				var testId = int.TryParse(id, out var idDoc);

			    if (!testId)
			    {
				    throw new ApplicationException("Parametro 'id' non valido");
			    }

                if (string.IsNullOrEmpty(operation))
                {
                    operation = "";
                }

                strCause = "Recupero di template_cn16";
				var xmlbase = _utils.GetXmlTemplate("template_cn16", GetCurrentPath());

				strCause = "Recupero di template_cn16_lotti";
				var xmlLotti = _utils.GetXmlTemplate( "template_cn16_lotti", GetCurrentPath());

                strCause = "Recupero di template_can_29_organization";
                var xmlOrgs = _utils.GetXmlTemplate("template_can_29_organization", GetCurrentPath());

                using (var connection = new SqlConnection(connectionString))
			    {
				    strCause = "Apertura della connessione sql";
					connection.Open();

                    SqlCommand cmd1;
                    string strSql;
                    int idProc = idDoc;

                    if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                    {
                        strCause = "Recupero di template_cn16_changes";
                        var xmlChanges = _utils.GetXmlTemplate("template_cn16_changes", GetCurrentPath());

                        strCause = "Recupero di template_cn16_change_list";
                        var xmlChangeList = _utils.GetXmlTemplate("template_cn16_change_list", GetCurrentPath());

						//L'id in input in caso di change notice è l'id del documento di rettifica/proroga/revoca e quindi dobbiamo recuperare dal linked doc la gara
                        strSql = "select linkeddoc as idProc from ctl_doc with(nolock) where id = @idDoc";
						cmd1 = new SqlCommand(strSql, connection);
                        cmd1.Parameters.AddWithValue("@idDoc", idDoc);

                        using (var rs = cmd1.ExecuteReader())
                        {
                            if (rs.Read())
                            {
                                idProc = (int)rs["idProc"];
                            }
                            else
                            {
                                throw new ApplicationException("Fallito recupero gara");
                            }
                        }

                        strCause = "Esecuzione della stored E_FORMS_CHANGE_NOTICE";
                        strSql = "EXEC E_FORMS_CHANGE_NOTICE @idDoc, @idProc, @idpfu";

                        cmd1 = new SqlCommand(strSql, connection);
                        cmd1.Parameters.AddWithValue("@idDoc", idDoc);
                        cmd1.Parameters.AddWithValue("@idProc", idProc);
                        cmd1.Parameters.AddWithValue("@idpfu", idpfu);

                        using (var rs = cmd1.ExecuteReader())
                        {
                            if (rs.Read())
                            {
                                xmlChanges = _utils.ElabXmlDb(rs, xmlChanges);
                            }
                            else
                            {
                                throw new ApplicationException("Dati CHANGE NOTICE assenti");
                            }
                        }

                        strCause = "Recupero l'elenco dei change list";
                        var xmlListaChange = GetChangeList(connection, idDoc, idProc, xmlChangeList);

                        //Nel blocco changes sostituisco gli EVENTUALI change
                        strCause = "sostituisco gli eventuali change";
                        xmlChanges = xmlChanges.Replace("@@@CHANGE_LIST@@@", xmlListaChange);

                        //Nell'xml di cn16 aggiunto il blocco xml di changes
                        strCause = "sostituzione place holder CONTRACT_NOTICE_CHANGES";
                        xmlbase = xmlbase.Replace("@@@CONTRACT_NOTICE_CHANGES@@@", xmlChanges);
                    }

                    strCause = "Esecuzione della stored E_FORMS_CN16_DATI_ENTE";
					strSql = "EXEC E_FORMS_CN16_DATI_ENTE @idProc";
                    
					cmd1 = new SqlCommand(strSql, connection);
					cmd1.Parameters.AddWithValue("@idProc", idProc);

                    string organizzazioni = "";

                    using (var rs = cmd1.ExecuteReader())
					{
                        while (rs.Read())
                        {
                            organizzazioni += _utils.ElabXmlDb(rs, xmlOrgs);
                        }

						if ( string.IsNullOrEmpty(organizzazioni) )
                            throw new ApplicationException("Dati ente assenti");
                    }

                    xmlbase = xmlbase.Replace("@@@CONTRACT_NOTICE_ORGANIZATIONS@@@", organizzazioni);

                    strCause = "Esecuzione della stored E_FORMS_CN16_DATI_GARA";
					strSql = "EXEC E_FORMS_CN16_DATI_GARA @idProc";

                    cmd1 = new SqlCommand(strSql, connection);
                    cmd1.Parameters.AddWithValue("@idProc", idProc);

                    using (var rs = cmd1.ExecuteReader())
                    {
                        if (rs.Read())
                        {
                            xmlbase = _utils.ElabXmlDb(rs, xmlbase);
                        }
                        else
                        {
                            throw new ApplicationException("Dati gara assenti");
                        }
                    }

                    strCause = "Invocazione del metodo GetTenderReq";
					var tenderReq = GetTenderReq(connection,idProc);
                    xmlbase = xmlbase.Replace("@@@SPECIFIC_TENDERER_REQUIREMENT@@@", tenderReq);

                    strCause = "Invocazione del metodo getLotti";
					var newXmlLotti = getLotti(connection, idProc, xmlLotti);
                    xmlbase = xmlbase.Replace("@@@LISTA_LOTTI@@@", newXmlLotti);

					//Dopo aver completato la produzione dell'xml lo vado a validare e solo se si supera con successo la validate si scrive l'xml nel DB, viceversa restituisco errore
					xmlVal = new XMLValidation();
					//xmlResult = new XMLValidationOutput();

					//Errori Cablati
					string XSDPath = "Il percorso fornito per il file XSD risulta incorretto. Controlla se il file esiste";
					string XMLPath = "Il percorso fornito per il file XML risulta incorretto. Controlla se il file esiste";
					string XSD = "Errore nel recupero dell'XSD";
					string ValidateXML = "Errore di validazione file XML";
					string ReadXML = "Errore di lettura file XML con schema XSD";

					//Parametri Cablati
					string Xml = string.Empty;
					string Xsd = "UBL-ContractNotice-2.3.xsd";
					bool isXmlPath = false;
					bool isXsdPath = true;

					xmlResult = xmlVal.ValidateXML(xmlbase, Xsd, isXmlPath, isXsdPath);

					//Se ho avuto un errore qualsiasi entro nel merito del motivo
					if (!xmlResult.Esit)
					{
						if (xmlResult.Error != Errors.RuntimeException)
						{
							var erroreXsd = $"TIPO ERRORE : {xmlResult.Error} -- ";

							erroreXsd += string.Join(" -- ", xmlResult.ValidationErrors);

							strCause = "Scrittura dell'errore XSD nella Document_E_FORM_PAYLOADS";
							strSql = @"INSERT INTO Document_E_FORM_PAYLOADS( idHeader, operationDate, operationType, idpfu, payload )
										VALUES ( @idProc, getDate(), @opType, @idPfu, @payload )";

							cmd1 = new SqlCommand(strSql, connection);
							cmd1.Parameters.AddWithValue("@idProc", idProc);

                            if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                            {
                                cmd1.Parameters.AddWithValue("@opType", "ERRORE_CHANGE_NOTICE");
                            }
                            else
                            {
                                cmd1.Parameters.AddWithValue("@opType", "ERRORE_CN16");
                            }

                            
							cmd1.Parameters.AddWithValue("@idPfu", idpfu);
							cmd1.Parameters.AddWithValue("@payload", erroreXsd);

							cmd1.ExecuteNonQuery();

                            strCause = "Scrittura dell'xml non valido nella Document_E_FORM_PAYLOADS";

                            cmd1 = new SqlCommand(strSql, connection);
                            cmd1.Parameters.AddWithValue("@idProc", idProc);

                            if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                            {
                                cmd1.Parameters.AddWithValue("@opType", "XML_NON_VALIDO_CHANGE_NOTICE");
                            }
                            else
                            {
                                cmd1.Parameters.AddWithValue("@opType", "XML_NON_VALIDO_CN16");
                            }

                            

                            cmd1.Parameters.AddWithValue("@idPfu", idpfu);
                            cmd1.Parameters.AddWithValue("@payload", xmlbase);

                            cmd1.ExecuteNonQuery();


                            var xmlErrConf = ConfigurationManager.AppSettings[$"XMLValidation.Error.{xmlResult.Error}"];

							if (!string.IsNullOrEmpty(xmlErrConf))
							{
								throw new ConfigurationException(xmlErrConf);
							}
						
							//Fallback nel caso in cui non ci sono i parametri nel webconfig
							switch (xmlResult.Error)
							{
								case Errors.XSDPath:
									throw new ConfigurationException(XSDPath);
								case Errors.XMLPath:
									throw new ConfigurationException(XMLPath);
								case Errors.XSD:
									throw new ConfigurationException(XSD);
								case Errors.ValidateXML:
									throw new ConfigurationException(ValidateXML);
								case Errors.ReadXML:
									throw new ConfigurationException(ReadXML);
								default:
									throw new ConfigurationException("Errore validazione XML. Tipo non gestito"); //Non capiterà mai
							}
							
						}

						throw new Exception(xmlResult.RuntimeException);
						
					}

					//Inserisco l'xml in tabella solo se è valido rispetto agli XSD

					strCause = "Scrittura nella Document_E_FORM_PAYLOADS";
					//Inserisco l'xml generato nel DB e lo collego alla procedura di gara
					strSql = @"INSERT INTO Document_E_FORM_PAYLOADS( idHeader, operationDate, operationType, idpfu, payload )
									VALUES ( @idProc, getDate(), @opType, @idPfu, @payload )";

                    cmd1 = new SqlCommand(strSql, connection);
                    cmd1.Parameters.AddWithValue("@idProc", idProc);

                    if (operation.ToUpper().Equals("CHANGE_NOTICE"))
                    {
                        cmd1.Parameters.AddWithValue("@opType", "CN16_CHANGE_NOTICE");
                    }
                    else
                    {
                        cmd1.Parameters.AddWithValue("@opType", "CN16");
                    }

                    

                    cmd1.Parameters.AddWithValue("@idPfu", idpfu);
                    cmd1.Parameters.AddWithValue("@payload", xmlbase);

                    cmd1.ExecuteNonQuery();

			    }

                if (string.IsNullOrEmpty(xmlbase))
                {
	                throw new ApplicationException("Errore nella generazione. XML vuoto");
				}

                //select top 1 payload from Document_E_FORM_PAYLOADS with(nolock) where idheader = 1111 and operationType = 'CN16' order by 1 desc

				esito = "1#OK";


		    }
            catch (ConfigurationException ex1)
            {
	            esito = "0#" + ex1.Message;
			}
			catch (ApplicationException e)
		    {
			    esito = "0#" + e.Message;
		    }
		    catch (Exception e)
		    {
				//Se non mi trovo su un eccezione lanciata dal codice voglio la stack trace completa
			    esito = "0#" + strCause + " -- " + e.ToString();
		    }


		    return new HttpResponseMessage()
		    {
			    Content = new StringContent(
				    esito,
				    Encoding.UTF8,
				    "text/html"
			    )
		    };
	    }

        private string GetChangeList(SqlConnection connection, int idDoc, int idProc, string xmlChangeList)
        {
            const string strSql = "EXEC E_FORMS_CHANGE_LIST @idDoc, @idProc";

            var cmd1 = new SqlCommand(strSql, connection);
            cmd1.Parameters.AddWithValue("@idDoc", idDoc);
            cmd1.Parameters.AddWithValue("@idProc", idProc);

            var output = "";

            using (var rs = cmd1.ExecuteReader())
            {
                while (rs.Read())
                {
                    output += _utils.ElabXmlDb(rs, xmlChangeList);
                }
            }

            return output;
        }
    }
}
