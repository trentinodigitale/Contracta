using Microsoft.Extensions.Configuration;

namespace eProcurementNext.Session
{
    public class SessionCommon
    {
        private static IConfiguration? _configuration;

        public static IConfiguration? Configuration
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


        private const int SessionTimeoutDefault = 20;

        public static int SessionTimeout
        {
            get
            {
                var timeout = SessionTimeoutDefault;

                if (_configuration != null)
                {
                    var timeoutCfg = _configuration.GetSection("Session:Timeout");
                    if (timeoutCfg != null)
                    {
                        try
                        {
                            timeout = Convert.ToInt32(timeoutCfg.Value);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("Impossibile leggere la durata di una sesssione da configurazione", ex);
                        }
                    }
                }

                return timeout;
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
                var cfg = _configuration.GetSection("MongoDb:Collection");
                return cfg != null ? cfg.Value : "";
            }
        }

        /// <summary>
        /// chiave per indicare se cifrare i dati salvati su mongo quando richiesto dalla sezione del metabase
        /// </summary>
        public static bool EncryptData
        {
            get
            {
                if (_configuration == null)
                {
                    return true; //valore di default
                }

                var cfg = _configuration.GetSection("Session:EncryptData");
                var strTmpVal = cfg != null ? cfg.Value : "";

                //Per default i dati in sessione devono essere cifrati ( dove richiesto dal metabase )
                return string.IsNullOrEmpty(strTmpVal) || strTmpVal.ToLower() == "yes";

            }
        }

    }
}
