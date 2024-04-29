Public Class NotificationsMailQueueModelType
    Public property id As String
    Public property mpmevento As String
    Public property tipoevento As Integer
    Public property creationdate As DateTime
    Public property idpfu As String    
    Public property sessionid As String
    Public property source As String
    Public property message As String
    

    'DATI SPECIFICI
    Public property nomecliente As String
    Public property ambiente As String
    Public property codazi As String
    Public property  userip As String
    Public property contestoapplicativo As String
    Public property errornumber As String 
    Public property ipserver As String
    Public property errorsource As String 
    Public property errorcause As String
    Public property paginachiamante As String
    Public property mollicadipane As String 
    Public property paginarichiesta As String
    Public property querystring As String
    '/DATI SPECIFICI


    Public property sent As Boolean?            
    Public property send_date As DateTime?
    Public Property send_error As String


    Public Property job_id As String

    Public function GetMailSubject As String
        Return "ERRORE INSERIMENTO ALLEGATO"
        'TODO: gestire un oggetto generico in funzione dell'mp evento
    End function
    Public function GetMailBody As String
        dim strMailBody As String = "<p>" & vbcrlf
	    strMailBody = strMailBody & "Email di alert backoffice generata a partire da un errore nell'inserimento di un allegato utente<br/>"& vbcrlf

	    strMailBody = strMailBody & "<hr/>" & vbcrlf

	    strMailBody = strMailBody & "<p>"& vbcrlf
	    strMailBody = strMailBody & "<strong>INFORMAZIONI SUL SERVER DOVE E' AVVENUTO L'ERRORE</strong>"& vbcrlf
	    strMailBody = strMailBody & "<br/> CLIENTE  : " & NomeCliente & vbcrlf
	    strMailBody = strMailBody & "<br/> AMBIENTE : " & Ambiente & vbcrlf
	    strMailBody = strMailBody & "<br/> IP NODO  : " & ipServer & vbcrlf
	    strMailBody = strMailBody & "</p>" & vbcrlf
	
	    strMailBody = strMailBody & "<hr/>" & vbcrlf
	
	    strMailBody = strMailBody & "<p>"& vbcrlf
	    strMailBody = strMailBody & "<strong>INFORMAZIONI SULL'UTENTE</strong>"& vbCrLf
        strMailBody = strMailBody & "<br/> IDPFU  		 				  : " & idpfu & vbCrLf
        strMailBody = strMailBody & "<br/>  ID JOB ( AfCommon_WorkerQueueEntryModelType ) : " & job_id & vbCrLf

        'if strUserName <> "" then
        '	strMailBody = strMailBody & "<br/> USER NAME					  : " & cstr(strUserName) & vbcrlf
        'end if

        If CodAzi <> "" then
		    strMailBody = strMailBody & "<br/> IDAZI					  : " & cstr(CodAzi) & vbcrlf
	    end if
	
	    strMailBody = strMailBody & "<br/> IP 					  : " & cstr(userIp) & vbcrlf

	    strMailBody = strMailBody & "</p>"& vbcrlf
	
	    strMailBody = strMailBody & "<hr/>" & vbcrlf
	
	    strMailBody = strMailBody & "<p>"& vbcrlf
	    strMailBody = strMailBody & "<strong>INFORMAZIONI SULL'ERRORE</strong>"& vbcrlf
	    strMailBody = strMailBody & "<br/> CONTESTO  			 		  : " & contestoApplicativo & vbcrlf
	    strMailBody = strMailBody & "<br/> NUMERO DELL'ERRORE  			  : " & cstr(errorNumber) & vbcrlf
	
	    if errorSource <> "" then
		    strMailBody = strMailBody & "<br/> ERR.SOURCE					  : " & cstr(errorSource) & vbcrlf
	    end if
	
	    if ErrorCause <> "" then
		    strMailBody = strMailBody & "<br/> STR CAUSE					  : " & cstr(ErrorCause) & vbcrlf
	    end if
	
	    strMailBody = strMailBody & "<br/> DATA INVIO EMAIL/DATA ERRORE   : " & cstr(Me.creationdate.ToString("o")) & vbcrlf
	    strMailBody = strMailBody & "<br/> PAGINA CHIAMANTE 			  : " & cstr(paginaChiamante) & vbcrlf
	
	    strMailBody = strMailBody & "<br/> ELEMENTO CORRENTE BRICIOLE DI PANE : " & cstr(mollicaDiPane) & vbcrlf
	
	
	    strMailBody = strMailBody & "<br/> PAGINA RICHIESTA 			  : " & cstr(paginaRichiesta) & vbcrlf
	    strMailBody = strMailBody & "<br/> QUERY STRING 				  : " & cstr(queryString) & vbcrlf

	    strMailBody = strMailBody & "<br/> MESSAGGIO DI ERRORE   		  : " & cstr(message).Replace(vbCrLf,"<br/>") & vbcrlf
	    strMailBody = strMailBody & "</p>" & vbcrlf
	
	    strMailBody = strMailBody & "</p>" & vbcrlf
	
	    strMailBody = strMailBody & "<hr/>" & vbcrlf

        Return strMailBody
    End function
End Class
