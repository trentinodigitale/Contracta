using Microsoft.VisualBasic;
using System.Data;
using System.Data.SqlClient;

namespace ParixClient
{

    public class Db
    {

        public SqlConnection sqlConn;
        private string connectionString = "";
        private SqlTransaction sqlTran = null;
        private string query = string.Empty;
        private object comm;

        public Db(string strCnString)
        {

            connectionString = Strings.Replace(strCnString, "Provider=SQLOLEDB;", "");
            connectionString = Strings.Replace(connectionString, "Provider=SQLOLEDB.1;", "");
            connectionString = Strings.Replace(connectionString, "Provider=SQLOLEDB.2;", "");
            connectionString = Strings.Replace(connectionString, "Provider=SQLOLEDB.3;", "");

        }

        // If (sqlConn Is Nothing) Then 'Or sqlConn.State <> ConnectionState.Open) Then
        ~Db()
        {
            ;
            close();
            // End If
        }

        public void setQuery(string sql)
        {
            query = sql;
        }

        public void initCommand()
        {
            comm = getSqlCommand(query);

            // With comm
            // .Connection = sqlConn
            // .CommandType = CommandType.Text
            // .CommandText = query
            // End With
        }


        //public void setParameter(string paramName, SqlDbType paramType, object paramValue)
        //{

        //    {
        //        ref var withBlock = ref comm;

        //        if (paramValue is null)
        //        {
        //            withBlock.Parameters.Add("@" + paramName, paramType).Value = DBNull.Value;
        //        }
        //        else
        //        {
        //            withBlock.Parameters.Add("@" + paramName, paramType).Value = paramValue;
        //        }

        //    }

        //}

        //public void executeCommand()
        //{
        //    comm.ExecuteNonQuery();
        //    comm = null;
        //}

        public bool init()
        {
            ;

            // -- Se la connessione non è attiva la attiviamo
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

            return default;
        err:
            ;

            Console.WriteLine("ERRORE NELLA INIT SUL DB : " + Information.Err().Description);
            return false;

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

        public void beginTrans()
        {

            sqlTran = sqlConn.BeginTransaction();

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

        public object getSqlValueFromQuery(string strSql, string columnName)
        {
            object getSqlValueFromQueryRet = default;

            if (init() == true)
            {

                var sqlComm = new SqlCommand(strSql, sqlConn);
                var r = sqlComm.ExecuteReader();

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

                close();  // --> chiamo N volte getTrascodifica() e poi chiamo da fuori la close()

                return getSqlValueFromQueryRet;
            }

            else
            {

                // connessione non attiva
                throw new Exception(" Connessione non attiva ");

            }

        }

        public void execSqlNoTransaction(string strSql)
        {
            ;

            if (init() == true)
            {

                var sqlComm = new SqlCommand(strSql, sqlConn);

                sqlComm.ExecuteNonQuery();

            }

        }

        public bool ColumnExists(SqlDataReader reader, string columnName)
        {
            ;

            int Counter;

            var loopTo = reader.FieldCount - 1;
            for (Counter = 0; Counter <= loopTo; Counter++)
            {

                if ((Strings.UCase(reader.GetName(Counter)) ?? "") == (Strings.UCase(columnName) ?? ""))
                {
                    return true;
                }

            }

            return false;

        err:
            ;

            return false;

        }

    }
}