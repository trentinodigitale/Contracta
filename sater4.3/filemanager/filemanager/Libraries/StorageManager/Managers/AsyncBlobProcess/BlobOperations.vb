Imports DbManager

Public Class BlobOperations


    Private shared readonly property archivepassword As String = "FDSAK)$£$KK$£!!£"

    ''' <summary>
    ''' funzione acessaria del BlobManager che crea un blob da uno stream in un file su disco zippato con password ed eventualmente lo salva nel DB dei Blobs
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="stream"></param>
    ''' <param name="SaveToDb"></param>
    Public shared sub SaveToFolder(Dbm As CTLDB.DatabaseManager, byref B As BlobEntryModelType, stream As System.IO.Stream,SaveToDb As Boolean)
        Dim folder As String = AfCommon.AppSettings.item("PathBlobsEntry").Trim("\").Trim("/")
        If Not My.Computer.FileSystem.DirectoryExists(folder) Then My.Computer.FileSystem.CreateDirectory(folder)
        Dim archivefile As String = folder & "\" & B.id & ".zip"
        B.data = Nothing
        If SaveToDb
            If IsNothing(BlobManager.fx_get_blob(B.id,Dbm))                
                CTLDB.DbClassTools.fx_save_instance(B,Dbm)
            End If
            stream.Seek(0,IO.SeekOrigin.Begin)
            Dim table As String = CTLDB.DbClassTools.GetTableName(GetType(BlobEntryModelType))
            Dim params As New Hashtable
            params("@id") = B.id
            params("@data") = New Byte(){}
            Dbm.ExecuteNonQuery("UPDATE [" & table & "] SET [data] = @data WHERE id = @id",params)
            Dim buffer(10 * 1024 * 1024) As Byte
            Dim bytesread As Long = stream.Read(buffer, 0, buffer.Length)
            While bytesread > 0
                Dim percentage As Double = stream.Position * 100 / stream.Length
                Dbm.fx_update_queue_operation("Storing Bytes to Database" , percentage)
                If bytesread = buffer.Length
                    params("@data") = buffer                    
                Else
                    Using ms As New System.IO.MemoryStream
                        ms.Write(buffer, 0, bytesread)
                        params("@data") = ms.ToArray
                    End Using
                End If
                Dbm.ExecuteNonQuery("UPDATE [" & table & "] SET [data] = [data] + @data WHERE id = @id",params)
                bytesread = stream.Read(buffer, 0, buffer.Length)
            End While
        End If
        stream.Seek(0,IO.SeekOrigin.Begin)
        If Not My.Computer.FileSystem.FileExists(archivefile)
            Using fs As New System.IO.FileStream(archivefile, IO.FileMode.Create)
                Using Z As New Ionic.Zip.ZipFile()
                    Z.Password = archivepassword
                    Z.AddEntry(B.id,stream)
                    Z.Save(fs)
                End Using
            End Using
        Else
            Using Z As Ionic.Zip.ZipFile = Ionic.Zip.ZipFile.Read(archivefile)
                Z.Password = archivepassword
                Z.AddEntry(B.id,stream)
                Z.Save()
            End Using
        End If
        If SaveToDb Then
            BlobManager.fx_save_blob(Dbm, B, False)           'l'elemento va aggiornato ma non salvato interamente
        Else
            BlobManager.fx_save_blob(Dbm, B, True, False)            'l'elemento non esiste va salvato per intero
        End If        
    End sub
    ''' <summary>
    ''' Restituisce una copia in chiaro del file leggendo in primis dal filesysteme e, se non presente, dal database
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="RemoveOnExit"></param>
    ''' <returns></returns>
    Public Shared Function GetPureFileOnDisk(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, RemoveOnExit As Boolean) As String

        Dim folder As String = AfCommon.AppSettings.item("PathBlobsEntry").Trim("\").Trim("/")
        If Not My.Computer.FileSystem.DirectoryExists(folder) Then My.Computer.FileSystem.CreateDirectory(folder)
        Dim archivefile As String = folder & "\" & B.id & ".zip"

        Dbm.AppendOperation("GetPureFileOnDisk")
        If My.Computer.FileSystem.FileExists(archivefile) Then
            Dbm.AppendOperation("GetPureFileOnDisk ha trovato il file: " & archivefile)
            Try

                Using Z As Ionic.Zip.ZipFile = Ionic.Zip.ZipFile.Read(archivefile)

                    Z.Password = archivepassword
                    Dim tf As String = CTLDB.DatabaseManager.GetTempFileName
                    Using fs As New System.IO.FileStream(tf, IO.FileMode.OpenOrCreate)
                        Z.Item(B.id).Extract(fs)
                    End Using
                    If RemoveOnExit Then
                        BlobManager.TempHistory.Add(tf)
                    End If

                    Return tf

                End Using

            Catch ex As Exception

                '-- se va in errore la lettura del file dal disco locale
                Try
                    Dbm.AppendOperation("GetPureFileOnDisk: va in errore la lettura del file dal disco locale -  file: " & archivefile)
                    My.Computer.FileSystem.DeleteFile(archivefile)
                Catch ex2 As Exception
                End Try

            End Try

        End If

        '-- se arriviamo qui vuol dire che O non c'è il file OPPURE è corretto e quindi è fallita la sua read

        'GET FROM BUFFER
        Dim params As New Hashtable

        params("@id") = B.id
        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT [data] FROM [" & CTLDB.DbClassTools.GetTableName(GetType(BlobEntryModelType)) & "] with(nolock) WHERE id = @id", params)
            If dr.Read Then

                If Not IsDBNull(dr("data")) Then
                    Dim tf As String = CTLDB.DatabaseManager.GetTempFileName
                    CTLDB.DbUtils.saveFileFromRecordSet(Dbm, dr, "data", tf, B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA256))
                    Using fs As New System.IO.FileStream(tf, IO.FileMode.Open)
                        SaveToFolder(Dbm, B, fs, False)
                    End Using
                    BlobManager.TempHistory.Add(tf)
                    Return tf
                End If
            End If
        End Using

        Dbm.RunException("File Not Found for " & B.id, New Exception("File Not Found for " & B.id))
        Return Nothing

    End Function
End Class





