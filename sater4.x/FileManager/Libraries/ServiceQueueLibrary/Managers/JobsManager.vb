Imports CTLDB

Public Class JobsManager

    ''' <summary>
    ''' Restisuice lo stato di avanzamento della lavorazione di un Job
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="jobid"></param>
    ''' <returns></returns>
    Public Shared Function fx_get_job_status(Dbm As CTLDB.DatabaseManager, jobid As String) As AfCommon.WorkerQueueEntryModelType

        Dim tablename As String = ""
        Dim ret As AfCommon.WorkerQueueEntryModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.WorkerQueueEntryModelType)(jobid, Dbm, Nothing, False, tablename, True)

        Dim retMain As AfCommon.MainWorkerQueueEntryModelType = Nothing

        '-- se il record è nothing vuol dire che non è stato ancora copiato il job dalla tabella MAINworkerQueueEntryModelType alla WorkerQueueEntryModelType
        If IsNothing(ret) Then

            '-- Chiedo al db un record della tabella 'tablename' con chiave ID 'jobid' per ottenere un oggetto della classe passata come parametro 'MainWorkerQueueEntryModelType'
            retMain = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.MainWorkerQueueEntryModelType)(jobid, Dbm, Nothing, False, tablename, True)

            ret = New AfCommon.WorkerQueueEntryModelType()

            With ret

                .action = retMain.action
                .creationdate = retMain.creationdate
                .displayonform = retMain.displayonform
                .displayvariables = retMain.displayvariables
                .esit = retMain.esit
                .id = retMain.id
                .identifier = retMain.identifier
                .idpfu = retMain.idpfu
                .lastclientupdate = retMain.lastclientupdate
                .lastupdate = retMain.lastupdate
                .lockid = retMain.lockid
                .locktime = retMain.locktime
                .mainstart = retMain.mainstart
                .message = retMain.message
                .operation = Dbm.translate("Caricamento in corso...")
                .outputscripts = retMain.outputscripts
                .progress = retMain.progress
                .returnactions = retMain.returnactions
                .sessionid = retMain.sessionid
                .settings = retMain.settings
                .stacktrace = retMain.stacktrace
                .started = retMain.started

            End With


        End If

        ret.lastclientupdate = Date.Now

        Dim params As New Hashtable
        params("@id") = ret.id

        Dim start As DateTime = Date.Now
        Dim currentEx As Exception = Nothing

        tablename = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.MainWorkerQueueEntryModelType), Dbm, True)

        While Date.Now.Subtract(start).TotalSeconds < 5

            Try

                Dbm.ExecuteNonQuery("UPDATE [" & tablename & "] SET lastclientupdate = GETDATE() WHERE id = @id", params)
                currentEx = Nothing
                Exit While

            Catch ex As Exception
                currentEx = ex
                Threading.Thread.Sleep(500)
            End Try

        End While

        Return ret

    End Function

    ''' <summary>
    ''' Crea un Job da eseguire
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="mainstart"></param>
    ''' <param name="action"></param>
    ''' <param name="identifier"></param>
    ''' <param name="settings"></param>
    ''' <param name="idPfu"></param>
    ''' <param name="SessionId"></param>
    ''' <returns></returns>
    Public Shared Function fx_enqueue(Dbm As CTLDB.DatabaseManager, mainstart As DateTime?, action As String, identifier As String, settings As Hashtable, idPfu As Integer?, SessionId As String) As String
        'Dim W As new AfCommon.WorkerQueueEntryModelType(idPfu,SessionId)
        Dim W As New AfCommon.MainWorkerQueueEntryModelType(idPfu, SessionId)
        With W
            .mainstart = mainstart
            .action = action
            .creationdate = Date.Now
            .esit = Nothing
            .id = AfCommon.Tools.getrandomid
            .identifier = identifier
            If Not IsNothing(settings) Then
                .settings = settings
            End If
        End With
        Dim tablename As String = ""
        CTLDB.DbClassTools.fx_save_instance(W, Dbm, tablename)
        Dim params As New Hashtable
        params("@id") = W.id
        Dbm.ExecuteNonQuery("UPDATE [" & tablename & "] set lastclientupdate = GETDATE() WHERE id = @id", params)
        Return W.id
    End Function

    '--- mai usata. se va implementata ricordarsi di usare MainWorkerQueueEntryModelType e non WorkerQueueEntryModelType
    '''' <summary>
    '''' Crea un job da eseguire e ne attende l'esecuzione per il timeout definito
    '''' </summary>
    '''' <param name="Dbm"></param>
    '''' <param name="mainstart"></param>
    '''' <param name="action"></param>
    '''' <param name="identifier"></param>
    '''' <param name="settings"></param>
    '''' <param name="waittimeout"></param>
    '''' <param name="idPfu"></param>
    '''' <param name="sessionid"></param>
    '''' <returns></returns>
    'Public shared function fx_enqueue_and_wait(Dbm As CTLDB.DatabaseManager,mainstart As DateTime?, action As String,identifier As String, settings As Hashtable, waittimeout As TimeSpan?,idPfu As Integer?,sessionid As String) As AfCommon.WorkerQueueEntryModelType
    '    Dim jobid As String = fx_enqueue(Dbm,mainstart,action,identifier,settings,idPfu,sessionid)
    '    Dim start As DateTime = Date.Now
    '    While Not waittimeout.HasValue OrElse start.Subtract(Date.Now) < waittimeout
    '        Dim J As AfCommon.WorkerQueueEntryModelType =  JobsManager.fx_get_job_status(Dbm,jobid)
    '        If J.esit.HasValue
    '            Return J
    '        End If
    '    End While
    '    Return Nothing
    'End function

End Class
