Imports System.Web.Mvc
Imports CTLDB

Namespace Controllers
    Public Class JobController
        Inherits Controller

        <Route("jobservice/{fx}")>
        <HttpPost()>
        function jobservice(fx As String,tid As String,jobid As String) As JsonResult
            Dim ret As New JsonResultModelType
            Dim language As String = ""
            Try                
                Select Case fx
                    Case "checkprogress"
                        Using Dbm As New DatabaseManager(False, Nothing)
                            Try
                                '-- Verifichiamo dal client se il job è in lavorazione, contemporaneamente aggiorniamo il lastClientUpdate per indicare che il client è ancora in watching
                                Dim W As AfCommon.WorkerQueueEntryModelType = ServiceQueueLibrary.JobsManager.fx_get_job_status(Dbm, jobid)
                                Dbm.setUserInfo(W.idpfu, W.sessionid)
                                language = Dbm.language
                                Dim stage_elapsed As String = "-"
                                If W.started.HasValue Then
                                    stage_elapsed = TimeSpan.FromSeconds(CLng(Date.Now.Subtract(W.started).TotalSeconds)).ToString
                                End If
                                Dim main_elapsed As String = ""
                                If W.mainstart.HasValue Then
                                    main_elapsed = TimeSpan.FromSeconds(CLng(Date.Now.Subtract(W.mainstart).TotalSeconds)).ToString
                                Else
                                    main_elapsed = stage_elapsed
                                End If
                                If W.esit.HasValue AndAlso Not W.esit.Value AndAlso Not String.IsNullOrWhiteSpace(W.message) Then
                                    'W.message = "Errore di sistema " & Date.Now.ToString("o")
                                End If

                                If W.esit.HasValue Then
                                    
                                    If W.esit Then
                                        Dbm.RegisterLogInfo("Job " & W.id & " Completato con successo" & W.message, "/AF_WebFileManager/proxy/1.0/uploadattach", "checkprogress")
                                    Else

                                        Dbm.RegisterLogError("Job " & W.id & " Completato con errori" & W.message, "/AF_WebFileManager/proxy/1.0/uploadattach", "checkprogress")

                                    End If


                                    Try
                                        Dim params As New Hashtable
                                        params("@id") = jobid
                                        '-- cancelliamo il record dalla tabella MAIN ( ci serviva solo per mantenere il keep alive del client
                                        Dim tblName = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.MainWorkerQueueEntryModelType), Dbm, True)
                                        Dbm.ExecuteNonQuery("DELETE FROM [" & tblName & "] where id = @id", params)

                                    Catch ex As Exception
                                    End Try

                                End If

                                Dim closedialog As Boolean = (W.esit.HasValue AndAlso W.esit.Value = True) AndAlso Not W.displayonform
                                If Not String.IsNullOrWhiteSpace(W.operation) Then
                                    W.operation = Dbm.translate(W.operation)
                                End If
                                ret.content = New With {.closedialog = closedialog, .displayonform = W.displayonform, .data = W, .main_elapsed = main_elapsed, .stage_elapsed = stage_elapsed, .percentage = Format(W.progress, "#0.00").Replace(",", ".")}
                                ret.esit = True
                            Catch ex As Exception
                                Dbm.RunException(ex.Message, ex)
                            End Try
                        End Using
                End Select
            Catch ex As Exception
                ret.message = DatabaseManager.gettranslation(language,"INFO_UTENTE_ERRORE_PROCESSO") & "<br/>" & Date.Now.ToString("dd/MM/yyyy HH:mm:ss")
                ret.esit=False
                ret.content = Nothing
            End Try
            Return Json(ret)
        End function
    End Class
End Namespace