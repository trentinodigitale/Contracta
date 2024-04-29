<%@ Page Language="VB" validateRequest="false" aspcompat="true"%>

<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

    Dim pathDownload As String = ConfigurationSettings.AppSettings("app.dir_download")
	Dim strConnectionString As String = ConfigurationSettings.AppSettings("db.conn")
    Dim globalStrCause As String = ""
    Dim totTentativi As Integer = 0
    Dim sqlConn1 As SqlConnection = Nothing
	dim attivaTrace as Boolean = false
	
    Sub Page_Load()
        
        Dim algoritmoUsato As String = "SHA1_OLD" '-- il default resterà quello "vecchio" per mantenere la retrocompatibilità. la ctldb chiamerà questa pagina con il parametro query string 'algoritmo' con SHA256
		Dim strSQL As String = ""
				 
        If UCase(CStr(Request.QueryString("genera_hash"))) = "YES" Then

            If Request.QueryString("file") <> "" Then
				
                Try

                    Dim pathFile As String = Request.QueryString("file")
				
					strSQL = "select id from LIB_Dictionary where dzt_name='SYS_ATTIVA_TRACE' and DZT_ValueDef = 'YES'"
				
					sqlConn1 = New SqlConnection(strConnectionString)
					sqlConn1.Open()
					
					Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
					Dim rs As SqlDataReader = sqlComm.ExecuteReader()
				
					if ( rs.Read() ) then
						attivaTrace = true
					end if
					
					rs.close()
					
					call traceDB("INIZIO PAGINA")
				
                    If My.Computer.FileSystem.FileExists(pathFile) = False Then
						call traceDB("FILE NON TROVATO. " & pathFile)
                        Response.Write("0#Da filehash.aspx, il file '" & pathFile & "' non esiste")
                    Else
                        
                        Dim strOut As String = ""
                        totTentativi = 0
                        Dim fileBloccato As Boolean = True
                        Dim msgErr As String = ""
                        
                        If Request.QueryString("algoritmo") <> "" Then                           
                            algoritmoUsato = Request.QueryString("algoritmo")
                        End If
                        
						call traceDB("RICHIESTO HASH BINARIO CON ALGORITMO " & algoritmoUsato)
						
                        While totTentativi < 5 And fileBloccato = True
                            
                            Try

                                Select Case algoritmoUsato.ToUpper()
                            
                                    Case "SHA1_OLD"
                                        strOut = getSha1FileHash(pathFile)
                                    Case "SHA1"
                                        strOut = getSha1V3FileHash(pathFile)
                                    Case "SHA256"
                                        strOut = getSha256FileHash(pathFile)
                                    Case "MD5"
                                        strOut = getMD5FileHash(pathFile)
                                
                                    Case Else
                                
                                        Response.Write("0#ALGORITMO DI HASH '" & algoritmoUsato & "' NON SUPPORTATO")

                                End Select
                                
                                msgErr = ""
                                fileBloccato = False

                            Catch ex As Exception

                                msgErr = ex.Message
                                Threading.Thread.Sleep(1000)

                            End Try
                            
                            totTentativi = totTentativi + 1
                            
                        End While
                        
                        If msgErr <> "" Then
                            Throw New Exception(msgErr)
                        End If
   
						call traceDB("FINE PAGINA. HASH RESTITUITO : " & strOut.ToUpper)
                        Response.Write(strOut.ToUpper)
						sqlConn1.close()
						
                    End If
				
					

                Catch ex As Exception
				
                    Call traceError(ex.Message.ToString())
					call traceDB("ERRORE." & ex.Message.ToString())
					
					sqlConn1.close()
					
                    Response.Write("0#filehash.aspx - Tentativo numero " & CStr(totTentativi) & " - strCause = '" & globalStrCause & "' - " & ex.Message.ToString())
					
                End Try

            End If
            
        Else

            hash_check.Text = CStr(Request.QueryString("hash_check"))
            
            '-- quando l'algoritmo passato è vuoto ci troviamo su un "vecchio" file, quindi con il vecchio algoritmo di hash
            If CStr(Request.QueryString("alg")) <> "" Then
                algoritmoScelto.Value = CStr(Request.QueryString("alg"))
            Else
                algoritmoScelto.Value = "SHA1_OLD"
            End If
            
            
        End If

    End Sub

    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        EsitoVerifica.Text = ""
        EsitoVerifica.BackColor = System.Drawing.Color.White
        
        If FileUpload1.HasFile Then
            
            Try
                
                Dim nomeFileOriginale As String = FileUpload1.FileName
                Dim vet As String() = nomeFileOriginale.Split(New Char() {"."c})
                
                Dim fileExt As String = ""
                
                If vet.Length > 0 Then
                    fileExt = vet(vet.GetUpperBound(0))
                    
                    If fileExt <> "" Then
                        
                        Dim strSQL As String = "select DZT_ValueDef from LIB_Dictionary with(nolock) where dzt_name='SYS_ESTENSIONI_UPLOAD'"
				
                        sqlConn1 = New SqlConnection(strConnectionString)
                        sqlConn1.Open()
					
                        Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
                        Dim rs As SqlDataReader = sqlComm.ExecuteReader()
				
                        If (rs.Read()) Then
                        
                            Dim estensionAmmesse As String = rs("DZT_ValueDef")
                            
                            If InStr(1, UCase(estensionAmmesse), UCase(fileExt)) = 0 Then
                                EsitoVerifica.Text = "Estensione non ammessa"
                                EsitoVerifica.BackColor = System.Drawing.Color.Red
                                Return
                            End If
                            
                        End If
                        
                        rs.Close()
                        
                    End If
                    
                End If
                
                
                Dim uniqueStr As String = "_" & Date.Now.Hour & Date.Now.Minute & Date.Now.Second & Date.Now.Millisecond & "_"
                Dim nomeFile As String = pathDownload & "temp" & uniqueStr
                Dim hashGenerato As String = ""
                
                FileUpload1.SaveAs(nomeFile)
                
                Dim algoritmoUsato As String = "SHA256"
                
                If CStr(Request.Form("algoritmoScelto")) <> "" Then
                    algoritmoUsato = Request.Form("algoritmoScelto")
                End If
                    
                Select Case algoritmoUsato.ToUpper()
                            
                    Case "SHA1"
                        hashGenerato = getSha1V3FileHash(nomeFile).ToUpper
                    Case "SHA1_OLD"
                        hashGenerato = getSha1FileHash(nomeFile).ToUpper
                    Case "SHA256"
                        hashGenerato = getSha256FileHash(nomeFile).ToUpper
                    Case "MD5"
                        hashGenerato = getMD5FileHash(nomeFile).ToUpper
                    Case Else
                                
                        hashGenerato = "ALGORITMO DI HASH '" & algoritmoUsato & "' NON SUPPORTATO"

                End Select

                Label1.Text = "HASH<br/><strong>" & hashGenerato & "</strong>"

                File.Delete(nomeFile)
                    
                '-- se è stato inserito un valore da verificare
                If hash_check.Text.Trim <> "" Then
                    
                    EsitoVerifica.Width = WebControls.Unit.Percentage(70)
                    EsitoVerifica.Style.Add("text-align", "center")
                    
                    If hash_check.Text.Trim.ToUpper = hashGenerato Then
                        EsitoVerifica.Text = "L'HASH COINCIDE"
                        EsitoVerifica.BackColor = System.Drawing.Color.GreenYellow
                    Else
                        EsitoVerifica.Text = "L'HASH NON COINCIDE"
                        EsitoVerifica.BackColor = System.Drawing.Color.Red
                    End If
                
                End If
                    
                'Label1.Text = "File name: " & FileUpload1.PostedFile.FileName & "<br>" & _
                '    "File Size: " & _
                '    FileUpload1.PostedFile.ContentLength & " kb<br>" & _
                '    "Content type: " & _
                'FileUpload1.PostedFile.ContentType
                
            Catch ex As Exception
                Label1.Text = "ERROR: " & ex.Message.ToString()
                Call traceError(ex.Message.ToString())
            End Try
            
        Else
            Label1.Text = "Non hai specificato un file."
        End If
        
    End Sub
    
    Function getSha256FileHash(ByVal pathFile As String) As String
        
        Dim sha256 As New SHA256Managed
        Dim outHash As String = " "
        
        globalStrCause = "Invocazione metodo File.OpenRead"
		call traceDB("METODO getSha256FileHash. " & globalStrCause)
        'Dim fileStream As FileStream = File.OpenRead(pathFile)
        Dim fileStream As FileStream = File.Open(pathFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)
        
        Try
            globalStrCause = "Esecuzione sha256.ComputeHash"
			call traceDB("METODO getSha256FileHash. " & globalStrCause)
            outHash = BitConverter.ToString(sha256.ComputeHash(fileStream)).Replace("-", String.Empty)
        Catch ex As Exception

        End Try
        
        globalStrCause = "Invocazione metodo fileStream.Close"
		call traceDB("METODO getSha256FileHash. " & globalStrCause)
        fileStream.Close()
        
        Return outHash
        
    End Function
    
    Function getMD5FileHash(ByVal pathFile As String) As String
        
        Dim sha256 As New MD5CryptoServiceProvider
        Dim outHash As String = " "
        
        Dim fileStream As FileStream = File.OpenRead(pathFile)
        
        Try
            outHash = BitConverter.ToString(sha256.ComputeHash(fileStream)).Replace("-", String.Empty)
        Catch ex As Exception

        End Try
        
        fileStream.Close()
        
        Return outHash
        
    End Function
    
    Function getSha1V3FileHash(ByVal pathFile As String) As String

        Dim sha256 As New SHA1Managed
        Dim outHash As String = " "
        
        Dim fileStream As FileStream = File.OpenRead(pathFile)
        
        Try
            outHash = BitConverter.ToString(sha256.ComputeHash(fileStream)).Replace("-", String.Empty)
        Catch ex As Exception

        End Try
        
        fileStream.Close()
        
        Return outHash
        
    End Function
    
    Function getSha1FileHash(ByVal pathFile As String) As String

        Dim sha1Obj As New System.Security.Cryptography.SHA1CryptoServiceProvider
		
		dim totTentativi as Integer = 0
		dim fileBloccato as Boolean = true
		Dim bytesToHash() As Byte
		dim msgErr as String = ""
	
		while totTentativi < 10 and fileBloccato = true
		
			
			Try

				bytesToHash = ReadFile(pathFile)
				msgErr = ""
				fileBloccato = false

			Catch ex As Exception

				msgErr = ex.message
				Threading.Thread.Sleep(1000)

			End Try

			totTentativi = totTentativi + 1
			
		end while
		
		If msgErr <> "" Then
            Throw New Exception(msgErr)
        End If		
		
        bytesToHash = sha1Obj.ComputeHash(bytesToHash)

        Dim strResult As String = ""

        For Each b As Byte In bytesToHash
            strResult += b.ToString("x2")
        Next

        Return strResult

    End Function
	
	Function getSha1FileHashV2(ByVal pathFile As String) As String

        Dim hashValue() As Byte
		Dim hash As New System.Security.Cryptography.SHA1CryptoServiceProvider
		
        Dim fileStream As FileStream = File.OpenRead(pathFile)

        fileStream.Position = 0

        hashValue = hash.ComputeHash(fileStream)

        Dim hash_hex = PrintByteArray(hashValue)

        fileStream.Close()

        Return hash_hex

    End Function
	
    Public Function PrintByteArray(ByVal array() As Byte) As String

        Dim hex_value As String = ""

        Dim i As Integer
        For i = 0 To array.Length - 1
            hex_value += array(i).ToString("X2")
        Next i

        Return hex_value.ToLower

    End Function
    
    Public Function ReadFile(ByVal fileName As String) As Byte()

        Dim data() As Byte
        Dim f As FileStream
        Dim msgErr As String = ""
        Dim strCauseLocal As String = ""
        dim chiudi as boolean = false
		
        Try
		
			strCauseLocal = "Creo l'oggetto FileStream con FileMode.Open, FileAccess.Read"
			f = New FileStream(fileName, FileMode.Open, FileAccess.Read)
			
			chiudi = true
			
			Dim size As Integer = Fix(f.Length)
			ReDim data(size)
			
            strCauseLocal = "effettuo la read del file"
            size = f.Read(data, 0, size)
            
        Catch ex As Exception
        
            msgErr = ex.Message
            
        Finally
            
			if chiudi then
				strCauseLocal = "effettuo la close del file"
				f.Close()
			end if
            
        End Try

		f = Nothing

        If msgErr <> "" Then
            Throw New Exception(strCauseLocal & " - " & msgErr)
        End If
        
        Return data

    End Function
	
	Private Sub traceError(ByVal descrizione As String)

        On Error Resume Next
        
        Dim contesto = "FILEHASH.ASPX"
        Dim typeTrace As String = "TRACE-ERROR"
        
        Dim sSource As String
        Dim sLog As String
        Dim sEvent As String
        Dim sMachine As String

        sEvent = Left("Errore nella generazione dell'hash del file --- Descrizione dell'errore : " & descrizione, 4000)
        
        sSource = "AFLink"
        sLog = "Application"
        sMachine = "."

        If Not EventLog.SourceExists(sSource, sMachine) Then
            EventLog.CreateEventSource(sSource, sLog, sMachine)
        End If

        Dim ELog As New EventLog(sLog, sMachine, sSource)

        ELog.WriteEntry(sEvent, EventLogEntryType.Error)

        Err.Clear()
        
    End Sub
	
    private sub traceDB( ByVal descrizione as String )

		if ( attivaTrace ) then

			on error resume next

			dim strSQL as String = "INSERT INTO CTL_TRACE (contesto,sessionIdASP,sessionIdApp,idpfu,idDoc,descrizione)"
			strSQL = strSQL & " VALUES ('filehash.aspx','','',-20, -1, '" & Replace(descrizione, "'", "''") & "')"

			Dim sqlComm = New SqlCommand(strSQL, sqlConn1)
			sqlComm.ExecuteNonQuery()

			on error goto 0

		end if

	end sub

</script>
<%
    If Request.QueryString("genera_hash") = "" Then

%>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>FILE CHECKSUM</title>
</head>
<body>



    <form id="form1" runat="server">
    
		<fieldset>
		
			<legend>GENERAZIONE/VERIFICA HASH - FILE CHECKSUM</legend>
			
			<br />

            Selezionare il file da verificare 
			<asp:FileUpload ID="FileUpload1" runat="server" /><br /><br />

            <!--
            2. Selezionare l'algoritmo di hash desiderato :  <br />
            <ul style="list-style: none;">
                <li><input type="radio" name="algoritmoScelto" value="SHA256" checked="checked" /> SHA 256</li>
                <li><input type="radio" name="algoritmoScelto" value="SHA1" /> SHA 1 </li>
                <li><input type="radio" name="algoritmoScelto" value="SHA1_OLD" /> SHA 1 legacy</li>
                <li><input type="radio" name="algoritmoScelto" value="MD5" /> MD5  </li>
            </ul>
            -->
            
            <asp:HiddenField id="algoritmoScelto" runat="server" />

			<br />
			(opzionale) Hash da verificare : 
			<asp:TextBox id="hash_check" runat="server" Width="100%" />
			<br /><br />
			<asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Upload File" />&nbsp;<br />
			<br />
			<asp:Label ID="Label1" runat="server"></asp:Label>
			<br /><br />
			<asp:Label ID="EsitoVerifica" runat="server"></asp:Label>
			
		</fieldset>
    </form>
</body>
</html>
<%
	end if
%>
