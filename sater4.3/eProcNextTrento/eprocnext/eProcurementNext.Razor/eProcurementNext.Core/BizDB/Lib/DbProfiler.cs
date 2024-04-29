using eProcurementNext.Core.Storage;
using Microsoft.Extensions.Configuration;
using System.Diagnostics;

namespace eProcurementNext.BizDB
{
    public class DbProfiler : IDbProfiler
    {
        private IConfiguration configuration;

        private decimal startTime;
        private decimal endTime;
        private decimal freq_ticks;
        private long tempoInMilliSeconds;

        private Stopwatch stopwatch = new Stopwatch();
        private static int readTimer = CommonModule.DebugTrace.dbProfilerTimer;
        public static bool attrivaProf;
        private static int executionTime = 0;

        public static bool entryRead = false;
        public static DateTime dbProfilerStartTime = DateTime.Now;
        private DateTime dbProfilerCheckTime;
        private static int dbProfilerStartSeconds;

        public DbProfiler(IConfiguration? _configuration = null)
        {
            //dbProfilerStartTime = DateTime.Now
            dbProfilerCheckTime = DateTime.Now;
            //Console.WriteLine(dbProfilerStartTime)

            double seconds = (dbProfilerCheckTime - dbProfilerStartTime).TotalSeconds;
            //Console.WriteLine("Secondi: " + (int)seconds)

            int timeToRefresh = readTimer > 0 ? readTimer : 60;

            if (((int)seconds) > timeToRefresh || !entryRead)
            {
                //  Console.WriteLine("Sono entrato nell'aggiornamento di entryRead")
                entryRead = false;
                dbProfilerStartTime = DateTime.Now;
            }

            try
            {
                if (!entryRead)
                {

                    IConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
                    // Duplicate here any configuration sources you use.
                    //configurationBuilder.AddJsonFile("AppSettings.json");
                    if (CommonStorage.FileExists("appsettings.json"))
                    {
                        configurationBuilder.AddJsonFile("appsettings.json");
                    }
                    else if (CommonStorage.FileExists("appsettings_WebAPI.json"))
                    {
                        configurationBuilder.AddJsonFile("appsettings_WebAPI.json");
                    }
                    IConfiguration configuration = configurationBuilder.Build();

                    bool sectionExists = configuration.GetChildren().Any(item => item.Key == "ApplicationContext");

                    if (sectionExists)
                    {
                        var r = configuration[key: "ApplicationContext:ATTIVA_DB_PROFILER"];
                        int refresh = Convert.ToInt32(configuration[key: "ApplicationContext:DB_PROFILER_REFRESH"]);

                        try
                        {
                            executionTime = Convert.ToInt32(configuration[key: "ApplicationContext:DB_PROFILER_EXEC_TIME"]);
                        }
                        catch
                        {
                            executionTime = 0;
                        }

                        attrivaProf = Convert.ToBoolean(r.ToString());
                        readTimer = refresh;
                        entryRead = true;
                    }
                    else
                    {
                        attrivaProf = false;
                    }
                }
            }
            catch
            {
                throw;
            }
        }

        public void endProfiler()
        {
            //QueryPerformanceCounter(out endTime)

            stopwatch.Stop();
            tempoInMilliSeconds = stopwatch.ElapsedMilliseconds;
        }

        public void startProfiler()
        {
            //QueryPerformanceCounter(out startTime)
            stopwatch.Start();
        }

        public void traceDbProfiler(string strSql, string? parConnection = null)
        {
            string cString = parConnection != null ? parConnection.ToString() : configuration.GetConnectionString("DefaultConnection");

            if (attrivaProf && (executionTime == 0 || tempoInMilliSeconds > executionTime * 1000))
            {
                var sqlParams = new Dictionary<string, object?>();

                sqlParams.Add("@tempoInMilliSeconds", tempoInMilliSeconds);
                sqlParams.Add("@strSql", strSql);

                string sSql = $"INSERT INTO CTL_DB_PROFILER ([tempoEsecuzione],[scriptSQL]) VALUES (@tempoInMilliSeconds, @strSql)";

                CommonDB.CommonDbFunctions cdf = new CommonDB.CommonDbFunctions();
                cdf.ExecSqlNoProfiler(sSql, cString, parCollection: sqlParams);
            }
        }
    }
}

