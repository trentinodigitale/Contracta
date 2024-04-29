using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using eProcurementNext.CommonModule.Exceptions;
using eProcurementNext.Session;
using Microsoft.Extensions.Hosting;
using MongoDB.Bson;
using MongoDB.Driver;

namespace eProcurementNext.Razor
{
    public /*internal*/ class SessionCleaningService : IHostedService //, IDisposable
    {
        private Timer _timer = null;

        private MainGlobalAsa _mainGlobalAsa;
        private IServiceProvider _serviceProvider = null;

        /// <summary>
        /// Valore di default intervallo con cui si rimuovono vecchie sessioni
        /// </summary>
        public const int DefaultInterval = 60;

        /// <summary>
        /// Intervallo con cui si rimuovono vecchie sessioni
        /// </summary>
        private int _interval = 60;

        /// <summary>
        /// Classe per eliminare sessioni scadute
        /// </summary>
        /// <param name="mainGlobalAsa"></param>
        /// <param name="serviceProvider"></param>
        /// <param name="interval">intervallo di tempo in secondi con cui si ripete la ricerca delle sessioni scadute</param>
        public SessionCleaningService(MainGlobalAsa mainGlobalAsa, IServiceProvider serviceProvider, int interval = DefaultInterval)
        {
            _mainGlobalAsa = mainGlobalAsa;
            _serviceProvider = serviceProvider;
            _interval = interval; // interval != null ? interval : DefaultInterval;
        }

        /// <summary>
        /// Avvia il servizio
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public Task StartAsync(CancellationToken cancellationToken)
        {
           
            _timer = new Timer(
                DeleteOldSessions,
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

        public static /*private*/ void DeleteOldSessions(object? state)
        {
            var ids = Session.Session.GetOldSessionsIds();

            //Console.WriteLine($"{DateTime.Now.ToString("yyyy-MM-dd HH:mm:sszz")} Clean sessions: processing {ids.Count()} sessions");

            if (ids.Any())
            {
                List<eProcurementNext.Session.ISession>? sessions = new List<eProcurementNext.Session.ISession>();
                foreach (var id in ids)
                {
                    var session = new eProcurementNext.Session.Session();
                    //var session = _serviceProvider.GetService<EprocNext.Session.ISession>();
                    if (session != null)
                    {
                        try
                        {
                            session.Load(id);
                            MainGlobalAsa.Session_onEnd(session);
                        }
                        catch (SessionMongoDbException ex)
                        {
                            Console.WriteLine(ex);
                            DebugTrace dt = new DebugTrace();
                            dt.Write($"Errore nel metodo DeleteOldSessions() : {ex}");
                        }
                        catch (Exception ex)
                        {
                            eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString, "eliminazione sessione scaduta e non eliminata");
                        }
                    }
                }
            }

        }

        public static bool DeleteAllSessions()
        {
            string connectionString = SessionCommon.MongoDbConnectionString;
            string collectionName = SessionCommon.CollectionName;

            MongoClient _client = null;
            IMongoDatabase _database = null;
            IMongoCollection<BsonDocument> _collection = null;

            string databaseName = "";
            if (string.IsNullOrEmpty(connectionString))
            {
                databaseName = "local";
                connectionString = "";
                _client = new MongoClient();
            }
            else
            {
                databaseName = MongoUrl.Create(connectionString).DatabaseName;
                _client = new MongoClient(connectionString);
            }
            _database = _client.GetDatabase(databaseName);


            var filter_list = new BsonDocument("name", collectionName);
            var options = new ListCollectionNamesOptions { Filter = filter_list };

            var collectionExists = _database.ListCollectionNames(options).Any();

            if (!collectionExists)
            {
                return false;
            }
            _database.DropCollection(collectionName);

            bool deleted = !_database.ListCollectionNames(options).Any();

            _database.CreateCollection(collectionName, new CreateCollectionOptions { });

            return deleted;

        }

    }
}
