using Microsoft.AspNetCore.Hosting;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureKeyVault;
using Microsoft.Extensions.Hosting;
using System;

namespace EprocNext.WebApi
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                Console.WriteLine($"KeyVault Endpoint: {GetKeyVaultEndpoint()}");
                CreateHostBuilder(args).Build().Run();
                return 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return 1;
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args)
        {
            var host = Host.CreateDefaultBuilder(args);

            if (!string.IsNullOrEmpty(Environment.GetEnvironmentVariable("KEYVAULT_ENDPOINT")))
            {
                host.ConfigureAppConfiguration((context, config) =>
                {
                    var keyVaultEndpoint = GetKeyVaultEndpoint();
                    if (!string.IsNullOrEmpty(keyVaultEndpoint))
                    {
                        var azureServiceTokenProvider = new AzureServiceTokenProvider();
                        var keyVaultClient = new KeyVaultClient(new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback));
                        config.AddAzureKeyVault(keyVaultEndpoint, keyVaultClient, new DefaultKeyVaultSecretManager());
                    }
                });

                Console.WriteLine("KeyVault called!");
            }
            else
            {
                Console.WriteLine("KeyVault not called because KEYVAULT_ENDPOINT environment variable is empty!");
            }

            return host.ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
        }

        private static string GetKeyVaultEndpoint() => $"https://{Environment.GetEnvironmentVariable("KEYVAULT_ENDPOINT")}.vault.azure.net/";
    }
}
