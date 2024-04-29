
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
Imports iTextSharp.text.pdf.security

'-- *********************************************************************
'-- * Versione=1&data=2012-05-24&Attvita=&Nominativo=FedericoLeone *
'-- *********************************************************************

Namespace sign

    Public Class Utils

        Dim tsl_online As String = ConfigurationSettings.AppSettings("app.tsl_online")
        Dim outFile As String = ConfigurationSettings.AppSettings("app.directory_output_p7m")
        Dim pathTsl As String = ConfigurationSettings.AppSettings("app.path_xml_tsl")
        Dim urlTsl As String = ConfigurationSettings.AppSettings("app.url_xml_tsl")
        Dim table_info_sign As String = ConfigurationSettings.AppSettings("app.table_sign")
        Dim tslFromTable As String = ConfigurationSettings.AppSettings("app.tsl_da_tabella")

        Public isTrusted As Boolean = False
        Public revoked As Integer = False
        Public isExpired As Boolean = False
        Public verificaFirma As Boolean = False
        Public firmatario As String = ""
        Public firmatarioInfo As String = ""
        Public scadenzaFirma As Date
        Public cnCertificatore As String = ""

        Public totFirme As Integer = 0

        Public ATT_Hash As String = "NULL" 'chiave di aggancio per i documenti nuovi
        Public attIdMsg As String = "NULL" 'chiave di aggancio per i documenti generici
        Public attOrderFile As String = "NULL" 'chiave di aggancio per i documenti generici
        Public attIdObj As String = "NULL" 'chiave di aggancio per i documenti generici
        Public idAzi As String = "NULL"

        Public originalFileName As String = ""

        Public strCause As String = ""

        Sub New()

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

        Public Function verifyPdfSigned(ByVal pdf As String, ByRef out As String, ByVal request As HttpRequest, Optional firmeMultipleIncrociate As Boolean = False) As Boolean

            Dim db As New DbUtil
            Dim hashAllegato As String = ""
            Dim checkFile As Boolean = True
            Dim nomeFile As String = Split(pdf, "\")(Split(pdf, "\").Length - 1)
            Dim reader As PdfReader = Nothing
            Dim strErr As String = ""
            Dim idpfu As String = ""
            Dim algoritmoHashFirma As String = ""
            Dim checkValidAlgoritmoFirmas As Boolean = True
            Dim BLOCK_VERIFY_REVOKE As Boolean = False

            totFirme = 0

            Try

                strCause = "Test estensione file"
                If pdf.EndsWith(".p7m") = False Then
                    strCause = "New PdfReader"
                    reader = New PdfReader(pdf)
                    strCause = "recupero numero firme"
                    totFirme = reader.AcroFields.GetSignatureNames.Count
                    checkFile = True
                Else
                    checkFile = False
                    totFirme = 0
                End If

                If totFirme = 0 And firmeMultipleIncrociate = True Then

                    If Not reader Is Nothing Then
                        strCause = "Close del reader 1"
                        reader.Close()
                    End If

                    Return True
                End If

            Catch ex As Exception

                Try

                    strCause = "Catch1.desc:" & ex.Message

                    If Not reader Is Nothing Then
                        strCause = "Close del reader 2"
                        reader.Close()
                    End If

                Catch ex2 As Exception
                End Try

                checkFile = False
                strErr = ex.Message

            End Try


            '-- Se il file pdf non è firmato digitalmente tracciamo la cosa nel db e usciamo dalla funzione
            If checkFile = False Or reader Is Nothing Or totFirme = 0 Then

                strCause = "db.init"

                '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
                If (db.init() = True) Then

                    Dim strSql As String = ""
                    strSql = "select id from LIB_Dictionary where dzt_name='SYS_BLOCK_VERIFY_REVOKE' and DZT_ValueDef = 'YES'"
                    Dim sqlComm1 As New SqlCommand(strSql, db.sqlConn)
                    Dim rs As SqlDataReader = sqlComm1.ExecuteReader()
                    If (rs.Read()) Then
                        BLOCK_VERIFY_REVOKE = True
                    End If

                    rs.Close()
                    strSql = ""

                    If firmeMultipleIncrociate = False Then



                        Try

                            If Not request Is Nothing Then
                                db.trace("Verifica PDF, queryString: " & request.QueryString.ToString, "verifyPdfSigned()")
                            End If

                            strCause = "Compongo la insert per la CTL_SIGN_ATTACH_INFO "

                            '-- Se chi ci invoca è da parte del documento nuovo
                            If ATT_Hash <> "NULL" Then
                                strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & ATT_Hash & "' and statoFirma <> 'SIGN_PENDING'"
                            Else
                                strSql = "delete from ctl_sign_attach_info where attIdMsg = " & attIdMsg & " and attOrderFile = " & attOrderFile & " and attIdObj = " & attIdObj
                            End If

                            Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                            sqlComm.ExecuteNonQuery()

                            strCause = "invoco metodo tracciaFirmaNonValida"

                            tracciaFirmaNonValida(db, firmeMultipleIncrociate, nomeFile, strCause)

                            strCause = "reader close1"

                            Try
                                reader.Close()
                            Catch ex As Exception

                            End Try


                        Catch ex As Exception

                            db.close()
                            out = ("0#" & strCause & "," & ex.Message)
                            Return False

                        End Try

                    Else

                        Try
                            reader.Close()
                        Catch ex As Exception
                        End Try

                    End If

                End If

                db.close()

                out = "1#OK"
                Return True

            End If

            '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
            If (db.init() = True) Then

                If firmeMultipleIncrociate = False Then

                    Dim strSql As String = ""

                    Try

                        If Not request Is Nothing Then
                            db.trace("Verifica PDF, queryString: " & request.QueryString.ToString, "verifyPdfSigned()")
                        End If

                        strCause = "Cancello i record vecchi "

                        '-- Se chi ci invoca è da parte del documento nuovo
                        If ATT_Hash <> "NULL" Then
                            strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & Replace(ATT_Hash, "'", "''") & "' and statoFirma <> 'SIGN_PENDING'"
                        Else
                            strSql = "delete from ctl_sign_attach_info where attIdMsg = " & CLng(attIdMsg) & " and attOrderFile = " & CLng(attOrderFile) & " and attIdObj = " & CLng(attIdObj)
                        End If

                        Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                        sqlComm.ExecuteNonQuery()

                    Catch ex As Exception

                        out = ("0#Errore nella cancellazione dei vecchi record associati all'allegato, " & ex.Message)
                        db.close()
                        Return False

                    End Try

                End If

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

                Catch ex As Exception

                    tracciaFirmaNonValida(db, firmeMultipleIncrociate, nomeFile, strCause, ex.Message)

                    Try
                        reader.Close()
                    Catch ex2 As Exception

                    End Try

                    db.close()

                    out = "1#OK"
                    Return True

                End Try



                '-- Converto il certificato dal formato di bouncycastle in quello delle apiwindows

                Dim certificato As New X509Certificate2
                certificato.Import(pk.SigningCertificate.GetEncoded())

                'algoritmoHashFirma = certificato.SignatureAlgorithm.Value

                Try


                    algoritmoHashFirma = pk.DigestAlgorithmOid

                    'Dim signedCms As New System.Security.Cryptography.Pkcs.SignedCms
                    'Dim info As System.Security.Cryptography.Pkcs.SignerInfo

                    'signedCms.Decode(ReadFile(pdf))  '-- per il file del firmatario estero ottengo un {"Valore tag ASN1 non valido."}
                    'info = signedCms.SignerInfos.Item(i)
                    'algoritmoHashFirma = info.DigestAlgorithm.Value

                Catch ex As Exception

                    Try
                        Dim signedCms As New System.Security.Cryptography.Pkcs.SignedCms
                        Dim info As System.Security.Cryptography.Pkcs.SignerInfo

                        signedCms.Decode(ReadFile(pdf))
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

                verificaFirma = True

                Call getInfoUtilizzoCertificato(certificato, isCertificatoSottoscrizione, usoCertificato)

                cnCertificatore = pk.SigningCertificate.IssuerDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.CN)(0).ToString

                Try
                    firmatario = pk.SigningCertificate.SubjectDN.GetValues(Org.BouncyCastle.Asn1.X509.X509Name.CN)(0).ToString
                Catch
                End Try

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

                Dim cal As Date = Nothing

                Try

                    cal = pk.SignDate

                    If IsNothing(cal) Then
                        cal = Now()
                    End If

                Catch ex As Exception

                    cal = Now()

                End Try



                scadenzaFirma = pk.SigningCertificate.NotAfter

                '-- Se la data di firma è maggiore della scadenza del certificato   
                If (cal > scadenzaFirma) Then
                    isExpired = True
                End If

                isTrusted = checkIsTrusted(cnCertificatore, cal, tslFromTable, tsl_online, pathTsl, urlTsl, statoEmittente)

                Dim pkc As Org.BouncyCastle.X509.X509Certificate() = pk.SignCertificateChain
                Dim motivoRevoca As String = ""

                verificaFirma = pk.Verify()

                checkValidAlgoritmoFirmas = db.checkAlgoritmoFirma(algoritmoHashFirma, cal.ToString("yyyy-MM-dd"))

                revoked = -1

                If BLOCK_VERIFY_REVOKE = False Then
                    Try

                        x509.Import(certificato.GetRawCertData)

                        Dim esitoVerifica As New Microsoft.VisualBasic.Collection



                        esitoVerifica = verificaRevocaWindows(x509, cal)

                        motivoRevoca = esitoVerifica("motivo")
                        revoked = esitoVerifica("revocato")

                        If motivoRevoca <> "" Then
                            note = note & motivoRevoca
                        End If

                        x509 = Nothing



                    Catch ex As Exception

                        revoked = -1

                        '-- se è andata in errore la verifica della revoca
                        '-- proviamo tramite i metodi offerti da iTextSharp
                        '-- per verificare la revoca tramite ocsp

                        Try
                            If Not IsNothing(pk.Ocsp) Then
                                If pk.IsRevocationValid() Then
                                    revoked = 1
                                Else
                                    revoked = 0
                                End If
                            End If
                        Catch ex2 As Exception
                            revoked = -1
                        End Try

                        'revoked = IIf(pk.IsRevocationValid(), 1, 0) Or IIf(PdfPKCS7.VerifyOcspCertificates(pk.Ocsp, kall), 1, 0)

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

                If verificaFirma And isTrusted And Not isExpired And isCertificatoSottoscrizione And checkValidAlgoritmoFirmas And (revoked <= 0) Then
                    If (revoked = 0) Then
                        statoFirma = "SIGN_OK" '-- Tutto ok
                    Else
                        statoFirma = "SIGN_OK_NOT_VER_REVOCA" '-- Tutto ok tranne che è stato possibile verifica se il certificato è revocato
                    End If
                Else
                    statoFirma = "SIGN_NOT_OK" '-- Firma non valida
                End If

                '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
                If (db.init() = True) Then

                    Dim strSql As String = ""

                    Try

                        strCause = "Compongo la insert per la CTL_SIGN_ATTACH_INFO "

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
                                    "" & IIf(isTrusted, 1, 0) & "," &
                                    "" & revoked & "," &
                                    "" & IIf(isExpired, 1, 0) & "," &
                                    "" & IIf(isCertificatoSottoscrizione, 1, 0) & "," &
                                    "" & IIf(verificaFirma, 1, 0) & "," &
                                    "" & IIf(checkValidAlgoritmoFirmas, 1, 0) & "," &
                                    "'PDF'," &
                                    "'" & Replace(Replace(cnCertificatore, "'", "''"), "CN=", "") & "'," &
                                    "'" & Replace(firmatarioInfo, "'", "''") & "'," &
                                    "'" & Replace(firmatario, "'", "''") & "'," &
                                    "'" & Replace(cal.ToString("yyyy-MM-dd HH:mm:ss"), ".", ":") & "'," &
                                    "'" & Replace(scadenzaFirma.ToString("yyyy-MM-dd HH:mm:ss"), ".", ":") & "',"

                        If firmeMultipleIncrociate Then
                            strSql = strSql & "'" & Replace(Split(originalFileName, "\")(Split(originalFileName, "\").Length - 1), "'", "''") & "'"
                        Else
                            strSql = strSql & "'" & Replace(nomeFile, "'", "''") & "'"
                        End If


                        strSql = strSql & "," & names.Count & "," &
                                    "'" & Replace(usoCertificato, "'", "''") & "'," &
                                    "'" & Replace(statoFirma, "'", "''") & "'" &
                                    "," & IIf(Trim(attIdMsg) = "", "NULL", attIdMsg) &
                                    "," & IIf(Trim(attOrderFile) = "", "NULL", attOrderFile) &
                                    "," & IIf(Trim(attIdObj) = "", "NULL", attIdObj) &
                                    ",@objCertificato" &
                                    "," & IIf(idAzi = "", "NULL", idAzi) &
                                    ",'" & Replace(algoritmoHashFirma, "'", "''") & "'" &
                                    "," & IIf(revoked = -1, -1, 0) &
                                    ",'" & Replace(note, "'", "''") & "'" &
                                    ",'" & Replace(statoEmittente, "'", "''") & "'" &
                                    ",'" & Replace(firmatarioInfo, "'", "''") & "'" &
                                    ",'" & Replace(serialNumberCertificato, "'", "''") & "'" &
                                 ")"

                        strCause = "Eseguo la insert sulla CTL_SIGN_ATTACH_INFO"

                        Dim sqlComm As New SqlCommand(strSql, db.sqlConn)

                        Dim myParameter As SqlParameter = New SqlParameter("@objCertificato", SqlDbType.Image, pk.SigningCertificate.GetEncoded().Length)
                        myParameter.Value = pk.SigningCertificate.GetEncoded()
                        sqlComm.Parameters.Add(myParameter)

                        sqlComm.ExecuteNonQuery()

                        Try
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

                            'Response.Write(strSql)

                            sqlComm = New SqlCommand(strSql, db.sqlConn)
                            sqlComm.ExecuteNonQuery()

                        Catch ex2 As Exception

                        End Try

                    Catch ex As Exception

                        out = ("0#" & strCause & "," & ex.Message)
                        db.close()
                        Return False

                    End Try

                End If

            Next

            db.close()
            reader.Close()
            reader = Nothing

            out = "1#OK"

            Return True

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

            '  Convert our JSON to a binary (ASN.1) OCSP request
            http.CreateOcspRequest(json, ocspRequest)

            '  Send the OCSP request to the OCSP server
            Dim resp As Chilkat.HttpResponse = http.PBinaryBd("POST", ocspUrl, ocspRequest, "application/ocsp-request", False, False)
            If (http.LastMethodSuccess <> True) Then
                Return 2
            End If


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

        Public Sub tracciaFirmaNonValida(db As DbUtil, firmeMultipleIncrociate As Boolean, nomeFile As String, ByRef strCause As String, Optional motiviExtra As String = "")

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

            strSql = strSql & ",'SIGN_NOT_OK'" &
                     ",'" & Replace(ATT_Hash, "'", "''") & "'" &
                    "," & IIf(attIdMsg = "", "NULL", attIdMsg) &
                    "," & IIf(attOrderFile = "", "NULL", attOrderFile) &
                    "," & IIf(attIdObj = "", "NULL", attIdObj) &
                     ",'Allegato non firmato." & motiviExtra & "'" &
                     ")"


            strCause = "Eseguo la insert sulla CTL_SIGN_ATTACH_INFO"

            Dim sqlComm = New SqlCommand(strSql, db.sqlConn)
            sqlComm.ExecuteNonQuery()

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

    End Class


    


End Namespace