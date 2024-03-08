using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Text;
using System.Web.Http;
using System.Xml.Linq;
using System.Configuration;
using INIPEC.Library;
using System.Linq;

namespace INIPEC.Controllers
{
    public class OTPController : ApiController
    {
        [HttpGet]
        [ActionName("Generate")]
        public string Generate(string idPfuGuid)
        {
            SqlDataReader rs = null;
            string strSQL = string.Empty;
            var pu = new PDNDUtils();
            int idPfu = 0;
            string result = string.Empty;
            string receiptValue = string.Empty;
            string otpValue = string.Empty;
            string otpResponse = string.Empty;

            string numTelefono = string.Empty;
            string indirizzoWS = string.Empty;
            string clientID = string.Empty;
            string clientSecret = string.Empty;
            string Messaggio = string.Empty;
            string Mittente = string.Empty;
            string LunghezzaOTP = string.Empty;

            string otpHelper = string.Empty;
            string cleanedNumTelefono = string.Empty;
            string templateNumTelefono = string.Empty;
            int tempoValidita = 0;
            string tempoValiditaString = string.Empty;
            int restoDivisioneNum = 0;
            int lunghezzaPartiNum = 0;
            string numTelefono_start = string.Empty;
            string numTelefono_mid = string.Empty;
            string numTelefono_end = string.Empty;
            string removedCellPart = "";

            try
            {
                using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]))
                {
                    connection.Open();

                    using (SqlCommand cmd = new SqlCommand(strSQL, connection))
                    {
                        // Recupero l'idPfu tramite accessguid
                        idPfu = Security.getAccessFromGuid(idPfuGuid);

                        //Tramite IdPfu Accedo alla tabella degli Utenti e recupero il numero di telefono associato
                        strSQL = @"select 
                                    pfuCell 
                                  from ProfiliUtente with(nolock)
                                  where IdPfu = @IdPfu";

                        cmd.Parameters.AddWithValue("@IdPfu", idPfu);
                        cmd.CommandText = strSQL;

                        rs = cmd.ExecuteReader();

                        if (rs.Read())
                        {
                            numTelefono = (string)rs["pfuCell"];

                            rs.Close();

                            /* STEP 1 - CONTROLLI NUMERO DI TELEFONO */
                            //Il numero di telefono recuperato deve essere composto di solo cifre numeriche altrimenti il servizio non riuscirà ad inviare l'SMS

                            // Rimuovo spazi bianchi e caratteri di separazione
                            cleanedNumTelefono = Regex.Replace(numTelefono, @"\s|[-]|[(]|[)]", "");

                            // Verifico che la stringa risultante sia composta solo da cifre o "+"
                            if (!Regex.IsMatch(cleanedNumTelefono, @"^(\+|\d)+$"))
                            {
                                // Il numero non è valido
                                throw new ArgumentException("CUSTOM:Numero di telefono non valido. Contattare l'amministratore per effettuare l'accesso");
                            }

                            //CERCO DI COMPORRE UN NUMERO FORMALMENTE CORRETTO
                            if (!CheckPrefissoTelfonico(cleanedNumTelefono))
                            {
                                //PATCH ! -- Non avendo un prefisso telefonico valido aggiungo io il +39 davanti come fallback
                                cleanedNumTelefono = "+39" + cleanedNumTelefono;
                            }

                            // Rimuovo l'eventuale "+" all'inizio del numero
                            if (cleanedNumTelefono.StartsWith("+"))
                            {
                                cleanedNumTelefono = cleanedNumTelefono.Substring(1);
                                removedCellPart = "+";
                            }

                            //Rimuovo l'evenutale "00" all'inizio del numero
                            if (cleanedNumTelefono.StartsWith("00"))
                            {
                                cleanedNumTelefono = cleanedNumTelefono.Substring(2);
                                removedCellPart = "00";
                            }

                            //Spplitto il numero in 3 parti per cifrare i caratteri centrali
                            restoDivisioneNum = cleanedNumTelefono.Length % 3;
                            lunghezzaPartiNum = cleanedNumTelefono.Length / 3;

                            numTelefono_start = cleanedNumTelefono.Substring(0, lunghezzaPartiNum);
                            numTelefono_mid = new string('*', (cleanedNumTelefono.Substring(lunghezzaPartiNum, lunghezzaPartiNum + restoDivisioneNum)).Length);
                            numTelefono_end = cleanedNumTelefono.Substring((lunghezzaPartiNum * 2) + restoDivisioneNum, lunghezzaPartiNum);

                            templateNumTelefono = removedCellPart + numTelefono_start + numTelefono_mid + numTelefono_end;

                            /* STEP 2 - RECUPERO CONFIGURAZIONE DA DB */
                            //Recupero la configurazione per effettuare la chiamata al WS (step 3)

                            strSQL = @"SELECT 
                                             dbo.PARAMETRI('CERTIFICATION','certification_req_33113','LunghezzaOTP','0',-1) as LunghezzaOTP
                                            ,dbo.PARAMETRI('CERTIFICATION','certification_req_33113','Mittente','0',-1) as Mittente
                                            ,dbo.PARAMETRI('CERTIFICATION','certification_req_33113','Messaggio','0',-1) as Messaggio
                                            ,dbo.PARAMETRI('CERTIFICATION','certification_req_33113','clientSecret','0',-1) as clientSecret
                                            ,dbo.PARAMETRI('CERTIFICATION','certification_req_33113','clientID','0',-1) as clientID
                                            ,dbo.PARAMETRI('CERTIFICATION','certification_req_33113','indirizzoWS','0',-1) as indirizzoWS";

                            cmd.CommandText = strSQL;
                            cmd.Parameters.Clear();

                            rs = cmd.ExecuteReader();

                            if (rs.Read())
                            {
                                indirizzoWS = (string)rs["IndirizzoWS"];
                                clientID = (string)rs["ClientID"];
                                clientSecret = (string)rs["ClientSecret"];
                                Messaggio = (string)rs["Messaggio"];
                                Mittente = (string)rs["Mittente"];
                                LunghezzaOTP = (string)rs["LunghezzaOTP"];

                                //Eseguo una replace nell'indirizzo del WS con il ClientID
                                indirizzoWS = indirizzoWS.Replace("smsUserId", clientID);

                                rs.Close();

                                /* STEP 3 - CHIAMATA AL SERVIZIO */
                                //Chiamo il servizio per generare l'OTP e mi salvo in tabella il ritorno per confrontarlo in un secondo momento con quanto digitato dall'utente

                                //Ora posso invocare il WS per genereare l'OTP
                                var client = new HttpClient();
                                var request = new HttpRequestMessage(HttpMethod.Post, indirizzoWS);
                                var collection = new List<KeyValuePair<string, string>>();
                                collection.Add(new KeyValuePair<string, string>("pwd", clientSecret));
                                collection.Add(new KeyValuePair<string, string>("msg", Messaggio));
                                collection.Add(new KeyValuePair<string, string>("tel", cleanedNumTelefono));
                                collection.Add(new KeyValuePair<string, string>("sender", Mittente));
                                collection.Add(new KeyValuePair<string, string>("otpLength", LunghezzaOTP));
                                var content = new FormUrlEncodedContent(collection);
                                request.Content = content;

                                var response = client.SendAsync(request).Result;
                                response.EnsureSuccessStatusCode();

                                //Ottengo dall'XML tornato i valori
                                XDocument xmlDoc = XDocument.Parse(response.Content.ReadAsStringAsync().Result);

                                receiptValue = xmlDoc.Element("responseWithOTP").Element("receipt").Value;
                                otpValue = xmlDoc.Element("responseWithOTP").Element("otp").Value;
                                otpResponse = xmlDoc.Element("responseWithOTP").Element("response").Value;

                                //Testando il campo response vado a generare un'eccezione specifica se diverso da 0
                                if (otpResponse != "0")
                                {
                                    throw new ArgumentException($"Errore nel WS esterno: Codice {otpResponse} --- Dettaglio: {GetErrorDescription(otpResponse)}");
                                }


                                /* STEP 4 - Recupero il template dai ML e vado a sostituire con i valori dinamicamente */
                                strSQL = @"SELECT 
                                                dbo.PARAMETRI('CERTIFICATION','certification_req_33113','TempoValiditaOTP','0',-1) as TempoValidita";

                                cmd.Parameters.Clear();
                                cmd.CommandText = strSQL;

                                rs = cmd.ExecuteReader();

                                if (rs.Read())
                                {
                                    tempoValidita = Convert.ToInt32(rs["TempoValidita"]);

                                    tempoValiditaString = ConvertiSecondiInStringa(tempoValidita);

                                    rs.Close();
                                }
                                else
                                {
                                    throw new ArgumentException("Impossibile recuperare il parametro che indica il tempo di validità dell'OTP");
                                }

                                //Recupero il ML dell'helper OTP e faccio le replace sui placeholder per generare il testo finale da visualizzare
                                strSQL = @"select 
                                                ML_Description as Helper
                                                from LIB_Multilinguismo with(nolock)
                                                where ML_KEY = 'HELP_MESSAGE_OTP_ACCESS'";

                                cmd.Parameters.Clear();
                                cmd.CommandText = strSQL;

                                rs = cmd.ExecuteReader();

                                if (rs.Read())
                                {
                                    otpHelper = (string)rs["Helper"];

                                    otpHelper = otpHelper.Replace("@@@TempoValidita@@@", tempoValiditaString);
                                    otpHelper = otpHelper.Replace("@@@NumeroTelefono@@@", templateNumTelefono);

                                    rs.Close();
                                }
                                else
                                {
                                    throw new ArgumentException("Impossibile recuperare il Multilinguismo dell'helper");
                                }


                                /* STEP 5 - SALVO L'OTP HASHATO E IL TEMPLATE, TORNO 1#IDROW_CODICE_OTP */

                                strSQL = "INSERT INTO OTP_Access(Server_Id, OTP_Hash, idPfu, Messaggio, TemplateHelper) SELECT @receiptValue, @otpValue, @idPfu, @Messaggio, @templateHelper";

                                cmd.CommandText = strSQL;
                                cmd.Parameters.Clear();

                                // Aggiungo i parametri
                                cmd.Parameters.AddWithValue("@receiptValue", receiptValue);
                                cmd.Parameters.AddWithValue("@idPfu", idPfu);
                                cmd.Parameters.AddWithValue("@Messaggio", response.Content.ReadAsStringAsync().Result);
                                cmd.Parameters.AddWithValue("@otpValue", CalculateSHA256Hash(otpValue));
                                cmd.Parameters.AddWithValue("@templateHelper", otpHelper);

                                cmd.ExecuteNonQuery();

                                rs.Close();
                            }
                            else
                            {
                                throw new ArgumentException("CUSTOM:Impossibile recuperare i dati di configurazione del servizio");
                            }
                        }
                        else
                        {
                            throw new ArgumentException("CUSTOM:Impossibile recuperare numero di telefono per invio OTP");
                        }

                        //Esito positivo e ritorno l'idRow che fa riferimento al record appena inserito in tabella
                        result = "1#" + receiptValue;

                        //Salvo la traccia se andato a buon fine
                        pu.InsertTrace("OTP/GENERATE", result + " (Server_Id OTP_Access)", Convert.ToString(idPfu));
                    }
                }
            }
            catch (Exception ex)
            {
                //Vado a ritornare un codice di errore CUSTOM per poterlo mostrare a video senza lavorazioni intermedie.
                //Per l'errore specifico vedere la trace dentro la tabella OTP_Access
                if (ex.Message.Contains("CUSTOM:"))
                    result = "0#" + ex.Message.Replace("CUSTOM:", "");
                else
                    result = "0#" + "Errore nell'elaborazione del servizio, conttatare il supporto tecnico";

                //Salvo la traccia dell'errore
                pu.InsertTrace("OTP/GENERATE", "ERRORE:" + ex.Message, Convert.ToString(idPfu));
            }

            return result;
        }

        [HttpGet]
        [ActionName("Validate")]
        public string Validate(int idRow, string otpCode, string idPfuGuid)
        {
            SqlDataReader rs = null;
            string strSQL = string.Empty;
            string result = string.Empty;
            int idPfu = 0;

            var pu = new PDNDUtils();

            string OTPHash = string.Empty;
            int tempoValidita;
            DateTime InsertDate;
            bool isReadOTP;
            int tentativiDisponibili;
            int numRetry = 0;

            try
            {
                //Tramite Server_Id (precedentemente ritornato dal metodo Generate) accedo alla tabella
                //per ottenere i valori da confrontare con l'OTP inserito dall'utente
                using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]))
                {
                    // Recupero l'idPfu tramite accessguid
                    idPfu = Security.getAccessFromGuid(idPfuGuid);

                    strSQL = @" select 
                                     Server_Id
                                    ,OTP_Hash
                                    ,isReadOTP
                                    ,InsertDate
                                    ,numRetry
                                  from OTP_Access with(nolock)
                                  where Server_Id = @idRow";

                    connection.Open();
                    using (SqlCommand cmd = new SqlCommand(strSQL, connection))
                    {
                        cmd.Parameters.AddWithValue("@idRow", idRow);
                        rs = cmd.ExecuteReader();

                        if (rs.Read())
                        {
                            OTPHash = (string)rs["OTP_Hash"];
                            InsertDate = (DateTime)rs["InsertDate"];
                            isReadOTP = (bool)rs["isReadOTP"];
                            numRetry = (int)rs["numRetry"];

                            rs.Close();


                            strSQL = @"SELECT 
                                              dbo.PARAMETRI('CERTIFICATION','certification_req_33113','TempoValiditaOTP','0',-1) as TempoValidita
                                             ,dbo.PARAMETRI('CERTIFICATION','certification_req_33113','TentativiDisponibili','1',-1) as TentativiDisponibili";

                            cmd.CommandText = strSQL;
                            cmd.Parameters.Clear();

                            rs = cmd.ExecuteReader();

                            if (rs.Read())
                            {
                                tempoValidita = Convert.ToInt32(rs["TempoValidita"]);
                                tentativiDisponibili = Convert.ToInt32(rs["TentativiDisponibili"]);

                                rs.Close();

                                //Eseguo i controlli per verificare che l'otp sia valido per l'accesso, altrimenti restiuisco i vari casi di blocco
                                DateTime dataScadenza = InsertDate.AddSeconds(tempoValidita);


                                if (dataScadenza >= DateTime.Now && !isReadOTP && OTPHash == CalculateSHA256Hash(otpCode) && (numRetry < tentativiDisponibili))
                                {
                                    //Aggiorno la tabella settando l'otp come letto, quindi usato per accedere alla piattaforma e in quanto tale non più utilizzabile
                                    strSQL = "UPDATE OTP_Access SET isReadOTP = 1 where Server_Id = @idRow";

                                    cmd.CommandText = strSQL;
                                    cmd.Parameters.Clear();

                                    // Aggiungi i parametri
                                    cmd.Parameters.AddWithValue("@idRow", idRow);

                                    cmd.ExecuteNonQuery();

                                    rs.Close();


                                    //Aggiorno la tabella profiliutente settando TelTrusted a 1 nel caso in cui passo tutti i controlli
                                    strSQL = "UPDATE ProfiliUtente SET TelTrusted = 1 where idPfu = @idPfu";

                                    cmd.CommandText = strSQL;
                                    cmd.Parameters.Clear();

                                    // Aggiungi i parametri
                                    cmd.Parameters.AddWithValue("@idPfu", idPfu);

                                    cmd.ExecuteNonQuery();

                                    rs.Close();

                                    //Esito positivo e ritorno OK
                                    result = "1#OK";

                                }
                                else
                                {
                                    //Fornisco un errore specifico in base alla casistica
                                    if (OTPHash != CalculateSHA256Hash(otpCode))
                                    {
                                        //Prima di lanciare l'eccezione vado ad incrementare in tabella il numero di retry per la login
                                        if (numRetry < tentativiDisponibili)
                                        {
                                            strSQL = "UPDATE OTP_Access SET numRetry = numRetry + 1 where Server_Id = @idRow";

                                            cmd.CommandText = strSQL;
                                            cmd.Parameters.Clear();

                                            cmd.Parameters.AddWithValue("@idRow", idRow);
                                            cmd.ExecuteNonQuery();

                                            rs.Close();
                                        }
                                        else
                                        {
                                            throw new ArgumentException("CUSTOM:Il codice fornito è errato.");
                                        }
                                    }

                                    if (dataScadenza <= DateTime.Now)
                                    {
                                        throw new ArgumentException("CUSTOM:Il tuo codice è scaduto.");
                                    }

                                    if (isReadOTP)
                                    {
                                        throw new ArgumentException("CUSTOM:Il codice è già stato utilizzato.");
                                    }

                                    //Se sono arrivato in questo punto significa che non sono state lanciate eccezioni,
                                    //ovvero il codice risulta errato ma ci sono ancora tentativi disponibili per ritentare l'accesso
                                    //In questo caso setto result a 1 con argomento RETRY per indicare che si può ritentare
                                    result = "1#" + "RETRY";
                                }
                            }
                            else
                            {
                                throw new ArgumentException("Mancanza del parametro per indicare il tempo di validità dell'OTP");
                            }
                        }
                        else
                        {
                            throw new ArgumentException("Mancanza di record in tabella OTP_Access per l'id fornito " + idRow);
                        }
                    }
                }

                //traccio che è andato a buon fine il giro
                pu.InsertTrace("OTP/VALIDATE", result + " --- numRetry=" + numRetry + " --- Codice OTP Inserito: " + otpCode, Convert.ToString(idPfu));

                //Salvo la traccia nella tabella CTL_LOG_SPID
                using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]))
                {
                    string pfuCodiceFiscale = string.Empty;

                    connection.Open();

                    strSQL = "select pfuCodiceFiscale from ProfiliUtente with(nolock) where idPfu = @idPfu";
                    using (SqlCommand cmd1 = new SqlCommand(strSQL, connection))
                    {
                        cmd1.Parameters.AddWithValue("@idPfu", idPfu);
                        rs = cmd1.ExecuteReader();

                        if (rs.Read())
                        {
                            pfuCodiceFiscale = (string)rs["pfuCodiceFiscale"];

                            rs.Close();
                        }

                        strSQL = "insert into CTL_LOG_SPID(idpfu,AspSessionID,ipChiamante,HTTP_SHIBSESSIONINDEX,HTTP_FISCALNUMBER,LOA,Canale) select @idPfu, '', '', '', @pfuCodiceFiscale, '3', 'CUSTOM'";
                        cmd1.CommandText = strSQL;
                        cmd1.Parameters.Clear();

                        // Aggiungo i parametri
                        cmd1.Parameters.AddWithValue("@pfuCodiceFiscale", pfuCodiceFiscale);
                        cmd1.Parameters.AddWithValue("@idPfu", idPfu);

                        cmd1.ExecuteNonQuery();

                        rs.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                //Vado a ritornare un codice di errore CUSTOM per poterlo mostrare a video senza lavorazioni intermedie.
                //Per l'errore specifico vedere la trace dentro la tabella OTP_Access
                if (ex.Message.Contains("CUSTOM:"))
                    result = "0#" + ex.Message.Replace("CUSTOM:", "");
                else
                    result = "0#" + "Errore nell'elaborazione del servizio, conttatare il supporto tecnico";

                //Salvo la traccia dell'errore
                pu.InsertTrace("OTP/VALIDATE", "ERRORE:" + result + "--- Codice OTP Inserito:" + otpCode + "--- exception trace: " + ex.Message, Convert.ToString(idPfu));
            }
            return result;
        }

        //Metodo per calcolare l'hash SHA-256 di una stringa
        static string CalculateSHA256Hash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] inputBytes = Encoding.UTF8.GetBytes(input);
                byte[] hashBytes = sha256.ComputeHash(inputBytes);

                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    builder.Append(hashBytes[i].ToString("x2"));
                }

                return builder.ToString();
            }
        }

        //Metodo per ricavare il tempo in stringa dati dei secondi
        static string ConvertiSecondiInStringa(int tempoInSeconds)
        {
            if (tempoInSeconds < 0)
            {
                return "Tempo non valido";
            }

            int minuti = tempoInSeconds / 60;
            int secondi = tempoInSeconds % 60;

            string risultato = $"{minuti} {(minuti == 1 ? "minuto" : "minuti")}";

            if (secondi > 0)
            {
                risultato += $" e {secondi} {(secondi == 1 ? "secondo" : "secondi")}";
            }

            return risultato;
        }

        static string GetErrorDescription(string codErrore)
        {
            Dictionary<string, string> errors = new Dictionary<string, string>
            {
                {"0", "Successo"},
                {"203", "Utente inesistente o non attivo o password errata"},
                {"301", "SMS - Impossibile creare il messaggio"},
                {"302", "SMS - Impossibile aggiungere il destinatario"},
                {"303", "SMS - Messaggio non trovato"},
                {"304", "SMS - tutti i destinatari sono in black list (invio a singolo o multipli destinatario)"},
                {"305", "SMS - alcuni dei destinatari sono in black list (invio a destinatari multipli)"},
                {"310", "Messaggio vuoto"},
                {"311", "Mittente vuoto non ammesso"},
                {"701", "CUSTOM:Errore nel formato del numero telefonico"}, //Lo metto Custom per poterlo mostrare lato utente dato che in determinate condizioni l'utente può modificare autonomamente il n. di telefono e quindi correggere in autonomia l'errore
                {"704", "SMS - Numero messaggi e numero destinatari incongruenti"},
                {"710", "Lunghezza eccessiva di un messaggio"},
                {"711", "Lunghezza nulla di un messaggio"},
                {"712", "SMS - Lunghezza eccessiva di un numero telefonico"},
                {"713", "Lunghezza nulla di un numero telefonico / indirizzo destinatario"},
                {"714", "SMS - Numero telefonico non numerico"},
                {"720", "SMS - Tipo di messaggio non ammesso (solo per SMS binari)"},
                {"721", "SMS - Numero di caratteri nella sequenza esadecimale dispari (solo per SMS binari)"},
                {"722", "SMS - Caratteri esadecimali non validi (validi '0'-'9', 'A'-'F', solo per SMS binari)"},
                {"723", "SMS - Utente non abilitato all'invio sms verso il gestore di destinazione"},
                {"725", "SMS - Campo binario troppo lungo"},
                {"730", "Lunghezza OTP errata"},
                {"731", "Maschera formattazione OTP errata"},
                {"732", "Tag OTP assente"},
                {"733", "Mail server non configurato"},
                {"734", "Mail server non raggiungibile"},
                {"735", "Template non trovato"},
                {"736", "Errore di formato template"},
                {"737", "OriginalId ID duplicato e usato per OTP"}
            };

            foreach (var errore in errors)
            {
                if (errore.Key == codErrore)
                {
                    return errore.Value;
                }
            }

            return "";
        }

        static bool CheckPrefissoTelfonico(string numTelefono)
        {
            //Lista nota dei Prefissi telefonici
            Dictionary<string, string> prefissiTelefonici = new Dictionary<string, string>
            {
                //America
                {"1264", "Anguilla"},
                {"54", "Argentina"},
                {"1246", "Barbados"},
                {"591", "Bolivia"},
                {"1345", "Cayman Isole"},
                {"506", "Costa Rica"},
                {"593", "Ecuador"},
                {"1473", "Grenada"},
                {"592", "Guyana"},
                {"504", "Honduras"},
                {"596", "Martinica"},
                {"505", "Nicaragua"},
                {"51", "Perù"},
                {"1869", "St Kitts & Nevis"},
                {"1649", "Turks e Caicos"},
                {"58", "Venezuela"},
                {"599", "Antille Olandesi"},
                {"297", "Aruba"},
                {"501", "Belize"},
                {"55", "Brasile"},
                {"56", "Cile"},
                {"53", "Cuba"},
                {"503", "El Salvador"},
                {"590", "Guadalupa"},
                {"594", "Guyana Francese"},
                {"1284", "Isole Vergini GB"},
                {"52", "Messico"},
                {"507", "Panama"},
                {"1787", "Porto Rico"},
                {"597", "Suriname"},
                {"598", "Uruguay"},
                {"1268", "Antigua e Barbuda"},
                {"1242", "Bahamas"},
                {"1441", "Bermuda"},
                {"57", "Colombia"},
                {"1767", "Dominica"},
                {"1876", "Giamaica"},
                {"502", "Guatemala"},
                {"509", "Haiti"},
                {"1340", "Isole Vergini US"},
                {"1664", "Montserrat"},
                {"595", "Paraguay"},
                {"1809", "Rep. Dominicana"},
                {"1868", "Trinidad e Tobago"},
                {"1", "Usa"},
                
                //Europa
                {"355", "Albania"},
                {"32", "Belgio"},
                {"359", "Bulgaria"},
                {"45", "Danimarca"},
                {"358", "Finlandia"},
                {"350", "Gibilterra"},
                {"299", "Groenlandia"},
                {"39", "Italia"},
                {"370", "Lituania"},
                {"356", "Malta"},
                {"47", "Norvegia"},
                {"351", "Portogallo"},
                {"40", "Romania"},
                {"421", "Slovacchia"},
                {"46", "Svezia"},
                {"36", "Ungheria"},
                {"376", "Andorra"},
                {"375", "Bielorussia"},
                {"357", "Cipro"},
                {"372", "Estonia"},
                {"33", "Francia"},
                {"44", "Gran Bretagna"},
                {"353", "Irlanda"},
                {"371", "Lettonia"},
                {"352", "Lussemburgo"},
                {"373", "Moldavia"},
                {"31", "Olanda"},
                {"377", "Principato Monaco"},
                {"7", "Russia"},
                {"386", "Slovenia"},
                {"41", "Svizzera"},
                {"43", "Austria"},
                {"387", "Bosnia Erzegovina"},
                {"385", "Croazia"},
                {"298", "Faer Oer Isole"},
                {"49", "Germania"},
                {"30", "Grecia"},
                {"354", "Islanda"},
                {"423", "Liechtenstein"},
                {"389", "Macedonia"},
                {"382", "Montenegro"},
                {"48", "Polonia"},
                {"420", "Repubblica Ceca"},
                {"381", "Serbia"},
                {"34", "Spagna"},
                {"380", "Ucraina"},

                //Africa
                {"213", "Algeria"},
                {"267", "Botswana"},
                {"237", "Camerun"},
                {"269", "Comore"},
                {"20", "Egitto"},
                {"241", "Gabon"},
                {"253", "Gibuti"},
                {"240", "Guinea Equatoriale"},
                {"231", "Liberia"},
                {"265", "Malawi"},
                {"222", "Mauritania"},
                {"264", "Namibia"},
                {"236", "Rep. Centrafricana"},
                {"250", "Ruanda"},
                {"232", "Sierra Leone"},
                {"249", "Sudan"},
                {"255", "Tanzania"},
                {"256", "Uganda"},
                {"244", "Angola"},
                {"226", "Burkina Faso"},
                {"238", "Capo Verde"},
                {"242", "Congo"},
                {"291", "Eritrea"},
                {"220", "Gambia"},
                {"224", "Guinea"},
                {"254", "Kenya"},
                {"218", "Libia"},
                {"223", "Mali"},
                {"230", "Mauritius"},
                {"227", "Niger"},
                {"243", "Rep. Dem. Congo"},
                {"221", "Senegal"},
                {"252", "Somalia"},
                {"211", "Sudan del Sud"},
                {"228", "Togo"},
                {"260", "Zambia"},
                {"229", "Benin"},
                {"257", "Burundi"},
                {"235", "Ciad"},
                {"225", "Costa d'Avorio"},
                {"251", "Etiopia"},
                {"233", "Ghana"},
                {"245", "Guinea Bissau"},
                {"266", "Lesotho"},
                {"212", "Marocco"},
                {"258", "Mozambico"},
                {"234", "Nigeria"},
                {"262", "Réunion"},
                {"248", "Seychelles"},
                {"27", "Sudafrica"},
                {"268", "Swaziland"},
                {"216", "Tunisia"},
                {"263", "Zimbabwe"},

                //Asia, oceania e pacifico
                {"93", "Afghanistan"},
                {"61", "Australia"},
                {"880", "Bangladesh"},
                {"855", "Cambogia"},
                {"82", "Corea del Sud"},
                {"63", "Filippine"},
                {"962", "Giordania"},
                {"62", "Indonesia"},
                {"972", "Israele"},
                {"686", "Kiribati"},
                {"961", "Libano"},
                {"60", "Malesia"},
                {"977", "Nepal"},
                {"968", "Oman"},
                {"675", "Papua Nuova Guinea"},
                {"677", "Salomone"},
                {"963", "Siria"},
                {"886", "Taiwan"},
                {"676", "Tonga"},
                {"688", "Tuvalu"},
                {"84", "Vietnam"},
                {"966", "Arabia Saudita"},
                {"994", "Azerbaigian"},
                {"975", "Bhutan"},
                {"86", "Cina"},
                {"971", "Emirati Arabi Uniti"},
                {"995", "Georgia"},
                {"852", "Hong Kong"},
                {"98", "Iran"},
                {"965", "Kuwait"},
                {"853", "Macao"},
                {"976", "Mongolia"},
                {"687", "Nuova Caledonia"},
                {"92", "Pakistan"},
                {"689", "Polinesia Francese"},
                {"685", "Samoa"},
                {"94", "Sri Lanka"},
                {"66", "Thailandia"},
                {"90", "Turchia"},
                {"998", "Uzbekistan"},
                {"967", "Yemen"},
                {"374", "Armenia"},
                {"973", "Bahrein"},
                {"673", "Brunei"},
                {"850", "Corea del Nord"},
                {"679", "Figi"},
                {"81", "Giappone"},
                {"91", "India"},
                {"964", "Iraq"},
                {"996", "Kirghizistan"},
                {"856", "Laos"},
                {"960", "Maldive"},
                {"95", "Myanmar"},
                {"64", "Nuova Zelanda"},
                {"970", "Palestina"},
                {"974", "Qatar"},
                {"65", "Singapore"},
                {"992", "Tagikistan"},
                {"670", "Timor Est"},
                {"993", "Turkmenistan"}
            };

            //Controllo se il numero fornito mathca con uno dei prefissi noti (entrambe le forme di prefisso "+" o "00"
            foreach (var prefisso in prefissiTelefonici)
            {
                if (numTelefono.StartsWith($"+{prefisso.Key}") || numTelefono.StartsWith($"00{prefisso.Key}"))
                {
                    return true;
                }
            }

            return false;
        }
    }
}