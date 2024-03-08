using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Security.Common;
using eProcurementNext.CtlProcess;
using System.Data.SqlClient;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.Services
{
    public class Service
    {
        private static bool _enableLoggingWithoutDebugging = true;

        const int TimerIntervalDefault = 2000;

        const string ConnectionPool_ConnectionStringsKey = "ConnectionPool_ConnectionStrings";

        private int _timerInterval = TimerIntervalDefault;

        private readonly CommonDbFunctions cdf = new();

        public int TimerInterval
        {
            get { return _timerInterval; }
        }


        private IConfiguration _configuration;

        Dictionary<string, dynamic[,]> colConnectionString = new Dictionary<string, dynamic[,]>();
        private int numConnection = 0;
        private bool mp_InProcess = false;

        private int test_semaforo = 0;

        private bool alertBackoffice = false;
        private string mailBackoffice = "";
        private string mailFrom = "";

        private Dictionary<string, int> collezioneErrori = null;

        private string tempoGarbageCollector = "";

        //'-- pool di SQL Connection per consentire la gestione attiva di N ambienti
        private SqlConnection[]? connectionPool = null;
        static int _simultaneousThreadCount = 0;

        Thread[] threadPool = new Thread[_simultaneousThreadCount];

        const string Source = "CTLSERVICES";
        const string SourceStart = "CtlServices Start";

        const string SimultaneousThreadsKey = "SimultaneousThreads";
        const string NewThreadCheckIntervalKey = "NewThreadCheckInterval";
        const string TimerIntervalKey = "TimerInterval";

        private readonly DebugTrace dt = new();

        public Service(IConfiguration configuration)
        {
            _configuration = configuration;
            _simultaneousThreadCount = Convert.ToInt32(_configuration.GetSection(SimultaneousThreadsKey).Value);
            threadPool = new Thread[_simultaneousThreadCount];
        }

        public void Load()
        {
            var cfgTimerInterval = _configuration.GetSection("Parameters:TimerInterval").Value;
            int.TryParse(cfgTimerInterval, out _timerInterval);
        }

        public void Start(ref bool success)
        {
            int i = 0;
            int j = 0;
            string strConn = "";
            TSRecordSet rs = new TSRecordSet();
            bool trace_event = false;
            string[] v;
            string tmp = String.Empty;
            string strSql = String.Empty;

            SqlConnection objLocalConn = null;

            success = true;

            //'-- Il default non inserisce ogni chiamata nell'event viewer
            trace_event = false;

            test_semaforo = 0;

            var connectionStringsCfg = _configuration.GetSection(ConnectionPool_ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();
            kvPairs.RemoveAt(0); // rimuovo la sezione 

            numConnection = kvPairs.Count;
            connectionPool = new SqlConnection[numConnection];

            for (i = 0; i < numConnection; i++)
            {
                strConn = kvPairs[i].Value;

                if (!string.IsNullOrWhiteSpace(strConn))
                {
                    //'-- Se è presente un parametro di configurazione sulla stringa di connessione
                    if (strConn.Contains("#@#", StringComparison.Ordinal))
                    {
                        v = strConn.Split("#@#");
                        strConn = v[0];

                        //'-- Se la riga sarà nella forma   connectionString#@#TRACE_EVENT
                        if (v[1].ToUpper() == "TRACE_EVENT")
                        {
                            trace_event = true;
                        }
                        else
                        {
                            trace_event = false;
                        }
                    }

                    LogEvent(TsEventLogEntryType.Information, $"Caricata connessione [{strConn}] ", strConn, Source);

                    //'-- Attiviamo la connessione unica del servizio, che passeremo per eseguire tutte le query
                    objLocalConn = SetConnection(strConn);
                    objLocalConn.Open();

                    connectionPool[i] = objLocalConn;

                    //'-- Testo la presenza della tabella CTL_SERVICES
                    strSql = "select top 0 * from CTL_SERVICES with(nolock)";

                    try
                    {
                        rs = rs.Open(strSql, strConn);
                        //rs = cdf.GetRSReadFromQuery_(strSql, "", objLocalConn)
                    }
                    catch (Exception e)
                    {
                        var newEx = new Exception("Manca la tabella", e);
                        TraceErr(newEx, ApplicationCommon.Application.ConnectionString);

                        //'-- stoppo l'esecuzione del servizio fin tanto che non viene riportata la tabella CTL_SERVICES
                        success = false;
                        // se success è false il chiamante
                        // chiama il metodo Stop

                        return;
                    }

                    //'-- PER OGNI CONNESSIONE CARICO LA LISTA DEI DEMON DA ESEGUIRE
                    rs = cdf.GetRSReadFromQuery_("select * from LIB_Services with(nolock) where bDeleted = 0 order by srv_id", strConn, objLocalConn);

                    dynamic[,] m = new dynamic[rs.RecordCount, 8];

                    if (rs is not null)
                    {
                        rs.MoveFirst();

                        for (j = 0; j < rs.RecordCount; j++)
                        {
                            m[j, eProcurementNext.Services.Declares.SRV_id] = CInt(rs["SRV_id"]!);
                            m[j, eProcurementNext.Services.Declares.SRV_DOC_ID] = CStr(rs["SRV_DOC_ID"]);
                            m[j, eProcurementNext.Services.Declares.SRV_DPR_ID] = CStr(rs["SRV_DPR_ID"]);
                            m[j, eProcurementNext.Services.Declares.SRV_SecInterval] = CInt(rs["SRV_SecInterval"]!);
                            m[j, eProcurementNext.Services.Declares.SRV_SQL] = CStr(rs["SRV_SQL"]);
                            if (rs["SRV_LastExec"] != null) 
                            { 
                                m[j, eProcurementNext.Services.Declares.SRV_LastExec] = CDate(rs["SRV_LastExec"]!);          //'DATEDIFF ( datepart , startdate , enddate ]
                            }
                            m[j, eProcurementNext.Services.Declares.SRV_CONN] = strConn;
                            m[j, eProcurementNext.Services.Declares.SRV_EVENT_VIEWER] = trace_event;

                            rs.MoveNext();
                        }
                    }

                    colConnectionString.Add(i.ToString(), m);

                    //'-- Recupero le informazioni relative all'alerting backoffice in caso di errore
                    string strTmp = String.Empty;

                    alertBackoffice = false;

                    strTmp = _configuration.GetSection("MailBackoffice:Active").Value;

                    //'-- Se si è scelto di attivare il meccanismo di alert backoffice sul cliente
                    if (!string.IsNullOrEmpty(strTmp) && strTmp.ToUpper() == "YES")
                    {
                        alertBackoffice = true;
                        //dt.Write("CTLSERVICES riga 195 - alertBackoffice = " + alertBackoffice.ToString());

                        collezioneErrori = new Dictionary<string, int>();

                        mailBackoffice = _configuration.GetSection("MailBackoffice:MailTo").Value;
                        mailFrom = _configuration.GetSection("MailBackoffice:MailFrom").Value;

                        var paramsDic = new Dictionary<string, object?>();
                        paramsDic.Add("@mailFrom", mailFrom);

                        rs = cdf.GetRSReadFromQuery_("select * from ctl_config_mail with(nolock) where alias = @mailFrom", strConn, parCollection: paramsDic);

                        if (rs.RecordCount == 0)
                        {
                            //-- non avendo trovato la configurazione email disattivo l'alerting mail backoffice
                            alertBackoffice = false;
                        }
                    }
                }
            }

            //'-- recupero il tempo, in minuti, dopo i quali cancello i vecchi semafori presenti nella tabelle CTL_SERVICES
            tempoGarbageCollector = "60";

            string strTemp = _configuration.GetSection("Config:TempoPuliziaTabella").Value;

            if (!string.IsNullOrEmpty(strTemp) && int.TryParse(strTemp, out _))
            {
                tempoGarbageCollector = strTemp;
            }

            if (alertBackoffice)
            {
                //dt.Write("CTLSERVICES riga 231 prima di LOG EVENT - Meccanismo di alerting backoffice mail per errori attivo");
                LogEvent(TsEventLogEntryType.Information, "Meccanismo di alerting backoffice mail per errori attivo", "", SourceStart);
                //dt.Write("CTLSERVICES riga 233 dopo LOG EVENT - Meccanismo di alerting backoffice mail per errori attivo");
            }
            else
            {
                //dt.Write("CTLSERVICES riga 237 prima di LOG EVENT - Meccanismo di alerting backoffice mail per errori NON attivo");
                LogEvent(TsEventLogEntryType.Information, "Meccanismo di alerting backoffice mail per errori NON attivo", "", SourceStart);
                //dt.Write("CTLSERVICES riga 239 dopo LOG EVENT - Meccanismo di alerting backoffice mail per errori NON attivo");
            }
        }

        public void StopService()
        {
            try
            {
                for (int i = 0; i < threadPool.Length; i++)
                {
                    if (threadPool[i].IsAlive)
                    {
                        threadPool[i].Abort();
                    }
                }
            }
            catch (Exception ex)
            {

            }

            try
            {
                DateTime d1;

                d1 = DateTime.Now;

                while (mp_InProcess && DateDiff("s", d1, DateTime.Now) < 10)
                {
                }

                StopConnectionPool();
            }
            catch (Exception ex)
            {
            }
        }

        private void ExecuteTestTask(dynamic[,] m, int j, string connectionString,/* SqlConnection objLocalConn,*/ int threadIndex)
        {
            using SqlConnection objLocalConn = new SqlConnection(connectionString);
            objLocalConn.Open();

            var cdf = new CommonDbFunctions();

            Console.WriteLine(threadIndex + " " + DateTime.Now);
            var rand = new Random();
            int secs = rand.Next(1, 6);

            try
            {
                var parCollection = new Dictionary<string, object>();
                parCollection.Add("@SRV_id", m[j, eProcurementNext.Services.Declares.SRV_id]);
                ExecSqlNoTrace("INSERT INTO CTL_SERVICES (srv_id) VALUES (@SRV_id)", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn, parCollection: parCollection);

            }
            catch (Exception ex)
            {
            }

            TSRecordSet rs = new TSRecordSet();
            rs = cdf.GetRSReadFromQuery_("select count(*) as SemaphoresCount from CTL_SERVICES", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn);
            if (rs.RecordCount > 0)
            {
                int semaphoresCount = GetValueFromRS(rs.Fields["SemaphoresCount"]);
                Console.WriteLine($"semaphores count: {semaphoresCount} waiting for secs {secs}");
            }

            Thread.Sleep(secs * Convert.ToInt32(_configuration.GetSection(TimerIntervalKey).Value));

            var parCollection2 = new Dictionary<string, object>();
            parCollection2.Add("@SRV_id", m[j, eProcurementNext.Services.Declares.SRV_id]);
            ExecSql("delete from CTL_SERVICES where srv_id = @SRV_id", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn, parCollection: parCollection2);
        }

        public void ExecuteThread(object? param)
        {
            Thread thread = Thread.CurrentThread;
            ThreadParam? objParam = (ThreadParam?)param;
            int localIndexValue = objParam.j.value; //Copia la variabile per sganciarla dallo scope del chiamante e non incorrere in problemi di concorrenza  

            Console.WriteLine("1: Sto eseguendo il thread con ID: " + thread.ManagedThreadId);
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("2: Thread eseguiti: " + ThreadPool.CompletedWorkItemCount);
            Console.WriteLine("3: Numero thread impegnati: " + ThreadPool.ThreadCount);
            Console.ResetColor();

            ////////try
            ////////{
            ////////    Console.ForegroundColor = (ConsoleColor)objParam.threadIndex + 1;
            ////////}
            ////////catch (Exception)
            ////////{
            ////////    Console.ResetColor();
            ////////}

            Console.WriteLine("4: ExecuteThread - Settaggio nome CurrentThread : \"Demone\" " + localIndexValue);

            //////Thread.CurrentThread.Name = "Demone " + localIndexValue;

            //////Console.WriteLine("ExecuteThread - CurrentThread.name = " + Thread.CurrentThread.Name);

            //////ExecuteThread_sub(objParam.m, localIndexValue, objParam.connectionString, objParam.threadIndex);
            ///

            thread.Name = "Demone" + localIndexValue;
            Console.WriteLine("5: ExecuteThread - CurrentThread.name = " + thread.Name);
            dynamic[,] m = objParam.m;
            var idIndex = m[localIndexValue, eProcurementNext.Services.Declares.SRV_id];
            Console.WriteLine("IdDemone DB: " + idIndex);
            Console.WriteLine("ExecuteThread - CurrentThread.name = " + Thread.CurrentThread.Name);

            ExecuteThread_sub(objParam.m, localIndexValue, objParam.connectionString, objParam.threadIndex);
        }

        public void ExecuteThread_sub(dynamic[,] m, int j, string connectionString, int threadIndex)
        {

            using SqlConnection objLocalConn = new(connectionString);
            objLocalConn.Open();

            //'-- Verifico se il servizio su cui mi trovo è già in esecuzione
            var parCollection = new Dictionary<string, object?>();

            parCollection.Add("@SRV_id", m[j, eProcurementNext.Services.Declares.SRV_id]);
            TSRecordSet rs = cdf.GetRSReadFromQuery_("select * from CTL_SERVICES with(nolock) where srv_id = @SRV_id", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), null, parCollection: parCollection);

            //'-- Se il record non esiste lo creo così da appropriarmi dell'esecuzione del servizio
            if (rs.RecordCount == 0)
            {

                bool success = false;

                try
                {
                    parCollection.Clear();
                    parCollection.Add("@SRV_id", m[j, eProcurementNext.Services.Declares.SRV_id]);
                    ExecSqlNoTrace("INSERT INTO CTL_SERVICES (srv_id) VALUES (@SRV_id)", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn, parCollection: parCollection);
                    success = true;
                }
                catch (Exception)
                {
                    success = false;
                }


                //'-- Se l'inserimento del semaforo è andato a buon fine passo ad eseguire il servizio.
                //'-- Potrebbe andare in errore grazie all'indice inserito sulla colonna srv_id per tutelarci da un inserimento di record-semaforo in concorrenza
                if (success)
                {
                    try
                    {
                        DateTime dtSRV_LastExec = DateTime.MinValue;
                        if (m[j, eProcurementNext.Services.Declares.SRV_LastExec] != null)
                            dtSRV_LastExec = m[j, eProcurementNext.Services.Declares.SRV_LastExec];

                        //'-- verifico se eseguire il demone
                        if (DateDiff("s", dtSRV_LastExec, DateTime.Now) > m[j, eProcurementNext.Services.Declares.SRV_SecInterval])
                        {

                            //'-- aggiorno il demone sul DB per tracciare l'orario dell'ultima esecuzione
                            m[j, eProcurementNext.Services.Declares.SRV_LastExec] = DateTime.Now;

                            try
                            {
                                parCollection.Clear();
                                parCollection.Add("@SRV_id", m[j, eProcurementNext.Services.Declares.SRV_id]);
                                ExecSql("update LIB_Services set SRV_LastExec = getdate() where SRV_id = @SRV_id", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn, parCollection: parCollection);
                                success = true;
                            }
                            catch (Exception)
                            {
                                success = false;
                            }

                            if (success)
                            {
                                Dictionary<string, dynamic> params_ = new Dictionary<string, dynamic>();
                                params_.Add("TRACE", m[j, eProcurementNext.Services.Declares.SRV_EVENT_VIEWER]);

                                Console.ForegroundColor = ConsoleColor.Yellow;
                                Console.WriteLine("nome processo: " + CStr(m[j, eProcurementNext.Services.Declares.SRV_DPR_ID]) + " - doctype: " + CStr(m[j, eProcurementNext.Services.Declares.SRV_DOC_ID]));
                                Console.ForegroundColor = ConsoleColor.White;

                                ExecuteProcess_new(CStr(m[j, eProcurementNext.Services.Declares.SRV_DPR_ID]), CStr(m[j, eProcurementNext.Services.Declares.SRV_DOC_ID]), CStr(m[j, eProcurementNext.Services.Declares.SRV_SQL]), CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), params_, objLocalConn);
                            }
                        }
                    }
                    finally
                    {
                        //'-- Finita l'esecuzione del servizio cancello il mio semaforo dalla tabella
                        parCollection.Clear();
                        parCollection.Add("@SRV_id", m[j, eProcurementNext.Services.Declares.SRV_id]);
                        ExecSql("delete from CTL_SERVICES where srv_id = @SRV_id", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn, parCollection: parCollection);
                    }
                }
            }

            //'-- Per evitare record zombie, nel caso in cui i servizi vengono killati o comunque vanno giu senza completare la loro esecuzione (con la relativa pulizia dei record semaforo)
            //'-- Cancello i semafori più vecchi di X minuti, con X recuperato dal .ini del servizio
            parCollection.Clear();
            parCollection.Add("@tempoGarbageCollector", tempoGarbageCollector);
            ExecSql("delete from CTL_SERVICES where DATEDIFF( minute, data, getdate()) > @tempoGarbageCollector", CStr(m[j, eProcurementNext.Services.Declares.SRV_CONN]), objLocalConn, parCollection: parCollection);
        }

        public void TimerCallback()
        {
            Console.WriteLine("Chiamata alla TimerCallback");

            SqlConnection objLocalConn;

            //'-- Semaforo
            if (!mp_InProcess)
            {
                Console.WriteLine("Elaborazione della TimerCallback. trovato mp_InProcess a true");

                mp_InProcess = true;

                test_semaforo++;

                var findNewThreadSlotInterval = Convert.ToInt32(_configuration.GetSection(NewThreadCheckIntervalKey).Value);

                //'-- PER OGNI CONNESSIONE
                for (int i = 0; i < numConnection; i++)
                {
                    Console.WriteLine($"Itero sulla connessione sql {i}");

                    dynamic[,] m = colConnectionString[i.ToString()];

                    objLocalConn = connectionPool[i];

                    LockObj lockedInt = new(0);

                    while (lockedInt.value < m.GetLength(0))
                    {
                        int threadIndex = -1;
                        while (threadIndex < 0)
                        {
                            for (int indiceThread = 0; indiceThread < _simultaneousThreadCount; indiceThread++)
                            {
                                // posso utilizzare la k-esima posizione se
                                // NON gli è stato assegnato un thread o se
                                // il thread assegnato è terminato
                                if (threadPool[indiceThread] is null || !threadPool[indiceThread].IsAlive)
                                {
                                    Console.WriteLine("Trovato il thread " + indiceThread + " libero");
                                    threadIndex = indiceThread;
                                    break;
                                }
                            }
                            Thread.Sleep(findNewThreadSlotInterval);
                        }

                        int copyIndiceServizio = lockedInt.value;

                        var thd = new Thread(() =>
                        {
                            Thread.CurrentThread.Name = $"Demone {lockedInt.value}";

                            try
                            {
                                ExecuteThread_sub(m, copyIndiceServizio, objLocalConn.ConnectionString, threadIndex);
                            }
                            catch (Exception ex)
                            {
                                TraceErr(ex, ApplicationCommon.Application.ConnectionString, "Thread di esecuzione servizio/demone. Chiamata al metodo ExecuteThread_sub");
                                Console.WriteLine("Thread di esecuzione servizio/demone. Chiamata al metodo ExecuteThread_sub. exception : " + ex.ToString());
                            }
                        });

                        Console.WriteLine($"Creazione oggetto Thread {threadIndex} con indice servizio : {lockedInt.value}");

                        threadPool[threadIndex] = thd;
                        Console.WriteLine($"Invocazione Thread Start per l'indice thread{threadIndex}");
                        thd.Start();

                        lock (lockedInt)
                        {
                            Console.WriteLine($"{Thread.CurrentThread.Name} - incremento la variabile lockedInt ( indice del servizio ) di 1. Attuale valore : {lockedInt.value}");
                            lockedInt.value++;
                        }

                    }

                    //'-- aggiorno l'oggetto connessione nel vettore delle connessioni.
                    //'-- il motivo è dovuto al fatto che l'oggetto connessione singola può essere stato chiuso e riaperto durante l'elaborazione e
                    //'-- senza questo aggiornamento del vettore riprenderemmo sempre un oggetto 'chiuso' o comunque non coerente
                    connectionPool[i] = objLocalConn;

                    // TODO  capire il motivo di queste 2 righe sotto
                    colConnectionString.Remove(i.ToString());
                    colConnectionString.Add(i.ToString(), m);

                }

                test_semaforo = test_semaforo - 1;

                mp_InProcess = false;
                Console.WriteLine("Uscita dalla TimerCallback");
            }
        }

        public void TimerCallback2()
        {
            Console.WriteLine("Inizio TimerCallback");

            SqlConnection objLocalConn = new();

            //'Semaforo ???
            if (!mp_InProcess)
            {
                Console.WriteLine("Elaborazione TimerCallback: mp_InProcess a false");
                mp_InProcess = true;
                Console.WriteLine("Elaborazione TimerCallback: mp_InProcess a true");

                test_semaforo++;

                var findNewThreadSlotInterval = Convert.ToInt32(_configuration.GetSection(NewThreadCheckIntervalKey).Value);

                //' per ogni connessione
                for (int i = 0; i < numConnection; i++)
                {
                    Console.WriteLine("Iterazione sulla connessione sql = " + i);

                    dynamic[,] m = colConnectionString[i.ToString()];
                    objLocalConn = connectionPool[i];

                    ThreadParam[] thAr = new ThreadParam[m.GetLength(0)];

                    LockObj lockedInt; //= new LockObj(0)

                    Console.WriteLine("Creazione ThreadPool");

                    for (int w = 0; w < m.GetLength(0); w++)
                    //while (lockedInt.value < m.GetLength(0))
                    {
                        int pippo = m.GetLength(0);
                        lockedInt = new LockObj(w);
                        ThreadParam thParam = new()
                        {
                            m = m,
                            threadIndex = 0,
                            j = lockedInt,
                            connectionString = objLocalConn.ConnectionString
                        };
                        thAr[w] = thParam;
                        Console.WriteLine("Inserimento thread nel pool con lockedInt = " + lockedInt.value);

                        //lockedInt.value++;

                        //Console.ForegroundColor = ConsoleColor.Yellow;
                        //Console.WriteLine("valore lockedInt = " + lockedInt.value);
                        //Console.ResetColor();
                        //Thread.Sleep(2000);
                    }

                    for (int x = 0; x < thAr.Length; x++)
                    {
                        ThreadPool.QueueUserWorkItem(new WaitCallback(ExecuteThread), thAr[x]);
                    }

                    connectionPool[i] = objLocalConn;
                    colConnectionString.Remove(i.ToString());
                    colConnectionString.Add(i.ToString(), m);
                }

                test_semaforo--;
                mp_InProcess = false;

                Console.WriteLine("Uscita da TimerCallback");
            }

        }


        private async Task<bool> ExecuteProcess_new(string strProcessName, string strDocType, string strSql, string strConnectionString, Dictionary<string, dynamic> params_, SqlConnection connection)
        {
			ELAB_RET_CODE vRetCode;
			bool ret = false;
            dynamic strDocKey;
            string strDescrRetCode = "";
            string myProcessName = "";
            string myDocType = "";
            string? st = "";
            string strTmp = "";
            string errDescription = "";
            bool trace_event = false;
            trace_event = false;

			//-- per ogni documento della query richiama il processo
			TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, connection);
            if (rs is not null && rs.RecordCount > 0)
            {
				if (params_ is not null && params_.ContainsKey("TRACE"))
				{
					trace_event = (bool)params_["TRACE"];
				}

				rs.MoveFirst();
                while (!rs.EOF)
                {
                    myProcessName = strProcessName;
                    myDocType = strDocType;
                    errDescription = "";

                    //' prende dalla query (se avvalorati) il nome del processo ed il tipo del documento

                    //'-- Verifico che ID_DOC e ID_USER siano presenti e avvalorati
                    if (IsNull(rs.Fields["ID_DOC"]) == false || IsNull(rs.Fields["ID_USER"]) == false)
                    {
                        st = "";

                        if (rs.Columns.Contains("ProcessName"))
                        {
                            st = CStr(rs["ProcessName"]);
                            if (!string.IsNullOrEmpty(st))
                            {
                                myProcessName = st;
                            }
                        }

                        st = "";
                        if (rs.Columns.Contains("DocType"))
                        {
                            st = CStr(rs["DocType"]);
                            if (!string.IsNullOrEmpty(st))
                            {
                                myDocType = st;
                            }
                        }

                        DebugTrace dt = new();
                        if (trace_event)
                        {
                            LogEvent(TsEventLogEntryType.Error, $"CTLSERVICES - Start obj.Elaborate( {myProcessName} , {myDocType} , {GetValueFromRS(rs.Fields["ID_DOC"])} , {GetValueFromRS(rs.Fields["ID_USER"])}", strConnectionString, Source);
                        }

                        var obj_el = new ClsElab();

                        vRetCode = ELAB_RET_CODE.RET_CODE_ERROR;
                        try
                        {
                            Console.ForegroundColor = ConsoleColor.Cyan;
                            Console.WriteLine("nome processo: " + myProcessName + " - doctype: " + myDocType);
                            Console.ForegroundColor = ConsoleColor.White;
                            //dt.Write("CTLSERVICES riga 771 prima di Elaborate - nome processo: " + myProcessName + " - doctype: " + myDocType)
                            vRetCode = obj_el.Elaborate(myProcessName, myDocType, GetValueFromRS(rs.Fields["ID_DOC"]), CLng(GetValueFromRS(rs.Fields["ID_USER"])), ref strDescrRetCode, 1, strConnectionString);
                        }
                        catch (Exception e)
                        {
                            //dt.Write("CTLSERVICES riga 776 - " + e.ToString())
                            TraceErr(e, strConnectionString, Source);
                            errDescription = e.ToString();
                        }

                        if (trace_event)
                        {
                            //dt.Write("CTLSERVICES riga 783 prima di LOG EVENT - End obj.Elaborate( " + myProcessName + " , " + myDocType + " , " + GetValueFromRS(rs.Fields["ID_DOC"]) + " , " + GetValueFromRS(rs.Fields["ID_USER"]))
                            LogEvent(TsEventLogEntryType.Error, "CTLSERVICES - End obj.Elaborate( " + myProcessName + " , " + myDocType + " , " + GetValueFromRS(rs.Fields["ID_DOC"]) + " , " + GetValueFromRS(rs.Fields["ID_USER"]), strConnectionString, Source);
                            //dt.Write("CTLSERVICES riga 785 dopo LOG EVENT - End obj.Elaborate( " + myProcessName + " , " + myDocType + " , " + GetValueFromRS(rs.Fields["ID_DOC"]) + " , " + GetValueFromRS(rs.Fields["ID_USER"]))
                        }

                        //'-- Se non è andato tutto bene
                        if (vRetCode != ELAB_RET_CODE.RET_CODE_OK)
                        {
                            //dt.Write($"CTLSERVICES prima di scrivere LogEvent Warning - err:{errDescription}")
                            if (vRetCode == ELAB_RET_CODE.RET_CODE_ERROR)
                            {
                                LogEvent(TsEventLogEntryType.Error, "CTLSERVICES error - ExecuteProcess(" + myProcessName + "," + myDocType + " , " + GetValueFromRS(rs.Fields["ID_DOC"]) + " , " + GetValueFromRS(rs.Fields["ID_USER"]) + ") - [" + strDescrRetCode + "] - err.description:" + errDescription, strConnectionString, Source);
                            }
                            else
                            {
                                LogEvent(TsEventLogEntryType.Warning, "CTLSERVICES warning - ExecuteProcess (" + myProcessName + "," + myDocType + " , " + GetValueFromRS(rs.Fields["ID_DOC"]) + " , " + GetValueFromRS(rs.Fields["ID_USER"]) + ") - [" + strDescrRetCode + "] - err.description:" + errDescription, strConnectionString, Source);
                            }

                            try
                            {
                                Console.ForegroundColor = ConsoleColor.Cyan;
                                Console.WriteLine("alertBackoffice: " + alertBackoffice.ToString());
                                Console.ForegroundColor = ConsoleColor.White;
                            }
                            catch (Exception ex)
                            {
                                Console.ForegroundColor = ConsoleColor.Green;
                                Console.WriteLine(ex.Message);
                                Console.ForegroundColor = ConsoleColor.White;
                            }

                            //dt.Write("CTLSERVICES riga 812 prima di controllare alertBackoffice " + alertBackoffice.ToString())

                            //'-- se è attivo l'alerting
                            if (alertBackoffice)
                            {
                                //'-- 1. Compongo la chiave dell'errore
                                //'-- 2. Verifico se questo errore per lo stesso processo e a parità di parametri è gia andato in errore
                                //'-- 3. Se è andato in errore 1 volta sola non faccio partire l'email(potrebbe essere un errore spot),
                                //'--    Se è la seconda volta faccio partire l'email
                                //'--    Se l'errore si è ripresentato dopo la 2a volta non faccio partire più email di backoffice per quel processo


                                //'strTmp = myProcessName & "," & myDocType & " , " & rs.Fields("ID_DOC") & " , " & rs.Fields("ID_USER") & ") - [" & strDescrRetCode & "] - errDesc: " & errDescription


                                //'-- Non tolgo dalla chiave il solo idDoc, ma anche che la descrizione dell'errore.questo perchè nella descrizione dell'errore ( sia strDescrRetCode che errDescription )
                                //'-- può arrivare l'id del processo.quindi l'errore sarebbe comunque diverso per ogni ID
                                //'-- ( vedi ELAB-NOTIER_LISTA )
                                strTmp = myProcessName + "," + myDocType;

                                if (!collezioneErrori.ContainsKey(strTmp))
                                {
                                    //'-- Errore ancora non presente
                                    collezioneErrori.Add(strTmp, CInt(1));
                                }
                                else
                                {
                                    int totErrori = 0;
                                    totErrori = CInt(collezioneErrori[strTmp]);
                                    //dt.Write("CTLSERVICES riga 840 - totErrori=" + totErrori.ToString())
                                    if (totErrori == 1)
                                    {
                                        //'-- Compongo il corpo email
                                        string strBody = "";
                                        strBody = "Errore CtlService. <br/>";

                                        strBody = strBody + "Email di alert per un processo in errore invocato in background dalla CtlService. ";
                                        strBody = strBody + " <br/>A parità di processo, non verrà inviata più questa email ";
                                        strBody = strBody + " <br/>a meno di un riavvio della CTLService. <br/><br/> ";

                                        strBody = strBody + " <strong> INFORMAZIONI ERRORE </strong> <br/>";

                                        strBody = strBody + "Process name : " + myProcessName + "<br/>";
                                        strBody = strBody + "DocType : " + myDocType + "<br/>";
                                        strBody = strBody + "IdDoc : " + CStr(GetValueFromRS(rs.Fields["ID_DOC"])) + "<br/>";
                                        strBody = strBody + "IdUser : " + CStr(GetValueFromRS(rs.Fields["ID_USER"])) + "<br/>";
                                        strBody = strBody + "RetCode description : " + strDescrRetCode + "<br/>";
                                        strBody = strBody + "err.Description : " + errDescription + "<br/>";

                                        //dt.Write("CTLSERVICES riga 861 prima di chiamare SendMailCentralizzata_New")
                                        Email.Basic.SendMailCentralizzata_New(mailBackoffice, mailFrom, "", "", "", "Errore CtlService", strBody, "I", connection, null,
                                            null, null, null, null, null, null, null, null, null, null);
                                        //dt.Write("CTLSERVICES riga 864 dopo la chiamata a SendMailCentralizzata_New")
                                        collezioneErrori.Remove(strTmp);
                                        collezioneErrori.Add(strTmp, CInt(2));
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        LogEvent(TsEventLogEntryType.Error, "CTLSERVICES - Mancano ID_USER o ID_DOC in un record ritornato dalla query " + strSql, strConnectionString, Source);
                    }

                    rs.MoveNext();
                }
            }

            return ret;
        }

        private void StopConnectionPool()
        {
            if (connectionPool is not null)
            {
                //'-- chiudo le connessioni nel pool
                for (int i = 0; i < connectionPool.Length; i++)
                {
                    if (connectionPool[i] != null)
                    {
                        try
                        {
                            connectionPool[i].Close();
                        }
                        catch (Exception ex)
                        {

                        }

                        connectionPool[i] = null;
                    }
                }
                connectionPool = null;
            }
        }

        public void LogEvent(TsEventLogEntryType eventType, string message, string connectionString, string contesto = "")
        {
            DebugTrace dt = new();
            try
            {
                if (_enableLoggingWithoutDebugging)
                {
                    if (!string.IsNullOrEmpty(connectionString))
                    {
                        //dt.Write("CTLSERVICES Service.LogEvent riga 919 prima di chiamare LogEvent")
                        eProcurementNext.CommonDB.Basic.LogEvent(eventType, message, connectionString, contesto);
                        //dt.Write("CTLSERVICES Service.LogEvent riga 921 LogEvent eseguito")
                    }
                }
            }
            catch (Exception ex)
            {
                //dt.Write("CTLSERVICES Service.LogEvent riga 925 - errore: " + ex.ToString())
            }
        }

        public void TraceErr(Exception error, string connectionString, string contesto = "")
        {
            if (_enableLoggingWithoutDebugging)
            {
                if (!string.IsNullOrEmpty(connectionString))
                {
                    eProcurementNext.CommonDB.Basic.TraceErr(error, connectionString, contesto);
                }
            }
        }


        private void ExecSqlNoTrace(string strSql, string strConnectionString, SqlConnection? parConnection = null, int timeout = -1, Dictionary<string, object?>? parCollection = null)
        {
            cdf.Execute(strSql, strConnectionString, parConnection, timeout, parCollection);
        }

        private void ExecSql(string strSql, string strConnectionString, SqlConnection? parConnection = null, int timeout = -1, Dictionary<string, object?>? parCollection = null)
        {
            cdf.Execute(strSql, strConnectionString, parConnection, timeout, parCollection);
        }

        public SqlConnection SetConnection(string sValue)
        {
            SqlConnection cnLocal = new SqlConnection();

            sValue = sValue.Trim();
            cnLocal.ConnectionString = sValue;

            return cnLocal;
        }

    }

    class ThreadParam
    {
        public dynamic[,]? m;
        public LockObj j;
        public string connectionString = string.Empty;
        public int threadIndex;
    }

}

