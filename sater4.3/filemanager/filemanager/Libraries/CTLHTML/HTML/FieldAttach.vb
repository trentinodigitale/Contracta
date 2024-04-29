Imports CTLDB

Namespace Html
    Public Class FieldAttach
        ''' <summary>
        ''' Restituisce L'html di un campo dopo l'attach di un documento
        ''' </summary>
        ''' <param name="Dbm">Database Connection Manager</param>
        ''' <param name="name"> VALORIZZATO DAL PARAMETRO IN GET 'FIELD'. è il nome tecnico del campo presente nel dizionario ( colonna dzt_name )</param>
        ''' <param name="value">chiave/riferimento dell'attach. è il TECH VALUE ( quello con i valori separati da asterisco )</param>
        ''' <param name="format">stringa contenente le modalità grafiche 'fuori dai default' con le quali si desidera rappresentare il field attach</param>
        ''' <returns></returns>
        Public Shared Function html(jobid As String, name As String, value As String, format As String, printmode As Boolean) As String

            Dim strFormatRipulita As String = format
            Dim signStatus As String = ""
            Dim strSQL As String = ""
            Dim nome_image As String = ""
            Dim ToolTip As String = ""
            Dim Style As String = "Attach"
            Dim Path As String = "../../" '-- percorso relativo che serve per tornare alla radice dell'applicazione
            Dim strHTML_OUT As String = ""
            Dim Guid As String = ""
            Dim vEditable As Boolean = True
            Dim v As String() = Nothing

            If InStr(1, strFormatRipulita, "EXT:") > 0 Then

                Dim a As String
                Dim ix As Integer
                Dim ix2 As Integer
                ix = InStr(1, strFormatRipulita, "EXT:")
                ix2 = InStr(ix + 1, strFormatRipulita, "-")
                a = Mid(strFormatRipulita, ix, ix2 - ix + 1)
                strFormatRipulita = Replace(strFormatRipulita, a, "")

            End If

            '--Formattazione di default:Icona e nome
            If strFormatRipulita = "" Then
                strFormatRipulita = "I,N"
            End If

            '-- Verifico se è un allegato con richiesta di verifica avanzata firma digitale
            If InStr(1, strFormatRipulita, "V") > 0 And value <> "" Then

                signStatus = ""

                '-- Recupero il guid dell'allegato, Value= NAMEATTACH*TYPEATTACH*SIZEATTACH*GUID
                v = Split(value, "*")
                Guid = v(3)

                '--  DA GESTIRE CON IL PARAMETRO @GUID
                strSQL = "select isnull(statoFirma,'KO') as statoFirma from CTL_SIGN_ATTACH_INFO with(nolock) where ATT_Hash = '" & Replace(Guid, "'", "''") & "' order by statoFirma asc"
                signStatus = "SIGN_WAIT"

                '-- Itero sugli N certificati dell'allegato (Nel caso di firme multiple)
                Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)

                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSQL, Nothing)
                        While dr.Read
                            signStatus = dr("statoFirma")
                            '-- Se trovo uno stato diverso da sign_ok posso fermarmi
                            If signStatus <> "KO" And UCase(signStatus) <> "SIGN_OK" Then
                                Exit While ' forzo l'uscita dal while (con la successiva invocazione di moveNext)
                            End If
                        End While
                    End Using

                End Using

                'faccio coincidere lo stato con il nome dell'immagine che lo rappresenta
                nome_image = LCase(signStatus)

            ElseIf Not String.IsNullOrWhiteSpace(value) Then
                v = Split(value, "*")
                Guid = v(3)
            End If
            '------------------------------------------
            '-- AGGIUNGERE IN SEGUITO LA GESTIONE DELLA FORMAT PER VISUALIZZARE LA TOOLTIP ESTESA CON NOME FILE DIMENSIONE ED ESTENSIONE
            '------------------------------------------


            strHTML_OUT = ""

            '-- campo nascosto per il recupero dei dati in formato tecnico
            'strHTML_OUT = strHTML_OUT & "<input type=""hidden"" name=""" & name & """  id=""" & name & """ "
            'strHTML_OUT = strHTML_OUT & " value=""" & AfCommon.Tools.EncodeTools.HTMLencode(value) & """ "
            'strHTML_OUT = strHTML_OUT & "/>" & vbCrLf

            '--apertura div contenitore
            strHTML_OUT = strHTML_OUT & "<div id=""DIV_" & name & """ >"

            '-- disegna la parte visuale
            strHTML_OUT = strHTML_OUT & "<table "
            strHTML_OUT = strHTML_OUT & " id=""" & name & "_V"" "
            strHTML_OUT = strHTML_OUT & " class=""" & Style & "_Tab"" >"
            strHTML_OUT = strHTML_OUT & "<tr>"
            strHTML_OUT = strHTML_OUT & "<td>"

            If value <> "" Then

                Dim strOnClick As String
                Dim strOnClickSenzaBusta As String = ""

                If printmode = False Then

                    '-- Se è attiva la format di verifica estesa firma e l'allegato è stato elaborato
                    If InStr(1, strFormatRipulita, "V") > 0 Then ' RIMOSSO IL CONTROLLO PER CONSENTIRE LO SBUSTAMENTO ANCHE DEL PREGRESSO And signStatus <> "SIGN_WAIT" Then
                        strOnClickSenzaBusta = " onclick=""javascript: DownloadFileSenzaBusta('" & AfCommon.Tools.EncodeTools.JAVASCRIPTEncode(v(3)) & "','" & AfCommon.Tools.EncodeTools.JAVASCRIPTEncode(v(0)) & "');"""
                    End If

                    '-- Se è stato chiesto il download senza busta sul nome del file
                    If InStr(1, strFormatRipulita, "B") > 0 Then
                        strOnClick = strOnClickSenzaBusta
                    Else
                        '--javascript per aprire l'allegato integro
                        strOnClick = " onclick=""javascript:"
                        strOnClick = strOnClick & "ExecFunction( '"
                        strOnClick = strOnClick & AfCommon.Tools.EncodeTools.HTMLencode(Path & "CTL_Library/functions/field/DisplayAttach.ASP?OPERATION=DISPLAY&FIELD=" & name & "&PATH=" & AfCommon.Tools.EncodeTools.URLencode(Path) & "&TECHVALUE=" & AfCommon.Tools.EncodeTools.URLencode(value) & "&FORMAT=" & AfCommon.Tools.EncodeTools.URLencode(format) & "' ")
                        strOnClick = strOnClick & " , 'DisplayAttach' , ',height=400,width=600' );"" "
                    End If

                Else

                    strOnClick = ""
                    strOnClickSenzaBusta = ""

                End If

                '------------------------------------------
                '-- AGGIUNGERE IN SEGUITO LA GESTIONE DELLA FORMAT PER VISUALIZZARE L'ICONA IN FUNZIONE DELL'ESTENSIONE DEL FILE
                '------------------------------------------

                '-- Verifico se è un allegato con firma digitale
                If InStr(1, strFormatRipulita, "V") > 0 And value <> "" Then

                    '-- icona per scaricare il file privo di busta
                    strHTML_OUT = strHTML_OUT & "<img class=""img_label_alt"" alt=""" & AfCommon.Tools.EncodeTools.HTMLencode("Scarica il file privo di busta firmata") & """ title=""" & AfCommon.Tools.EncodeTools.HTMLencode("Scarica il file privo di busta firmata") & """ id=""" & name & "_V_I"" src=""" & Path & "CTL_Library/images/Domain/dwnSenzaBusta.png"" " & strOnClickSenzaBusta & "/>"

                    '-- La funzione javascript InfoSignCert prende 2 parametri, il path che eredita dal field. E altri 4 parametri
                    '-- che gli permettono di raggiungere i certificati associati all'allegato:   infoSignCert( path, hash, attIdMsg, attOrderFile, attIdObj
                    '-- per il documento nuovo sarà avvalorato solo hash, per il documento generico il primo sarà vuoto e gli altri 3 saranno avvalorati.
                    strHTML_OUT = strHTML_OUT & "&nbsp;&nbsp;"
                    Dim srcpath As String
                    srcpath = "CTL_Library/images/Domain/" & nome_image & ".png"

                    strHTML_OUT = strHTML_OUT & "<img alt=""" & AfCommon.Tools.EncodeTools.HTMLencode(DatabaseManager.gettranslation("I", srcpath)) & """ "

                    If printmode = False Then
                        strHTML_OUT = strHTML_OUT & "onclick=""InfoSignCert( '','" & Replace(AfCommon.Tools.EncodeTools.HTMLencode(Guid), "'", "\'") & "','','','');"" "
                    End If

                    strHTML_OUT = strHTML_OUT & " class=""IMG_SIGNINFO"" src=""" & Path & srcpath & """/> &nbsp; "

                End If


                strHTML_OUT = strHTML_OUT & "<span "
                strHTML_OUT = strHTML_OUT & "id=""" & name & "_V_N"" "

                If printmode = False Then
                    strHTML_OUT = strHTML_OUT & " class=""" & Style & "_label"" "
                    strHTML_OUT = strHTML_OUT & strOnClick
                End If


                strHTML_OUT = strHTML_OUT & " title=""" & AfCommon.Tools.EncodeTools.HTMLencode(ToolTip) & """ "
                strHTML_OUT = strHTML_OUT & ">"

                '--verifico se mostrare il nome
                If InStr(1, strFormatRipulita, "N") > 0 Then
                    strHTML_OUT = strHTML_OUT & AfCommon.Tools.EncodeTools.HTMLencode(v(0))
                End If

                '------------------------------------------
                '-- AGGIUNGERE IN SEGUITO LA GESTIONE DELLA FORMAT PER MOSTRARE LA SIZE
                '------------------------------------------
                strHTML_OUT = strHTML_OUT & "</span>"

                '--se editabile inserisco il pulsante per la selezione
                If vEditable And printmode = False Then

                    strHTML_OUT = strHTML_OUT & "<input class=""" & Style & "_button"" type=""button"" name=""" & name & "_V_BTN"" id=""" & name & "_V_BTN"" "
                    strHTML_OUT = strHTML_OUT & " alt=""Inserisci allegato"" value=""..."" "
                    strHTML_OUT = strHTML_OUT & " onclick=""javascript:"
                    strHTML_OUT = strHTML_OUT & "ExecFunction( '"
                    strHTML_OUT = strHTML_OUT & AfCommon.Tools.EncodeTools.HTMLencode(Path & "CTL_Library/functions/field/UploadAttach.asp?OPERATION=INSERT&FIELD=" & name & "&PATH=" & AfCommon.Tools.EncodeTools.URLencode(Path) & "&TECHVALUE=" & AfCommon.Tools.EncodeTools.URLencode(value) & "&FORMAT=" & AfCommon.Tools.EncodeTools.URLencode(format))

                    'If Not Domain Is Nothing Then
                    '    strHTML_OUT =HtmlEncode("&DOMAIN=" & HtmlEncode(Domain.id)))
                    'End If

                    '-- se è richiesta la cifratura
                    If InStr(1, strFormatRipulita, "C") > 0 Then
                        strHTML_OUT = strHTML_OUT & AfCommon.Tools.EncodeTools.HTMLencode("&IDDOC=' + getObjValue('IDDOC') + '&CIF=1")
                    End If

                    strHTML_OUT = strHTML_OUT & "' , 'UploadAttach' , ',height=300,width=600' );"" "
                    strHTML_OUT = strHTML_OUT & "/>" & vbCrLf

                End If

                strHTML_OUT = strHTML_OUT & "</td>"
                strHTML_OUT = strHTML_OUT & "</tr>"
            Else
                If vEditable And printmode = False Then
                    strHTML_OUT = strHTML_OUT & "<input class=""" & Style & "_button"" type=""button"" name=""" & name & "_V_BTN"" id=""" & name & "_V_BTN"" "
                    strHTML_OUT = strHTML_OUT & " alt=""Inserisci allegato"" value=""..."" "
                    strHTML_OUT = strHTML_OUT & " onclick=""javascript:"
                    strHTML_OUT = strHTML_OUT & "ExecFunction( '"
                    strHTML_OUT = strHTML_OUT & AfCommon.Tools.EncodeTools.HTMLencode(Path & "CTL_Library/functions/field/UploadAttach.asp?OPERATION=INSERT&FIELD=" & name & "&PATH=" & AfCommon.Tools.EncodeTools.URLencode(Path) & "&FORMAT=" & AfCommon.Tools.EncodeTools.URLencode(format))

                    'If Not Domain Is Nothing Then
                    '    strHTML_OUT =HtmlEncode("&DOMAIN=" & HtmlEncode(Domain.id)))
                    'End If

                    '-- se è richiesta la cifratura
                    If InStr(1, strFormatRipulita, "C") > 0 Then
                        strHTML_OUT = strHTML_OUT & AfCommon.Tools.EncodeTools.HTMLencode("&IDDOC=' + getObjValue('IDDOC') + '&CIF=1")
                    End If

                    strHTML_OUT = strHTML_OUT & "' , 'UploadAttach' , ',height=300,width=600' );"" "
                    strHTML_OUT = strHTML_OUT & "/>" & vbCrLf

                End If
            End If

            '-- se è richiesta la visualizzazione dell'hash
            If InStr(1, strFormatRipulita, "H") > 0 And value <> "" Then

                '-- se nella forma tecnica è presente l'hash
                If UBound(v) >= 5 Then

                    Dim algoritmoHash As String
                    Dim hashFile As String

                    algoritmoHash = v(4)
                    hashFile = v(5)

                    strHTML_OUT = strHTML_OUT & "<tr>"
                    strHTML_OUT = strHTML_OUT & "<td>"
                    strHTML_OUT = strHTML_OUT & "<span class=""attach_info_hashfile"" title=""L'algoritmo di hash utilizzato &egrave; " & algoritmoHash & """>"
                    strHTML_OUT = strHTML_OUT & UCase(hashFile)
                    strHTML_OUT = strHTML_OUT & "</span>"
                    strHTML_OUT = strHTML_OUT & "</td>"
                    strHTML_OUT = strHTML_OUT & "</tr>"

                End If

            End If

            strHTML_OUT = strHTML_OUT & "</table>"

            '--chiusura div contenitore
            strHTML_OUT = strHTML_OUT & "</div>"

            Return strHTML_OUT

        End Function

        ''-- FUNZIONE DA RIMAPPARE/IMPLEMETNARE/GESTIRE COME MEGLIO CREDI IN UN MODULO COMUNE 
        'Public Function HtmlEncode(ByVal str As String) As String
        '    Return str
        'End Function

        ''-- FUNZIONE DA RIMAPPARE/IMPLEMETNARE/GESTIRE COME MEGLIO CREDI IN UN MODULO COMUNE 
        'Public Function HtmlEncodeJSValue(ByVal str As String) As String
        '    Dim s As String

        '    s = CStr(str)

        '    s = Replace(str, "\", "\\")
        '    s = Replace(str, "'", "\'")

        '    HtmlEncodeJSValue = s

        'End Function

        ''-- FUNZIONE DA RIMAPPARE/IMPLEMETNARE/GESTIRE COME MEGLIO CREDI IN UN MODULO COMUNE 
        'Public Function UrlEncode(ByVal str As String) As String
        '    Return str
        'End Function

        ''--da utilizzare per inserire il valore nei tag
        'Public Function HtmlEncodeValue(ByVal str As String) As String

        '    Dim s As String

        '    s = CStr(str)

        '    s = Replace(str, """", "&#34;")

        '    HtmlEncodeValue = s

        'End Function

    End Class
End Namespace

