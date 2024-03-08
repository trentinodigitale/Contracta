using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Security;
using System.Runtime.CompilerServices;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;
using System.Web;

namespace OAuth2OpenID.OpenID
{
    public partial class access : System.Web.UI.Page
    {
        //variabili per la versione di tsl 1.2 aggiunte per poter utilizzare un framework .net 3.5 che NON  supporta questo TSL
        public const SslProtocols _Tls12 = (SslProtocols)0x00000C00;
        public const SecurityProtocolType Tls12 = (SecurityProtocolType)_Tls12;

        private static bool RemoteCertificateValidate(object sender, X509Certificate cert, X509Chain chain, SslPolicyErrors error)
        {
            // trust any certificate
            System.Console.WriteLine("Warning, ECCEZIONE DI RemoteCertificateValidate");
            return true;
        }

        protected void Page_Load(object sender, EventArgs e)
        {

            string strCause = "";
            SqlConnection sqlConn = null;

            try
            {
                strCause = "Forzo il TLS 1.2";
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                string Authorization_code = Request.QueryString["code"];
                string stateGuid = Request.QueryString["state"];
                string idpError = Request.QueryString["error"];

                if (!string.IsNullOrEmpty(idpError))
                {
                    strCause = "Lancio un eccezione per errore lato idp";
                    throw new ApplicationException("Errore lato idp : " + idpError);
                }

                if (string.IsNullOrEmpty(Authorization_code) || string.IsNullOrEmpty(stateGuid))
                {
                    strCause = "Redirect su /Application/, parametri obbligatori non passati dall'idp";
                    Response.Redirect("/Application/", false);
                    return;
                    //throw new ApplicationException("PARAMETRI OBBLIGATORI ASSENTI");
                }

                strCause = "Recupero connectionstring";
                string connectionString = ConfigurationManager.AppSettings["db.conn"];

                strCause = "Init SqlConnection";
                sqlConn = new SqlConnection(connectionString);

                strCause = "Apertura connessione";
                sqlConn.Open();

                //testResponseSPID(sqlConn);

                strCause = "Scrittura nel LOG";
                Util.logUtente(sqlConn, Request, "OpenID\\access.aspx", "Richiesto login OAuth/OpenID step 2");

                //1. generazione delll'oggeto di autenticazione PKCE
                strCause = "Recupero dati di autenticazione PKCE";
                PKCE pkceAuth = new PKCE(sqlConn, stateGuid);

                //2. recupero dei parametri di ambiente, come discovery endpoint, client_id, etc
                strCause = "Recupero i parametri di ambiente";
                string discoveryUrl = Util.getSYS(sqlConn, "OPENID_URL_DISCOVERY");
                string client_id = Util.getSYS(sqlConn, "OPENID_CLIENT_KEY");
                string client_secret = Util.getSYS(sqlConn, "OPENID_CLIENT_SECRET");
                string redirect_uri = Util.getSYS(sqlConn, "OPENID_REDIRECT_URI");

                OpenIdConfiguration conf = null;

                //Se è presente un endpoint di discovery per recuperarela configurazione
                if (!string.IsNullOrEmpty(discoveryUrl))
                {
                    //3. recupero dati di configurazione dal discovery endpoint
                    strCause = "Recupero configurazione dal discovery endpoint";
                    string jsonDiscovery = Util.invoke_GET_WS(discoveryUrl, "");

                    if (string.IsNullOrEmpty(jsonDiscovery))
                        throw new Exception("Output del discovery vuoto");

                    strCause = "Lettura informazioni dall'output del discovery";
                    conf = JsonConvert.DeserializeObject<OpenIdConfiguration>(jsonDiscovery);
                }
                else
                {
                    conf = new OpenIdConfiguration
                    {
                        token_endpoint = Util.getSYS(sqlConn, "OPENID_TOKEN_ENDPOINT")
                    };

                }



                //4. composizione parametri per redirect a authorization_endpoint
                string tokenParams = "";
                strCause = "Composizione parametri da passare al tokenEndpoint";

                /*
                    grant_type= authorization_code
                    code=kjfla...2341rar //ricevuto dall’endpoint Authorization
                    redirect_uri=https://spwebapp.it //url dove ricevere la risposta con il token
                    client_id= rZvGM5gtHdGjCJ7bAnj45W4bip4a //ClientKey ricevuto via mail
                    client_secret= mFCqzPbPf7AtVbXkaGIlu_zz63Ia //ClientSecret ricevuto via mail
                    code_verifier=gdgTJ464...JHg7 // code_verifier generato per test PKCE
                 */

                tokenParams = "grant_type=authorization_code";
                tokenParams += "&code=" + HttpUtility.UrlEncode(Authorization_code);
                tokenParams += "&redirect_uri=" + HttpUtility.UrlEncode(redirect_uri);
                tokenParams += "&client_id=" + HttpUtility.UrlEncode(client_id);
                tokenParams += "&client_secret=" + HttpUtility.UrlEncode(client_secret);
                tokenParams += "&code_verifier=" + HttpUtility.UrlEncode(pkceAuth.code_verifier);

                //esempio : "grant_type=authorization_code&client_id=%24%7Baccount.clientId%7D&code_verifier=YOUR_GENERATED_CODE_VERIFIER&code=YOUR_AUTHORIZATION_CODE&redirect_uri=%24%7Baccount.callback%7D",

                Util.traceDB(sqlConn, "OpenID\\access.aspx", "Invocazione di " + conf.token_endpoint + " POST: " + tokenParams);

                strCause = "Invocazione ws di token_endpoint";
                string jsonAuth = Util.invoke_POST_WS(conf.token_endpoint, tokenParams);

                Util.traceDB(sqlConn, "OpenID\\access.aspx", "output dal token_endpoint : " + jsonAuth);

                if (string.IsNullOrEmpty(jsonAuth))
                    throw new ApplicationException("output vuoto dal ws di token_endpoint");

                JObject auth = JObject.Parse(jsonAuth);

                string authError = "";

                try
                {
                    authError = (string)auth["error_description"];
                }
                catch (Exception)
                {
                }

                if (!string.IsNullOrEmpty(authError))
                    throw new ApplicationException("ERRORE invoke_POST_WS: " + authError);

                string access_token = "";
                string id_token = ""; // utile per il logout

                try
                {
                    access_token = (string)auth["access_token"];
                }
                catch (Exception)
                {
                }

                try
                {
                    id_token = (string)auth["id_token"];
                }
                catch (Exception)
                {
                }

                if (string.IsNullOrEmpty(access_token))
                    throw new ApplicationException("access_token non restuito dal token_endpoint");

                strCause = "Invocazione ws di userinfo_endpoint";
                string jsonUserInfo = Util.invoke_AccessToken_WS(conf.userinfo_endpoint, access_token);

                Util.traceDB(sqlConn, "OpenID\\access.aspx", "output dal userinfo_endpoint : " + jsonUserInfo);

                if (string.IsNullOrEmpty(jsonUserInfo))
                    throw new ApplicationException("output vuoto dal ws di userinfo_endpoint");

                JObject userInfo = JObject.Parse(jsonUserInfo);

                authError = "";

                try
                {
                    authError = (string)userInfo["error_description"];
                }
                catch (Exception)
                {
                }

                if (!string.IsNullOrEmpty(authError))
                    throw new ApplicationException("ERRORE invoke_AccessToken_WS: " + authError);


                string codice_fiscale = "";
                string canale = "";
                string LOA = "";

                strCause = "Recupero dati CF e canale di autentificazione:" + jsonUserInfo;
                string claim_key_cf = Util.getSYS(sqlConn, "OPENID_CLAIM_KEY");
                string claim_canale = Util.getSYS(sqlConn, "OPENID_CLAIM_KEY_CANALE");

                string strVirtualDirectory = Util.getSYS(sqlConn, "NOMEAPPLICAZIONE");

                if (string.IsNullOrEmpty(claim_key_cf))
                    claim_key_cf = "sub";

                try
                {
                    codice_fiscale = (string)userInfo[claim_key_cf];

                    canale = (string)userInfo[claim_canale];

                    //se non trovo il canale come indicato nella sys porovo a cercarlo tutto minuscolo 
                    //dal 31/01/2024 abbiamo visto su lazio che ci arriva ext_auth_channel 
                    if (string.IsNullOrEmpty(canale))
                    {
                        canale = (string)userInfo[claim_canale.ToLower()];
                    }

                    if (claim_canale.ToLower() == "providername" || claim_canale.ToLower() == "auth_type")  //MOLISE e ESTAR
                    {
                        if (canale.ToUpper() == "CNS")
                        {
                            canale = "CNS";
                        }
                        else if (canale.ToUpper() == "CIEID" || canale.ToUpper() == "CIE") //CieId
                        {
                            canale = "CIE";
                        }
                        else
                        {
                            canale = "SPID";
                        }
                        LOA = "3";
                    }

                    if (claim_canale.ToLower() == "issuersource") //TND
                    {
                        var issuersource = (JObject)userInfo["issuersource"];
                        canale = (string)issuersource["claim_canale"];
                        LOA = "3";
                    }

                    //applicato tolower 
                    if (claim_canale.ToLower() == "ext_auth_channel") //STELLA 
                    {
                        LOA = (string)userInfo["extLoA"]; //ext_LoA
                        if (string.IsNullOrEmpty(LOA))
                        {
                            LOA = (string)userInfo["ext_LoA"];
                            //dal 31(01/2024 ciu arriva tutto minuscolo
                            //"{\"fiscal_number\":\"MLNBNM67R31F839H\",\"sub\":\"MLNBNM67R31F839H\",\"ext_auth_channel\":\"SPID\",\"parse_fiscal_number\":\"MLNBNM67R31F839H\",\"ext_loa\":\"LoA3\",\"given_name\":\"BRUNO MARIA\",\"family_name\":\"MOLINO\"}"
                            if (string.IsNullOrEmpty(LOA))
                            {
                                LOA = (string)userInfo["ext_loa"];
                            }
                        }

                        if (LOA.ToLower() == "loa3")
                        {
                            LOA = "3";
                        }
                        if (LOA.ToLower() == "loa4")
                        {
                            LOA = "4";
                        }

                        if (canale.ToLower() == "spid")
                        {
                            canale = "SPID";
                        }

                        if (canale.ToLower() == "shared_cie") /*SHARED_cie*/
                        {
                            canale = "CIE";
                        }

                        if (canale.ToLower() == "tscns") /*TSCNS*/
                        {
                            canale = "CNS";
                        }
                    }



                }
                catch (Exception)
                {
                    codice_fiscale = (string)userInfo[claim_key_cf];
                }

                if (string.IsNullOrEmpty(codice_fiscale))
                {
                    //Response.Redirect("./output.asp?lo=lista_attivita&ACCESSO=CodiceFiscaleVuoto",false)
                    Response.Redirect("/" + strVirtualDirectory + "/OpenID/output.asp?lo=lista_attivita&ACCESSO=CodiceFiscaleVuoto", false);
                    return;
                }

                codice_fiscale = codice_fiscale.ToUpper();

                if (codice_fiscale.StartsWith("TINIT-"))
                {
                    codice_fiscale = codice_fiscale.Replace("TINIT-", "");
                }

                strCause = "Ricerca utente per codice fiscale";
                string strSQL = "select pfulogin , pfuidAzi , cast( NEWID() as varchar(100)) as ID, cast( NEWID() as varchar(100)) as ID2 from profiliutente with(nolock) inner join aziende with(nolock) on pfuidazi = idazi where aziDeleted = 0 and pfuDeleted = 0 and pfuCodiceFiscale = @codice_fiscale";

                SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
                cmd.Parameters.Add("@codice_fiscale", SqlDbType.NVarChar, 4000).Value = codice_fiscale;

                SqlDataReader rs = null;

                try
                {
                    using (rs = cmd.ExecuteReader())
                    {
                        if (rs.Read()) //movefirst
                        {

                            string pfulogin = "";
                            int pfuidAzi = 0;
                            string guid = "";
                            string guid2 = "";

                            strCause = "Lettura dei dati utente in aflink";
                            pfulogin = rs.GetString(0);
                            pfuidAzi = rs.GetInt32(1);
                            guid = rs.GetString(2);
                            guid2 = rs.GetString(3);

                            strCause = "Verifica match multiplo";
                            bool multiOccurs = rs.Read(); //Se c'è più di 1 occorrenza

                            rs.Close();

                            Util.traceLoginFederato(sqlConn, guid, pfulogin, codice_fiscale);

                            if (!string.IsNullOrEmpty(id_token))
                                Util.saveIdToken(sqlConn, guid2, id_token);

                            if (multiOccurs)
                            {
                                if (Util.saveLogSPID(sqlConn, Request, jsonUserInfo, codice_fiscale, "MULTI", LOA, canale) == true)
                                {
                                    Response.Redirect("/" + strVirtualDirectory + "/OpenID/output.asp?lo=lista_attivita&ACCESSO=Multi&CF=" + codice_fiscale + "&LOGINFEDERA=" + HttpUtility.UrlEncode(guid) + "&TMPTK=" + HttpUtility.UrlEncode(guid2), false);
                                }
                                else
                                {
                                    throw new ApplicationException("ERRORE inserimento CTL_LOG_SPID-MULTI - " + DateTime.Now);

                                }

                            }
                            else
                            {
                                if (Util.saveLogSPID(sqlConn, Request, jsonUserInfo, codice_fiscale, "CONFIRM", LOA, canale) == true)
                                {
                                    Response.Redirect("/" + strVirtualDirectory + "/login.asp?redirectback=yes&chiamante=/portale/index.php&strMnemonicoMP=PA&LOGINFEDERA=" + HttpUtility.UrlEncode(guid) + "&FEDERA_AZI=" + pfuidAzi.ToString() + "&TMPTK=" + HttpUtility.UrlEncode(guid2), false);
                                }
                                else
                                {

                                    throw new ApplicationException("ERRORE inserimento CTL_LOG_SPID-CONFIRM - " + DateTime.Now);
                                }

                            }

                            return;

                        }
                        else
                        {

                            rs.Close();

                            string newID = Util.RandomString(32);
                            Util.saveIdToken(sqlConn, newID, id_token);
                            if (Util.saveLogSPID(sqlConn, Request, jsonUserInfo, "", "DENIED", "", "") == true)
                            {
                                Response.Redirect("/" + strVirtualDirectory + "/OpenID/output.asp?lo=lista_attivita&ACCESSO=NonTrovato&TMPTK=" + HttpUtility.UrlEncode(newID) + "&CF=" + codice_fiscale, false);
                                return;
                            }
                            else
                            {
                                throw new ApplicationException("ERRORE inserimento CTL_LOG_SPID-DENIED - " + DateTime.Now);

                            }


                        }
                    }
                }
                catch (Exception)
                {
                    throw;
                }
                finally
                {
                    try
                    {
                        rs.Close();
                    }
                    catch (Exception) { }
                }




            }
            catch (Exception ex)
            {

                string msgError = "ERRORE DI RUN TIME. " + strCause + " - " + ex.Message;

                if (ex.GetType().FullName == "System.ApplicationException")
                {
                    msgError = ex.Message;
                }

                Util.logUtente(sqlConn, Request, "OpenID\\access.aspx", msgError, true);
                Response.Write(msgError);

                return;

            }
            finally
            {
                if (sqlConn != null)
                {
                    if (sqlConn.State == System.Data.ConnectionState.Open)
                    {
                        sqlConn.Close();
                    }
                }
            }

        }


        public static void testResponseSPID(SqlConnection sqlConn)
        {
            string codice_fiscale = "";
            string canale = "";
            string LOA = "";

            try
            {
                string claim_key_cf = Util.getSYS(sqlConn, "OPENID_CLAIM_KEY");
                string claim_canale = Util.getSYS(sqlConn, "OPENID_CLAIM_KEY_CANALE");
                var json = "{\"fiscal_number:\"PRRFRZ82R23H501U\",\"sub\":\"PRRFRZ82R23H501U\",\"ext_auth_channel\":\"SPID\",\"parse_fiscal_number\":\"PRRFRZ82R23H501U\",\"ext_loa\":\"LoA3\",\"given_name\":\"Fabrizio\",\"family_name\":\"Pirrone\"}";
                JObject userInfo = JObject.Parse(json);
                codice_fiscale = (string)userInfo[claim_key_cf];

                canale = (string)userInfo[claim_canale];

                if (string.IsNullOrEmpty(canale))
                {
                    canale = (string)userInfo[claim_canale.ToLower()];
                }

                if (claim_canale.ToLower() == "ext_auth_channel") //STELLA 
                {
                    LOA = (string)userInfo["extLoA"]; //ext_LoA
                    if (string.IsNullOrEmpty(LOA))
                    {
                        LOA = (string)userInfo["ext_LoA"];
                        if (string.IsNullOrEmpty(LOA))
                        {
                            LOA = (string)userInfo["ext_loa"];
                        }
                    }

                    if (LOA.ToLower() == "loa3")
                    {
                        LOA = "3";
                    }
                    if (LOA.ToLower() == "loa4")
                    {
                        LOA = "4";
                    }

                    if (canale.ToLower() == "spid")
                    {
                        canale = "SPID";
                    }

                    if (canale.ToLower() == "shared_cie") /*SHARED_cie*/
                    {
                        canale = "CIE";
                    }

                    if (canale.ToLower() == "tscns") /*TSCNS*/
                    {
                        canale = "CNS";
                    }


                }
            }
            catch (Exception ex)
            {
                Util.traceDB(sqlConn, "OpenID\\access.aspx", "ERRORE funzione saveLogSPID : Canale = " + canale + " LOA = " + LOA + " ERRORE = " + ex.Message);
            }

        }
    }
}