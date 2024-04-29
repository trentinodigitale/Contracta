Imports System.Xml
Imports System.Security.Cryptography.X509Certificates
Imports System.Security.Cryptography.Pkcs
Imports System.Data.SqlClient
Imports System.Data
Imports System.IO
Imports System.Collections
Imports iTextSharp.text.pdf
Imports System.Security.Cryptography
Imports System.Configuration
Imports System.Reflection



'Imports Pdftools

' PARAMETRI
'  mode 
'  isSigned
'  signedfile
'  ATT_Hash
'  attIdMsg
'  attOrderFile
'  attIdObj

'-- *********************************************************************
'-- * Versione=1&data=2012-05-24&Attvita=&Nominativo=FedericoLeone *
'-- * Versione=2&data=2014-05-05&Attvita=56165&Nominativo=FedericoLeone *
'-- *********************************************************************

Public Class pdf
    Inherits System.Web.UI.Page

    Dim tsl_online As String = ConfigurationSettings.AppSettings("app.tsl_online")
    Dim outFile As String = ConfigurationSettings.AppSettings("app.directory_output_p7m")
    Dim pathTsl As String = ConfigurationSettings.AppSettings("app.path_xml_tsl")
    Dim urlTsl As String = ConfigurationSettings.AppSettings("app.url_xml_tsl")
    Dim table_info_sign As String = ConfigurationSettings.AppSettings("app.table_sign")
    Dim tslFromTable As String = ConfigurationSettings.AppSettings("app.tsl_da_tabella")

    Dim enableSignedCMS As String = ConfigurationSettings.AppSettings("app.enableSignedCMS")

    Dim totIterazioni As Integer = 0
    Dim uniqueStr As String = ""

    Dim strFileEstratto As String = ""

    Dim codiceAttivazioneChilkat As String = "AFSLZN.CBX012020_qnMbzzsEprmC"

    'Declare Function CertVerifyRevocation Lib "crypt32.dll" (TODO) As TODO ??

    Public Sub New()

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

        If tslFromTable Is Nothing Or CStr(tslFromTable) = "" Then

            tslFromTable = IniRead(path & "../application.ini", "FIRMA", "tsl_da_tabella")

            '-- se non è stata trovata la chiave metto un default
            If tslFromTable = "<Not_Found>" Then
                tslFromTable = "si"
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

        If table_info_sign Is Nothing Or CStr(table_info_sign) = "" Then
            table_info_sign = IniRead(path & "../application.ini", "FIRMA", "table_sign")

            '-- se non è stata trovata la chiave metto un default
            If table_info_sign = "<Not_Found>" Then
                table_info_sign = "CTL_SIGN_ATTACH_INFO"
            End If

        End If


    End Sub

    Public Sub start(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        On Error Resume Next

        Response.ExpiresAbsolute = DateTime.Now
        Response.Expires = -1441
        Response.CacheControl = "no-cache"
        Response.AddHeader("Pragma", "no-cache")
        Response.AddHeader("Pragma", "no-store")
        Response.AddHeader("cache-control", "no-cache")
        Response.Cache.SetCacheability(HttpCacheability.NoCache)
        Response.Cache.SetNoServerCaching()

        Dim operazione As String

        If Directory.Exists(outFile) = False Then
            Response.Write("0#Directory di lavoro '" & outFile & "' non presente")
            Response.End()
        End If

        If (Request.QueryString("mode") = Nothing) Then
            operazione = "PDF"
        Else
            operazione = Request.QueryString("mode")
        End If

        If (UCase(operazione) = "PDF") Then

            generaPdf()

        ElseIf (UCase(operazione) = "PDF_HASH") Then

            Dim strOut As String = parsePdf(Request.QueryString("PDF"), False)

            Response.Write(strOut)
            Response.End()

        ElseIf (UCase(operazione) = "VERIFICA_PDF") Then

            '-- test verifica avanzata PDF
            Dim a As New sign.Utils

            If Not Request.QueryString("ATT_Hash") Is Nothing And Request.QueryString("ATT_Hash") <> "" Then
                a.ATT_Hash = Request.QueryString("ATT_Hash")
            End If

            If Not Request.QueryString("attIdMsg") Is Nothing And Request.QueryString("attIdMsg") <> "" Then
                a.attIdMsg = Request.QueryString("attIdMsg")
            End If

            If Not Request.QueryString("attOrderFile") Is Nothing And Request.QueryString("attOrderFile") <> "" Then
                a.attOrderFile = Request.QueryString("attOrderFile")
            End If

            If Not Request.QueryString("attIdObj") Is Nothing And Request.QueryString("attIdObj") <> "" Then
                a.attIdObj = Request.QueryString("attIdObj")
            End If

            If Not Request.QueryString("idAzi") Is Nothing And Request.QueryString("idAzi") <> "" Then
                a.idAzi = Request.QueryString("idAzi")
            End If

            If (Request.QueryString("signedfile") = Nothing) Or (Request.QueryString("signedfile") = "") Then

                Response.Write("0#Parametro signedfile obbligatorio per la verifica avanzata di un allegato firmato")

            Else

                Dim out As String = ""

                If Not System.IO.File.Exists(Request.QueryString("signedfile")) Then

                    Response.Write("0#File " & Request.QueryString("signedfile") & " non trovato ")

                Else

                    a.verifyPdfSigned(Request.QueryString("signedfile"), out, Request)

                    Dim strOut As String

                    If (Err.Number <> 0) Then
                        strOut = "0#ERR: " & a.strCause & Err.Description
                    Else
                        strOut = out
                    End If

                    Dim db As New DbUtil

                    If db.init Then

                        db.trace("Esito da .net:" & strOut, "verificaFirmaPDF")

                        db.close()

                    End If

                    Response.Write(strOut)

                End If



            End If

        ElseIf (UCase(operazione) = "VERIFICA_P7M") Then

            If (Request.QueryString("signedfile") = Nothing) Or (Request.QueryString("signedfile") = "") Then

                Response.Write("0#Parametro signedfile obbligatorio per la verifica avanzata di un allegato firmato")

            Else

                If Not System.IO.File.Exists(Request.QueryString("signedfile")) Then

                    Response.Write("0#File " & Request.QueryString("signedfile") & " non trovato ")

                Else

                    '-- test verifica avanzata P7M
                    verifyP7M(Request.QueryString("signedfile"))

                    If Err.Number <> 0 Then
                        Response.Write("0#ERR:" & Err.Description)

                        On Error Resume Next

                        'db.close() 'Chiudo la connessione se è rimasta aperta

                        If totIterazioni > 0 Then

                            '-- Cancelliamo tutti i file estratti
                            For k As Integer = totIterazioni To 0 Step -1

                                System.IO.File.Delete(outFile & uniqueStr & "estratto" & k)
                                Err.Clear()
                            Next

                        End If

                    Else


                        'On Error Resume Next
                        'db.close() 'Chiudo la connessione se è rimasta aperta

                    End If

                End If



            End If

        ElseIf (UCase(operazione) = "ESCLUDI_BUSTA") Then

            '-- Download di un file firmato senza l'envelope
            downloadSenzaEnvelope()

            If Err.Number <> 0 Then
                Response.Write("0#ERR" & Err.Description)
            End If

        ElseIf (UCase(operazione) = "DOWNLOAD_CERTIFICATO") Then

            downloadCertificato()

            If Err.Number <> 0 Then
                Response.Write("0#ERR" & Err.Description)
            End If

        ElseIf (UCase(operazione) = "COMPILA_MODULO_PDF") Then

            compilaModuloPdf()

            If Err.Number <> 0 Then

                If CStr(Request.QueryString("pdf")) <> "" Then

                    Response.Write("0#" & Err.Description)

                End If

                Response.Clear()

                Dim db As New DbUtil

                If (db.init() = True) Then

                    db.trace("ERRORE IN COMPILA_PDF, " & Err.Description, "pdf.aspx.compila_modulo_pdf")
                    db.close()

                End If

            End If

            ElseIf (UCase(operazione) = "GET_HASH") Then

                If Request.QueryString("file") <> "" And System.IO.File.Exists(Request.QueryString("file")) Then

                    Dim output As String = ""

                    output = getSha1FileHash(Request.QueryString("file"))

                    If (Err.Number <> 0) Then
                        Response.Write("0#ERR: " & Err.Description)
                    Else
                        Response.Write("1#" & output)
                    End If

                Else

                    Response.Write("0#ERR: Parametro 'file' non passato o file non trovato")

                End If

            ElseIf (UCase(operazione) = "VERIFICA_REVOCA") Then

                If (Request.QueryString("ID") = Nothing) Or (Request.QueryString("ID") = "") Then

                    Response.Write("0#Parametro ID obbligatorio per la verifica di revoca di un allegato firmato")

                Else

                Response.Write(verifica_revoca(Request.QueryString("id")))

                End If


            ElseIf (UCase(operazione) = "MERGE_PDF") Then

                '--se il parametro directory_pdf non è passato
                If (Request.QueryString("directory_pdf") = Nothing) Or (Request.QueryString("directory_pdf") = "") Or ((Request.QueryString("pdf") = Nothing) Or (Request.QueryString("pdf") = "")) Then
                    Response.Write("0#Parametri directory_pdf e pdf obbligatori per il merge dei pdf")
                Else

                    If Request.QueryString("TEST_MODE") = "YES" Then
                        On Error GoTo 0
                    End If
                    Dim strErr As String

                    strErr = mergePdf(CStr(Request.QueryString("directory_pdf")), CStr(Request.QueryString("pdf")))

                    If Err.Number <> 0 Or strErr <> "" Then
                        'Response.StatusCode = 500 'status di errore
                        'Response.StatusDescription = strErr
                        Response.Write("0#" & strErr)
                    Else
                        Response.Write("1#OK")
                    End If

                End If

            Else

                firmaDigiale()

            End If

    End Sub

    Private Function verifyP7M(ByVal pathP7m As String, Optional via_com As Boolean = False, Optional ByVal com_ATT_Hash As String = Nothing,
                            Optional com_attIdMsg As String = Nothing,
                            Optional com_attOrderFile As String = Nothing,
                            Optional com_attIdObj As String = Nothing,
                            Optional com_idAzi As String = Nothing) As String


        verifyP7M = ""

        Dim db As New DbUtil
        Dim ATT_Hash As String = "" 'chiave di aggancio per i documenti nuovi
        Dim attIdMsg As String = "" 'chiave di aggancio per i documenti generici
        Dim attOrderFile As String = "" 'chiave di aggancio per i documenti generici
        Dim attIdObj As String = "" 'chiave di aggancio per i documenti generici
        Dim idAzi As String = ""
        Dim note As String = ""
        Dim checkValidAlgoritmoFirmas As Boolean = True

        Dim BLOCK_VERIFY_REVOKE As Boolean = False

        Dim nomeFileCustom As String = ""

        Dim totNumSigner As Integer = 0


        If Not com_ATT_Hash Is Nothing Then
            ATT_Hash = com_ATT_Hash
        Else
            If Not Request.QueryString("ATT_Hash") Is Nothing And Request.QueryString("ATT_Hash") <> "" Then
                ATT_Hash = Request.QueryString("ATT_Hash")
            End If

            If Not Request.QueryString("NOME_FILE") Is Nothing And Request.QueryString("NOME_FILE") <> "" Then
                nomeFileCustom = Request.QueryString("NOME_FILE")
            End If

        End If

        If Not com_attIdMsg Is Nothing Then
            attIdMsg = com_attIdMsg
        Else
            If Not Request.QueryString("attIdMsg") Is Nothing And Request.QueryString("attIdMsg") <> "" Then
                attIdMsg = Request.QueryString("attIdMsg")
            End If
        End If

        If Not com_attOrderFile Is Nothing Then
            attOrderFile = com_attOrderFile
        Else
            If Not Request.QueryString("attOrderFile") Is Nothing And Request.QueryString("attOrderFile") <> "" Then
                attOrderFile = Request.QueryString("attOrderFile")
            End If
        End If

        If Not com_attIdObj Is Nothing Then
            attIdObj = com_attIdObj
        Else
            If Not Request.QueryString("attIdObj") Is Nothing And Request.QueryString("attIdObj") <> "" Then
                attIdObj = Request.QueryString("attIdObj")
            End If
        End If

        If Not com_idAzi Is Nothing Then
            idAzi = com_idAzi
        Else
            If Not Request.QueryString("idAzi") Is Nothing And Request.QueryString("idAzi") <> "" Then
                idAzi = Request.QueryString("idAzi")
            End If
        End If


        If (db.init() = True) Then

            'db.trace("Verifica firma digitale,File: " & pathP7m & " queryString: " & Replace(Request.QueryString.ToString, "'", "''"), "verifyP7M()")

            Dim strSql As String = ""
            Dim strCause As String = ""



            strSql = "select id from LIB_Dictionary where dzt_name='SYS_BLOCK_VERIFY_REVOKE' and DZT_ValueDef = 'YES'"
            Dim sqlComm1 As New SqlCommand(strSql, db.sqlConn)
            Dim rs As SqlDataReader = sqlComm1.ExecuteReader()
            If (rs.Read()) Then
                BLOCK_VERIFY_REVOKE = True
            End If

            rs.Close()
            strSql = ""

            Try

                strCause = "Cancello i record vecchi "

                '-- Se chi ci invoca è da parte del documento nuovo
                If ATT_Hash <> "" Then
                    strSql = "delete from ctl_sign_attach_info where ATT_Hash = '" & Replace(ATT_Hash, "'", "''") & "' and statoFirma <> 'SIGN_PENDING'"
                Else
                    strSql = "delete from ctl_sign_attach_info where attIdMsg = " & CLng(attIdMsg) & " and attOrderFile = " & CLng(attOrderFile) & " and attIdObj = " & CLng(attIdObj)
                End If

                Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                sqlComm.ExecuteNonQuery()

            Catch ex As Exception

                If via_com = False Then
                    Response.Write("0#Errore nella cancellazione dei vecchi record associati all'allegato, " & ex.Message)
                Else
                    verifyP7M = "0#Errore nella cancellazione dei vecchi record associati all'allegato, " & ex.Message
                End If

                db.close()

                Exit Function

            End Try


        Else

            Throw New Exception("ERRORE INIT SUL DATABASE(" & db.dbError & "), verificare stringa di connessione formato .net")

        End If


        Dim copyPathP7m As String = ""
        copyPathP7m = pathP7m.Clone

        Dim crypt As New Chilkat.Crypt2()
        Dim success As Boolean
        Dim verificaP7mChilkat As Boolean = False

        Dim strFileDaEstrarre As String = ""


        strFileEstratto = ""
        uniqueStr = "_" & Date.Now.Hour & Date.Now.Minute & Date.Now.Second & Date.Now.Millisecond & "_"


        'success = crypt.UnlockComponent("AFSOLUCrypt_kBFfOFAyUJJG")
        'success = crypt.UnlockComponent("AFSOLUCrypt_5JnVzsEOUJJd")
        success = crypt.UnlockComponent(codiceAttivazioneChilkat)


        If success <> True Then

            If via_com = False Then
                Response.Write("0#" & crypt.LastErrorText)
            Else
                verifyP7M = "0#" & crypt.LastErrorText
            End If

            crypt.Dispose()
            crypt = Nothing

            Exit Function

        End If

        'Dim totIterazioni As Integer = 0

        totIterazioni = 0

        '------------------------------------------------------------------------------------------------------------------
        '-- PER QUEI FILE P7M CON FIRMA MULTIPLA E CON BUSTA MULTIPLA ( quindi N .p7m.p7m ) chilkat
        '-- non estree tutte le firme ma estrae un p7m che ha a sua volta un p7m al suo interno.
        '-- dobbiamo iterare N volte il processo di estrazione
        '------------------------------------------------------------------------------------------------------------------

        verificaP7mChilkat = True

        '-- ITERO SULLE FIRME MULTIPLE "VERTICALI". CIOE' CON N BUSTE/ENVELOPE
        While verificaP7mChilkat = True

            totIterazioni = totIterazioni + 1

            'Verifica e ripristino del file originale
            Try
                strFileDaEstrarre = outFile & uniqueStr & "estratto" & totIterazioni
                success = crypt.VerifyP7M(copyPathP7m, strFileDaEstrarre)
            Catch ex As Exception
                verificaP7mChilkat = False
            End Try

            verificaP7mChilkat = success
            note = crypt.LastErrorText

            If verificaP7mChilkat = True Then

                strFileEstratto = strFileDaEstrarre

                Dim numSigner As Integer = 0
                numSigner = crypt.NumSignerCerts

                If numSigner <= 0 Then

                    numSigner = 1

                End If

                totNumSigner = totNumSigner + numSigner

                Dim certificato As Chilkat.Cert
                'Dim certChain As Chilkat.CertChain   '-- usabile Dalla versione 9.5.0.49
                Dim certificati(numSigner - 1) As Chilkat.Cert

                Dim i As Integer

                '-- ITERO N VOLTE LA VERIFICA PER OGNI FIRMATARIO (GESTIONE FIRMA MULTIPLA)
                '-- ITERO SULLE FIRME MULTIPLE "ORIZZONTALI"/"PARALLELE". CIOE' SUGLI N FIRMATARI PRESENTI A PARITA' DI BUSTA/ENVELOPE
                For i = 0 To numSigner - 1

                    certificato = crypt.GetSignerCert(i)
                    'certChain = crypt.GetSignerCertChain(0)

                    Dim isExpired As Boolean = certificato.Expired
                    Dim scadenzaFirma As Date = certificato.ValidTo
                    Dim calNow As Date = Now().ToUniversalTime
                    Dim numeroSeriale As String = ""
                    Dim statoFirma As String = ""

                    numeroSeriale = certificato.SerialNumber


                    'Dim dtApposizioneFirma As DateTime
                    Dim algoritmoHashFirma As String = ""
                    Dim envelope As SignedCms

                    ' dtApposizioneFirma = Nothing
                    Dim cal As Date = crypt.GetSignatureSigningTime(i)
                    Dim assenzaDataFirma As Boolean = True

                    If UCase(CStr(enableSignedCMS)) = "YES" Then

                        Try

                            envelope = New SignedCms

                            '-- questo metodo era molto lento, sopratutto con i file .zip.p7m  quindi tramite il parametro web.config disableSignedCMS ne abbiamo rimosso l'uso
                            '--     usando solo la libreria chilkat
                            envelope.Decode(ReadFile(copyPathP7m))

                            Dim info As SignerInfo
                            Dim val As System.Security.Cryptography.Pkcs.Pkcs9SigningTime
                            Dim totFirme As Integer
                            Dim kCiclo As Integer

                            totFirme = envelope.SignerInfos.Count

                            For kCiclo = 0 To totFirme - 1

                                '---------------------------------------------------------------------------------------------------
                                '--- NON FUNZIONANDO BENE CHILKAT, NELLO SPECIFICO NON RECUPERA BENE LA DATA APPOSIZIONE FIRMA -----
                                '--- PASSO A RECUPERARLA CON LE LIBRERIE DI BASSO LIVELLO DI SISTEMA.                          -----
                                '---------------------------------------------------------------------------------------------------

                                cal = Nothing
                                info = envelope.SignerInfos.Item(kCiclo)

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
                                            val = a.Values.Item(0)
                                            cal = val.SigningTime
                                        End If

                                    Next

                                End If


                            Next

                            envelope = Nothing

                            note = ""

                        Catch ex As Exception

                            note = "Errore nel recupero dell'algoritmo di firma." & ex.Message
                            envelope = Nothing
                            cal = Nothing

                            Try

                                If algoritmoHashFirma = "" Then
                                    '-- proviamo il 2o metodo di recupero dell'algoritmo di firma
                                    algoritmoHashFirma = getDigestAlgorithm(crypt, copyPathP7m, i)
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
                            algoritmoHashFirma = getDigestAlgorithm(crypt, copyPathP7m, i)
                        Catch ex As Exception
                            algoritmoHashFirma = ""
                        End Try


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
                    If (cal > scadenzaFirma) Then

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
                    Dim nomeFile As String = Split(pathP7m, "\")(Split(pathP7m, "\").Length - 1)
                    Dim firmaValidaDal As Date = certificato.ValidFrom
                    Dim firmaValidaAl As Date = certificato.ValidTo
                    Dim infoCertificateChain As String = ""
                    Dim usoCertificato As String = ""

                    '-- Salvo il certificato su disco e mi ricavo un array di byte
                    certificato.SaveToFile(outFile & uniqueStr & "cert.cer")
                    Dim objCertificato() As Byte = ReadFile(outFile & uniqueStr & "cert.cer")

                    Try
                        System.IO.File.Delete(outFile & uniqueStr & "cert.cer")
                    Catch
                    End Try

                    Dim x509 As New X509Certificate2
                    x509.Import(objCertificato)

                    Try

                        Dim codiceFiscaleFirmatario As String = ""

                        If Len(firmatarioInfo) <> 16 Then

                            codiceFiscaleFirmatario = x509.Subject

                            If codiceFiscaleFirmatario.Contains("SERIALNUMBER=") Then
                                Dim ind As Integer = codiceFiscaleFirmatario.IndexOf("SERIALNUMBER=")
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

                    Try
                        '-- provo a recuperare i flag d'uso del certificato dal x509 per poi passare a recuperarli da chilkat ( che non gestisce bene un uso di certificato con N flag insieme )
                        Call (New sign.Utils()).getInfoUtilizzoCertificato(x509, isCertificatoSottoscrizione, usoCertificato)
                    Catch ex As Exception
                    End Try

                    Dim motivoRevoca As String = ""

                    checkValidAlgoritmoFirmas = db.checkAlgoritmoFirma(algoritmoHashFirma, cal.ToString("yyyy-MM-dd"))

                    If BLOCK_VERIFY_REVOKE = False Then


                        Try
                            '-- effettuo una priva verifica di revoca tramite chilat poi se non ci riesce passo alle api di windows
                            revoked = certificato.CheckRevoked
                        Catch ex As Exception
                            revoked = -1
                        End Try

                        If (revoked - 1) Then

                            Try
                                '  0: Good
                                '  1: Revoked
                                '  2: Unknown.
                                revoked = New sign.Utils().verificaRevocaChilkat(certificato)   '- verifica chilkat tramite OCSP

                                If revoked = 2 Then
                                    revoked = -1
                                End If

                            Catch ex As Exception
                                revoked = -1
                            End Try

                        End If

                        '-- se non è stato possibile verificare la revoca con chilkat scendiamo di livello (api di windows)
                        If (revoked = -1) Then

                            Dim esitoVerifica As New Microsoft.VisualBasic.Collection
                            esitoVerifica = New sign.Utils().verificaRevocaWindows(x509, cal)

                            motivoRevoca = esitoVerifica("motivo")
                            revoked = esitoVerifica("revocato")

                            If motivoRevoca <> "" Then
                                note = note & motivoRevoca
                            End If

                        End If
                    End If

                    Try
                        isTrusted = checkIsTrusted(cnCertificatore, cal, tslFromTable, tsl_online, pathTsl, urlTsl, statoEmittente)
                    Catch ex As Exception
                        isTrusted = True
                    End Try


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
                            isCertificatoSottoscrizione = IIf(certificato.IntendedKeyUsage = 64, 1, 0)
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
                    If (db.init() = True) Then

                        Dim strSql As String = ""
                        Dim strCause As String = ""

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
                                        "@ATT_Hash," &
                                        "" & IIf(isTrusted, 1, 0) & "," &
                                        "" & revoked & "," &
                                        "" & IIf(isExpired, 1, 0) & "," &
                                        "" & IIf(isCertificatoSottoscrizione, 1, 0) & "," &
                                        "" & IIf(verificaP7mChilkat, 1, 0) & "," &
                                        "" & IIf(checkValidAlgoritmoFirmas, 1, 0) & "," &
                                        "'P7M'," &
                                        "@certificatore," &
                                        "@codFiscFirmatario," &
                                        "@firmatario,"


                            If (assenzaDataFirma = True) Then
                                strSql = strSql & "NULL,"
                            Else
                                strSql = strSql & "'" & Replace(cal.ToString("yyyy-MM-dd HH:mm:ss"), ".", ":") & "',"
                            End If

                            If CStr(scadenzaFirma) = "" Then
                                strSql = strSql & "NULL,"
                            Else
                                strSql = strSql & "'" & Replace(scadenzaFirma.ToString("yyyy-MM-dd HH:mm:ss"), ".", ":") & "',"
                            End If

                            strSql = strSql &
                                        "@nomeFile," &
                                        "" & numSigner & "," &
                                        "@usoCertificato," &
                                        "@statoFirma" &
                                        "," & IIf(attIdMsg = "", "NULL", CStr(attIdMsg)) &
                                        "," & IIf(attOrderFile = "", "NULL", CStr(attOrderFile)) &
                                        "," & IIf(attIdObj = "", "NULL", CStr(attIdObj)) &
                                        ",@objCertificato" &
                                        "," & IIf(idAzi = "", "NULL", CStr(idAzi)) &
                                        ",@algoritmo" &
                                        "," & IIf(revoked = -1, -1, 0) &
                                        ",@note" &
                                        ",@CountryName" &
                                        ",@subjectSerialNumber" &
                                        ",@certificateSerialNumber" &
                                     ")"


                            'db.trace("Sto per eseguire " & strSql, "verifyP7M")

                            strCause = "Eseguo la insert sulla CTL_SIGN_ATTACH_INFO"


                            Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                            Dim myParameter As SqlParameter = New SqlParameter("@objCertificato", SqlDbType.Image, objCertificato.Length)

                            myParameter.Value = objCertificato

                            sqlComm.Parameters.Add(myParameter)

                            sqlComm.Parameters.AddWithValue("ATT_Hash", ATT_Hash)
                            sqlComm.Parameters.AddWithValue("certificatore", Replace(cnCertificatore, "CN=", ""))
                            sqlComm.Parameters.AddWithValue("codFiscFirmatario", firmatarioInfo)
                            sqlComm.Parameters.AddWithValue("firmatario", firmatario)
                            sqlComm.Parameters.AddWithValue("nomeFile", IIf(nomeFileCustom <> "", nomeFileCustom, nomeFile))
                            sqlComm.Parameters.AddWithValue("usoCertificato", usoCertificato)
                            sqlComm.Parameters.AddWithValue("statoFirma", statoFirma)
                            sqlComm.Parameters.AddWithValue("algoritmo", algoritmoHashFirma)
                            sqlComm.Parameters.AddWithValue("note", note)
                            sqlComm.Parameters.AddWithValue("CountryName", statoEmittente)
                            sqlComm.Parameters.AddWithValue("subjectSerialNumber", firmatarioInfo)
                            sqlComm.Parameters.AddWithValue("certificateSerialNumber", numeroSeriale)

                            sqlComm.ExecuteNonQuery()

                            objCertificato = Nothing

                            Try
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

                                sqlComm = New SqlCommand(strSql, db.sqlConn)
                                sqlComm.ExecuteNonQuery()

                            Catch ex2 As Exception

                            End Try

                            x509 = Nothing

                        Catch ex As Exception

                            db.close()

                            If via_com = False Then
                                Response.Write("0#" & strCause & "," & ex.Message)
                            Else
                                verifyP7M = "0#" & strCause & "," & ex.Message
                            End If

                            Exit Function

                        End Try

                    End If

                Next

                db.close()

            ElseIf (totIterazioni = 1) Then '-- Se siamo nel primo livello di iterazione

                '-- Scrivo nella tabella per la raccolta delle informazioni sulla firma
                If (db.init() = True) Then

                    Dim strSql As String = ""
                    Dim strCause As String = ""

                    Try

                        strCause = "Compongo la insert per la CTL_SIGN_ATTACH_INFO "

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
                            strSql = strSql & ",'" & Replace(Split(pathP7m, "\")(Split(pathP7m, "\").Length - 1), "'", "''") & "'"
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


                        strCause = "Eseguo la insert sulla CTL_SIGN_ATTACH_INFO"

                        Dim sqlComm = New SqlCommand(strSql, db.sqlConn)
                        sqlComm.ExecuteNonQuery()


                    Catch ex As Exception

                        db.close()

                        If via_com = False Then
                            Response.Write("0#" & strCause & "," & ex.Message)
                        Else
                            verifyP7M = "0#" & strCause & "," & ex.Message
                        End If

                        Exit Function

                    End Try

                End If

                db.close()

                Exit While '-- l'ultima verifica effettuata non aveva la firma digitale applicava o era corrotta

            End If

            copyPathP7m = outFile & uniqueStr & "estratto" & totIterazioni

        End While

        '-- Gestione firma multipla, p7m esterno e pdf firmato all'interno
        '-- se non è andata in errore la verifyP7M e se il file p7m aveva almeno una busta, controllo se il file estratto è un pdf a sua volta firmato
        If strFileEstratto <> "" Then

            Dim out As String = ""
            Dim a As New sign.Utils


            If Not com_ATT_Hash Is Nothing Then
                ATT_Hash = com_ATT_Hash
            Else
                If Not Request.QueryString("ATT_Hash") Is Nothing And Request.QueryString("ATT_Hash") <> "" Then
                    ATT_Hash = Request.QueryString("ATT_Hash")
                End If
            End If

            If Not com_attIdMsg Is Nothing Then
                attIdMsg = com_attIdMsg
            Else
                If Not Request.QueryString("attIdMsg") Is Nothing And Request.QueryString("attIdMsg") <> "" Then
                    attIdMsg = Request.QueryString("attIdMsg")
                End If
            End If

            If Not com_attOrderFile Is Nothing Then
                attOrderFile = com_attOrderFile
            Else
                If Not Request.QueryString("attOrderFile") Is Nothing And Request.QueryString("attOrderFile") <> "" Then
                    attOrderFile = Request.QueryString("attOrderFile")
                End If
            End If

            If Not com_attIdObj Is Nothing Then
                attIdObj = com_attIdObj
            Else
                If Not Request.QueryString("attIdObj") Is Nothing And Request.QueryString("attIdObj") <> "" Then
                    attIdObj = Request.QueryString("attIdObj")
                End If
            End If

            If Not com_idAzi Is Nothing Then
                idAzi = com_idAzi
            Else
                If Not Request.QueryString("idAzi") Is Nothing And Request.QueryString("idAzi") <> "" Then
                    idAzi = Request.QueryString("idAzi")
                End If
            End If

            Dim firmeMultipleIncrociate As Boolean = True

            If via_com = True Then
                'a.verifyPdfSigned(pathP7m, out, Nothing, firmeMultipleIncrociate)
                a.originalFileName = pathP7m
                a.ATT_Hash = ATT_Hash
                a.verifyPdfSigned(strFileEstratto, out, Nothing, firmeMultipleIncrociate)
            Else
                'a.verifyPdfSigned(Request.QueryString("signedfile"), out, Request, firmeMultipleIncrociate)
                a.originalFileName = Request.QueryString("signedfile")
                a.ATT_Hash = ATT_Hash
                a.verifyPdfSigned(strFileEstratto, out, Request, firmeMultipleIncrociate)
            End If



            Try

                If db.init Then

                    Dim strsql = ""

                    '-- Se chi ci invoca è da parte del documento nuovo
                    If ATT_Hash <> "" Then
                        strsql = "update ctl_sign_attach_info set numSigners = numSigners + " & CStr(a.totFirme) & " where ATT_Hash = '" & Replace(ATT_Hash, "'", "''") & "'"
                    Else
                        strsql = "update ctl_sign_attach_info set numSigners = numSigners + " & CStr(a.totFirme) & " where attIdMsg = " & CLng(attIdMsg) & " and attOrderFile = " & CLng(attOrderFile) & " and attIdObj = " & CLng(attIdObj)
                    End If

                    Dim sqlComm As New SqlCommand(strsql, db.sqlConn)
                    sqlComm.ExecuteNonQuery()

                    db.close()

                End If

            Catch ex As Exception

            End Try
            

        End If

        If totIterazioni > 0 Then

            '-- Cancelliamo tutti i file estratti
            For k As Integer = totIterazioni To 0 Step -1

                Try
                    System.IO.File.Delete(outFile & uniqueStr & "estratto" & k)
                Catch
                End Try

            Next

        End If

        Try
            crypt.Dispose()
            crypt = Nothing
        Catch ex As Exception

        End Try
        

        If via_com = False Then
            Response.Write("1#OK")
        Else
            verifyP7M = "1#OK"
        End If

        Exit Function

    End Function

    Private Sub generaPdf()

        On Error Resume Next

        Dim url As String
        Dim pdf As String
        Dim pageSize As String
        Dim pageOrientation As String
        Dim fitWith As String
        Dim isPdfA As Boolean = False

        Dim footerKey As String = ""
        Dim lngPrefix As String = ""
        Dim mediaType As String = ""

        Dim idDoc As String = ""
        Dim vistaFooterHeader As String = ""

        '-- Controllo sui parametri obbligatori
        If (Request.QueryString("url") = Nothing Or Request.QueryString("pdf") = Nothing) Then
            Response.Write("0#Parametro url o pdf mancanti")
            Return
        End If

        'url = UrlDecode(Request.QueryString("url")) 'url che ci restituirà la pagina html
        'url = Server.UrlDecode(Request.QueryString("url"))
        url = CStr(Request.QueryString("url"))

        pdf = Request.QueryString("pdf") 'percorso completo di nome del file pdf da generare

        '-- Parametri opzionali 
        pageSize = Request.QueryString("pagesize")
        pageOrientation = Request.QueryString("pageorientation")
        fitWith = Request.QueryString("fitwith")

        footerKey = CStr(Request.QueryString("ml_footer"))
        lngPrefix = CStr(Request.QueryString("lng_prefix"))
        mediaType = CStr(Request.QueryString("media_type"))
        idDoc = CStr(Request.QueryString("IDDOC"))
        vistaFooterHeader = CStr(Request.QueryString("view_footer_header"))

        If (UCase(CStr(Request.QueryString("PDF_A"))) = "YES" Or CStr(Request.QueryString("PDF_A")) = "1") Then
            isPdfA = True
        End If

        If lngPrefix = "" Then
            lngPrefix = "I"
        End If

        If mediaType = "" Then
            mediaType = "screen"
        End If

        ConvertURLToPDF(url, pdf, pageSize, pageOrientation, fitWith, isPdfA, footerKey, lngPrefix, mediaType, vistaFooterHeader, idDoc) 'scrive il pdf creato a partire dalla pagina html sul percorso specificato

        If Err.Number > 0 Then
            Response.Write("0#errore ( " & Err.Number & " ) : " & Err.Description)
        Else
            Response.Write("1#File pdf generato con successo")
        End If

        Response.End()

    End Sub

    Private Function firmaDigiale(Optional via_com As Boolean = False, Optional com_filePdf As String = Nothing, Optional com_isSigned As String = Nothing) As String

        On Error Resume Next

        Dim pdf As String
        Dim isSigned As String

        firmaDigiale = ""

        If via_com = True Then

            If com_filePdf = "" Then
                firmaDigiale = "0#" & Err.Description
                Exit Function
            End If

            pdf = com_filePdf
            isSigned = com_isSigned

        Else

            If (Request.QueryString("pdf") = Nothing Or Request.QueryString("issigned") = Nothing) Then
                Response.Write("0#Parametro pdf o IsSigned mancanti")
                Exit Function
            End If

            'pdf = Server.UrlDecode(Request.QueryString("pdf")) -- NON BISOGNA FARE LA URL DECODE. E' IMPLICITO NEL RECUPERO DEI PARAMETRI DA GET
            pdf = CStr(Request.QueryString("pdf"))
            isSigned = Request.QueryString("issigned")

        End If

        Err.Clear()

        If (File.Exists(pdf)) Then

            If Err.Number <> 0 Then

                If via_com = False Then
                    Response.Write("0#" & Err.Description)
                Else
                    firmaDigiale = "0#" & Err.Description
                End If

                Exit Function

            End If

        Else

            If via_com = False Then
                Response.Write("0#File '" & pdf & "' non trovato")
            Else
                firmaDigiale = "0#File '" & pdf & "' non trovato"
            End If


            Exit Function

        End If

        Dim output As String = parsePdf(pdf, isSigned)

        Dim db As New DbUtil

        If db.init Then

            db.trace("Output da pdf.aspx:" & output, "firmaDigitale()")

            db.close()

        End If


        If via_com = False Then
            Response.Write(CStr(output))
            Response.Flush()
        Else
            firmaDigiale = CStr(output)
        End If

        Exit Function


    End Function

    Public Function UrlDecode(str As String) As String
        Dim app As String
        Dim c As String

        Dim i As Integer
        'Dim s As Integer
        Dim ch As String

        app = str
        While InStr(i + 1, app, "%")

            i = InStr(i + 1, app, "%")
            c = Mid(app, i + 1, 2)
            ch = Hex2Char(c)

            app = Replace(app, "%" & c, ch)
        End While
        UrlDecode = app



    End Function

    Public Function Hex2Char(str As String) As String

        Dim c1 As String
        Dim c2 As String
        Dim v1 As Integer
        Dim v2 As Integer
        c1 = Mid(str, 1, 1)
        c2 = Mid(str, 2, 1)
        If c1 >= "0" And c1 <= "9" Then
            v1 = Asc(c1) - 48
        Else
            v1 = Asc(UCase(c1)) - 55
        End If
        If c2 >= "0" And c2 <= "9" Then
            v2 = Asc(c2) - 48
        Else
            v2 = Asc(UCase(c2)) - 55
        End If
        v1 = v1 * 16 + v2

        Hex2Char = Chr(v1)

    End Function

    Public Function UrlEncode(str As String) As String
        Dim app As String = ""
        Dim c As String

        Dim i As Integer
        Dim l As Integer

        l = Len(str)

        For i = 1 To l

            c = Mid(str, i, 1)

            If (c >= "a" And c <= "z") Or (c >= "A" And c <= "Z") Or (c >= "0" And c <= "9") Then
                c = c
            Else
                c = "%" & Right("00" & Hex(Asc(c)), 2)
            End If

            app = app + c

        Next i

        UrlEncode = app

    End Function

    Private Sub downloadSenzaEnvelope()

        Dim hash As String = ""
        Dim idObj As String = ""
        Dim strSql As String = ""
        Dim db As New DbUtil
        Dim nomeFile As String = ""
        Dim contentFile As String = "application/pdf"
        Dim nomeFileEstratto As String = ""
        Dim estensione As String = ""

        If Not Request.QueryString("ATT_HASH") Is Nothing And CStr(Request.QueryString("ATT_HASH")) <> "" Then
            hash = Request.QueryString("ATT_HASH")
        End If

        If Not Request.QueryString("ATTIDOBJ") Is Nothing And CStr(Request.QueryString("ATTIDOBJ")) <> "" Then
            idObj = Request.QueryString("ATTIDOBJ")
        End If


        '-- Documento nuovo
        If hash <> "" Then

            strSql = "select att_obj as blob, att_name as nomeFile, isnull(ATT_CIFRATO,0) as ATT_CIFRATO FROM CTL_Attach with(nolock) where att_hash = '" & Replace(hash, "'", "''") & "'"

        Else

            '-- documento generico
            strSql = "select ObjFile  as blob, ObjName as nomeFile from TAB_OBJ where idObj = " & CLng(idObj)

        End If



        If (db.init()) Then

            'db.trace("DOWNLOAD SENZA ENVELOPE - Chiamato metodo, select recupero allegato : " & CStr(strSql), "downloadSenzaEnvelope()")

            Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
            Dim r As SqlDataReader = sqlComm.ExecuteReader() 'CommandBehavior.SequentialAccess)
            Dim attach() As Byte = Nothing
            Dim uniqueStr As String = Date.Now.Hour & Date.Now.Minute & Date.Now.Second & Date.Now.Millisecond & "_"


            Dim values() As Byte
            Dim cifrato As Integer

            '-- se ritorna dei record
            If (r.Read() = True) Then

                nomeFile = CStr(r("nomeFile"))

                cifrato = r("ATT_CIFRATO")

                If cifrato = 1 Then
                    Response.Redirect("./CTL_LIBRARY/MessageBoxWin.asp?ML=yes&MSG=Download del file non consentito&CAPTION=Informazione&ICO=1")
                    Response.End()
                End If

                If cifrato = 2 Then
                    Response.Redirect("./CTL_LIBRARY/MessageBoxWin.asp?ML=yes&MSG=Operazione di decifratura in corso. L'accesso al file e' momentaneamente bloccato, riprovare a breve&CAPTION=Informazione&ICO=1")
                    Response.End()
                End If

                '-- Estratto un array di byte dal database per la colonna "blob"
                Dim ndx As Integer = r.GetOrdinal("blob")

                ' Retrieve the length of the necessary byte array.
                Dim len As Long = r.GetBytes(ndx, 0, Nothing, 0, 0)

                ' Create a buffer to hold the bytes, and then 
                ' read the bytes from the DataTableReader.
                ReDim values(CInt(len))
                r.GetBytes(ndx, 0, values, 0, CInt(len))

                'Dim size As Long = r.GetBytes(ndx, 0, Nothing, 0, 0)
                'Dim values As Byte() = New Byte(size - 1) {}    '-- allegato recuperato dal db

                'Dim bufferSize As Long = 3000000
                'Dim bytesRead As Long = 0
                'Dim lastBytesRead As Long = bufferSize
                'Dim curPos As Integer = 0

                'db.trace("DOWNLOAD SENZA ENVELOPE - Ciclo lettura file size : " & CStr(size), "downloadSenzaEnvelope()")

                'While (bytesRead < size And lastBytesRead >= 0)

                'If (size - bytesRead < bufferSize) Then
                '    bufferSize = size - bytesRead
                'End If

                'lastBytesRead = r.GetBytes(ndx, curPos, values, curPos, bufferSize)
                'bytesRead += lastBytesRead

                'curPos += bufferSize

                'End While

                r.Close()

                '-- LOG
                'db.trace("DOWNLOAD SENZA ENVELOPE - File trovato, nome : " & nomeFile, "downloadSenzaEnvelope()")

                '-- Se è un pdf l'allegato glielo inviamo al client così com'è.
                '-- se è un p7m ne tolgo prima la busta
                If UCase(nomeFile).EndsWith(".PDF") Then

                    attach = values

                ElseIf UCase(nomeFile).EndsWith(".P7M") Then

                    Dim crypt As New Chilkat.Crypt2()
                    Dim success As Boolean
                    Dim verificaP7mChilkat As Boolean = False


                    'success = crypt.UnlockComponent("AFSOLUCrypt_kBFfOFAyUJJG")
                    'success = crypt.UnlockComponent("AFSOLUCrypt_5JnVzsEOUJJd")
                    success = crypt.UnlockComponent(codiceAttivazioneChilkat)

                    If success <> True Then

                        Response.Write("0#" & crypt.LastErrorText)
                        Return

                    End If

                    Dim pathP7m As String = outFile & uniqueStr & "temp.p7m"

                    '-- scrivo l'allegato in un file temporaneo
                    System.IO.File.WriteAllBytes(pathP7m, values)


                    '-- Recupero il nome originale del file senza la busta andandomelo a ricavare
                    '-- dall'attuale nome file, (nella forma :  documento.pdf.p7m  oppure  file.doc.p7m )

                    Try

                        estensione = Path.GetExtension(Replace(LCase(nomeFile), ".p7m", ""))

                        '-- se non c'è l'estensione ( è stato rinominato il file dopo l'apposizione del .p7m )
                        If (Not estensione Is Nothing) And (estensione <> "") Then

                            'db.trace("DOWNLOAD SENZA ENVELOPE - Estensione file senza evelope : " & CStr(estensione), "downloadSenzaEnvelope()")

                            nomeFileEstratto = Replace(LCase(nomeFile), ".p7m", "")

                            Select Case Mid(LCase(estensione), 2)

                                Case LCase("bmp")
                                    contentFile = "image/x-xbitmap"

                                Case LCase("jpg")
                                    contentFile = "image/jpeg"

                                Case LCase("tif")
                                    contentFile = "image/tiff"

                                Case LCase("tiff")
                                    contentFile = "image/tiff"

                                Case LCase("pdf")
                                    contentFile = "application/pdf"

                                Case LCase("doc")
                                    contentFile = "Application/msword"

                                Case LCase("docx")
                                    contentFile = "Application/msword"

                                Case LCase("docm")
                                    contentFile = "Application/msword"

                                Case LCase("xls")
                                    contentFile = "Application/vnd.ms-excel"

                                Case LCase("xlt")
                                    contentFile = "Application/vnd.ms-excel"

                                Case LCase("ppt")
                                    contentFile = "Application/vnd.ms-powerpoint"

                                Case LCase("pps")
                                    contentFile = "Application/vnd.ms-powerpoint"

                                Case LCase("zip")
                                    contentFile = "Application/zip"

                                Case Else
                                    contentFile = "Application/x-AFLink"

                            End Select

                        Else

                            nomeFileEstratto = "file_temp.pdf"

                        End If

                    Catch
                        nomeFileEstratto = "temp1.pdf"
                    End Try

                    db.close()

                    Dim totCicli As Integer = 0
                    success = True

                    Dim originalPathP7m As String
                    originalPathP7m = pathP7m.Clone

                    While success = True And totCicli <= 10

                        'db.trace("DOWNLOAD SENZA ENVELOPE - Ciclo di estrazione : " & CStr(totCicli), "downloadSenzaEnvelope()")

                        totCicli = totCicli + 1

                        'Verifica e ripristino del file originale
                        Try
                            success = crypt.VerifyP7M(pathP7m, outFile & uniqueStr & totCicli & "estratto")
                        Catch ex As Exception
                            success = False
                        End Try

                        '-- Se il file è corrotto gia al 1o ciclo o il .p7m non è firmato o non è firmato correttamente, usciamo dal programma
                        If totCicli = 1 And success = False Then

                            Response.End()
                            Return

                        End If

                        pathP7m = outFile & uniqueStr & totCicli & "estratto"

                    End While


                    verificaP7mChilkat = True

                    'db.trace("DOWNLOAD SENZA ENVELOPE - Da far scaricare : " & CStr(outFile & uniqueStr & (totCicli - 1) & "estratto"), "downloadSenzaEnvelope()")

                    If System.IO.File.Exists(outFile & uniqueStr & (totCicli - 1) & "estratto") Then

                        attach = ReadFile(outFile & uniqueStr & (totCicli - 1) & "estratto")

                    Else

                        Response.Write("0#Errore nell'estrazione del contenuto della busta firmata")
                        Response.End()
                        Return

                    End If



                    Try
                        System.IO.File.Delete(originalPathP7m)
                    Catch
                    End Try

                    '-- Cancelliamo tutti i file estratti
                    For k As Integer = totCicli To 0 Step -1

                        'db.trace("DOWNLOAD SENZA ENVELOPE - Ciclo di cancellazione : " & CStr(k), "downloadSenzaEnvelope()")


                        Try
                            System.IO.File.Delete(outFile & uniqueStr & k & "estratto")
                        Catch
                        End Try

                        If k < 0 Then
                            Exit For
                        End If

                    Next

                End If

                If UCase(nomeFile).EndsWith(".P7M") Then
                    nomeFile = nomeFileEstratto
                    'Else
                    '    nomeFile = "file_envelope.pdf"
                End If


                Response.Clear()
                Response.ClearHeaders()
                Response.ClearContent()

                If Not Request.IsSecureConnection Then

                    Response.AddHeader("Cache-control", "no-store")
                    Response.AddHeader("Pragma", "no-cache")
                    Response.AddHeader("Expires", "0")
                    Response.AddHeader("Content-Length", attach.Length.ToString())

                End If

                Response.Charset = Nothing
                Response.ContentType = contentFile
                Response.AddHeader("Content-Disposition", "attachment;filename=""" & LCase(Trim(nomeFile)) & """")
                'Response.AddHeader("Content-Disposition", "inline; filename=" & LCase(Trim(nomeFile)))

                Response.BinaryWrite(attach)


                Response.Flush()
                'Response.Close()

                values = Nothing
                attach = Nothing

            Else

                Response.Write("0#Allegato firmato non trovato")

            End If

        End If

    End Sub

    Private Sub downloadCertificato()

        Dim idDoc As String = ""
        Dim strSql As String = ""
        Dim db As New DbUtil
        Dim contentFile As String = "Application/pkix-cert"

        If Not Request.QueryString("IDDOC") Is Nothing And CStr(Request.QueryString("IDDOC")) <> "" Then
            idDoc = Request.QueryString("IDDOC")
        Else
            Response.Write("Parametro IDDOC obbligatorio")
        End If

        strSql = "select objCertificato as blob from CTL_SIGN_ATTACH_INFO with(nolock) where id = " & CLng(idDoc)

        If (db.init()) Then

            Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
            Dim r As SqlDataReader = sqlComm.ExecuteReader()

            '-- se la select ritorna un record
            If (r.Read() = True) Then

                '-- Estratto un array di byte dal database per la colonna "blob"
                Dim ndx As Integer = r.GetOrdinal("blob")
                Dim size As Long = r.GetBytes(ndx, 0, Nothing, 0, 0)
                Dim values As Byte() = New Byte(size - 1) {}    '-- allegato recuperato dal db

                Dim bufferSize As Integer = 1024
                Dim bytesRead As Long = 0
                Dim curPos As Integer = 0

                While (bytesRead < size)
                    If (size - bytesRead < bufferSize) Then
                        bufferSize = size - bytesRead
                    End If

                    bytesRead += r.GetBytes(ndx, curPos, values, curPos, bufferSize)
                    curPos += bufferSize
                End While


                Response.Clear()
                Response.ClearHeaders()
                Response.ClearContent()

                Response.AddHeader("Pragma", "no-cache")
                Response.AddHeader("Expires", "0")
                Response.AddHeader("Content-Length", values.Length.ToString())

                Response.Charset = Nothing
                Response.ContentType = contentFile
                Response.AddHeader("content-disposition", "attachment; filename=certificato.cer")

                Response.BinaryWrite(values)


                Response.Flush()
                'Response.Close()

                r.Close()
                db.close()

                values = Nothing

            Else

                Response.Write("Nessun certificato associato all'id " & idDoc)

            End If

        Else

            Response.Write("Errore nella connessione al database")

        End If

    End Sub

    Private Sub compilaModuloPdf()

        '-- Controllo parametri obbligatori
        If (Request.QueryString("URL_DOWNLOAD") = Nothing) Or (Request.QueryString("URL_DOWNLOAD") = "") Then
            Return
        End If
        If (Request.QueryString("VIEW") = Nothing) Or (Request.QueryString("VIEW") = "") Then
            Return
        End If
        If (Request.QueryString("ID_VIEW") = Nothing) Or (Request.QueryString("ID_VIEW") = "") Then
            Return
        End If

        Dim contentFile As String = "Application/pdf"
        Dim tempFile As String
        Dim db As New DbUtil

        uniqueStr = "_" & Date.Now.Hour & Date.Now.Minute & Date.Now.Second & Date.Now.Millisecond & "_"

        If CStr(Request.QueryString("pdf")) <> "" Then
            tempFile = CStr(Request.QueryString("pdf"))
        Else
            tempFile = outFile & uniqueStr & "pdf_temp.pdf"
        End If

        If (db.init()) Then

            db.trace(".net invocazione compilaModuloPdf : " & Request.QueryString.ToString, "compilaModuloPdf()")
            db.close()

        End If

        Dim reader As PdfReader = Nothing

        Try

            '-- Se ci viene chiesto di elaborare un pdf da url
            If (LCase(Left(Request.QueryString("URL_DOWNLOAD"), 5)) = "http:" Or LCase(Left(Request.QueryString("URL_DOWNLOAD"), 5)) = "https") Then

                reader = New PdfReader(New Uri(Request.QueryString("URL_DOWNLOAD")))

            Else

                '-- altrimenti è da file system
                reader = New PdfReader(Request.QueryString("URL_DOWNLOAD"))

            End If

        Catch ex As Exception

            If (db.init()) Then
                db.trace("ERRORE new PdfReader(" & Request.QueryString("URL_DOWNLOAD") & "), " & ex.Message, "pdf.aspx.compila_modulo_pdf")
                db.close()
            End If

            Throw New Exception("Errore nel PdfReader(URL:" & Request.QueryString("URL_DOWNLOAD") & ") :: ERRORE :: " & ex.Message)

        End Try


        '-- se c'era un file con lo stesso nome lo cancelliamo (praticamente impossibile).. vedi "la differenza tra la teoria e la pratica"
        If (File.Exists(tempFile)) Then
            File.Delete(tempFile)
        End If

        'Dim memStream As New MemoryStream()

        Dim stamper = Nothing

        Try
            stamper = New PdfStamper(reader, New FileStream(tempFile, FileMode.Create))
        Catch ex As Exception

            If (db.init()) Then
                db.trace("ERRORE IN PdfStamper(" & Request.QueryString("URL_DOWNLOAD") & "), :  " & ex.Message, "pdf.aspx.compila_modulo_pdf")
                db.close()
            End If


            Throw New Exception("Errore nella creazione del PdfStamper (tempFile:" & tempFile & ") :: ERRORE :: " & ex.Message)
        End Try




        Dim pdfFormFields = stamper.AcroFields

        'pdfFormFields.SetField("RAGIONE_SOCIALE", " -- RAGIONE SOCIALE --")
        'pdfFormFields.SetField("SEDE_LEGALE", " -- SEDE LEGALE --")
        'pdfFormFields.SetField("CODFIS_PIVA", " -- PIVA COD FISC! --")


        Dim strSql As String = ""

        If (db.init()) Then

            strSql = "select * from " & Replace(Request.QueryString("VIEW"), " ", "") & " where id = '" & Replace(Request.QueryString("ID_VIEW"), "'", "''") & "'"

            db.trace(".net pdf recuperato, select in corso su vista parametri : '" & strSql & "'", "compilaModuloPdf()")

            Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
            sqlComm.CommandTimeout = 240 'il default era 30 secondi
            Dim r As SqlDataReader = sqlComm.ExecuteReader()

            '-- se il ritorna dei record
            If (r.Read() = True) Then

                '-- Itero sulle colonne della select e per ogni nomeColonna provo a cercare il corrispettivo
                '-- field nel pdf e ci carico il valore associato che mi ritorna la vista

                For k As Integer = 1 To r.FieldCount

                    Try
                        pdfFormFields.SetField(r.GetName(k), r(k))
                    Catch ex As Exception

                    End Try

                Next

            Else

                db.trace(".net, la select (" & strSql & ") non ha tornato record. chiamata : " & Request.QueryString.ToString, "compilaModuloPdf()")
                db.close()
                Return

            End If


            db.close()
            sqlComm = Nothing
            r.Close()

            r = Nothing

        Else

            If (File.Exists(tempFile)) Then
                File.Delete(tempFile)
            End If

            Return

        End If


        stamper.Close()

        '-- Se è stata chiesta la scrittura del PDF compilato su filesystem e non in binary stream
        If CStr(Request.QueryString("pdf")) = "" Then

            Response.Clear()
            Response.ClearHeaders()
            Response.ClearContent()

            Dim values As Byte()

            values = ReadFile(tempFile)

            Response.AddHeader("Pragma", "no-cache")
            Response.AddHeader("Expires", "0")
            'Response.AddHeader("Content-Length", memStream.Length.ToString())
            Response.AddHeader("Content-Length", values.Length.ToString())

            Response.Charset = Nothing
            Response.ContentType = contentFile
            Response.AddHeader("content-disposition", "attachment; filename=ElaboratoPdf.pdf")

            'memStream.Seek(0, SeekOrigin.Begin)
            'memStream.Close()

            Response.BinaryWrite(values)

            Response.Flush()
            'Response.Close()

            If (File.Exists(tempFile)) Then
                File.Delete(tempFile)
            End If

            values = Nothing

        Else


            Response.Write("1#OK")

        End If

        'memStream = Nothing

        stamper = Nothing
        reader = Nothing


    End Sub

    '-- funzione invocata via COM per la verifica estesa di firma digitale
    Public Function firmaEstesaCOM(mode As String, pdf As String, isSigned As String, signedfile As String, att_hash As String, attIdMsg As String, attOrderFile As String, attIdObj As String, idAzi As String) As String

        'Dim db As DbUtil = New DbUtil()
        'Dim strSql As String = ""

        'If (db.init() = True) Then


        '    strSql = "insert into ctl_trace (descrizione) values ('TEST_HTML2PDF.firmaEstesaCOM')"
        '    Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
        '    sqlComm.ExecuteNonQuery()

        'End If

        'db.close()

        'mode=SIGN
        'mode=VERIFICA_P7M
        'mode=VERIFICA_PDF
        On Error Resume Next

        firmaEstesaCOM = ""

        If (UCase(mode) = "VERIFICA_P7M") Then

            If (signedfile = Nothing) Or (signedfile = "") Then

                firmaEstesaCOM = "0#Parametro signedfile obbligatorio per la verifica avanzata di un allegato firmato"

            Else

                If Not System.IO.File.Exists(signedfile) Then

                    firmaEstesaCOM = "0#File " & signedfile & " non trovato "

                Else

                    '-- test verifica avanzata P7M
                    firmaEstesaCOM = verifyP7M(signedfile, True, att_hash, attIdMsg, attOrderFile, attIdObj, idAzi)

                    If Err.Number <> 0 Then
                        firmaEstesaCOM = "0#ERR:" & Err.Description

                        If totIterazioni > 0 Then

                            '-- Cancelliamo tutti i file estratti
                            For k As Integer = totIterazioni To 0 Step -1

                                System.IO.File.Delete(outFile & uniqueStr & "estratto" & k)
                                Err.Clear()
                            Next

                        End If

                    End If

                End If

            End If

        ElseIf (UCase(mode) = "VERIFICA_PDF") Then

            '-- test verifica avanzata PDF
            Dim a As New sign.Utils

            If Not att_hash Is Nothing And att_hash <> "" Then
                a.ATT_Hash = att_hash
            End If

            If Not attIdMsg Is Nothing And attIdMsg <> "" Then
                a.attIdMsg = attIdMsg
            End If

            If Not attOrderFile Is Nothing And attOrderFile <> "" Then
                a.attOrderFile = attOrderFile
            End If

            If Not attIdObj Is Nothing And attIdObj <> "" Then
                a.attIdObj = attIdObj
            End If

            If Not idAzi Is Nothing And idAzi <> "" Then
                a.idAzi = idAzi
            End If

            If (signedfile = Nothing) Or (signedfile = "") Then

                firmaEstesaCOM = "0#Parametro signedfile obbligatorio per la verifica avanzata di un allegato firmato"

            Else

                Dim out As String = ""

                If Not System.IO.File.Exists(signedfile) Then

                    firmaEstesaCOM = "0#File " & signedfile & " non trovato "

                Else

                    a.verifyPdfSigned(signedfile, out, Nothing)

                    If (Err.Number <> 0) Then
                        firmaEstesaCOM = "0#ERR: " & Err.Description
                    Else
                        firmaEstesaCOM = out
                    End If

                End If

            End If

        ElseIf (UCase(mode) = "SIGN") Then
            firmaEstesaCOM = firmaDigiale(True, pdf, isSigned)
        End If


    End Function

    '-- viene passato l'id tabellare della tabella ctl_sign_attach_info e si ritorna
    '-- l'output da portare a video per l'esito della verifica di revoca
    Private Function verifica_revoca(id As Long) As String

        Dim strcause As String = ""
        Dim db As New DbUtil

        Try
            Dim x509 As New X509Certificate2
            Dim motivoRevoca As String = ""
            Dim revoked As Integer = -1
            Dim esitoVerifica As New Microsoft.VisualBasic.Collection


            If (db.init()) Then

                Dim strSql As String = "select id,objCertificato, isnull(dataApposizioneFirma,'') as dataApposizioneFirma,statoFirma,dataVerifica from ctl_sign_attach_info with(nolock) where id = " & id

                Dim sqlComm As New SqlCommand(strSql, db.sqlConn)

                strcause = "Eseguo la select per il recupero del certificato"

                Dim r As SqlDataReader = sqlComm.ExecuteReader()

                'Dim attach() As Byte = Nothing
                Dim certificato() As Byte

                '-- se il record è presente
                If (r.Read() = True) Then

                    Dim vecchioStatoFirma As String = r("statoFirma")

                    '-- Se lo stato firma è in uno stato non corretto per verificare la revoca essendo già stato messo ad ok o a non ok
                    If vecchioStatoFirma <> "SIGN_OK_NOT_VER_REVOCA" And vecchioStatoFirma <> "SIGN_OK_NOT_CF_NOT_VER_REVOCA" Then

                        r.Close()
                        db.close()
                        Return "1#OK"


                    End If

                    strcause = "Leggo il certificato da verificare"

                    Dim ndx As Integer = r.GetOrdinal("objCertificato")
                    Dim dataFirma As Date = IIf(CStr(r("dataApposizioneFirma")) = "", r("dataVerifica"), r("dataApposizioneFirma"))

                    Dim len As Long = r.GetBytes(ndx, 0, Nothing, 0, 0)
                    Dim statoFirma As String = ""
                    Dim VerificaCF As Integer = 0

                    ReDim certificato(CInt(len))

                    '-- leggo il certificato( in byte ) dal record
                    r.GetBytes(ndx, 0, certificato, 0, CInt(len))

                    x509.Import(certificato)

                    r.Close()

                    strcause = "Eseguo la verifica del certificato"
                    esitoVerifica = New sign.Utils().verificaRevocaWindows(x509, dataFirma)

                    motivoRevoca = esitoVerifica("motivo")
                    revoked = esitoVerifica("revocato")

                    If revoked < 0 Then

                        Try

                            Dim certificato2 As New Chilkat.Cert
                            certificato2.LoadFromBinary(certificato)
                            Dim esitoIntverifica = New sign.Utils().verificaRevocaChilkat(certificato2)

                            '  0: Good
                            '  1: Revoked
                            '  2: Unknown.
                            Select Case esitoIntverifica
                                Case 0
                                    revoked = 0
                                Case 1
                                    revoked = 1
                                Case 2
                                    revoked = -1
                            End Select


                            certificato2 = Nothing

                            motivoRevoca = ""

                        Catch ex As Exception
                            revoked = -1
                        End Try

                    End If

                    certificato = Nothing
                    x509 = Nothing

     
                    If (revoked = 0) Then
                        statoFirma = "SIGN_OK" '-- Tutto ok
                        VerificaCF = 0
                    ElseIf (revoked = 1) Then
                        statoFirma = "SIGN_NOT_OK" '-- firma non ok perchè il certificato è revocato
                        VerificaCF = 1
                    ElseIf (revoked = -2) Then  '-- la revoca non è stata verificata e non farò ri-iterare la verifica mancando il root certificate nello store. PartialChain
                        statoFirma = "SIGN_OK_NOT_VER_REVOCA"
                        VerificaCF = 0
                    Else
                        statoFirma = "SIGN_OK_NOT_VER_REVOCA" '-- Tutto ok tranne che è stato possibile verifica se il certificato è revocato
                        VerificaCF = -1
                    End If

                    '-- se la revoca non è stata verificata ma era gia passato il controllo del codice fiscale
                    If revoked < 0 And vecchioStatoFirma = "SIGN_OK_NOT_CF_NOT_VER_REVOCA" Then
                        statoFirma = "SIGN_OK_NOT_CF_NOT_VER_REVOCA"
                        VerificaCF = 1
                    End If

                    strcause = "Eseguo la query di update "

                    strSql = "UPDATE ctl_sign_attach_info "
                    strSql = strSql & " SET statoFirma = '" & Replace(statoFirma, "'", "''") & "' "
                    strSql = strSql & " ,tentativiTestRevoca = isnull(tentativiTestRevoca,0) + 1 "
                    strSql = strSql & " ,isRevoked = " & revoked
                    strSql = strSql & " ,VerificaCF = " & VerificaCF

                    If revoked <= 0 And motivoRevoca <> "" Then
                        strSql = strSql & " ,note = '" & Replace(motivoRevoca, "'", "''") & "' "
                    Else
                        strSql = strSql & " ,note = '' "
                    End If

                    strSql = strSql & " WHERE id = " & id

                    sqlComm = New SqlCommand(strSql, db.sqlConn)

                    sqlComm.ExecuteNonQuery()

                    sqlComm = Nothing

                    db.close()
                    Return "1#OK"

                Else

                    db.trace("Il record con id " & id & " non esiste", "pdf.aspx - verifica_revoca")
                    db.close()

                    Return "0#Il record con id " & id & " non esiste"

                End If

            Else

                Return "0#Errore nella connessione al db." & db.dbError

            End If

        Catch ex As Exception

            db.trace("ERRORE IN VERIFICA_REVOCA, " & strcause & " --- " & ex.Message, "pdf.aspx - verifica_revoca")
            db.close()
            Return "0#" & strcause & " --- " & ex.Message

        End Try

    End Function

    '-- PARAMETRI DI INPUT :
    '--     * directory = Directory in cui ci si aspettano i file pdf da fondere insieme. tutti i pdf in essa contenuti verranno fusi
    '-- OUTPUT : true se è stato generato bene, eccezione se c'è stato un errore
    Public Function mergePdf(strDirectory As String, Optional strFileOutput As String = "") As String

        Dim mergeResultPdfDocument As New EvoPdf.Document
        Dim listaFile As String()

        'mergeResultPdfDocument.AutoCloseAppendedDocs = True
        mergeResultPdfDocument.LicenseKey = licenceKey

        mergeResultPdfDocument.AutoCloseAppendedDocs = True

        '-- se la directory esiste
        If Directory.Exists(strDirectory) Then

            listaFile = Directory.GetFiles(strDirectory)
            Array.Sort(listaFile) '-- ordino la lista di file per nome

            Dim fileToMerge As String

            For Each fileToMerge In listaFile

                '-- se il file è un pdf
                If LCase(CStr(Right(fileToMerge, 4))) = ".pdf" Then

                    Try

                        Dim pdfDocumentToMerge As New EvoPdf.Document(fileToMerge)

                        '-- Se il pdf è generato in modo anomalo e possiede 2 %%EOF uno all'inizio(o a metà) e l'altro alla fine
                        '-- potrebbe andare in errore il suo parse.

                        mergeResultPdfDocument.AppendDocument(pdfDocumentToMerge)

                        'pdfDocumentToMerge.Close()

                    Catch ex As Exception
                        'Throw New System.Exception("ERRORE in blocco (open,append,close):" & ex.Message)
                        mergePdf = "Errore nella lettura del file '" & getNomeFileFromPath(fileToMerge) & "'. errore: " & ex.Message
                        Exit Function
                    End Try

                End If

            Next

        Else

            'Throw New System.Exception(CStr(strDirectory) & " non è una directory valida.")
            mergePdf = CStr(strDirectory) & " non è una directory valida."
            Exit Function

        End If

        Dim outPdfBuffer() As Byte

        Try

            If mergeResultPdfDocument Is Nothing Then
                'Throw New System.Exception("ERRORE. mergeResultPdfDocument e' NULL")
                mergePdf = "ERRORE. mergeResultPdfDocument e' NULL"
                Exit Function
            End If

            'Salva il pdf finale nell'array di byte
            outPdfBuffer = mergeResultPdfDocument.Save()

            mergeResultPdfDocument.Close()

        Catch ex As Exception
            'Throw New System.Exception("ERRORE nella save() del pdf:" & ex.Message)
            mergePdf = "ERRORE nella save() del pdf:" & ex.Message
            Exit Function
        End Try

        If outPdfBuffer.Length > 0 Then

            If File.Exists(strFileOutput) Then
                Try
                    File.Delete(strFileOutput)
                Catch ex As Exception

                End Try
            End If

            Try
                File.WriteAllBytes(strFileOutput, outPdfBuffer)
            Catch ex As Exception
                mergePdf = "Errore nella scrittura del file pdf finale. " & ex.Message
                Exit Function
            End Try


            'Lo restituisco in output al browser
            'Response.AddHeader("Content-Type", "application/pdf")
            'Response.AddHeader("Content-Disposition", String.Format("attachment; filename=" & strNomeFileOutput & "; size={0}", outPdfBuffer.Length.ToString()))
            'Response.BinaryWrite(outPdfBuffer)
            'Response.End()

        Else
            'Throw New System.Exception("Errore nella generazione del file pdf. Taglia 0 del pdf finale")
            mergePdf = "Errore nella generazione del file pdf. Taglia 0 del pdf finale"
            Exit Function
        End If


        Return ""

    End Function

    Private Function getDigestAlgorithm(ByRef crypt As Chilkat.Crypt2, ByVal fileP7m As String, ByVal indexFirmatario As Integer) As String

        getDigestAlgorithm = ""

        Dim json As Chilkat.JsonObject = crypt.LastJsonData
        json.EmitCompact = False
        json.Emit()

        If IsNumeric(indexFirmatario) = False Then
            indexFirmatario = 0
        End If

        Dim oid_digest_alg As String = json.StringOf("pkcs7.verify.signerInfo[" & indexFirmatario & "].cert.digestAlgOid")

        If oid_digest_alg <> "" Then

            getDigestAlgorithm = oid_digest_alg

        Else

            getDigestAlgorithm = json.StringOf("pkcs7.verify.digestAlgorithms[0]")

            If UCase(getDigestAlgorithm) = "SHA256" Then
                getDigestAlgorithm = "2.16.840.1.101.3.4.2.1"
            ElseIf UCase(getDigestAlgorithm) = "SHA384" Then
                getDigestAlgorithm = "2.16.840.1.101.3.4.2.2"
            ElseIf UCase(getDigestAlgorithm) = "SHA512" Then
                getDigestAlgorithm = "2.16.840.1.101.3.4.2.3"
            End If

        End If


    End Function

End Class
