Imports StorageManager


''' <summary>
''' Istanza di un JOB in Corso
''' Il gestore esegue una nuova istanza dell'AF_ServiceFileManager per la lavorazione in modalità Classica mentre utilizza lo stesso processo quando il Debugger è attivo.
''' </summary>
Public Class AsyncQueueWorker
    Public property id As String 
    Public property lockid As String
    Private ReadOnly TR as system.threading.Thread  = Nothing
    Public Function active() As Boolean
        Return Not IsNothing(Me.TR) AndAlso Me.TR.IsAlive
    End Function
    Public Sub New(id As String, lockid As String)

        Me.id = id
        Me.lockid = lockid

        Try
            Me.TR.Priority = Threading.ThreadPriority.AboveNormal
        Catch ex As Exception
        End Try

        Me.TR = New Threading.Thread(AddressOf execute)
        Me.TR.Start()

    End Sub
    Private Sub execute()
        If Debugger.IsAttached Then
            Call AfServiceManager.fx_run_worker(Me.id, Me.lockid)
        Else
            Dim processTorun As String = System.Reflection.Assembly.GetEntryAssembly().Location

            Dim strAction As String = "post-upload-action"

            '-- timeout dedicato al tempo di elaborazione dell'allegato. si consiglia 5 minuti, espresso in millisecondi è 300000
            Dim strTimeOut As String = AfCommon.AppSettings.item("shell-timeout-" & strAction)
            Dim timeOut As Integer = -1
            If Not IsNothing(strTimeOut) AndAlso IsNumeric(strTimeOut) Then
                timeOut = CInt(strTimeOut)
            End If

            Shell(processTorun & " exec:" & Me.id & "@" & Me.lockid & " settingsfile:" & AfCommon.AppSettings.item.settingsfile, AppWinStyle.NormalFocus, True, timeOut)

        End If
    End Sub

    Public Sub StopThread()
        If Not Debugger.IsAttached Then
            Try
                Me.TR.Abort()
            Catch ex As Exception
            End Try
        End If
    End Sub

    Private Function isAliveExt(TR As System.Threading.Thread) As Boolean
        '-- il solo uso del metodo isAlive del thread non è sicuro? non contempla tutti i casi e non è adatto a capire se un thread è ancora "vivo" o meno?
        'Return (TR.ThreadState And (TR.ThreadState.Stopped Or TR.ThreadState.Unstarted)) = 0
        Throw New NotImplementedException
    End Function


End Class
