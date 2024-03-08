using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.Core.Storage;
using Microsoft.Extensions.Configuration;
using System.Data;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.CtlProcess.Test
{
    [TestClass]
    public class ElabTest
    {
        const string ConnectionStringsKey = "ConnectionStrings";

        private readonly IConfiguration _configuration;

        private string GetConfigPath()
        {
            string configPath = "";

            var t = Path.GetFullPath(@"..\..\", Directory.GetCurrentDirectory());
            if (Path.GetDirectoryName(t).EndsWith("x64"))
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }
            else
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }

            return configPath;
        }

        public ElabTest()
        {
            var configPath = GetConfigPath();
            var exists = Directory.Exists(configPath);

            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                //.AddEnvironmentVariables()
                .Build();

            ApplicationCommon.Configuration = _configuration;

        }

        private ELAB_RET_CODE TestElaborate(string strProcessName, string strDocType, ref string strDescrRetCode, dynamic? strDocKey = null, long lIdPfu = -20)
        {
            string vConnectionString = "";

            var connectionStringsCfg = _configuration.GetSection(ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();

            vConnectionString = _configuration.GetConnectionString("DefaultConnection");

            if (strDocKey == null)
                strDocKey = -1;
            dynamic? vIdMp = 1;

            ClsElab elab = new ClsElab();

            return elab.Elaborate(strProcessName, strDocType, strDocKey, lIdPfu, ref strDescrRetCode, vIdMp, vConnectionString);
        }

        // strProcessName = DPR_ID / strDocType = DPR_DOC_ID
        private void TestElaborate(string strProcessName, string strDocType, dynamic? strDocKey = null, long lIdPfu = -20)
        {
            string strDescrRetCode = "";
            TestElaborate(strProcessName, strDocType, ref strDescrRetCode, strDocKey, lIdPfu);
        }

        [TestMethod]
        public void Elaborate_clsSetValue()
        {
            TestElaborate("clsSetValue", "REFACTORING_UNITTEST");
        }

        [TestMethod]
        public void Elaborate_clsCheckAndUpd()
        {
            string strDescrRetCode = "";
            //TestElaborate(strProcessName, strDocType, ref strDescrRetCode);
            //Assert.IsNotNull(strDescrRetCode);

            ELAB_RET_CODE retCode = TestElaborate("clsCheckAndUpd", "REFACTORING_UNITTEST", ref strDescrRetCode);
            Assert.IsTrue(string.IsNullOrEmpty(strDescrRetCode));

            retCode = TestElaborate("clsCheckAndUpd_condfalse", "REFACTORING_UNITTEST", ref strDescrRetCode);
            Assert.IsTrue(!string.IsNullOrEmpty(strDescrRetCode));
        }

        [TestMethod]
        public void Elaborate_clsSubProcess()
        {
            string strDescrRetCode = "";
            ELAB_RET_CODE retCode = TestElaborate("clsSubProcess", "REFACTORING_UNITTEST", ref strDescrRetCode);
        }

        [TestMethod]
        public void TestSendMailLevelUp()
        {
            TestElaborate("SEND_MAIL_LEVEL_UP", "REFACTORING", 423271);
        }

        [TestMethod]
        public void TestSendPec()
        {
            TestElaborate("SEND_MAIL_PEC", "REFACTORING", 423309);
        }
        [TestMethod]
        public void TestSendMail()
        {
            TestElaborate("EMAIL", "TEST_SYS", 423309);
        }

        [TestMethod]
        public void TestCTLMailsystem()
        {
            TestElaborate("RUN", "CTLMAILSYSTEM", 71680);
        }

        [TestMethod]
        public void TestInvokeService()
        {
            TestElaborate("VERIFICA_FASCICOLO", "PROTOCOLLO_GENERALE", 423143);
        }

        [TestMethod]
        public void TestVerifySign()
        {
            TestElaborate("SIGN_PENDING", "SIGN_VERIFY");
        }


        [TestMethod]
        public void TestDecryptAttch()
        {
            TestElaborate("DECIFRA_FILE_SUB", "CIFRATURA", 230940);
        }

        //[TestMethod]
        //public void Elaborate_clsSetValue_()
        //{

        //    TestElaborate("XX", "XX");
        //}

        //[TestMethod]
        //public void _Elaborate_clsSetValue()
        //{
        //    TestElaborate("XX", "XX");
        //}

        //[TestMethod]
        //public void Elaborate_ServizieProcessi()
        //{
        //    TestElaborate("TEST_PROCESS_1", "REFACTORING");
        //}

        //[TestMethod]
        //public void Elaborate_clsSubProcess()
        //{
        //    TestElaborate("TEST_PROCESS_1", "REFACTORING");
        //}

        [TestMethod]
        public void Elaborate_clsDownloader()
        {
            TestElaborate("TEST_CLS_DOWNLOADER", "REFACTORING");
        }

        [TestMethod]
        public void Elaborate_clsGetProtocol()
        {
            TestElaborate("TEST_PROTOCOL", "NUOVA_CONVENZIONE");
        }

        //[TestMethod]
        //public async Task TestURLDownloadToFileAsync()
        //{
        //    await Basic.DownloadFileFromWebAsync(@"http://files.customersaas.com/files/34NQcSAEa9X8glBfsI9Z9XYk.pdf", @"E:\Downloads\Samsung.pdf");
        //}

        [TestMethod]
        public void TestSemaphore()
        {
            ClsSemaphore semaforo = new ClsSemaphore();
            semaforo.Dispose();
            //semaforo = null;
        }

        [TestMethod]
        public void TestTime()
        {
            string time = Convert.ToDateTime(DateTime.Now).ToString("yyyyMMddhhmmss");
        }

        [TestMethod]
        public void TestWriteFile()
        {
            CommonStorage.Write(@"E:\PortaleGareTelematiche\Allegati\pippo.txt", "ERRORE 2040!");
        }

        [TestMethod]
        public void UpdateTest2()
        {
            var connectionStringsCfg = _configuration.GetSection(ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();

            string vConnectionString = _configuration.GetConnectionString("DefaultConnection");

            TSRecordSet? rs = new TSRecordSet();

            var cdf = new CommonDbFunctions();
            var strSql = "select * from _Test WHERE id=1"; // 

            try
            {
                rs = rs.Open(strSql, vConnectionString); // cdf.GetRSReadFromQuery_(strSql, vConnectionString);

                //if (rs.RecordCount > 0)
                //{
                //    rs.Fields["id"] = 1;
                //    rs.Fields["Testo"] = "Pippo4";
                //    rs.Fields["Numero"] = 61;
                //    rs.Update(rs.Fields, "id", "_Test2");
                //}

                System.Data.DataRow dr = rs.AddNew();
                dr["Testo"] = "Nuovo Testo";
                dr["Numero"] = 92;
                rs.Update(dr, "id", "_Test2");
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message, ex.InnerException);
            }

        }
        [TestMethod]
        public void TestTransazione()
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            int iCount = 0;

            var connectionStringsCfg = _configuration.GetSection(ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();

            string vConnectionString = _configuration.GetConnectionString("DefaultConnection");

            System.Data.SqlClient.SqlConnection cnLocal = cdf.SetConnection(vConnectionString);
            cnLocal.Open();

            try
            {
                // QUERY SENZA TRANSAZIONE
                TSRecordSet rs = cdf.GetRSReadFromQuery_("select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_SERVIZIO'", vConnectionString, cnLocal);
                iCount = rs.RecordCount;
            }
            catch { }

            //APERTURA TRANSAZIONE
            System.Data.SqlClient.SqlTransaction trans = cnLocal.BeginTransaction(System.Data.IsolationLevel.ReadCommitted);

            try
            {
                // QUERY SENZA TRANSAZIONE
                TSRecordSet rs = cdf.GetRSReadFromQuery_("select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_SERVIZIO'", vConnectionString, cnLocal);
                iCount = rs.RecordCount;
            }
            catch { }
            try
            {
                // QUERY CON TRANSAZIONE
                TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_SERVIZIO'", vConnectionString, cnLocal, trans);
                iCount = rs.RecordCount;
            }
            catch { }
        }
    }
}