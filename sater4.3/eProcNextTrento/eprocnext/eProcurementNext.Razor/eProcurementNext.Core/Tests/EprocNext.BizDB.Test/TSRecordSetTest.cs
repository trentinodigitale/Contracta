using eProcurementNext.CommonDB;
using Microsoft.Extensions.Configuration;
using System.Collections.ObjectModel;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Security.Cryptography;
using Xunit;
using static eProcurementNext.CommonModule.Basic;
using Assert = Xunit.Assert;

namespace eProcurementNext.BizDB.Test
{
    public class TSRecordSetTest : TestBase
    {
        string _connectionString = string.Empty;

        public TSRecordSetTest() : base()
        {
            _connectionString = _configuration.GetConnectionString("DefaultConnection");
        }

        [Fact]
        public void SelectTest()
        {
            string strSql = "select TOP 1 * from _Test";
            var cdf = new CommonDbFunctions();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, _connectionString);
            int number = GetValueFromRS(rs.Fields["Number"]);
            int? number2 = GetValueFromRS(rs.Fields["Number2"]);
        }

        [Fact]
        public void SelectTestWithNullValues()
        {
            string strSql = "select * from _Test2 where Numero = 458";
            var cdf = new CommonDbFunctions();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, _connectionString);
            int number = CInt(rs["Number"]!);
            int? number2 = CInt(rs["Number2"]!);
        }

        [Fact]
        public void SelectParamTest()
        {
            string strSql = "select * from _Test where Id = @id";
            var cdf = new CommonDbFunctions();
            var paramsDic = new Dictionary<string, object?>();
            paramsDic.Add("@id", 1);
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, _connectionString, paramsDic);
            int number = CInt(rs["Number"]!);
            int? number2 = CInt(rs["Number2"]!);
        }

        [Fact]
        public void SelectAllWithImageBlobTest()
        {
            string strSql = "select TOP 1 * from _Test";
            var cdf = new CommonDbFunctions();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, _connectionString);
            dynamic blob = GetValueFromRS(rs.Fields["ImageBlob"]);
        }

        [Fact]
        public void InsertTest()
        {
            TSRecordSet rs = new TSRecordSet();
            rs = rs.Open("SELECT Id, Number FROM _Test WHERE Id=-1", _connectionString);
            DataRow dr = rs.AddNew();
            dr["Number"] = 9;
            EsitoTSRecordSet inserted = rs.Update(dr, "Id", "_Test");
        }

        [Fact]
        public void UpdateTest()
        {
            TSRecordSet rs = new TSRecordSet();
            //rs = rs.Open("SELECT * FROM CTL_ATTACH WHERE ATT_IdRow=-1", _connectionString);
            rs = rs.Open("SELECT Id,Number FROM _Test WHERE Id=2", _connectionString);
            //DataRow dr = new DataRow();
            rs.Fields["Number"] = 38;
            //dr["Number"] = 38;
            EsitoTSRecordSet inserted = rs.Update(rs.Fields, "Id", "_Test");
        }

        [Fact]
        public void InsertTest2()
        {
            TSRecordSet rsObj = new TSRecordSet();
            var cdf = new CommonDbFunctions();
            rsObj = rsObj.Open("SELECT * FROM _Test2 WHERE id=-1", _connectionString);
            //'aggiunge un nuovo record
            DataRow dr = rsObj.AddNew();
            dr["Testo"] = "Test Inserimento 3 RSRecordSet con verifica righee";
            dr["Numero"] = 106;
            rsObj.Update(dr, "id", "_Test2");
        }


        [Fact]
        public void UpdateTest2()
        {
            TSRecordSet rs = new TSRecordSet();
            var strSql = "select * from _Test2";
            rs = rs.Open(strSql, _connectionString);
            int numeroRighe = rs.RecordCount;

            DataRow dr = rs.dt.NewRow();
            dr["id"] = 19;
            dr["Testo"] = "Modifica Nuovo Update 2";
            dr["Numero"] = 67890;
            rs.Update(dr, "Id", "_Test2");
        }

        [Fact]
        public void UpdateTestWithPar()
        {
            TSRecordSet rs = new TSRecordSet();
            var strSql = "select * from _Test2";
            rs = rs.Open(strSql, _connectionString);
            int numeroRighe = rs.RecordCount;

            DataRow dr = rs.dt.NewRow();
            dr["id"] = 19;
            dr["Testo"] = "Modifica Nuovo Update";
            dr["Numero"] = 12345;
            rs.Update(dr, "Id", "_Test2");

            Dictionary<string, object?> dic = new Dictionary<string, object?>();
            dic.Add("Testo", "Modifica Nuovo Update con Parametri");
            dic.Add("Numero", "5432100");
            rs.Update(dr, "Id", "_Test2", dic);
        }

        [Fact]
        public void BlobTest()
        {
            long bytesLength = 20 * 1024 * 1024;

            string currentDirectory = System.IO.Directory.GetCurrentDirectory();
            string filePath = Path.Combine(currentDirectory, "saveToRecordSetTestFile");
            string readFilePath = Path.Combine(currentDirectory, "saveToRecordSetTestFile_read");

            //testare se la dimensione è cambiata
            if (!File.Exists(filePath) || (new FileInfo(filePath)).Length == 0)
            {
                byte[] buffer = new byte[10000];
                Random random = new Random();

                using FileStream fs = new FileStream(filePath, FileMode.Create, FileAccess.Write);
                while (bytesLength > buffer.Length)
                {
                    random.NextBytes(buffer);
                    fs.Write(buffer);
                    bytesLength -= buffer.Length;
                }
                random.NextBytes(buffer);
                fs.Write(buffer, 0, (int)bytesLength);
            }

            Assert.True(File.Exists(filePath), "file di test non esiste");
            Assert.True((new FileInfo(filePath)).Length > 0, "file di test vuoto");

            try
            {
                var cdf = new CommonDbFunctions();
                var strSql = "select * from _Test WHERE Id=1"; // 

                TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, _connectionString);

                var sw = new Stopwatch();
                sw.Start();
                eProcurementNext.CommonDB.Basic.SaveToRecordset("ImageBlob", "_Test", "Id", 1, filePath, _connectionString);
                //EprocNext.CommonDB.Basic.SaveToRecordset_(rs.Columns["ImageBlob"], "_Test", "Id", "1", filePath, _connectionString);
                sw.Stop();
                TimeSpan elapsed = sw.Elapsed;

                eProcurementNext.CommonDB.Basic.saveFileFromRecordSet("ImageBlob", "_Test", "Id", "1", readFilePath, _connectionString);
                //EprocNext.CommonDB.Basic.saveFileFromRecordSet(rs.Columns["ImageBlob"], "_Test", "Id", "1", readFilePath, _connectionString);
                Assert.True(File.Exists(readFilePath));

                using FileStream fs = File.Open(filePath, FileMode.Open, FileAccess.Read),
                        fs2 = File.Open(readFilePath, FileMode.Open, FileAccess.Read);
                byte[] hash = SHA256.Create().ComputeHash(fs);
                byte[] hash2 = SHA256.Create().ComputeHash(fs2);
                Assert.Equal(hash, hash2);
            }
            finally
            {
                if (File.Exists(filePath))
                {
                    File.Delete(filePath);
                }

                if (File.Exists(readFilePath))
                {
                    File.Delete(readFilePath);
                }
            }
        }



        [Fact]
        public void SchemaTest()
        {
            string _strSql1 = "select * from _Test";

            string _strSql2 = "SELECT* FROM CTL_ATTACH WHERE ATT_IdRow = -1";

            string _strSql = _strSql1;

            SqlCommand cmd = new SqlCommand();
            SqlDataAdapter da = new SqlDataAdapter();
            DataSet ds = new DataSet();

            SqlConnection conn = new SqlConnection(_connectionString);
            cmd.Connection = conn;
            cmd.CommandText = _strSql;
            cmd.CommandType = CommandType.Text;

            da.SelectCommand = cmd;

            //da.Fill(ds);

            //DataTable dt = new DataTable("_Test");
            //da.FillSchema(dt, SchemaType.Source);

            if (conn.State == ConnectionState.Closed)
            {
                conn.Open();
            }

            string fieldName = string.Empty;
            string typeName = string.Empty;

            using var reader = cmd.ExecuteReader(CommandBehavior.SchemaOnly);
            var ColumnSchema = reader.GetColumnSchema();

            //for (int i = 0; i < reader.FieldCount; i++)
            //{
            //    fieldName = reader.GetName(i);
            //    typeName = reader.GetDataTypeName(i);
            //}


            //Using Reader As SqlDataReader = cmd.ExecuteReader(CommandBehavior.SchemaOnly)
            //    For i As Integer = 0 To Reader.FieldCount - 1
            //        Me.ListBox1.Items.Add(String.Format("{0}: {1}", Reader.GetName(i), Reader.GetDataTypeName(i)))

            //    Next
            //End Using


            //DataTable dtSchema = new DataTable();
            //da.FillSchema(ds, SchemaType.Source, "_Test");
            //da.Fill(ds, "_Test");

            //Assert.True(ds.Tables.Count > 1, $"DataSet tables: {ds.Tables.Count}. ");

            //string nomeColonna = "Number";

            //dtSchema.Select($"COLUMN_NAME = '{nomeColonna}'");
        }

        [Fact]
        public void SchemaTest2()
        {
            string _strSql1a = "select * from _Test where Id = -1";
            string _strSql1b = "select * from _Test where Id = 1";

            string _strSql2 = "SELECT* FROM CTL_ATTACH WHERE ATT_IdRow = -1";

            string _strSql = _strSql1b;

            SqlCommand cmd = new SqlCommand();
            SqlDataAdapter da = new SqlDataAdapter();
            DataSet ds = new DataSet();

            SqlConnection conn = new SqlConnection(_connectionString);
            cmd.Connection = conn;
            cmd.CommandText = _strSql;
            cmd.CommandType = CommandType.Text;

            if (conn.State == ConnectionState.Closed)
            {
                conn.Open();
            }

            using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow  /*CommandBehavior.SchemaOnly*/))
            {
                ReadOnlyCollection<System.Data.Common.DbColumn> columnSchema = reader.GetColumnSchema();
                var number1 = columnSchema.FirstOrDefault(c => c.ColumnName == "Number");

                reader.Read();

                var number1Value = reader.GetValue("Number");

                //object[] values = new object[] { };
                //int columsCount = columnSchema.Count();
                //Array.Resize(ref values, columsCount);
                //reader.GetValues(values);

                //da.Fill(ds);

            }

            if (conn.State == ConnectionState.Open)
            {
                conn.Close();
            }

        }


        [Fact]
        public async void WriteBinaryTest()
        {
            string currentDirectory = System.IO.Directory.GetCurrentDirectory();
            string filePath = Path.Combine(currentDirectory, "outFile");

            using SqlConnection conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            using SqlCommand cmd = new SqlCommand("INSERT INTO [_Test] (ImageBLOB) VALUES (@bindata)", conn);
            using FileStream file = File.Open(filePath, FileMode.Open);

            // Add a parameter which uses the FileStream we just opened
            // Size is set to -1 to indicate "MAX"
            cmd.Parameters.Add("@bindata", SqlDbType.Binary, -1).Value = file;

            // Send the data to the server asynchronously
            await cmd.ExecuteNonQueryAsync();
        }

        [Fact]
        public void ReadBinaryTest()
        {
            string currentDirectory = System.IO.Directory.GetCurrentDirectory();
            string outfilePath = Path.Combine(currentDirectory, "outFile");

            SqlConnection conn;
            SqlCommand cmd;
            FileStream stream;
            BinaryWriter writer;

            try
            {
                stream = new FileStream(outfilePath, FileMode.OpenOrCreate, FileAccess.Write);
                writer = new BinaryWriter(stream);
                conn = new SqlConnection(_connectionString);
                cmd = new SqlCommand();
                cmd.Connection = conn;

                //string strSql = $"select {fldName} from [{tableName}] where {colIdentity} = {key}";
                //string strSql = $"select ATT_Obj from CTL_Attach where ATT_IdRow = 10";
                string strSql = $"select ImageBLOB from _Test where Id = 1";


                cmd.CommandText = strSql;
                cmd.CommandType = CommandType.Text;

                conn.Open();

                const int bufferSize = 10000;

                byte[] buffer = new byte[bufferSize];

                //buffer[5748] = 240;

                using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                {
                    ReadOnlyCollection<System.Data.Common.DbColumn> columnSchema = reader.GetColumnSchema();
                    int ordinal = reader.GetOrdinal("ImageBLOB");

                    //int size = 0;
                    //for (int i = 0; i < columnSchema.Count; i++)
                    //{
                    //    if (ordinal == columnSchema[0].ColumnOrdinal) {
                    //        size = columnSchema[0].ColumnSize.Value;
                    //        break;
                    //    }
                    //}

                    //if (size == null || size == 0)
                    //{
                    //    throw new Exception("size error");
                    //}

                    //int bytesToRead = size;


                    reader.Read();

                    int startIndex = 0;
                    long retval = reader.GetBytes(ordinal, startIndex, buffer, 0, bufferSize);
                    while (retval == bufferSize)
                    {
                        writer.Write(buffer);
                        writer.Flush();

                        startIndex += bufferSize;
                        retval = reader.GetBytes(ordinal, startIndex, buffer, 0, bufferSize);
                    }

                    writer.Write(buffer, 0, (int)retval);
                    writer.Flush();

                    //while (bytesToRead > 0)
                    //{
                    //    reader.GetBytes(ordinal, 0, buffer, 0, BufSize);
                    //    bytesToRead -= BufSize;
                    //}

                    //byte[] attObj = (byte[])reader.GetValue("ATT_Obj");
                    //int s = attObj.Length;

                    writer.Close();
                    stream.Close();
                }

                conn.Close();
            }
            finally
            {

            }
        }


        [Fact]
        public void ATest()
        {
            string strSql = "select * from _Test where Id = 1";

            //string strSql = _strSql1b;

            SqlCommand cmd = new SqlCommand();
            SqlDataAdapter da = new SqlDataAdapter();
            DataSet ds = new DataSet();

            SqlConnection conn = new SqlConnection(_connectionString);
            cmd.Connection = conn;
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;

            da.SelectCommand = cmd;
            da.Fill(ds);
        }

        [Fact]
        public void ATestConParm()
        {
            string strSql = "select * from _Test2 where Id = @id";
            Dictionary<string, object?> parrColl = new Dictionary<string, object?>();
            parrColl.Add("@id", 1);
            //string strSql = _strSql1b;

            CommonDbFunctions cdf = new CommonDbFunctions();

            cdf.Execute(strSql, _connectionString, null, parCollection: parrColl);
        }

        [Fact]
        public void ATestConParmTS()
        {
            string strSql = "select * from _Test2 where Id = @id";
            Dictionary<string, object?> parrColl = new Dictionary<string, object?>();
            parrColl.Add("@id", 1);
            //string strSql = _strSql1b;

            CommonDbFunctions cdf = new CommonDbFunctions();

            TSRecordSet ts = new TSRecordSet();
            ts = cdf.GetRSReadFromQuery_(strSql, _connectionString, parrColl);
        }

        [Fact]
        public void testProfiler()
        {
            string strSql = "select * from _Test2";
            TSRecordSet ts = new TSRecordSet();
            ts.Open(strSql, _connectionString);
            int nrec = ts.RecordCount;

        }

    }
}
