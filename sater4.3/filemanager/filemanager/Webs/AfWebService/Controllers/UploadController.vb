Imports System.Web.Mvc
Imports CTLDB

Namespace Controllers
    Public Class UploadController
        Inherits Controller


        <Route("upload")>
        Function uploadattach(pid As String) As ActionResult

            Dim fileextensions As String = "*.*"
            Dim showextensions As Boolean = False
            Dim postpage As String = ""
            Dim clearvalue As String = ""
            Dim fieldid As String = ""
            Dim maxsize As Long = 1024
            Dim language As String = ""
            Dim format As String = ""
            Dim techValue As String = ""
            Dim strVirtualDirectory As String = ""
            Dim strPath As String = ""
            '--nuova variabile per indicare il giro di firma
            '--quandio viene invocato uploadattachsigned
            Dim GiroFirma As String = "0" '0/1

            Dim cert_req_33215 As String = "0"

            Using Dbm As New DatabaseManager(False, Nothing, "")
                Dim PR As AfCommon.ProxyRequestModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(pid, Dbm, Nothing, False)
                Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                language = Dbm.language
                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select DZT_ValueDef from LIB_Dictionary where DZT_Name = 'SYS_ESTENSIONI_UPLOAD'", Nothing)
                    If dr.Read Then
                        fileextensions = dr("DZT_ValueDef")
                    End If
                End Using

                Try

                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select DZT_ValueDef from LIB_Dictionary where DZT_Name = 'SYS_MAX_SIZE_ATTACH'", Nothing)
                        If dr.Read Then
                            maxsize = CLng(dr("DZT_ValueDef"))
                        End If
                    End Using

                Catch ex As Exception
                    maxsize = 1024
                End Try

                format = PR.query("FORMAT")
                techValue = PR.query("TECHVALUE")

                GiroFirma = PR.query("GIRO_FIRMA")

                '--SE MI ARRIVA IN QS questo valore a YES significa che il techvalue lo tengo nella CTL_IMPORT
                If (UCase(PR.query("TECHBUFFER")) = "YES") Then
                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select A from CTL_IMPORT with(nolock) where isnull(A,'') <> '' and idpfu = " & PR.idPfu, Nothing)
                        If dr.Read Then
                            techValue = System.Web.HttpUtility.UrlDecode(dr("A"))
                        End If
                    End Using
                End If



                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select dbo.PARAMETRI('CERTIFICATION','certification_req_33215','Visible','0', -1) as val_flag", Nothing)
                    If dr.Read Then
                        cert_req_33215 = dr("val_flag")
                    End If
                End Using

                strVirtualDirectory = Dbm.getDbSYS("strVirtualDirectory")

                Dim tmpVirtualDir As String = AfCommon.AppSettings.item("app.strVirtualDirectory")

                ' Se presente la variabile nell'appsettings la facciamo vincere rispetto alla SYS
                If String.IsNullOrEmpty(tmpVirtualDir) = False Then
                    strVirtualDirectory = tmpVirtualDir
                End If

                strPath = PR.query("PATH")
                fieldid = PR.query("FIELD")

                If Not String.IsNullOrWhiteSpace(format) AndAlso format.Contains("EXT:") Then
                    Dim extpart As String = format.Substring(format.IndexOf("EXT:", StringComparison.OrdinalIgnoreCase) + 4)
                    If extpart.Contains("-") Then
                        extpart = extpart.Substring(0, extpart.IndexOf("-", StringComparison.OrdinalIgnoreCase))
                    End If
                    extpart = extpart.Trim()
                    If Not String.IsNullOrWhiteSpace(extpart) Then
                        showextensions = True
                        fileextensions = extpart.Replace(",", ";").Trim(";").ToUpper()
                    End If
                End If

                If Not String.IsNullOrWhiteSpace(PR.query("PAGE")) Then
                    postpage = PR.query("PAGE")
                    postpage = postpage.Replace("../../", strVirtualDirectory & "/CTL_LIBRARY/")
                    Dim qlist As New List(Of String)
                    For Each k As String In PR.query.Keys
                        Select Case k
                            Case "PAGE"
                                Continue For
                            Case Else
                                qlist.Add(k & "=" & System.Web.HttpUtility.UrlEncode(PR.query(k)))
                        End Select
                    Next
                    If postpage.Contains("?") Then
                        postpage &= "&" & String.Join("&", qlist.ToArray)
                    Else
                        postpage &= "?" & String.Join("&", qlist.ToArray)
                    End If
                    fileextensions = fileextensions.Replace(";", ";.").Trim(".").Trim(";").Replace(";", ",")
                ElseIf Not String.IsNullOrWhiteSpace(PR.query("TECHVALUE")) Then
                    clearvalue = CTLHTML.Html.FieldAttach.html(Dbm.jobid, PR.query("FIELD"), "", PR.query("FORMAT"), False)
                    clearvalue = clearvalue.Replace(Environment.NewLine, " ").Replace("""", "\""")
                    '--fieldid = PR.query("FIELD")
                End If
            End Using

            Return View(viewName:="uploadattach", model:=New With {.language = language, .fileextensions = fileextensions.Trim(";"), .maxsize = maxsize & "mb", .showextensions = showextensions, .postpage = postpage, .clearvalue = clearvalue, .fieldid = fieldid, .format = format, .techvalue = techValue, .virtualdirapp = strVirtualDirectory, .path = strPath, .certification_req_33215 = cert_req_33215, .GiroFirma = GiroFirma})

        End Function


        <Route("chunkupload/1.0")>
        <HttpPost()>
        Function chunkuploader(pid As String, name As String, chunk As Integer, chunks As Integer, tid As String, size As Long) As JsonResult

            Dim ret As New UploadInformations
            Dim language As String = ""

            Try
                With ret
                    If Request.Files.Count = 1 Then

                        '-- parametro da config per attivare uno stress test ( generatore automatico di N upload a fronte di un unico file caricato )
                        Dim tmpStressCount As Object = AfCommon.AppSettings.item("stressCount")
                        Dim stressCount As Integer = 0
                        If Not IsNothing(tmpStressCount) AndAlso IsNumeric(tmpStressCount) Then
                            stressCount = CInt(tmpStressCount)
                        End If

                        Dim buffer(Request.Files(0).InputStream.Length - 1) As Byte
                        Request.Files(0).InputStream.Read(buffer, 0, buffer.Length)
                        Using Dbm As New DatabaseManager(False, Nothing, "")

                            If String.IsNullOrWhiteSpace(tid) Then

                                Dim PR As AfCommon.ProxyRequestModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(pid, Dbm, Nothing, False)

                                Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                                language = Dbm.language

                                Dim format As String = PR.query("FORMAT")
                                Dim extensions As String = ""
                                If Not String.IsNullOrWhiteSpace(format) AndAlso format.Contains("EXT:") Then
                                    Dim extpart As String = format.Substring(format.IndexOf("EXT:", StringComparison.OrdinalIgnoreCase) + 4)
                                    If extpart.Contains("-") Then
                                        extpart = extpart.Substring(0, extpart.IndexOf("-", StringComparison.OrdinalIgnoreCase))
                                    End If
                                    extpart = extpart.Trim()
                                    If Not String.IsNullOrWhiteSpace(extpart) Then
                                        extensions = extpart.Replace(",", ";").Trim(";").ToUpper()
                                    End If
                                End If

                                tid = StorageManager.BlobManager.fx_prepare_upload(Dbm, pid, Request.UserHostAddress, Request.Url.AbsoluteUri, size, name, extensions)

                                Dbm.RegisterLogInfo("INIZIO_UPLOAD. NOME FILE : " & name, "/AF_WebFileManager/proxy/1.0/uploadattach", "NOME_FILE_UPLOAD", "")
                                Dbm.AppendOperation("INIZIO_UPLOAD. NOME FILE : " & name)

                                For k = 1 To stressCount
                                    StorageManager.BlobManager.fx_prepare_upload(Dbm, pid, Request.UserHostAddress, Request.Url.AbsoluteUri, size, name, extensions, tid & "_" & CStr(k))
                                Next


                            End If

                            .tid = tid

                            Dim B As StorageManager.BlobEntryModelType = StorageManager.BlobManager.fx_get_blob(tid, Dbm)

                            If Not B.status = StorageManager.BlobEntryModelType.fileStatusEnumType.Uploading Then
                                Throw New Exception("Unable to append bytes to this file")
                            ElseIf B.uploaded >= size AndAlso buffer.Length > 0 Then
                                Throw New Exception("Bytes Exceeded FileSize")
                            Else
                                StorageManager.BlobManager.fx_append_chunk_data(Dbm, B, buffer)
                            End If
                            Dim elapsed As TimeSpan = Date.Now.Subtract(B.creationdate)
                            .elapsed = TimeSpan.FromSeconds(CLng(elapsed.TotalSeconds)).ToString
                            .esit = True
                            .percentage = Format(B.uploaded * 100 / B.size, "#0.00").Replace(",", ".") & "%"
                            Dim upbyte As Double = elapsed.TotalMilliseconds / B.uploaded
                            .remaining = TimeSpan.FromSeconds(CLng(TimeSpan.FromMilliseconds(upbyte * (B.size - B.uploaded)).TotalSeconds)).ToString
                            .uploadedbytes = AfCommon.Tools.FormattingTools.bytestoHuman(B.uploaded)
                            .totalbytes = AfCommon.Tools.FormattingTools.bytestoHuman(B.size)
                            .remainingbytes = AfCommon.Tools.FormattingTools.bytestoHuman(B.size - B.uploaded)
                            .filename = name
                            .ipaddress = B.ipaddress
                            Dim Eof As Boolean = (chunk = (chunks - 1)) OrElse (chunk = 0 AndAlso chunks = 0)
                            If Eof Then
                                StorageManager.BlobManager.fx_set_upload_complete(Dbm, tid)
                            End If

                            For k = 1 To stressCount

                                Dim Bx As StorageManager.BlobEntryModelType = StorageManager.BlobManager.fx_get_blob(tid & "_" & CStr(k), Dbm)
                                StorageManager.BlobManager.fx_append_chunk_data(Dbm, Bx, buffer)

                                If Eof Then
                                    StorageManager.BlobManager.fx_set_upload_complete(Dbm, Bx.id)
                                End If

                            Next


                        End Using
                        .esit = True
                    Else
                        .esit = False
                    End If
                End With

            Catch ex As Exception
                ret.esit = False
                'ret.message = ex.Message
                If Not ConfigurationManager.AppSettings("debug") = "true"
                    ret.message = DatabaseManager.gettranslation(language, "INFO_UTENTE_ERRORE_PROCESSO") & "<br/>" & Date.Now.ToString("dd/MM/yyyy HH:mm:ss")
                Else
                    ret.message = ex.Message & vbCrLf & ex.StackTrace
                End If
            End Try

            Return Json(ret)

        End Function



        <Route("uploadservice/{fx}")>
        <HttpPost()>
        Function uploadservice(fx As String, tid As String, jobid As String, filepath As String) As JsonResult
            Dim ret As New JsonResultModelType
            Dim language As String = ""
            Try
                Select Case fx
                    Case "postprocess" '-- INSERISCE IL JOB AL COMPLETAMENTO DELL'UPLOAD ( FINITI I CHUNK )
                        Using Dbm As New DatabaseManager(False, Nothing, "")

                            Dim B As StorageManager.BlobEntryModelType = StorageManager.BlobManager.fx_get_blob(tid, Dbm)
                            Dim PR As AfCommon.ProxyRequestModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.ProxyRequestModelType)(B.pid, Dbm, Nothing)
                            Dbm.setUserInfo(PR.idPfu, PR.SessionId)
                            language = Dbm.language
                            ret.content = ServiceQueueLibrary.JobsManager.fx_enqueue(Dbm, B.creationdate, "post-upload-action", tid, Nothing, PR.idPfu, PR.SessionId)
                            Dbm.RegisterLogInfo("Upload completato, richiesto il job per lavorare il file : #" & B.filename & "# (" & B.size & ")", "/AF_WebFileManager/proxy/1.0/uploadattach")
                            ret.esit = True
                            ret.message = Dbm.translate("Post Operation Started...")

                            '-- parametro da config per attivare uno stress test ( generatore automatico di N upload a fronte di un unico file caricato )
                            Dim tmpStressCount As Object = AfCommon.AppSettings.item("stressCount")
                            Dim stressCount As Integer = 0
                            If Not IsNothing(tmpStressCount) AndAlso IsNumeric(tmpStressCount) Then

                                stressCount = CInt(tmpStressCount)

                                For k = 1 To stressCount

                                    Dim Bx As StorageManager.BlobEntryModelType = StorageManager.BlobManager.fx_get_blob(tid & "_" & CStr(k), Dbm)

                                    ServiceQueueLibrary.JobsManager.fx_enqueue(Dbm, Bx.creationdate, "post-upload-action", tid & "_" & CStr(k), Nothing, PR.idPfu, PR.SessionId)

                                Next

                            End If

                            Dbm.commit()

                        End Using
                End Select
            Catch ex As Exception
                ret.message = DatabaseManager.gettranslation(language,"INFO_UTENTE_ERRORE_PROCESSO") & "<br/>" & Date.Now.ToString("dd/MM/yyyy HH:mm:ss")
                ret.esit=False
                'ret.esit=False
                'ret.message = ex.Message '& vbCrLf & ex.StackTrace
            End Try

            Return Json(ret)
        End function
    End Class
End Namespace