using System.Data;
using System.Data.SqlClient;

namespace eProcurementNext.RegistroImprese.CERVED
{
    public class Tools
    {


        public static void InsertParixDati(SqlConnection sqlConn, string sessionid, string codice_fiscale, string AttrName, string Valore)
        {
            var strSql = "INSERT INTO Parix_Dati(sessionid,codice_fiscale,nome_campo,valore)";
            strSql = strSql + " VALUES(@sessionid,@codice_fiscale,@nome_campo,@valore)";

            var cmd1 = new SqlCommand(strSql, sqlConn);

            string Valore2 = "";
            if (string.IsNullOrEmpty(Valore))
                Valore2 = "";
            else
                Valore2 = Valore;

            cmd1.Parameters.Add("@sessionid", SqlDbType.VarChar).Value = sessionid;
            cmd1.Parameters.Add("@codice_fiscale", SqlDbType.VarChar).Value = codice_fiscale;
            cmd1.Parameters.Add("@nome_campo", SqlDbType.VarChar).Value = AttrName;
            cmd1.Parameters.Add("@valore", SqlDbType.VarChar).Value = Valore2;

            cmd1.ExecuteNonQuery();


        }

        public static void GetComune(SqlConnection sqlConn, string codice, out string dmv_cod)
        {
            string strSql;
            SqlCommand cmd1;
            SqlDataReader rs;
            dmv_cod = "";

            // legge il minimo valore di idheader sulla CTL_DomainValues
            //strSql = "select min(idheader) as idheader from CTL_DomainValues with (nolock) where idheader < 0";

            strSql = " declare @val as int set @val = " + codice + " select dmv_descml,dmv_cod from lib_domainvalues where dmv_cod LIKE '%-' + cast(@val as varchar(20))and dmv_dm_id = 'GEO' and DMV_Level = 7";



            cmd1 = new SqlCommand(strSql, sqlConn);
            rs = cmd1.ExecuteReader();

            if (rs.Read())
            {
                dmv_cod = rs.GetString(rs.GetOrdinal("dmv_cod"));
            }

            rs.Close();




        }


        public static void GetProvincia(SqlConnection sqlConn, string codice, out string descrizione)
        {
            string strSql;
            SqlCommand cmd1;
            SqlDataReader rs;
            descrizione = "";

            // legge il minimo valore di idheader sulla CTL_DomainValues
            //strSql = "select min(idheader) as idheader from CTL_DomainValues with (nolock) where idheader < 0";

            strSql = " select dmv_descml,dmv_cod from lib_domainvalues where dmv_cod ='" + codice + "' and dmv_dm_id = 'GEO' and DMV_Level = 6";



            cmd1 = new SqlCommand(strSql, sqlConn);
            rs = cmd1.ExecuteReader();

            if (rs.Read())
            {
                descrizione = rs.GetString(rs.GetOrdinal("dmv_descml"));
            }

            rs.Close();




        }



        public static void GetEndPoint(SqlConnection sqlConn, out string strEndPoint_1, out string strEndPoint_2)
        {
            string strSql;
            SqlCommand cmd1;
            SqlDataReader rs;
            strEndPoint_1 = "";
            strEndPoint_2 = "";

            // legge il minimo valore di idheader sulla CTL_DomainValues
            //strSql = "select min(idheader) as idheader from CTL_DomainValues with (nolock) where idheader < 0";

            strSql = " select dzt_name, DZT_ValueDef  from LIB_Dictionary  where dzt_name = 'SYS_URL_CERVED_ENTITY_SEARCH'";

            cmd1 = new SqlCommand(strSql, sqlConn);
            rs = cmd1.ExecuteReader();

            if (rs.Read())
            {
                strEndPoint_1 = rs.GetString(rs.GetOrdinal("DZT_ValueDef"));
            }

            rs.Close();

            strSql = " select dzt_name, DZT_ValueDef  from LIB_Dictionary  where dzt_name = 'SYS_URL_CERVED_ENTITY_PROFILE'";

            cmd1 = new SqlCommand(strSql, sqlConn);
            rs = cmd1.ExecuteReader();

            if (rs.Read())
            {
                strEndPoint_2 = rs.GetString(rs.GetOrdinal("DZT_ValueDef"));
            }

            rs.Close();




        }

        public static string getConnectionString(string cnString)
        {
            string connectionString = cnString.Replace("Provider=SQLOLEDB;", "");
            connectionString = connectionString.Replace("Provider=SQLOLEDB.1;", "");
            connectionString = connectionString.Replace("Provider=SQLOLEDB.2;", "");
            connectionString = connectionString.Replace("Provider=SQLOLEDB.3;", "");

            return connectionString;
        }

        public static string getDescFormaSoc(SqlConnection sqlConn, string codice)
        {
            string strSql;
            SqlCommand cmd1;
            SqlDataReader rs;
            string descrizione = "";

            strSql = "select dscTesto as Descrizione";
            strSql = strSql + " from tipidatirange with(nolock), descsI with(nolock)";
            strSql = strSql + " where tdridtid = 131 and tdrdeleted=0 and IdDsc =  tdriddsc and isnull(tdrCodiceEsterno,'') = '" + codice.Replace("'", "''") + "'";

            using (cmd1 = new SqlCommand(strSql, sqlConn))
            {
                using (rs = cmd1.ExecuteReader())
                {
                    if (rs.Read())
                    {
                        descrizione = rs.GetString(rs.GetOrdinal("Descrizione"));
                    }
                }
            }

            return descrizione;
        }


    }
}
