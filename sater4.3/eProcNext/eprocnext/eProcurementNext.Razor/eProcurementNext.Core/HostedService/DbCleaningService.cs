using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Session;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using MongoDB.Bson;
using MongoDB.Driver;

namespace eProcurementNext.Razor
{
    public class DbCleaningService : IHostedService
    {
        private static Timer _timer = null;
        private IServiceProvider _serviceProvider = null;
        private IConfiguration _configuration;

        /// <summary>
        /// Valore di default, intervallo con cui si richiama questo servizio
        /// </summary>
        private int DefaultInterval = 60;
        private int _interval;

        static CommonDB.CommonDbFunctions cdf = new CommonDB.CommonDbFunctions();

        /// <summary>
        /// Numero Di Record da mantenere in tabella, quelli in eccesso verranno cancellati.
        /// </summary>
        private int DefaultMaxRecordsEventViewer = 2500;

        /// <summary>
        /// Metodo per innescare le pulizie del DB
        /// </summary>
        /// <param name="mainGlobalAsa"></param>
        /// <param name="serviceProvider"></param>
        /// <param name="interval">intervallo di tempo in secondi con cui si ripete la ricerca delle sessioni scadute</param>
        public DbCleaningService(IServiceProvider serviceProvider, IConfiguration _conf)
        {
            _serviceProvider = serviceProvider;
            _configuration = _conf;
            string strDefaultInterval = string.Empty;
            string strDefaultMaxRecordsEventViewer = string.Empty;

            //if (!String.IsNullOrEmpty(_configuration.GetSection("DbCleaningService:DefaultInterval").Value))
            //{
            strDefaultInterval = ConfigurationServices.GetKey("DbCleaningService:DefaultInterval", "60");
            if (!string.IsNullOrEmpty(strDefaultInterval))
            {
                _interval = Convert.ToInt32(strDefaultInterval);
            }
            else
            {
                _interval = DefaultInterval;
            }

            //if (!String.IsNullOrEmpty(_configuration.GetSection("DbCleaningService:DefaultMaxRecordsEventViewer").Value))
            //{
            strDefaultMaxRecordsEventViewer = ConfigurationServices.GetKey("DbCleaningService:DefaultMaxRecordsEventViewer", "2500");
            if (!string.IsNullOrEmpty(strDefaultMaxRecordsEventViewer))
            {
                DefaultMaxRecordsEventViewer = Convert.ToInt32(strDefaultMaxRecordsEventViewer);
            }


        }

        /// <summary>
        /// Avvia il servizio
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public Task StartAsync(CancellationToken cancellationToken)
        {
            _timer = new Timer(
                CleanDbEventViewer,
                state: null,
                dueTime: TimeSpan.Zero, // delay per prima esecuzione
                period: TimeSpan.FromSeconds(_interval));   // ogni minuto 60 sec 

            return Task.CompletedTask;
        }

        /// <summary>
        /// Ferma il servizio
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public Task StopAsync(CancellationToken cancellationToken)
        {
            _timer.Change(Timeout.Infinite, Timeout.Infinite);
            return Task.CompletedTask;
        }

        public void CleanDbEventViewer(object? state)
        {
#if DEBUG
            Console.WriteLine($"Sto eseguendo il task DbCleaningService alle ore {DateTime.Now}");
#endif
            string strSql = string.Empty;

            string dbEventViewerSP = ConfigurationServices.GetKey("DbCleaningService:DbCleaningEventViewerStoredProcedure", "DB_CLEANING_EVENT_VIEWER");
            if(string.IsNullOrEmpty(dbEventViewerSP))
            {
                dbEventViewerSP = "DB_CLEANING_EVENT_VIEWER";
            }

            //if (!string.IsNullOrEmpty(dbEventViewerSP) && checkStoredProcedure(dbEventViewerSP))  // abbiamo appurato che è inutile verificare l'esistenza della stored perché comunque non dobbiamo interrompere l'esecuzione
            // dell'applicazione
            //{

            Dictionary<string, object> param = new Dictionary<string, object>();
            param.Add("@recordAlive", DefaultMaxRecordsEventViewer);

            try
            {
                strSql = $"exec {dbEventViewerSP} @recordAlive";
                string lTimeout = ConfigurationServices.GetKey("SqlCommand:CommandTimeOut", "60");
                int iLTimeout = Convert.ToInt32(lTimeout);
                // la stored procedure esiste e si può procedere con la sua esecuzione 
                cdf.Execute(strSql, ApplicationCommon.Application.ConnectionString, timeout: (iLTimeout * 2), parCollection: param); // si raddoppia il timeout di default per gestire eventuali carichi di lavoro molto pesanti e la generazioni di un qualche timeout

            }
            catch (Exception ex)
            {
#if DEBUG
                Console.WriteLine(ex.ToString());
#endif
            }
            //}

        }

        public bool checkStoredProcedure(string storedName)
        {
            Dictionary<string, object> param = new Dictionary<string, object>();
            param.Add("@storedName", storedName);

            string strSqlSp = "select * from sysobjects where type='P' and name=@storedName";
            bool spExists = false;
            TSRecordSet rs = new TSRecordSet();
            rs = cdf.GetRSReadFromQuery_(strSqlSp, ApplicationCommon.Application.ConnectionString, parCollection: param);
            if (rs != null && rs.RecordCount > 0)
            {
                spExists = true;
            }

            return spExists;
        }
    }
}
