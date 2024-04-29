using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace INIPEC.Library
{
    public class Security
    {
        public static int getAccessFromGuid(string guid)
        {
            SqlDataReader rs = null;
            string strSql = string.Empty;

            int getAccessFromGuidRet = 0;

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]))
            {
                connection.Open();

                strSql = "select idpfu from CTL_ACCESS_BARRIER with(nolock) where guid = @guid and datediff(SECOND, data,getdate()) <= 60";
                using (SqlCommand cmd = new SqlCommand(strSql, connection))
                {
                    cmd.Parameters.AddWithValue("@guid", guid);
                    rs = cmd.ExecuteReader();

                    if (rs.Read())
                    {
                        getAccessFromGuidRet = (int)rs["idpfu"];
                    }

                    rs.Close();

                    strSql = "delete from CTL_ACCESS_BARRIER where guid = @guid";

                    cmd.Parameters.Clear();
                    cmd.CommandText = strSql;

                    cmd.Parameters.AddWithValue("@guid", guid);
                    cmd.ExecuteNonQuery();
                }

                connection.Close();
            }
            return getAccessFromGuidRet;
        }
    }
}