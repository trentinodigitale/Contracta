Public Class ProxyRequestModelType
    Public property id As String
    Public property fx As String
    Public property creationdate As DateTime
    Public property url As String
    Public property ipaddress As String
    Public property query As new Hashtable
    Public property form As New Hashtable

    Public property ref_url As String
    Public property ref_query As New Hashtable
    Public function idPfu As Integer?
        If Me.query.ContainsKey("idPfu") AndAlso IsNumeric(Me.query("idPfu")) Then
            Return CInt(Me.query("idPfu"))
        End If
        Return Nothing
    End function
    Public function SessionId As String
        If Me.query.ContainsKey("sessionID") AndAlso Not String.IsNullOrWhiteSpace(Me.query("sessionID"))
            Return Me.query("sessionID")
        End If
        Return String.Empty
    End function
End Class
