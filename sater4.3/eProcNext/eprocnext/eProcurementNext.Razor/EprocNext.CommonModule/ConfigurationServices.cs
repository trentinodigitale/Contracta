using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Reflection;
using System.Text.Json;

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

        //public static string GetObject(string sectionKey, string PurposeId)
        //{

        //    var result = _configuration.GetSection(sectionKey).Get<List<Models.PCPEservice>>().Where(x => x.purposeId == PurposeId).Single();

        //    return result;
        //}

        public static string GetObjectsInSection(string sectionKey)
        {

            var Section = _configuration.GetSection(sectionKey);

            string result = "";
            // iterate through each child object of section
            foreach (var Object in Section.GetChildren())
            {
                Dictionary<string, string> elements = new Dictionary<string, string>();
                //for (int i = 0; i < Object.GetChildren().Count(); i++)
                //{

                List<IConfigurationSection> el = Object.GetChildren().ToList();

                //if (String.IsNullOrEmpty(purposeId))
                //{
                foreach (IConfigurationSection i in el)
                {
                    elements.Add(i.Key, i.Value);

                }
                result += JsonSerializer.Serialize(elements) + ",";
                //}
                //else
                //{
                //    result = "";

                //List<IConfigurationSection> ic = el.Where(key => key.Key == "purposeId" && key.Value == purposeId).ToList();
                //if (ic != null)
                //{
                //    foreach (IConfigurationSection i in el)
                //    {
                //        elements.Add(i.Key, i.Value);
                //    }
                //    result += JsonSerializer.Serialize(elements);
                //}
                //}


            }

            int resultLenght = result.Length;




            if (result.EndsWith(","))
            {
                result = result.Substring(0, result.Length - 1);
            }


            result = "[" + result + "]";
            return result;

        }
    }

}
