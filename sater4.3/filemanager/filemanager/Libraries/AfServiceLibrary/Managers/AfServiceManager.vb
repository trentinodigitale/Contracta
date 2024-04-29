Imports StorageManager

Public Class AfServiceManager
    Public class ActiveWorkerQueue
        Public property id As String
        Public property lockid As String
    End Class

    ''' <summary>
    ''' Restituzione del prossimo JOB in coda in attesa di lavorazione
    ''' Al job viene attribuito un Lockid che lo blocca per 30 secondi
    ''' </summary>
    ''' <returns></returns>
    Private Shared Function RetrievePendingQueueItems() As ActiveWorkerQueue

        Dim ret As ActiveWorkerQueue = Nothing

        Using Dbm As New CTLDB.DatabaseManager(False, Nothing)

            Try
                'INIT TABLE
                'Dim tablename As String = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.WorkerQueueEntryModelType), Dbm, True)
                Dim tablename As String = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.MainWorkerQueueEntryModelType), Dbm, True)

                Dim targetTableName As String = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.WorkerQueueEntryModelType), Dbm, True)

                Dim params As New Hashtable
                params("lastlocktime") = Date.Now.AddSeconds(-30)
                params("lockid") = Guid.NewGuid.ToString.Replace("-", "")
                params("lockdelay") = 30

                '-- prendiamo il primo record lavorabile in ordine di data creazione ASC. una volta assegno un lockid ed un locktime ( per bloccare il job rispetto agli altri servizi in background ) lo copiamo nella tabella di lavoro.
                '-- questo doppio passaggio ci permette di evitare i problemi di transazione e deadlock
                '-- completata la presa in carico del job e la creazione del record "figlio", recuperiamo id e lockid 
                '-- se questa query va in errore, vuol dire che è fallita la insert nella tabella di lavoro a causa di un accesso concorrente a parità di ID ( quindi è corretto riprovare e non dare errore )
                Dim updatequery As String = "
                    BEGIN TRY
	                    
                        SET NOCOUNT ON;

                        declare @id nvarchar(max)
                        SELECT Top 1 @id = id FROM [" & tablename & "] where lockid is null ORDER BY [creationdate] ASC;

                        IF NOT @id IS NULL
                        BEGIN

                            UPDATE  t
                            SET     t.lockid = @lockid,
                                    t.locktime = GETDATE(),
                                    t.lastclientupdate = getdate()
                            FROM    [" & tablename & "] as t
                            where t.id = @id and lockid is null 
                            ;

                            INSERT INTO[" & targetTableName & "] SELECT * FROM [" & tablename & "] with(nolock) where id = @id;
                          
                            -- il record nella tabella MAIN servirà per il meccanismo di keel alive del client e verrà cancellato al completamento del job
                            --DELETE FROM [" & tablename & "] where id = @id;

                            SELECT @id as id, @lockid as lockid 

                        END
                        ELSE
                        BEGIN

                            select top 0 '' as id, '' as lockid 

                        END

                    END TRY
                    BEGIN CATCH
                        select top 0 '' as id, '' as lockid 
                    END CATCH
                                        "
                'Dim affected As Integer = Dbm.ExecuteNonQuery(updatequery, params)
                'If affected = 1 Then

                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(updatequery, params)

                    If dr.Read Then

                        ret = New ActiveWorkerQueue() With {.id = dr("id"), .lockid = dr("lockid")}

                    End If

                End Using

                'End If
                Dbm.commit()    '-- abbiamo tolta la transazione. quindi questa committ non farà nulla

            Catch ex As Exception
                '-- abbiamo tolta la transazione. quindi questa rollback non farà nulla
                Dbm.rollback(True)
            End Try

        End Using

        Return ret

    End Function
    ''' <summary>
    ''' Testa la presenza di un client in ascolto sull'upload
    ''' In modalità debug il parametero "IsClientActive" viene restituito sempre = True
    ''' </summary>
    ''' <param name="id">id del job</param>
    ''' <param name="lockid">lock id</param>
    ''' <param name="IsClientActive">Un parametro che indica se l'utente è ancora in watch sul job tramite la interfaccia di monitoraggio</param>
    ''' <returns></returns>
    Public Shared Function fx_test_isClientActive(id As String, lockid As String, ByRef IsClientActive As Boolean) As Boolean

        'Dim tablename As String = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.WorkerQueueEntryModelType))
        Dim tablename As String = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.MainWorkerQueueEntryModelType))
        Dim plock As New Hashtable

        plock("@id") = id
        plock("@lockid") = lockid

        '-- con la gestione delle 2 tabelle di worker ( main e normale ) non serve più aggiornare il locktime
        'Dim HasValidLock As Boolean = Dbm.ExecuteNonQuery("UPDATE [" & tablename & "] SET locktime = GETDATE() WHERE Id = @id AND [lockid] = @lockid", plock) = 1
        Dim HasValidLock As Boolean = True

        If HasValidLock Then

            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", id, id)

                If Not Debugger.IsAttached Then
                    plock("@timeout") = 30
                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT lastclientupdate FROM [" & tablename & "] with(nolock) WHERE Id = @id AND (NOT esit IS NULL OR DATEDIFF(second,lastclientupdate,GETDATE()) < @timeout)", plock)
                        IsClientActive = dr.Read
                    End Using
                Else
                    IsClientActive = True
                End If

            End Using

        End If

        Return HasValidLock

    End Function


    ''' <summary>
    ''' Classe di Aggiornamento del Lock del job in lavorazione
    ''' La routine di execute aggiorna la scadenza del lock di 30 secondi, ogni 5 secondi al fine di prevenire la presa in carico da parte di un altro processo
    ''' </summary>
    Private Class AsyncKeepAliveJobQueue
        Implements IDisposable
        Private TR As System.Threading.Thread = Nothing
        Private ReadOnly id As String
        Private ReadOnly lockid As String
        Private lastupdate As DateTime? = Nothing
        'Private ReadOnly Dbm As CTLDB.DatabaseManager = Nothing
        Private _IsClientActive As Boolean = True
        Public ReadOnly Property IsClientActive As Boolean

            Get

                Dim debug_level As Integer = 0

                Try
                    Dim tmp_debug_level As Object = AfCommon.AppSettings.item("app.debug_level")

                    If Not IsNothing(debug_level) AndAlso IsNumeric(debug_level) Then
                        debug_level = CInt(tmp_debug_level)
                    End If

                Catch ex As Exception
                    debug_level = 0
                End Try

                '-- se è attiva la modalità app.debug_level con livello maggiore di 1 ritorniamo sempre TRUE
                Return debug_level > 1 OrElse _IsClientActive

            End Get

        End Property
        Public Sub New(id As String, lockid As String)
            Me.id = id
            Me.lockid = lockid
            'Me.Dbm = Dbm
            AfServiceLibrary.AfServiceManager.fx_test_isClientActive(Me.id, Me.lockid, Me._IsClientActive)
            lastupdate = Date.Now
            Me.TR = New Threading.Thread(AddressOf execute)
            Me.TR.Start()
        End Sub
        Private IsAborted As Boolean = False
        Private Sub execute()
            While True
                Try
                    If Not lastupdate.HasValue OrElse Date.Now.Subtract(lastupdate.Value).TotalSeconds > 5 Then
                        AfServiceLibrary.AfServiceManager.fx_test_isClientActive(Me.id, Me.lockid, Me._IsClientActive)
                        lastupdate = Date.Now
                    End If
                Catch ex As Exception
                    If Not IsAborted Then
                        Console.ForegroundColor = ConsoleColor.Red
                        Console.WriteLine("Error on lock update:" & ex.Message)
                        Console.ResetColor()
                    End If
                End Try
            End While
        End Sub

#Region "IDisposable Support"
        Private disposedValue As Boolean ' To detect redundant calls
        ' IDisposable
        Protected Overridable Sub Dispose(disposing As Boolean)
            If Not disposedValue Then
                If disposing Then
                    If Not IsNothing(Me.TR) AndAlso Me.TR.IsAlive Then
                        Me.IsAborted = True
                        Me.TR.Abort()
                        Me.TR = Nothing
                    End If
                End If
            End If
            disposedValue = True
        End Sub
        Public Sub Dispose() Implements IDisposable.Dispose
            Dispose(True)
        End Sub
#End Region
    End Class

    ''' <summary>
    ''' Conclude il job e lo mette in uno stato di Fail
    ''' </summary>
    ''' <param name="jobid"></param>
    ''' <param name="tablename">nome della tabella Db dei jobs</param>
    Private Shared Sub fx_abort_job(jobid As String, tablename As String, sourceDb As CTLDB.DatabaseManager)

        Dim params As New Hashtable
        params("esit") = False
        params("message") = "Process Aborted by Thread for Client Inactivity"
        params("id") = jobid

        Using Dbm As New CTLDB.DatabaseManager(False, sourceDb, "", jobid, jobid)

            Dbm.ExecuteNonQuery("UPDATE [" & tablename & "] SET esit = @esit, message = @message,lastupdate = GETDATE() WHERE id = @id", params)
            Dbm.fx_update_queue_operation("Process Aborted by Thread for Client Inactivity", 100)

            Try

                '-- cancelliamo il record dalla tabella MAIN ( ci serviva solo per mantenere il keep alive del client
                Dim tblName = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.MainWorkerQueueEntryModelType), Dbm, True)
                Dbm.ExecuteNonQuery("DELETE FROM [" & tblName & "] where id = @id", params)

            Catch ex As Exception
            End Try

        End Using

    End Sub

    ''' <summary>
    ''' Esecuzione della lavorazione di uno specifico JOB dalla coda
    ''' 
    ''' </summary>
    ''' <param name="jobid"></param>
    ''' <param name="lockid"></param>
    Public Shared Sub fx_run_worker(jobid As String, lockid As String)
        Dim starttime As DateTime = Date.Now
        Dim tablename As String = ""
        Dim W As AfCommon.WorkerQueueEntryModelType = Nothing

        Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

            While Date.Now.Subtract(starttime).TotalSeconds < 60
                Try
                    '-- effettuiamo la select sulla tabella WorkerQueueEntryModelType accendendo con il suo ID ( jobid )
                    W = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.WorkerQueueEntryModelType)(jobid, Dbm, Nothing,, tablename, True)
                    Exit While
                Catch ex As Exception
                    System.Threading.Thread.Sleep(5000)
                End Try
            End While

        End Using

        If IsNothing(W) OrElse Not W.lockid = lockid Then

            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                Try

                    Dbm.setUserInfo(W.idpfu, W.sessionid)

                    '-- cancelliamo il record dalla tabella MAIN ( ci serviva solo per mantenere il keep alive del client

                    Dim params As New Hashtable
                    params.Add("@id", jobid)

                    Dim tblName = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.MainWorkerQueueEntryModelType), Dbm, True)
                    Dbm.ExecuteNonQuery("DELETE FROM [" & tblName & "] where id = @id", params)

                Catch ex As Exception
                End Try

                Dbm.AppendOperation("Eccezione per job non lavorabile")
                Dbm.traceError(New Exception("Unable to retrive job@lockid  " & jobid & "@" & lockid), False)

            End Using

            Return

        End If


        Using KAW As New AsyncKeepAliveJobQueue(jobid, lockid)
            If Not W.esit.HasValue Then

                Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                    Dbm.setUserInfo(W.idpfu, W.sessionid)

                    'RUN
                    Console.ForegroundColor = ConsoleColor.Yellow
                    Console.WriteLine("JOB STARTED : " & W.action & vbTab & Date.Now.ToString())
                    Console.ResetColor()

                    If KAW.IsClientActive Then
                        Dim X As New AsyncJobExecuter(jobid, W)
                        While X.active
                            System.Threading.Thread.Sleep(100)
                            If Not KAW.IsClientActive Then
                                X.Abort()
                                fx_abort_job(W.id, tablename, Dbm)
                            End If
                        End While
                    Else
                        fx_abort_job(W.id, tablename, Dbm)
                    End If

                End Using

                Console.ForegroundColor = ConsoleColor.Green
                Console.WriteLine("JOB COMPLETE : " & W.action & vbTab & Date.Now.Subtract(starttime).ToString)
                Console.ResetColor()

            End If
        End Using

        'TODO: Mettere la cancellazione del file sotto try catch vuoto o no ? ==> (SI)
        Try

            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                BlobManager.fx_purge_blob_history(Dbm)
            End Using

        Catch ex As Exception

        End Try

    End Sub

    ''' <summary>
    ''' Gestore Asincrono della esecuzione di uno specifico JOB
    ''' </summary>
    Private Class AsyncJobExecuter
        'Private ReadOnly Dbm As CTLDB.DatabaseManager = Nothing
        Private ReadOnly W As AfCommon.WorkerQueueEntryModelType = Nothing
        Private TR As System.Threading.Thread = Nothing
        Private jobid As String

        Public Function active() As Boolean
            Return Not IsNothing(Me.TR) AndAlso Me.TR.IsAlive
        End Function
        Public Sub Abort()
            If Me.active Then
                Me.TR.Abort()
            End If
        End Sub
        Public Sub New(jobid As String, W As AfCommon.WorkerQueueEntryModelType)
            'Me.Dbm = Dbm
            Me.jobid = jobid
            Me.W = W
            Me.TR = New System.Threading.Thread(AddressOf execute)
            Me.TR.Start()
        End Sub
        Private Sub execute()
            Try
                ExecuteJOB(Me.jobid, W)
            Catch ex As Exception
            End Try
        End Sub
    End Class



    Private Shared ReadOnly ActiveProcess As New List(Of AsyncQueueWorker)
    Private Shared exitnow As Boolean = False
    Private Shared TRSERVICE As System.Threading.Thread = Nothing

    ''' <summary>
    ''' Inizializza il job orchestrator per la lavorazione dei jobs in coda
    ''' </summary>
    Public Shared Sub StartJobOrchestrator()
        If IsNothing(TRSERVICE) OrElse Not TRSERVICE.IsAlive Then
            TRSERVICE = New Threading.Thread(AddressOf fx_do_pending_operations)
            TRSERVICE.Start()
        End If
    End Sub

    ''' <summary>
    ''' termina l'esecuzione del job orchestrator dopo aver atteso lo smaltimento della coda
    ''' </summary>
    Public Shared Sub [Stop]()
        AfServiceLibrary.AfServiceManager.exitnow = True
        While ActiveProcess.FindAll(Function(m) m.active = True).Count > 0
            System.Threading.Thread.Sleep(500)
        End While
    End Sub

    ''' <summary>
    ''' Routine di gestione dei job in corso
    ''' </summary>
    Public Shared Sub fx_do_pending_operations()
        While Not exitnow
            Dim tc As String = AfCommon.AppSettings.item("max_threads_count")

            Dim threads As Integer = System.Environment.ProcessorCount

            If Not String.IsNullOrWhiteSpace(tc) AndAlso IsNumeric(tc) Then
                threads = CInt(tc)
            End If

            If Not threads > 0 Then threads = 0

            Dim start As DateTime = Date.Now

            'ATTENDE CHE VENGANO LIBERATI SLOT SE SONO PASSATI MENO DI 5 MINUTI                        
            While Date.Now.Subtract(start).TotalMinutes < 5 AndAlso threads > 0 AndAlso ActiveProcess.FindAll(Function(m) m.active = True).Count >= threads
                System.Threading.Thread.Sleep(1000)
            End While

            Dim AW As ActiveWorkerQueue = RetrievePendingQueueItems()

            While Not IsNothing(AW)

                '-- Verifichiamo se il job non è già presente
                If IsNothing(ActiveProcess.Find(Function(m) m.id = AW.id)) Then
                    '-- Creo il job, lo mando in esecuzione tramite un thread indipendente e lo aggiungo all'elenco di processi attivi
                    ActiveProcess.Add(New AsyncQueueWorker(AW.id, AW.lockid))
                End If

                start = Date.Now

                'SE ENTRO 5 MINUTI NON SI LIBERA UNO SLOT, ESEGUO UGUALMENTE IL WORKER
                While Date.Now.Subtract(start).TotalMinutes < 5 AndAlso threads > 0 AndAlso ActiveProcess.FindAll(Function(m) m.active = True).Count >= threads
                    System.Threading.Thread.Sleep(1000)
                End While

                AW = RetrievePendingQueueItems()

            End While

            '--Forziamo lo stop di tutti i thread non attivi ( nel caso anomalo in cui ci fossero thread non attivi non andati giù )
            For Each actProc In ActiveProcess.FindAll(Function(m) m.active = False)
                actProc.StopThread()
            Next

            '--rimuoviamo dalla collezione tutti i processi non attivi
            ActiveProcess.RemoveAll(Function(m) m.active = False)

            System.Threading.Thread.Sleep(1000)

        End While
    End Sub



    ''' <summary>
    ''' Routine di esecuzione di un JOb
    ''' </summary>
    ''' <param name="W">Istanza del JOB</param>
    Private Shared Sub ExecuteJOB(jobid As String, W As AfCommon.WorkerQueueEntryModelType)

        '--------------------------------------------------
        '--- METODO DI INIZIO PER LA LAVORAZIONE DEL JOB --
        '--------------------------------------------------

        Try
            Dim fx As String = ""


            Select Case W.action
                Case "post-upload-action"

                    Dim starttime As DateTime = Date.Now
                    Dim currentEx As Exception = Nothing

                    W.started = starttime

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                        While Date.Now.Subtract(starttime).TotalSeconds < 30

                            Try
                                '-- aggiorniamo lo started

                                Dim updFields As New Hashtable
                                updFields("started") = W.started

                                CTLDB.DbClassTools.fx_update_instance(Of AfCommon.WorkerQueueEntryModelType)(W, W.id, updFields, Dbm, Nothing)

                                currentEx = Nothing
                                Exit While

                            Catch ex As Exception
                                currentEx = ex
                                System.Threading.Thread.Sleep(5000)
                            End Try

                        End While

                        If Not IsNothing(currentEx) Then
                            Dbm.RunException(currentEx.Message, currentEx)
                        End If

                    End Using

                    Dim VerificaEstensione As String = "0"

                    Dim P As AfCommon.ProxyRequestModelType = Nothing
                    Dim B As BlobEntryModelType = Nothing

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                        Dbm.setUserInfo(W.idpfu, W.sessionid)
                        B = CTLDB.DbClassTools.fx_get_instance(Of BlobEntryModelType)(W.identifier, Dbm, Nothing, withNoLock:=True)
                        BlobManager.fx_save_blob(Dbm, B)
                        P = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(B.pid, Dbm, Nothing)

                        If Not IsNothing(P) Then fx = P.fx

                        Try

                            Dim strsql As String = "select dbo.PARAMETRI('piattaforma','allegati','VerificaEstensione','0',-1) as VerificaEstensione"

                            Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(strsql, Nothing)
                                If dr.Read Then
                                    VerificaEstensione = dr("VerificaEstensione")
                                End If
                            End Using

                        Catch ex As Exception

                        End Try

                        Dbm.AppendOperation("Starting Complete Upload Process")

                        '-- UNIAMO TUTTI I CHUNK ,calciamo l'hash di checksum, verifica di congruità tra estensione e contenuto
                        FileQueueManager.fx_complete_upload_process(jobid, B, P.query, Dbm)
                        
                    End Using


                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                        Dbm.setUserInfo(W.idpfu, W.sessionid)
                        Dbm.AppendOperation("Upload Process Complete")
                        CTLDB.DbClassTools.fx_save_instance(New AfCommon.ProxyRequestModelType, Dbm, False)

                    End Using

                    '-- se è richisto il controllo bloccante dei file che non rispettano contenuto<->estensione
                    If VerificaEstensione.Equals("2") And B._verificaEstensione.Equals("NoMatch") Then
                        Throw New Exception("Il contenuto del file non e' coerente con la sua estensione")
                    End If


                    Dim displaymessage As Boolean = False
                    If Not String.IsNullOrWhiteSpace(P.query("FORMAT")) AndAlso P.query("FORMAT").ToString.ToUpper.Contains("M") Then
                        Dim strFormat As String = P.query("FORMAT")
                        If InStr(1, strFormat, "EXT:") > 0 Then
                            Dim a As String
                            Dim ix As Integer
                            Dim ix2 As Integer
                            ix = InStr(1, strFormat, "EXT:")
                            ix2 = InStr(ix + 1, strFormat, "-")
                            a = Mid(strFormat, ix, ix2 - ix + 1)
                            strFormat = Replace(strFormat, a, "")
                        End If
                        displaymessage = strFormat.ToUpper.Contains("M")
                    End If


                    Select Case fx.ToLower
                        Case "uploadattach","uploadpath"

                            Dim bd As New Hashtable

                            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                                Dbm.setUserInfo(W.idpfu, W.sessionid)

                                Dim Res As AfCommon.ComplexResponseModelType = CTLATTACHS.Attach.UploadAttach(jobid, B, P.query, P.query("idPfu"), Dbm)

                                bd.Add("field", P.query("FIELD"))
                                bd.Add("save_hash", P.query("SAVE_HASH") = "YES")
                                bd.Add("displaymessage", displaymessage)
                                bd.Add("htmlvalue", CTLHTML.Html.FieldAttach.html(jobid, P.query("FIELD"), Res.techvalue, P.query("FORMAT"), False))
                                bd.Add("techvalue", Res.techvalue)
                                If displaymessage AndAlso Res.esit Then
                                    bd.Add("message", "Operazione Completata con Successo")
                                Else
                                    bd.Add("message", "")
                                End If

                                Try

                                    '-- il parametor a 0 vuol dire che non sono richiesti messaggi di controllo in output
                                    If VerificaEstensione.Equals("0") = False Then

                                        Select Case B._verificaEstensione.ToLower '-- per il caso Verified non diamo un output differente
                                            Case "notverified"
                                                bd("message") = "File caricato con successo. Verifica di contenuto non avvenuta"
                                            Case "nomatch"
                                                bd("message") = "File caricato con successo. Il contenuto del file sembra non essere coerente con la sua estensione"
                                            Case "notsupported"
                                                bd("message") = "File caricato con successo. Verifica di contenuto non supportata per l'estensione"
                                        End Select

                                    End If

                                Catch ex As Exception

                                End Try

                            End Using

                            W.returnactions("do-opener-update") = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(bd)

                        Case "uploadattachsigned","uploadpath_signed"

                            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                                B._verificaEstensione = "Verified" '-- essendo un "giro di firma" se il file verrà accettato sarà sicuramente un file buono. altrimenti non avremmo potuto neanche verificarne il contenuto

                                Dbm.setUserInfo(W.idpfu, W.sessionid)

                                Dim Res As AfCommon.ComplexResponseModelType = CTLATTACHS.Attach.UploadAttachSign(jobid, B, P.query, P.query("idPfu"), Dbm)

                                Dim bd As New Hashtable
                                Select Case P.query("OPERATION")
                                    Case "INSERTSIGN"
                                        Dim field As String = "SIGN_ATTACH"
                                        If Not String.IsNullOrWhiteSpace(P.query("AREA")) Then
                                            field = P.query("AREA") & "_" & field
                                        End If
                                        Dim field_visual As String = field
                                        If Not String.IsNullOrWhiteSpace(P.query("AREA_VISUAL")) Then
                                            field_visual = P.query("AREA_VISUAL") & "_" & field
                                        End If
                                        'bd.Add("field",field)
                                        'bd.Add("field_visual",field_visual)
                                        bd.Add("save_hash", P.query("SAVE_HASH") = "YES")

                                        If Not P.query("NO_REFRESH_PARENT") = "YES" Then

                                            bd.Add("refresh_parent_location", Dbm.getDbSYS("strVirtualDirectory") & "/ctl_library/Document/")

                                        End If

                                        If P.query("SAVE_HASH") = "YES" Then
                                            displaymessage = False
                                        Else
                                            displaymessage = True
                                        End If

                                        bd.Add("field", field)
                                        bd.Add("displaymessage", displaymessage)
                                        bd.Add("htmlvalue", CTLHTML.Html.FieldAttach.html(jobid, field, Res.techvalue, P.query("FORMAT"), False))
                                        bd.Add("techvalue", Res.techvalue)

                                        If displaymessage AndAlso Res.esit Then
                                            bd.Add("message", "allegato firmato correttamente salvato")
                                        Else
                                            bd.Add("message", "")
                                        End If

                                        W.returnactions("do-opener-update") = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(bd)

                                    Case Else
                                        bd.Add("save_hash", P.query("SAVE_HASH") = "YES")
                                        bd.Add("field", P.query("FIELD"))
                                        bd.Add("displaymessage", displaymessage)
                                        bd.Add("htmlvalue", CTLHTML.Html.FieldAttach.html(jobid, P.query("FIELD"), Res.techvalue, P.query("FORMAT"), False))
                                        bd.Add("techvalue", Res.techvalue)
                                        If displaymessage AndAlso Res.esit Then
                                            bd.Add("message", "Operazione Completata con Successo")
                                        Else
                                            bd.Add("message", "")
                                        End If
                                        W.returnactions("do-opener-update") = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(bd)
                                End Select

                            End Using


                    End Select
                Case "pdfoperation"

                    Dim P As AfCommon.ProxyRequestModelType = Nothing

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                        P = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(W.identifier, Dbm, Nothing)
                    End Using

                    Select Case P.query("mode").ToString.ToUpper
                        Case "PDF", ""
                            W.settings("response") = PdfLibrary.PdfUtils.generaPdf(jobid, P.query)
                        Case "PDF_HASH"
                            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                                W.settings("response") = PdfLibrary.PdfUtils.GetPdfHash(Dbm, P.query("pdf"), False)
                            End Using

                        Case Else
                            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                                Dbm.RunException("Invalid Mode for :" & P.query("mode"), New Exception("Invalid Mode for :" & P.query("mode")))
                            End Using

                    End Select

                Case "display-attach"

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                        Dim P As AfCommon.ProxyRequestModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(W.identifier, Dbm, Nothing)
                        Dim Res As AfCommon.DisplayAttachResponseModelType = CTLATTACHS.Attach.DisplayAttach(Dbm, P.query, P.query("IdPfu"), "")
                        Dim retfile As String = BlobManager.GetPureFileOnDisk(Dbm, Res.blobid, False)

                        BlobManager.PreseveBlob(Res.blobid)
                        W.settings("json") = AfCommon.Tools.Serialization.JsonSerialize(Of AfCommon.DisplayAttachResponseModelType)(Res)
                        W.settings("fileid") = retfile
                        W.settings("blobid") = Res.blobid
                        W.returnactions("download-jobresult") = W.id

                    End Using


                    'Case "move-file-to-db"
                    '    'Q = DbManager.DbClassTools.fx_get_instance(of AfCommon.TempUploadTokenModelType)(W.identifier,Dbm,new string(){"data"},true)
                    '    'TODO: Implement This
                    'Case "get-binary-hash"
                    '    'TODO: Implement This
                    'Case "get-pdf-hash"
                    '    'TODO: Implement This
                    'Case "envelope-extractor"
                    '    'TODO: Implement This
                    'Case "encrypt-file"
                    '    'TODO: Implement This
                    'Case "get-cypher-key"
                    '    'TODO: Implement This
                    'Case "decrypt-file"
                    '    'TODO: Implement This
                    'Case "check-digital-signature"
                    '    'TODO: Implement This
                    'Case "compare-pdf-hash"
                    '    'TODO: Implement This
                    'Case "get-base64-string"
                    '    'TODO: Implement This
                Case Else

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                        Dbm.setUserInfo(W.idpfu, W.sessionid)
                        Dbm.RunException("Invalid Action on EXECUTE JOB for :" & W.action, New Exception("Invalid Action on EXECUTE JOB for :" & W.action))
                    End Using

            End Select

            W.esit = True
            W.message = String.Empty

        Catch ex As Exception
            W.esit = False
            W.message = ex.Message ' & vbCrLf & ex.StackTrace
            W.stacktrace = ex.StackTrace
            If Debugger.IsAttached Then
                W.message = ex.Message & vbCrLf & ex.StackTrace
            End If
            Select Case ex.GetType.FullName
                Case GetType(AfCommon.UploaderException).FullName
                    W.displayonform = True

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                        Dbm.setUserInfo(W.idpfu, W.sessionid)
                        W.message = Dbm.translate("INFO_UTENTE_ERRORE_PROCESSO") & "<br/>" & Date.Now.ToString("dd/MM/yyyy HH:mm:ss")
                    End Using

            End Select
        End Try

        W.progress = 100
        W.operation = "Job Complete"

        Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

            '-- aggiorno il record della tabella dei worker / della coda di job
            Dim XW As AfCommon.WorkerQueueEntryModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.WorkerQueueEntryModelType)(W.id, Dbm, Nothing)
            XW.esit = W.esit
            XW.message = W.message
            XW.progress = W.progress
            XW.operation = W.operation
            XW.returnactions = W.returnactions
            XW.settings = W.settings
            XW.displayonform = W.displayonform
            XW.stacktrace = W.stacktrace
            CTLDB.DbClassTools.fx_save_instance(XW, Dbm)

        End Using


    End Sub

End Class
