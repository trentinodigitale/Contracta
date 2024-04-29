using EprocNext.BizDB;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;


namespace EprocNext.CommonDB
{
    public class DebugTrace_
    {
        private static ReaderWriterLockSlim _readWriteLock = new ReaderWriterLockSlim();

        private static bool isActive = default;
        private static int debugFileTimer = CommonModule.DebugTrace.debugFileTimer;
        private static bool entryRead = false;

        private IConfiguration configuration;

        public static DateTime debugFileStartTime = DateTime.Now;
        private DateTime debugFileCheckTime;

        private static string debugFileName = string.Empty;
        private static string debugFilePath = string.Empty;


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
        public void Write(string message, string? nomeApplicazione = null, string? nomeFunzione = null)
        {
            if (isActive)
            {
                if (!Directory.Exists(debugFilePath))
                    Directory.CreateDirectory(debugFilePath);

                string fullPathName = Path.Combine(debugFilePath, debugFileName);
                string debugMessage = Environment.NewLine + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + " : ";
                debugMessage += !string.IsNullOrEmpty(nomeApplicazione) ? nomeApplicazione + " - " : "";
                debugMessage += !string.IsNullOrEmpty(nomeFunzione) ? nomeFunzione + " - " + message : message;

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
                //Tolta la risalita dell'eccezione per non far andare in errore il chiamante in caso di mancata scrittura di una trace
                //else
                //    throw new Exception("DebugTrace.Write() - Scrittura nel file di log fallita. Completato il tempo di attesa per accesso concorrente in write");
                
            }
        }


    }

}
