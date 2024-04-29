using eProcurementNext.Application;
using Microsoft.Extensions.Configuration;
using Xunit;
using Assert = Xunit.Assert;

namespace eProcurementNext.Session.EmailTest
{
    public class EmailTest
    {
        private readonly IConfiguration _configuration;

        public EmailTest()
        {
            var configPath = Path.GetFullPath(@"..\..\..\..\..\eProcurementNext.Razor", Directory.GetCurrentDirectory());

            var exists = Directory.Exists(configPath);

            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                .AddEnvironmentVariables()
                .Build();

            ApplicationCommon.Application["ConnectionString"] = _configuration.GetConnectionString("DefaultConnection");

            string connString = ApplicationCommon.Application.ConnectionString;
        }

        [Fact]
        public void UnlockTest()
        {
            string unlockKey = eProcurementNext.Email.Basic.GetUnlockKey(this._configuration);
            var mailMan = new Chilkat.MailMan();
            var success = mailMan.UnlockComponent(unlockKey);
            Assert.True(success);
        }

        [Fact]
        public void CanSendMail()
        {

        }
    }
}