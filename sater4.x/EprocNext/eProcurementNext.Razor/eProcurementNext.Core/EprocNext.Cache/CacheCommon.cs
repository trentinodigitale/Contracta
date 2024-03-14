using Microsoft.Extensions.Configuration;

namespace eProcurementNext.Cache
{
    public class CacheCommon
    {
        private static IConfiguration _configuration = null;

        public static IConfiguration Configuration
        {
            get
            {
                return _configuration;
            }
            set
            {
                if (_configuration == null)
                {
                    _configuration = value;
                }
                else
                {
                    throw new ApplicationException("configuration already initialized");
                }
            }
        }

        public static string MongoDbConnectionString
        {
            get
            {
                string connectionString = "";

                if (_configuration != null)
                {
                    var cfg = _configuration.GetSection("ConnectionStrings:MongoDbConnection");
                    if (cfg != null)
                    {
                        connectionString = cfg.Value;
                    }
                }

                return connectionString;
            }

        }

        /// <summary>
        /// MongoDB collection name
        /// </summary>
        public static string CollectionName
        {
            get
            {
                if (_configuration == null)
                {
                    return "";
                }
                var cfg = _configuration.GetSection("MongoDb:SystemCollection");
                return cfg != null ? cfg.Value : "";
            }
        }
    }
}
