Imports System.Configuration

Public Class DatabaseManager
    Implements IDisposable
    Private _connectionstring As String = ""
    Private ReadOnly _usetransaction As Boolean = False
    Private ReadOnly jobid As String = ""
    Private readonly logparent As String = ""
    Public function GetAccessInfo(acckey As String) As UserAccessInfo
        Dim RET As UserAccessInfo = Nothing
        Dim params As New Hashtable
        params("acckey") = acckey
        Using dr As SqlClient.SqlDataReader = Me.ExecuteReader("select * from CTL_ACCESS_BARRIER with(nolock) where guid = @acckey and datediff(SECOND, data,getdate()) <= 30",params)
            If dr.Read
                RET = New UserAccessInfo With {.idPfu = dr("idpfu"),.sessionID = dr("sessionid")}
            End If
        End Using
        Return RET
    End function

    Public Sub RegisterPageRequest(idpfu As Integer?,sessionid As String,description As String)
        If Not IsNothing(System.Web.HttpContext.Current)
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
            With System.Web.HttpContext.Current.Request
                params("@ip") = .UserHostAddress
                params("@idpfu") = If(idpfu,idpfu.Value,DBNull.Value)
                params("@targeturl") = .Url.AbsolutePath
                If Not IsNothing(.UrlReferrer)
                    params("@sourceurl") = .UrlReferrer.AbsoluteUri
                Else
                    params("@sourceurl") = DBNull.Value
                End If
                params("@querystring") = .Url.Query.Trim("?")
                Dim formvalues As New List(Of String)
                If Not IsNothing(.Form)
                    For each k As String In .Form.Keys
                        formvalues.Add(k & "=" & .Form(k))
                    Next
                End If
                params("@form")  = String.Join("&",formvalues.ToArray)
                params("@browser") = .UserAgent
                If String.IsNullOrWhiteSpace(description)
                    description = "SERVER-NAME:" & My.Computer.Name
                End If
                params("@description") = description
                params("@sessionid") = If(not IsNothing(sessionid),sessionid,String.Empty)
            End With
            Me.ExecuteNonQuery(command,params)
        End If
    End Sub
    Private Sub traceError(ByVal descrizione As String)
	    'ERRORE NELL'EVENT VIEWER. RENDERE DINAMICO IL CONTESTO 
        Dim contesto = "FILEHASH.ASPX"
        Dim typeTrace As String = "TRACE-ERROR"        
        Dim sSource As String
        Dim sLog As String
        Dim sEvent As String
        Dim sMachine As String = ""
        sEvent = Left("Errore nella generazione dell'hash del file --- Descrizione dell'errore : " & descrizione, 4000)        
        sSource = "AFLink"
        sLog = "Application"
        sMachine = "."
        'If Not System.Diagnostics.EventLog.SourceExists(sSource, sMachine) Then
        '    System.Diagnostics.EventLog.CreateEventSource(sSource,sLog,sMachine)
        'End If
        'Dim ELog As New EventLog(sLog, sMachine, sSource)
        'ELog.WriteEntry(sEvent, EventLogEntryType.Error)        
    End Sub
    Public shared function GetTempFileName As String
        Try
            Dim tempdir As String = AfCommon.AppSettings.item("tempdir")
            If Not String.IsNullOrWhiteSpace(tempdir)
                If Not My.Computer.FileSystem.DirectoryExists(tempdir) Then My.Computer.FileSystem.CreateDirectory(tempdir)
            Else
                Return My.Computer.FileSystem.GetTempFileName
            End If
            Dim ret As String = tempdir.Trim("\")  & "\" & AfCommon.Tools.getrandomid
            My.Computer.FileSystem.WriteAllBytes(ret,New Byte(){},False)
            Return ret

        Catch ex As Exception
            Return My.Computer.FileSystem.GetTempFileName
        End Try
    End function
    Private Function connectionstring As String
        If Not String.IsNullOrWhiteSpace(_connectionstring)
            Return _connectionstring
        ElseIf Not String.IsNullOrWhiteSpace(AfCommon.AppSettings.item("connectionstring"))            
            me._connectionstring = AfCommon.AppSettings.item("connectionstring")
            Return _connectionstring
        Else
            Throw New Exception("Connectionstring Not Found in Configuration Settings")
        End If
    End Function
    Public function IsReady
        Return Not IsNothing(Me.conn) AndAlso Me.conn.State = ConnectionState.Open
    End function
    Private _conn As SqlClient.SqlConnection = Nothing
    Private Function conn As SqlClient.SqlConnection
        If IsNothing(_conn)
            _conn = New SqlClient.SqlConnection(Me.connectionstring)
            _conn.Open
        End If
        Return _conn
    End Function
    Private _tr As SqlClient.SqlTransaction = Nothing
    Private Function tr As SqlClient.SqlTransaction
        If IsNothing(_tr) AndAlso Me._usetransaction
            Me._tr = Me.conn.BeginTransaction
        End If
        Return _tr
    End Function
    Public Sub New(usetransaction As Boolean, Optional connectionstring As String = "",Optional jobid As String= "",Optional logparent As String = "")
        Me._usetransaction = usetransaction
        Me._connectionstring = connectionstring
        Me.jobid = jobid
        Me.logparent = logparent
        Dim starttime As DateTime = Date.Now
        While Not Me.IsReady AndAlso Date.Now.Subtract(starttime).TotalSeconds < 30
            System.Threading.Thread.Sleep(100)
        End While
    End Sub
    Public sub fx_update_queue_operation(operation As String,progress As Double,Optional displayvariables As Hashtable = Nothing)
        If Not String.IsNullOrWhiteSpace(Me.jobid)
            If Not String.IsNullOrWhiteSpace(operation)
                Me.AppendOperation(operation)
            End If            
            If IsNothing(displayvariables) OrElse displayvariables.Keys.Count = 0
                Dim params As New Hashtable
                params("@id") = Me.jobid
                params("@operation") = operation & " (" & Format(progress,"#0.00") & " %)"
                params("@progress") = progress
                Dim main_tablename As String = DbClassTools.GetTableName(gettype(AfCommon.WorkerQueueEntryModelType))
                me.ExecuteNonQuery("UPDATE [" & main_tablename & "] SET [operation] = @operation, [progress] = @progress WHERE id = @id", params)
            Else
                Dim W As AfCommon.WorkerQueueEntryModelType = DbManager.DbClassTools.fx_get_instance(Of AfCommon.WorkerQueueEntryModelType)(Me.jobid, Me, Nothing)
                For each k As String In displayvariables.Keys
                    W.displayvariables(k) = displayvariables(k)
                Next
                W.operation = operation
                W.progress = progress
                DbManager.DbClassTools.fx_save_instance(W, Me)                
            End If
        End If
    End sub
    Public Function ExecuteNonQuery(command As String, params As Hashtable) As Integer
        Using cmd As New SqlClient.SqlCommand(command, Me.conn, Me.tr)
            cmd.CommandTimeout = conn.ConnectionTimeout
            If Not IsNothing(params)
                For Each k As String In params.Keys
                    Dim value As Object = params(k)
                    If Not k.StartsWith("@") Then k = "@" & k
                    If IsNothing(value) Then value = DBNull.Value
                    cmd.Parameters.AddWithValue(k, value)
                Next
            End If
            Return cmd.ExecuteNonQuery
        End Using
    End Function
    Public Function ExecuteReader(command As String, params As Hashtable) As SqlClient.SqlDataReader
        Dim cmd As New SqlClient.SqlCommand(command, Me.conn, Me.tr)
        cmd.CommandTimeout = conn.ConnectionTimeout
        If Not IsNothing(params)
            For Each k As String In params.Keys
                Dim value As Object = params(k)
                If Not k.StartsWith("@") Then k = "@" & k
                If IsNothing(value) Then value = DBNull.Value
                cmd.Parameters.AddWithValue(k, value)
            Next
        End If
        Return cmd.ExecuteReader(CommandBehavior.KeyInfo)
    End Function
    Public Function fx_get_datatable(command As String, params As Hashtable) As DataTable
        Using cmd As New SqlClient.SqlCommand(command, Me.conn, Me.tr)
            cmd.CommandTimeout = conn.ConnectionTimeout
            If Not IsNothing(params)
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
    Public Sub TraceDB(Text as String,target As String,session As Object)

    End Sub

    Public Sub AppendOperation(text As String)
        Dim LE As New AfCommon.OperationLogEntryModelType() With {.id = AfCommon.Tools.getrandomid,.creationdate = Date.Now,.logparent = Me.logparent,.text = text}
        DbManager.DbClassTools.fx_save_instance(LE,Me,True)
        Console.WriteLine(LE.creationdate.ToString() & vbTab & "OP : " & vbTab & LE.text)
    End Sub

    Public Sub RunException(message As String)
        me.traceError(message)
        Console.ForegroundColor = ConsoleColor.Red
        Console.WriteLine(message)
        Console.ResetColor
        Throw New Exception(message)
    End Sub


    Public Sub commit
        If Not IsNothing(Me._tr)
            Me._tr.Commit
            Me._tr = Nothing
        End If
    End Sub
    Public Sub rollback(optional IgnoreException As Boolean = False)
        If Not IsNothing(Me._tr)
            Try
                Me._tr.Rollback
                Me._tr = Nothing
            Catch ex As Exception
                If Not IgnoreException Then Throw ex
            End Try
        End If
    End Sub

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
#End Region
End Class
