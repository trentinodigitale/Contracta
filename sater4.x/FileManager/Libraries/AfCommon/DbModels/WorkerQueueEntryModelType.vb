Public Class WorkerQueueEntryModelType
    Public property id As String
    Public property identifier As String
    Public property creationdate As DateTime    
    Public property action As String                    'azione da eseguire in accordo con i parametri forniti
    Public property esit As Boolean?
    Public property message As String
    Public property displayonform As Boolean
    Public property stacktrace As String
    Public property mainstart As DateTime?
    Public property started As DateTime?
    Public property lastupdate As DateTime?
    Public property operation As String
    Public property progress As Double
    Public property settings As New Hashtable
    Public property outputscripts As New Hashtable
    Public property displayvariables As New Hashtable
    Public property returnactions As New Hashtable
    Public property lockid As String
    Public property locktime As DateTime?
    Public property idpfu As Integer?
    Public property sessionid As String
    Public property lastclientupdate As DateTime?
    Public sub New(idPfu As Integer?,SessionId As String)
        Me.idpfu = idPfu
        Me.sessionid = SessionId
    End sub
    Public sub New
    End sub
End Class


'Esempio di utilizzo
'1)
    'action : "url-to-pdf"
    'params:  url = https://www.test.local?pdf=123456
    'do: CREA UN PDF DALL'URL E SALVA IL RISULTATO IN UN ELEMENTO temporaneo del FS
  


