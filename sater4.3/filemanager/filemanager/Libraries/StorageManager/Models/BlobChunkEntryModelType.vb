Public Class BlobChunkEntryModelType
    Public property id As String
    Public property blobid As String
    Public property creationdate As DateTime
    Public property position As Long
    Public property data As Byte()
    Public sub New(blobid As String,position As Long,data As Byte())
        Me.id = AfCommon.Tools.getrandomid
        Me.creationdate = Date.Now
        Me.blobid=blobid
        Me.position = position
        Me.data = data
    End sub
    Public sub New

    End sub
End Class
