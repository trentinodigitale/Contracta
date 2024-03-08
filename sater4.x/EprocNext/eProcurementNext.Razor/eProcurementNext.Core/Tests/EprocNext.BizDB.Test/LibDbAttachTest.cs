using eProcurementNext.Application;
using Microsoft.Extensions.Configuration;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.BizDB.Test
{
    public class LibDbAttachTest
    {
        const string TestFilePath = "testAttachFile.txt";

        private IConfiguration _configuration;

        private string GetConfigPath(string projectName)
        {
            string configPath = "";

            var t = Path.GetFullPath(@"..\..\", Directory.GetCurrentDirectory());

            if (Path.GetDirectoryName(t).EndsWith("x64"))
            {
                configPath = Path.GetFullPath(Path.Combine(@"..\..\..\..\..\..\", projectName), Directory.GetCurrentDirectory());
            }
            else
            {
                configPath = Path.GetFullPath(Path.Combine(@"..\..\..\..\..\", projectName), Directory.GetCurrentDirectory());
            }

            //if (Path.GetDirectoryName(t).EndsWith("x64"))
            //{
            //    configPath = Path.GetFullPath(@"..\..\..\..\..\..\EprocNext.Services", Directory.GetCurrentDirectory());
            //}
            //else
            //{
            //    configPath = Path.GetFullPath(@"..\..\..\..\..\EprocNext.Services", Directory.GetCurrentDirectory());
            //}

            return configPath;
        }

        public LibDbAttachTest()
        {
            var configPath = GetConfigPath("eProcurementNext.Razor");
            var exists = Directory.Exists(configPath);

            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                //.AddEnvironmentVariables()
                .Build();
        }

        [Fact]
        public void InsertCTL_Attach_FromFileTest()
        {
            var curDir = Directory.GetCurrentDirectory();
            string path = Path.Combine(curDir, TestFilePath);
            var exists = File.Exists(path);
            Assert.True(exists, "File per test non trovato");

            string nomeFileCreato = path;
            string nomeFile = Path.GetFileName(path);
            string strConnectionString = _configuration.GetConnectionString("DefaultConnection");

            ApplicationCommon.Configuration = _configuration;

            LibDbAttach lda = new LibDbAttach();
            var keyAttach = lda.InsertCTL_Attach_FromFile(nomeFileCreato, strConnectionString, nomeFile);
        }
    }
}
