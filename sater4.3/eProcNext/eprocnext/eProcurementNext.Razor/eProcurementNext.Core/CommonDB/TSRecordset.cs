using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule.Exceptions;
using System.Data;
using System.Data.SqlClient;

namespace eProcurementNext.CommonDB
{
    public class TSRecordSet : ICloneable
    {
        public DataTable? dt { get; set; }
        public DataTable? filteredDT { get; set; }
        public DataColumnCollection? Columns { get; set; }
        public DataRowCollection? _Fields { get; set; }
        private readonly SqlDataAdapter da;
        public SqlCommand cmd;
        private readonly DataSet ds;
        private SqlTransaction? _tran = null;
        const string adFilterNone = "";
        public int RecordCount { get; set; } = 0;
        public int AbsolutePosition
        {

            get
            {
                return position;
            }
            set
            {
                position = value;
            }
        }
        public int position { get; set; } = 0;
        private string _strSql = string.Empty;
        private string _connectionString = string.Empty;
        private readonly CommonDbFunctions cdf;

        public TSRecordSet()
        {
            da = new SqlDataAdapter();
            cmd = new SqlCommand();
            ds = new DataSet();
            cdf = new CommonDbFunctions();
        }

        public bool EOF
        {
            get
            {
                return this.position == this.RecordCount;
            }
        }

        public bool BOF
        {
            get
            {
                return this.position == 0;
            }
        }

        public DataRow? Fields
        {
            get
            {
                if (_Fields is not null && _Fields.Count != 0)
                {
                    return _Fields[this.position];
                }
                else
                {
                    return null;
                }
            }
        }

        /// <summary>
        /// Naviga al primo record contenuto nel recordset
        /// </summary>
        public void MoveFirst()
        {
            if (EOF && BOF)
            {
                return;
            }
            this.position = 0;
        }

        /// <summary>
        /// naviga all'ultimo record contenuto nel recordset
        /// </summary>
        public void MoveLast()
        {
            if ((EOF && BOF) || _Fields == null)
            {
                return;
            }
            this.position = _Fields.Count - 1;
        }


        /// <summary>
        ///  naviga al record successivo contenuto nel recordset
        /// </summary>
        public void MoveNext()
        {
            if (!EOF)
            {
                this.position++;
            }


        }

        /// <summary>
        /// Ottiene una istanza dell'oggetto RecordSet 
        /// </summary>
        /// <param name="connectionString">Stringa di connessione da utilizzare per il recupero dei dati</param>
        /// <param name="strSql">Query SQL da utilizzare per il recupero dei dati</param>
        /// <param name="nomeTabella">La Tabella che contiene lo schema da utilizzare per le eventuali operazioni CRU(D). L'operazione di cancellazione non è al momento implementata</param>
        /// <returns></returns>
        public TSRecordSet? Open(string strSql, string connectionString, Dictionary<string, object?>? parColl = null, SqlConnection? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            try
            {
                _connectionString = connectionString;
                _strSql = strSql;
                _tran = transaction;

                SqlConnection conn;

                if (connection is null)
                    conn = new SqlConnection(connectionString);
                else
                    conn = connection;

                cmd = cdf.GetSqlCommand(_strSql, connectionString, conn, objTransaction: transaction, lTimeout: timeout, parCollection: parColl);

                da.SelectCommand = cmd;

                DbProfiler dbf = new(ApplicationCommon.Configuration);
                dbf.startProfiler();

                da.Fill(ds);

                dbf.endProfiler();
                dbf.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString); // connectionString);
                if (ds.Tables.Count > 0)
                {
                    dt = ds.Tables[0];


                    this.RecordCount = dt.Rows.Count;
                    this._Fields = dt.Rows;
                    this.Columns = dt.Columns;
                }
                else
                {
                    throw new SqlTableNotFoundException("Stringa sql: " + strSql);

                }
            }
            catch (SqlTableNotFoundException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new Exception($"TSRecordSet.Open() - Exception.Message = \"{ex.Message}\" - SQL : \"{strSql}\"", ex);
            }

            return this;
        }


        public TSRecordSet OpenWithTransaction(string strSql, SqlConnection connection, SqlTransaction? transaction, Dictionary<string, object?>? parColl = null, int timeout = -1)
        {
            return Open(strSql, connection.ConnectionString, parColl, connection, transaction, timeout);
        }
        /// <summary>
        /// Consente di ottenere un SOTTOINSIEME del recordset basato sul filtro
        /// </summary>
        /// <param name="filtro">Raprpesenta la clausola where</param>
        public void Filter(string filtro)
        {
            if (dt == null)
                throw new NullReferenceException("Filter non possibile con DataTable null");

            if (String.IsNullOrEmpty(filtro))
            {
                this.RecordCount = dt.Rows.Count;
                this._Fields = dt.Rows;
                this.Columns = dt.Columns;
                this.position = 0;
            }
            else
            {
                DataTable backup;

                backup = dt.Clone();

                DataRow[] foundRows;
                foundRows = dt.Select(filtro);

                foreach (DataRow r in foundRows)
                {
                    backup.ImportRow(r);
                }

                this.RecordCount = backup.Rows.Count;
                this._Fields = backup.Rows;
                this.position = 0;
            }

        }

        /// <summary>
        /// Cancella il filtro impostato e ripristina il recordset iniziale non filtrato
        /// </summary>
        public void clearFiltro()
        {
            if (filteredDT == null || dt == null)
                throw new NullReferenceException("clearFiltro non possibile con DataTable null");

            if (filteredDT.Rows.Count > 0)
            {
                filteredDT.Rows.Clear();
                this.RecordCount = dt.Rows.Count;
                this._Fields = dt.Rows;
                this.Columns = dt.Columns;
                this.position = 0;
            }
        }

        /// <summary>
        /// naviga alla posizione del recordset che contiene il record corrispondente alla condizione filtro. Non modifica l'insieme di record
        /// </summary>
        /// <param name="filtro"></param>
        public bool Find(string filtro)
        {

            if (filteredDT == null && dt == null)
                throw new NullReferenceException("clearFiltro non possibile con DataTable null");
            if (_Fields == null)
                throw new NullReferenceException("Find non possibile con DataRowCollection null");

            if (filteredDT is not null && filteredDT.Rows.Count > 0)
            {
                DataRow[] aDR = filteredDT.Select(filtro);
                if (aDR.Length == 0)
                {
                    this.position = this.RecordCount;
                    return false;
                }

                int counter = 0;

                foreach (DataRow dr in _Fields)
                {
                    if (dr == aDR[0])
                    {
                        this.position = counter;
                        break;
                    }
                    counter++;
                }

                if (aDR.Length == 1)
                {
                    return true;
                }


            }
            else
            {

                DataRow[] aDR = dt.Select(filtro);
                if (aDR.Length == 0)
                {
                    this.position = this.RecordCount;
                    return false;
                }

                int counter = 0;

                foreach (DataRow dr in this._Fields)
                {
                    if (dr == aDR[0])
                    {
                        this.position = counter;
                        break;
                    }
                    counter++;
                }

                if (aDR.Length == 1)
                {
                    return true;
                }
            }

            return false;
        }


        /// <summary>
        /// Ottiene una istanza DataRow da inviare all'Update per gestire l'inserimento di un nuovo record
        /// </summary>
        /// <returns></returns>
        public DataRow AddNew()
        {
            if (dt == null)
                throw new NullReferenceException("AddNew non possibile con DataTable null");

            if (this.position > -1)
            {
                this.position = -1;
            }
            return dt.NewRow();

        }

        /// <summary>
        /// Ottiene una istanza DataRow da inviare all'Update per gestire l'inserimento di un nuovo record
        /// </summary>
        /// <returns></returns>
        public DataRow getNewDataRow()
        {
            if (dt == null)
                throw new NullReferenceException("getNewDataRow non possibile con DataTable null");

            if (this.position > -1)
            {
                this.position = -1;
            }
            return dt.NewRow();
        }

        /// <summary>
        /// Aggiornamento record. colIdentity è obbligatorio e non è prevista una valorizzazione della colonna "identity" dal chiamante.
        /// </summary>
        /// <param name="dr">DataRow contenente i valori del record da aggiornare/inserire</param>
        /// <param name="colIdentity">Nome della colonna che nella tabella contiene il riferimento identity</param>
        /// <param name="nomeTabella">Nome della tabella oggetto di Insert o di Update</param>
        /// <param name="parCollection">Dizionario contenente i parametri SQL utilizzati nello script sql</param>
        public EsitoTSRecordSet Update(DataRow dr, string colIdentity, string nomeTabella, Dictionary<string, dynamic?>? parCollection = null)
        {
            if(parCollection != null)
            {
                foreach (var item in parCollection) 
                {
                    if(item.Value is Double)
                    {
                        var backupValue = item.Value;
                        try
                        {
                            decimal tempDecimal = (decimal)backupValue;
                            parCollection[item.Key] = tempDecimal;
                        }
                        catch
                        {
							parCollection[item.Key] = backupValue;
						}
                    }
                }

            }

            if (dt == null)
                throw new NullReferenceException("Update non possibile con DataTable null");

            cdf.SetSqlCommandTimeout(cmd);

            EsitoTSRecordSet risultato = new EsitoTSRecordSet();
            string strSql = String.Empty;

            try
            {
	            int c;
	            SqlParameter par;
	            if (position > -1)
                {

	                if (dr is null)
		                throw new SqlUpdateException($"Update della tabella {nomeTabella} non possibile. Recupero del valore di colIdentity bloccato a causa del DatRow null");

                    DataColumn[] dkey = dt.PrimaryKey;
                    string[] strColName = new string[dkey.Length];

                    if (dkey.Length > 0)
                    {
                        for (int i = 0; i <= dkey.Length; i++)
                        {
                            strColName[i] = dkey[i].ColumnName;
                        }
                    }
                    else if (string.IsNullOrWhiteSpace(colIdentity))
                    {
                        /*strColName = new string[1];
                        for (int i = 0; i < dt.Columns.Count; i++)
                        {
                            if (dt.Columns[i].AutoIncrement)
                            {
                                strColName[i] = dkey[i].ColumnName;
                                break;
                            }
                        }*/
                        throw new SqlUpdateException("colIdentity not found");
                    }
                    else
                    {
                        strColName = new string[1];
                        strColName[0] = colIdentity;
                    }

                    if (parCollection == null)
                    {

                        strSql = $"Update {nomeTabella} SET ";

                        for (c = 0; c < dt.Columns.Count; c++)
                        {
                            var x = dt.Columns[c].ColumnName;
                            if (x.Length > 0 && x.ToUpper() != colIdentity.ToUpper())
                            {
                                strSql += $"[{dt.Columns[c].ColumnName}] = @p{c}, ";
                                par = new SqlParameter();
                                par.ParameterName = $"@p{c}";
                                par.Value = dr[c];

                                cmd.Parameters.Add(par);

                            }
                        }

                        strSql = strSql.Substring(0, strSql.Length - 2);
                        strSql += $" where {strColName[0]} = @p{c};";
                        par = new SqlParameter();
                        par.ParameterName = $"@p{c}";
                        par.Value = dr[strColName[0]];
                        cmd.Parameters.Add(par);
                        cmd.CommandText = strSql;

                        if (_tran != null)
                            cmd.Transaction = _tran;

                    }
                    else
                    {
                        SqlParameter[]? updParameters = cdf.GetSqlParameters(parCollection);

                        if (updParameters == null)
                            throw new NullReferenceException("Update non possibile con updParameters null");

                        strSql = $"Update {nomeTabella} SET ";
                        foreach (SqlParameter p in updParameters)
                        {
                            bool isIdentityParam = string.Equals(p.ParameterName, colIdentity, StringComparison.CurrentCultureIgnoreCase) || p.ParameterName.ToUpper() == $"@{colIdentity.ToUpper()}";
                            if (isIdentityParam) continue;
                            strSql += $" [{p.ParameterName.Replace("@", "")}] = {p.ParameterName}, ";
                            cmd.Parameters.Add(p);
                        }
                        strSql = strSql.Substring(0, strSql.Length - 2);
                        strSql += $" where {colIdentity} = @p{colIdentity};";
                        SqlParameter parId = new SqlParameter();
                        parId.ParameterName = $"@p{colIdentity}";
                        parId.Value = dr[strColName[0]];
                        cmd.Parameters.Add(parId);
                        cmd.CommandText = strSql;

                        if (_tran != null)
                            cmd.Transaction = _tran;

                    }

                    da.UpdateCommand = cmd;
                    risultato.tipoOperazione = "U";

                }
                else
                {
                    strSql = $"INSERT INTO {nomeTabella} (";

                    for (c = 0; c < dt.Columns.Count; c++)
                    {
                        var x = dt.Columns[c].ColumnName;
                        if (x.Length > 0 && x.ToUpper() != colIdentity.ToUpper() && dr[dt.Columns[c].ColumnName] != DBNull.Value)
                        {
                            strSql += $"[{dt.Columns[c].ColumnName}], ";
                        }
                    }
                    strSql = strSql.Substring(0, strSql.Length - 2);
                    strSql += ") VALUES(";

                    for (c = 0; c < dt.Columns.Count; c++)
                    {
                        if (dt.Columns[c].ColumnName.ToUpper() != colIdentity.ToUpper() && dr[dt.Columns[c].ColumnName] != DBNull.Value)
                        {
                            par = new SqlParameter();
                            par.ParameterName = $"@p{c}";
                            strSql += $"@p{c}, ";
                            par.Value = dr[c];
                            cmd.Parameters.Add(par);
                        }
                    }
                    cmd.Parameters.Add("@MyId", SqlDbType.Int, 0, colIdentity).Direction = ParameterDirection.Output;
                    strSql = strSql.Substring(0, strSql.Length - 2);
                    strSql += ");";

                    strSql += " SET @MyID = SCOPE_IDENTITY();";

                    cmd.CommandText = strSql;

                    if (_tran != null)
                        cmd.Transaction = _tran;

                    da.InsertCommand = cmd;
                    da.InsertCommand.UpdatedRowSource = UpdateRowSource.FirstReturnedRecord;
                    risultato.tipoOperazione = "I";
                }

                da.AcceptChangesDuringUpdate = true;
                DbProfiler df = new DbProfiler(ApplicationCommon.Configuration);
                df.startProfiler();
                risultato.numeroRigheInserite = da.Fill(ds);
                df.endProfiler();
                df.traceDbProfiler(strSql, ApplicationCommon.Application.ConnectionString);

                if (risultato.tipoOperazione == "I")
                {
                    risultato.id = Convert.ToInt32(cmd.Parameters["@MyId"].Value.ToString());
                }

                this.RecordCount = dt.Rows.Count;
                this.position = 0;
                risultato.esito = true;
                cmd.Parameters.Clear();
            }
            catch (Exception ex)
            {
                throw new SqlUpdateException($"TSRecordSet.Update() - Exception.Message = \"{ex.Message}\" - SQL : \"{strSql}\"", ex);
            }

            return risultato;

        }


		/// <summary>
		/// Metodo per ordinare i dati contenuti nella DataTable. 
		/// Vengono accettati solo nomi di colonne e non codice SQL (ad es. un CAST)
		/// </summary>
		/// <param name="sortValue"> Nomi delle colonne soggetti all'order by </param>
		/// <exception cref="NullReferenceException"></exception>
		public void Sort(string sortValue)
        {

            if (filteredDT == null && dt == null)
                throw new NullReferenceException("Sort non possibile con DataTable null");

            DataTable sortedTable;

            if (filteredDT != null && filteredDT.Rows.Count > 0)
            {
                sortedTable = filteredDT;
            }
            else if (dt != null)
            {
                sortedTable = dt;
            }
            else
            {
                throw new NullReferenceException("Sort non possibile con DataTable null");
            }

            sortedTable.DefaultView.Sort = sortValue;
            sortedTable = sortedTable.DefaultView.ToTable(true);

            this.RecordCount = sortedTable.Rows.Count;
            this._Fields = sortedTable.Rows;
            this.position = 0;

            if (filteredDT != null && filteredDT.Rows.Count > 0)
            {
                filteredDT = sortedTable;

            }
            else if (dt != null)
            {
                dt = sortedTable;
            }

        }


        public object Clone()
        {
            return MemberwiseClone();
        }

        public bool ColumnExists(string columnName)
        {
            if (this.Columns == null)
                throw new NullReferenceException("ColumnExists non possibile con Columns null");

            if (this.Columns.Contains(columnName))
                return true;

            return false;
        }

        public object? this[string columnName]
        {
            get
            {
                if (this.Fields == null)
                    throw new NullReferenceException("Recupero dati non possibile con Fields null");

                object? value = this.Fields.GetValueFromRS(columnName);
                return value;
            }
        }
        public object? this[int indexCol]
        {
            get
            {
                if (this.Fields == null)
                    throw new NullReferenceException("Recupero dati non possibile con Fields null");

                object? value = this.Fields.GetValueFromRS(indexCol);
                return value;
            }
        }

    }

    /// <summary>
    /// Classe utile per gli Extension Methods di DataRow. Utile in accoppiata a DataTable e TsRecordSet
    /// </summary>
    public static class DataRowExtension
    {
        /// <summary>
        /// Extension Methods di DataRow, permette di ottenere il valore di una colonna gestendo il DBNull come null
        /// </summary>
        /// <param name="colName">Nome della colonna per la quale si vuole ottenere il valore</param>
        /// <returns>Valore nullable della colonna richiesta</returns>
        public static object? GetValueFromRS(this DataRow dr, string colName)
        {
            object? val = dr[colName];
            if (val is DBNull)
            {
                return null;
            }

            return val;
        }

        /// <summary>
        /// Extension Methods di DataRow, permette di ottenere il valore di una colonna gestendo il DBNull come null
        /// </summary>
        /// <param name="colName">Posizione della colonna per la quale si vuole ottenere il valore</param>
        /// <returns>Valore nullable della colonna richiesta</returns>
        public static object? GetValueFromRS(this DataRow dr, int colPosition)
        {
            object? val = dr[colPosition];
            if (val is DBNull)
            {
                return null;
            }

            return val;
        }
    }
}

