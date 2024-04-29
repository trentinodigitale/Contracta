Imports CTLDB
Imports StorageManager

Public Class FileQueueManager
    ''' <summary>
    ''' Completamento del processo di Upload con la sola composizione di un unico files che è l'aggregazione dei chunks Caricati e calcolo degli HASH
    ''' </summary>
    ''' <param name="sourceDbm"></param>
    ''' <param name="B"></param>
    Public Shared Sub fx_complete_upload_process(jobid As String, ByRef B As BlobEntryModelType, query As Hashtable, sourceDbm As CTLDB.DatabaseManager)

        Dim main_tablename As String = DbClassTools.GetTableName(GetType(BlobEntryModelType))
        Dim parts_tablename As String = DbClassTools.GetTableName(GetType(BlobChunkEntryModelType))

        Dim params As New Hashtable
        params("@blobid") = B.id

        Try
            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                'BUILD ENTIRE DATA FROM PARTS
                Select Case B.status
                    Case BlobEntryModelType.fileStatusEnumType.UploadComplete
                        If Not B.uploaded = B.size Then Dbm.RunException("Upload Incomplete~YES_ML", New Exception("Upload Incomplete"))
                        Dim partscounter As Integer = 0
                        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT COUNT(id) as items FROM [" & parts_tablename & "] with(nolock) WHERE [blobid] = @blobid", params)
                            If dr.Read Then
                                partscounter = dr("items")
                            End If
                        End Using
                        If partscounter > 0 Then
                            'CLEAR DATA FIELD
                            Dim First As Boolean = True
                            'BUILD DATA FIELD FROM CHUNK LIST
                            Dim tf As String = CTLDB.DatabaseManager.GetTempFileName()



                            Using DbmUpdate As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)


                                Try

                                    Using fs As New System.IO.FileStream(tf, IO.FileMode.OpenOrCreate)

                                        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT * FROM [" & parts_tablename & "] with(nolock)  WHERE [blobid] = @blobid ORDER BY [position] ASC", params)
                                            While dr.Read
                                                Dim data As Byte() = dr("data")
                                                Dim position As Integer = dr("position")
                                                fs.Write(data, 0, data.Length)
                                                Dim percentage As Double = ((position + 1) * 100 / partscounter)
                                                DbmUpdate.fx_update_queue_operation("Composing File", percentage, , False)
                                            End While
                                        End Using

                                        Dim verificaExt As String = "NotVerified"

                                        Try

                                            '--- VERIFICHIAMO IL CONTENUTO DEL FILE RISPETTO ALL'ESTENSIONE
                                            Dim inspector = New FileSignatures.FileFormatInspector()
                                            Dim Format = inspector.DetermineFileFormat(fs)

                                            Dim FileFormat_ok = LCase(AfCommon.AppSettings.item("FileFormat"))

                                            ''--VEIRIFICHIAMO SE NEL FILE DI CONFIGURAZIONE E' PRESENTE L'ELENCO DELLE ESTENSIONI VALIDE
                                            ''--ALTRIMENTI FA QUELLLO CHE FA ORA kpf 434749
                                            ''--SE LA LIB TERZA NON HA VERIFICATO IL CONTENUTO VEDE SE RIENTRA TRA LE
                                            ''--ESTENSIONI AMMESSE ED IN QUEL CASO DIAMO NOMATCH
                                            If IsNothing(Format) Then

                                                If FileFormat_ok <> "" And FileFormat_ok.Contains("~") Then

                                                    Dim Index As Integer = -1
                                                    Dim vet() As String = FileFormat_ok.Trim.Split("~")

                                                    Index = Array.IndexOf(vet, B.extension.Trim(".").ToLower)
                                                    If Index > -1 Then
                                                        verificaExt = "NoMatch"
                                                    Else
                                                        verificaExt = "NotSupported"
                                                    End If
                                                Else
                                                    verificaExt = "NotSupported"
                                                End If

                                            Else

                                                If Format.Extension.ToLower.Equals(B.extension.Trim(".").ToLower) Then
                                                    verificaExt = "Verified"
                                                Else
                                                    verificaExt = "NoMatch"
                                                End If

                                            End If

                                        Catch ex As Exception
                                            verificaExt = "NotVerified"
                                        End Try


                                        DbmUpdate.fx_update_queue_operation("Storing File", 0)
                                        StorageManager.BlobOperations.SaveToFolder(Dbm, B, fs, True)

                                        ''--se l'estensione è un P7M utilizzo chillKAT per verificarne il contenuto
                                        If B.extension.Trim(".").ToLower = "p7m" Then

                                            '--chiamo la ExtractP7M per capire se il file P7M è valido
                                            Dim PDF_FILE As BlobEntryModelType = Nothing

                                            Using Dbm2 As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                                                '--se non iresco a sbustare va in eccezione 
                                                '--allora lo gestisco con un try catch
                                                Try
                                                    Call Dbm2.TraceDB("FILE P7M. Verifica estensione e contenuto", "fx_complete_upload_process")
                                                    Dbm2.AppendOperation("Rimuovo l'envelope P7M dal file firmato")
                                                    PDF_FILE = PdfLibrary.PdfUtils.ExtractP7M(Dbm2, B, False)

                                                    If IsNothing(PDF_FILE) Then
                                                        verificaExt = "NoMatch"
                                                    Else
                                                        verificaExt = "Verified"
                                                    End If

                                                Catch ex As Exception
                                                    verificaExt = "NoMatch"
                                                End Try

                                            End Using

                                        End If

                                        B._verificaEstensione = verificaExt

                                    End Using


                                Catch ex As Exception
                                    Dbm.RunException(ex.Message, ex)
                                Finally
                                    If My.Computer.FileSystem.FileExists(tf) Then
                                        My.Computer.FileSystem.DeleteFile(tf)
                                    End If
                                End Try

                            End Using



                            B.status = BlobEntryModelType.fileStatusEnumType.Complete
                            Dim fields As New Hashtable
                            fields("blobid") = B.id
                            fields("status") = Int(B.status)
                            CTLDB.DbClassTools.fx_update_instance(Of BlobEntryModelType)(B, B.id, fields, Dbm, Nothing)
                            'REMOVE FILES
                            Dbm.ExecuteNonQuery("DELETE FROM [" & parts_tablename & "] WHERE [blobid] = @blobid", params)
                            BlobManager.fx_save_blob(Dbm, B)
                        End If
                End Select

            End Using


            Dim NeedHash As Boolean = IsNothing(B.hashlist) OrElse B.hashlist.Trim.Split(".").Length < 5
            If NeedHash Then

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                    Dbm.fx_update_queue_operation("Calculating File HASH...", 0)

                End Using

                '-- invochiamo la funzione per calcolare gli hash di checksum sul file. a meno che non c'è la format a J, in caso di errore risale un exception
                StorageManager.BlobManager.fx_calculate_hash(jobid, B, Not query("FORMAT").ToString.ToUpper.Contains("J"))

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                    Dbm.RegisterLogInfo(B.GetHashPart(AfCommon.Tools.SHA_Algorithm.SHA256), "/AF_WebFileManager/proxy/1.0/uploadattach", "Calcolo hash binario completato", "HASH")
                    Dbm.fx_update_queue_operation("Calculating File HASH Complete : " & B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA256), 100)
                End Using


            End If

            Dim outputvariables As New Hashtable

            outputvariables("HASH MD5") = B.GetHash(AfCommon.Tools.SHA_Algorithm.MD5)
            outputvariables("HASH SHA1") = B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA1)
            outputvariables("HASH SHA256") = B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA256)
            outputvariables("HASH SHA384") = B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA384)
            outputvariables("HASH SHA512") = B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA512)

            outputvariables("PDF HASH") = B.pdfhash

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                Dbm.fx_update_queue_operation("Write Output Variables", 100, outputvariables)
            End Using


        Catch ex As Exception

            params = New Hashtable
            params("@tid") = B.id
            params("@message") = "ECCEZIONE:" & ex.Message & vbCrLf & ex.StackTrace
            params("@status") = Int(BlobEntryModelType.fileStatusEnumType.Failed)

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                Dbm.ExecuteNonQuery("UPDATE [" & main_tablename & "] SET [status] = @status, [message] = @message WHERE [id] = @tid", params)
            End Using

        End Try

    End Sub

End Class
