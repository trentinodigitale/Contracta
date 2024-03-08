Imports CTLDB

Public Class BlobManager
    Public Shared BlobHistory As New List(Of String)
    Public shared TempHistory As New List(Of String)

    ''' <summary>
    ''' crea un file blob partendo da un file su disco
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="filepath"></param>
    ''' <param name="filename"></param>
    ''' <param name="SaveToDb"></param>
    ''' <returns></returns>
    Public Shared Function create_blob_from_file(Dbm As CTLDB.DatabaseManager, filepath As String, filename As String, SaveToDb As Boolean) As BlobEntryModelType
        Dbm.AppendOperation("Creating BLOB from file :" & filepath)
        Dim B As New BlobEntryModelType(filename)
        Using fs As New System.IO.FileStream(filepath, IO.FileMode.Open)
            B.size = fs.Length
            B.uploaded = B.size
            B.status = BlobEntryModelType.fileStatusEnumType.Complete
            fs.Seek(0, IO.SeekOrigin.Begin)
            BlobOperations.SaveToFolder(Dbm, B, fs, SaveToDb)
        End Using
        BlobManager.fx_save_blob(Dbm, B)
        Return B
    End Function

    ''' <summary>
    ''' crea un blob partendo da un campo del database
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="dr"></param>
    ''' <param name="fieldname"></param>
    ''' <param name="filename"></param>
    ''' <param name="SaveToDb"></param>
    ''' <returns></returns>
    Public Shared Function create_blob_from_dbfield(Dbm As CTLDB.DatabaseManager, dr As SqlClient.SqlDataReader, fieldname As String, filename As String, SaveToDb As Boolean) As BlobEntryModelType
        Dim tempfile As String = CTLDB.DatabaseManager.GetTempFileName
        Dbm.AppendOperation("Creating BLOB from Db Field :" & fieldname)
        Dim size As Long = CTLDB.DbUtils.saveFileFromRecordSet(Dbm, dr, fieldname, tempfile, "")
        Dim RET As BlobEntryModelType = create_blob_from_file(Dbm, tempfile, filename, SaveToDb)
        My.Computer.FileSystem.DeleteFile(tempfile)
        Return RET
    End Function
    ''' <summary>
    ''' Prepara il blob per un processo di upload
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="pid"></param>
    ''' <param name="ipaddress"></param>
    ''' <param name="requesturl"></param>
    ''' <param name="filesize"></param>
    ''' <param name="filename"></param>
    ''' <param name="extensions"></param>
    ''' <returns></returns>
    Public Shared Function fx_prepare_upload(Dbm As DatabaseManager, pid As String, ipaddress As String, requesturl As String, filesize As Long, filename As String, extensions As String, Optional id As String = "",Optional byref BI As BlobEntryModelType = Nothing) As String
        'VERIFICA SE L'ESTENSIONE E' AMMESSA
        BI = Nothing
        'Dim ext As String = New System.IO.FileInfo(filename).Extension.Trim.ToLower.Trim(".")
        Dim ext As String = StorageManager.BlobEntryModelType.getExtension(filename).Trim.ToLower.Trim(".")

        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select DZT_ValueDef from LIB_Dictionary where DZT_Name = 'SYS_ESTENSIONI_UPLOAD'", Nothing)
            If dr.Read Then
                Dim fileextensions As String = dr("DZT_ValueDef")
                Dim HTA As New Hashtable
                For Each fe As String In fileextensions.Trim.Split(";")
                    HTA(fe.Trim.ToLower.Trim(".")) = True
                Next
                If Not HTA.ContainsKey(ext) Then Throw New Exception("Estensione non ammessa per """ & ext & """")
                If Not String.IsNullOrWhiteSpace(extensions) Then
                    Dim HTE As New Hashtable
                    For Each fe As String In extensions.Trim.Split(";")
                        HTE(fe.Trim.ToLower.Trim(".")) = True
                    Next
                    If Not HTE.ContainsKey(ext) Then Throw New Exception("Estensione non ammessa per """ & ext & """")
                End If
            End If
        End Using

        Dim maxsizeMB As Long

        Try

            Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select DZT_ValueDef from LIB_Dictionary where DZT_Name = 'SYS_MAX_SIZE_ATTACH'", Nothing)
                If dr.Read Then
                    maxsizeMB = CLng(dr("DZT_ValueDef"))
                End If
            End Using

        Catch ex As Exception
            maxsizeMB = 1024
        End Try

        Dim maxsizeByte As Long = maxsizeMB * (1024 * 1024)

        If filesize > maxsizeByte Then
            'Throw New Exception("La dimensione del file eccede la dimensione massima consentita di " & AfCommon.Tools.FormattingTools.bytestoHuman(maxsizeByte))
            Dbm.RunException("La dimensione del file supera il massimo consentito~YES_ML", Nothing)
        End If

        If String.IsNullOrWhiteSpace(id) Then
            id = AfCommon.Tools.getrandomid
        End If

        BI = New BlobEntryModelType(filename) With {.id = id, .pid = pid, .size = filesize, .ipaddress = ipaddress, .status = BlobEntryModelType.fileStatusEnumType.Uploading}
        CTLDB.DbClassTools.fx_save_instance(BI, Dbm)
        Return BI.id
    End Function

    Public Shared function fx_append_large_file_data(Dbm As DatabaseManager, tid As String, filepath As String) As BlobEntryModelType
        'Chunkize FILE AT 10MB Each
        Dim UPB As StorageManager.BlobEntryModelType = StorageManager.BlobManager.fx_get_blob(tid, Dbm)
        Dim ReadBuffer(10 * 1024 * 1024) as Byte
        Using fs As New System.IO.FileStream(filepath, System.IO.FileMode.Open, System.IO.FileAccess.Read)
            fs.Seek(0, IO.SeekOrigin.Begin)
            Dim bytesread As Integer = fs.Read(ReadBuffer, 0, ReadBuffer.Length)
            While bytesread > 0
                Dim buffer As Byte() = Nothing
                Using ms As New System.IO.MemoryStream
                    ms.Write(ReadBuffer, 0, bytesread)
                    buffer = ms.ToArray
                End Using
                'SALVA IL FILE NEL DB E ATTIVA IL PROCESSO DI ELABORAZIONE
                If Not UPB.status = StorageManager.BlobEntryModelType.fileStatusEnumType.Uploading Then
                    Throw New Exception("Unable to append bytes to this file")
                ElseIf UPB.uploaded >= fs.Length AndAlso buffer.Length > 0 Then
                    Throw New Exception("Bytes Exceeded FileSize")
                Else
                    fx_append_chunk_data(Dbm, UPB, buffer)
                End If
                bytesread = fs.Read(ReadBuffer, 0, ReadBuffer.Length)
            End While
            StorageManager.BlobManager.fx_set_upload_complete(Dbm, tid)
        End Using
        Return BlobManager.fx_get_blob(UPB.id, Dbm)

    End function

    ''' <summary>
    ''' Accoda il chunk nel database
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="data"></param>
    Public Shared Sub fx_append_chunk_data(Dbm As DatabaseManager, ByRef B As BlobEntryModelType, data As Byte())
        'GET LAST PART
        Dim tablepartname As String = DbClassTools.GetTableName(GetType(BlobChunkEntryModelType))
        DbClassTools.fx_save_instance(New BlobChunkEntryModelType("", 0, Nothing), Dbm, False)
        Dim sql As String = "SELECT Top 1 [position] FROM [" & tablepartname & "] with(nolock) WHERE [blobid] = @blobid Order by [position] DESC"
        Dim position As Integer = -1
        Dim params As New Hashtable
        params("@blobid") = B.id
        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(sql, params)
            If dr.Read Then
                position = dr("position")
            End If
        End Using
        Dim QP As New BlobChunkEntryModelType(B.id, position + 1, data)
        DbClassTools.fx_save_instance(QP, Dbm)
        B.uploaded += data.Length
        params("@uploaded") = B.uploaded
        Dbm.ExecuteNonQuery("UPDATE [" & DbClassTools.GetTableName(B.GetType) & "] SET [uploaded] = @uploaded  WHERE [id] = @blobid", params)
    End Sub
    ''' <summary>
    ''' Restituisce un blob salvato
    ''' </summary>
    ''' <param name="id"></param>
    ''' <param name="Dbm"></param>
    ''' <returns></returns>
    Public Shared Function fx_get_blob(id As String, Dbm As DatabaseManager) As BlobEntryModelType
        Return DbClassTools.fx_get_instance(Of BlobEntryModelType)(id, Dbm, New String() {"data"}, True, withNoLock:=True)
    End Function
    ''' <summary>
    ''' salva un blob o aggiorna uno esistente
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="Fullsave"></param>
    Public Shared Sub fx_save_blob(Dbm As CTLDB.DatabaseManager, ByRef B As BlobEntryModelType, Optional Fullsave As Boolean = False, Optional DO_UPDATE As Boolean = True)
        If Fullsave Then
            CTLDB.DbClassTools.fx_save_instance(B, Dbm, "", DO_UPDATE:=DO_UPDATE)
        Else
            CTLDB.DbClassTools.fx_update_instance(Of BlobEntryModelType)(B, B.id, Nothing, Dbm, New String() {"data"})
        End If
        If Not BlobHistory.Contains(B.id) Then
            BlobHistory.Add(B.id)
        End If
    End Sub

    ''' <summary>
    ''' imposta il processo di upload di un blob completo
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="tid"></param>
    Public Shared Sub fx_set_upload_complete(Dbm As DatabaseManager, tid As String)
        Dim params As New Hashtable
        params("@blobid") = tid
        params("@status") = CInt(BlobEntryModelType.fileStatusEnumType.UploadComplete)
        Dbm.ExecuteNonQuery("UPDATE [" & DbClassTools.GetTableName(GetType(BlobEntryModelType)) & "] SET status = @status WHERE [id] = @blobid", params)
    End Sub


    ''' <summary>
    ''' elimina un blob e il suo corrispondente file su disco
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="id"></param>
    Public Shared Sub fx_delete_blob(Dbm As CTLDB.DatabaseManager, id As String)
        Dim folder As String = AfCommon.AppSettings.item("PathBlobsEntry").Trim("\").Trim("/")
        If Not My.Computer.FileSystem.DirectoryExists(folder) Then My.Computer.FileSystem.CreateDirectory(folder)
        Dim archivefile As String = folder & "\" & id & ".zip"
        If My.Computer.FileSystem.FileExists(archivefile) Then
            My.Computer.FileSystem.DeleteFile(archivefile)
        End If
        Dim table_blobs As String = DbClassTools.GetTableName(GetType(BlobEntryModelType))
        Dim params As New Hashtable

        Dim remove_file_from_table As String
        remove_file_from_table = "YES"

        If UCase(AfCommon.AppSettings.item("remove_file_from_table")) = "NO" Then
            remove_file_from_table = "NO"
        End If
        If remove_file_from_table = "YES" Then
            params("@id") = id
            Dbm.ExecuteNonQuery("DELETE FROM [" & table_blobs & "] WHERE id = @id", params)
        End If

    End Sub


    ''' <summary>
    ''' elimina un Blob, il suo file su disco e tutti i file temporanei che sono stati creati durante il processo
    ''' </summary>
    ''' <param name="Dbm"></param>
    Public Shared Sub fx_purge_blob_history(Dbm As CTLDB.DatabaseManager)
        While BlobHistory.Count > 0
            fx_delete_blob(Dbm, BlobHistory(0))
            BlobHistory.RemoveAt(0)
        End While
        While TempHistory.Count > 0
            Dim start As DateTime = Date.Now
            While Date.Now.Subtract(start).TotalMinutes < 1
                Try
                    Dim file As String = TempHistory(0)
                    If My.Computer.FileSystem.FileExists(file) Then My.Computer.FileSystem.DeleteFile(file)
                    Exit While
                Catch ex As Exception
                    System.Threading.Thread.Sleep(5)
                End Try
            End While
            TempHistory.RemoveAt(0)
        End While
    End Sub

    ''' <summary>
    ''' Imdica un id di blob da non cancellare nel purge
    ''' </summary>
    ''' <param name="id"></param>
    Public Shared Sub PreseveBlob(id As String)
        If BlobHistory.Contains(id) Then
            BlobHistory.Remove(id)
        End If
    End Sub


    ''' <summary>
    ''' calcola i vari hash partendo da un blob
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    Public Shared Sub fx_calculate_hash(jobid As String, ByRef B As BlobEntryModelType, Optional throwException As Boolean = True)

        Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

            Try


                Dim ClearFile As String = GetPureFileOnDisk(Dbm, B, True)
                Using fs As New System.IO.FileStream(ClearFile, IO.FileMode.Open, IO.FileAccess.Read, IO.FileShare.None)
                    B.SetHash(AfCommon.Tools.SHA_Algorithm.MD5, AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.MD5))
                    fs.Seek(0, IO.SeekOrigin.Begin)
                    B.SetHash(AfCommon.Tools.SHA_Algorithm.SHA1, AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA1))
                    fs.Seek(0, IO.SeekOrigin.Begin)
                    B.SetHash(AfCommon.Tools.SHA_Algorithm.SHA256, AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA256))
                    fs.Seek(0, IO.SeekOrigin.Begin)
                    B.SetHash(AfCommon.Tools.SHA_Algorithm.SHA384, AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA384))
                    fs.Seek(0, IO.SeekOrigin.Begin)
                    B.SetHash(AfCommon.Tools.SHA_Algorithm.SHA512, AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA512))
                End Using

                My.Computer.FileSystem.DeleteFile(ClearFile)
                BlobManager.fx_save_blob(Dbm, B)

            Catch ex As Exception

                Dbm.TraceDB("Errore nella generazione dell'hash binario del file. " & ex.Message, "BlocManager.fx_calculate_hash")

                '-- se throwException è passato a false non facciamo risalire l'errore di generazione hash ( caso di format "J" per saltare i controlli sul file )
                If throwException Then
                    Throw ex
                End If

            End Try

        End Using



    End Sub


    ''' <summary>
    ''' crea una copa sul disco (in chiaro) di un BLOB
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="blobid"></param>
    ''' <param name="RemoveOnExit"></param>
    ''' <returns></returns>
    Public Shared Function GetPureFileOnDisk(Dbm As CTLDB.DatabaseManager, blobid As String, RemoveOnExit As Boolean) As String
        Dim B As BlobEntryModelType = fx_get_blob(blobid, Dbm)
        Return BlobOperations.GetPureFileOnDisk(Dbm, B, RemoveOnExit)
    End Function
    ''' <summary>
    ''' crea una copa sul disco (in chiaro) di un BLOB
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="RemoveOnExit"></param>
    ''' <returns></returns>
    Public Shared Function GetPureFileOnDisk(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, RemoveOnExit As Boolean) As String
        Return BlobOperations.GetPureFileOnDisk(Dbm, B, RemoveOnExit)
    End Function


    ''' <summary>
    ''' estra i bytes in chiaro da un blob
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <returns></returns>
    Public Shared Function GetPureBytes(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType) As Byte()
        Dim buffer As Byte() = Nothing
        Dim ClearFile As String = GetPureFileOnDisk(Dbm, B, True)
        buffer = My.Computer.FileSystem.ReadAllBytes(ClearFile)
        My.Computer.FileSystem.DeleteFile(ClearFile)
        Return buffer
    End Function


    ''' <summary>
    ''' Crea una copia Criptata di un BLOB
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="encryptionkey"></param>
    ''' <param name="SaveToDb"></param>
    ''' <returns></returns>
    Public Shared Function Get_Encrypted_Blob_Copy(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, encryptionkey As String, SaveToDb As Boolean) As BlobEntryModelType
        Dim clearSourceFile As String = GetPureFileOnDisk(Dbm, B, True)
        Dim EM As New AfCommon.Tools.EncryptionTools.EncryptionManager(encryptionkey)
        Dim tf As String = CTLDB.DatabaseManager.GetTempFileName
        EM.EncryptFile(clearSourceFile, tf)
        My.Computer.FileSystem.DeleteFile(clearSourceFile)
        Dim NBE As New BlobEntryModelType(B.filename)
        Dim first As Boolean = True
        Using fs As New System.IO.FileStream(tf, IO.FileMode.Open)
            NBE.size = fs.Length
            NBE.uploaded = NBE.size
            BlobOperations.SaveToFolder(Dbm, NBE, fs, SaveToDb)
        End Using
        My.Computer.FileSystem.DeleteFile(tf)
        fx_calculate_hash(Dbm.jobid, NBE)
        Return NBE
    End Function


    ''' <summary>
    ''' crea una copia decriptata di un blob
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="encryptionkey"></param>
    ''' <param name="SaveToDb"></param>
    ''' <returns></returns>
    Public Shared Function Get_Decrypted_Blob_Copy(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, encryptionkey As String, SaveToDb As Boolean) As BlobEntryModelType
        Dim clearSourceFile As String = GetPureFileOnDisk(Dbm, B, True)
        Dim EM As New AfCommon.Tools.EncryptionTools.EncryptionManager(encryptionkey)
        Dim tf As String = CTLDB.DatabaseManager.GetTempFileName
        EM.Decrypt(clearSourceFile, tf)
        My.Computer.FileSystem.DeleteFile(clearSourceFile)
        Dim NBE As New BlobEntryModelType(B.filename)
        Dim buffer(10 * 1024 * 1024) As Byte
        Dim first As Boolean = True
        Using fs As New System.IO.FileStream(tf, IO.FileMode.Open)
            NBE.size = fs.Length
            NBE.uploaded = NBE.size
            BlobOperations.SaveToFolder(Dbm, NBE, fs, SaveToDb)
        End Using
        My.Computer.FileSystem.DeleteFile(tf)
        fx_calculate_hash(Dbm.jobid, NBE)
        Return NBE
    End Function



    Private Shared TR_PURGER As System.Threading.Thread = Nothing
    Private Shared last_purge As DateTime? = Nothing
    Public Shared exitNow As Boolean = False

    ''' <summary>
    ''' inizializza il processo di pulizia di tutti i files inutilizzati e temporanei residui dei processi
    ''' </summary>
    Public Shared Sub fx_init_purger()
        If IsNothing(TR_PURGER) OrElse Not TR_PURGER.IsAlive Then
            last_purge = Nothing
            TR_PURGER = New Threading.Thread(AddressOf fx_do_purgefiles)
            TR_PURGER.Start()
        End If
    End Sub

    Private Shared Sub fx_do_purgefiles()

        While Not exitNow

            'Console.WriteLine("checking files to purge")

            Dim purge_interval_minutes As Integer = 15

            Try
                purge_interval_minutes = CInt(AfCommon.AppSettings.item("app.purgeinterval"))
            Catch ex As Exception
            End Try

            If Not last_purge.HasValue OrElse Date.Now.Subtract(last_purge.Value).TotalMinutes > purge_interval_minutes Then
                Dim purged As Long = 0
                Dim PurgException As Exception = Nothing
                Using dbm As New CTLDB.DatabaseManager(False, Nothing)
                    Try
                        dbm.AppendOperation("Lettura Parametri dal file di configurazione")
                        Dim purge_age_minutes As Integer = AfCommon.AppSettings.item("app.purgeage")
                        Dim params As New Hashtable
                        params("@purge_age") = purge_age_minutes

                        'DELETE ORPHANED CHUNKS
                        dbm.AppendOperation("Cancellazione Orphaned chunks")
                        Dim chunks_table As String = CTLDB.DbClassTools.GetTableName(GetType(StorageManager.BlobChunkEntryModelType), dbm, True)
                        purged += dbm.ExecuteNonQuery("DELETE FROM [" & chunks_table & "] WHERE creationdate <= DATEADD(MINUTE,-@purge_age,GETDATE())", params)

                        'DELETE OLD BLOB FILES
                        dbm.AppendOperation("Cancellazione Vecchi Blobs")
                        Dim blobstable As String = CTLDB.DbClassTools.GetTableName(GetType(StorageManager.BlobEntryModelType), dbm, True)
                        Using dr As SqlClient.SqlDataReader = dbm.ExecuteReader("SELECT Id FROM [" & blobstable & "] with(nolock) WHERE creationdate <= DATEADD(MINUTE,-@purge_age,GETDATE())", params)
                            While dr.Read

                                Using dbmUpd As New CTLDB.DatabaseManager(False, Nothing)

                                    Try
                                        dbmUpd.AppendOperation(vbTab & "Cancellazione BlobId :" & dr("id"))
                                        fx_delete_blob(dbmUpd, dr("id"))
                                        purged += 1
                                    Catch ex As Exception
                                        dbmUpd.AppendOperation(vbTab & "Cancellazione Fallita :" & dr("id"))
                                        PurgException = ex
                                    End Try

                                End Using

                            End While
                        End Using

                        'DELETE OLD FILES ON DISK
                        Dim folder As String = AfCommon.AppSettings.item("PathBlobsEntry").Trim("\").Trim("/")
                        dbm.AppendOperation("Cancellazione File nella directory :" & folder)


                        For Each file As String In My.Computer.FileSystem.GetFiles(folder, FileIO.SearchOption.SearchAllSubDirectories, "*.*")
                            Try
                                dbm.AppendOperation(vbTab & "Verifica Cancellazione File : " & file)
                                Dim FI As New System.IO.FileInfo(file)
                                Dim name As String = FI.Name
                                If Not String.IsNullOrWhiteSpace(FI.Extension) Then
                                    name = name.Substring(0, name.Length - FI.Extension.Length)
                                End If
                                Dim filedate As DateTime? = AfCommon.Tools.randomid_to_date(name)
                                If filedate.HasValue AndAlso filedate.Value <= Date.Now.AddMinutes(-purge_age_minutes) Then
                                    dbm.AppendOperation(vbTab & "Esecuzione Cancellazione File : " & file)
                                    My.Computer.FileSystem.DeleteFile(file)
                                    purged += 1
                                End If
                            Catch ex As Exception
                                dbm.AppendOperation("Errore Cancellazione File :" & file)
                                PurgException = ex
                            End Try
                        Next
                        If Not PurgException Is Nothing Then
                            Throw PurgException
                        End If

                    Catch ex As Exception
                        dbm.traceError(ex, True)
                        Console.ForegroundColor = ConsoleColor.Red
                        Console.WriteLine(ex.Message)
                        Console.ResetColor()
                    End Try

                    Try

                        '-- pulizia delle tabelle di lavoro
                        Dim strsql As String = "EXEC GARBAGE_COLLECTOR 'ATTACH_64'"
                        dbm.ExecuteNonQuery(strsql, Nothing)

                    Catch ex As Exception

                    End Try

                End Using
                last_purge = Date.Now
                If purged > 0 Then
                    Console.WriteLine("Cleared " & purged & " files")
                End If
            End If

            System.Threading.Thread.Sleep(60 * 1000)

        End While
    End Sub

End Class
