using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace eProcurementNext.CommonModule
{
    public static class ConfigurationServices
    {
        public static IConfiguration? _configuration;

        public static string _contentRootPath;

        public static List<IReadOnlyList<Endpoint>> ListOfEndpoints { get; set; } = new();

        public static bool HasKey(string key)
        {
            var section = _configuration.GetSection(key);
            return section.Exists();
        }
        public static string? GetKey(string key, string? defaultValue = null)
        {
            string? result;

            try
            {
                if (!key.Contains(':', StringComparison.Ordinal))
                {
                    result = _configuration.GetSection(key).Value;
                }
                else
                {
                    result = _configuration.GetRequiredSection(key).Value;
                }
            }
            catch (InvalidOperationException)
            {
                //Se non troviamo la chiave richiesta nel settings
                if (defaultValue != null)
                {
                    result = defaultValue;
                }
                else
                {
                    result = null!;
                }
            }
            result ??= defaultValue;

            return result;
        }

        public static Dictionary<string, string> GetObjectOfKeys(string sectionKey)
        {
            Dictionary<string, string> dictToReturn = new();
            var result = _configuration.GetRequiredSection(sectionKey).GetChildren().AsEnumerable();
            foreach (var item in result)
            {
                dictToReturn.Add(item.Key, item.Value);
            }
            return dictToReturn;
        }

        public static void Reload()
        {
            string? configPath = GetKey("path_appsettings");
            if (string.IsNullOrEmpty(configPath))
            {
                configPath = _contentRootPath;
            }
            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                .Build();
        }
    }

}
