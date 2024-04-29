using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.Cache;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor
{
    public class MainGlobalAsa : IGlobalAsa
    {
        IEprocNextApplication _application;
        IConfiguration _configuration;
        ITabManage _tabManage;
        IWebHostEnvironment _environment;

        //IHttpContextAccessor _httpContext;

        IServiceProvider _serviceProvider;

        SessionCleaningService? _sessionCleaningService;

        /// <summary>
        /// Chiave nome sezione per variabili di applicazione in appsettings.json
        /// </summary>
        const string ApplicationContextKey = "ApplicationContext";

        private static IGlobalAsa? _globalAsa = null;

        public static IGlobalAsa? GlobalAsa
        {
            get { return _globalAsa; }
            set { if (_globalAsa != null) _globalAsa = value; }
        }

        public MainGlobalAsa(IEprocNextApplication application, IConfiguration configuration,
            ITabManage tabManage, IWebHostEnvironment environment, /*IHttpContextAccessor httpContext,*/
            IServiceProvider serviceProvider)
        {
            // inizializzo proprietà oggetto application

            ApplicationCommon.Application = application;
            _application = application;

            var check = (_application.GetHashCode() == ApplicationCommon.Application.GetHashCode());
            if (!check)
            {
                throw new ApplicationException("Multiple reference to application object");
            }

            // inizializzo proprietà configuration

            ApplicationCommon.Configuration = configuration;
            SessionCommon.Configuration = configuration;
            CacheCommon.Configuration = configuration;

            // inizializzo proprietà Cache
            var cache = new EProcNextCache(CacheCommon.MongoDbConnectionString, CacheCommon.CollectionName);

            string cacheKey = "cache";

            try
            {
                //cache.Load(cacheKey);
            }
            catch (Exception ex)
            {
                //cache.Init(cacheKey);
                cache.Save();
            }
            ApplicationCommon.Cache = cache;


            _environment = environment;
            _configuration = configuration;
            _tabManage = tabManage;
            _serviceProvider = serviceProvider;

            _globalAsa = this;
        }

        // --inizializzo le varibili application

        public void InitializeApplicationBase()
        {
            var contentRootPath = _environment.ContentRootPath;
            InitializeApplicationBase(contentRootPath);
        }

        public static async void InitializeApplicationBase(string contentRootPath)
        {
            IEprocNextApplication _application = ApplicationCommon.Application;
            IConfiguration _configuration = ApplicationCommon.Configuration;

            // --carico in application tutte le variabili SYS
            var globalAsa = new eProcurementNext.BizDB.GlobalAsa(_configuration);


            Dictionary<string, string> sysVars = globalAsa.GetSysVariables();
            foreach (var item in sysVars)
            {
                _application[item.Key] = item.Value;
            }

            // -- Ricarico i valori dall'application ini per dare una priorità maggiore a questi ultimi
            // -- invece che alla sys. così da avere valori indipendenti in base al server (vedi bilanciamento di carico)
            var applicationContext = _configuration.GetSection(ApplicationContextKey);
            var kvPairs = applicationContext.AsEnumerable().ToList();

            foreach (var item in kvPairs)
            {
                if (item.Key != ApplicationContextKey)
                {
                    _application[item.Key.Replace(ApplicationContextKey + ":", "")] = item.Value;
                }
            }

            //'-- impostazione della HomePage Iniziale
            _application["UrlHomePage"] = "Home/HomeAfs.asp";

            if (_application["HomePage"] == "2")
            {
                _application["UrlHomePage"] = "Home2/Main.asp";
            }

            //'--imposto cartella per la stampa
            string? FolderFilePrint = _configuration.GetSection("Constants:FolderFilePrint").Value;
            _application["FolderFilePrint"] = FolderFilePrint;

            //var serverMappedPath = contentRootPath;
            _application["strVirtualDirectory"] = _configuration.GetSection("ApplicationContext:strVirtualDirectory").Value; //Es /startPath
            _application["NOMEAPPLICAZIONE"] = _configuration.GetSection("ApplicationContext:NOMEAPPLICAZIONE").Value; //Es startPath
            var strVirtualDirectory = _application["strVirtualDirectory"];  // nome della directory virtuale del Web Client

            var serverMappedPath = contentRootPath;
            if (!string.IsNullOrEmpty(serverMappedPath))
            {
                return;
            }

            //'--imposto il path fisico della cartella che contiene i file temporanei delle stampe
            var FolderPrintDownload = Path.Combine(serverMappedPath, strVirtualDirectory, FolderFilePrint);
            _application["FolderPrintDownload"] = FolderPrintDownload;

            //'--imposto il path fisico degli style css
            string? FolderCss = _configuration.GetSection("Constants:FolderCss").Value;
            _application["strPathCss"] = Path.Combine(serverMappedPath, strVirtualDirectory, FolderCss);

            //'--imposto path fisico per le immagini dei prodotti
            string Folderproduct = _application["FolderImageProduct"];
            _application["PathFolderImageProduct"] = Path.Combine(serverMappedPath, strVirtualDirectory, Folderproduct);

        }

        public void RefreshApplicationBase()
        {
            InitializeApplicationBase();
        }

        public static void InitializeMultiLanguage()
        {
            var libDbMultiLanguage = new LibDbMultiLanguage(ApplicationCommon.Configuration);
            var dict = new Dictionary<string, string>();
            libDbMultiLanguage.InitLanguagePlus("", dict);
            ApplicationCommon.SetMultiLanguage(dict);

        }

        public static void RefreshMultiLanguage()
        {
            ApplicationCommon.ClearMultiLanguage();
            MainGlobalAsa.InitializeMultiLanguage();
        }

        public void InitializeApplication()
        {
            InitializeApplicationBase();

            Task.Run(() =>
            {
                _tabManage.ExecSql("EXEC AF_REFRESH_OWNERS_LIST", _application["connectionstring"], null);
            });



            //'-- Caricamento della black list in application
            var objDB = new BlackList();
            var objblacklist = new Dictionary<string, dynamic>();
            //objDB.loadBlackListInMem(_application["ConnectionString"], ref objblacklist);
            _application["blacklist"] = objblacklist;
            var objownerslist = new Dictionary<string, dynamic>();
            objDB.loadOwnersInMem(_application["ConnectionString"], objownerslist);
            ApplicationCommon.OwnersList = objownerslist;
            ApplicationCommon.Application["ownerslist"] = ApplicationCommon.OwnersList;
            ApplicationCommon.BlackList = objblacklist;

            //'-- aggiunto all'application l'informazione contenuta nella chiave di registro IdIpNode
            //per poter discriminare il nodo sul quale ci troviamo e usare l'informazione nel log
            //(l'ip del server veniva meno per le chiamate da localhost )
            var ipServer = ApplicationCommon.getAflinkRegistryKey("IdIpNode");
            _application["IdIpNode"] = ipServer;
        }

        public void MY_Application_OnStart()
        {
            // inizializzo la connection string 
            string? connString = ApplicationCommon.Configuration.GetConnectionString("DefaultConnection");

            if (string.IsNullOrEmpty(connString))
                throw new Exception("Avvio dell'applicazione non possibile, connection string non configurata. Attributo 'DefaultConnection'");

            _application["ConnectionString"] = connString;
            _application["Init_application"] = "1";

            //Leggo il file di configurazione per inizializzare l'applicazione. Essendo un loop stretto ottengo un carico elevato per la CPU, lancio quindi un task
            InitializeApplication();

            //Carico il nuovo multilinguismo
            InitializeMultiLanguage();

            //'-- RIGENERO LA STRINGA DI PERMESSI CLIENTE
#if DEBUG
            Console.WriteLine("TASK di RefreshPermessiCliente() saltato (debug)");
#else
                Task.Run(() => RefreshPermessiCliente()).ContinueWith((task) => Console.WriteLine("TASK di RefreshPermessiCliente() completato"));
#endif
            //RefreshPermessiCliente(); //'-- capire se serve ancora farlo 2 volte. forse no

            //'Invoca una stored per inizializzare parametri legati ai moduli evitando customizzazioni
            StartUpDbApplication();

            // avvio background service per rimozione sessioni scadute
            string? cleanerEnabledCfg = _configuration.GetSection("Session:CleanerEnabled").Value;
            bool cleanerEnabled = !string.IsNullOrEmpty(cleanerEnabledCfg) && cleanerEnabledCfg != "no" ? true : false;

            if (cleanerEnabled)
            {
                string? cleaningIntervalCfg = _configuration.GetSection("Session:CleaningInterval").Value;
                int cleaningInterval = !string.IsNullOrEmpty(cleaningIntervalCfg) ? Convert.ToInt32(cleaningIntervalCfg) : SessionCleaningService.DefaultInterval;
                _sessionCleaningService = new SessionCleaningService(this, _serviceProvider, cleaningInterval);
                _sessionCleaningService.StartAsync(CancellationToken.None);
            }

            // avvio servizio di pulitura della tabella CTL_EVENT_VIEWER a mezzo della stored procedure indicata in appsettings 

            //if(_configuration.GetValue)
            DbCleaningService _dbCleaningService = new DbCleaningService(_serviceProvider, _configuration);

            _dbCleaningService.StartAsync(CancellationToken.None);
        }

        public static void Session_onStart(eProcurementNext.Session.ISession _session)
        {
            //'-- incrementa il numero di utenti che usano l'applicazione	
            ApplicationCommon.Application["ActiveUsers"] = ApplicationCommon.Application["ActiveUsers"] + 1;

            _session["FieldsEditabiliModello"] = 1; //'CAMPI TESTO NEI MODELLI NON EDITABILI
        }

        public static void DeleteFilePrint(eProcurementNext.Session.ISession _session)
        {
            IEprocNextApplication _application = ApplicationCommon.Application;

            string FolderPrintDownload = "FolderPrintDownload";
            string PathFolderAllegati = "PathFolderAllegati";

            if (!IsEmpty(_session["idPfu"]) && !string.IsNullOrEmpty(CStr(_session["idPfu"])))
            {
                if (!string.IsNullOrEmpty(_session[FolderPrintDownload]))
                {
                    foreach (string objFiles in CommonStorage.ListObjects(_application[FolderPrintDownload]))
                    {
                        var posDiesisTilde = objFiles.Contains(CStr(_session["idPfu"]), StringComparison.Ordinal);

                        if (posDiesisTilde)
                        {
                            CommonStorage.DeleteObject(Path.Combine(_application["FolderPrintDownload"], objFiles));
                        }
                    }
                }

                //'-- Cancello tutti i file nella direcory allegati contenenti l'idpfu oppure quelli più vecchi di un giorno con nome diverso "ctl_log_proc_errors.txt" 
                if (!string.IsNullOrEmpty(_session[PathFolderAllegati]))
                {
                    foreach (string objFile in CommonStorage.ListObjects(_application[PathFolderAllegati]))
                    {
                        var posDiesisTilde = objFile.Contains(CStr(_session["idPfu"]), StringComparison.Ordinal);
                        long datafile_OLD = DateDiff("h", File.GetCreationTimeUtc(objFile), DateTime.UtcNow.Subtract(new TimeSpan(1, 0, 0, 0, 0)));

                        if ((posDiesisTilde || datafile_OLD > 0) && objFile != "ctl_log_proc_errors.txt")
                        {
                            CommonStorage.DeleteObject(Path.Combine(_application["PathFolderAllegati"], objFile));
                        }
                    }
                }

                //'-- Cancello tutte le sotto-directory nella direcory allegati contenenti l'idpfu (ed i files in esse contenuti) oppure quelli più vecchi di un giorno 
                if (!string.IsNullOrEmpty(_session[PathFolderAllegati]))
                {
                    foreach (string dir in CommonStorage.ListDirectories(_application[PathFolderAllegati]))
                    {
                        var posDiesisTilde = dir.Contains(CStr(_session["idPfu"]), StringComparison.Ordinal);
                        long datafile_OLD = DateDiff("h", Directory.GetCreationTimeUtc(dir), DateTime.UtcNow.Subtract(new TimeSpan(1, 0, 0, 0, 0)));

                        if (posDiesisTilde || datafile_OLD > 0)
                        {
                            var objFolder = Path.Combine(_application["PathFolderAllegati"], dir);
                            CommonStorage.DeleteDirectory(objFolder);
                        }
                    }
                }
            }
        }


        public static bool ObjUsersLoggedExists(string SessionID)
        {
            return new eProcurementNext.Session.Session().IsActive(SessionID);
        }

        public static void ObjUsersLoggedRemove(string SessionID)
        {
            eProcurementNext.Session.Session ses = new eProcurementNext.Session.Session();
            try
            {
                ses.Load(SessionID);
                ses.Delete();
            }
            catch
            {
            }
        }

        public static async Task Session_onEnd(eProcurementNext.Session.ISession session)
        {
            IEprocNextApplication _application = ApplicationCommon.Application;

            TabManage obj;
            string strSql;
            string SessionID = session.SessionID;

            obj = new TabManage(ApplicationCommon.Configuration);

            string connectionString = ApplicationCommon.Application.ConnectionString;

            //'-- usa la collezione degli utenti loggati per capire se il sessionID è tra qli utenti loggati. capire se è ancora utile         
            if (ObjUsersLoggedExists(CStr(SessionID)))
            {
                string? IdPfu = (!IsEmpty(session["IdPfu"]) && CStr(session["IdPfu"]) != "") ? CStr(session["IdPfu"]) : "";

                if (!string.IsNullOrEmpty(IdPfu) && IsNumeric(IdPfu))
                {

                    await Task.Run(() =>
                    {
                        try
                        {
                            var sqlP = new Dictionary<string, object?>();

                            sqlP.Add("@IdPfu", global::eProcurementNext.CommonModule.Basic.CInt(IdPfu));
                            sqlP.Add("@SessionID", SessionID);

                            //'-- svuoto il SessionID sulla tabella SE coincide con l'attuale ( per evitare che se sto venendo buttato fuori da una sessione con il mio stresso idpfu
                            //'-- cancello dalla tabella il sessionid anche per la sessione buona )
                            strSql = "update profiliutente set pfuSessionID = null, pfuIpServerLogin = NULL where idpfu = @IdPfu and isnull(pfuSessionID,'') = @SessionID";
                            obj.ExecSql(strSql, connectionString, parCollection: sqlP);

                            strSql = "insert into CTL_LOG_PROC ( DOC_NAME , PROC_NAME , idPfu )" +
                                            " values( 'LOGIN' , 'END', @IdPfu )";
                            obj.ExecSql(strSql, connectionString, parCollection: sqlP);


                            //'-- schedula il processo per attuare operazioni legate alla chiusura della sessione di lavoro'
                            strSql = "insert into CTL_Schedule_Process (IdDoc, IdUser, DPR_DOC_ID, DPR_ID )"
                                    + " values( 0 , @IdPfu, 'SESSION' , 'ON_END' )";

                            obj.ExecSql(strSql, connectionString, parCollection: sqlP);

                            //'--TRACCIO NEL LOG END SESSION
                            string ipServer = global::eProcurementNext.CommonModule.Basic.CStr(global::eProcurementNext.Application.ApplicationCommon.getAflinkRegistryKey("IdIpNode"));

                            string CTL_LOG_UTENTE = "CTL_LOG_UTENTE";
                            if (CStr(session["sProfilo"]).Contains("@", StringComparison.Ordinal))
                            {
                                CTL_LOG_UTENTE = global::eProcurementNext.Application.ApplicationCommon.Application["CTL_LOG_UTENTE"];
                            }

                            if (!string.IsNullOrEmpty(CTL_LOG_UTENTE))
                            {

                                strSql = "INSERT INTO " + CTL_LOG_UTENTE + " " +
                                "(ip,idpfu,datalog,paginaDiArrivo,paginaDiPartenza,querystring,form,browserUsato,descrizione, sessionID) VALUES " +
                                "('', @IdPfu ,getDate(),'gloabal.asa',''," +
                                "'Session_onEnd','','','NODO:" + global::eProcurementNext.CommonModule.Basic.CStr(ipServer) + "', @SessionID )";

                                obj.ExecSql(strSql, connectionString, parCollection: sqlP);
                            }
                        }
                        catch (Exception ex)
                        {
                            eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString, "Session_onEnd");
                        }



                    });

                }



            }

            Task.Run(() => DeleteFilePrint(session));

            //'-- DECREMENTO IL NUMERO DI UTENZE
            _application["ActiveUsers"] = _application["ActiveUsers"] - 1;

            //'--rimuovo sessione dalla lista degli utenti loggati
            if (ObjUsersLoggedExists(CStr(SessionID)))
            {
                ObjUsersLoggedRemove(SessionID);
            }

            // rimuove la sessione
            Task.Run(() => session.Delete());

        }

        public static void SessionAbandon(eProcurementNext.Session.ISession session)
        {
            session.Delete();
        }

        public static void SessionAbandon(
            HttpContext httpContext,
            eProcurementNext.Session.ISession session
        )
        {
            try
            {
                Session_onEnd(session);
            }
            catch (Exception ex)
            {
                eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString, "eliminazione sessione scaduta e non eliminata");
            }
            SessionAbandon(session);
            SessionMiddleware.DeleteAllCookies(httpContext);
            SessionMiddleware.DeleteAnonymousCookie(httpContext);
        }

        public static async void RefreshPermessiCliente(bool sync = false)
        {
            // Lancio un blocco di codice asincrono usando Task.Run
            var task = Task.Run(() =>
            {
                var application = ApplicationCommon.Application;

                var moduliGruppi = application["MODULI_GRUPPI"];
                var moduliPermessi = application["MODULI_PERMESSI"];

                var parameters = new Dictionary<string, object?>
                {
                    { "@MODULI_GRUPPI", moduliGruppi },
                    { "@MODULI_PERMESSI", moduliPermessi }
                };

                var strQuery = "DECLARE @permessi_totali varchar(8000)" + Constants.vbCrLf;
                strQuery = strQuery + "set @permessi_totali = ''" + Constants.vbCrLf;
                strQuery = strQuery + "EXEC dbo.GENERA_PERMESSI_CLIENTE  @MODULI_GRUPPI , @MODULI_PERMESSI,  @permessi_totali out" + Constants.vbCrLf;

                var connString = application.ConnectionString;

                var cdf = new CommonDbFunctions();
                cdf.Execute(strQuery, connString, parCollection: parameters);
            });

            //Se richiesto Attendo il completamento del Task. all'avvio dell'applicazione lo lasciamo asincrono mentre per la refresh.asp aspettiamo così da non creare errori nel successivo comando di ricarica permessi utenti
            if (sync)
            {
                task.GetAwaiter().GetResult();
            }
            else
            {
                await task;
            }
        }

        public static async void StartUpDbApplication()
        {
            await Task.Run(() =>
            {
                string strQuery = "EXEC dbo.STARTUPDBAPPLICATION";
                ExecSQL(strQuery);
            });
        }

        public void Application_OnEnd()
        {

            //'--------------------------------------------------------------------------------------------------------------------------------------------------------------
            //'--- SVUOTO I SEMAFORI DI SESSIONE RIMASTI APPESI PER IL SERVER CHE SI STA AVVIANDO ( COSÌ DA NON CREARE PROBLEMI NEI CLIENTI CON BILANCIAMENTO DI CARICO )  --
            //'--------------------------------------------------------------------------------------------------------------------------------------------------------------

            if (CStr(_application["appWithLogin"]) == "1")
            {
                string ipServer = CStr(ApplicationCommon.getAflinkRegistryKey("IdIpNode"));
                var sqlParams = new Dictionary<string, object?>
                {
                    { "@ipServer", ipServer }
                };
                string strSql = "update profiliutente set pfuSessionID = NULL, pfuIpServerLogin = NULL where pfuIpServerLogin = @ipServer and isnull(pfuSessionID,'') <> ''";

                var objTab = new TabManage(_configuration);
                objTab.ExecSql(strSql, CStr(_application["ConnectionString"]), parCollection: sqlParams);

                //'--TRACCIO NEL LOG END APPLICATION

                strSql = @"INSERT INTO CTL_LOG_UTENTE 
                            (ip,idpfu,datalog,paginaDiArrivo,paginaDiPartenza,querystring,form,browserUsato,descrizione, sessionID) VALUES 
                            ('', 0, getDate(), 'gloabal.asa', '', 'Application_OnEnd', '', '', 'NODO:@ipServer, '')";

                objTab.ExecSql(strSql, CStr(_application["ConnectionString"]), parCollection: sqlParams);
            }

            // termino il servizio di rimozione vecchie sessioni
            _sessionCleaningService.StopAsync(CancellationToken.None);
        }

        public static void ExecSQL(string strSql)
        {
            IEprocNextApplication application = ApplicationCommon.Application;
            IConfiguration configuration = ApplicationCommon.Configuration;

            var obj = new TabManage(configuration);
            obj.ExecSql(strSql, application["connectionstring"]);
        }
    }
}
