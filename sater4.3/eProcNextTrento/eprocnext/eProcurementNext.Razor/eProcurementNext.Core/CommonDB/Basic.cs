using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq.Expressions;
using System.Reflection;
using System.Runtime.InteropServices;

namespace eProcurementNext.CommonDB
{
    public static class Basic
    {

        public enum TsEventLogEntryType
        {
            Critical = 0,
            Error = 1,
            Warning = 2,
            Information = 4,
        }

        /// <summary>
        /// Traccia un messaggio di errore a partire da una Exception e scrive anche nell'Event Viewer
        /// </summary>
        /// <param name="error"></param>
        /// <param name="connectionString"></param>
        /// <param name="contesto"></param>
        public static void TraceErr(Exception error, string connectionString, string contesto = "")
        {
            string errorString = String.Empty;
            if (!string.IsNullOrWhiteSpace(error.Message))
            {
                errorString = $"{error.Message}\n{error}";
            }
            else
            {
                errorString = error.ToString();
            }

            var dbEV = new DbEventViewer();
            dbEV.traceEventInDBConnString(0, contesto, errorString, connectionString, null);

            WriteToEventLog(errorString);

        }

        /// <summary>
        /// Traccia un messaggio di errore custom e lo scrive anche nell'Event Viewer
        /// </summary>
        /// <param name="eventType"></param>
        /// <param name="message"></param>
        /// <param name="connectionString"></param>
        /// <param name="contesto"></param>
        public static void LogEvent(TsEventLogEntryType eventType, string message, string connectionString = "", string contesto = "")
        {
            string errorString = message;

            try
            {

                if (!string.IsNullOrEmpty(connectionString))
                {
                    var dbEV = new DbEventViewer();
                    dbEV.traceEventInDBConnString((int)eventType, contesto, errorString, connectionString, null);
                }

                WriteToEventLog(errorString, eventType);
            }
            catch
            {
            }
        }

        private static EventLogEntryType GetWindowsEventLogEntryType(TsEventLogEntryType eventType)
        {
            return (EventLogEntryType)eventType;
        }

        public static void WriteToEventLog(string message, TsEventLogEntryType eventType = TsEventLogEntryType.Error)
        {
            DebugTrace dt = new();
            try
            {
                string sSource = ApplicationCommon.Application["EventLogSource"]; //= "AFLink"
                if (string.IsNullOrEmpty(sSource))
                    sSource = "AFLink";
                dt.Write("Basic.WriteToEventLog riga 82 - sSource=" + sSource);
                string sLog = "Application";
                string sMachine = ".";
                if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                {
                    EventSourceCreationData SourceData = new EventSourceCreationData(sSource, $"{sLog}{sMachine}");

                    if (!EventLog.SourceExists(sSource, sMachine))
                        System.Diagnostics.EventLog.CreateEventSource(SourceData);

                    EventLog ELog = new EventLog(sLog, sMachine, sSource);
                    ELog.WriteEntry(message, GetWindowsEventLogEntryType(eventType));
                }
            }
            catch (Exception ex)
            {
                dt.Write("Basic.WriteToEventLog riga 94 - " + ex.ToString());
            }
        }

        public static TSRecordSet User_GetInfoAttrib(long lIdPfu, string Attrib, string strConnectionString)
        {

            string strSql = "";
            try
            {
                CommonDbFunctions cdb = new CommonDbFunctions();
                TSRecordSet rs;

                //Set mp_objDB = CreateObject("ctldb.clsTabManage")

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@IdPfu", lIdPfu);
                sqlParams.Add("@dztnome", Attrib);
                strSql = "select dztnome,attvalue from ProfiliutenteAttrib with(nolock) where idpfu=@IdPfu and dztnome = @dztnome order by IdUsAttr";

                rs = cdb.GetRSReadFromQuery_(strSql, strConnectionString, null, parCollection: sqlParams);

                return rs;
            }
            catch (Exception ex)
            {
                throw new Exception($"User_GetInfo ({strSql}) - Exception : {ex}");
            }
        }
        public static bool isValidErr(string strvalue, int tipo, string strRegExp = "", bool ignoreCase = true)
        {

            if (eProcurementNext.DashBoard.Basic.isValid(strvalue, tipo, strRegExp, ignoreCase) == false)
            {
                throw new Exception("isValidErr - Parametro non valido :  ," + strvalue);
            }

            return true;
        }

        public static void SaveToRecordset(string fldName, string tableName, string colIdentity, int key, Stream stream, SqlConnection conn, SqlTransaction? trans = null)
        {
            string strSql = string.Empty;

            SqlDataAdapter da = new SqlDataAdapter();
            DataSet ds = new DataSet();

            using SqlCommand cmd = new SqlCommand(strSql, conn);
            cmd.CommandTimeout = 180;
            if (trans != null)
                cmd.Transaction = trans;


            cmd.CommandType = CommandType.Text;
            da.SelectCommand = cmd;

            if (string.IsNullOrEmpty(colIdentity) || key == -1)
            {
                strSql = $"INSERT INTO [{tableName}] ([{fldName}]) VALUES (@bindata);";
                cmd.CommandText = strSql;
                da.InsertCommand = cmd;
            }
            else
            {
                strSql = $"UPDATE [{tableName}] SET [{fldName}] = @bindata where {colIdentity} = {key};";
                cmd.CommandText = strSql;
                da.UpdateCommand = cmd;
            }

            //strSql += $" select * from {tableName} where {colIdentity} = scope_identity() "

            // Add a parameter which uses the FileStream we just opened
            // Size is set to -1 to indicate "MAX"
            cmd.Parameters.Add("@bindata", SqlDbType.Binary, -1).Value = stream;

            da.AcceptChangesDuringUpdate = true;
            da.Fill(ds);
        }

        public static void SaveToRecordset(string fldName, string tableName, string colIdentity, int key, string DiskFile, string connectionString)
        {
            using FileStream file = File.Open(DiskFile, FileMode.Open);
            using SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            SaveToRecordset(fldName, tableName, colIdentity, key, file, conn);
        }

        public static async Task SaveToRecordsetAsync(DataColumn fld, string tableName, string colIdentity, string key, string DiskFile, string connectionString)
        {
            string strSql = string.Empty;

            if (string.IsNullOrEmpty(colIdentity))
            {
                strSql = $"INSERT INTO [{tableName}] ([{fld.ColumnName}]) VALUES (@bindata)";
            }
            else
            {
                strSql = $"UPDATE [{tableName}] SET [{fld.ColumnName}] = @bindata where {colIdentity} = {key}";
            }

            using SqlConnection conn = new SqlConnection(connectionString);
            await conn.OpenAsync();
            using SqlCommand cmd = new SqlCommand(strSql, conn);
            using FileStream file = File.Open(DiskFile, FileMode.Open);
            // Add a parameter which uses the FileStream we just opened
            // Size is set to -1 to indicate "MAX"
            cmd.Parameters.Add("@bindata", SqlDbType.Binary, -1).Value = file;

            // Send the data to the server asynchronously
            await cmd.ExecuteNonQueryAsync();
        }

        public static void saveFileFromRecordSet(string fldName, string tableName, string colIdentity, int key, string FILE, SqlConnection? conn = null, SqlTransaction? trans = null)
        {
            using FileStream fileStream = new FileStream(FILE, FileMode.OpenOrCreate, FileAccess.Write);
            saveFileFromRecordSet(fldName, tableName, colIdentity, key, fileStream, conn, trans);
        }

        public static void saveFileFromRecordSet(string fldName, string tableName, string colIdentity, string key, string file_,  SqlConnection? conn = null, SqlTransaction? trans = null)
        {
            bool bNewConn = false;

            try
            {
                if (conn == null)
                {
                    conn = new SqlConnection();
                    conn.ConnectionString = ApplicationCommon.Application["ConnectionString"];
                    conn.Open();
                    bNewConn = true;
                }

                using SqlCommand cmd = new("", conn);
                cmd.Connection = conn;
                if (trans is not null)
                {
                    cmd.Transaction = trans;
                }
               
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddWithValue("@key", key);

                //   ATTENZIONE !! //
                // non usare sqlparameter nel codice seguente !! //
                var strSql = $"select {fldName} from {tableName} with(nolock) where {colIdentity} = @key";
                cmd.CommandText = strSql;

                using SqlDataReader reader = cmd.ExecuteReader(CommandBehavior.SequentialAccess);
                if (reader.Read())
                {
                    if (reader.IsDBNull(0))
                    {
                        throw new Exception($"Allegato {key} NULL");
                    }

                    using FileStream newFile = new FileStream(file_, FileMode.OpenOrCreate, FileAccess.Write);
                    using Stream data = reader.GetStream(0);
                    data.CopyTo(newFile);
                }
                else
                {
                    throw new Exception($"Allegato {key} non trovato");
                }
            }
            finally
            {
                if (conn is not null && bNewConn)
                {
                    conn.Close();
                }
            }
        }

        public static void saveFileFromRecordSet(string fldName, string tableName, string colIdentity, int key, Stream stream, SqlConnection? conn = null, SqlTransaction? trans = null)
        {
            bool bNewConn = false;

            try
            {
                if (conn == null)
                {
                    conn = new SqlConnection();
                    conn.ConnectionString = ApplicationCommon.Application["ConnectionString"];
                    conn.Open();
                    bNewConn = true;
                }

                using SqlCommand cmd = new("", conn);
                cmd.Connection = conn;
                if (trans is not null)
                {
                    cmd.Transaction = trans;
                }

				//   ATTENZIONE !! //

				// non usare sqlparameter nel codice seguente !! //

				string strSql = $"select [{fldName}] from [{tableName}] with(nolock) where [{colIdentity}] = {key}";

                cmd.CommandText = strSql;
                cmd.CommandType = CommandType.Text;
                //cmd.Parameters.AddWithValue("@key", key);

                using var reader = cmd.ExecuteReader(CommandBehavior.SequentialAccess);
                int ordinal = reader.GetOrdinal(fldName);
                reader.Read();

                using Stream dataStream = reader.GetStream(ordinal);
                dataStream.CopyTo(stream);
            }
            catch (Exception ex)
            {
                throw;
            }
            finally
            {
                if (conn is not null && bNewConn)
                {
                    conn.Close();
                }
            }
        }

        public static void saveFileFromRecordSet(string fldName, string tableName, string colIdentity, dynamic key, Stream stream, SqlConnection? conn = null, SqlTransaction? trans = null)
        {
            bool bNewConn = false;

            try
            {
                if (conn == null)
                {
                    conn = new SqlConnection();
                    conn.ConnectionString = ApplicationCommon.Application.ConnectionString;
                    conn.Open();
                    bNewConn = true;
                }

                using SqlCommand cmd = new("", conn);
                cmd.Connection = conn;
                cmd.Parameters.AddWithValue("@key", key);
                if (trans is not null)
                {
                    cmd.Transaction = trans;
                }


                string strSql = $"select [{fldName}] from [{tableName}] with(nolock) where [{colIdentity}] = @key";

                cmd.CommandText = strSql;
                cmd.CommandType = CommandType.Text;

                using var reader = cmd.ExecuteReader(CommandBehavior.SequentialAccess);
                int ordinal = reader.GetOrdinal(fldName);
                reader.Read();

                using Stream dataStream = reader.GetStream(ordinal);
                dataStream.CopyTo(stream);
            }
            catch (Exception ex)
            {
                throw;
            }
            finally
            {
                if (conn is not null && bNewConn)
                {
                    conn.Close();
                }
            }
        }

        public static void saveFileFromRecordSet(string fldName, string tableName, string colIdentity, string key, string FILE, string connectionString)
        {
            using SqlConnection conn = new SqlConnection(connectionString);
            conn.Open();
            saveFileFromRecordSet(fldName, tableName, colIdentity, key, FILE, conn, null);
        }

        public static Exception SetStackTrace(this Exception target, StackTrace stack) => _SetStackTrace(target, stack);

        private static readonly Func<Exception, StackTrace, Exception> _SetStackTrace = new Func<Func<Exception, StackTrace, Exception>>(() =>
        {
            ParameterExpression target = Expression.Parameter(typeof(Exception));
            ParameterExpression stack = Expression.Parameter(typeof(StackTrace));
            Type traceFormatType = typeof(StackTrace).GetNestedType("TraceFormat", BindingFlags.NonPublic);
            MethodInfo toString = typeof(StackTrace).GetMethod("ToString", BindingFlags.NonPublic | BindingFlags.Instance, null, new[] { traceFormatType }, null);
            object normalTraceFormat = Enum.GetValues(traceFormatType).GetValue(0);
            MethodCallExpression stackTraceString = Expression.Call(stack, toString, Expression.Constant(normalTraceFormat, traceFormatType));
            FieldInfo stackTraceStringField = typeof(Exception).GetField("_stackTraceString", BindingFlags.NonPublic | BindingFlags.Instance);
            BinaryExpression assign = Expression.Assign(Expression.Field(target, stackTraceStringField), stackTraceString);
            return Expression.Lambda<Func<Exception, StackTrace, Exception>>(Expression.Block(assign, target), target, stack).Compile();
        })();

    }
}
