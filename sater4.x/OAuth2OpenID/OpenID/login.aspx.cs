using Newtonsoft.Json;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Security;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;
using System.Web;

namespace OAuth2OpenID.OpenID
{
    public partial class login : System.Web.UI.Page
    {
        //variabili per la versione di tsl 1.2 aggiunte per poter utilizzare un framework .net 3.5 che NON  supporta questo TSL
        public const SslProtocols _Tls12 = (SslProtocols)0x00000C00;
        public const SecurityProtocolType Tls12 = (SecurityProtocolType)_Tls12;

        protected void Page_Load(object sender, EventArgs e)
        {
            string strCause = "";
            SqlConnection sqlConn = null;

            try
            {

        
                strCause = "Forzo il TLS 1.2";
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                strCause = "Recupero connectionstring";
                string connectionString = ConfigurationManager.AppSettings["db.conn"];

                strCause = "Init SqlConnection";
                sqlConn = new SqlConnection(connectionString);

                strCause = "Apertura connessione";
                sqlConn.Open();

                strCause = "Scrittura nel LOG";
                Util.logUtente(sqlConn, Request, "OpenID\\login.aspx", "Richiesto login OAuth/OpenID");

                //1. generazione delll'oggetto di autenticazione PKCE
                strCause = "Creazione autenticazione PKCE";
                PKCE pkceAuth = new PKCE(sqlConn);

                //2. recupero dei parametri di ambiente, come discovery endpoint, client_id, etc
                strCause = "Recupero i parametri di ambiente";
                string discoveryUrl = Util.getSYS(sqlConn, "OPENID_URL_DISCOVERY");
                string client_id = Util.getSYS(sqlConn, "OPENID_CLIENT_KEY");
                string redirect_uri = Util.getSYS(sqlConn, "OPENID_REDIRECT_URI");
                string scope = Util.getSYS(sqlConn, "OPENID_SCOPE");

                if ( string.IsNullOrEmpty(scope) )
                {
                    scope = "openid";
                }

                //Salvataggio dell'autenticazione PKCE nel database con restituzione di un valore di aggancio ( sfruttiamo il parametro STATE )
                string stateGuid = pkceAuth.save();

                OpenIdConfiguration conf = null;

                //Se è presente un endpoint di discovery per recuperarela configurazione
                if (!string.IsNullOrEmpty(discoveryUrl))
                {

                    //3. recupero dati di configurazione dal discovery endpoint
                    strCause = "Recupero configurazione dal discovery endpoint";
                    string jsonDiscovery = Util.invoke_GET_WS(discoveryUrl, "");

                    if (string.IsNullOrEmpty(jsonDiscovery))
                        throw new ApplicationException("Output del discovery vuoto");

                    strCause = "Lettura informazioni dall'output del discovery";
                    conf = JsonConvert.DeserializeObject<OpenIdConfiguration>(jsonDiscovery);

                }
                else
                {
                    conf = new OpenIdConfiguration
                    {
                        authorization_endpoint = Util.getSYS(sqlConn, "OPENID_AUTHORIZATION_ENDPOINT")
                    };
                }

                if (string.IsNullOrEmpty(conf.authorization_endpoint))
                    throw new ApplicationException("authorization_endpoint vuoto");

                //4. composizione parametri per redirect a authorization_endpoint
                string authorizationQueryString = "";
                strCause = "Composizione parametri da passare all'authorization_endpoint";

                /*
                    response_type = code,
                    client_id = rZvGM5gtHdGmCJ7bAnj45W4bip4a //ClientKey ricevuto via mail
                    redirect_uri = https://spwebapp.it //url di risposta per l’authorization_code
                    state = A4rF8t //Es. Random string per prevenzione CSRF
                    scope = openid
                    code_challenge = WIwW8sZaGc...X2ff // code_challenge generato per test PKCE
                    code_challenge_method = S256 *
                 */

                authorizationQueryString = "response_type=code";
                authorizationQueryString += "&client_id=" + HttpUtility.UrlEncode(client_id);
                authorizationQueryString += "&redirect_uri=" + HttpUtility.UrlEncode(redirect_uri);
                //authorizationQueryString += "&state=" + HttpUtility.UrlEncode(RestUtil.RandomString(8));
                authorizationQueryString += "&state=" + HttpUtility.UrlEncode(stateGuid);
                authorizationQueryString += "&scope=" + HttpUtility.UrlEncode(scope);
                authorizationQueryString += "&code_challenge=" + HttpUtility.UrlEncode(pkceAuth.code_challenge );
                authorizationQueryString += "&acr_values=" + HttpUtility.UrlEncode("https://www.spid.gov.it/SpidL2");
                authorizationQueryString += "&code_challenge_method=S256";

                Util.logUtente(sqlConn, Request, "OpenID\\login.aspx", "Invocazione " + conf.authorization_endpoint + "?" + authorizationQueryString);

                strCause = "Response.Redirect verso " + conf.authorization_endpoint + "?" + authorizationQueryString;

                Response.Redirect(conf.authorization_endpoint + "?" + authorizationQueryString, false);
                return;

            }
            catch (Exception ex)
            {

                string msgError = "ERRORE DI RUN TIME. " + strCause + " - " + ex.Message;

                if (ex.GetType().FullName == "System.ApplicationException")
                {
                    msgError = ex.Message;
                }

                Util.logUtente(sqlConn, Request, "OpenID\\login.aspx", msgError, true);
                Response.Write(msgError);

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

        private static bool RemoteCertificateValidate(object sender, X509Certificate cert, X509Chain chain, SslPolicyErrors error)
        {
            // trust any certificate
            System.Console.WriteLine("Warning, ECCEZIONE DI RemoteCertificateValidate");
            return true;
        }
    }
}