Public Class TempUploadTokenModelType
    Public property id As String
    Public property pid As String                       'collezione di parametri
    Public property creationdate As DateTime
    Public property ipaddress As String
    Public property uploaded As Long
    Public property filesize As Long?
    Public property filename As String
    Public property signed As Boolean
    Public property started As DateTime?
    Public property hash_md5 As String
    Public property hash_sha1 As String
    Public property hash_sha256 As String
    Public property hash_sha384 As String
    Public property hash_sha512 As String
    Public property pdf_content_hash As String
    Public property requesturl As String
    Public property data As Byte() = Nothing            'non modificare la posizione di questa colonna nè aggiungere colonne prima di questa
    Public property uploadcomplete As Boolean
    Public property datacomplete As Boolean
    Public property message As String
    Public property settings As Hashtable
    Public function extension As String
        If Not String.IsNullOrWhiteSpace(Me.filename)
            Return New System.IO.FileInfo(Me.filename).Extension
        End If
        Return String.Empty
    End function

    Public sub New(ipaddress As String,requesturl As String)
        Me.New()
        Me.ipaddress = ipaddress
        Me.requesturl = requesturl
    End sub
    Public function CalculateAllHashes(data As Byte(),pdf_hash As String) As Boolean
        Dim ret As Boolean=False
        If Not IsNothing(data)
            If String.IsNullOrWhiteSpace(Me.hash_md5)
                Me.hash_md5 = AfCommon.Tools.HashTools.GetHASHBytesToString(data, Tools.SHA_Algorithm.MD5)
                ret = True
            End If
            If String.IsNullOrWhiteSpace(Me.hash_sha1)
                Me.hash_sha1 = AfCommon.Tools.HashTools.GetHASHBytesToString(data, Tools.SHA_Algorithm.SHA1)
                ret = True
            End If
            If String.IsNullOrWhiteSpace(Me.hash_sha256)
                Me.hash_sha256 = AfCommon.Tools.HashTools.GetHASHBytesToString(data, Tools.SHA_Algorithm.SHA256)
                ret = True
            End If
            If String.IsNullOrWhiteSpace(Me.hash_sha384)
                Me.hash_sha384 = AfCommon.Tools.HashTools.GetHASHBytesToString(data, Tools.SHA_Algorithm.SHA384)
                ret = True
            End If
            If String.IsNullOrWhiteSpace(Me.hash_sha512)
                Me.hash_sha512 = AfCommon.Tools.HashTools.GetHASHBytesToString(data, Tools.SHA_Algorithm.SHA512)
                ret = True
            End If
        End If
        If String.IsNullOrWhiteSpace(Me.pdf_content_hash) AndAlso Not String.IsNullOrWhiteSpace(pdf_hash)
            Me.pdf_content_hash = pdf_hash
            ret = True
        End If
        Return ret
    End function
    Public sub New
        Me.id = Tools.getrandomid
        Me.creationdate = Date.Now
        Me. data = New Byte(){}
    End sub
End Class
