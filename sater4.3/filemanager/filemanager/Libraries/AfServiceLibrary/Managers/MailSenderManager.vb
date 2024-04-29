Public Class MailSenderManager
    Private shared TRMS As System.Threading.Thread = Nothing

    ''' <summary>
    ''' inizializza la gestione del mailsender per le notifiche
    ''' </summary>
    Public shared sub fx_init_mailsender
        If IsNothing(TRMS) OrElse not TRMS.IsAlive
            TRMS = New Threading.Thread(AddressOf fx_do_send_mail)
            TRMS.Start
        End If
    End sub
    Private shared Sub UnlockChilkat(Dbm As CTLDB.DatabaseManager)
        Dim glob As new Chilkat.Global
        if Not glob.UnlockBundle(afcommon.Statics.codiceAttivazioneChilkat) Then 
            throw New Exception("Unable to Unlock Chilkcat Crypt2 With Key: " & afcommon.Statics.codiceAttivazioneChilkat)
        End If
    End Sub

    ''invia le email in coda
    Private shared sub fx_do_send_mail
        While True
            Dim sleep As Integer = 5000
            Try
                If AfCommon.AppSettings.item("app.mailer").ToUpper = "YES" Then
                    Using Dbm As New CTLDB.DatabaseManager(True, Nothing)

                        Try

                            UnlockChilkat(Dbm)
                            Dim tablename As String = CTLDB.DbClassTools.GetTableName(GetType(AfCommon.NotificationsMailQueueModelType), Dbm, True)
                            Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT Top 1 id FROM [" & tablename & "] WHERE sent IS NULL Order by creationdate", New Hashtable)

                                If dr.Read Then

                                    sleep = 0

                                    Dim NE As AfCommon.NotificationsMailQueueModelType = CTLDB.DbClassTools.fx_get_instance(Of AfCommon.NotificationsMailQueueModelType)(dr("id"), Dbm, Nothing)
                                    Dim params As New Hashtable
                                    params("@id") = NE.id
                                    Dim send_error As String = ""
                                    params("@sent") = SendMail(NE.GetMailSubject, NE.GetMailBody, True, NE.mpmevento, send_error)
                                    params("@send_error") = send_error
                                    Dbm.ExecuteNonQuery("UPDATE [" & tablename & "] SET sent = @sent, send_date = GETDATE() WHERE id = @id", params)
                                Else
                                    sleep = 1000
                                End If
                            End Using

                        Catch ex As Exception
                            'Dbm.traceError(ex,True) '-- se la tabella manca non dobbiamo andare in errore.
                            sleep = 1000
                        End Try
                        Dbm.commit()
                    End Using
                End If
            Catch ex As Exception
                'TODO: WRITE IN EVENT VIEWER ONLY (perchè c'è un errore di accesso al Db)
            End Try
            System.Threading.Thread.Sleep(sleep)
        End While
    End sub
    ''' <summary>
    ''' Invio di una singola email
    ''' </summary>
    ''' <param name="subject"></param>
    ''' <param name="body"></param>
    ''' <param name="htmlbody"></param>
    ''' <param name="mpmEvento"></param>
    ''' <param name="send_error"></param>
    ''' <returns></returns>
    Private shared function SendMail(subject As String,body As String,htmlbody As Boolean,mpmEvento As String, byref send_error As String) As Boolean
        Try
            Using Dbm As New CTLDB.DatabaseManager(False, Nothing)
                Dim strMailTo As String = String.Empty
                Dim strMailFrom As String = String.Empty
                Dim params As New Hashtable
                params("mpmEvento") = mpmEvento
                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select mpmTo, mpmFrom from MPMail with(nolock) where mpmEvento = @mpmEvento", params)
                    If dr.Read Then
                        strMailTo = dr("mpmTo")
                        strMailFrom = dr("mpmFrom")
                    End If
                End Using
                Dim mailman As Chilkat.MailMan = Nothing
                Dim mailmessage As Chilkat.Email = Nothing
                If Not String.IsNullOrWhiteSpace(strMailFrom) AndAlso Not String.IsNullOrWhiteSpace(strMailTo) Then
                    params = New Hashtable
                    params("@strMailFrom") = strMailFrom.Trim
                    Using DT As DataTable = Dbm.fx_get_datatable("select top 1 dbo.DecryptPwd(password) as pwd, * from CTL_CONFIG_MAIL with(nolock) where alias=@strMailFrom", params)
                        If DT.Rows.Count > 0 Then

                            With DT.Rows(0)
                                mailman = New Chilkat.MailMan()
                                mailmessage = New Chilkat.Email()
                                Dim dr As DataRow = DT.Rows(0)
                                mailman.SmtpHost = dr("Server")
                                mailman.SmtpPort = dr("ServerPort")
                                mailman.SmtpSsl = dr("UseSSL")
                                mailman.SmtpAuthMethod = dr("Authenticate")
                                If Not IsDBNull(dr("username")) Then
                                    mailman.SmtpUsername = dr("UserName")
                                    mailman.SmtpPassword = dr("pwd")
                                End If
                                If Not IsNothing(DT.Columns("StartTLS")) AndAlso Not IsDBNull(dr("StartTLS")) Then
                                    mailman.StartTLS = dr("StartTLS")
                                End If
                                mailmessage.FromAddress = dr("MailFrom")
                                mailmessage.FromName = dr("AliasFrom")
                            End With
                        End If
                    End Using
                End If
                If Not IsNothing(mailman) AndAlso Not IsNothing(mailmessage) Then
                    mailmessage.Subject = subject
                    If htmlbody Then
                        mailmessage.SetHtmlBody(body)
                    Else
                        mailmessage.SetTextBody(body, "text/plain")
                    End If
                    For Each receivers As String In strMailTo.Trim.Split(";")
                        mailmessage.AddTo(receivers, receivers)
                    Next
                    Dim esit As Boolean = mailman.SendEmail(mailmessage)
                    If Not esit Then
                        send_error = mailman.LastErrorText
                    Else
                        Console.WriteLine("Email message sent to:" & mailmessage.GetTo(0))
                    End If
                    Return esit
                End If
            End Using
            Return True
        Catch ex As Exception
            send_error = ex.Message
            Return False
        End Try
    End function
End Class
