using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Web;
using System.Web.UI.WebControls;
using System.Xml;


namespace ProtocolloPiTre
{
    public class Tools
    {

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




        public static void DM_Attributi(SqlConnection sqlConn, int IdAzi, string dztName, out string val_out)
        {
            string strSql;
            SqlCommand cmd1;
            SqlDataReader rs;
            val_out = "";


            // legge il valore del codice AIC
            //strSql = "select * from dm_attributi with (nolock) where idapp=1 and lnk = " + IdAzi.ToString() + " and dztnome='" + dztName + "'";
            strSql = "select vatvalore_ft from dm_attributi with (nolock) where idapp=1 and lnk = @idazi and dztnome = @dztnome";

            cmd1 = new SqlCommand(strSql, sqlConn);

            cmd1.Parameters.Add("@idazi", SqlDbType.Int).Value = IdAzi;
            cmd1.Parameters.Add("@dztnome", SqlDbType.NVarChar, 4000).Value = dztName;

            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    //CodiceAIC = rs.GetInt32(rs.GetOrdinal("CodiceAIC"));


                    val_out = rs.GetString(rs.GetOrdinal("vatvalore_ft"));

                }

                //rs.Close();
            }

        }

        public static string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }

        public static void addSqlParamsCommand(Hashtable parametri, SqlCommand cmd)
        {
            foreach (DictionaryEntry de in parametri)
            {
                object val = de.Value;

                if (val == null)
                {
                    val = DBNull.Value;
                }

                cmd.Parameters.AddWithValue((string)de.Key, val);

            }
        }

        public static string getNodeAttribValue(XmlNode nodo, string xPath, XmlNamespaceManager nspace, string attribName)
        {
            XmlNodeList listaNodi;
            string strVal = "";

            try
            {
                listaNodi = nodo.SelectNodes(xPath, nspace);

                if (listaNodi.Count > 0)
                {
                    strVal = listaNodi[0].Attributes[attribName].InnerText;
                }

            }
            catch (Exception)
            {
                strVal = "";
            }

            return strVal;
        }

        public static string getNodeXml(XmlDocument doc, XmlNamespaceManager manager, string xpath)
        {
            string strOut = "";

            XmlNodeList listaNodi = doc.SelectNodes(xpath, manager);

            if (listaNodi.Count > 0)
            {
                strOut = listaNodi[0].OuterXml;
            }

            return strOut == null ? "" : strOut;
        }

        public static bool IsNumeric(string s)
        {
            float output;
            return float.TryParse(s, out output);
        }

        public static string getrandomid(bool uppercase = false)
        {
            string ret = Guid.NewGuid().ToString().Replace("-", "").ToLower();

            if (uppercase)
                ret = ret.ToUpper();
            else if (IsNumeric(ret.Substring(0, 1)))
                ret = "r" + ret.Substring(1);

            //var withBlock = DateTime.Now.ToUniversalTime();
            //return ret.Substring(0, 17) + "_" + String.Format("0000", withBlock.Year) + String.Format("00", withBlock.Month) + String.Format("00", withBlock.Day) + String.Format("00", withBlock.Hour) + String.Format("00, withBlock.Minute") + String.Format("00", withBlock.Second) + String.Format("000", withBlock.Millisecond);

            return ret;

        }

        public static string getUrlParam(string queryString, string param)
        {
            Uri myUri = new Uri("http://www.example.com?" + queryString);
            return HttpUtility.ParseQueryString(myUri.Query).Get(param);
        }


        




        public static bool IsDate(String date)

        {

            try

            {

                DateTime dt = DateTime.Parse(date);

                return true;
            }

            catch
            {
                return false;
            }

        }




    }
}

