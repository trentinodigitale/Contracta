using eProcurementNext.Application;
using Microsoft.Extensions.Configuration;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.CommonModule.FileHashTest
{
    public class FileHashTest
    {
        private readonly IConfiguration _configuration;

        public FileHashTest()
        {
        }

        const string TestFilePath = "fileHashTestFile";

        [Fact(Skip = "da sistemare")]
        public void ConfigurationTest()
        {
            string algorithm = ApplicationCommon.FileHashAlgorithm;
            var curDir = Directory.GetCurrentDirectory();
            string path = Path.Combine(curDir, TestFilePath);
            var exists = File.Exists(path);
            Assert.True(exists, "File per test non trovato");
            var hash = FileHash.GetHashFile(algorithm, path);
            Assert.NotEmpty(hash);
        }

        [Theory]
        [InlineData(FileHash.Algorithm.SHA1, "07A93D3232545284283FA736B3E04595F325548F")]
        [InlineData(FileHash.Algorithm.SHA256, "751AB02C086075F3D0B801C0E36A153FA507E41A5EEEE0B6B8ADE5DB8F2E7D79")]
        [InlineData(FileHash.Algorithm.MD5, "C74A9A4029AFE6FD7A398356B8493457")]
        public void GetHashTest(string algorithm, string expectedHash)
        {
            var curDir = Directory.GetCurrentDirectory();
            string path = Path.Combine(curDir, TestFilePath);
            var exists = File.Exists(path);
            Assert.True(exists, "File per test non trovato");
            var hash = FileHash.GetHashFile(algorithm, path);
            Assert.Equal(expectedHash, hash);
        }
    }
}