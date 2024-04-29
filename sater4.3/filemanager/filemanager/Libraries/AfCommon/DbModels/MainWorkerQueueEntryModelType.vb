Public Class MainWorkerQueueEntryModelType
    Public Property id As String
    Public Property identifier As String
    Public Property creationdate As DateTime
    Public Property action As String                    'azione da eseguire in accordo con i parametri forniti
    Public Property esit As Boolean?
    Public Property message As String
    Public Property displayonform As Boolean
    Public Property stacktrace As String
    Public Property mainstart As DateTime?
    Public Property started As DateTime?
    Public Property lastupdate As DateTime?
    Public Property operation As String
    Public Property progress As Double
    Public Property settings As New Hashtable
    Public Property outputscripts As New Hashtable
    Public Property displayvariables As New Hashtable
    Public Property returnactions As New Hashtable
    Public Property lockid As String
    Public Property locktime As DateTime?
    Public Property idpfu As Integer?
    Public Property sessionid As String
    Public Property lastclientupdate As DateTime?
    Public Sub New(idPfu As Integer?, SessionId As String)
        Me.idpfu = idPfu
        Me.sessionid = SessionId
    End Sub
    Public Sub New()
    End Sub
End Class


