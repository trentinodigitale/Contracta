using Microsoft.Extensions.Configuration;

namespace eProcurementNext.CommonModule
{
    public class DebugTrace
    {
        private static ReaderWriterLockSlim _readWriteLock = new ReaderWriterLockSlim();

        public static int dbProfilerTimer = -1; // variabile utilizzata da DbProfiler per stabilire se rileggere (se < 0) o meno appsettings
        public static int debugFileTimer = -1; // variabile utilizzata dal debugFile per stabilire se rileggere (se < 0) o meno appsettings


        private static bool isActive = default;
        private static bool entryRead = false;

        private IConfiguration configuration;

        public static DateTime debugFileStartTime = DateTime.Now;
        private DateTime debugFileCheckTime;

        private static string debugFileName = string.Empty;
        private static string debugFilePath = string.Empty;
        private static string debugFilterString = string.Empty;


        public DebugTrace(IConfiguration _configuration = null)
        {
            debugFileCheckTime = DateTime.Now;

            double seconds = (debugFileCheckTime - debugFileStartTime).TotalSeconds;
            int timeToRefresh = debugFileTimer > 0 ? debugFileTimer : 60;

            if (((int)seconds) > timeToRefresh || !entryRead)
            {
                entryRead = false;
                debugFileStartTime = DateTime.Now;
            }

            try
            {
                if (!entryRead)
                {
                    IConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
                    configurationBuilder.AddJsonFile("appsettings.json");
                    IConfiguration configuration = configurationBuilder.Build();

                    bool sectionExists = configuration.GetChildren().Any(item => item.Key == "ApplicationContext");

                    if (sectionExists)
                    {
                        isActive = Convert.ToBoolean(configuration[key: "ApplicationContext:DebugToFileActive"]);
                        int refresh = Convert.ToInt32(configuration[key: "ApplicationContext:DebugFileRefresh"]);
                        debugFileName = configuration[key: "ApplicationContext:DebugFileName"];
                        debugFilePath = configuration[key: "ApplicationContext:DebugFilePath"];
                        debugFileTimer = refresh;
                        debugFilterString = configuration[key: "ApplicationContext:DebugFilterString"];
                        entryRead = true;
                    }
                    else
                    {
                        isActive = false;
                    }
                }
            }
            catch { }
        }

        /// <summary>
        /// Consente di scrivere in un file messaggi di utilità durante il debug
        /// </summary>
        /// <param name="message">Il testo del messaggio da memorizzare</param>
        /// <param name="nomeApplicazione">Paramentro opzionale. Il nome dell'applicazione oggetto di debug</param>
        /// <param name="nomeFunzione">Parametro opzionale. Il nome del metodo o funzione oggetto di debug</param>
        /// <param name="filter">Stringa utile a selezionare gli eventi da tracciare</param>
        public void Write(string message, string? nomeApplicazione = null, string? nomeFunzione = null, string? filter = null)
        {
            if (message == null)
            {
                return;
            }
            if (isActive)
            {
                if (!Directory.Exists(debugFilePath))
                    Directory.CreateDirectory(debugFilePath);

                string fullPathName = Path.Combine(debugFilePath, debugFileName);
                string debugMessage = Environment.NewLine + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + " : ";
                debugMessage += !string.IsNullOrEmpty(nomeApplicazione) ? nomeApplicazione + " - " : "";
                debugMessage += !string.IsNullOrEmpty(nomeFunzione) ? nomeFunzione + " - " + message : message;

                if (filter != null && !filter.Contains(debugFilterString, StringComparison.Ordinal))
                {
                    return;
                }
                else if (filter == null || (filter != null && filter.Contains(debugFilterString, StringComparison.Ordinal)))
                {
                    //Richiedo il lock in scrittura e se vengo bloccato riprovo fino al timeout di 100 millisecondi
                    if (_readWriteLock.TryEnterWriteLock(100))
                    {
                        try
                        {
                            File.AppendAllText(fullPathName, debugMessage);
                        }
                        finally
                        {
                            _readWriteLock.ExitWriteLock();
                        }
                    }
                }



            }
        }


    }

}
