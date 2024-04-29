using Microsoft.Extensions.Configuration;

namespace eProcurementNext.BizDB.Test
{
    public class TestBase
    {
        protected IConfiguration _configuration;

        public TestBase(string appSettingsProjectName = "eProcurementNext.Razor")
        {
            var configPath = GetConfigPath(appSettingsProjectName);
            var exists = Directory.Exists(configPath);

            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                //.AddEnvironmentVariables()
                .Build();
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


        //private void SetConfiguration(string appSettingsProjectName = "eProcurementNext.Razor") {
        //    var configPath = GetConfigPath(appSettingsProjectName);
        //    var exists = Directory.Exists(configPath);

        //    _configuration = new ConfigurationBuilder()
        //        .SetBasePath(configPath)
        //        .AddJsonFile("appsettings.json", false, false)
        //        //.AddEnvironmentVariables()
        //        .Build();
        //} 
    }
}
