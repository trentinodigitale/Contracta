using eProcurementNext.BizDB;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Xunit;
//using Microsoft.AspNetCore.Builder.WebApplication;

namespace eProcurementNext.Session.Test
{
    public class Test
    {
        private IConfiguration config;

        private readonly TestServer _testServer;
        private readonly HttpClient _testClient;

        private IConfiguration _configuration;

        public Test()
        {
            var dir = Directory.GetCurrentDirectory();

            // up 5 eProcurementNext.Razor
            var solPath = Path.GetFullPath(@"..\..\..\..\..", dir);
            var path = Path.Combine(solPath, "eProcurementNext.Razor");

            var builder = new ConfigurationBuilder()
                .SetBasePath(path)
                .AddJsonFile("appsettings.json");
            config = builder.Build();

        }

        [Fact]
        public void GlobalAsa_GetSysVarsTest()
        {
            var globalAsa = new GlobalAsa(config);
            var sysVars = globalAsa.GetSysVariables();
            //Assert.True(sysVars.ContainsKey("AVVISO_SESSIONE_LAG"), "collection has not key AVVISO_SESSIONE_LAG");

            //var keyLAG = sysVars.Keys.Where(x => x.ToUpper().Contains("LAG")).First();
            //var value = sysVars[keyLAG];
        }

        [Fact]
        public void Test1()
        {
            var list = new List<KeyValuePair<string, dynamic>>();
            var mulLing = new LibDbMultiLanguage(config);
            //mulLing.InitLanguage("UK", list);

        }


        public void _Test()
        {
            //_testServer = new TestServer(new WebHostBuilder()
            //    .UseStartup<StartupBase>()
            //    );
            //_testClient = _testServer.CreateClient();



            //var args = new string[] { };
            //var builder = WebApplication.CreateBuilder(args);
            //var app = builder.Build();
            //app.Services.GetRequiredService<IConfiguration>();
        }
    }
}