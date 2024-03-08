using Newtonsoft.Json;

namespace INIPEC.Library
{
    public static class AnacFormUtils
    {
        public static string getJsonWithOptAttrib(object obj)
        {
            var jsonSettings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            };

            // Serializzazione dell'oggetto in formato JSON
            return JsonConvert.SerializeObject(obj, jsonSettings);
        }
    }
}