
Imports System.Security.Cryptography.X509Certificates

Imports iTextSharp.text.pdf
Imports iTextSharp.text.pdf.parser

Imports Org.BouncyCastle.X509
Imports Org.BouncyCastle.Tsp
Imports Org.BouncyCastle.Ocsp
Imports Org.BouncyCastle.X509.Store
Imports System.Data.SqlClient
Imports System.Data
Imports System.Configuration
Imports System.Reflection
Imports System.Security.Cryptography
Imports iTextSharp.text.pdf.security
Imports System.Xml
Imports System.Security.Cryptography.Pkcs
Imports Chilkat
Imports StorageManager

'-- *********************************************************************
'-- * Versione=1&data=2012-05-24&Attvita=&Nominativo=FedericoLeone *
'-- *********************************************************************

Namespace sign

    Public Class Utils

        Dim tsl_online As String = AfCommon.AppSettings.item("app.tsl_online")
        Dim outFile As String = AfCommon.AppSettings.item("app.directory_output_p7m")
        Dim pathTsl As String = AfCommon.AppSettings.item("app.path_xml_tsl")
        Dim urlTsl As String = AfCommon.AppSettings.item("app.url_xml_tsl")
        Dim table_info_sign As String = AfCommon.AppSettings.item("app.table_sign")
        Dim tslFromTable As String = AfCommon.AppSettings.item("app.tsl_da_tabella")
        Dim enableSignedCMS As String = AfCommon.AppSettings.item("app.enableSignedCMS")


        'Public isTrusted As Boolean = False
        'Public revoked As Integer = False
        'Public isExpired As Boolean = False
        'Public verificaFirma As Boolean = False
        'Public firmatario As String = ""
        'Public firmatarioInfo As String = ""
        'Public scadenzaFirma As Date
        'Public cnCertificatore As String = ""

        'Public totFirme As Integer = 0

        Public ATT_Hash As String = "NULL" 'chiave di aggancio per i documenti nuovi
        Public attIdMsg As String = "NULL" 'chiave di aggancio per i documenti generici
        Public attOrderFile As String = "NULL" 'chiave di aggancio per i documenti generici
        Public attIdObj As String = "NULL" 'chiave di aggancio per i documenti generici
        Public idAzi As String = "NULL"

        Public originalFileName As String = ""
        Private uniqueStr As String = ""
        Private Function IniRead(filename As String, k1 As String, k2 As String) As String
            'TODO: Implements This
        End Function

        Private Dbm As CTLDB.DatabaseManager = Nothing
        Sub New(Dbm As CTLDB.DatabaseManager)
            Me.Dbm = Dbm

            On Error Resume Next

            Dim path As String = (New System.Uri(Assembly.GetExecutingAssembly().CodeBase)).AbsolutePath
            Dim array As String()
            Dim nomeFile As String

            array = Split(path, "/")
            nomeFile = array(UBound(array))

            path = path.Replace(nomeFile, "")

            path = System.Web.HttpUtility.UrlDecode(path)

            If tsl_online Is Nothing Or CStr(tsl_online) = "" Then
                tsl_online = IniRead(path & "../application.ini", "FIRMA", "tsl_online")

                '-- se non è stata trovata la chiave metto un default
                If tsl_online = "<Not_Found>" Then
                    tsl_online = "no"
                End If

            End If

            If outFile Is Nothing Or CStr(outFile) = "" Then
                outFile = IniRead(path & "../application.ini", "FIRMA", "directory_output_p7m")

                '-- se non è stata trovata la chiave metto un default
                If outFile = "<Not_Found>" Then
                    outFile = "d:\PortaleGareTelematiche\Allegati\"
                End If

            End If

            If pathTsl Is Nothing Or CStr(pathTsl) = "" Then
                pathTsl = IniRead(path & "../application.ini", "FIRMA", "path_xml_tsl")

                '-- se non è stata trovata la chiave metto un default
                If pathTsl = "<Not_Found>" Then
                    pathTsl = "d:\PortaleGareTelematiche\Web\Application\IT_TSL_signed.xml"
                End If

            End If

            If urlTsl Is Nothing Or CStr(urlTsl) = "" Then
                urlTsl = IniRead(path & "../application.ini", "FIRMA", "url_xml_tsl")

                '-- se non è stata trovata la chiave metto un default
                If urlTsl = "<Not_Found>" Then
                    urlTsl = "https://applicazioni.cnipa.gov.it/TSL/IT_TSL_signed.xml"
                End If

            End If

        End Sub
        Private Shared Sub CloseReader(ByRef reader As PdfReader, ByRef ClearFile As String)
            If Not IsNothing(reader) Then
                reader.Close()
                reader.Dispose()
                reader = Nothing
            End If
            If Not String.IsNullOrWhiteSpace(ClearFile) AndAlso My.Computer.FileSystem.FileExists(ClearFile) Then
                My.Computer.FileSystem.DeleteFile(ClearFile)
            End If
            ClearFile = ""
        End Sub
        Public Function verifyPdfSigned(B As BlobEntryModelType, Optional firmeMultipleIncrociate As Boolean = False) As AfCommon.ComplexResponseModelType
            Dim ret As New AfCommon.ComplexResponseModelType(False, "", "")
            Dim hashAllegato As String = ""
            Dim checkFile As Boolean = True
            Dim reader As PdfReader = Nothing
            Dim strErr As String = ""
            Dim idpfu As String = ""
            Dim algoritmoHashFirma As String = ""
            Dim checkValidAlgoritmoFirmas As Boolean = True
            Dim totFirme As Integer = 0
            Dim ClearFile As String = ""
            Dim nomeFile As String = B.filename
            Try
                Dbm.AppendOperation("Test estensione file")
                If Not B.extension.ToLower = ".p7m" Then
                    Dbm.AppendOperation("New PdfReader")
                    ClearFile = BlobManager.GetPureFileOnDisk(Dbm, B, True)
                    reader = New PdfReader(ClearFile)
                    Dbm.AppendOperation("recupero numero firme")
                    totFirme = reader.AcroFields.GetSignatureNames.Count
                    checkFile = True
                Else
                    checkFile = False
                    totFirme = 0
                End If

                If totFirme = 0 And firmeMultipleIncrociate = True Then
                    If Not reader Is Nothing Then
                        Dbm.AppendOperation("Close del reader 1")
                        reader.Close()
                    End If
                    ret.esit = True
                    CloseReader(reader, ClearFile)
                    Return ret
                End If
            Catch ex As Exception
                Try
                    Dbm.AppendOperation("Catch1.desc:" & ex.Message)
                    CloseReader(reader, ClearFile)
                Catch ex2 As Exception
                End Try
                checkFile = False
                strErr = ex.Message
            End Try


            '-- Se il file pdf non è firmato digitalmente tracciamo la cosa nel db e usciamo dalla funzione
            If checkFile = False Or reader Is Nothing Or totFirme = 0 Then

                Dbm.AppendOperation("db.init")

                '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma

                If firmeMultipleIncrociate = False Then

                    Dim strSql As String = ""

                    Try

                        Dbm.AppendOperation("Compongo la insert per la CTL_SIGN_ATTACH_INFO ")

                        '-- Se chi ci invoca è da parte del documento nuovo
                        If ATT_Hash <> "NULL" Then
                            strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & ATT_Hash & "'"
                        Else
                            strSql = "delete from ctl_sign_attach_info where attIdMsg = " & attIdMsg & " and attOrderFile = " & attOrderFile & " and attIdObj = " & attIdObj
                        End If
                        Dbm.ExecuteNonQuery(strSql, Nothing)
                        Dbm.AppendOperation("invoco metodo tracciaFirmaNonValida")

                        '--aggiunto strerr per avere una differnza per il caso di file senza firme oppure file corrotto
                        tracciaFirmaNonValida(firmeMultipleIncrociate, nomeFile, strErr)

                        Dbm.AppendOperation("reader close1")

                        CloseReader(reader, ClearFile)


                    Catch ex As Exception
                        ret.out = ("0#" & "CAUSE" & "," & ex.Message)
                        ret.esit = False
                        Return ret
                    End Try
                Else
                    CloseReader(reader, ClearFile)
                End If
                ret.out = "1#OK"
                ret.esit = True
                Return ret
            End If

            '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
            If firmeMultipleIncrociate = False Then
                Dim strSql As String = ""
                Try
                    Dbm.AppendOperation("Cancello i record vecchi ")

                    '-- Se chi ci invoca è da parte del documento nuovo
                    If ATT_Hash <> "NULL" Then
                        strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & Replace(ATT_Hash, "'", "''") & "'"
                    Else
                        strSql = "delete from ctl_sign_attach_info where attIdMsg = " & CLng(attIdMsg) & " and attOrderFile = " & CLng(attOrderFile) & " and attIdObj = " & CLng(attIdObj)
                    End If
                    Dbm.ExecuteNonQuery(strSql, Nothing)
                Catch ex As Exception
                    ret.out = ("0#Errore nella cancellazione dei vecchi record associati all'allegato, " & ex.Message)
                    ret.esit = False
                    Return ret
                End Try
            End If

            Dim st As New X509Store(StoreName.Root, StoreLocation.CurrentUser)
            st.Open(OpenFlags.ReadOnly)

            Dim col As X509Certificate2Collection = st.Certificates
            st.Close()

            Dim parser As New X509CertificateParser()
            Dim kall As New List(Of Org.BouncyCastle.X509.X509Certificate)

            Dim cert As X509Certificate2 = Nothing

            For Each cert In col

                Dim c2 As Org.BouncyCastle.X509.X509Certificate = parser.ReadCertificate(cert.GetRawCertData())
                kall.Add(c2)

            Next

            Dim af As AcroFields = reader.AcroFields
            Dim x509 As New X509Certificate2
            Dim sign_usage As Integer = AcroFields.FIELD_TYPE_SIGNATURE

            Dim names As List(Of String) = af.GetSignatureNames()

            Dim i As Integer = -1

            'for (int k = 0; k < names.Count; ++k) {
            For Each name As String In names

                i = i + 1

                '-- Itero sui certificati ( per firma multipla )
                Dim pk As PdfPKCS7 = Nothing

                Try


                    pk = af.VerifySignature(name)
                    
                    ret.signscounter +=1

                Catch ex As Exception
                    tracciaFirmaNonValida(firmeMultipleIncrociate, nomeFile, ex.Message)
                    CloseReader(reader, ClearFile)
                    ret.out = "1#OK"
                    ret.esit = True
                    Return ret
                End Try



                '-- Converto il certificato dal formato di bouncycastle in quello delle apiwindows

                Dim certificato As New X509Certificate2
                certificato.Import(pk.SigningCertificate.GetEncoded())

                'algoritmoHashFirma = certificato.SignatureAlgorithm.Value

                Try


                    'TODO: ho modificato questa parte usando BouncyCastle
                    'algoritmoHashFirma = pk.DigestAlgorithmOid

                    Dim mapField = GetType(Org.BouncyCastle.Cms.CmsSignedData).Assembly.[GetType]("Org.BouncyCastle.Cms.CmsSignedHelper").GetField("digestAlgs", BindingFlags.[Static] Or BindingFlags.NonPublic)
                    Dim map = CType(mapField.GetValue(Nothing), System.Collections.IDictionary)
                    Dim hashAlgName = CStr(map(certificato.SignatureAlgorithm.Value))
                    'Dim hashAlg = HashAlgorithm.Create(hashAlgName)
                    algoritmoHashFirma = resolveDigestAlgorithm(hashAlgName)

                    'Dim signedCms As New System.Security.Cryptography.Pkcs.SignedCms
                    'Dim info As System.Security.Cryptography.Pkcs.SignerInfo

                    'signedCms.Decode(ReadFile(pdf))  '-- per il file del firmatario estero ottengo un {"Valore tag ASN1 non valido."}
                    'info = signedCms.SignerInfos.Item(i)
                    'algoritmoHashFirma = info.DigestAlgorithm.Value

                Catch ex As Exception

                    Try
                        Dim signedCms As New System.Security.Cryptography.Pkcs.SignedCms
                        Dim info As System.Security.Cryptography.Pkcs.SignerInfo

                        If String.IsNullOrWhiteSpace(ClearFile) Then
                            ClearFile = BlobManager.GetPureFileOnDisk(Dbm, B, True)
                        End If
                        signedCms.Decode(My.Computer.FileSystem.ReadAllBytes(ClearFile))
                        info = signedCms.SignerInfos.Item(i)
                        algoritmoHashFirma = info.DigestAlgorithm.Value
                    Catch ex2 As Exception
                        '-- Se entreremo in questo catch è andato in errore il metodo decode
                        '-- per "Unknown cryptographic algorithm", cioè non supporta l'algoritmo
                        '-- utilizzato per la firma digitale. ad es. SHA256 o superiore
                        '-- Questo accade nei sistemi windows 2003 o inferiori.
                        '-- Se ci troviamo in questa casistica diamo per assunto che l'algoritmo non
                        '-- essendo supportato non è quindi SHA1 ma SHA256 (per il futuro, quando
                        '-- si adoterrà SHA512, si spera che sui clienti non ci sia più windows2003)
                        algoritmoHashFirma = "2.16.840.1.101.3.4.2.1" 'OID value per SHA256
                    End Try

                End Try


                Dim isCertificatoSottoscrizione As Boolean = False
                Dim usoCertificato As String = ""
                Dim statoFirma As String = ""
                Dim note As String = ""
                Dim statoEmittente As String = ""

                Dim serialNumberCertificato As String = ""

                note = "INFO CA : " & vbCrLf
                note = note & pk.SigningCertificate.IssuerDN.ToString & vbCrLf
                note = note & "INFO SIGNER : " & vbCrLf
                note = note & pk.SigningCertificate.SubjectDN.ToString

                Dim verificaFirma As Boolean = True

                Call getInfoUtilizzoCertificato(certificato, isCertificatoSottoscrizione, usoCertificato)

                Dim cnCertificatore As String = pk.SigningCertificate.IssuerDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.CN)(0).ToString

                Dim firmatario As String = ""
                Try
                    firmatario = pk.SigningCertificate.SubjectDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.CN)(0).ToString
                Catch
                End Try

                Dim firmatarioInfo As String = ""
                Try
                    Dim tmpStrCFfirmatario As String = ""
                    tmpStrCFfirmatario = pk.SigningCertificate.SubjectDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.SerialNumber)(0).ToString
                    '-- se il serial number contiene ":" vuol dire che abbiamo un serial number italiano nella forma IT:codiceFiscaleFirmatario
                    '-- altrimenti il certificato è estero e prendiamo l'intero serial number senza splittare sul :

                    If tmpStrCFfirmatario.Contains(":") Then
                        firmatarioInfo = Split(pk.SigningCertificate.SubjectDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.SerialNumber)(0).ToString, ":")(1)
                    Else
                        firmatarioInfo = tmpStrCFfirmatario
                    End If
                Catch
                End Try

                Try
                    Try
                        '-- 1. RECUPERO LO STATO DELL'EMITTENTE DEL CERTIFICATO ( DALLA CERTIFICATION AUTORITY )
                        statoEmittente = pk.SigningCertificate.IssuerDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.C)(0).ToString
                    Catch ex As Exception
                        statoEmittente = ""
                    End Try


                    If statoEmittente = "" Then
                        '-- 2. SE NON RIESCO A RECUPERARE LO STATO DEL CERTIFICATORE PROVO CON QUELLO DEL FIRMATARIO
                        statoEmittente = pk.SigningCertificate.SubjectDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.C)(0).ToString
                    End If

                    If statoEmittente = "" Then
                        '-- 3. Do come default Italia
                        statoEmittente = "IT"
                    End If

                Catch
                    statoEmittente = "IT"
                End Try

                Dim SignDate As Date? = Nothing
                Try
                    SignDate = pk.SignDate
                    If Not SignDate.HasValue Or Year(SignDate) = 1 Then
                        SignDate = Date.Now
                    End If
                Catch ex As Exception
                    SignDate = Date.Now
                End Try
                Dim ScadenzaCertificato As DateTime = pk.SigningCertificate.NotAfter

                '-- Se la data di firma è maggiore della scadenza del certificato   
                Dim isexpired As Boolean = SignDate.Value > ScadenzaCertificato


                Dim isTrusted As Boolean = checkIsTrusted(cnCertificatore, SignDate, tslFromTable, tsl_online, pathTsl, urlTsl, statoEmittente)

                Dim pkc As Org.BouncyCastle.X509.X509Certificate() = pk.SignCertificateChain
                Dim motivoRevoca As String = ""

                verificaFirma = pk.Verify()

                checkValidAlgoritmoFirmas = checkAlgoritmoFirma(algoritmoHashFirma, SignDate.Value)
                Dim revoked As Integer
                Try

                    x509.Import(certificato.GetRawCertData)

                    Dim esitoVerifica As New Microsoft.VisualBasic.Collection

                    'GESTITO CON PARAMETRO LA CHIAMATA SE LA MACCHINA APPLICATION DOVE GIRA IL SERVIZIO ALLEGATI NON ESCE SULLA RETE ASPETTA SOLO CHE VA IN TIMEOUT LA CHIAMATA
                    'Default DEVE FARE COME PRIMA SE YES  NON FA LA CHIAMATA ( ci è servito su STELLA )
                    If UCase(AfCommon.AppSettings.item("app.BLOCK_VERIFY_REVOKE")) <> "YES" Then

                        esitoVerifica = verificaRevocaWindows(x509, SignDate)

                        motivoRevoca = esitoVerifica("motivo")
                        revoked = esitoVerifica("revocato")

                        If motivoRevoca <> "" Then
                            note = note & motivoRevoca
                        End If

                        x509 = Nothing
                    Else
                        revoked = -1
                    End If


                Catch ex As Exception

                    revoked = -1

                    '--- COMMENTIAMO L'INVOCAZIONE AD ISREVOCATIONVALID PERCHE' PER UN FILE IN PRODUZIONE
                    '--     CI DAVA UN FALSO POSITIVO SU UNA REVOCA. 

                    '-- se è andata in errore la verifica della revoca
                    '-- proviamo tramite i metodi offerti da iTextSharp
                    '-- per verificare la revoca tramite ocsp
                    'Try
                    'If Not IsNothing(pk.Ocsp) Then
                    'If pk.IsRevocationValid() Then
                    'revoked = 1
                    'Else
                    'revoked = 0
                    'End If
                    'End If
                    'Catch ex2 As Exception
                    '    revoked = -1
                    'End Try

                    'revoked = IIf(pk.IsRevocationValid(), 1, 0) Or IIf(PdfPKCS7.VerifyOcspCertificates(pk.Ocsp, kall), 1, 0)

                End Try

                If revoked = -1 And UCase(AfCommon.AppSettings.item("app.BLOCK_VERIFY_REVOKE")) <> "YES" Then

                        Try

                            Dim chilkatCert As New Chilkat.Cert
                            chilkatCert.LoadFromBinary(certificato.RawData)

                            'Returns 1 if the certificate has been revoked, 0 if not revoked, and -1 if unable to check the revocation status.
                            revoked = chilkatCert.CheckRevoked

                            If revoked = -1 Then

                                '  0: Good
                                '  1: Revoked
                                '  2: Unknown.
                                revoked = verificaRevocaChilkat(chilkatCert)  '- verifica chilkat tramite OCSP

                                If revoked = 2 Then
                                    revoked = -1
                                End If

                            End If

                            chilkatCert.Dispose()

                        Catch ex2 As Exception
                            revoked = -1
                        End Try


                    End If

                    If revoked <> 0 Then
                    note = note & motivoRevoca
                End If

                'Dim fails As Object = PdfPKCS7.VerifyCertificates(pkc, kall, Nothing, cal)
                'If (fails Is Nothing) Then
                'verificaFirma = True '(" Il certificato è valido rispetto al KeyStore") & " <br/> "
                'Else
                'verificaFirma = False '(" Certificato non valido : " + fails(1).ToString) & " <br/> "
                'Exit For

                'End If


                Try
                    serialNumberCertificato = certificato.GetSerialNumberString
                Catch ex As Exception
                    serialNumberCertificato = ""
                End Try

                If verificaFirma And isTrusted And Not isexpired And isCertificatoSottoscrizione And checkValidAlgoritmoFirmas And (revoked <= 0) Then
                    If (revoked = 0) Then
                        statoFirma = "SIGN_OK" '-- Tutto ok
                    Else
                        statoFirma = "SIGN_OK_NOT_VER_REVOCA" '-- Tutto ok tranne che è stato possibile verifica se il certificato è revocato
                    End If
                Else
                    statoFirma = "SIGN_NOT_OK" '-- Firma non valida
                End If

                '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma

                Dim strSql As String = ""
                Try
                    Dbm.AppendOperation("Compongo la insert per la CTL_SIGN_ATTACH_INFO ")

                    strSql = "INSERT INTO CTL_SIGN_ATTACH_INFO " &
                                "( " &
                                "ATT_Hash " &
                                ",isTrustedCA " &
                                ",isRevoked " &
                                ",isExpired " &
                                ",isCertificatoSottoscrizione " &
                                ",isValidSign " &
                                ",isValidAlgoritm " &
                                ",signExt " &
                                ",certificatore " &
                                ",codFiscFirmatario " &
                                ",firmatario " &
                                ",dataApposizioneFirma" &
                                ",scadenzaFirma " &
                                ",nomeFile " &
                                ",numSigners " &
                                ",usoCertificato " &
                                ",statoFirma " &
                                ",attIdMsg " &
                                ",attOrderFile " &
                                ",attIdObj " &
                                ",objCertificato " &
                                ",idAzi " &
                                ",algoritmo " &
                                ",VerificaCF " &
                                ",note,CountryName, subjectSerialNumber, certificateSerialNumber) " &
                                "VALUES(" &
                                "'" & Replace(ATT_Hash, "'", "''") & "'," &
                                "" & If(isTrusted, 1, 0) & "," &
                                "" & revoked & "," &
                                "" & If(isexpired, 1, 0) & "," &
                                "" & If(isCertificatoSottoscrizione, 1, 0) & "," &
                                "" & If(verificaFirma, 1, 0) & "," &
                                "" & If(checkValidAlgoritmoFirmas, 1, 0) & "," &
                                "'PDF'," &
                                "'" & Replace(Replace(cnCertificatore, "'", "''"), "CN=", "") & "'," &
                                "'" & Replace(firmatarioInfo, "'", "''") & "'," &
                                "'" & Replace(firmatario, "'", "''") & "'," &
                                "'" & Replace(SignDate.Value.ToString("yyyy-MM-dd HH:mm:ss"), ".", ":") & "'," &
                                "'" & Replace(ScadenzaCertificato.ToString("yyyy-MM-dd HH:mm:ss"), ".", ":") & "',"

                    If firmeMultipleIncrociate Then
                        strSql = strSql & "'" & Replace(Split(originalFileName, "\")(Split(originalFileName, "\").Length - 1), "'", "''") & "'"
                    Else
                        strSql = strSql & "'" & Replace(nomeFile, "'", "''") & "'"
                    End If


                    strSql = strSql & "," & names.Count & "," &
                                "'" & Replace(usoCertificato, "'", "''") & "'," &
                                "'" & Replace(statoFirma, "'", "''") & "'" &
                                "," & If(Trim(attIdMsg) = "", "NULL", attIdMsg) &
                                "," & If(Trim(attOrderFile) = "", "NULL", attOrderFile) &
                                "," & If(Trim(attIdObj) = "", "NULL", attIdObj) &
                                ",@objCertificato" &
                                "," & If(idAzi = "", "NULL", idAzi) &
                                ",'" & Replace(algoritmoHashFirma, "'", "''") & "'" &
                                "," & If(revoked = -1, -1, 0) &
                                ",'" & Replace(note, "'", "''") & "'" &
                                ",'" & Replace(statoEmittente, "'", "''") & "'" &
                                ",'" & Replace(firmatarioInfo, "'", "''") & "'" &
                                ",'" & Replace(serialNumberCertificato, "'", "''") & "'" &
                                ")"

                    Dbm.AppendOperation("Eseguo la insert sulla CTL_SIGN_ATTACH_INFO")
                    Dim params As New Collections.Hashtable
                    params("@objCertificato") = pk.SigningCertificate.GetEncoded()
                    Dbm.ExecuteNonQuery(strSql, params)

                    Dbm.AppendOperation("Invoco la stored GET_INFO_FIRMA")

                    '--- INVOCO LA STORED 'GET_INFO_FIRMA' --
                    '--- PER EFFETTUARE EVENTUALI CONTROLLI O MODIFICHE AGGIUNTIVE DELEGANDOLE ALLA STORED
                    '--- COSì DA NON DOVER PER FORZA RICOMPILARE LA DLL NEL CASO SI RIESCA
                    '--- A GESTIRE L'ECCEZIONE ALL'INTERNO DELLA STORED
                    strSql = "exec GET_INFO_FIRMA '" & Replace(CStr(firmatarioInfo), "'", "''") & "','" & Replace(CStr(cnCertificatore), "'", "''") & "','" & Replace(CStr(algoritmoHashFirma), "'", "''") & "','" & Replace(CStr(note), "'", "''") & "'"

                    '-- aggiungo le informazioni per recuperare in modo univoco il record appena inserito
                    If ATT_Hash <> "" Then
                        strSql = strSql & ",'" & Replace(ATT_Hash, "'", "''") & "'"
                    Else
                        strSql = strSql & ",''," & CStr(CLng(attIdMsg)) & "," & CStr(CLng(attOrderFile)) & "," & CStr(CLng(attIdObj)) & ""
                    End If
                    Dbm.ExecuteNonQuery(strSql, New Collections.Hashtable)
                    'Response.Write(strSql)            

                Catch ex As Exception
                    ret.out = ("0#" & "CAUSE" & "," & ex.Message)
                    ret.esit = False
                    Return ret
                End Try
            Next
            CloseReader(reader, ClearFile)
            ret.out = "1#OK"
            ret.esit = True

            Return ret
        End Function

        Sub verifyPdfSigned(p1 As String)
            Throw New NotImplementedException
        End Sub

        Public Function verificaRevocaWindows(ByVal x509 As X509Certificate2, ByVal dataFirma As Date) As Microsoft.VisualBasic.Collection

            '-- stringa vuota se non è revocato, altrimenti c'è il motivo
            Dim ret As New Microsoft.VisualBasic.Collection
            Dim revoca As Integer = -1
            Dim motivo As String = ""

            Try

                Try
                    If IsNothing(dataFirma) Then
                        dataFirma = Now()
                    End If
                Catch ex As Exception
                    dataFirma = Now()
                End Try

                Dim ch As New X509Chain

                '-- effetto la verifica di revoca online
                ch.ChainPolicy.RevocationMode = X509RevocationMode.Online
                '-- Offline:	 Un controllo di revoca viene eseguito mediante un elenco di certificati revocati memorizzato nella cache.
                '-- Online :	 Un controlo di revoca viene eseguito mediante un elenco di certificati revocati online

                '-- imposto il flag di controllo sul certificato del firmatario
                ch.ChainPolicy.RevocationFlag = X509RevocationFlag.EndCertificateOnly

                'ch.ChainPolicy.UrlRetrievalTimeout = New TimeSpan(3000)

                ch.ChainPolicy.UrlRetrievalTimeout = New TimeSpan(GetTicksFromSeconds(60))

                ch.ChainPolicy.VerificationFlags = X509VerificationFlags.AllFlags
                'ch.ChainPolicy.VerificationFlags = X509VerificationFlags.AllowUnknownCertificateAuthority

                '-- Il certificato lo verifico rispetto alla data dell'apposizione della firma
                '-- non rispetto ad ora. da capire chilkat invece come si comporta
                ch.ChainPolicy.VerificationTime = dataFirma


                Dim isRevoked As Boolean = False
                Dim verificato As Boolean = False

                Try
                    ch.Build(x509)

                    If ch.ChainStatus.Length() = 0 Then
                        isRevoked = False
                        verificato = True
                    Else
                        Dim k As Integer = 0

                        verificato = False

                        For Each s As X509ChainStatus In ch.ChainStatus

                            If s.Status = X509ChainStatusFlags.NoError Then
                                isRevoked = False
                                verificato = True
                                Exit For
                            ElseIf s.Status = X509ChainStatusFlags.Revoked Then
                                isRevoked = True
                                verificato = True
                                Exit For
                            ElseIf s.Status = X509ChainStatusFlags.PartialChain Then
                                '-- se è stato trovato questo errore è perchè
                                '-- probabilmente non è installata la root certificate sul server
                                '-- e quindi le api non permettono la validazione della revoca
                                '-- se la root non è presente nello store dei certificati
                                isRevoked = False
                                verificato = True

                                ret.Add(s.StatusInformation, "motivo")
                                ret.Add(-2, "revocato") '-- non ho potuto verificare e non devo continuare a provarci fino a un cambio di stato

                                Return ret
                            End If

                            '-- tutte le altre X509ChainStatusFlags portano a un'impossibilità
                            '-- di verificare la revoca

                        Next
                    End If


                Catch ex As Exception

                    motivo = ex.Message
                    verificato = False

                End Try


                If isRevoked Or verificato = False Then

                    If verificato = False Then
                        motivo = motivo & " - Revoca non verificata."
                    Else
                        motivo = motivo & " - REVOCATO."
                    End If


                    Try

                        Dim k As Integer = 0
                        For Each s As X509ChainStatus In ch.ChainStatus

                            k = k + 1
                            Dim str As String = s.Status.ToString()
                            motivo = motivo & "Chain livello " & k & "  - " & s.StatusInformation & " " & str & "<br/>" & vbCrLf
                        Next

                    Catch ex As Exception
                        motivo = motivo & " - errore recupero info chain : " & ex.Message & "."
                    End Try

                    If verificato Then
                        revoca = 1
                    Else
                        revoca = -1
                    End If


                Else
                    revoca = 0
                End If



            Catch ex As Exception
                motivo = "Errore non gestito:" & ex.Message
                revoca = -1
            End Try

            ret.Add(motivo, "motivo")
            ret.Add(revoca, "revocato")

            Return ret

        End Function

        Public Function verificaRevocaChilkat(ByVal cert As Chilkat.Cert) As Integer

            '  NOTE: REQUIRES CHILKAT V9.5.0.75 OR GREATER.

            '  Get the cert's OCSP URL.
            Dim ocspUrl As String = cert.OcspUrl

            '  Build the JSON that will be the OCSP request.
            Dim prng As New Chilkat.Prng
            Dim json As New Chilkat.JsonObject

            json.EmitCompact = False
            json.UpdateString("extensions.ocspNonce", prng.GenRandom(36, "base64"))
            json.I = 0

            json.UpdateString("request[i].cert.hashAlg", "sha1")
            json.UpdateString("request[i].cert.issuerNameHash", cert.HashOf("IssuerDN", "sha1", "base64"))
            json.UpdateString("request[i].cert.issuerKeyHash", cert.HashOf("IssuerPublicKey", "sha1", "base64"))
            json.UpdateString("request[i].cert.serialNumber", cert.SerialNumber)

            json.Emit()

            '  Our OCSP request looks like this:
            '  {
            '    "extensions": {
            '      "ocspNonce": "qZDfbpO+nUxRzz6c/SPjE5QCAsPfpkQlRDxTnGl0gnxt7iXO"
            '    },
            '    "request": [
            '      {
            '        "cert": {
            '          "hashAlg": "sha1",
            '          "issuerNameHash": "9u2wY2IygZo19o11oJ0CShGqbK0=",
            '          "issuerKeyHash": "d8K4UJpndnaxLcKG0IOgfqZ+uks=",
            '          "serialNumber": "6175535D87BF94B6"
            '        }
            '      }
            '    ]
            '  }


            Dim ocspRequest As New Chilkat.BinData
            Dim http As New Chilkat.Http

            Dbm.AppendOperation("verificaRevocaChilkat CreateOcspRequest")

            '  Convert our JSON to a binary (ASN.1) OCSP request
            http.CreateOcspRequest(json, ocspRequest)

            Dbm.AppendOperation("verificaRevocaChilkat pre url " & CStr(ocspUrl))

            'GESTITO CON PARAMETRO, DEFAULT NON DEVE FARE NULLA SE YES LO SETTA COSì ( ci è servito su puglia )
            If UCase(AfCommon.AppSettings.item("app.UseIEProxy")) = "YES" Then
                http.UseIEProxy = 1
            End If

            '  Send the OCSP request to the OCSP server
            Dim resp As Chilkat.HttpResponse = http.PBinaryBd("POST", ocspUrl, ocspRequest, "application/ocsp-request", False, False)

            Dbm.AppendOperation("verificaRevocaChilkat post HttpResponse ")

            Try
                Dbm.AppendOperation("verificaRevocaChilkat LastErrorText:    " & CStr(http.LastErrorText))
            Catch ex As Exception
            End Try

            If (http.LastMethodSuccess <> True) Then
                Return 2
            End If

            Dbm.AppendOperation("verificaRevocaChilkat post url " & CStr(ocspUrl))

            '  Get the binary (ASN.1) OCSP reply
            Dim ocspReply As New Chilkat.BinData
            resp.GetBodyBd(ocspReply)


            '  Convert the binary reply to JSON.
            '  Also returns the overall OCSP response status.
            Dim jsonReply As New Chilkat.JsonObject
            Dim ocspStatus As Integer = http.ParseOcspReply(ocspReply, jsonReply)

            '  The ocspStatus can have one of these values:
            '  -1:  The ARG1 does not contain a valid OCSP reply.
            '  0:  Successful - Response has valid confirmations..
            '  1: Malformed request - Illegal confirmation request.
            '  2: Internal error - Internal error in issuer.
            '  3: Try later -  Try again later.
            '  4: Not used - This value is never returned.
            '  5: Sig required - Must sign the request.
            '  6: Unauthorized - Request unauthorized.

            If (ocspStatus < 0) Then
                Return 2
            End If

            '  Let's examine the OCSP response (in JSON).
            jsonReply.EmitCompact = False
            jsonReply.Emit()

            '  The JSON reply looks like this:
            '  (Use the online tool at https://tools.chilkat.io/jsonParse.cshtml
            '  to generate JSON parsing code.)

            '  {
            '    "responseStatus": 0,
            '    "responseTypeOid": "1.3.6.1.5.5.7.48.1.1",
            '    "responseTypeName": "ocspBasic",
            '    "response": {
            '      "responderIdChoice": "KeyHash",
            '      "responderKeyHash": "d8K4UJpndnaxLcKG0IOgfqZ+uks=",
            '      "dateTime": "20180803193937Z",
            '      "cert": [
            '        {
            '          "hashOid": "1.3.14.3.2.26",
            '          "hashAlg": "SHA-1",
            '          "issuerNameHash": "9u2wY2IygZo19o11oJ0CShGqbK0=",
            '          "issuerKeyHash": "d8K4UJpndnaxLcKG0IOgfqZ+uks=",
            '          "serialNumber": "6175535D87BF94B6",
            '          "status": 0,
            '          "thisUpdate": "20180803193937Z",
            '          "nextUpdate": "20180810193937Z"
            '        }
            '      ]
            '    }
            '  }
            ' 

            '  The certificate status:
            Dim certStatus As Integer = json.IntOf("response.cert[0].status")

            Return certStatus

            '  Possible certStatus values are:
            '  0: Good
            '  1: Revoked
            '  2: Unknown.

        End Function

        Public Function GetTicksFromSeconds(seconds As Long)
            Return seconds * 10000000
        End Function

        Public Sub tracciaFirmaNonValida(firmeMultipleIncrociate As Boolean, nomeFile As String, Optional motiviExtra As String = "")

            Dim strSql As String

            strSql = "INSERT INTO CTL_SIGN_ATTACH_INFO " &
                     "( " &
                     "isValidSign " &
                     ",nomeFile " &
                     ",statoFirma " &
                     ",ATT_Hash " &
                     ",attIdMsg " &
                     ",attOrderFile " &
                     ",attIdObj " &
                     ",note) " &
                     "VALUES(" &
                     "0"

            If firmeMultipleIncrociate Then
                strSql = strSql & ",'" & Replace(Split(originalFileName, "\")(Split(originalFileName, "\").Length - 1), "'", "''") & "'"
            Else
                strSql = strSql & ",'" & Replace(nomeFile, "'", "''") & "'"
            End If

            '--attenzione se si modifica la dicitura "Allegato non firmato." che viene inserita nel campo Note
            '--deve essere modificato il controllo presente alla riga 136 del file attach.vb della funzione UploadAttach
            strSql = strSql & ",'SIGN_NOT_OK'" &
                     ",'" & Replace(ATT_Hash, "'", "''") & "'" &
                    "," & IIf(attIdMsg = "", "NULL", attIdMsg) &
                    "," & IIf(attOrderFile = "", "NULL", attOrderFile) &
                    "," & IIf(attIdObj = "", "NULL", attIdObj) &
                     ",'Allegato non firmato." & Replace(motiviExtra, "'", "''") & "'" &
                     ")"


            Dbm.AppendOperation("Eseguo la insert sulla CTL_SIGN_ATTACH_INFO")
            Dbm.ExecuteNonQuery(strSql, Nothing)
        End Sub

        Public Sub getInfoUtilizzoCertificato(ByVal certificato As X509Certificate2, ByRef isCertificatoSottoscrizione As Boolean, ByRef usoCertificato As String)

            Dim estensioni As X509ExtensionCollection = certificato.Extensions

            For Each estensione As X509Extension In estensioni

                Try

                    Dim keyUsage As System.Security.Cryptography.X509Certificates.X509KeyUsageExtension
                    keyUsage = DirectCast(estensione, X509KeyUsageExtension)
                    Dim utilizzoCertificato = keyUsage.KeyUsages

                    'If (utilizzoCertificato = X509KeyUsageFlags.NonRepudiation Or utilizzoCertificato = 192) Then
                    If ((utilizzoCertificato And X509KeyUsageFlags.NonRepudiation) = X509KeyUsageFlags.NonRepudiation) Then '-- utilizzoCertificato è usata con operatori di tipo bitwise contiene quindi una combinatoria di big/flag quindi facendo un confronto di tipo AND logico con la desiderata e verificando che la risultante mi dia proprio la desiderata.. funziona
                        isCertificatoSottoscrizione = True
                    Else
                        isCertificatoSottoscrizione = False
                    End If

                    Select Case utilizzoCertificato
                        Case X509KeyUsageFlags.CrlSign
                            usoCertificato = "CRL Signing"
                        Case X509KeyUsageFlags.DataEncipherment
                            usoCertificato = "Data Encipherment"
                        Case X509KeyUsageFlags.DecipherOnly
                            usoCertificato = "Decipher-Only"
                        Case X509KeyUsageFlags.DigitalSignature
                            usoCertificato = "Digital Signature"
                        Case X509KeyUsageFlags.EncipherOnly
                            usoCertificato = "Encipher-Only"
                        Case X509KeyUsageFlags.KeyAgreement
                            usoCertificato = "Key Agreement"
                        Case X509KeyUsageFlags.KeyCertSign
                            usoCertificato = "KeyCertSign"
                        Case X509KeyUsageFlags.KeyEncipherment
                            usoCertificato = "Key Encipherment"
                        Case X509KeyUsageFlags.NonRepudiation
                            usoCertificato = "Non-Repudiation"
                        Case 192
                            usoCertificato = "Non-Repudiation or Digital Signature"
                    End Select

                Catch ex As Exception
                    '-- Non ci troviamo nell'estensione che ci interessa ( la KeyUsages )
                End Try

            Next

        End Sub


        Public Function checkIsTrusted(cnCertificatore As String, dataFirma As Date, tslFromTable As String, tsl_online As String, pathTsl As String, urlTsl As String, Optional countryName As String = "IT") As Boolean
            Dim ret As Boolean = False
            Try

                If UCase(tslFromTable) = "SI" Or UCase(tslFromTable) = "YES" Then

                    '-- non leggo più la tsl da internet o dal file xml
                    '-- ma dalla tabella CTL_TrustServiceList avvalorata
                    '-- dall'integrazione

                    If dataFirma = Nothing Then
                        dataFirma = Now
                    End If

                    Dim strSql As String = ""
                    Dim strDataFirma As String = dataFirma.ToString("yyyy-MM-dd HH:mm:ss")

                    strDataFirma = Replace(strDataFirma, ".", ":") '-- per problemi di vecchi server 

                    '-- Se presente, tolgo  "CN="
                    If cnCertificatore.Contains("CN=") Then
                        cnCertificatore = Mid(cnCertificatore, 4)
                    End If

                    '-- datafirma. es: 2014-05-09 16:42:03.000'
                    'strSql = "select id from CTL_TrustServiceList where deleted = 0 and '" & Replace(strDataFirma, "'", "''") & "' >= StatusStartingTime and '" & Replace(strDataFirma, "'", "''") & "' <= isnull(StatusEndTime,'2999-11-29 01:01:00.000') and FullServiceName = '" & Replace(cnCertificatore, "'", "''") & "' and CountryName = '" & Replace(countryName, "'", "''") & "'"

                    '-- verifico la presenza del certificatore nella CTL_TrustServiceList andando in relazione con la trascodifica PREFISSI_STATI_EU per i casi come la grecia e la gran bretagna
                    '--     che non hanno rispettato la codifica ISO dello stato. nel certificato ci arrivava lo stato come GR ma nell'elenco dei certificatori il codice dello stato era EL
                    strSql = "select a.id " &
                        " from CTL_TrustServiceList a with(nolock) " &
                        "           left join CTL_Transcodifica b on dztNome = 'CountryName' and Sistema = 'PREFISSI_STATI_EU' and ValOut = CountryName " &
                        " where deleted = 0 and '" & Replace(strDataFirma, "'", "''") & "' >= StatusStartingTime and '" & Replace(strDataFirma, "'", "''") & "' <= isnull(StatusEndTime,'2999-11-29 01:01:00.000') and FullServiceName = '" & Replace(cnCertificatore, "'", "''") & "' " &
                        "           and isnull(b.ValIn, CountryName) = '" & Replace(countryName, "'", "''") & "'"


                    Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSql, Nothing)
                        If dr.Read Then
                            ret = True
                        End If
                    End Using
                Else

                    Dim m_xmld As XmlDocument
                    Dim m_nodelist As XmlNodeList
                    Dim m_node As XmlNode
                    m_xmld = New XmlDocument()
                    '-- vecchia gestione
                    'Caricamento dell'xml
                    If (UCase(tsl_online).Equals("NO")) Then
                        m_xmld.Load(pathTsl)
                    Else
                        m_xmld.Load(urlTsl)
                    End If
                    '-- seleziono tutti i nodi figli del nodo filtroCompany
                    m_nodelist = m_xmld.GetElementsByTagName("tsl:ServiceName")

                    If m_nodelist.Count = 0 Then
                        m_nodelist = m_xmld.GetElementsByTagName("ServiceName")
                    End If

                    'Ciclo sui nodi che rispecchiano la ricerca
                    For Each m_node In m_nodelist

                        Try

                            '-- recupero il nodo figlio del tag serviceName ( che si chiama Name ) e ne prendo il valore
                            Dim valore As String = m_node.FirstChild.InnerText

                            If (valore.Contains(cnCertificatore)) Then
                                ret = True
                                Exit For
                            End If
                        Catch errore As Exception

                            Console.Write(errore.ToString())

                        End Try

                    Next

                    m_xmld = Nothing
                    m_nodelist = Nothing

                End If

            Catch ex As Exception

                Dbm.TraceDB("ERRORE ricerca trusted CA." & ex.Message, "checkIsTrusted()")

            End Try
            Return ret
        End Function





        ''' <returns></returns>
        Public Function verifyP7M(B As BlobEntryModelType, firmeMultipleIncrociate As Boolean) As AfCommon.ComplexResponseModelType

            'Dim TEMP_EXTRACTIONS As New List(Of String)

            Dim ret As New AfCommon.ComplexResponseModelType(False, "", "")
            Dim note As String = ""
            Dim checkValidAlgoritmoFirmas As Boolean = True
            Dim totNumSigner As Integer = 0
            Dim totFirme As Integer = 0

            Dim nomeFile As String = B.filename

            'Dbm.trace("Verifica firma digitale,File: " & fileid & " queryString: " & Replace(Request.QueryString.ToString, "'", "''"), "verifyP7M()")

            Dim strSql As String = ""
            Try

                Dbm.AppendOperation("Cancello i record vecchi ")
                '-- Se chi ci invoca è da parte del documento nuovo
                If Not String.IsNullOrWhiteSpace(ATT_Hash) Then
                    strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & Replace(ATT_Hash, "'", "''") & "'"
                Else
                    strSql = "delete from ctl_sign_attach_info where attIdMsg = " & CLng(attIdMsg) & " and attOrderFile = " & CLng(attOrderFile) & " and attIdObj = " & CLng(attIdObj)
                End If
                Dbm.ExecuteNonQuery(strSql, Nothing)
            Catch ex As Exception
                ret.out = "0#Errore nella cancellazione dei vecchi record associati all'allegato, " & ex.Message
                ret.esit = False
                Return ret
            End Try

            Dim crypt As New Chilkat.Crypt2()
            Dim success As Boolean = True
            Dim verificaP7mChilkat As Boolean = False
            Me.uniqueStr = "_" & Date.Now.Hour & Date.Now.Minute & Date.Now.Second & Date.Now.Millisecond & "_"
            MainUtils.UnlockChilkat(Dbm)
            Dim totIterazioni As Integer = 0

            '------------------------------------------------------------------------------------------------------------------
            '-- PER QUEI FILE P7M CON FIRMA MULTIPLA E CON BUSTA MULTIPLA ( quindi N .p7m.p7m ) chilkat
            '-- non estree tutte le firme ma estrae un p7m che ha a sua volta un p7m al suo interno.
            '-- dobbiamo iterare N volte il processo di estrazione
            '------------------------------------------------------------------------------------------------------------------

            verificaP7mChilkat = True

            '-- ITERO SULLE FIRME MULTIPLE "VERTICALI". CIOE' CON N BUSTE/ENVELOPE
            Dim CONTAINER_ELEMENT As BlobEntryModelType = Nothing           'è l'elemento contenitore dell'elemento corrente
            Dim TEMP_EXTRACTED As BlobEntryModelType = Nothing

            Dim ht_files As New Hashtable

            While verificaP7mChilkat = True AndAlso totIterazioni < 50

                totIterazioni = totIterazioni + 1
                'Verifica e ripristino del file originale
                Dim clearpath As String = ""
                Try
                    Dbm.fx_update_queue_operation("Checking Signature 1", 0)
                    Dim strFileDaEstrarre As String = outFile & uniqueStr & "estratto" & totIterazioni
                    clearpath = BlobManager.GetPureFileOnDisk(Dbm, B, True)

                    '-- se la busta p7m è valida ed il file che si vuole verificare è diverso dal file sbustato ( per evitare bug chilkat )
                    success = crypt.VerifyP7M(clearpath, strFileDaEstrarre)
                    success = success AndAlso Not (AfCommon.Tools.HashTools.GetHASHBytesToString(clearpath, AfCommon.Tools.SHA_Algorithm.SHA256) = AfCommon.Tools.HashTools.GetHASHBytesToString(strFileDaEstrarre, AfCommon.Tools.SHA_Algorithm.SHA256))

                    Dbm.AppendOperation("VerifyP7M effettuato")

                    If success Then

                        '-- se la verifica del contenuto con l'estensione non è ancora passata a verificata
                        If B._verificaEstensione.ToLower.Equals("verified") = False Then
                            B._verificaEstensione = "Verified"
                        End If

                        TEMP_EXTRACTED = BlobManager.create_blob_from_file(Dbm, strFileDaEstrarre, B.filename, False)
                        TEMP_EXTRACTED.filename = B.filename.Substring(0, B.filename.LastIndexOf(".", StringComparison.Ordinal))

                        BlobManager.fx_save_blob(Dbm, TEMP_EXTRACTED, False)

                    End If

                    If My.Computer.FileSystem.FileExists(strFileDaEstrarre) Then
                        My.Computer.FileSystem.DeleteFile(strFileDaEstrarre)
                    End If
                Catch ex As Exception
                    verificaP7mChilkat = False
                Finally
                    If My.Computer.FileSystem.FileExists(clearpath) Then
                        My.Computer.FileSystem.DeleteFile(clearpath)
                    End If
                End Try
                verificaP7mChilkat = success

                note = crypt.LastErrorText

                If verificaP7mChilkat = True Then
                    Dbm.fx_update_queue_operation("Checking Signature 2", 0)
                    'MOVE EXTRACT TO CURRENT
                    CONTAINER_ELEMENT = B
                    B = TEMP_EXTRACTED
                    Dim numSigner As Integer = crypt.NumSignerCerts
                    If numSigner <= 0 Then
                        numSigner = 1
                    End If

                    totNumSigner += numSigner

                    Dim certificato As Chilkat.Cert
                    'Dim certChain As Chilkat.CertChain   '-- usabile Dalla versione 9.5.0.49
                    Dim certificati(numSigner - 1) As Chilkat.Cert

                    '-- ITERO N VOLTE LA VERIFICA PER OGNI FIRMATARIO (GESTIONE FIRMA MULTIPLA)
                    '-- ITERO SULLE FIRME MULTIPLE "ORIZZONTALI"/"PARALLELE". CIOE' SUGLI N FIRMATARI PRESENTI A PARITA' DI BUSTA/ENVELOPE

                    For i As Integer = 0 To numSigner - 1
                        Dbm.AppendOperation("Ciclo Firmatari " & CStr(i))

                        certificato = crypt.GetSignerCert(i)
                        If IsNothing(certificato) Then
                            Throw New Exception(crypt.LastErrorText)
                        End If
                        'certChain = crypt.GetSignerCertChain(0)

                        Dim isExpired As Boolean = certificato.Expired
                        Dim scadenzaFirma As Date = certificato.ValidTo
                        Dim calNow As Date = Now().ToUniversalTime
                        Dim numeroSeriale As String = ""
                        Dim statoFirma As String = ""

                        numeroSeriale = certificato.SerialNumber


                        'Dim dtApposizioneFirma As DateTime
                        Dim algoritmoHashFirma As String = ""
                        Dim envelope As SignedCms = Nothing
                        ' dtApposizioneFirma = Nothing
                        Dim SigningTime As Date = crypt.GetSignatureSigningTime(i)
                        Dim assenzaDataFirma As Boolean = True

                        Dbm.AppendOperation("Salvo il certificato su disco e mi ricavo un array di byte")
                        '-- Salvo il certificato su disco e mi ricavo un array di byte
                        certificato.SaveToFile(outFile & uniqueStr & "cert.cer")
                        Dim objCertificato() As Byte = My.Computer.FileSystem.ReadAllBytes(outFile & uniqueStr & "cert.cer")
                        Try
                            System.IO.File.Delete(outFile & uniqueStr & "cert.cer")
                        Catch
                        End Try
                        Dim x509 As New X509Certificate2
                        x509.Import(objCertificato)

                        Dbm.AppendOperation("Verifico enableSignedCMS " & UCase(CStr(enableSignedCMS)))

                        If UCase(CStr(enableSignedCMS)) = "YES" Then

                            Try

                                envelope = New SignedCms
                                '-- questo metodo era molto lento, sopratutto con i file .zip.p7m  quindi tramite il parametro web.config disableSignedCMS ne abbiamo rimosso l'uso
                                '--     usando solo la libreria chilkat
                                envelope.Decode(BlobManager.GetPureBytes(Dbm, CONTAINER_ELEMENT))



                                'Dim val As System.Security.Cryptography.Pkcs.Pkcs9SigningTime
                                For kCiclo As Integer = 0 To envelope.SignerInfos.Count - 1
                                    '---------------------------------------------------------------------------------------------------
                                    '--- NON FUNZIONANDO BENE CHILKAT, NELLO SPECIFICO NON RECUPERA BENE LA DATA APPOSIZIONE FIRMA -----
                                    '--- PASSO A RECUPERARLA CON LE LIBRERIE DI BASSO LIVELLO DI SISTEMA.                          -----
                                    '---------------------------------------------------------------------------------------------------

                                    Dim info As SignerInfo = envelope.SignerInfos.Item(kCiclo)

                                    '--- ITERO SUI CERTIFICATI FINO A CHE NON MI FERMO SU QUELLO CHE STIA ELABORANDO NEL CICLO PIU' ESTERNO A QUESTO METODO

                                    If info.Certificate.SerialNumber = numeroSeriale Or totFirme = 1 Then

                                        Try

                                            algoritmoHashFirma = info.DigestAlgorithm.Value

                                        Catch

                                            '-- Se entreremo in questo catch è andato in errore il metodo decode
                                            '-- per "Unknown cryptographic algorithm", cioè non supporta l'algoritmo
                                            '-- utilizzato per la firma digitale. ad es. SHA256 o superiore
                                            '-- Questo accade nei sistemi windows 2003 o inferiori.
                                            '-- Se ci troviamo in questa casistica diamo per assunto che l'algoritmo non
                                            '-- essendo supportato non è quindi SHA1 ma SHA256 (per il futuro, quando
                                            '-- si adoterrà SHA512, si spera che sui clienti non ci sia più windows2003)

                                            algoritmoHashFirma = "2.16.840.1.101.3.4.2.1" 'OID value per SHA256

                                        End Try


                                        For Each a In info.SignedAttributes

                                            '-- itero su tutti gli attributi di firma e mi fermo su quello con codice OID
                                            '-- corrispondente con il codice dell'attributo di apposizione firma, restituire una collezione parlante no eh ?

                                            If a.Oid.Value = "1.2.840.113549.1.9.5" Then
                                                Dim val As System.Security.Cryptography.Pkcs.Pkcs9SigningTime = a.Values.Item(0)
                                                SigningTime = val.SigningTime
                                            End If
                                        Next

                                    End If


                                Next

                                envelope = Nothing

                                note = ""

                            Catch ex As Exception

                                note = "Errore nel recupero dell'algoritmo di firma." & ex.Message
                                envelope = Nothing

                                Try

                                    If algoritmoHashFirma = "" Then
                                        '-- proviamo il 2o metodo di recupero dell'algoritmo di firma
                                        algoritmoHashFirma = getDigestAlgorithm(crypt, i)
                                    End If

                                Catch ex2 As Exception
                                    note = "Errore nel recupero dell'algoritmo di firma." & ex2.Message
                                End Try

                                If algoritmoHashFirma = "" Then
                                    statoFirma = "SIGN_WARNING"
                                End If

                            End Try

                        Else

                            Try
                                algoritmoHashFirma = getDigestAlgorithm(crypt, i)
                            Catch ex As Exception
                                algoritmoHashFirma = ""
                            End Try

                            If String.IsNullOrWhiteSpace(algoritmoHashFirma) Then
                                Dim mapField = GetType(Org.BouncyCastle.Cms.CmsSignedData).Assembly.[GetType]("Org.BouncyCastle.Cms.CmsSignedHelper").GetField("digestAlgs", BindingFlags.[Static] Or BindingFlags.NonPublic)
                                Dim map = CType(mapField.GetValue(Nothing), System.Collections.IDictionary)
                                Dim hashAlgName = CStr(map(x509.SignatureAlgorithm.Value))
                                'Dim hashAlg = HashAlgorithm.Create(hashAlgName)
                                algoritmoHashFirma = resolveDigestAlgorithm(hashAlgName)
                            End If

                            If algoritmoHashFirma = "" Then
                                statoFirma = "SIGN_WARNING"
                            End If

                        End If

                        If crypt.HasSignatureSigningTime(i) = False Then
                            assenzaDataFirma = True
                        Else
                            assenzaDataFirma = False
                        End If


                        '-- Se la data di apposizione della firma è maggiore della scadenza del certificato   
                        If (SigningTime > scadenzaFirma) Then
                            isExpired = True
                        Else
                            isExpired = False
                        End If

                        '-- non usiamo più la verifica della revoka di chilkat ma quella implementata da noi

                        'Dim revoked As Integer = certificato.CheckRevoked()
                        Dim revoked As Integer = -1

                        Dim isTrusted As Boolean = False

                        Dim infoCertificatore As String = certificato.IssuerO 'INFOCERT SPA (ORganizzazione)
                        Dim cnCertificatore As String = "CN=" & certificato.IssuerCN 'InfoCert Firma Qualificata
                        Dim allInfoCertificatore As String = certificato.IssuerDN  'IssuerDN	"C=IT, O=INFOCERT SPA, SN=07945211006, OU=Certificatore Accreditato, CN=InfoCert Firma Qualificata"	string

                        Dim firmatario As String = certificato.SubjectCN  'Firmataro
                        Dim firmatarioOrg As String = certificato.SubjectO 'organizzazione firmatario
                        Dim firmatarioInfo As String = certificato.SubjectDN  'tutte le info sul firmatario

                        Dim statoEmittente As String = ""

                        Dim isCertificatoSottoscrizione As Boolean = False

                        Try
                            statoEmittente = certificato.IssuerC

                            If statoEmittente = "" Then
                                statoEmittente = "IT"
                            End If

                        Catch
                            statoEmittente = "IT"
                        End Try

                        Try

                            Dim ind As Integer = 0

                            If firmatarioInfo.Contains("SERIALNUMBER=") Then

                                ind = firmatarioInfo.IndexOf("SERIALNUMBER=")

                                firmatarioInfo = firmatarioInfo.Substring(ind + 13) 'recupero dal dopo SERIALNUMBER= in poi
                                firmatarioInfo = Split(firmatarioInfo, ",")(0) 'recupero IT:xxxx

                                If firmatarioInfo.Contains(":") Then
                                    firmatarioInfo = Split(firmatarioInfo, ":")(1) 'recupero solo il codice fiscale
                                End If

                            Else

                                ind = firmatarioInfo.IndexOf(", SN=")

                                firmatarioInfo = firmatarioInfo.Substring(ind + 5) 'recupero dal dopo SN= in poi
                                firmatarioInfo = Split(firmatarioInfo, ",")(0) 'recupero IT:xxxx

                                If firmatarioInfo.Contains(":") Then
                                    firmatarioInfo = Split(firmatarioInfo, ":")(1) 'recupero solo il codice fiscale
                                End If

                            End If


                        Catch ex As Exception

                            firmatarioInfo = CStr(firmatarioInfo)

                        End Try


                        'If Len(firmatarioInfo) <> 16 Then
                        'Dim snumber As String = certificato.SerialNumber
                        'firmatarioInfo = Split(snumber, ":")(1) 'codice fiscale
                        'End If

                        Dim alternativeNameFirmatario As String = certificato.Rfc822Name
                        Dim firmaValidaDal As Date = certificato.ValidFrom
                        Dim firmaValidaAl As Date = certificato.ValidTo
                        Dim infoCertificateChain As String = ""
                        Dim usoCertificato As String = ""

                        Try

                            Dim codiceFiscaleFirmatario As String = ""

                            If Len(firmatarioInfo) <> 16 Then

                                codiceFiscaleFirmatario = x509.Subject

                                If codiceFiscaleFirmatario.Contains("SERIALNUMBER=") Then
                                    Dim ind As Integer = codiceFiscaleFirmatario.IndexOf("SERIALNUMBER=", StringComparison.Ordinal)
                                    codiceFiscaleFirmatario = codiceFiscaleFirmatario.Substring(ind + 13) 'recupero dal dopo SERIALNUMBER= in poi
                                    codiceFiscaleFirmatario = Split(codiceFiscaleFirmatario, ",")(0) 'recupero IT:xxxx

                                    If codiceFiscaleFirmatario.Contains(":") Then
                                        firmatarioInfo = Split(codiceFiscaleFirmatario, ":")(1) 'recupero solo il codice fiscale
                                    Else
                                        firmatarioInfo = codiceFiscaleFirmatario
                                    End If

                                End If


                            End If

                        Catch ex As Exception
                        End Try

                        Dbm.AppendOperation("getInfoUtilizzoCertificato")

                        Try
                            '-- provo a recuperare i flag d'uso del certificato dal x509 per poi passare a recuperarli da chilkat ( che non gestisce bene un uso di certificato con N flag insieme )
                            Call Me.getInfoUtilizzoCertificato(x509, isCertificatoSottoscrizione, usoCertificato)
                        Catch ex As Exception
                        End Try

                        Dim motivoRevoca As String = ""
                        Dbm.AppendOperation("checkAlgoritmoFirma")
                        checkValidAlgoritmoFirmas = Me.checkAlgoritmoFirma(algoritmoHashFirma, SigningTime)

                        Dbm.AppendOperation("verifica CheckRevoked")
                        If UCase(AfCommon.AppSettings.item("app.BLOCK_VERIFY_REVOKE")) <> "YES" Then
                            Try
                                '-- effettuo una priva verifica di revoca tramite chilat poi se non ci riesce passo alle api di windows
                                revoked = certificato.CheckRevoked

                                Dbm.AppendOperation("fine verifica CheckRevoked " & CStr(revoked))

                            Catch ex As Exception
                                revoked = -1
                            End Try



                            If (revoked - 1) Then

                                Dbm.AppendOperation("verificaRevocaChilkat")

                                Try
                                    '  0: Good
                                    '  1: Revoked
                                    '  2: Unknown.
                                    revoked = Me.verificaRevocaChilkat(certificato)   '- verifica chilkat tramite OCSP

                                    Dbm.AppendOperation("fine verificaRevocaChilkat " & CStr(revoked))

                                    If revoked = 2 Then
                                        revoked = -1
                                    End If

                                Catch ex As Exception
                                    revoked = -1
                                End Try



                            End If

                            '-- se non è stato possibile verificare la revoca con chilkat scendiamo di livello (api di windows)
                            If (revoked = -1) Then

                                Dbm.AppendOperation("verificaRevocaWindows")

                                Dim esitoVerifica As New Microsoft.VisualBasic.Collection
                                esitoVerifica = Me.verificaRevocaWindows(x509, SigningTime)

                                motivoRevoca = esitoVerifica("motivo")
                                revoked = esitoVerifica("revocato")

                                If motivoRevoca <> "" Then
                                    note = note & motivoRevoca
                                End If

                                Dbm.AppendOperation("fine verificaRevocaWindows")

                            End If
                        End If
                        Dbm.AppendOperation("checkIsTrusted")

                        Try
                            isTrusted = checkIsTrusted(cnCertificatore, SigningTime, tslFromTable, tsl_online, pathTsl, urlTsl, statoEmittente)
                        Catch ex As Exception
                            isTrusted = True
                        End Try

                        Dbm.AppendOperation("fine checkIsTrusted")

                        Try

                            '-- se non sono già state settate le note
                            If note = "" Then

                                note = "INFO CA : " & vbCrLf
                                note = note & allInfoCertificatore & vbCrLf
                                note = note & "INFO SIGNER : " & vbCrLf
                                note = note & certificato.SubjectDN

                                If revoked <> 0 Then
                                    note = note & " ---- : " & motivoRevoca
                                End If

                            End If


                        Catch ex As Exception
                            note = ""
                        End Try



                        Try

                            If isCertificatoSottoscrizione = False Then
                                isCertificatoSottoscrizione = If(certificato.IntendedKeyUsage = 64, 1, 0)
                            End If

                        Catch ex As Exception
                            isCertificatoSottoscrizione = True
                        End Try


                        ' Dalla documentazione chilkat ,certificato.IntendedKeyUsage :
                        ' Digital Signature: 128
                        ' Non-Repudiation: 64
                        ' Key Encipherment: 32
                        ' Data Encipherment: 16
                        ' Key Agreement: 8
                        ' Certificate Signing: 4
                        ' CRL Signing: 2
                        ' Encipher-Only: 1

                        If usoCertificato = "" Then
                            Select Case certificato.IntendedKeyUsage
                                Case 128
                                    usoCertificato = "Digital Signature"
                                Case 64
                                    usoCertificato = "Non-Repudiation"
                                Case 32
                                    usoCertificato = "Key Encipherment"
                                Case 16
                                    usoCertificato = "Data Encipherment"
                                Case 8
                                    usoCertificato = "Key Agreement"
                                Case 4
                                    usoCertificato = "Certificate Signing"
                                Case 2
                                    usoCertificato = "CRL Signing"
                                Case 1
                                    usoCertificato = "Encipher-Only"
                            End Select
                        End If



                        '-- se non è stato già impostato uno stato firma
                        If statoFirma = "" Then

                            If (verificaP7mChilkat) And isTrusted And Not isExpired And isCertificatoSottoscrizione And checkValidAlgoritmoFirmas And (revoked <= 0) Then

                                If (revoked = 0) Then
                                    statoFirma = "SIGN_OK" '-- Tutto ok
                                Else
                                    statoFirma = "SIGN_OK_NOT_VER_REVOCA" '-- Tutto ok tranne che è stato possibile verifica se il certificato è revocato
                                End If

                            Else

                                '-- Se uno dei dati obbligatori manca, non lo consideriamo NON valido, ma mancante. Quindi lo stato complessivo sarà WARNING piuttosto che KO
                                If algoritmoHashFirma = "" Or cnCertificatore = "" Then
                                    statoFirma = "SIGN_WARNING" '-- Non abbiamo potuto verificare la bontà della firma
                                Else
                                    statoFirma = "SIGN_NOT_OK" '-- Firma non valida"
                                End If

                            End If

                        End If



                        '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
                        strSql = ""
                        Try
                            Dbm.AppendOperation("Compongo la insert per la CTL_SIGN_ATTACH_INFO ")
                            strSql = "INSERT INTO CTL_SIGN_ATTACH_INFO " &
                                        "( " &
                                        "ATT_Hash " &
                                        ",isTrustedCA " &
                                        ",isRevoked " &
                                        ",isExpired " &
                                        ",isCertificatoSottoscrizione " &
                                        ",isValidSign " &
                                        ",isValidAlgoritm " &
                                        ",signExt " &
                                        ",certificatore " &
                                        ",codFiscFirmatario " &
                                        ",firmatario " &
                                        ",dataApposizioneFirma" &
                                        ",scadenzaFirma " &
                                        ",nomeFile " &
                                        ",numSigners " &
                                        ",usoCertificato " &
                                        ",statoFirma " &
                                        ",attIdMsg " &
                                        ",attOrderFile " &
                                        ",attIdObj " &
                                        ",objCertificato " &
                                        ",idAzi " &
                                        ",algoritmo " &
                                        ",VerificaCF " &
                                        ",note,CountryName, subjectSerialNumber, certificateSerialNumber) " &
                                        "VALUES(" &
                                        "@ATT_Hash," &
                                        "" & If(isTrusted, 1, 0) & "," &
                                        "" & revoked & "," &
                                        "" & If(isExpired, 1, 0) & "," &
                                        "" & If(isCertificatoSottoscrizione, 1, 0) & "," &
                                        "" & If(verificaP7mChilkat, 1, 0) & "," &
                                        "" & If(checkValidAlgoritmoFirmas, 1, 0) & "," &
                                        "'P7M'," &
                                        "@certificatore," &
                                        "@codFiscFirmatario," &
                                        "@firmatario," &
                                        "@datafirma," &
                                        "@scadenzafirma," &
                                        "@nomeFile," &
                                        "" & numSigner & "," &
                                        "@usoCertificato," &
                                        "@statoFirma" &
                                        "," & If(attIdMsg = "", "NULL", CStr(attIdMsg)) &
                                        "," & If(attOrderFile = "", "NULL", CStr(attOrderFile)) &
                                        "," & If(attIdObj = "", "NULL", CStr(attIdObj)) &
                                        ",@objCertificato" &
                                        "," & IIf(idAzi = "", "NULL", CStr(idAzi)) &
                                        ",@algoritmo" &
                                        "," & IIf(revoked = -1, -1, 0) &
                                        ",@note" &
                                        ",@CountryName" &
                                        ",@subjectSerialNumber" &
                                        ",@certificateSerialNumber" &
                                        ")"
                            Dbm.AppendOperation("Eseguo la insert sulla CTL_SIGN_ATTACH_INFO")

                            Dim params As New Collections.Hashtable
                            params("@objCertificato") = objCertificato
                            params("@ATT_Hash") = ATT_Hash
                            params("@certificatore") = Replace(cnCertificatore, "CN=", "")
                            params("@codFiscFirmatario") = firmatarioInfo
                            params("@firmatario") = firmatario
                            params("@nomeFile") = nomeFile
                            params("@usoCertificato") = usoCertificato
                            params("@statoFirma") = statoFirma
                            params("@algoritmo") = algoritmoHashFirma
                            params("@note") = note
                            params("@CountryName") = statoEmittente
                            params("@subjectSerialNumber") = firmatarioInfo
                            params("@certificateSerialNumber") = numeroSeriale
                            If assenzaDataFirma Then
                                params("@datafirma") = DBNull.Value
                            Else
                                params("@datafirma") = SigningTime
                            End If
                            params("@scadenzafirma") = scadenzaFirma
                            Dbm.ExecuteNonQuery(strSql, params)
                            objCertificato = Nothing

                            Dbm.AppendOperation("Invoco la stored GET_INFO_FIRMA")

                            '--- INVOCO LA STORED 'GET_INFO_FIRMA' --
                            '--- PER EFFETTUARE EVENTUALI CONTROLLI O MODIFICHE AGGIUNTIVE DELEGANDOLE ALLA STORED
                            '--- COSì DA NON DOVER PER FORZA RICOMPILARE LA DLL NEL CASO SI RIESCA
                            '--- A GESTIRE L'ECCEZIONE ALL'INTERNO DELLA STORED
                            strSql = "exec GET_INFO_FIRMA '" & Replace(CStr(x509.Subject), "'", "''") & "','" & Replace(CStr(x509.Issuer), "'", "''") & "','" & Replace(CStr(algoritmoHashFirma), "'", "''") & "','" & Replace(CStr(x509.ToString), "'", "''") & "'"

                            '-- aggiungo le informazioni per recuperare in modo univoco il record appena inserito
                            If ATT_Hash <> "" Then
                                strSql = strSql & ",'" & Replace(ATT_Hash, "'", "''") & "'"
                            Else
                                strSql = strSql & ",''," & CStr(CLng(attIdMsg)) & "," & CStr(CLng(attOrderFile)) & "," & CStr(CLng(attIdObj)) & ""
                            End If
                            'Response.Write(strSql)
                            Dbm.ExecuteNonQuery(strSql, Nothing)


                            x509 = Nothing
                            totFirme += 1
                        Catch ex As Exception
                            ret.out = "0#" & ex.Message
                            ret.esit = False
                            Return ret
                        End Try
                    Next
                ElseIf (totIterazioni = 1) Then '-- Se siamo nel primo livello di iterazione
                    '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
                    strSql = ""
                    Try
                        Dbm.AppendOperation("Compongo la insert per la CTL_SIGN_ATTACH_INFO ")
                        '-- Se chi ci invoca è da parte del documento nuovo
                        'If ATT_Hash <> "" Then
                        'strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & ATT_Hash & "'"
                        'Else
                        'strSql = "delete from ctl_sign_attach_info where attIdMsg = " & attIdMsg & " and attOrderFile = " & attOrderFile & " and attIdObj = " & attIdObj
                        'End If

                        strSql = "INSERT INTO CTL_SIGN_ATTACH_INFO " &
                                "( " &
                                "isValidSign " &
                                ",nomeFile " &
                                ",statoFirma " &
                                ",ATT_Hash " &
                                ",attIdMsg " &
                                ",attOrderFile " &
                                ",attIdObj " &
                                ",note) " &
                                "VALUES(" &
                                "0"

                        Try
                            strSql = strSql & ",'" & Replace(B.filename, "'", "''") & "'"
                        Catch ex As Exception
                            strSql = strSql & ",''"
                        End Try


                        strSql = strSql & ",'SIGN_NOT_OK'" &
                                ",'" & Replace(ATT_Hash, "'", "''") & "'" &
                            "," & IIf(attIdMsg = "", "NULL", attIdMsg) &
                            "," & IIf(attOrderFile = "", "NULL", attOrderFile) &
                            "," & IIf(attIdObj = "", "NULL", attIdObj) &
                                ",'Allegato p7m non firmato, " & Replace(note, "'", "''") & "'" &
                                ")"


                        Dbm.AppendOperation("Eseguo la insert sulla CTL_SIGN_ATTACH_INFO")
                        Dbm.ExecuteNonQuery(strSql, Nothing)
                    Catch ex As Exception
                        Dim strcause As String = "XXX"
                        ret.out = "0#" & strcause & "," & ex.Message
                        ret.esit = False
                        Return ret
                    End Try

                    Exit While '-- l'ultima verifica effettuata non aveva la firma digitale applicava o era corrotta
                End If
                'copyPathP7m = outFile & uniqueStr & "estratto" & totIterazioni
            End While


            '-- Gestione firma multipla, p7m esterno e pdf firmato all'interno
            '-- se non è andata in errore la verifyP7M e se il file p7m aveva almeno una busta, controllo se il file estratto è un pdf a sua volta firmato
            If Not IsNothing(TEMP_EXTRACTED) Then
                Dim out As String = ""
                Dim a As New sign.Utils(Dbm)

                a.ATT_Hash = Me.ATT_Hash

                If Not String.IsNullOrWhiteSpace(Me.idAzi) Then
                    a.idAzi = Me.idAzi
                End If

                a.originalFileName = nomefile

                firmeMultipleIncrociate = True

                Dim statofirma As AfCommon.ComplexResponseModelType = a.verifyPdfSigned(TEMP_EXTRACTED, firmeMultipleIncrociate)
                Try
                    strSql = ""
                    '-- Se chi ci invoca è da parte del documento nuovo
                    If ATT_Hash <> "" Then
                        strSql = "update ctl_sign_attach_info set numSigners = numSigners + " & CStr(totFirme) & " where ATT_Hash = '" & Replace(ATT_Hash, "'", "''") & "'"
                    Else
                        strSql = "update ctl_sign_attach_info set numSigners = numSigners + " & CStr(totFirme) & " where attIdMsg = " & CLng(attIdMsg) & " and attOrderFile = " & CLng(attOrderFile) & " and attIdObj = " & CLng(attIdObj)
                    End If
                    Dbm.ExecuteNonQuery(strSql, Nothing)
                Catch ex As Exception
                End Try
            End If

            'If totIterazioni > 0 Then
            '    '-- Cancelliamo tutti i file estratti
            '    For k As Integer = totIterazioni To 0 Step -1
            '        Try
            '            System.IO.File.Delete(outFile & uniqueStr & "estratto" & k)
            '        Catch
            '        End Try
            '    Next
            'End If
            Try
                crypt.Dispose()
                crypt = Nothing
            Catch ex As Exception
            End Try
            ret.out = "1#OK"
            ret.esit = True
            Return ret

        End Function


        Private Function getDigestAlgorithm(ByRef crypt As Chilkat.Crypt2, ByVal indexFirmatario As Integer) As String
            Dim json As Chilkat.JsonObject = crypt.LastJsonData
            json.EmitCompact = False
            json.Emit()
            If IsNumeric(indexFirmatario) = False Then
                indexFirmatario = 0
            End If
            Dim oid_digest_alg As String = json.StringOf("pkcs7.verify.signerInfo[" & indexFirmatario & "].cert.digestAlgOid")
            If oid_digest_alg <> "" Then
                Return oid_digest_alg
            Else
                Dim alg As String = json.StringOf("pkcs7.verify.digestAlgorithms[0]")
                Return resolveDigestAlgorithm(alg)
            End If
        End Function

        Private Function resolveDigestAlgorithm(alg As String) As String
            If Not String.IsNullOrWhiteSpace(alg) Then

                Select Case alg.ToUpper
                    Case "SHA256"
                        Return "2.16.840.1.101.3.4.2.1"
                    Case "SHA384"
                        Return "2.16.840.1.101.3.4.2.2"
                    Case "SHA512"
                        Return "2.16.840.1.101.3.4.2.3"
                End Select
            End If
            Return String.Empty
        End Function

        Public Function checkAlgoritmoFirma(alg As String, dataFirma As DateTime) As Boolean
            Dim ret As Boolean = True
            Dim params As New Collections.Hashtable
            params("@datafirma") = dataFirma
            params("@alg") = alg
            Dim strSql As String = "select * FROM CTL_RelationsTime "
            strSql = strSql & " where REL_Type = 'VERIFICA_ALGORITMO_FIRMA' and REL_ValueInput = @alg AND @datafirma >= REL_Data_I AND @datafirma <= REL_Data_F"
            using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(strSql,params)
                ret = dr.Read
            End Using
            Return ret
        End Function
    End Class
End Namespace