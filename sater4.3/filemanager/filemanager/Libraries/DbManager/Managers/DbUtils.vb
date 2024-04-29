Public Class DbUtils
    Public Shared function saveFileFromRecordSet(Dbm As DbManager.DatabaseManager, dr As SqlClient.SqlDataReader,fieldname As String,targetfile As String,currenthash As String) as long
        Dim filesize As Long = 0
        Dim columns As New Hashtable
        For cnpos As Integer = 0 To dr.FieldCount -1
            Dim name As String = dr.GetName(cnpos)
            columns(name.Trim.ToLower) = cnpos
        Next
        If My.Computer.FileSystem.FileExists(targetfile) Then My.Computer.FileSystem.DeleteFile(targetfile)
        Dim colindex As Integer = columns(fieldname.Trim.ToLower)
        'GET SIZE

        dim readindex as Integer = 0
        Dim buffer((10 * 1024 * 1024) - 1) as Byte
        Dim bytesread As Integer = dr.GetBytes(colindex,readindex,Buffer,0,buffer.Length)
        While bytesread > 0
            Using ms As New System.IO.MemoryStream
                ms.Write(buffer,0,bytesread)
                My.Computer.FileSystem.WriteAllBytes(targetfile,ms.ToArray,True)
            End Using
            readindex += bytesread
            Dbm.AppendOperation("Reading Bytes from Db Field :" & fieldname & " ==> " & AfCommon.Tools.FormattingTools.bytestoHuman(readindex))
            bytesread = dr.GetBytes(colindex,readindex,Buffer,0,buffer.Length)
            Dbm.fx_update_queue_operation("Retrieving Bytes from Record " & AfCommon.Tools.FormattingTools.bytestoHuman(readindex),50)
        End While
        filesize = readindex
        If Not String.IsNullOrWhiteSpace(currenthash)
            Dbm.AppendOperation("Verifico l'hash del file creato per verificare la conformità con quello esistente")
            Using fs As New System.IO.FileStream(targetfile,IO.FileMode.Open,IO.FileAccess.Read)
                If currenthash.Contains(":")
                    Dim s As String() = currenthash.Trim.Split(":")
                    Select Case s(0)
                        Case "SHA1"
                            if Not AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA1) = currenthash
                                Dbm.RunException("Hash non corrispondente")
                            End If
                        Case "SHA256"
                            if Not AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA256) = currenthash
                                Dbm.RunException("Hash non corrispondente")
                            End If
                        Case "SHA384"
                            if Not AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA384) = currenthash
                                Dbm.RunException("Hash non corrispondente")
                            End If
                        Case "SHA512"
                            if Not AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA512) = currenthash
                                Dbm.RunException("Hash non corrispondente")
                            End If
                        Case Else
                            Dbm.RunException("Algoritmo non riconosciuto: " & s(0))
                    End Select
                Else
                    if Not AfCommon.Tools.HashTools.GetHASHBytesToString(fs, AfCommon.Tools.SHA_Algorithm.SHA256).Trim.Split(":")(1) = currenthash
                        Dbm.RunException("Hash non corrispondente")
                    End If
                End If
            End Using
        End If
        Return filesize
    End function
End Class
