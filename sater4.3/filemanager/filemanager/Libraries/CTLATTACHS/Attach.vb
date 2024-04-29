Imports System.Collections.Specialized
Imports StorageManager

Public Class Attach

    ''' <summary>
    ''' Route di Upload Attach
    ''' </summary>
    ''' <param name="ORIGINALFILE">Blob del file caricato dall'utente</param>
    ''' <param name="query">HashTable contenente tutti i parametri ricevuti dalla richiesta iniziale per il trattamento del file</param>
    ''' <param name="idPfu">Id dell'utente che ha caricato il file</param>
    ''' <returns></returns>
    Public Shared Function UploadAttach(jobid As String, ORIGINALFILE As BlobEntryModelType, query As Hashtable, idPfu As String, sourceDbm As CTLDB.DatabaseManager) As AfCommon.ComplexResponseModelType

        Dim idDoc As String = ""
        Dim bSaltaControlli As Boolean = False

        If Not String.IsNullOrWhiteSpace(query("IDDOC")) Then
            idDoc = CStr(query("IDDOC"))
        ElseIf Not String.IsNullOrWhiteSpace(CStr(query(19))) Then
            idDoc = CStr(query(19))
        End If
        '-- SE CIF=1 si sta chiedendo la cifratura del file
        Dim strCifrato As String = "0"
        If Not String.IsNullOrWhiteSpace(query("CIF")) Then
            strCifrato = CStr(query("CIF"))
        ElseIf Not String.IsNullOrWhiteSpace(CStr(query(22))) Then
            strCifrato = CStr(query(22))
        End If
        If CStr(strCifrato) = "" Then
            strCifrato = "0"
        End If

        '-- Se CIF=1 abbiamo bisogno anche del parametro IDDOC avvalorato e diverso da NEW%
        If Left(strCifrato, 1) = "1" And (idDoc = "" Or idDoc.Contains("NEW")) Then

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                Dbm.AppendOperation("do il messaggio di errore per richiesta cifratura ma senza iddoc")
                Dbm.RunException("0#Prima di allegare salvare il documento~YES_ML", Nothing)
            End Using

        End If


        Dim strFormat As String = query("FORMAT")
        If InStr(1, strFormat, "EXT:") > 0 Then
            Dim a As String
            Dim ix As Integer
            Dim ix2 As Integer
            ix = InStr(1, strFormat, "EXT:")
            ix2 = InStr(ix + 1, strFormat, "-")
            a = Mid(strFormat, ix, ix2 - ix + 1)
            strFormat = Replace(strFormat, a, "")
        End If

        '-- se è stato richiesto il salto dei controlli sul file ( di firma, di contenuto e di hash )
        If InStr(1, strFormat, "J") > 0 Then
            bSaltaControlli = True
        End If

        Dim WQ As BlobEntryModelType = InsertCTL_Attach(jobid, ORIGINALFILE, sourceDbm, strCifrato, idDoc)

        If InStr(1, strFormat, "V") > 0 And bSaltaControlli = False Then

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                Call Dbm.AppendOperation("Verifico se è un allegato con firma digitale")
                Do_VerificaFirma(Dbm, ORIGINALFILE, WQ.id, idPfu, strFormat, "", "", query)

                '-- la libreria FileSignatures non verifica i file p7m quindi sfruttiamo la nostra verifica di firma per capirlo
                If ORIGINALFILE.extension.Trim(".").ToLower.Equals("p7m") And ORIGINALFILE._verificaEstensione.ToLower.Equals("NotVerified") = False Then

                    If WQ.settings.ContainsKey("id_row") Then

                        Try
                            Dim params As New Hashtable

                            params("@idRow") = WQ.settings("id_row")
                            params("@verExt") = ORIGINALFILE._verificaEstensione

                            Dbm.ExecuteNonQuery("UPDATE CTL_Attach set ATT_VerificaEstensione = @verExt where ATT_IdRow = @idRow", params)
                        Catch ex As Exception

                        End Try

                    End If

                End If




            End Using



            '-- Se è stato richiesto il blocco in caso di verifica errata
            If InStr(1, strFormat, "B") > 0 Then

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                    Dbm.AppendOperation("verifico se la firma è buona")

                    Dim strSql As String = "select isvalidSign from ctl_sign_attach_info with(nolock) where att_hash = '" & Replace(WQ.id, "'", "''") & "' and isvalidSign = 1"

                    Call Dbm.TraceDB("Trovata format B. Verifico se il file è firmato e valido.select: '" & strSql & "'", "CTLATTACHS.UploadAttach")
                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSql, Nothing)

                        '-- se il file non ha il check di firma valida
                        If Not dr.Read Then


                            Call Dbm.TraceDB("Record di firma valida non trovato.", "CTLATTACHS.UploadAttach")
                            Dbm.AppendOperation("cancello l'allegato dalla base dati")

                            Dim params As New Hashtable
                            params("@att_hash") = WQ.id
                            Dbm.ExecuteNonQuery("delete from CTL_Attach where att_hash = @att_hash", params)

                            Dbm.AppendOperation("do il messaggio di errore")


                            Dim StrMotivoErrore As String = "Firma non valida o file corrotto~YES_ML"

                            '--controllo se non presente la firma testando il campo note=allegato non firmato
                            '--se diverso o la fima non valida oppure file corrotto
                            strSql = "select Note from ctl_sign_attach_info with(nolock) where att_hash = '" & Replace(WQ.id, "'", "''") & "' and isvalidSign = 0"


                            Using dr1 As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSql, Nothing)

                                If dr1.Read Then

                                    '--va modificato il controllo se viene modificata la dicitura "Allegato non firmato." nella file signutils.vb
                                    '--nella funzione verifyPdfSigned
                                    If dr1("Note") = "Allegato non firmato." Then

                                        StrMotivoErrore = "Attenzione il file inserito non risulta firmato digitalmente~YES_ML"

                                    End If
                                End If

                            End Using


                            Dbm.RunException(StrMotivoErrore, Nothing)

                        End If
                    End Using

                End Using

            End If


        End If

        If bSaltaControlli Then

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                Call Dbm.AppendOperation("Recuperiamo l'idazi a partire dall'idpfu prima di inserire la sentinella di sign pending")

                Dim params As New Hashtable
                Dim idAzi As Integer = 0

                params("@idpfu") = idPfu

                Try
                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select pfuidazi from profiliutente with(nolock) where idpfu = @idpfu", params)
                        If dr.Read Then
                            idAzi = CStr(dr("pfuidazi"))
                        End If
                    End Using
                Catch ex As Exception
                End Try

                params.Clear()

                Call Dbm.AppendOperation("Inserimento del record fittizio nella CTL_SIGN_ATTACH_INFO")

                params("@att_hash") = WQ.id
                params("@nomeFile") = WQ.filename
                params("@idAzi") = idAzi

                Dbm.ExecuteNonQuery("INSERT INTO CTL_SIGN_ATTACH_INFO ( ATT_Hash, nomeFile, statoFirma, idazi, HASH_PDF_FIRMA, CF_ATTESO ) values ( @att_hash, @nomeFile, 'SIGN_PENDING', @idAzi, NULL, NULL )", params)

            End Using

        End If

        Return New AfCommon.ComplexResponseModelType(True, "", WQ.settings("techvalue"))

    End Function

    ''' <summary>
    ''' Route di Upload Attach Signed
    ''' </summary>
    ''' <param name="sourceDbm"></param>
    ''' <param name="ORIGINALFILE">Blob del file caricato dall'utente</param>
    ''' <param name="query">HashTable contenente tutti i parametri ricevuti dalla richiesta iniziale per il trattamento del file</param>
    ''' <param name="idPfu">Id dell'utente che ha caricato il file</param>
    ''' <returns></returns>
    Public Shared Function UploadAttachSign(jobid As String, ORIGINALFILE As BlobEntryModelType, query As Hashtable, idPfu As String, sourceDbm As CTLDB.DatabaseManager) As AfCommon.ComplexResponseModelType

        Dim out As New AfCommon.ComplexResponseModelType(False, "", "")

        Dim idDoc As String = ""
        Dim strCifrato As String = "0"
        Dim jumpVerifySign As String = ""
        Dim strTable As String = ""
        Dim strArea As String = ""
        Dim IsSigned As Boolean = False
        Dim codiceFiscale As String = ""
        Dim sign_or_attach As String = ""

        idDoc = CStr(query("IDDOC"))

        '-- SE CIF=1 si sta chiedendo la cifratura del file
        strCifrato = CStr(query("CIF"))

        If CStr(strCifrato) = "" Then
            strCifrato = "0"
        End If

        jumpVerifySign = CStr(query("jumpsign"))
        strTable = CStr(query("TABLE"))
        strArea = CStr(query("AREA"))

        If CStr(query("OPERATION")) = "INSERTSIGN" Then
            IsSigned = True
        End If

        Dim disattivaControlloCF As String = "NO"
        'CStr(query("DISATTIVA_CONTROLLO_CF_FIRMA"))

        Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

            Try
                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select DZT_ValueDef from LIB_Dictionary where DZT_Name='SYS_DISATTIVA_CONTROLLO_CF_FIRMA'", Nothing)
                    If dr.Read Then
                        disattivaControlloCF = CStr(dr("DZT_ValueDef"))
                    End If
                End Using
            Catch ex As Exception
            End Try

        End Using




        '-- Se non è stato chiesto di disattivare questo controllo
        If CStr(UCase(disattivaControlloCF)) <> "YES" Then
            codiceFiscale = CStr(query("CF"))
        End If

        sign_or_attach = CStr(query("SIGN_OR_ATTACH"))


        Dim saveHash As String = CStr(query("SAVE_HASH"))
        Dim strColName As String = "SIGN_HASH"
        If Trim(strArea) <> "" Then
            strColName = strArea & "_" & strColName
        End If
        Dim strIdentity As String = "ID"

        If Not String.IsNullOrWhiteSpace(query("IDENTITY")) Then
            strIdentity = query("IDENTITY")
        End If

        Dim bSaltaControlli As Boolean = False
        Dim bControlloOnlyHash As Boolean = False

        Dim strFormat As String = CStr(query("FORMAT"))

        If InStr(1, strFormat, "EXT:") > 0 Then

            Dim a As String
            Dim ix As Integer
            Dim ix2 As Integer

            ix = InStr(1, strFormat, "EXT:")
            ix2 = InStr(ix + 1, strFormat, "-")
            a = Mid(strFormat, ix, ix2 - ix + 1)
            strFormat = Replace(strFormat, a, "")

        End If

        bSaltaControlli = False
        bControlloOnlyHash = False


        '-- se è stato richiesto il salto dei controlli sul file ( di firma, di contenuto e di hash )
        If InStr(1, strFormat, "J") > 0 Then
            bSaltaControlli = True
        End If

        '-- se è stato richiesto il controllo sul file solo di bontà dell'hash
        If InStr(1, strFormat, "S") > 0 Then
            bControlloOnlyHash = True
        End If

        Dim firmaOk As Boolean = True


        Dim INSERTED As BlobEntryModelType = Nothing

        '-- se è stato passato il parametro di jumpsign o la format J, saltiamo qualsiasi controllo ed alleghiamo direttamente
        If jumpVerifySign <> "" Or bSaltaControlli = True Then

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                Call Dbm.TraceDB("Richiesto JUMPSIGN", "CTLATTACHS.UploadAttachSign")
                '--salvo il file in base dati
                Dbm.AppendOperation("salvo il file in base dati")
            End Using

            INSERTED = InsertCTL_Attach(jobid, ORIGINALFILE, sourceDbm, strCifrato, idDoc)
            '-- Costruisco il valore tecnico
            '--gestione del field per aggiornare l'attributo a video

            Dim strColAttachSign As String = "SIGN_ATTACH"
            If strArea <> "" Then
                strColAttachSign = strArea & "_" & strColAttachSign
            End If


            Dim params As New Hashtable

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                '--aggiorno sul documento la codifca tecnica dell 'allegato di firma
                Dbm.AppendOperation("aggiorno sul documento la codifca tecnica dell 'allegato di firma")

                Dim strSql As String = "update " & Replace(strTable, " ", "") & " set " & strColAttachSign & "= @techvalue Where " & Replace(strIdentity, " ", "") & " = @iddoc"

                params("@techvalue") = INSERTED.settings("techvalue")
                params("@iddoc") = CLng(idDoc)
                Dbm.AppendOperation("aggiorno sul documento la codifica tecnica dell 'allegato di firma [" & strSql & "]")
                Dbm.ExecuteNonQuery(strSql, params)

            End Using


            If bSaltaControlli = True Then

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                    Try
                        '--recupero hash del pdf salvato sul documento
                        Dbm.AppendOperation("recupero hash del pdf salvato sul documento:table=" & strTable & "-iddoc=" & idDoc)

                        Dim strImprontaPDF As String = ""
                        Dim Getparams As New Hashtable
                        Getparams("@iddoc") = CLng(idDoc)
                        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select " & Replace(strColName, " ", "") & "  From " & Replace(strTable, " ", "") & " Where " & Replace(strIdentity, " ", "") & " = @iddoc", Getparams)
                            If dr.Read Then
                                strImprontaPDF = dr(strColName)
                            End If
                        End Using

                        params.Clear()

                        Dim IdAzi As Integer = 0

                        params("@idpfu") = idPfu

                        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select pfuidAzi from profiliutente where idpfu = @idpfu", params)
                            If dr.Read Then
                                IdAzi = CStr(dr("pfuidAzi"))
                            End If
                        End Using

                        Call Dbm.AppendOperation("Inserimento del record fittizio nella CTL_SIGN_ATTACH_INFO")

                        params("@att_hash") = INSERTED.id
                        params("@nomeFile") = INSERTED.filename
                        params("@idAzi") = IdAzi

                        Dbm.ExecuteNonQuery("INSERT INTO CTL_SIGN_ATTACH_INFO ( ATT_Hash, nomeFile, statoFirma, idazi, HASH_PDF_FIRMA, CF_ATTESO ) values ( @att_hash, @nomeFile, 'SIGN_PENDING', @idAzi, NULL, NULL )", params)


                    Catch ex As Exception

                    End Try

                End Using



            End If

            Return New AfCommon.ComplexResponseModelType(True, "", INSERTED.settings("techvalue"))

        Else


            Select Case ORIGINALFILE.extension.Trim(".").ToLower
                Case "pdf"

                    If String.IsNullOrWhiteSpace(ORIGINALFILE.pdfhash) Then
                        If saveHash = "YES" Then
                            IsSigned = False
                        End If

                        Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                            ORIGINALFILE.pdfhash = PdfLibrary.PdfUtils.GetPdfHash(Dbm, ORIGINALFILE, IsSigned,, bControlloOnlyHash)
                        End Using

                        Dim params As New Hashtable
                        params("pdf_content_hash") = ORIGINALFILE.pdfhash

                        Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                            BlobManager.fx_save_blob(Dbm, ORIGINALFILE)
                        End Using

                    End If

                    Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                        Call Dbm.TraceDB("GIRO PDF. esito verifica firma : " & ORIGINALFILE.pdfhash, "CTLDB.LIB_DBATTACH.UPLOADATTACHSIGN")

                        If ORIGINALFILE.pdfhash.Trim.Split("#")(0) = "0" Then      'ERRORE
                            firmaOk = False
                            If CStr(sign_or_attach) = "" Then
                                If CStr(query("IDDOC")) <> "" Then
                                    out.out = "2#" & CStr(Split(ORIGINALFILE.pdfhash, "#")(1))
                                    'Rimosso "Pdf Hash: " dal messaggio  --> Dbm.RunException("Pdf Hash: " & ORIGINALFILE.pdfhash.Trim.Split("#")(1), Nothing)
                                    Dbm.RunException(ORIGINALFILE.pdfhash.Trim.Split("#")(1), Nothing)
                                Else
                                    out.out = "2#" & ORIGINALFILE.pdfhash.Trim.Split("#")(1)
                                End If
                                Return out
                            End If
                        Else

                            INSERTED = ORIGINALFILE

                        End If

                    End Using


                Case "p7m"

                    Dim PDF_FILE As BlobEntryModelType = Nothing

                    Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                        Call Dbm.TraceDB("GIRO P7M. Sto per effettuare la verifyP7M", "CTLDB.LIB_DBATTACH.UPLOADATTACHSIGN")
                        Dbm.AppendOperation("Rimuovo l'envelope P7M dal file firmato")
                        PDF_FILE = PdfLibrary.PdfUtils.ExtractP7M(Dbm, ORIGINALFILE, False)
                    End Using

                    Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                        Dbm.AppendOperation("Calcolo l'hash di contenuto sul file")
                        ORIGINALFILE.pdfhash = PdfLibrary.PdfUtils.GetPdfHash(Dbm, PDF_FILE, False)

                        If String.IsNullOrWhiteSpace(query("IDDOC")) Then
                            Dbm.RunException("2#Errore elaborazione file firmato~YES_ML", New Exception("2#Errore elaborazione file firmato"))
                        End If

                    End Using

                Case Else

                    Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                        Dbm.RunException("Tipo di file non ammesso~YES_ML", Nothing)
                    End Using

            End Select




            If UCase(saveHash) = "YES" Then

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                    Dbm.AppendOperation("salvo il file in base dati")
                End Using

                INSERTED = InsertCTL_Attach(jobid, ORIGINALFILE, sourceDbm, strCifrato, idDoc)
                INSERTED.pdfhash = ORIGINALFILE.pdfhash

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                    Dbm.AppendOperation("aggiorno sul documento l'hash dell'allegato")
                    Dim strSql As String = "update " & Replace(strTable, " ", "") & " set " & Replace(strColName, " ", "") & "= @pdf_hash WHERE " & Replace(strIdentity, " ", "") & " = @iddoc"
                    Dim params As New Hashtable
                    params("@pdf_hash") = INSERTED.pdfpureHash
                    params("@iddoc") = CLng(idDoc)
                    Dim affected As Integer = Dbm.ExecuteNonQuery(strSql, params)
                    Dim strColAttachSign As String = "SIGN_ATTACH"
                    If strArea <> "" Then
                        strColAttachSign = strArea & "_" & strColAttachSign
                    End If

                    Dbm.AppendOperation("aggiorno sul documento la codifca tecnica dell 'allegato di firma")
                    strSql = "update " & Replace(strTable, " ", "") & " set " & Replace(strColAttachSign, " ", "") & "= @techvalue Where " & Replace(strIdentity, " ", "") & " = @iddoc"
                    params = New Hashtable
                    params("@iddoc") = CLng(idDoc)
                    params("@techvalue") = INSERTED.settings("techvalue")         'TECHVALUE DELL'OGGETTO ORIGINALE INSERITO NEL DB
                    Dbm.AppendOperation("aggiorno sul documento la codifica tecnica dell 'allegato di firma [" & strSql & "]")
                    Dbm.ExecuteNonQuery(strSql, params)

                End Using

            End If

            Dim strImprontaSave As String = ""

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                '--recupero hash del pdf salvato sul documento
                Dbm.AppendOperation("recupero hash del pdf salvato sul documento:table=" & strTable & "-iddoc=" & idDoc)


                Dim Getparams As New Hashtable
                Getparams("@iddoc") = CLng(idDoc)
                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("Select " & Replace(strColName, " ", "") & "  From " & Replace(strTable, " ", "") & " Where " & Replace(strIdentity, " ", "") & " = @iddoc", Getparams)
                    If dr.Read Then
                        strImprontaSave = dr(strColName)
                    End If
                End Using

                Call Dbm.TraceDB("CONFRONTO TRA HASH", "CTLDB.LIB_DBATTACH.UPLOADATTACHSIGN")

            End Using



            '--se il file coincide allora salvo il file come allegato e la sua codifica tecnica sul documento
            '-- oppure se è stato chiesto di ignorare gli errori di firma non blocco o di salvare l'hash.
            If (CStr(sign_or_attach) <> "" OrElse UCase(saveHash) = "YES" OrElse (Not String.IsNullOrWhiteSpace(ORIGINALFILE.pdfhash) AndAlso ORIGINALFILE.pdfpureHash = strImprontaSave)) Then




                '-- se era passato save_hash ho gia messo l'allegato in base dati
                If UCase(saveHash) <> "YES" Then

                    Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                        '--salvo il file in base dati
                        Dbm.AppendOperation("salvo il file in base dati")

                    End Using

                    INSERTED = InsertCTL_Attach(jobid, ORIGINALFILE, sourceDbm, strCifrato, idDoc)
                    INSERTED.pdfhash = ORIGINALFILE.pdfhash

                End If

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                    'TODO: do_verifica_firma prende ancora tra i parametri l'oggetto DBM 
                    Do_VerificaFirma(Dbm, ORIGINALFILE, INSERTED.id, idPfu, strFormat, sign_or_attach, codiceFiscale, query, bControlloOnlyHash)

                End Using

                '--costruisco il valore tecnico
                out.techvalue = INSERTED.settings("techvalue")

                Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                    '--gestione del field per aggiornare l'attributo a video

                    Dim strColAttachSign As String = "SIGN_ATTACH"
                    If strArea <> "" Then
                        strColAttachSign = strArea & "_" & strColAttachSign
                    End If
                    '-- se era passato save_hash ho gia fatto questa update
                    If UCase(saveHash) <> "YES" Then
                        '--aggiorno sul documento la codifca tecnica dell 'allegato di firma
                        Dbm.AppendOperation("aggiorno sul documento la codifca tecnica dell 'allegato di firma")
                        Dim strSql As String = "update " & Replace(strTable, " ", "") & " set " & Replace(strColAttachSign, " ", "") & "= @techvalue WHERE " & Replace(strIdentity, " ", "") & " = @iddoc"
                        Dim pinsert As New Hashtable
                        pinsert("@techvalue") = out.techvalue
                        pinsert("@iddoc") = CLng(idDoc)
                        Dbm.AppendOperation("aggiorno sul documento la codifica tecnica dell 'allegato di firma [" & strSql & "]")
                        Dbm.ExecuteNonQuery(strSql, pinsert)
                    End If
                    out.out = "1#OK"
                    out.esit = True

                End Using

            Else
                If CStr(query("IDDOC")) <> "" Then

                    Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                        '--inserisco messaggio per dire che allegato nn corrispondente
                        Dbm.AppendOperation("inserisco messaggio per dire che allegato nn corrispondente")
                        Dbm.RunException("allegato inserito non corrispondente a quello generato e successivamente firmato digitalmente~YES_ML", Nothing)

                    End Using


                Else
                    out.out = "3#Allegato inserito non corrisponde a quello generato e successivamente firmato digitalmente"
                End If
            End If


        End If

        Return out

    End Function




    ''' <summary>
    ''' Registra il File nella Tabella CTL_Attach e restituisce le info di inserimento
    ''' tra cui il techvalue, l'att_hash( che è l'id del blob risultante)
    ''' </summary>
    ''' <param name="sourceDbm"></param>
    ''' <param name="B"></param>
    ''' <param name="cifra"></param>
    ''' <param name="idDoc"></param>
    ''' <returns></returns>
    Private Shared Function InsertCTL_Attach(jobid As String, B As BlobEntryModelType, sourceDbm As CTLDB.DatabaseManager,
                        Optional cifra As String = "0", Optional idDoc As String = "") As BlobEntryModelType

        Dim mp_idDoc As String = ""
        Dim WQ As BlobEntryModelType = Nothing
        Dim Encrypt As Boolean = cifra.Substring(0, 1) = "1"

        If Encrypt Then

            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

                Dbm.AppendOperation("If di cifratura file")
                If String.IsNullOrWhiteSpace(idDoc) OrElse idDoc.Contains("NEW") Then
                    Dbm.RunException("0#Prima di allegare salvare il documento~YES_ML", Nothing)
                End If
                Dim strTable As String = ""
                Dim s() As String = cifra.Trim.Split("~")
                Select Case s.Length
                    Case 1
                        strTable = "ctl_doc"
                    Case 2
                        strTable = s(1)
                End Select
                WQ = cifraFile(Dbm, B, idDoc, True, strTable, mp_idDoc)

            End Using

        Else
            WQ = B
        End If

        'INSERIMENTO DEI DATI NEL DB
        Dim params As New Hashtable
        Dim fields As New List(Of String)

        With fields
            .Add("ATT_OBJ") : params("@ATT_OBJ") = New Byte() {}
            .Add("ATT_Hash") : params("@ATT_Hash") = WQ.id
            .Add("ATT_Size") : params("@ATT_Size") = B.size.ToString
            .Add("ATT_Name") : params("@ATT_Name") = B.filename
            .Add("ATT_Type") : params("@ATT_Type") = B.extension.Trim(".")
            If Encrypt Then
                .Add("ATT_CIFRATO") : params("@ATT_CIFRATO") = 1
                .Add("ATT_IDDOC") : params("@ATT_IDDOC") = mp_idDoc
            End If
            .Add("ATT_FileHash") : params("@ATT_FileHash") = B.GetHashPart(AfCommon.Tools.SHA_Algorithm.SHA256)
            .Add("ATT_AlgoritmoHash") : params("@ATT_AlgoritmoHash") = AfCommon.Tools.SHA_Algorithm.SHA256.ToString
            .Add("ATT_VerificaEstensione") : params("@ATT_VerificaEstensione") = B._verificaEstensione
        End With

        Dim paramslist As New List(Of String)
        For Each f As String In fields
            paramslist.Add("@" & f)
        Next

        Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

            Dbm.ExecuteNonQuery("INSERT INTO CTL_ATTACH(" & String.Join(",", fields.ToArray) & ") VALUES (" & String.Join(",", paramslist.ToArray) & ")", params)
            Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT @@identity as id_row", Nothing) '-- per qualche motivo se metto scope_identity() al posto di @@identity, non funziona
                If dr.Read Then
                    WQ.settings("id_row") = dr("id_row")
                End If
            End Using

        End Using

        Dim techdatedatetime As DateTime? = Nothing

        Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)

            'SAVE DATAVALUE
            Dim updateparams As New Hashtable
            updateparams("@id_row") = WQ.settings("id_row")
            updateparams("@blobid") = WQ.id

            '--recupero hash del pdf salvato sul documento
            Dbm.AppendOperation("Aggiorno il campo ATT_OBJ su CTL_ATTACH record con ATT_IdRow:" & WQ.settings("id_row") & "BLOB:" & WQ.id)

            '-- se f.[data] dovesse essere nullo, executeNonQuery restituirà 0 e quindi lanceremo un eccezione.
            If Not Dbm.ExecuteNonQuery("    UPDATE att
                                        SET     att.ATT_OBJ = f.[data]
                                        FROM    CTL_ATTACH att with(nolock)
                                                INNER JOIN [" & CTLDB.DbClassTools.GetTableName(GetType(BlobEntryModelType)) & "]  f with(nolock)  on  f.id = @blobid
                                        WHERE   att.ATT_IdRow = @id_row and not f.[data] is null
                                        ", updateparams) = 1 Then

                '-- sganciamo il record vuoto ( privo di blob )
                updateparams("@blobid") = "-" & WQ.id
                Dbm.ExecuteNonQuery("UPDATE CTL_ATTACH set att_hash = @blobid where att_idRow = @id_row", updateparams)

                Dbm.RunException("Unable to write CTL_ATTACH Binary Data~YES_ML", New Exception("Unable to write CTL_ATTACH Binary Data"))

            Else
                Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT ATT_DataInsert FROM CTL_ATTACH with(nolock) WHERE ATT_IdRow = @id_row", updateparams)
                    While dr.Read
                        If Not techdatedatetime.HasValue Then
                            techdatedatetime = dr("ATT_DataInsert")
                        Else
                            Dbm.RunException("System Error on Multiple Idrow for :" & WQ.id, New Exception("System Error on Multiple Idrow for :" & WQ.id))
                        End If
                    End While
                End Using
            End If

            'BUILD TECHVALUE
            Dim techdatetimeString As String = ""
            With techdatedatetime.Value
                techdatetimeString = Format(.Year, "0000") & "-" & Format(.Month, "00") & "-" & Format(.Day, "00") & "T" & Format(.Hour, "00") & ":" & Format(.Minute, "00") & ":" & Format(.Second, "00")
            End With
            WQ.settings("techvalue") = WQ.filename & "*" & WQ.extension.Trim(".") & "*" & B.size & "*" & WQ.id & "*" & AfCommon.Tools.SHA_Algorithm.SHA256.ToString & "*" & B.GetHashPart(AfCommon.Tools.SHA_Algorithm.SHA256) & "*" & techdatetimeString

            BlobManager.fx_save_blob(Dbm, WQ)

        End Using


        If Encrypt Then

            '----------------------------------------------------------------------------------------
            '--- EFFETTUO LA COPIA DI BACKUP DEL BLOB CIFRATO NELLA TABELLA CTL_ENCRYPTED_ATTACH ----
            '----------------------------------------------------------------------------------------
            params = New Hashtable
            params("@att_hash") = WQ.id
            Using Dbm As New CTLDB.DatabaseManager(False, sourceDbm, "", jobid, jobid)
                Dbm.ExecuteNonQuery("insert into CTL_Encrypted_Attach(att_idRow, att_obj ) select ATT_IdRow,ATT_Obj from CTL_Attach with(nolock) where att_hash = @att_hash", params)
            End Using

        End If

        Return WQ

    End Function


    ''' <summary>
    ''' Esegue la cifratura/decifratura di un blob restituendo un nuovo Blob Cifrato
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="idDoc"></param>
    ''' <param name="cifra"></param>
    ''' <param name="table"></param>
    ''' <param name="mp_idDoc"></param>
    ''' <returns></returns>
    Private Shared Function cifraFile(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, ByVal idDoc As String, ByVal cifra As Boolean, Optional table As String = "ctl_doc", Optional ByRef mp_idDoc As String = "") As BlobEntryModelType
        '-- salvo l'idDoc passato come parametro nella variabile locale
        mp_idDoc = idDoc
        Dbm.AppendOperation("Invocazione getChiaveDiCifratura")
        If cifra Then
            Dbm.AppendOperation("Invocazione cifraturaFile per " & B.id)
            'cifraFile = obj.cifraturaFile(pathFileInput, pathFileOutput, cryptoKey, True, "")
            Dim encryptionkey As String = getChiaveDiCifratura(Dbm, idDoc, table, mp_idDoc)
            Dim RET As BlobEntryModelType = BlobManager.Get_Encrypted_Blob_Copy(Dbm, B, encryptionkey, True)
            Dbm.AppendOperation("Faccio un test di decifratura")
            'TEST DECIFRATURA
            'Dim decryptionkey As String = getChiaveDiCifratura(Dbm, idDoc, table, mp_idDoc)
            Dim DF As BlobEntryModelType = BlobManager.Get_Decrypted_Blob_Copy(Dbm, RET, encryptionkey, False)
            If Not DF.GetHash(AfCommon.Tools.SHA_Algorithm.SHA256) = B.GetHash(AfCommon.Tools.SHA_Algorithm.SHA256) Then
                Dbm.RunException("Unable to Decrypt File idDoc:" & idDoc, New Exception("Unable to Decrypt File idDoc:" & idDoc))
            End If
            BlobManager.fx_delete_blob(Dbm, DF.id)
            Return RET
        Else
            Dbm.AppendOperation("Invocazione DeCifraturaFile per " & B.id)
            Dim ClearFile As String = BlobManager.GetPureFileOnDisk(Dbm, B, True)
            Dim decryptionkey As String = getChiaveDiCifratura(Dbm, idDoc, table, mp_idDoc)
            Return BlobManager.Get_Decrypted_Blob_Copy(Dbm, B, decryptionkey, True)
        End If
    End Function


    'Legge la chiave di cifratura per il file
    Private Shared Function getChiaveDiCifratura(Dbm As CTLDB.DatabaseManager, idDoc As String, table As String, ByRef mp_idDoc As String) As String
        Dim ret As String = ""

        'Dim strSql As String = "select [guid] as chiave "
        ''-- se è stata passata una vista "custom" per recuperare il guid
        'If Not table.ToLower = "ctl_doc" Then
        'strSql = strSql & ",idDoc" '-- aggiungo la colonna che mi restituisce l'id del documento dal quale è stato recuperato il guid
        'End If
        'strSql = strSql & " from " & Replace(table, " ", "") & " WHERE id = @id "

        Dim idpfu As Integer

        If Dbm.getIdpfu().HasValue Then
            idpfu = Dbm.getIdpfu()
        Else
            idpfu = -1
        End If

        Dim strSQL As String = "Exec AFS_CRYPT_KEY_ATTACH @idpfu , @id , @table"

        Dim params As New Hashtable
        params("@idpfu") = idpfu
        params("@id") = idDoc
        params("@table") = table

        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSQL, params)
            If dr.Read Then

                If Not table.ToLower = "ctl_doc" Then
                    '-- sovrascrivo l'idDoc recuperato dalla vista invece di utilizzare quello passato come parametro alla pagina di upload
                    mp_idDoc = CStr(dr("idDoc"))
                End If
                'ret = "{" & dr("chiave").ToString.ToUpper & "}" '-- retro compatibilità vb6 riimossa perchè adesso chiamiamo una stored per il ritorno della chiave ed è sempre una stringa invece che uno uniqueidentifier
                ret = dr("chiave").ToString.ToUpper
            Else
                Dbm.RunException("errore recupero chiave di cifratura on " & idDoc & "@" & table, New Exception("errore recupero chiave di cifratura on " & idDoc & "@" & table))
            End If
        End Using

        Return ret
    End Function


    ''' <summary>
    ''' Verifica la validità del certificatore
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="giroFirma"></param>
    ''' <param name="hash"></param>
    ''' <returns></returns>
    Private Shared Function isValidCertificatore(Dbm As CTLDB.DatabaseManager, giroFirma As Boolean, hash As String) As String

        '2 : Da settare sulla sys come default. aggiungo blocco certificatore su giro firma ( con o senza verifica hash, quindi anche se giroFirma = false )
        '1 : Default per assenza della sys. Dove controlliamo l'hash ( giroFirma = true) , aggiungo blocco su certificatore
        '0 : Comportamento attuale, senza blocco del certificatore

        Dim sysVerifica As String = ""
        Dim res As String = ""
        '-- Il default è un OK

        'TODO: Verificare questa cosa
        'sysVerifica = CStr(ApplicationASP("VERIFICA_CERTIFICATORE"))
        sysVerifica = Dbm.getDbSYS("VERIFICA_CERTIFICATORE")


        If sysVerifica = "" Then
            sysVerifica = "1"
        End If

        If sysVerifica = "0" Then
            res = ""
        Else

            If (giroFirma = True And sysVerifica = "1") Or (sysVerifica = "2") Then

                Using rsCheck As SqlClient.SqlDataReader = Dbm.ExecuteReader(CStr("select isnull(isTrustedCA,1) as isTrustedCA, isnull(isCertificatoSottoscrizione,0) as isCertificatoSottoscrizione from CTL_SIGN_ATTACH_INFO with (nolock) where att_hash='" & Replace(hash, "'", "''") & "' and isnull(isvalidsign,0) = 1 "), Nothing)
                    res = String.Empty
                    'If rsCheck.Read Then
                    While rsCheck.Read
                        If rsCheck("isTrustedCA") = 1 And rsCheck("isCertificatoSottoscrizione") = 1 Then
                            res = ""
                        Else
                            '-- Specializzo l'output in 3 possibili messaggi di blocco.
                            If rsCheck("isTrustedCA") = 0 And rsCheck("isCertificatoSottoscrizione") = 0 Then
                                res = "errore_isTrustedCA_e_isCertificatoSottoscrizione" '-- Non è una CA valida E non è un certificato di sottoscrizione
                            ElseIf rsCheck("isTrustedCA") = 0 Then
                                res = "errore_isTrustedCA" '-- Non è una CA valida
                            ElseIf rsCheck("isCertificatoSottoscrizione") = 0 Then
                                res = "errore_isCertificatoSottoscrizione" '-- Non è un certificato di sottoscrizione
                            End If
                        End If
                        If res <> "" Then
                            Exit While
                        End If
                    End While
                    'Else
                    'res = String.Empty
                    'End If
                End Using
            Else
                res = ""
            End If

        End If
        Return res
    End Function





    '--visualizza l'allegato a partire dall'identificativo di riga della tabella CTL_ATTACH
    Public Shared Function DisplayAttach(Dbm As CTLDB.DatabaseManager, query As Hashtable, idPfu As String, useragent As String) As AfCommon.DisplayAttachResponseModelType
        Dim ret As New AfCommon.DisplayAttachResponseModelType()
        ret.decifrato = True
        '--recupero valore tecnico attributo
        Dim strTechValue As String = query("TECHVALUE")
        Dim strType As String = ""
        Dim Att_Hash As String = ""
        Dim escludiBusta As String = ""
        If Not String.IsNullOrWhiteSpace(strTechValue) Then
            Dim aInfo As String() = Split(strTechValue, "*")
            '--recupero id attach
            'lIdAttach = aInfo(0)    
            '--recupero nome file
            ret.filename = aInfo(0)
            '--recupero type file
            strType = aInfo(1)
            '--recupero guid
            Att_Hash = aInfo(3)
            '--recupero formattazione            
            escludiBusta = UCase(CStr(query("ESCLUDI_BUSTA")))
        Else
            Select Case query("mode")
                Case "ESCLUDI_BUSTA"
                    escludiBusta = "YES"
                    Att_Hash = query("ATT_HASH")
                    ret.filename = query("NOMEFILE")
                Case Else
                    Throw New NotImplementedException("Mode not Implemnted : " & query("mode"))
            End Select
        End If



        Dim strFormat As String = query("FORMAT")
        Call Dbm.TraceDB("Inizio metodo displayAttach()", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
        If InStr(1, strFormat, "EXT:") > 0 Then
            Dim a As String
            Dim ix As Integer
            Dim ix2 As Integer
            ix = InStr(1, strFormat, "EXT:")
            ix2 = InStr(ix + 1, strFormat, "-")
            a = Mid(strFormat, ix, ix2 - ix + 1)
            strFormat = Replace(strFormat, a, "")
        End If


        Dbm.AppendOperation("Eseguo la select di recupero dell'allegato")
        '--recupero binario del file
        Dim params As New Hashtable
        params("@att_hash") = Att_Hash
        Dim HasData As Boolean = False
        'VERIFICA SE CI SONO DATI
        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select ATT_Type,ATT_CIFRATO,ATT_IDDOC,ATT_Name,
                                                                        HasData =   CASE 
                                                                                        WHEN NOT ATT_Obj IS NULL THEN CAST(1 as bit) 
                                                                                        ELSE CAST(0 as bit) 
                                                                                    END 
                                                                from ctl_Attach with(nolock) where ATT_Hash = @att_hash", params)
            If dr.Read AndAlso dr("HasData") Then
                If String.IsNullOrWhiteSpace(strType) Then
                    strType = dr("ATT_Type")
                End If
                If String.IsNullOrWhiteSpace(ret.filename) Then
                    ret.filename = dr("ATT_Name")
                End If
                Dim DBFILE As BlobEntryModelType = Nothing
                Using drb As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT Att_Obj from ctl_Attach with(nolock) where ATT_Hash = @att_hash", params)
                    If drb.Read Then
                        DBFILE = BlobManager.create_blob_from_dbfield(Dbm, drb, "ATT_Obj", dr("ATT_Name"), True)
                    End If
                End Using
                Dim cifrato As Integer
                Dim idDoc As Long
                cifrato = 0
                idDoc = -1000
                cifrato = dr("ATT_CIFRATO")
                Call Dbm.TraceDB("Query di recupero sulla ctl_attach eseguita e record ritornato con successo", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                Dim OUTFILE As BlobEntryModelType = Nothing
                '-- se la colonna ATT_CIFRATO è presente ed è uguale ad 1 ( l'allegato è cifrato) o a 2 ( è stata richiesta l'apertura delle buste )
                If cifrato = 1 Or cifrato = 2 Then
                    idDoc = dr("ATT_IDDOC")
                    '------------------------------------------------------------------------------------
                    '--- Controllo se l'utente che sta richiedendo il file decifrato è autorizzato  -----
                    '------------------------------------------------------------------------------------
                    Dbm.AppendOperation("Eseguo la select di controllo sul possesso del file cifrato")
                    Dim strSql As String = "select id from ctl_doc with (nolock) where id = " & CStr(idDoc) & " and ( idpfu = " & CStr(idPfu) & " or idpfuincharge = " & CStr(idPfu) & " )"
                    Call Dbm.TraceDB("Il file è cifrato. eseguo la select di controllo : " & strSql, "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                    Using druser As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSql, Nothing)
                        If druser.Read OrElse cifrato = 2 Then
                            '-- se l'utente è autorizzato alla decifratura o il file è stato già messo in pending per essere decifrato
                            'D:\PortaleGareTelematiche\Allegati\
                            Dbm.AppendOperation("Salvo il file sul disco")
                            Dim decryptionkey As String = getChiaveDiCifratura(Dbm, idDoc, "ctl_doc", idDoc)
                            '--decifro il file
                            OUTFILE = cifraFile(Dbm, DBFILE, idDoc, False)
                            '-- Segnalo la presenza del file decifrato su disco, manderemo quindi quello all'utente e non il blob in base dati
                            ret.decifrato = False
                        Else
                            Dbm.RunException("Download del file non consentito~YES_ML", Nothing)
                        End If
                    End Using
                Else                    'FILE NON CIFRATO IN BASE DATI
                    OUTFILE = DBFILE
                    ret.decifrato = True
                End If
                ret.blobid = OUTFILE.id

                '--costruisco l'header del file restituito
                Select Case LCase(strType)
                    Case LCase("bmp")
                        ret.contenttype = "image/x-xbitmap"
                    Case LCase("jpg")
                        ret.contenttype = "image/jpeg"
                    Case LCase("pdf")
                        ret.contenttype = "application/pdf"
                    Case LCase("doc")
                        ret.contenttype = "application/msword"
                    Case LCase("zip")
                        ret.contenttype = "application/zip"
                    Case Else
                        ret.contenttype = "application/x-AFLink"
                End Select

                '-- Con firefox se il nome del file contiene uno spazio il file in output avrà un filename sbagliato, senza estensione e si fermerà fino al primo spazio.
                '-- la correzione più corretta sarebbe fare un encode del nome file ma non garantisce una retrocompatibiltà maggiore ( i vecchi browser non supportano questa encode)
                '-- testo lo useragent e se è firefox sostituisco gli spazi con _

                'If MyInStr(CStr(userAgent), "firefox") > 0 Then
                '    strFileName = MyReplace(strFileName, " ", "_")
                'End If



                '--restituisco il file
                'Response.BinaryWrite rsAttach.Fields.Item("ATT_Obj").GetChunk(rsAttach.Fields("ATT_Obj").ActualSize)

                '-- se il file in base dati è già decifrato mandiamo quello
                Dbm.AppendOperation("Salvo il file sul disco prima di sbustarlo")
                If ret.decifrato = True Then
                    If escludiBusta = "YES" And ret.filename.ToLower.EndsWith(".p7m") Then
                        Call Dbm.TraceDB("Inizio operazioni per escludi busta", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                        Call Dbm.TraceDB("File originale salvato con successo : '" & ret.blobid & "' . Invoco il metodo togliBustaP7M", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                        Dbm.AppendOperation("Sbusto il file p7m")
                        'Call togliBustaP7M(tempfilepath, query)
                        OUTFILE = PdfLibrary.PdfUtils.ExtractP7M(Dbm, OUTFILE, True)
                        ret.blobid = OUTFILE.id
                        ret.filename = OUTFILE.filename
                        Call Dbm.TraceDB("metodo togliBustaP7M concluso. err.description : '" & CStr(Err.Description) & "' . invoco il metodo writeToOutput", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                        Dbm.AppendOperation("porto il output il file p7m sbustato")
                        'Call Dbm.traceDB("Metodo writeToOutput concluso. passo a cancellare il file '" & percorsoFile & "' dal disco", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", query)
                        'strCause = "cancello il file decifrato dal filesystem"                           
                    End If
                Else
                    If escludiBusta = "YES" And ret.filename.ToLower.EndsWith(".p7m") Then
                        Dbm.AppendOperation("Sbusto il file p7m")
                        Call Dbm.TraceDB("Invoco il metodo togliBustaP7M", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                        'Call togliBustaP7M(fileDeCifrato, session, strConnectionString)
                        OUTFILE = PdfLibrary.PdfUtils.ExtractP7M(Dbm, OUTFILE, True)
                        ret.blobid = OUTFILE.id
                        ret.filename = OUTFILE.filename
                    End If
                    Call Dbm.TraceDB("Invoco il metodo writeToOtput", "CTLDB.LIB_DBATTACH.DISPLAYATTACH")
                    Dbm.AppendOperation("porto il output il file decifrato")
                    'Call writeToOutput(response, fileDeCifrato)

                    'strCause = "cancello il file decifrato dal filesystem"
                    'Kill fileDeCifrato

                    'Call tabManage.traceDB("File '" & fileDeCifrato & "' cancellato", "CTLDB.LIB_DBATTACH.DISPLAYATTACH", session, strConnectionString)
                End If

                If InStr(strFormat, "O") > 0 Then
                    '--faccio aprire il file direttamente        
                    If escludiBusta = "YES" And ret.filename.ToLower.EndsWith(".p7m") Then
                        ret.headers.Add("Content-Disposition", "inline; filename=""" & Replace(ret.filename, ".p7m", "", , , vbTextCompare) & """")
                    Else
                        ret.headers.Add("Content-Disposition", "inline; filename=""" & ret.filename & """")
                    End If
                Else
                    '--faccio aprire la mascheria per il download                    
                    If escludiBusta = "YES" And ret.filename.ToLower.EndsWith(".p7m") Then
                        ret.headers.Add("Content-Disposition", "attachment; filename=""" & Replace(ret.filename, ".p7m", "", , , vbTextCompare) & """")
                    Else
                        ret.headers.Add("Content-Disposition", "attachment; filename=""" & ret.filename & """")
                    End If
                End If
            End If
        End Using
        Return ret
    End Function


    ''' <summary>
    ''' Verifica la firma presente in un file PDF/P7M
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="FILETOCHECK"></param>
    ''' <param name="Att_Hash"></param>
    ''' <param name="idPfu"></param>
    ''' <param name="strFormat"></param>
    ''' <param name="sign_or_attach"></param>
    ''' <param name="codicefiscale"></param>
    ''' <param name="query"></param>
    Public Shared Sub Do_VerificaFirma(Dbm As CTLDB.DatabaseManager, FILETOCHECK As BlobEntryModelType, Att_Hash As String, idPfu As String, strFormat As String, sign_or_attach As String, codicefiscale As String, query As Hashtable, Optional bControlloOnlyHash As Boolean = False)
        Dbm.fx_update_queue_operation("Checking PDF Signature", 0)

        Dim IdAzi As String = ""
        Dim params As New Hashtable
        params("@idpfu") = idPfu
        Try
            Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select pfuidAzi from profiliutente with(nolock) where idpfu = @idpfu", params)
                If dr.Read Then
                    IdAzi = CStr(dr("pfuidAzi"))
                End If
            End Using
        Catch ex As Exception
        End Try
        Dim checkfirmaresult As AfCommon.ComplexResponseModelType = Nothing
        Select Case FILETOCHECK.extension.ToLower
            Case ".pdf"
                checkfirmaresult = PdfLibrary.PdfUtils.verifyPdfSigned(Dbm, FILETOCHECK, Att_Hash, "", "", "", IdAzi)
            Case Else '".p7m" ( per i p7m o qualsiasi altra estensione )
                checkfirmaresult = PdfLibrary.PdfUtils.verifyP7MSigned(Dbm, FILETOCHECK, Att_Hash, "", "", "", IdAzi)
        End Select

        If Not IsNothing(checkfirmaresult) Then
            Call Dbm.TraceDB("Risposta di verifica estesa firma digitale : " & checkfirmaresult.out, "CTLDB.LIB_DBATTACH.UPLOADATTACH")
            Dbm.AppendOperation("verifico il certificatore")
            Dim esitotestfirma As String = isValidCertificatore(Dbm, False, Att_Hash)
            If Not String.IsNullOrWhiteSpace(esitotestfirma) And bControlloOnlyHash = False Then
                Dbm.RunException(Dbm.translate(esitotestfirma), Nothing)
            End If

            '-- Se l'url ha restituito un errore gestito
            If Right(checkfirmaresult.out, 1) = "0" Then
                '-- se è andata in errore la verifica della firma ed è stata passata la format B, cioè blocca in caso di verifica errata. cancello l'allegato
                If InStr(1, strFormat, "B") > 0 Then
                    Dbm.AppendOperation("cancello l'allegato dalla tabella")
                    If UCase(CStr(query("ATTIVA_FASE_DI_TEST"))) <> "YES" Then
                        params = New Hashtable
                        params("@att_hash") = Att_Hash
                        Dbm.ExecuteNonQuery("delete from CTL_Attach where att_hash = @att_hash", params)
                    End If
                End If
                Dbm.AppendOperation("cancello il file")
                If UCase(CStr(query("ATTIVA_FASE_DI_TEST"))) <> "YES" Then
                    'TODO: Delete WQ FILE                                                
                End If
                Call Dbm.TraceDB("Mando errore al client per verifica firma errata.MSG:" & checkfirmaresult.out, "CTLDB.LIB_DBATTACH.UPLOADATTACH")
                Dbm.RunException(checkfirmaresult.out, Nothing)
            End If

            If esitotestfirma <> "" And CStr(sign_or_attach) = "" And bControlloOnlyHash = False Then
                If CStr(query("IDDOC")) <> "" Then
                    Dbm.RunException(esitotestfirma, Nothing)
                Else
                    'UpLoadAttachSign = "3#File firmato con un certificatore non autorizzato dall'autority"
                    Dbm.RunException("3#" & esitotestfirma, Nothing)
                End If
            End If
            Dbm.AppendOperation("Verifica del codice fiscale del firmatario")

            '-- se è stato passato il codice fiscale controllo che sia presente tra i firmatari
            '-- una persona con quel codice fiscale
            If codicefiscale <> "" Then
                Using tempRs As SqlClient.SqlDataReader = Dbm.ExecuteReader(CStr("select top 1 codFiscFirmatario from CTL_SIGN_ATTACH_INFO with(nolock) where att_hash='" & Replace(Att_Hash, "'", "''") & "' and codFiscFirmatario like '%" & Replace(codicefiscale, "'", "''") & "%'"), Nothing)
                    If Not tempRs.Read And CStr(sign_or_attach) = "" Then
                        Dbm.RunException("Codice Fiscale del firmatario non corrispondente~YES_ML", Nothing)
                    End If
                End Using
            End If
        End If

    End Sub



End Class
