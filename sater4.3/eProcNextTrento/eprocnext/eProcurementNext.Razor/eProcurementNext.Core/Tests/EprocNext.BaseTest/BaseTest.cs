using Microsoft.Extensions.Configuration;

namespace eProcurementNext.BizDB.Test
{
    public class BaseTest
    {
        protected IConfiguration _configuration;
        protected string _connectionString;

        public BaseTest(string appSettingsProjectName = "eProcurementNext.Razor")
        {
            var configPath = GetConfigPath(appSettingsProjectName);
            var exists = Directory.Exists(configPath);

            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                //.AddEnvironmentVariables()
                .Build();

            _connectionString = _configuration.GetSection("ConnectionStrings:DefaultConnection").Value;
        }

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

            return configPath;
        }
    }
}
