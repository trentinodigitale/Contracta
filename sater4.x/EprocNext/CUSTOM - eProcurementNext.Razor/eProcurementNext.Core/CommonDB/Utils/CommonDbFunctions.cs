using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.CommonModule.Exceptions;
using eProcurementNext.Core.Security;
using Microsoft.Extensions.Configuration;
using MongoDB.Driver.Core.Configuration;
using Newtonsoft.Json;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace eProcurementNext.CommonDB
{
    public class CommonDbFunctions
    {
        private int queryTimeOut = 0;
        private string TimeOut = string.Empty;
        private SqlConnection? cnLocal;
        private IConfiguration? _configuration;
        public List<KeyValuePair<string, dynamic>> _dictionary = new List<KeyValuePair<string, dynamic>>();

        public string GetParam(string paramTarget, string param)
        {
            string paramTargetWith = "&" + paramTarget;
            string paramWith = "&" + param + "=";
            int ind = paramTargetWith.IndexOf(paramWith, StringComparison.Ordinal);
            string a = string.Empty;
            if (ind > 0)
            {
                a = paramTarget.Substring(ind + param.Length + 1);
                ind = a.IndexOf("&", StringComparison.Ordinal);
                if (ind > -1)
                {
                    a = a.Substring(0, ind);
                }
            }

            return a;
        }

        public bool ParseBool(string? input)
        {
            if (input == null)
            {
                return false;
            }

            switch (input.ToLower())
            {
                case "1":
                    return true;
                case "yes":
                    return true;
                default:
                    return false;
            }
        }

        public TSRecordSet? GetRSReadFromQueryWithTransaction(string strSql, string connectionString, SqlConnection? conn = null, SqlTransaction? trans = null, int lTime = -1, Dictionary<string, object?>? parCollection = null)
        {
            return GetRSReadFromQuery_(strSql, connectionString, conn, lTime, parCollection, trans);
        }

        private TSRecordSet? getTSRecordSet(string strSql, SqlConnection conn, int lTime = -1, Dictionary<string, object?>? parCollection = null, SqlTransaction? trans = null)
        {
            try
            {
                return new TSRecordSet().Open(strSql, conn.ConnectionString, parCollection, conn, trans, lTime);
            }
            catch (SqlTableNotFoundException)
            {
                return null;
            }
        }

        public TSRecordSet? GetRSReadFromQuery_(string strSql, string connectionString, Dictionary<string, dynamic?>? parCollection)
        {
            return GetRSReadFromQuery_(strSql, connectionString, parCollection: parCollection, conn: null);
        }
        public TSRecordSet? GetRSReadFromQuery_(string strSql, string connectionString, SqlConnection? conn = null, int lTime = -1, Dictionary<string, object?>? parCollection = null, SqlTransaction? trans = null)
        {
            if (conn != null) return getTSRecordSet(strSql, conn, lTime, parCollection, trans);

            SqlConnection sqlConnection = new(connectionString);
            return getTSRecordSet(strSql, sqlConnection, lTime, parCollection, trans);

        }

        public void ExecuteWithTransaction(string strSql, string connectionstring, SqlConnection? objConnection = null, SqlTransaction? objTransaction = null, int iTimeOut = -1, Dictionary<string, object?>? parCollection = null)
        {
            Execute_(strSql, connectionstring, objConnection, objTransaction, iTimeOut, parCollection);
        }


        public dynamic ExecuteScalar(string strSql, string connectionString, SqlConnection? objConnection = null, int iTimeout = -1, Dictionary<string,object?>? parcollection = null)
        {
            return ExecuteScalar_(strSql, connectionString, objConnection, iTimeout, parcollection);
        }

        public dynamic ExecuteScalar_(string strSql, string connectionString, SqlConnection? objConnection = null, int timeout = -1, Dictionary<string, object?>? parCollection = null)
        {
            SqlConnection conn = (objConnection == null) ? new SqlConnection(connectionString) : objConnection;
            SqlCommand cmd = GetSqlCommand(strSql, sqlConn: conn, lTimeout: timeout, parCollection: parCollection);
            dynamic result = null;
            try
            {

                if (objConnection == null)
                    conn.Open();

                DbProfiler dp = new DbProfiler(ApplicationCommon.Configuration);
                dp.startProfiler();

                result = cmd.ExecuteScalar();

                dp.endProfiler();

                dp.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); // conn.ConnectionString);

            }
            catch (Exception ex)
            {
                throw new Exception($"CommonDbFunctions.ExecuteScakar_() - Exception.Message = '{ex.Message}' - SQL : '{strSql}\'", ex);
            }
            finally
            {

                if (objConnection == null)
                    conn.Close();
            }
            return result;
        }


        public void Execute(string strSql, string connectionstring, SqlConnection? objConnection = null, int timeout = -1, Dictionary<string, object?>? parCollection = null)
        {
            Execute_(strSql, connectionstring, objConnection, timeout: timeout, parCollection: parCollection);
        }

        private void Execute_(string strSql, string connectionstring, SqlConnection? objConnection = null, SqlTransaction? objTransaction = null, int timeout = -1, Dictionary<string, object?>? parCollection = null)
        {
            SqlConnection conn = (objConnection == null) ? new SqlConnection(connectionstring) : objConnection;
            SqlCommand cmd = GetSqlCommand(strSql, sqlConn: conn, objTransaction: objTransaction, lTimeout: timeout, parCollection: parCollection);

            try
            {

                if (objConnection == null)
                    conn.Open();

                DbProfiler dp = new DbProfiler(ApplicationCommon.Configuration);
                dp.startProfiler();

                cmd.ExecuteNonQuery();

                dp.endProfiler();

                dp.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); // conn.ConnectionString);

            }
            catch (Exception ex)
            {
                throw new Exception($"CommonDbFunctions.Execute_() - Exception.Message = \"{ex.Message}\" - SQL : \"{strSql}\"", ex);
            }
            finally
            {

                if (objConnection == null)
                    conn.Close();
            }
        }

        public int GetRSCountNotRead(IConfiguration configuration, string OWNER, long idPfu, string strTable, string strFilter, string FilterHide, string strConnectionString, string strSort = "", int lTime = -1, string strStored = "")
        {
            int result = 0;
            TSRecordSet rs;
            SqlConnection connLocal = new SqlConnection();
            _configuration = configuration;
            string strSql = string.Empty;
            try
            {
                if (strStored.ToLower() != "yes")
                {
                    strSql = $"select count(*) as num from {strTable}";

                    if (!String.IsNullOrEmpty(strFilter))
                    {
                        strSql += $" where {strFilter}";
                        if (!String.IsNullOrEmpty(OWNER))
                        {
                            strSql += $" and {OWNER} = '{idPfu}'";
                        }
                    }
                    else
                    {
                        if (!String.IsNullOrEmpty(OWNER))
                        {
                            strSql += $" where {OWNER} = '{idPfu}'";
                        }
                    }

                    if (String.IsNullOrEmpty(FilterHide))
                    {
                        FilterHide = " bread='1' ";
                    }
                    else
                    {
                        FilterHide += " and bread='1' ";
                    }

                    // accoda alla query il filtro implicito non visibile
                    if (!String.IsNullOrEmpty(FilterHide))
                    {
                        if (!strSql.Contains(" where ", StringComparison.Ordinal))
                        {
                            strSql += $" where {FilterHide}";
                        }
                        else
                        {
                            strSql += $" and {FilterHide}";
                        }
                    }

                    rs = GetRSReadFromQuery_(strSql, strConnectionString, lTime: lTime);

                    result = (int)rs["num"];
                }
                else
                {
                    string[] vl;
                    vl = strFilter.Split("#~#");
                    if (vl.GetUpperBound(0) > 1)
                    {
                        strSql = $"exec {strTable}  {idPfu} , '{vl[0]}' , '{vl[1].Replace("'", "''")}' , '{vl[2]}' ";
                    }
                    else
                    {
                        strSql = $"exec {strTable}  {idPfu} , '' , '' , ''";
                    }

                    FilterHide = FilterHide.Replace("'", "''");
                    if (!String.IsNullOrEmpty(FilterHide))
                    {
                        FilterHide += " bread='1' ";
                    }
                    else
                    {
                        FilterHide += " and bread='1' ";
                    }

                    strSql += " , '" + FilterHide.Replace("'", "''") + "' , '" + strSort + "' , " + "-1" + ",  1";
                    rs = GetRSReadFromQuery_(strSql, strConnectionString, connLocal, lTime: lTime);
                    result = rs.RecordCount;
                }

            }
            catch (Exception ex)
            {
                throw new Exception("CommonDbFunctions.GetRSCountNotRead( " + strSql + "). errore : " + ex.ToString(), ex);
            }

            return result;
        }

        /// <summary>
        /// Imposta la SqlConnection da utilizzare
        /// </summary>
        /// <param name="cnLocal"></param>
        /// <param name="sValue"></param>
        /// <param name="lTimeOut"></param>
        public SqlConnection SetConnection(string sValue)
        {
            if (cnLocal == null)
            {
                cnLocal = new SqlConnection();
            }

            sValue = sValue.Trim();
            cnLocal.ConnectionString = sValue;

            return cnLocal;
        }

        public TSRecordSet User_GetInfoAttrib(long lIdPfu, string Attrib, string strConnectionString)
        {
            string strSql = "";
            try
            {
                strSql = "select dztnome,attvalue from ProfiliutenteAttrib with(nolock) where idpfu = @lIdPfu and dztnome = @Attrib order by IdUsAttr";

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@lIdPfu", lIdPfu);
                sqlParams.Add("@Attrib", Attrib);

                TSRecordSet rs = GetRSReadFromQuery_(strSql, strConnectionString, sqlParams);

                return rs;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message + "User_GetInfoAttrib ( " + strSql + " )", ex);
            }

        }
        /// <summary>
        /// Array di SqlParameter da utilizzare come input per uno statement sql ( SqlCommand )
        /// </summary>
        /// <param name="parameters">Dictionary contenente l'elenco chiave/valore da convertire in SqlParameter</param>
        /// <returns></returns>
        public SqlParameter[]? GetSqlParameters(Dictionary<string, object?> parameters)
        {
            if (parameters == null || parameters.Count < 1) return null;
            KeyValuePair<string, object?> element;
            var sqlParameters = new SqlParameter[parameters.Count];
            for (int i = 0; i < sqlParameters.Length; i++)
            {
                element = parameters.ElementAt(i);

                string newKey = !element.Key.StartsWith("@", StringComparison.Ordinal) ? "@" + element.Key : element.Key;
                dynamic newValue = element.Value == null ? DBNull.Value : element.Value;
                sqlParameters[i] = new SqlParameter(newKey, newValue);

            }
            return sqlParameters;
        }

        /// <summary>
        /// Funzione per verificare se un campo è presente nel field. True : è presente ; false : no è presente
        /// </summary>
        /// <param name="rs">TsRecordSet sul quale controllare la presenza della colonna</param>
        /// <param name="FieldName">Nome della colonna da verificare</param>
        /// <returns></returns>
        public bool FieldExistsInRS(TSRecordSet rs, string FieldName)
        {
            return rs.ColumnExists(FieldName);
        }

        public static string GetDefaultQueryTimeOut()
        {
            return ConfigurationServices.GetKey("SqlCommand:CommandTimeOut", "60");
        }

        public string base64attach(string strTechValue)
        {
            string result = string.Empty;
            TSRecordSet? rsAttach;

            string[] aInfo = strTechValue.Split("*");

            //'--recupero guid
            string strGuid = aInfo[3];

            //'--recupero binario del file
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@ATT_Hash", strGuid);
            rsAttach = GetRSReadFromQuery_("select ATT_Obj from ctl_Attach with(nolock) where ATT_Hash = @ATT_Hash", ApplicationCommon.Application.ConnectionString, sqlParams);

            if (rsAttach != null)
            {
                if (!(rsAttach.EOF && rsAttach.BOF))
                {
                    rsAttach.MoveFirst();
                    if (rsAttach["ATT_Obj"] != null)
                    {
                        //'--restituisco il file
                        //result = Convert.ToBase64String(Encoding.ASCII.GetBytes(rsAttach["ATT_Obj"]));
                        byte[]? inArray = rsAttach["ATT_Obj"] as byte[];

                        if (inArray == null)
                            throw new NullReferenceException("base64attach() - array di byte null");

                        result = Convert.ToBase64String(inArray);
                    }
                    else
                        throw new NullReferenceException("base64attach() - blob null");
                }
            }

            return result;
        }

        /// <summary>
        /// Restituisce una istanza TSRecordSet da un Json
        /// </summary>
        /// <param name="jsonData">Il contenuto di quanto estratto da MongoDb serializzato in formato Json. Il Json in input deve essere al netto delle informazioni aggiunte da MongoDB ("_iod", ObjectId ecc)</param>
        /// <returns>TSRecordSet</returns>
        public TSRecordSet getDeserializedTS(string jsonData)
        {
            TSRecordSet ts = new TSRecordSet();

            if (!String.IsNullOrEmpty(jsonData))
            {
                DataTable? dt;

                var options = new JsonSerializerOptions();
                options.Converters.Add(new CustomJsonConverterForType());
                options.ReferenceHandler = ReferenceHandler.Preserve;

                dt = Newtonsoft.Json.JsonConvert.DeserializeObject<DataTable>(jsonData);
                //dt = JsonSerializer.Deserialize<DataTable>(jsonData, options);

                if (dt == null)
                    throw new NullReferenceException("getDeserializedTS() conversione del jsonData fallito. DataTable null");

                ts.dt = dt;
                ts.position = 0;
                ts.AbsolutePosition = 0;
                ts.RecordCount = dt.Rows.Count;
                ts.filteredDT = dt;
                ts._Fields = dt.Rows;
                ts.Columns = dt.Columns;
                //ts.EOF = dt.Rows.Count <= 0;
                //ts.BOF = dt.Rows.Count <= 0;
            }
            return ts;

        }

        /// <summary>
        /// Restituisce l'equivalente di dell'insieme Fields in TSRecordSet in formato Json
        /// </summary>
        /// <param name="ts">L'istanza TSRecordSet da cui estrarre la stringa Json</param>
        /// <returns>stringa Json</returns>
        public string getSerializedTS(TSRecordSet rs)
        {
            string jsonData = string.Empty;
            if (rs != null && rs.dt != null)
            {
                jsonData = JsonConvert.SerializeObject(rs.dt, Formatting.Indented);
            }

            return jsonData;
        }

        public void ExecSqlNoProfiler(string strSql, string? strConnectionString, SqlConnection? parConnection = null, Dictionary<string, object?>? parCollection = null)
        {
            SqlConnection conn = (parConnection == null) ? new SqlConnection(strConnectionString) : parConnection;
            SqlCommand cmd = GetSqlCommand(strSql, sqlConn: conn);

            cmd.CommandType = CommandType.Text;

            try
            {
                if (parConnection == null)
                    conn.Open();

                if (parCollection != null)
                {
                    SqlParameter[]? param = GetSqlParameters(parCollection);
                    if (param != null)
                        cmd.Parameters.AddRange(param);
                }

                cmd.ExecuteNonQuery();
            }
            catch
            {
                throw;
            }
            finally
            {
                if (parConnection == null)
                    conn.Close();
            }
        }

        public SqlCommand GetSqlCommand(string strSql, string? connectionString = null, SqlConnection? sqlConn = null, SqlTransaction? objTransaction = null, int lTimeout = -1, Dictionary<string, object?>? parCollection = null)
        {
            string strDefaultTimeOut = GetDefaultQueryTimeOut();

            int DefaultTimeout = default;
            int timeOutToUse;

            if (!string.IsNullOrEmpty(strDefaultTimeOut))
            {
                DefaultTimeout = Convert.ToInt32(strDefaultTimeOut);
            }

            timeOutToUse = lTimeout > 0 ? lTimeout : DefaultTimeout;

            SqlCommand sCom = new SqlCommand();
            sCom.CommandTimeout = timeOutToUse;
            if (sqlConn != null)
            {
                sCom.Connection = sqlConn;
            }
            else
            {
                SqlConnection conn = new SqlConnection(connectionString);
                sCom.Connection = conn;
            }
            sCom.CommandText = strSql;

            if (parCollection != null && parCollection.Count > 0)
            {
                SqlParameter[] sqlParms = GetSqlParameters(parCollection);
                sCom.Parameters.AddRange(sqlParms);
            }
            if (objTransaction != null)
            {
                sCom.Transaction = objTransaction;
            }

            return sCom;
        }

        public void SetSqlCommandTimeout(SqlCommand cmd)
        {
            string strDefaultTimeOut = GetDefaultQueryTimeOut();
            cmd.CommandTimeout = Convert.ToInt32(strDefaultTimeOut);
        }
    }
}