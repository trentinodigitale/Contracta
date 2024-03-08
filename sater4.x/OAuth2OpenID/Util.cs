using Newtonsoft.Json.Linq;
using RestSharp;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Web;

namespace OAuth2OpenID
{
    public class Util
    {
        private static Random random = new Random();

        public static string RandomString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, length)
              .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        public static string legacy_invoke_GET_WS(string targetPage)
        {
            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(targetPage);
            request.Method = "GET";
            String output = String.Empty;


            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            {
                Stream dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                output = reader.ReadToEnd();
                reader.Close();
                dataStream.Close();
            }

            return output;

        }

        public static string legacy_invoke_POST_WS(string targetPage, string postdata)
        {
            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(targetPage);

            var data = Encoding.ASCII.GetBytes(postdata);

            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = data.Length;

            String output = String.Empty;

            using (var stream = request.GetRequestStream())
            {
                stream.Write(data, 0, data.Length);
            }

            var response = (HttpWebResponse)request.GetResponse();
            output = new StreamReader(response.GetResponseStream()).ReadToEnd();

            return output;

        }

        public static string invoke_POST_WS(string targetPage, string postdata)
        {
            var client = new RestClient(targetPage);
            var request = new RestRequest(Method.POST);
            request.AddHeader("content-type", "application/x-www-form-urlencoded");
            request.AddParameter("application/x-www-form-urlencoded", postdata, ParameterType.RequestBody);
            IRestResponse response = client.Execute(request);

            string output = response.Content;

            //if (response.StatusCode == HttpStatusCode.OK)
            return output;
            //else
            //    throw new Exception("Errore ritornato da " + targetPage + " : " + response.StatusDescription + " - " + output);
        }

        public static string invoke_GET_WS(string targetPage, string querystring)
        {
            var client = new RestClient(targetPage + '?' + querystring);
            var request = new RestRequest(Method.GET);
            //request.AddHeader("content-type", "application/json");
            //request.AddHeader("authorization", "Bearer ACCESS_TOKEN");
            IRestResponse response = client.Execute(request);

            string output = response.Content;

            if (string.IsNullOrEmpty(response.ErrorMessage))
                return output;
            else
                throw new Exception("Errore ritornato da " + targetPage + " : " + response.ErrorMessage);

        }

        public static string invoke_AccessToken_WS(string targetPage, string access_token)
        {
            var client = new RestClient(targetPage);
            var request = new RestRequest(Method.GET);
            request.AddHeader("content-type", "application/json");
            //request.AddHeader("authorization", "Bearer " + access_token)
            request.AddHeader("Authorization", "Bearer " + access_token);
            IRestResponse response = client.Execute(request);

            string output = response.Content;

            if (response.StatusCode == HttpStatusCode.OK)
                return output;
            else
                throw new Exception("Errore ritornato da " + targetPage + " : " + response.StatusDescription + " - " + output);

        }

        public static string getSYS(SqlConnection sqlConn, string sysName)
        {
            string sysVal = "";
            string strSQL = "select dbo.CNV_ESTESA('#SYS.SYS_" + sysName + "#', 'I') as val";

            SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
            SqlDataReader rs = null;

            try
            {
                using (rs = cmd.ExecuteReader())
                {
                    if (rs.Read())
                    {
                        sysVal = rs.GetString(0);
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

            return sysVal;

        }

        public static void logUtente(SqlConnection sqlConn, HttpRequest request, string paginaDiArrivo, string descrizione, bool error = false)
        {

            try
            {
                if (error)
                    WriteToEventLog(paginaDiArrivo + " - " + descrizione);
            }
            catch (Exception)
            {
            }

            if (sqlConn != null)
            {
                string ip = getRequestIP(request);
                string strSQL = "INSERT INTO ctl_log_utente(ip,paginaDiArrivo, querystring, descrizione) values ( @ip, @paginaDiArrivo,@tipoTrace, @descrizione)";

                SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
                cmd.Parameters.Add("@ip", SqlDbType.NVarChar, 4000).Value = ip;
                cmd.Parameters.Add("@paginaDiArrivo", SqlDbType.NVarChar, 4000).Value = paginaDiArrivo;
                cmd.Parameters.Add("@descrizione", SqlDbType.NVarChar, 4000).Value = descrizione;

                if (error)
                    cmd.Parameters.Add("@tipoTrace", SqlDbType.NVarChar, 4000).Value = "TRACE-ERROR";
                else
                    cmd.Parameters.Add("@tipoTrace", SqlDbType.NVarChar, 4000).Value = "TRACE-INFO";

                cmd.ExecuteNonQuery();
            }


        }

        public static void traceDB(SqlConnection sqlConn, string contesto, string descrizione)
        {
            string strSQL = "INSERT INTO CTL_TRACE( contesto, descrizione) values ( @contesto, @descrizione )";

            SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
            cmd.Parameters.Add("@contesto", SqlDbType.NVarChar, 4000).Value = contesto;
            cmd.Parameters.Add("@descrizione", SqlDbType.NVarChar, 4000).Value = descrizione;

            cmd.ExecuteNonQuery();
        }

        public static void WriteToEventLog(string message)
        {
            try
            {
                string sSource = "AFLink";
                string sLog = "Application";
                string sMachine = ".";

                if (!EventLog.SourceExists(sSource, sMachine))
                    EventLog.CreateEventSource(sSource, sLog, sMachine);


                EventLog ELog = new EventLog(sLog, sMachine, sSource);
                ELog.WriteEntry(message, EventLogEntryType.Error);


            }
            catch (Exception)
            {
            }

        }

        public static string getRequestIP(HttpRequest request)
        {
            string ipAdd = request.ServerVariables["HTTP_X_FORWARDED_FOR"];

            if (string.IsNullOrEmpty(ipAdd))
            {
                ipAdd = request.ServerVariables["REMOTE_ADDR"];
            }

            return ipAdd;
        }

        internal static void traceLoginFederato(SqlConnection sqlConn, string guid, string pfulogin, string codice_fiscale)
        {
            string strKeyFedera = "federa_" + guid;
            string data = DateTime.Now.ToString("yyyy-MM-dd HH':'mm");
            string strValueFedera = data + "@@@" + pfulogin + "@@@" + codice_fiscale;


            string strSQL = "INSERT INTO [CTL_LOG_PROC]([DOC_NAME],[parametri]) VALUES ( @strKeyFedera, @strValueFedera)";

            SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
            cmd.Parameters.Add("@strKeyFedera", SqlDbType.NVarChar, 4000).Value = strKeyFedera;
            cmd.Parameters.Add("@strValueFedera", SqlDbType.NVarChar, 4000).Value = strValueFedera;

            cmd.ExecuteNonQuery();
        }

        internal static void saveIdToken(SqlConnection sqlConn, string guid, string idToken)
        {

            string strSQL = "INSERT INTO CTL_ACCESS_BARRIER( guid, data, id_token ) values ( @guid, getDate(), @id_token )";

            SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
            cmd.Parameters.Add("@guid", SqlDbType.NVarChar, 4000).Value = guid;
            cmd.Parameters.Add("@id_token", SqlDbType.NVarChar, -1).Value = idToken;

            cmd.ExecuteNonQuery();
        }

        public static bool saveLogSPID(SqlConnection sqlConn, HttpRequest request, string jsonUserInfo, string cf, string status, string LOA, string Canale)
        {
            bool esito = false;
            try
            {
                if (sqlConn != null)
                {
                    if (string.IsNullOrEmpty(LOA))
                    {
                        LOA = "";
                    }
                    if (string.IsNullOrEmpty(Canale))
                    {
                        Canale = "";
                    }                 

                    string ip = getRequestIP(request);
                    string ipServer = GetIpServer();
                    string strSQL = "INSERT into CTL_LOG_SPID (ipChiamante, ipServer, AspSessionID, HTTP_SHIBSESSIONINDEX, dataInsRecord, status, HTTP_FISCALNUMBER, Response, AuthnReq_ID, LOA, Canale) values(@ipChiamante, @ipServer, @AspSessionID, @HTTP_SHIBSESSIONINDEX, GETDATE(), @status, @HTTP_FISCALNUMBER, @Response, @AuthnReq_ID, @LOA, @Canale)";

                    SqlCommand cmd = new SqlCommand(strSQL, sqlConn);
                    cmd.Parameters.Add("@ipChiamante", SqlDbType.NVarChar, 4000).Value = ip;
                    cmd.Parameters.Add("@ipServer", SqlDbType.NVarChar, 4000).Value = ipServer;
                    cmd.Parameters.Add("@HTTP_FISCALNUMBER", SqlDbType.NVarChar, 4000).Value = cf;
                    cmd.Parameters.Add("@status", SqlDbType.NVarChar, 4000).Value = status;
                    cmd.Parameters.Add("@Response", SqlDbType.NVarChar, 4000).Value = jsonUserInfo;
                    cmd.Parameters.Add("@AuthnReq_ID", SqlDbType.NVarChar, 4000).Value = "";
                    cmd.Parameters.Add("@AspSessionID", SqlDbType.NVarChar, 4000).Value = "";
                    cmd.Parameters.Add("@HTTP_SHIBSESSIONINDEX", SqlDbType.NVarChar, 4000).Value = "";
                    cmd.Parameters.Add("@LOA", SqlDbType.NVarChar, 4000).Value = LOA;
                    cmd.Parameters.Add("@Canale", SqlDbType.NVarChar, 4000).Value = Canale;

                    cmd.ExecuteNonQuery();
                    esito = true;
                }
            }
            catch (Exception ex)
            {
                traceDB(sqlConn, "OpenID\\access.aspx", "ERRORE funzione saveLogSPID : Canale = " + Canale + " LOA = " + LOA + " ERRORE = " + ex.Message);
                esito = false;
            }
            return esito;
        }

        public static string GetIpServer()
        {
            string esito = "";
            try
            {
                string hostName = Dns.GetHostName();
                esito = Dns.GetHostEntry(hostName).AddressList[1].ToString();
            }
            catch (Exception)
            {
                esito = "";
            }
            return esito;
        }

    }
}