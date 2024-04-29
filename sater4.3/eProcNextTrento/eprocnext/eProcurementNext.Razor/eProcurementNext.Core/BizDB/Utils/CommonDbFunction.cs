using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;

using System.Reflection;
using EprocNext.CommonDB;

namespace EprocNext.BizDB.Utils
{
    public static class CommonDbFunction_
    {

        public static string GetParam(string paramTarget, string param)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            return cdf.GetParam(paramTarget, param);
        }

        //public static Dictionary<string, dynamic> GetRSReadFromQuery(string strSql, string connectionString)
        //{
        //    CommonDbFunctions cdf = new CommonDbFunctions();
        //    return cdf.GetRSReadFromQuery(strSql, connectionString);
        //}

        public static bool ParseBool(string? input)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            return cdf.ParseBool(input);
        }

        public static void Execute(string strSql, string connectionstring, SqlConnection? objConnection = null)
        {
            
            SqlConnection conn = ( objConnection == null ) ? new SqlConnection(connectionstring) : objConnection;    
            
            SqlCommand cmd = new SqlCommand(strSql, conn);
            if (strSql.StartsWith("Exec", StringComparison.Ordinal))
            {
                cmd.CommandType = CommandType.StoredProcedure;
            }
            else
            {
                cmd.CommandType = CommandType.Text;
            }

            if (objConnection==null)   
                conn.Open();
            
            
            cmd.ExecuteNonQuery();

            

            if (objConnection == null)
                conn.Close();
        }
    }

}