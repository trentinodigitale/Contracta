Imports System.Configuration

''' <summary>
''' Manager principale per la gestione del Database, dei log utente, degli errori, delle traduzioni
''' </summary>
Public Class DatabaseManager
    Implements IDisposable

    ''' <summary>
    ''' Pulisce la cache delle traduzioni
    ''' </summary>
    Public Shared Sub ClearTranslationsCache()
        DatabaseManager.TranslationsCache = New Hashtable
    End Sub

    Private TempOperationLog As New List(Of AfCommon.OperationLogEntryModelType)
    Private Shared TranslationsCache As New Hashtable

    Private Class TCACHE
        Public Property key As String
        Public Property value As String
        Public Property creationdate As DateTime
        Public Sub New(key As String, value As String)
            Me.key = key
            Me.value = value
            Me.creationdate = Date.Now
        End Sub
    End Class

    Private _connectionstring As String = ""
    Private ReadOnly _usetransaction As Boolean = False
    Public ReadOnly jobid As String = ""
    Private ReadOnly logparent As String = ""
    Private Property idpfu As Integer?
    Private Property sessionID As String = ""
    Private _language As String = "I"

    Private updateOperationErrors As Integer = 0

    Public ReadOnly Property language As String
        Get
            Return _language
        End Get
    End Property

    ''' <summary>
    ''' importa le informazioni dell'utente oggetto dell'utilizzo
    ''' </summary>
    ''' <param name="idpfu"></param>
    ''' <param name="sessionID"></param>
    Public Sub setUserInfo(idpfu As Integer?, sessionID As String)

        Me.idpfu = idpfu
        Me.sessionID = sessionID

        If idpfu.HasValue Then

            Dim params As New Hashtable
            params("idpfu") = idpfu

            Using dr As SqlClient.SqlDataReader = Me.ExecuteReader("select isnull( l.lngSuffisso, 'I') as lngSuffisso from profiliutente p with(nolock) inner join lingue l with(nolock) on  pfuIdLng = IdLng where idpfu = @idpfu", params)
                If dr.Read Then
                    _language = dr("lngSuffisso")
                End If
            End Using

        End If


    End Sub

    Public Function getIdpfu() As Integer?
        Return Me.idpfu
    End Function

    ''' <summary>
    ''' Verifica le informazioni di accesso mediante l'acckey
    ''' </summary>
    ''' <param name="acckey"></param>
    ''' <returns></returns>
    Public Function GetAccessInfo(acckey As String) As UserAccessInfo
        Dim RET As UserAccessInfo = Nothing
        Dim query As String = "select * from CTL_ACCESS_BARRIER with(nolock) where guid = @acckey and datediff(SECOND, data,getdate()) <= 30"

        'TODO: improbabile ma rimuovere perchè sezione di test
        Try
            If Web.Configuration.WebConfigurationManager.AppSettings("debug") = "true" AndAlso acckey = "BB4CCC04-D054-4B66-ABB5-0266045CAF9A"
                Return New UserAccessInfo() With {.idPfu = "42727",.sessionID = "172472313"}
            End If
        Catch ex As Exception
        End Try

        Dim params As New Hashtable
        params("acckey") = acckey
        Using dr As SqlClient.SqlDataReader = Me.ExecuteReader("select * from CTL_ACCESS_BARRIER with(nolock) where guid = @acckey and datediff(SECOND, data,getdate()) <= 30", params)
            If dr.Read Then
                RET = New UserAccessInfo With {.idPfu = dr("idpfu"), .sessionID = dr("sessionid")}
            End If
        End Using
        Return RET
    End Function

    ''' <summary>
    ''' registra nel log utente le info relative ad una richiesta di pagina WEB
    ''' </summary>
    ''' <param name="WebRequest"></param>

    Public Sub RegisterPageRequest(WebRequest As System.Web.HttpRequest)
        If Not IsNothing(WebRequest) Then
            Dim command As String = "INSERT INTO [dbo].[CTL_LOG_UTENTE]
           ([ip]
           ,[idpfu]
           ,[datalog]
           ,[paginaDiArrivo]
           ,[paginaDiPartenza]
           ,[querystring]
           ,[form]
           ,[browserUsato]
           ,[descrizione]
           ,[sessionID])
     VALUES
           (@ip,@idpfu,GETDATE(),@targeturl,@sourceurl,@querystring,@form,@browser,@description,@sessionid)"
            Dim params As New Hashtable
            With WebRequest
                If Not String.IsNullOrWhiteSpace(.Headers("HTTP_X_FORWARDED_FOR")) Then
                    params("@ip") = .UserHostAddress & " (REVERSE PROXY) / IP CLIENT:" & .Headers("HTTP_X_FORWARDED_FOR")
                Else
                    params("@ip") = .UserHostAddress
                End If

                params("@idpfu") = If(Me.idpfu, Me.idpfu.Value, DBNull.Value)
                params("@targeturl") = .Url.AbsolutePath
                If Not IsNothing(.UrlReferrer) Then
                    params("@sourceurl") = .UrlReferrer.AbsoluteUri
                Else
                    params("@sourceurl") = DBNull.Value
                End If
                params("@querystring") = Left(.Url.Query.Trim("?"), 4000)
                Dim formvalues As New List(Of String)
                If Not IsNothing(.Form) Then

                    For Each k As String In .Form.Keys
                        formvalues.Add(k & "=" & .Form(k))
                    Next
                End If
                params("@form") = String.Join("&", formvalues.ToArray)
                params("@browser") = .UserAgent
                params("@description") = "SERVER-NAME:" & My.Computer.Name
                params("@sessionid") = If(Not IsNothing(sessionID), sessionID, String.Empty)
            End With
            Me.ExecuteNonQuery(command, params)
        End If
    End Sub

    ''' <summary>
    ''' Traccia l'errore, lo scrive nel registro eventi e crea una email di notifica
    ''' </summary>
    ''' <param name="ex"></param>
    ''' <param name="IgnoreTraceTraceEmail">Indica se EVITARE di inviare l'email</param>
    Public Sub traceError(ex As Exception, IgnoreTraceTraceEmail As Boolean)

        'COSTRUZIONE DELLA CATENA DI ECCEZIONI
        Dim message As String = ex.Message
        Dim stacktrace As String = ex.StackTrace
        Dim source As String = If(String.IsNullOrEmpty(ex.Source), "ATTACH_64", ex.Source)

        Dim exlist As New List(Of Exception)
        exlist.Insert(0, ex)
        While Not IsNothing(ex.InnerException)
            ex = ex.InnerException
            exlist.Insert(0, ex)
        End While
        Dim errors As New List(Of String)
        For i As Integer = 0 To exlist.Count - 1
            errors.Add(Format(i + 1, "000") & vbTab & "SRC:" & exlist(i).Source)
            errors.Add(Format(i + 1, "000") & vbTab & "MSG:" & exlist(i).Message)
            errors.Add(Format(i + 1, "000") & vbTab & "STRACE:" & exlist(i).StackTrace)
            errors.Add("")
        Next

        Dim loglist As New List(Of String)

        For Each LE As AfCommon.OperationLogEntryModelType In Me.TempOperationLog
            loglist.Add(LE.creationdate.ToString("o") & vbTab & LE.text)
        Next


        Try


            Dim tipoevento As Integer = 2
            Dim params As New Hashtable
            params("@tipoevento") = CInt(EventLogEntryType.Error)
            params("@source") = source
            params("@descrizione") = "ERRORI:" & String.Join(vbCrLf, errors.ToArray) & vbCrLf & "LOG_OPERAZIONI:" & String.Join(vbCrLf, loglist.ToArray)
            params("@idpfu") = Me.idpfu
            Me.ExecuteNonQuery("INSERT INTO CTL_EVENT_VIEWER(tipoevento,source,descrizione,idpfu) VALUES(@tipoevento,@source,@descrizione,@idpfu)", params)
            If Not IgnoreTraceTraceEmail Then
                Dim NM As New AfCommon.NotificationsMailQueueModelType
                With NM
                    .id = AfCommon.Tools.getrandomid
                    .mpmevento = "ERRORE_ALLEGATO"
                    'TODO: gestire mpmevento dinamicamente
                    .creationdate = Date.Now
                    .idpfu = Me.idpfu.ToString
                    .message = String.Join(vbCrLf, errors.ToArray)
                    .sent = Nothing
                    .sessionid = Me.sessionID
                    .source = source
                    .tipoevento = tipoevento

                    .ambiente = ""
                    .codazi = ""
                    .contestoapplicativo = ""
                    'DATI SPECIFICI
                    .nomecliente = ""
                    .ambiente = ""
                    .codazi = ""
                    .userip = ""
                    .contestoapplicativo = ""
                    .errornumber = ""
                    .ipserver = My.Computer.Name
                    .errorsource = ""
                    .errorcause = String.Join("<br/>", loglist.ToArray)
                    .paginachiamante = ""
                    .mollicadipane = ""
                    .paginarichiesta = ""
                    .querystring = ""
                    .job_id = Me.jobid
                    '/DATI SPECIFICI
                End With

                CTLDB.DbClassTools.fx_save_instance(NM, Me)
            End If

        Catch ex2 As Exception

        End Try



        Try
            Dim typeTrace As String = "TRACE-ERROR"

            Dim sSource As String
            Dim sLog As String
            Dim sEvent As String
            Dim sMachine As String

            sEvent = "ERRORI:" & String.Join(vbCrLf, errors.ToArray) & vbCrLf & "LOG_OPERAZIONI:" & String.Join(vbCrLf, loglist.ToArray)

            sSource = "AFLink"
            sLog = "Application"
            sMachine = "."

            If Not EventLog.SourceExists(sSource, sMachine) Then
                EventLog.CreateEventSource(sSource, sLog, sMachine)
            End If

            Dim ELog As New EventLog(sLog, sMachine, sSource)

            ELog.WriteEntry(sEvent, EventLogEntryType.Error)

        Catch ex2 As Exception

        End Try

    End Sub



    ''' <summary>
    ''' Restituisce un nome di file temporaneo
    ''' </summary>
    ''' <returns></returns>
    Public Shared Function GetTempFileName() As String
        Try
            Dim tempdir As String = AfCommon.AppSettings.item("tempdir")
            If Not String.IsNullOrWhiteSpace(tempdir) Then
                If Not My.Computer.FileSystem.DirectoryExists(tempdir) Then My.Computer.FileSystem.CreateDirectory(tempdir)
            Else
                Return My.Computer.FileSystem.GetTempFileName
            End If
            Dim ret As String = tempdir.Trim("\") & "\" & AfCommon.Tools.getrandomid
            My.Computer.FileSystem.WriteAllBytes(ret, New Byte() {}, False)
            Return ret

        Catch ex As Exception
            Return My.Computer.FileSystem.GetTempFileName
        End Try
    End Function

    ''' <summary>
    ''' la stringa di connessione, se non fornita nel costruttore viene presa dal file di configurazione
    ''' </summary>
    ''' <returns></returns>
    Private Function connectionstring() As String
        If Not String.IsNullOrWhiteSpace(_connectionstring) Then
            Return _connectionstring
        ElseIf Not String.IsNullOrWhiteSpace(AfCommon.AppSettings.item("connectionstring")) Then
            Me._connectionstring = AfCommon.AppSettings.item("connectionstring")
            Return _connectionstring
        Else
            Throw New Exception("Connectionstring Not Found in Configuration Settings")
        End If
    End Function
    Public Function IsReady()
        Return Not IsNothing(Me.conn) AndAlso Me.conn.State = ConnectionState.Open
    End Function
    Private _conn As SqlClient.SqlConnection = Nothing
    Private connecting As Boolean = False
    Private Function conn() As SqlClient.SqlConnection
        If IsNothing(_conn) Then

            If Not connecting Then
                connecting = True
                _conn = New SqlClient.SqlConnection(Me.connectionstring)
                _conn.Open()
                connecting = False
            End If
        End If
        Return _conn
    End Function
    Private _tr As SqlClient.SqlTransaction = Nothing
    Private Function tr() As SqlClient.SqlTransaction
        If IsNothing(_tr) AndAlso Me._usetransaction Then
            Me._tr = Me.conn.BeginTransaction
        End If
        Return _tr
    End Function

    Public Sub New(usetransaction As Boolean, sourceDbm As DatabaseManager, Optional connectionstring As String = "", Optional jobid As String = "", Optional logparent As String = "")

        Me._usetransaction = usetransaction
        Me._connectionstring = connectionstring
        Me.jobid = jobid
        Me.logparent = logparent

        Dim starttime As DateTime = Date.Now
        While Not Me.IsReady AndAlso Date.Now.Subtract(starttime).TotalSeconds < 30
            System.Threading.Thread.Sleep(100)
        End While

        If Not IsNothing(sourceDbm) Then

            Me.idpfu = sourceDbm.idpfu
            Me.sessionID = sourceDbm.sessionID
            Me._language = sourceDbm._language
            Me.TempOperationLog = sourceDbm.TempOperationLog

        End If

    End Sub

    ''' <summary>
    ''' Aggiorna le informazioni di Un JOB in lavorazione
    ''' </summary>
    ''' <param name="operation">Operazione corrente</param>
    ''' <param name="progress">Percentual di avanzamento</param>
    ''' <param name="displayvariables">Variabili prodotte la processo come nome/valore</param>
    Public Sub fx_update_queue_operation(operation As String, progress As Double, Optional displayvariables As Hashtable = Nothing, Optional appendOperation As Boolean = True)
        If Not String.IsNullOrWhiteSpace(Me.jobid) Then

            If Not String.IsNullOrWhiteSpace(operation) AndAlso appendOperation Then
                Me.AppendOperation(operation)
            End If
            If IsNothing(displayvariables) OrElse displayvariables.Keys.Count = 0 Then
                Dim params As New Hashtable
                params("@id") = Me.jobid
                params("@operation") = operation
                params("@progress") = progress
                Dim main_tablename As String = DbClassTools.GetTableName(GetType(AfCommon.WorkerQueueEntryModelType))

                Try
                    '-- Se il tentativo di aggiornare il job sul progresso avvenuto va in errore per meno di 3 volte, proseguiamo senza throw ex. altrimenti lanciamo errore
                    Me.ExecuteNonQuery("UPDATE [" & main_tablename & "] SET [operation] = @operation, [progress] = @progress WHERE id = @id", params)

                    '-- resettiamo i tentativi
                    updateOperationErrors = 0

                Catch ex As Exception

                    If updateOperationErrors > 3 Then
                        Me.AppendOperation("Superati i tentativi di update operation. fx_update_queue_operation")
                        Throw ex
                    End If

                    updateOperationErrors += 1

                End Try


            Else
                Dim W As AfCommon.WorkerQueueEntryModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.WorkerQueueEntryModelType)(Me.jobid, Me, Nothing)
                For Each k As String In displayvariables.Keys
                    W.displayvariables(k) = displayvariables(k)
                Next
                W.operation = operation
                W.progress = progress
                CTLDB.DbClassTools.fx_save_instance(W, Me)
            End If
        End If
    End Sub

    ''' <summary>
    ''' Esecuzione di una query SQL
    ''' </summary>
    ''' <param name="command"></param>
    ''' <param name="params"></param>
    ''' <returns></returns>
    Public Function ExecuteNonQuery(command As String, params As Hashtable) As Integer
        Using cmd As New SqlClient.SqlCommand(command, Me.conn, Me.tr)
            cmd.CommandTimeout = conn.ConnectionTimeout
            If Not IsNothing(params) Then

                For Each k As String In params.Keys
                    Dim value As Object = params(k)
                    If Not k.StartsWith("@") Then k = "@" & k
                    If IsNothing(value) Then value = DBNull.Value
                    cmd.Parameters.AddWithValue(k, value)
                Next
            End If
            Dim affected As Integer = cmd.ExecuteNonQuery
            Return affected
        End Using
    End Function
    ''' <summary>
    ''' Esecuzione di un datareader SQL
    ''' </summary>
    ''' <param name="command"></param>
    ''' <param name="params"></param>
    ''' <returns></returns>
    Public Function ExecuteReader(command As String, params As Hashtable) As SqlClient.SqlDataReader
        Dim cmd As New SqlClient.SqlCommand(command, Me.conn, Me.tr)
        cmd.CommandTimeout = conn.ConnectionTimeout
        If Not IsNothing(params) Then

            For Each k As String In params.Keys
                Dim value As Object = params(k)
                If Not k.StartsWith("@") Then k = "@" & k
                If IsNothing(value) Then value = DBNull.Value
                cmd.Parameters.AddWithValue(k, value)
            Next
        End If
        Return cmd.ExecuteReader(CommandBehavior.KeyInfo)
    End Function
    ''' <summary>
    ''' Esecuzione di una get Datatable SQL (mediante il DataAdapter)
    ''' </summary>
    ''' <param name="command"></param>
    ''' <param name="params"></param>
    ''' <returns></returns>
    Public Function fx_get_datatable(command As String, params As Hashtable) As DataTable
        Using cmd As New SqlClient.SqlCommand(command, Me.conn, Me.tr)
            cmd.CommandTimeout = conn.ConnectionTimeout
            If Not IsNothing(params) Then

                For Each k As String In params.Keys
                    Dim value As Object = params(k)
                    If Not k.StartsWith("@") Then k = "@" & k
                    If IsNothing(value) Then value = DBNull.Value
                    cmd.Parameters.AddWithValue(k, value)
                Next
            End If
            Dim DT As New DataTable
            Using da As New SqlClient.SqlDataAdapter(cmd)
                da.Fill(DT)
            End Using
            Return DT
        End Using
    End Function

    ''' <summary>
    ''' Scrittura nella tabella CTL_TRACE
    ''' </summary>
    ''' <param name="descrizione"></param>
    ''' <param name="contesto"></param>
    Public Sub TraceDB(descrizione As String, contesto As String)

        If UCase(AfCommon.AppSettings.item("ATTIVA_TRACE")) = "YES" Then

            Try

                Dim command As String = "INSERT INTO CTL_TRACE (contesto,sessionIdASP,idpfu,descrizione)
	                                    VALUES ( @contesto,@sessionid, @idpfu, @descrizione )"

                Dim params As New Hashtable

                params("@contesto") = contesto
                params("@sessionid") = If(Not IsNothing(sessionID), sessionID, String.Empty)
                params("@idpfu") = If(Me.idpfu, Me.idpfu.Value, DBNull.Value)
                params("@descrizione") = descrizione

                Me.ExecuteNonQuery(command, params)

            Catch ex As Exception
            End Try

        End If
    End Sub

    ''' <summary>
    ''' traduzione di un testo basata sull'utente corrente definito nell'istanza
    ''' </summary>
    ''' <param name="key"></param>
    ''' <returns></returns>
    Public Function translate(key As String) As String
        Dim ret As String = "???" & key & "???"

        Dim trycount = 0
        While trycount < 3
            Try
                If TranslationsCache.ContainsKey(Me.language) AndAlso CType(TranslationsCache(Me.language), Hashtable).ContainsKey(key) Then
                    Dim TC As TCACHE = CType(TranslationsCache(Me.language), Hashtable)(key)
                    If Not IsNothing(TC) AndAlso Date.Now.Subtract(TC.creationdate).TotalMinutes < AfCommon.Statics.translationsTTL_seconds Then
                        Return TC.value
                    End If
                End If
                Dim params As New Hashtable
                params("key") = key
                params("lng") = Me.language
                Dim strSQL As String = "select dbo.CNV_ESTESA(@key,@lng) as ML_Description" '"select ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY = @key and ML_LNG = @lng"

                Using dr As SqlClient.SqlDataReader = ExecuteReader(strSQL, params)
                    If dr.Read Then
                        ret = dr("ML_Description")
                        If Not TranslationsCache.ContainsKey(Me.language) Then TranslationsCache(Me.language) = New Hashtable
                        CType(TranslationsCache(Me.language), Hashtable)(key) = New TCACHE(key, ret)
                    End If
                End Using
                Exit While
            Catch ex As Exception
                trycount += 1
            End Try
        End While
        Return ret
    End Function

    Public Function getDbSYS(key As String) As String

        Dim ret As String = ""

        Dim params As New Hashtable
        params("key") = key

        Dim strSQL As String = "select DZT_ValueDef from LIB_Dictionary with(nolock) where dzt_name = 'SYS_' + @key"

        Using dr As SqlClient.SqlDataReader = ExecuteReader(strSQL, params)

            If dr.Read Then
                ret = dr("DZT_ValueDef")
            End If

        End Using

        Return ret

    End Function

    ''' <summary>
    ''' traduzione di un testo in base alla lingua fornita in ingresso alla funzione del metodo Shared
    ''' </summary>
    ''' <param name="language"></param>
    ''' <param name="key"></param>
    ''' <returns></returns>
    Public shared Function gettranslation(language As String,key As String) As String
        Using Dbm As New DatabaseManager(False, Nothing)
            If Not String.IsNullOrWhiteSpace(language) Then
                Dbm._language = language
            End If
            Return Dbm.translate(key)
        End Using
    End Function



    ''' <summary>
    ''' Creazione di una tralog per tracciare info commentate
    ''' </summary>
    ''' <param name="text"></param>
    Public Sub AppendOperation(text As String)

        Dim LE As New AfCommon.OperationLogEntryModelType() With {.id = AfCommon.Tools.getrandomid, .creationdate = Date.Now, .logparent = Me.logparent, .text = text, .idpfu = Me.idpfu, .sessionid = Me.sessionID}
        '--Tab AfCommon_OperationLogEntryModelType
        If UCase(AfCommon.AppSettings.item("ATTIVA_TRACE")) = "YES" Then
            CTLDB.DbClassTools.fx_save_instance(LE, Me, True)
        End If

        Me.TempOperationLog.Add(LE)
        Console.WriteLine(LE.creationdate.ToString() & vbTab & "OP : " & vbTab & LE.text)

    End Sub

    ''' <summary>
    ''' Registra un log di errore nel log utente
    ''' </summary>
    ''' <param name="message"></param>
    Public Sub RegisterLogError(message As String, Optional paginaDiArrivo As String = "", Optional description As String = "", Optional browserUsato As String = "")
        'REGISTRA L'ERRORE NEL LOG UTENTE
        'If Me.idpfu.HasValue Then
        Dim command As String = "INSERT INTO [dbo].[CTL_LOG_UTENTE]
            ([ip]
            ,[idpfu]
            ,[datalog]
            ,[paginaDiArrivo]
            ,[paginaDiPartenza]
            ,[querystring]
            ,[form]
            ,[browserUsato]
            ,[descrizione]
            ,[sessionID])
        VALUES
            (@ip,@idpfu,GETDATE(),@targeturl,@sourceurl,@querystring,@form,@browser,@description,@sessionid)"

        Dim params As New Hashtable
        params("@ip") = ""

        params("@idpfu") = If(Me.idpfu.HasValue, Me.idpfu.Value, DBNull.Value)
        params("@targeturl") = paginaDiArrivo
        params("@sourceurl") = DBNull.Value

        params("@querystring") = "TRACE-ERROR"

        params("@browser") = browserUsato

        params("@form") = message

        params("@description") = description

        params("@sessionid") = If(Not String.IsNullOrWhiteSpace(sessionID), sessionID, String.Empty)
        Me.ExecuteNonQuery(command, params)
        'End If
    End Sub
    ''' <summary>
    ''' ''' Registra un log di info nel log utente
    ''' </summary>
    ''' <param name="message"></param>
    Public Sub RegisterLogInfo(message As String, Optional paginaDiArrivo As String = "", Optional description As String = "", Optional browserUsato As String = "", Optional queryString As String = "TRACE-INFO")

        'REGISTRA L'ERRORE NEL LOG UTENTE
        'If Me.idpfu.HasValue Then
        Dim command As String = "INSERT INTO [dbo].[CTL_LOG_UTENTE]
            ([ip]
            ,[idpfu]
            ,[datalog]
            ,[paginaDiArrivo]
            ,[paginaDiPartenza]
            ,[querystring]
            ,[form]
            ,[browserUsato]
            ,[descrizione]
            ,[sessionID])
        VALUES
            (@ip,@idpfu,GETDATE(),@targeturl,@sourceurl,@querystring,@form,@browser,@description,@sessionid)"

        Dim params As New Hashtable

        params("@ip") = ""

        params("@idpfu") = If(idpfu.HasValue, Me.idpfu.Value, DBNull.Value)
        params("@targeturl") = paginaDiArrivo
        params("@sourceurl") = DBNull.Value

        params("@querystring") = Left(queryString, 4000)

        'Dim formvalues As New List(Of String)
        'params("@form") = String.Join("&", formvalues.ToArray)
        params("@browser") = browserUsato
        params("@form") = message

        params("@description") = description

        params("@sessionid") = If(Not String.IsNullOrWhiteSpace(sessionID), sessionID, String.Empty)

        Me.ExecuteNonQuery(command, params)

        ' End If
    End Sub


    ''' <summary>
    ''' Scatena una eccezione GESTITA o NON GESTITA
    ''' </summary>
    ''' <param name="message">Messaggio di errore</param>
    ''' <param name="ex">Se Presente l'eccezione NON GESTITA o CRITICA alora viene eseguita anche la TRACEERROR e il messaggio viene modificato in un errore Generico per l'utente</param>
    ''' <param name="IgnoreTraceEmail">Non inviare l'email di notifica</param>
    Public Sub RunException(message As String, ex As Exception, Optional IgnoreTraceEmail As Boolean = False)

        RegisterLogError(message, "/AF_WebFileManager/proxy/1.0/uploadattach", "RunException")

        'TODO: quando traceInsert viene passata EX  siamo in un errore tecnico, va quindi chiamata la traceError ( e a sua volta la libreria di gestione errori ) e nello stesso if va cambato il messaggio che uscirà all'utente mettendo quello generico "friendly"
        Console.ForegroundColor = ConsoleColor.Red
        Console.WriteLine(message)
        Console.ResetColor()

        If Not IsNothing(ex) Then
            Me.traceError(ex, IgnoreTraceEmail)
            Throw New AfCommon.UploaderException(message)
        Else
            Throw New Exception(message)
        End If
    End Sub

    ''' <summary>
    ''' Quando l'istanza viene inizializzata con Transazione, viene eseguito il commit della transazione
    ''' </summary>
    Public Sub commit
        If Not IsNothing(Me._tr)
            Me._tr.Commit
            Me._tr = Nothing
        End If
    End Sub
    ''' <summary>
    ''' ''' Quando l'istanza viene inizializzata con Transazione, viene eseguito il rollback della transazione
    ''' </summary>
    ''' <param name="IgnoreException"></param>
    Public Sub rollback(Optional IgnoreException As Boolean = False)
        If Not IsNothing(Me._tr) Then

            Try
                Me._tr.Rollback
                Me._tr = Nothing
            Catch ex As Exception
                If Not IgnoreException Then Throw ex
            End Try
        End If
    End Sub

    '-- METODO GENERICO DA USARE NEL CASO CI SERVISSE UN ESTENSIONE DI METODI MA NON VOGLIAMO MODIFICARNE LA FIRMA
    Public Function exec(Of T)(ByVal param As Hashtable) As T

        'Dim x As String = NameOf(exec) -- restituisce il nome di un oggetto qualsiasi

        Return Nothing

    End Function

#Region "IDisposable Support"
    Private disposedValue As Boolean ' To detect redundant calls
    Protected Overridable Sub Dispose(disposing As Boolean)
        If Not disposedValue Then
            If disposing Then
                Me.rollback
                If Not IsNothing(Me._conn) AndAlso Me._conn.State = ConnectionState.Open
                    _conn.Close
                    _conn.Dispose
                    _conn = Nothing
                End If
            End If
        End If
        disposedValue = True
    End Sub
    Public Sub Dispose() Implements IDisposable.Dispose
        Dispose(True)
    End Sub

    Protected Overrides Sub Finalize()
        MyBase.Finalize()

        GC.SuppressFinalize(Me)

    End Sub
#End Region
End Class