using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;
using System.Data;
using System.Data.SqlClient;


namespace eProcurementNext.Xls
{
    public class Database
    {

        public SqlConnection sqlConn;
        private string connectionString = string.Empty;
        private SqlTransaction sqlTran = default;

        public Database(string connString)
        {
            // -- Se nel costruttore viene passata la connectionstring vince sul default recupero dall'app.config
            if (!string.IsNullOrEmpty(connString))
            {
                connectionString = connString;
            }
        }

        // If (sqlConn Is Nothing) Then 'Or sqlConn.State <> ConnectionState.Open) Then
        //~Database()
        //{
        //    ;
        //    close();
        //    // End If
        //}

        public bool init()
        {
            try
            {
                //'-- Se la connessione non è attiva la attiviamo
                if (sqlConn is null) // Or sqlConn.State <> ConnectionState.Open) Then
                {

                    sqlConn = new SqlConnection(connectionString);
                    sqlConn.Open();

                }

                if (sqlConn.State == ConnectionState.Closed)
                {
                    sqlConn.Open();
                }

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERRORE NELLA INIT SUL DB : " + Information.Err().Description);
                return false;
            }
        }

        public SqlCommand getSqlCommand(string strSql)
        {
            SqlCommand getSqlCommandRet = default;

            if (sqlTran is not null)
            {

                getSqlCommandRet = sqlConn.CreateCommand();
                getSqlCommandRet.Transaction = sqlTran;
                getSqlCommandRet.CommandText = strSql;
            }

            else
            {

                getSqlCommandRet = new SqlCommand(strSql, sqlConn);

            }

            return getSqlCommandRet;

        }

        public bool beginTrans()
        {

            sqlTran = sqlConn.BeginTransaction();
            return default;

        }

        public bool commit()
        {
            bool commitRet = default;

            try
            {
                if (sqlTran is not null)
                {
                    sqlTran.Commit();
                    commitRet = true;
                }
                else
                {
                    commitRet = true;
                }
            }
            catch (Exception ex)
            {
                commitRet = false;
            }

            return commitRet;


        }

        public bool rollback()
        {
            bool rollbackRet = default;

            try
            {
                if (sqlTran is not null)
                {
                    sqlTran.Rollback();
                    rollbackRet = true;
                }
                else
                {
                    rollbackRet = true;
                }
            }
            catch (Exception ex)
            {
                rollbackRet = false;
            }

            return rollbackRet;

        }

        public void close()
        {
            ;
            sqlConn.Close();
        }

        public void executeQuery(string strSql)
        {
            SqlCommand sqlComm = getSqlCommand(strSql);
            sqlComm.ExecuteNonQuery();
        }

        public SqlDataReader getSqlReader(string strSql)
        {
            var sqlComm = getSqlCommand(strSql);
            return sqlComm.ExecuteReader();
        }

        public SqlDataReader getSqlReaderForMetadata(string strSql)
        {
            var sqlComm = getSqlCommand(strSql);
            return sqlComm.ExecuteReader(CommandBehavior.KeyInfo);
        }

        public string getTrascodifica(string sistema, string value, string dztNome)
        {
            string getTrascodificaRet = default;

            if (init() == true)
            {

                string strSql = "";

                strSql = "select * from ctl_transcodifica where sistema = '" + Strings.Replace(sistema, "'", "''") + "' and ValIn = '" + Strings.Replace(value, "'", "''") + "' and dztNome = '" + Strings.Replace(dztNome, "'", "''") + "'";

                var sqlComm = getSqlCommand(strSql);
                SqlDataReader r = sqlComm.ExecuteReader();

                if (r.Read() == true)
                {
                    getTrascodificaRet = (string)r["ValOut"];
                }

                else
                {

                    // -- Se non troviamo un match in tabella ritorniamo il valore passato
                    getTrascodificaRet = value;

                }

                return getTrascodificaRet;
            }
            else
            {

                // connessione non attiva
                return Conversions.ToString(false);

            }

        }

        public object getSqlValueFromQuery(string strSql, string columnName)
        {
            object getSqlValueFromQueryRet = default;

            if (init() == true)
            {

                var sqlComm = getSqlCommand(strSql);
                SqlDataReader r = sqlComm.ExecuteReader();

                // Ritorniamo true se sono presenti record, false altrimenti
                if (r.Read() == true)
                {
                    getSqlValueFromQueryRet = r[columnName];
                }

                else
                {

                    // -- Se non troviamo un match in tabella ritorniamo null
                    getSqlValueFromQueryRet = null;

                }

                return getSqlValueFromQueryRet;
            }

            else
            {

                // connessione non attiva
                throw new Exception(" Connessione non attiva ");

            }

        }


        public void logDB(string idDoc, string info)
        {
            ;

            if (init() == true)
            {

                string strSql = "";

                strSql = "INSERT INTO CTL_LOG_PROC(DOC_NAME,PROC_NAME,id_Doc,idPfu,Parametri,data)";
                strSql = strSql + " VALUES('XLSX', 'IMPORT', '" + Strings.Replace(idDoc, "'", "''") + "', idPfu, '" + Strings.Replace(info, "'", "''") + "', getdate())";

                var sqlComm = getSqlCommand(strSql);
                sqlComm.ExecuteNonQuery();

            }



        }

        public bool ColumnExists(SqlDataReader reader, string columnName)
        {
            int Counter;

            var loopTo = reader.FieldCount - 1;
            for (Counter = 0; Counter <= loopTo; Counter++)
            {

                if (reader.GetName(Counter).ToUpper() == Strings.UCase(columnName))
                {
                    return true;
                }

            }

            return false;
        }

    }
}

