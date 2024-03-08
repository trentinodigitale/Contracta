Imports System.Web.Mvc
Imports StorageManager


Namespace Controllers
    Public Class DownloadController
        Inherits Controller

        <Route("download")>
        Function downloadattach(id As String) As ActionResult
            Return View(viewName:="downloadattach")
        End Function

        <Route("downloadjobresult")>
        Function downloadjobresult(jobid As String) As FileResult


            Using Dbm As New CTLDB.DatabaseManager(False, Nothing)

                Dim W As AfCommon.WorkerQueueEntryModelType = ServiceQueueLibrary.JobsManager.fx_get_job_status(Dbm, jobid)
                Dbm.setUserInfo(W.idpfu, W.sessionid)

                If W.esit Then
                    Dim R As AfCommon.DisplayAttachResponseModelType = AfCommon.Tools.Serialization.JsonDeserialize(Of AfCommon.DisplayAttachResponseModelType)(W.settings("json"))
                    Dim retfile As String = W.settings("fileid")
                    Dim blobid As String = W.settings("blobid")
                    BlobManager.BlobHistory.Add(blobid)
                    BlobManager.TempHistory.Add(retfile)
                    If Not My.Computer.FileSystem.FileExists(retfile) Then
                        retfile = BlobManager.GetPureFileOnDisk(Dbm, blobid, True)
                    End If
                    For Each k As String In R.headers.Keys
                        Response.AddHeader(k, R.headers(k))
                    Next
                    Response.AddHeader("content-length", New System.IO.FileInfo(retfile).Length)
                    Response.ContentType = R.contenttype
                    Response.StatusCode = 200
                    Response.WriteFile(retfile)
                    Response.End()
                    BlobManager.fx_purge_blob_history(Dbm)
                End If

            End Using

        End Function
    End Class
End Namespace