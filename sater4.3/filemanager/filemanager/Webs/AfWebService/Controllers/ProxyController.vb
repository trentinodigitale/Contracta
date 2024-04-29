Imports System.Web.Mvc
Imports MongoDB.Bson
Imports StorageManager

Namespace Controllers
    Public Class ProxyController
        Inherits Controller

        ' GET: Proxy

        <Route("proxy/admin/{fx}")>
        Function aminproxy(fx As String) As JsonResult
            Select Case fx
                Case "purgetranslations"
                    CTLDB.DatabaseManager.ClearTranslationsCache()
                    Return Json(New With {.status = "OK"}, JsonRequestBehavior.AllowGet)
                Case "ping"
                    Return Json(New With {.status = "PONG"}, JsonRequestBehavior.AllowGet)
            End Select
        End Function

        Function index() As JsonResult
            Return Json(New With {.status = "OK_INDEX"}, JsonRequestBehavior.AllowGet)
        End Function

        <Route("proxy/1.0/{fx}")>
        <ValidateInput(False)>
        Function proxy(fx As String, filepath As String,filename As String, timeout As String,buttonlink As String) As ActionResult
            'REGISTER REQUEST
            Dim PR As New AfCommon.ProxyRequestModelType()

            With PR
                .creationdate = Date.Now
                For Each k As String In Request.Form.Keys
                    .form(k) = Request.Form(k)
                Next

                Dim query As String = Request.Url.Query

                If Not String.IsNullOrWhiteSpace(query) Then
                    query = query.Replace("&amp;", "&")
                End If

                With System.Web.HttpUtility.ParseQueryString(query)
                    For Each k As String In .Keys
                        If String.IsNullOrWhiteSpace(k) Then Continue For
                        PR.query(k) = .Item(k)
                    Next
                End With
                .url = Request.Url.AbsoluteUri
                .id = AfCommon.Tools.getrandomid
                .fx = fx
                .ipaddress = Request.UserHostAddress
                If Not IsNothing(Request.UrlReferrer) Then
                    .ref_url = Request.UrlReferrer.AbsoluteUri
                    With System.Web.HttpUtility.ParseQueryString(Request.UrlReferrer.AbsoluteUri)
                        For Each k As String In .Keys
                            If String.IsNullOrWhiteSpace(k) Then Continue For
                            PR.ref_query(k) = .Item(k)
                        Next
                    End With
                End If
            End With

            Dim IdPfu As Integer? = Nothing
            Dim strVirtualDirectory As String = ""
            Dim sessionid As String = ""

            Using Dbm As New CTLDB.DatabaseManager(False, Nothing)
                strVirtualDirectory = Dbm.getDbSYS("strVirtualDirectory")
                If Not String.IsNullOrWhiteSpace(PR.query("acckey")) Then
                    Dim UI As CTLDB.UserAccessInfo = Dbm.GetAccessInfo(PR.query("acckey"))
                    If Not IsNothing(UI) Then
                        IdPfu = UI.idPfu
                        sessionid = UI.sessionID
                        PR.query("idPfu") = UI.idPfu
                        PR.query("sessionID") = UI.sessionID
                    End If
                End If
                Dbm.setUserInfo(IdPfu, sessionid)
                Dbm.RegisterPageRequest(System.Web.HttpContext.Current.Request)
                CTLDB.DbClassTools.fx_save_instance(PR, Dbm)
            End Using





            Select Case fx.ToLower
                Case "preparecellupload"
                    Dim query As String = ""
                    If IdPfu.HasValue
                        Using Dbm As New CTLDB.DatabaseManager(False, Nothing)
                            Dbm.setUserInfo(IdPfu, sessionid)
                            Dbm.RegisterPageRequest(System.Web.HttpContext.Current.Request)

                            'RICAVA LA QUERY DALL PARAMETRO BUTTONLINK E INSERISCE I VALORI NELLA QUERY DELLA PROXYREQUEST
                            Dim queryOk As Boolean=False
                            Try
                                Dim start As Integer = buttonlink.IndexOf("'",StringComparison.Ordinal)
                                If start >= 0
                                    start +=1
                                    dim text = buttonlink.Substring(start)
                                    Dim _end As Integer = text.IndexOf("'",StringComparison.Ordinal)
                                    If _end >= 0
                                        text = text.Substring(0,_end)
                                        If text.Contains("?")
                                            text = text.Substring(text.IndexOf("?",StringComparison.Ordinal)).Trim("?")
                                            Dim nvq As NameValueCollection = System.Web.HttpUtility.ParseQueryString(text)
                                            For each k As String In nvq.Keys
                                                PR.query(k) = nvq(k)
                                            Next
                                            queryOk=True
                                        End If
                                    End If
                                End If
                            Catch ex As Exception
                            End Try
                            If queryOk
                                PR.fx = "uploadattach"
                                CTLDB.DbClassTools.fx_save_instance(PR, Dbm)
                                Return Json(New With{.esit = True, .pid = PR.id},JsonRequestBehavior.AllowGet)
                            Else
                                Return Json(New With{.esit = false,.message = "Error to Parse Query"},JsonRequestBehavior.AllowGet)
                            End If
                        End Using
                    Else
                        Return Json(New With{.esit = false,.message = "Accesso Negato"},JsonRequestBehavior.AllowGet)
                    End If

                Case "attach_fromfile"                              'INSERISCE UN FILE NEL DB E restituisce la forma tecnica
                    Dim ret As New JsonResultModelType
                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "")
                        Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                        Dim tid As String = ""
                        Dim B As BlobEntryModelType = Load_File_from_disk(Dbm, PR, Request, filepath, filename, tid, True, ret.message)
                        If Not IsNothing(B) Then
                            'Dim Res As AfCommon.ComplexResponseModelType = CTLATTACHS.Attach.UploadAttachSign(PR.id, B, PR.query, PR.query("idPfu"), Dbm)

                            Dim Res As AfCommon.ComplexResponseModelType = CTLATTACHS.Attach.UploadAttach(PR.id, B, PR.query, PR.query("idPfu"), Dbm)

                            If Res.esit Then
                                ret.content = Res.techvalue
                                ret.esit = True
                            Else
                                ret.message = Res.out
                                ret.esit = False
                            End If
                            BlobManager.fx_delete_blob(Dbm, B.id)
                        End If
                    End Using

                    'Return Json(ret)
                    Return Json(ret, JsonRequestBehavior.AllowGet)

                Case "uploadpath", "uploadpath_signed"               'IDENTICI a "uploadattach", "uploadattachsigned" ma con il parametro filepath in query che identifica il file fisico
                    Dim ret As New JsonResultModelType
                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "")
                        Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                        Dim tid As String = ""
                        Dim B As BlobEntryModelType = Load_File_from_disk(Dbm, PR, Request, filepath, filename, tid, True, ret.message)
                        If Not IsNothing(B) Then
                            PR = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(B.pid, Dbm, Nothing)
                            'ACCODA IL JOB PER LA LAVORAZIONE
                            Dim jobid As String = ServiceQueueLibrary.JobsManager.fx_enqueue(Dbm, B.creationdate, "post-upload-action", tid, Nothing, PR.idPfu, PR.SessionId)
                            Dbm.RegisterLogInfo("Upload completato, richiesto il job per lavorare il file : #" & B.filename & "# (" & B.size & ")", "/AF_WebFileManager/proxy/1.0/uploadattach")

                            'Attesa per la fine del processo in accordo con il timeou (in secondi) in querystring (timeout)
                            Dim start As DateTime = Date.Now
                            Dim W As AfCommon.WorkerQueueEntryModelType = ServiceQueueLibrary.JobsManager.fx_get_job_status(Dbm, jobid)
                            Dim waitseconds As Integer = 30
                            If Not String.IsNullOrWhiteSpace(timeout) AndAlso IsNumeric(timeout) Then
                                waitseconds = CInt(timeout)
                            End If
                            While Not W.esit.HasValue AndAlso Date.Now.Subtract(start).TotalSeconds < waitseconds
                                System.Threading.Thread.Sleep(3000)
                                W = ServiceQueueLibrary.JobsManager.fx_get_job_status(Dbm, jobid)
                            End While
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

                                If W.esit Then
                                    'Restituire il dato tecnico
                                    Dim json As String = W.returnactions("do-opener-update")
                                    If Not String.IsNullOrWhiteSpace(json) Then
                                        Dim bd As BsonDocument = BsonDocument.Parse(json)
                                        ret.content = bd("techvalue").AsString
                                    End If
                                    ret.esit = True
                                Else
                                    ret.esit = False
                                    ret.message = W.message
                                End If
                            Else
                                ret.esit = False
                                ret.message = "timeout"
                            End If
                        End If
                    End Using

                    'Return Json(ret)
                    Return Json(ret, JsonRequestBehavior.AllowGet)

                Case "uploadattach", "uploadattachsigned"
                    If IdPfu.HasValue
                        Response.Redirect("../../upload?pid=" & PR.id, True)
                    Else
                        Dim message As String = "Accesso Negato"
                        Response.Redirect(strVirtualDirectory & "/ctl_library/MessageBoxWin.asp?ML=no&MSG=" & System.Web.HttpUtility.UrlEncode(message) & "&CAPTION=Errore&ICO=2", True)
                    End If
                Case "displayattach"

                    'TODO: aggiungere in questo punto della display attach il test su If IdPfu.HasValue in abinato al test su ATT_PUBBLICO

                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing)
                        Dim jobid As String = ServiceQueueLibrary.JobsManager.fx_enqueue(Dbm, Date.Now, "display-attach", PR.id, Nothing, IdPfu, sessionid)
                        Response.Redirect("../../download?id=" & jobid)
                    End Using
                    'Using Dbm As New DbManager.DatabaseManager(False)
                    '    dim jobid As String = ServiceQueueLibrary.JobsManager.fx_enqueue(Dbm, Date.Now, "display-attach", PR.id, Nothing)
                    '    Dim W As AfCommon.WorkerQueueEntryModelType = ServiceQueueLibrary.JobsManager.fx_get_job_status(Dbm, jobid)
                    '    While Not W.esit.HasValue
                    '        System.Threading.Thread.Sleep(500)
                    '        W = ServiceQueueLibrary.JobsManager.fx_get_job_status(Dbm, jobid)
                    '    End While
                    '    If W.esit
                    '        Dim R As AfCommon.DisplayAttachResponseModelType = AfCommon.Tools.Serialization.JsonDeserialize(Of AfCommon.DisplayAttachResponseModelType)(W.settings("json"))
                    '        Dim retfile As String = BlobManager.GetPureFileOnDisk(Dbm, R.blobid)
                    '        For each k As String In R.headers.Keys
                    '            Response.AddHeader(k, R.headers(k))
                    '        Next
                    '        Response.AddHeader("content-legth", New System.IO.FileInfo(retfile).Length)
                    '        Response.ContentType = R.contenttype
                    '        Response.StatusCode = 200
                    '        Response.WriteFile(retfile)
                    '        Response.End
                    '        My.Computer.FileSystem.DeleteFile(retfile)
                    '    Else
                    '        Response.StatusCode = 404
                    '        Response.Write("File Not Found")
                    '        Response.End
                    '    End If
                    'End Using
                'Case "pdfoperation"
                '    Using Dbm As New CTLDB.DatabaseManager(False)
                '        Dim W As AfCommon.WorkerQueueEntryModelType = ServiceQueueLibrary.JobsManager.fx_enqueue_and_wait(Dbm,Date.Now, "pdfoperation",PR.id,Nothing,Nothing,IdPfu,sessionid)
                '        If W.esit.HasValue
                '            Response.Write(W.settings("response").ToString)
                '        Else
                '            Response.StatusCode = 500
                '        End If
                '    End Using
                Case "pdfoperation"
                    Using Dbm As New CTLDB.DatabaseManager(False, Nothing)

                        Dim pathFilePdf As String = PR.query("pdf")
                        Dim mode As String = PR.query("mode")

                        If String.IsNullOrEmpty(mode) Then
                            Response.Write("0#Parametro MODE obbligatorio")
                        End If

                        Select UCase(mode)
                            Case "SIGN"
                                Try
                                    If String.IsNullOrEmpty(pathFilePdf) Then
                                        Response.Write("0#Parametro PDF obbligatorio")
                                    Else
                                        Response.Write(PdfLibrary.PdfUtils.GetPdfHash(Dbm, pathFilePdf, False))
                                    End If
                                Catch ex As Exception
                                    Response.Write("0#" & ex.Message)
                                End Try
                            Case "VERIFICA_PDF"

                                If String.IsNullOrEmpty(pathFilePdf) Then
                                    Response.Write("0#Parametro PDF obbligatorio")
                                Else

                                    Call Dbm.AppendOperation("VERIFICA_PDF. Verifico se è un allegato con firma digitale")

                                    Dim ret As New JsonResultModelType
                                    Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                                    Dim B As BlobEntryModelType = Load_File_from_disk(Dbm, PR, Request, pathFilePdf, filename, "", False, ret.message)
                                    If Not IsNothing(B) Then
                                        Dim Res As AfCommon.ComplexResponseModelType = PdfLibrary.PdfUtils.verifyPdfSigned(Dbm, B, PR.query("attHash"), PR.query("attIdMsg"), PR.query("attOrderFile"), PR.query("attIdObj"), PR.query("idAzi"))
                                        BlobManager.fx_delete_blob(Dbm, B.id)
                                        If Res.esit Then

                                            If Res.signscounter = 0 AndAlso PR.query.ContainsKey("issigned") AndAlso PR.query("issigned").ToString.ToLower = "true" Then
                                                ret.esit = False
                                                Response.Write("0#Nessuna Firma trovata nel file")
                                            Else
                                                Response.Write(String.Empty)
                                            End If
                                        Else
                                            Response.Write(Res.out)
                                        End If
                                    Else
                                        Response.Write(ret.message)
                                    End If
                                End If

                            Case "VERIFICA_P7M"
                                If String.IsNullOrEmpty(pathFilePdf) Then
                                    Response.Write("0#Parametro PDF obbligatorio")
                                Else

                                    Call Dbm.AppendOperation("VERIFICA_P7M. Verifico se è un allegato con firma digitale")

                                    Dim ret As New JsonResultModelType
                                    Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                                    dim B As BlobEntryModelType = Load_File_from_disk(Dbm,PR,Request,pathFilePdf,filename,"",false,ret.message)
                                    If Not IsNothing(B)
                                        dim Res As AfCommon.ComplexResponseModelType = PdfLibrary.PdfUtils.verifyP7MSigned(Dbm,B,PR.query("attHash"), PR.query("attIdMsg"),PR.query("attOrderFile"),PR.query("attIdObj"),PR.query("idAzi"))
                                        BlobManager.fx_delete_blob(Dbm,B.id)
                                        If Res.esit
                                            Response.Write(String.Empty)
                                        Else
                                            Response.Write(Res.out)
                                        End If
                                    Else
                                        Response.Write(ret.message)
                                    End If
                                End If

                            Case Else
                                Response.Write("0#mode '" & mode & "' non supportato")
                        End Select
                    End Using
            End Select
        End Function

        Private shared function Load_File_from_disk(DBm As CTLDB.DatabaseManager, PR As  AfCommon.ProxyRequestModelType,request As HttpRequestBase, filepath As String,filename As String, byref tid As String,SaveToDb As Boolean, byref errormessage As String) As BlobEntryModelType
            Dim errlist As New List(Of String)
            Dim FI As System.IO.FileInfo = Nothing

            If String.IsNullOrWhiteSpace(filepath) OrElse Not My.Computer.FileSystem.FileExists(filepath) Then
                errlist.Add("File not found")
            Else
                FI = New System.IO.FileInfo(filepath)
            End If

            If errlist.Count = 0 Then

                Try

                    If String.IsNullOrWhiteSpace(filename) Then
                        filename = FI.Name
                    End If

                    Dim B As BlobEntryModelType = Nothing
                    If SaveToDb Then
                        Dim language As String = ""
                        'START PROCESS To REgister file into db
                        language = DBm.language
                        Dim format As String = PR.query("FORMAT")
                        Dim FEEXT As New System.IO.FileInfo(filename)
                        Dim extensions As String = FEEXT.Extension.Trim(".").Trim.ToLower()
                        'If Not String.IsNullOrWhiteSpace(format) AndAlso format.Contains("EXT:") Then
                        '    Dim extpart As String = format.Substring(format.IndexOf("EXT:", StringComparison.OrdinalIgnoreCase) + 4)
                        '    If extpart.Contains("-") Then
                        '        extpart = extpart.Substring(0, extpart.IndexOf("-", StringComparison.OrdinalIgnoreCase))
                        '    End If
                        '    extpart = extpart.Trim()
                        '    If Not String.IsNullOrWhiteSpace(extpart) Then
                        '        extensions = extpart.Replace(",", ";").Trim(";").ToUpper()
                        '    End If
                        'End If
                        tid = StorageManager.BlobManager.fx_prepare_upload(DBm, PR.id, request.UserHostAddress, request.Url.AbsoluteUri, FI.Length, filename, extensions)
                        DBm.RegisterLogInfo("INIZIO_UPLOAD. NOME FILE : " & filename, "/AF_WebFileManager/proxy/1.0/pathupload@proxy", "NOME_FILE_UPLOAD", "")
                        DBm.AppendOperation("INIZIO_UPLOAD. NOME FILE : " & filename)
                        'CARICA IL FILE DALLO STREAM AL DATABASE
                        B = BlobManager.fx_append_large_file_data(DBm, tid, FI.FullName)
                        AfServiceLibrary.FileQueueManager.fx_complete_upload_process(AfCommon.Tools.getrandomid, B, PR.query, Dbm)
                        Return B
                    Else
                        B = BlobManager.create_blob_from_file(DBm, filepath, filename, False)
                    End If
                    'TODO: Cancellare il file dal disco?????
                    Return B
                Catch ex As Exception
                    errormessage = ex.Message
                    Return Nothing
                End Try
            Else
                errormessage = String.Join(vbCrLf, errlist)
                Return Nothing
            End If
        End function
    End Class
End Namespace