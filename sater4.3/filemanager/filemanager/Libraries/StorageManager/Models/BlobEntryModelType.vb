Public Class BlobEntryModelType
    Public enum fileStatusEnumType
        Undefined = 0
        Uploading = 10
        UploadComplete = 20
        Failed = 90
        Complete = 100
    End enum

    Public property id As String
    Public property data As Byte() = Nothing
    Public property creationdate As DateTime
    Public property filename As String
    Public Function extension() As String

        Return getExtension(Me.filename)

    End Function
    Public property settings As New Hashtable
    Public property uploaded As Long = 0
    Public property size As Long = 0
    Public property status As fileStatusEnumType = fileStatusEnumType.Undefined
    Public property message As String
    Public property hashlist As String          'name piped splitted hash
    Public property pid As String               'id del processo di variabili che ha creato l'elemento

    '--other properties
    Public Property ipaddress As String

    Public Property _verificaEstensione As String = "NotVerified"

    Public sub New(filename As String)
        Me.id = AfCommon.Tools.getrandomid
        Me.creationdate = Date.Now
        Me.filename = filename
    End sub
    Public sub New
    End sub

    Public function GetHash(algorithm As AfCommon.Tools.SHA_Algorithm) As string
        If Not IsNothing(hashlist)
            Return hashlist.Split(New String(){vbTab},StringSplitOptions.RemoveEmptyEntries).ToList().Find(Function(m) m.StartsWith(Algorithm.ToString & ":"))
        End If
        Return String.Empty
    End function
        Public function GetHashPart(algorithm As AfCommon.Tools.SHA_Algorithm) As string
        If Not IsNothing(hashlist)
            Dim ret As String = hashlist.Split(New String(){vbTab},StringSplitOptions.RemoveEmptyEntries).ToList().Find(Function(m) m.StartsWith(Algorithm.ToString & ":"))
            ret = ret.Substring(ret.IndexOf(":",StringComparison.Ordinal)+1)
            Return ret
        End If
        Return String.Empty
    End function
    Public Sub SetHash(algorithm As AfCommon.Tools.SHA_Algorithm,hash As String)
        Dim hlist As New List(Of String)
        If Not String.IsNullOrWhiteSpace(Me.hashlist)
            hlist = hashlist.Split(New String(){vbTab},StringSplitOptions.RemoveEmptyEntries).ToList()
        End If
        hlist.RemoveAll(Function(m) m.StartsWith(algorithm.ToString & ":"))
        hlist.Add(hash)
        Me.hashlist = String.Join(vbTab,hlist.ToArray)
    End Sub
    Public property pdfhash As String           'hash di un file pdf
    Public Function pdfpureHash() As String
        If String.IsNullOrWhiteSpace(Me.pdfhash) OrElse Not pdfhash.StartsWith("1#") Then
            Throw New Exception("Errore nel calcolo dell'hash pdf")
        Else
            Return pdfhash.Substring(2)
        End If
    End Function
    Public Sub Complete(Dbm As CTLDB.DatabaseManager)
        If Not Me.status = fileStatusEnumType.Complete Then

        End If
    End Sub

    Public Shared Function getExtension(filename As String) As String

        '-- se ho il nome file e contiene il punto e non finisce con il punto
        If Not String.IsNullOrWhiteSpace(filename) AndAlso filename.Contains(".") And Not filename.EndsWith(".") Then
            Return filename.Substring(filename.LastIndexOf(".")) '-- restitiuamo ad es   .p7m
            'Return New System.IO.FileInfo(Me.filename).Extension '-- non accediamo al file system e risolviamo eventuali problemi di accesso
        End If

        Return String.Empty

    End Function

End Class
