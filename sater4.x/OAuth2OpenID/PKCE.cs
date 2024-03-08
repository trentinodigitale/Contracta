using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace OAuth2OpenID
{

    /// <summary>
    /// PKCE : Proof Key for Code Exchange
    /// </summary>
    public class PKCE
    {
        public string code_verifier { get; } //deve avere una lunghezza compresa tra 43 e 128 caratteri e deve essere generato con un algoritmo crittografico ad alta entropia.
        public string code_challenge { get; } //deve essere generato con algoritmo SHA256.

        private string access_guid = ""; //newid() che ci permette di riagganciare la coppia di chiavi pkce tramite la ctl_access_guid

        private SqlConnection sqlConn = null;

        public PKCE(SqlConnection sqlConn)
        {
            /* FASE 1. I CODICE PKCE VENGONO GENERATI */
            this.code_verifier = generateCodeVerifier();
            this.code_challenge = generateCodeChallange(this.code_verifier);
            this.sqlConn = sqlConn;
        }

        public PKCE(SqlConnection sqlConn, string stateGuid)
        {
            /* FASE 2. I CODICE PKCE RECUPERATI A PARTIRE DALLO STATEGUID */

            string strSQL = @"SET NOCOUNT ON
                select PKCE_code_challenge, PKCE_code_verifier from CTL_ACCESS_BARRIER with(nolock) where guid = @stateGuid
                DELETE FROM CTL_ACCESS_BARRIER where guid = @stateGuid";

            SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
            cmd.Parameters.Add("@stateGuid", SqlDbType.NVarChar, 4000).Value = stateGuid;

            SqlDataReader rs = null;

            try
            {
                using (rs = cmd.ExecuteReader())
                {
                    if (rs.Read())
                    {
                        this.code_challenge = rs.GetString(0);
                        this.code_verifier = rs.GetString(1);
                    }
                    else
                        throw new ApplicationException("stateGuid non trovato. Errore recupero dati PKCE");
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


        public string getAccessGuid()
        {
            return this.access_guid;
        }


        public string old_generateCodeVerifier()
        {
            try
            {

                RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
                var byteArray = new byte[32];
                provider.GetBytes(byteArray);
                return getBase64(byteArray);

            }
            catch (Exception ex)
            {
                throw new Exception("Errore nella generazione del code verifier." + ex.Message);
            }

        }

        public string generateCodeVerifier()
        {
            var rng = RandomNumberGenerator.Create();

            var bytes = new byte[32];
            rng.GetBytes(bytes);

            // It is recommended to use a URL-safe string as code_verifier.
            // See section 4 of RFC 7636 for more details.
            var code_verifier = Convert.ToBase64String(bytes)
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');

            return code_verifier;
        }

        public string generateCodeChallange(string codeVerifier)
        {
            var code_challenge = string.Empty;
            using (var sha256 = SHA256.Create())
            {
                var challengeBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(code_verifier));
                code_challenge = Convert.ToBase64String(challengeBytes)
                    .TrimEnd('=')
                    .Replace('+', '-')
                    .Replace('/', '_');
            }
            return code_challenge;
        }

        public string old_generateCodeChallange(string codeVerifier)
        {
            try
            {
                byte[] bytes = Encoding.ASCII.GetBytes(codeVerifier);
                byte[] hashBytes = null;

                hashBytes = new System.Security.Cryptography.SHA256CryptoServiceProvider().ComputeHash(bytes);
                return getBase64(hashBytes);
            }
            catch (Exception ex)
            {
                throw new Exception("Errore nella generazione del code challange." + ex.Message);
            }

        }

        private string getBase64(byte[] hashBytes)
        {
            string str64 = Convert.ToBase64String(hashBytes, Base64FormattingOptions.None);

            //Togliamo il carattere "=" di fine stringa
            str64 = str64.Remove(str64.Length - 1);

            return str64;
        }

        public string save()
        {

            this.access_guid = "";

            //Inseriamo l'access guid con una data di 1 usare superiore al getDate(). Questo per evitare che venga cancelato dopo 60 secondi dal metodo 'insertAccessBarrier'.
            //  in questo giro 60 secondi potrebbero non essere sufficienti per permettere all'utente di autenticarsi e ritornare su aflink
            string strSQL = @"SET NOCOUNT ON 
                    DECLARE @guid varchar(50)
                    select @guid = newid()
                    INSERT INTO CTL_ACCESS_BARRIER(guid,data, PKCE_code_challenge, PKCE_code_verifier) values(@guid, DATEADD(hour, 1, getdate()), @PKCE_code_challenge, @PKCE_code_verifier)
                    delete from CTL_ACCESS_BARRIER where datediff(SECOND, data, getdate()) > 60
                    select @guid as guid";

            SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
            cmd.Parameters.Add("@PKCE_code_challenge", SqlDbType.NVarChar, 4000).Value = this.code_challenge;
            cmd.Parameters.Add("@PKCE_code_verifier", SqlDbType.NVarChar, 4000).Value = this.code_verifier;

            SqlDataReader rs = null;

            try
            {
                using (rs = cmd.ExecuteReader())
                {
                    if (rs.Read())
                    {
                        this.access_guid = rs.GetString(0);
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
                catch (Exception){}
            }


            if (string.IsNullOrEmpty(this.access_guid))
            {
                throw new Exception("Access guid vuoto");
            }

            return this.access_guid;

        }

    }
}