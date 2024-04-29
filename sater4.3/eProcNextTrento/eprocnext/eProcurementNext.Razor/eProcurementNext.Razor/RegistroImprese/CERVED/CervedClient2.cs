//using Newtonsoft.Json;
//using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Security.Authentication;

namespace eProcurementNext.RegistroImprese.CERVED
{
    public class CervedClient2 : IParixClient
    {

        //variabili per la versione di tsl 1.2 aggiunte per poter utilizzare un framework .net 3.5 che NON  supporta questo TSL
        public const SslProtocols _Tls12 = (SslProtocols)0x00000C00;
        public const SecurityProtocolType Tls12 = (SecurityProtocolType)_Tls12;

        SqlConnection sqlConn;


        string _responseString = string.Empty;

        string strCause = string.Empty;

        public string CallEndPoint(string strEndPoint)
        {
            // TODO set security Protocol
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls12;
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

            var request = (HttpWebRequest)WebRequest.Create(strEndPoint);

            var response = (HttpWebResponse)request.GetResponse();

            var responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();

            HttpStatusCode StatusCode = response.StatusCode;

            return responseString;
        }

        public T? CallEndPoint<T>(string strEndPoint)
        {
            strCause = "DeserializeObject";

            // TODO set security Protocol
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls12;
            //ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

            var request = (HttpWebRequest)WebRequest.Create(strEndPoint);

            var response = (HttpWebResponse)request.GetResponse();

            var responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();

            HttpStatusCode StatusCode = response.StatusCode;


            if (StatusCode != HttpStatusCode.OK)
            {
                //strOut = "Errore. " + strErrore;

                JObject? o = null;
                //try
                //{
                strCause = "Parse del JSON restituito dal servizio di check coda";
                o = JObject.Parse(responseString);
                //}
                //catch (Exception e)
                //{
                //    throw new Exception(strCause);
                //}


                string msgError = "";

                try
                {

                    msgError = (string)o["errorDescription"];
                }
                catch (Exception)
                {
                }

                if (!string.IsNullOrEmpty(msgError))
                    throw new ApplicationException(msgError);
                else
                    throw new ApplicationException("Errore restituito dal WS " + strEndPoint + " : " + StatusCode + " . " + response.StatusDescription);

                //throw new Exception("Errore nell'invocazione del web service : " + statusDescription);
            }
            strCause = "DeserializeObject";


            T? obj = default(T);
            //TODO: Federico, rimuovere l'utilizzo di newtonsoft.json dalla soluzione. usare in sua vece quello standard dot net core. System.Text.Json
            obj = JsonConvert.DeserializeObject<T>(responseString);

            return obj;
        }

        public string getParixInfo(string CodFisc, string SessionKey, string ConnString, string extra = "")
        {

            string strOut = "";
            string strErrore = "";
            string strCause = "";
            string strEndPoint_1 = "";
            string strEndPoint_2 = "";

            try
            {

                ConnString = Tools.getConnectionString(ConnString);

                strCause = "Apre la connessione al db " + ConnString;
                sqlConn = new SqlConnection(ConnString);
                sqlConn.Open();


                if (string.IsNullOrEmpty(CodFisc))
                {
                    strOut = "Errore. " + "Codice fiscale vuoto";
                    return strOut;
                }

                Tools.GetEndPoint(sqlConn, out strEndPoint_1, out strEndPoint_2);


                //strEndPoint_1 = "https://api.cerved.com/cervedApi/v1/entitySearch/live?testoricerca=" + CodFisc + "&filtroescludicc=false&apikey=qzZBWuGAFGop3hEQ47Hin5xK8Teas73c";

                strEndPoint_1 = strEndPoint_1.Replace("<CODICE>", CodFisc);

                strCause = "chiamata al ws " + strEndPoint_1;

                OutCerved1? objJson = CallEndPoint<OutCerved1>(strEndPoint_1);


                // TODO set security Protocol
                //ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls;
                //ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls12;
                //ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;



                //var request = (HttpWebRequest)WebRequest.Create(strEndPoint_1);

                //var response = (HttpWebResponse)request.GetResponse();

                //var responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();

                //HttpStatusCode  StatusCode = response.StatusCode ;

                //if (StatusCode != HttpStatusCode.OK )
                //{
                //    //strOut = "Errore. " + strErrore;

                //    strCause = "Parse del JSON restituito dal servizio di check coda";
                //    JObject o = JObject.Parse(responseString);

                //    string msgError = "";

                //    try
                //    {

                //        msgError = (string)o["errorDescription"];
                //    }
                //    catch (Exception)
                //    {
                //    }

                //    if (!string.IsNullOrEmpty(msgError))
                //        throw new ApplicationException(msgError);
                //    else
                //        throw new ApplicationException("Errore restituito dal WS " + strEndPoint_1 + " : " + StatusCode + " . " + response.StatusDescription);

                //    //throw new Exception("Errore nell'invocazione del web service : " + statusDescription);
                //}

                //// se arrivo qui è OK

                //OutCerved1  objJson = JsonConvert.DeserializeObject<OutCerved1>(responseString);

                if (objJson.companiesTotalNumber == 0)
                {
                    //strOut = "Errore. " + "Codice fiscale " + CodFisc + " non trovato su CERVED";
                    strOut = "IMP_OCCORRENZA_0";
                    return strOut;
                }

                Tools.InsertParixDati(sqlConn, "LOG_CERVED", CodFisc, "JSON_CERVED_ENTITY_SEARCH", _responseString);

                int IdSoggetto = objJson.companies[0].dati_anagrafici.id_soggetto;
                string strIdSoggetto = IdSoggetto.ToString();

                //strEndPoint_2 = "https://api.cerved.com/cervedApi/v1/entityProfile/live?id_soggetto=" + strIdSoggetto + "&apikey=qzZBWuGAFGop3hEQ47Hin5xK8Teas73c";

                strEndPoint_2 = strEndPoint_2.Replace("<CODICE>", strIdSoggetto);

                // chiama il secondo WS
                strCause = "chiamata al ws " + strEndPoint_2;

                OutCerved2? objJson2 = CallEndPoint<OutCerved2>(strEndPoint_2);

                //request = (HttpWebRequest)WebRequest.Create(strEndPoint_2);

                //response = (HttpWebResponse)request.GetResponse();

                //responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();

                //StatusCode = response.StatusCode;

                //if (StatusCode != HttpStatusCode.OK)
                //{
                //    //strOut = "Errore. " + strErrore;

                //    strCause = "Parse del JSON restituito dal servizio di check coda";
                //    JObject o = JObject.Parse(responseString);

                //    string msgError = "";

                //    try
                //    {

                //        msgError = (string)o["errorDescription"];
                //    }
                //    catch (Exception)
                //    {
                //    }

                //    if (!string.IsNullOrEmpty(msgError))
                //        throw new ApplicationException(msgError);
                //    else
                //        throw new ApplicationException("Errore restituito dal WS " + strEndPoint_2 + " : " + StatusCode + " . " + response.StatusDescription);

                //    //throw new Exception("Errore nell'invocazione del web service : " + statusDescription);
                //}


                // se arrivo qui è OK




                Tools.InsertParixDati(sqlConn, "LOG_CERVED", CodFisc, "JSON_CERVED_ENTITY_PROFILE", _responseString);

                strCause = "DeserializeObject";
                //OutCerved2 objJson2 = JsonConvert.DeserializeObject<OutCerved2>(responseString);


                //azienda cessata
                /*
                il campo codice_stato_attivita / activity status indica qual è la posizione attuale del soggetto
                e può assumere i seguenti valori:

                A = attiva;
                C = cessata;
                D =in procedure;
                F = fallita;
                G = amministrazione giudiziaria;
                I = inattiva;
                L =in scioglimento / liquidazione;
                N =in procedura concorsuale;
                P = iscrizione;
                R = registrata;
                S = sospesa;
                T = cancellata

                 L’utilizzo dei dati del soggetto deve essere vincolato ai valori “A” o “P” o “R” 
                */

                string codice_stato_attivita = "";


                try
                {
                    codice_stato_attivita = objJson2.dati_attivita.codice_stato_attivita;
                }
                catch (Exception)
                {
                }

                if (codice_stato_attivita != "A" && codice_stato_attivita != "P" && codice_stato_attivita != "R" && codice_stato_attivita != "")
                {
                    if (extra == "1")
                        strOut = "AZIENDA_CESSATA";
                    else
                        strOut = "IMP_OCCORRENZA_0";

                    return strOut;
                }



                string strPIVA = objJson2.dati_anagrafici.partita_iva;
                string strRagSoc = objJson2.dati_anagrafici.denominazione;

                string strNatGiur = "";

                try
                {
                    strNatGiur = objJson2.dati_attivita.company_form.code;
                }
                catch (Exception)
                {
                }

                string strMailPec = "";

                strCause = "DeserializeObject - email";

                try
                {

                    if (objJson2.dati_anagrafici.pec.email.Length > 0)
                        strMailPec = objJson2.dati_anagrafici.pec.email[0];
                }
                catch (Exception)
                {
                }



                strCause = "DeserializeObject - indirizzo";
                string strIndirizzo = "";
                string strCAP = "";
                string strComune = "";
                string strCodComuneIstat = "";
                string strRegione = "";
                string strNazione = "";
                string strTelefono = "";
                string strSitoWeb = "";

                try
                {
                    strIndirizzo = objJson2.dati_anagrafici.indirizzo.toponimo;
                    strIndirizzo = strIndirizzo + " " + objJson2.dati_anagrafici.indirizzo.denominazione;
                    strIndirizzo = strIndirizzo + " " + objJson2.dati_anagrafici.indirizzo.civico;

                }
                catch (Exception)
                {
                }

                try
                {
                    strCAP = objJson2.dati_anagrafici.indirizzo.cap;

                }
                catch (Exception)
                {
                }

                try
                {
                    strComune = objJson2.dati_anagrafici.indirizzo.comune;

                }
                catch (Exception)
                {
                }

                try
                {
                    strCodComuneIstat = objJson2.dati_anagrafici.indirizzo.codice_comune_istat;

                }
                catch (Exception)
                {
                }

                try
                {
                    strRegione = objJson2.dati_anagrafici.indirizzo.regione;

                }
                catch (Exception)
                {
                }

                try
                {
                    strNazione = objJson2.dati_anagrafici.indirizzo.nazione;

                }
                catch (Exception)
                {
                }

                try
                {
                    strTelefono = objJson2.dati_anagrafici.telefono;

                }
                catch (Exception)
                {
                }

                try
                {
                    strSitoWeb = objJson2.dati_anagrafici.url_sito_web;

                }
                catch (Exception)
                {
                }



                strCause = "DeserializeObject - dati_attivita";

                string strDataCostituzione = "";
                string strDataIscrizioneREA = "";

                string strSedeCCIIAA = "";
                //strSedeCCIIAA = strSedeCCIIAA.Substring(0, 2);
                string strNumREA = "";
                //strNumREA = strNumREA.Substring(3);

                string strATECO = "";
                string strNACE = "";






                try
                {
                    strDataCostituzione = objJson2.dati_attivita.data_costituzione;
                }
                catch (Exception)
                {
                }
                try
                {
                    strDataIscrizioneREA = objJson2.dati_attivita.data_iscrizione_rea;
                }
                catch (Exception)
                {
                }
                try
                {
                    strSedeCCIIAA = objJson2.dati_attivita.codice_rea;
                    strSedeCCIIAA = strSedeCCIIAA.Substring(0, 2);
                }
                catch (Exception)
                {
                }
                try
                {
                    strNumREA = objJson2.dati_attivita.codice_rea;
                    strNumREA = strNumREA.Substring(3);
                }
                catch (Exception)
                {
                }
                try
                {
                    strATECO = objJson2.dati_attivita.ateco_info.codifica_ateco.codice_ateco;

                }
                catch (Exception)
                {
                }
                try
                {
                    strNACE = objJson2.dati_attivita.ateco_info.codifica_nace.codice;
                }
                catch (Exception)
                {
                }

                string strSIC = "";
                strCause = "DeserializeObject - ateco_info";


                try
                {

                    if (objJson2.dati_attivita.ateco_info.codifiche_sic.Length > 0)
                        strSIC = objJson2.dati_attivita.ateco_info.codifiche_sic[0].codice;
                }
                catch (Exception)
                {
                }

                strCause = "DeserializeObject - codifica_rae";
                string strRAE = "";
                string strSAE = "";
                try
                {
                    strRAE = objJson2.dati_attivita.ateco_info.codifica_rae.codice;
                }
                catch (Exception)
                {
                }
                try
                {
                    strSAE = objJson2.dati_attivita.ateco_info.codifica_sae.codice;
                }
                catch (Exception)
                {
                }

                strCause = "DeserializeObject - dati_economici_dimensionali";
                string strNumDip = "";
                string strAnnoUltBil = "";
                string strDataChiusura = "";
                string strFatturato = "";
                string strCapitale = "";
                string strMOL = "";
                string strAttivo = "";
                string strPatrimonio = "";
                string strUtilePerdita = "";




                try
                {
                    strNumDip = objJson2.dati_economici_dimensionali.numero_dipendenti.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strAnnoUltBil = objJson2.dati_economici_dimensionali.anno_ultimo_bilancio.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strDataChiusura = objJson2.dati_economici_dimensionali.data_chiusura_ultimo_bilancio;
                }
                catch (Exception)
                {
                }
                try
                {
                    strFatturato = objJson2.dati_economici_dimensionali.fatturato.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strCapitale = objJson2.dati_economici_dimensionali.capitale_sociale.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strMOL = objJson2.dati_economici_dimensionali.mol.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strAttivo = objJson2.dati_economici_dimensionali.attivo.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strPatrimonio = objJson2.dati_economici_dimensionali.patrimonio_netto.ToString();
                }
                catch (Exception)
                {
                }
                try
                {
                    strUtilePerdita = objJson2.dati_economici_dimensionali.utile_perdita_esercizio.ToString();
                }
                catch (Exception)
                {
                }







                // cancella i dati da Parix_Dati
                strCause = "cancellazione preventiva dati da Parix_Dati";
                var strSql = "delete from Parix_Dati where sessionid = @sessionid and codice_fiscale = @CodFisc";

                var cmd1 = new SqlCommand(strSql, sqlConn);


                cmd1.Parameters.Add("@sessionid", SqlDbType.VarChar).Value = SessionKey;
                cmd1.Parameters.Add("@CodFisc", SqlDbType.VarChar).Value = CodFisc;

                cmd1.ExecuteNonQuery();

                // Inserisce i dati in  Parix_Dati
                strCause = "Inserisce i dati in  Parix_Dati";

                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "RAGSOC", strRagSoc);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "codicefiscale", CodFisc);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "PIVA", strPIVA);

                strCause = "Inserisce i dati in  Parix_Dati - NatGiur";

                if (string.IsNullOrEmpty(strNatGiur))
                    strNatGiur = "";

                if (strNatGiur != "")
                    strNatGiur = Tools.getDescFormaSoc(sqlConn, strNatGiur);

                strCause = "Inserisce i dati in  Parix_Dati - NAGI";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "NAGI", strNatGiur);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "IscrCCIAA", strNumREA);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "SedeCCIAA", strSedeCCIIAA);

                strCause = "Inserisce i dati in  Parix_Dati - ANNOCOSTITUZIONE";

                if (string.IsNullOrEmpty(strDataCostituzione))
                    strDataCostituzione = "";

                if (strDataCostituzione.Length >= 10)
                    Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "ANNOCOSTITUZIONE", strDataCostituzione.Substring(6, 4));
                strCause = "Inserisce i dati in  Parix_Dati - LOCALITALEG";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "LOCALITALEG", strComune);
                strCause = "Inserisce i dati in  Parix_Dati - comune";

                string strCodComune = "";

                if (string.IsNullOrEmpty(strCodComuneIstat))
                {
                    strCodComuneIstat = "";
                    strCodComune = "";
                }
                else
                {
                    strCause = "Inserisce i dati in  Parix_Dati - Tools.GetComune";
                    Tools.GetComune(sqlConn, strCodComuneIstat, out strCodComune);
                }


                strCause = "Inserisce i dati in  Parix_Dati - Inserimento del comune";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "aziLocalitaLeg2", strCodComune);

                if (strCodComune != "")
                {
                    strCause = "Inserisce i dati in  Parix_Dati - strCodComune";
                    string[] subs = strCodComune.Split('-');
                    strCause = "Inserisce i dati in  Parix_Dati - provincia";
                    string strProv = strCodComune;
                    strProv = strProv.Replace("-" + subs[subs.Length - 1], "");
                    strCause = "Inserisce i dati in  Parix_Dati - Getprovincia";
                    string strDescrProv;
                    Tools.GetProvincia(sqlConn, strProv, out strDescrProv);

                    Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "PROVINCIALEG", strDescrProv);
                    Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "aziProvinciaLeg2", strProv);
                }

                strCause = "Inserisce i dati in  Parix_Dati - strNazione";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "aziStatoLeg", strNazione);
                strCause = "Inserisce i dati in  Parix_Dati - CAPLEG";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "CAPLEG", strCAP);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "INDIRIZZOLEG", strIndirizzo);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "NUMTEL", strTelefono);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "EMail", strMailPec);
                strCause = "Inserisce i dati in  Parix_Dati - ATECO";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "ATECO", strATECO);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "Numerodipendenti", strNumDip);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "FatturatoFornitore", strFatturato);
                strCause = "Inserisce i dati in  Parix_Dati - CapitaleSociale";
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "CapitaleSociale", strCapitale);
                Tools.InsertParixDati(sqlConn, SessionKey, CodFisc, "PatrimonioNetto", strPatrimonio);
            }
            catch (Exception ex1)
            {
                strErrore = "TS_AEC.sendCompany - " + strCause + " - " + ex1.Message + " [" + DateTime.Now + "]";
                strOut = "Errore. " + strErrore;
                // scrive errore nell'event viewer
                //TODO
                //WriteToEventLog(strErrore);
            }
            finally
            {
                try
                {
                    sqlConn.Close();
                }
                catch (Exception)
                { }
            }

            return strOut;
        }
    }
}
