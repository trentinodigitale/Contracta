using eProcurementNext.Cache;
using eProcurementNext.CommonModule;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Application
{
    public static class ApplicationCommon
    {
        private static eProcurementNext.Application.IEprocNextApplication _application;
        private static string DefaultFileHashAlgorithm = "SHA256";

        public static eProcurementNext.Application.IEprocNextApplication Application
        {
            get
            {
                if (_application == null)
                {
                    _application = new eProcNextApplication();
                }
                return _application;
            }
            set
            {
                if (_application == null)
                {
                    _application = value;
                }
                else
                {
                    throw new ApplicationException("already initialized");
                }
            }
        }

        private static IConfiguration? _configuration;
        private static IDictionary<string, string>? _dictionary;

        public static IConfiguration Configuration
        {
            get
            {
                return ConfigurationServices._configuration;
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

        private static IEprocNextCache? _cache;

        public static IEprocNextCache Cache
        {
            get
            {
                return _cache;
            }
            set
            {
                if (_cache == null)
                {
                    _cache = value;
                }
                else
                {
                    throw new ApplicationException("already initialized");
                }
            }
        }

        public static Dictionary<string, dynamic>? OwnersList { get; set; }
        public static Dictionary<string, dynamic>? BlackList { get; set; }

        public static string? getAflinkRegistryKey(string keyName)
        {
            return _configuration.GetSection("Registry:" + keyName).Value;
        }

        public static void SetMultiLanguage(IDictionary<string, string> dictionary)
        {
            _dictionary = dictionary;
        }

        public static void ClearMultiLanguage()
        {
            if (_dictionary != null)
                _dictionary.Clear();
        }

        public static long CountMultiLanguageKeys()
        {
            if (_dictionary == null)
            {
                return 0;
            }
            else
            {
                return _dictionary.Count;
            }
        }


        public static string CNV(string str, string strSuffix = "I", int strContext = 0, string noKey = "???")
        {
            var strKey = "";

            if (string.IsNullOrWhiteSpace(str))
            {
                return string.Empty;
            }

            if (ApplicationCommon.Application["TraceMultilinguismo"] == "1")
            {
                TraceMultilinguismo(strKey);
            }

            if (ApplicationCommon.Application.KeyExists("NoMLKey"))
            {
                //In old application veniva presa dalla sessione, ma è più corretto prenderlo da sys/config
                noKey = CStr(ApplicationCommon.Application["NoMLKey"]);
            }

            str = Trim(str);

            //'-- inizializzo
            var defaultValue = $"{noKey}{str}{noKey}";

            if (_dictionary == null)
                return defaultValue;

            strKey = UCase($"{strContext}_{strSuffix}_{str}");

            if (EProcNextCache.RedisDBEnabled)
            {
                var temp = Cache.GetML(strKey);
                if (temp is not null)
                {
                    return temp;
                }

                strKey = UCase($"0_{strSuffix}_{str}");
                temp = Cache.GetML(strKey);
                return temp ?? defaultValue;
            }

            if (_dictionary.ContainsKey(strKey))
            {
                return _dictionary[strKey];
            }

            //Proviamo sul contesto base
            strKey = UCase($"0_{strSuffix}_{str}");
            return _dictionary.ContainsKey(strKey) ? _dictionary[strKey] : defaultValue;
        }

        public static string CNV(string str, eProcurementNext.Session.ISession? session)
        {
            if (string.IsNullOrWhiteSpace(str))
            {
                return string.Empty;
            }

            //'-- recupero lingua
            string? strSuffix = session != null ? session["strSuffLing"] : "";
            if (string.IsNullOrEmpty(strSuffix))
            {
                strSuffix = "I";
            }

            //'-- recupero contesto
            string? strContext = session != null ? CStr(session["IdMP"]) : "";
            if (string.IsNullOrEmpty(strContext))
            {
                strContext = "0";
            }

            return CNV(str, strSuffix, Convert.ToInt32(strContext));
        }

        /// <summary>
        /// inserisce nella tabella TRACE_MULTILINGUISMO le chiavi del vecchio multilinguismo
        /// </summary>
        /// <param name="strKey"></param>
        public static void TraceMultilinguismo(string strKey)
        {
            CommonDB.CommonDbFunctions cdf = new();
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@strKey", strKey);
            cdf.Execute("insert into TRACE_MULTILINGUISMO (idMultilng,Type) values (@strKey,'O')", ApplicationCommon.Application["ConnectionString"], parCollection: sqlParams);
        }

        public static string FileHashAlgorithm
        {
            get
            {
                var fileHashAlgCfg = _configuration.GetSection("Cryptography:FileHashAlgorithm");
                if (fileHashAlgCfg != null)
                {
                    string algName = fileHashAlgCfg.Value;
                    if (algName == FileHash.Algorithm.SHA1 ||
                        algName == FileHash.Algorithm.SHA256 ||
                        algName == FileHash.Algorithm.MD5)
                    {

                        return algName;
                    }
                }
                return DefaultFileHashAlgorithm;
            }
        }
    }
}
