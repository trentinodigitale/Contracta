Imports System.Web

Imports System.IO
Imports System.Text

Imports System.Configuration
Imports System.Collections
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Imports System.Security.Cryptography.X509Certificates
Imports Org.BouncyCastle.X509
Imports Org.BouncyCastle.Tsp
Imports Org.BouncyCastle.Ocsp
Imports Org.BouncyCastle.X509.Store

Imports System.Xml
Imports iTextSharp.text.pdf
Imports iTextSharp.text.pdf.parser
Imports EvoPdf
Imports System.Data.SqlClient
Imports System.Net.Security
Imports System.Net


Module Module1

    'Public licenceKey As String = "b+Hy4PPz4PP29+D07vDg8/Hu8fLu+fn5+Q=="
    Public licenceKey As String = "5mh7aXp6aXlpfGd5aXp4Z3h7Z3BwcHA="

    Dim header1 As String = ""
    Dim headerN As String = ""
    Dim footer As String = ""
    Dim tipoChiave As String = ""
    Dim HeaderHeight As String = ""
    Dim FooterHeight As String = ""
    Dim baseURL As String = ""

    'Federico Leone
    Public Sub ConvertURLToPDF(url As String, pdfOut As String, pageSize As String, pageOrientation As String, fitWidth As String, isPdfA As Boolean, Optional footerKey As String = "", Optional lngPrefix As String = "I", Optional mediaType As String = "screen", Optional viewFooter As String = "", Optional idDoc As String = "")

        ' PDF converter. Può prendere come parametro l'html width del foglio
        ' Il default with per l'HTML viewer è di 1024 pixels.
        Dim pdfConverter As New PdfConverter()
        Dim db As New DbUtil

        ' license key
        pdfConverter.LicenseKey = licenceKey  'DEMO :  "ORIJGQoKGQkZCxcJGQoIFwgLFwAAAAA="

        If isPdfA Then
            pdfConverter.PdfDocumentOptions.PdfStandardSubset = EvoPdf.PdfStandardSubset.Pdf_A_1b
        End If

        pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A4
        pdfConverter.NavigationTimeout = 20

        '-- disattivato, altrimenti la firma embedded non funziona
        If (False) Then

            '-- blocco tutte le possibilità di editazione e di copia del pdf
            pdfConverter.PdfSecurityOptions.CanCopyContent = False
            pdfConverter.PdfSecurityOptions.CanEditContent = False
            pdfConverter.PdfSecurityOptions.CanEditAnnotations = False
            pdfConverter.PdfSecurityOptions.CanFillFormFields = False

        End If

        If Not pageSize Is Nothing And CStr(pageSize) <> "" Then

            If UCase(pageSize) = "A0" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A0
            If UCase(pageSize) = "A1" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A1
            If UCase(pageSize) = "A2" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A2
            If UCase(pageSize) = "A3" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A3
            If UCase(pageSize) = "A4" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A4
            If UCase(pageSize) = "A5" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A5
            If UCase(pageSize) = "A6" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A6
            If UCase(pageSize) = "A7" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A7
            If UCase(pageSize) = "A8" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A8
            If UCase(pageSize) = "A9" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A9
            If UCase(pageSize) = "A10" Then pdfConverter.PdfDocumentOptions.PdfPageSize = PdfPageSize.A10

        End If

        pdfConverter.PdfDocumentOptions.PdfPageOrientation = PdfPageOrientation.Portrait

        If Not pageOrientation Is Nothing And CStr(pageOrientation) <> "" Then

            If UCase(pageOrientation) = "PORTRAIT" Then pdfConverter.PdfDocumentOptions.PdfPageOrientation = PdfPageOrientation.Portrait
            If UCase(pageOrientation) = "LANDSCAPE" Then pdfConverter.PdfDocumentOptions.PdfPageOrientation = PdfPageOrientation.Landscape

        End If

        If Not fitWidth Is Nothing And (UCase(fitWidth) = "NO" Or UCase(fitWidth) = "0") Then

            'set if the HTML content is resized if necessary to fit the PDF page width - default is true
            pdfConverter.PdfDocumentOptions.FitWidth = False

        End If

        pdfConverter.PdfDocumentOptions.PdfCompressionLevel = PdfCompressionLevel.Normal

        pdfConverter.PdfDocumentOptions.ShowHeader = False

        pdfConverter.PdfDocumentOptions.EmbedFonts = True

        pdfConverter.PdfDocumentOptions.LiveUrlsEnabled = False

        pdfConverter.JavaScriptEnabled = True
        pdfConverter.InterruptSlowJavaScript = True
        pdfConverter.PdfConverterConcurrencyLevel = -1

        pdfConverter.PdfDocumentOptions.JpegCompressionEnabled = True


        If footerKey <> "" Then

            '-- AGGIUNGO LA PAGINAZIONE AUTOMATICA SFRUTTANDO UN FOOTER HTML AGGIUNTO MANUALMENTE
            Dim strHtmlFooterPaging As String = "" '"<!DOCTYPE html><html><head></head><body style=""font-family: 'Times New Roman'; font-size: 14px""><table style=""width: 100%""><tr><td style=""width: 90%"">Pagina <span style=""color: navy; font-weight: bold"">&p;</span> di <span style=""font-size: 16px; color: green; font-weight: bold"">&P;</span> pagine</td></tr></table></body></html>"
            Dim footerHeight As Integer = 20
            Dim ml_key As String = footerKey

            '-- se footerKey contiene @@@ mi aspetto una forma del tipo 20@@@ML_FOOTER_PDF_PAGING
            If footerKey.Contains("@@@") Then

                Try

                    Dim vet() As String
                    vet = Split(footerKey, "@@@")

                    footerHeight = CInt(vet(0))
                    ml_key = CInt(vet(1))

                Catch ex As Exception
                    footerHeight = 20
                End Try

            End If

            If lngPrefix = "" Then
                lngPrefix = "IT"
            End If

            Dim strSql As String = "select ML_Description from LIB_Multilinguismo with(nolock) where ml_key = '" & Replace(ml_key, "'", "''") & "' and ml_lng = '" & Replace(lngPrefix, "'", "''") & "'"

            If (db.init()) Then

                Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                Dim r As SqlDataReader = sqlComm.ExecuteReader()

                If (r.Read() = True) Then

                    strHtmlFooterPaging = r("ML_Description")

                Else

                    strHtmlFooterPaging = ""

                End If

                r.Close()
                r = Nothing
                db.close()
                sqlComm = Nothing

            End If

            If strHtmlFooterPaging <> "" Then

                pdfConverter.PdfDocumentOptions.ShowFooter = True
                pdfConverter.PdfFooterOptions.FooterHeight = 20

                Dim footerHtmlWithPageNumbers As New HtmlToPdfVariableElement(strHtmlFooterPaging, "")

                pdfConverter.PdfFooterOptions.AddElement(footerHtmlWithPageNumbers)


            End If

            '-- FINE GESTIONE AUTOMATICA PAGINAZIONE

        Else

            'viewFooter = ""

            If viewFooter <> "" Then

                '-- IL PASSAGGIO DI QUESTA VISTA ATTIVA IL MECCANISMO DI FOOTER/HEADER IN FUNZIONE DEI DATI RITORNATI. LA VISTA DOVRA' AVERE LA SEGUENTE STRUTTURA
                '	idRow,idDoc,htmlValue,tipo ( valori ammessi : 'header1','headerN', 'footer' )

                Dim strSql As String = "select isnull(htmlValue,'') as val,tipo from " & Replace(Replace(viewFooter, " ", ""), "'", "''") & " where idDoc = " & CStr(CLng(idDoc))

                If (db.init()) Then

                    Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                    Dim r As SqlDataReader = sqlComm.ExecuteReader()

                    While r.Read()

                        tipoChiave = r("tipo")

                        If tipoChiave.ToUpper().Equals("HEADER1") Then
                            header1 = r("val")
                        End If

                        If tipoChiave.ToUpper().Equals("HEADERN") Then
                            headerN = r("val")
                        End If

                        If tipoChiave.ToUpper().Equals("FOOTER") Then
                            footer = r("val")
                        End If

                        If tipoChiave.ToUpper().Equals("HEADERHEIGHT") Then
                            HeaderHeight = r("val")
                        End If

                        If tipoChiave.ToUpper().Equals("FOOTERHEIGHT") Then
                            FooterHeight = r("val")
                        End If

                        If tipoChiave.ToUpper().Equals("BASEURL") Then
                            baseURL = r("val")
                        End If


                    End While

                    r.Close()
                    r = Nothing

                    If baseURL = "" Then

                        strSql = "select dbo.CNV_ESTESA('#SYS.SYS_WEBSERVERAPPLICAZIONE_INTERNO##SYS.SYS_strVirtualDirectory#/report/','I') as baseURL"
                        sqlComm = New SqlCommand(strSql, db.sqlConn)
                        r = sqlComm.ExecuteReader()

                        If r.Read Then
                            baseURL = r("baseURL")
                        End If

                        r.Close()

                    End If

                    'baseURL = ""

                    db.close()
                    sqlComm = Nothing

                    If footer <> "" Then

                        pdfConverter.PdfDocumentOptions.ShowFooter = True

                        'pdfConverter.PdfFooterOptions.FooterHeight = 80

                        Dim footerHtmlWithPageNumbers As New HtmlToPdfVariableElement(footer, baseURL)

                        '-- se viene passata un altezza dell'header specifica
                        If FooterHeight <> "" Then
                            pdfConverter.PdfFooterOptions.FooterHeight = CInt(FooterHeight)
                        Else
                            footerHtmlWithPageNumbers.FitHeight = True
                        End If

                        pdfConverter.PdfFooterOptions.AddElement(footerHtmlWithPageNumbers)

                    End If

                    If header1 <> "" Or headerN <> "" Then

                        If header1 <> "" Then
                            AddHandler pdfConverter.PrepareRenderPdfPageEvent, AddressOf htmlToPdfConverter_PrepareRenderPdfPageEvent
                        End If

                        If HeaderHeight <> "" Then
                            pdfConverter.PdfHeaderOptions.HeaderHeight = CInt(HeaderHeight)
                        End If

                        pdfConverter.PdfDocumentOptions.ShowHeader = True

                        If HeaderHeight <> "" Then
                            DrawHeader(pdfConverter, CInt(HeaderHeight))
                        Else
                            DrawHeader(pdfConverter)
                        End If

                        'AddHandler pdfConverter.PrepareRenderPdfPageEvent, AddressOf htmlToPdfConverter_PrepareRenderPdfPageEvent

                    End If

                    End If

                End If

            End If

            pdfConverter.HttpRequestCookies.Clear()

            '-- il default della libreria è screen, ma in alcuni contesti può esserci utile passa print per fargli prendere i css che hanno media type print
            pdfConverter.MediaType = mediaType

            pdfConverter.SavePdfFromUrlToFile(url, pdfOut)

            pdfConverter = Nothing

    End Sub

    Private Sub DrawHeader(ByVal htmlToPdfConverter As HtmlToPdfConverter, Optional height As Integer = 0)

        htmlToPdfConverter.PdfHeaderOptions.HeaderBackColor = Drawing.Color.White

        'Dim headerHtml As New HtmlToPdfElement(headerN, baseURL)
        Dim headerHtml As New HtmlToPdfVariableElement(headerN, baseURL)

        If height <> 0 Then
            htmlToPdfConverter.PdfHeaderOptions.HeaderHeight = CInt(HeaderHeight)
        Else
            headerHtml.FitHeight = True
        End If

        htmlToPdfConverter.PdfHeaderOptions.AddElement(headerHtml)

    End Sub

    Private Sub htmlToPdfConverter_PrepareRenderPdfPageEvent(ByVal eventParams As PrepareRenderPdfPageParams)

        If (eventParams.PageNumber = 1) Then

            Dim pdfPage As EvoPdf.PdfPage = eventParams.Page

            pdfPage.AddHeaderTemplate(80)
            DrawAlternativePageHeader(pdfPage.Header, True)


        End If

    End Sub

    Private Sub DrawAlternativePageHeader(ByVal headerTemplate As Template, ByVal drawHeaderLine As Boolean)

        'Dim headerHtml As New HtmlToPdfElement(header1, baseURL)
        Dim headerHtml As New HtmlToPdfVariableElement(header1, baseURL)

        If HeaderHeight <> "" Then
            headerHtml.Height = CInt(HeaderHeight)
        Else
            headerHtml.FitHeight = True
        End If

        'headerHtml.FitHeight = True

        headerTemplate.AddElement(headerHtml)

    End Sub

    Private Sub ___htmlToPdfConverter_PrepareRenderPdfPageEvent(ByVal eventParams As PrepareRenderPdfPageParams)

        Dim pdfPage As EvoPdf.PdfPage = eventParams.Page
        Dim headerHtml = Nothing

        If (eventParams.PageNumber = 1) Then
            If header1 <> "" Then
                headerHtml = New HtmlToPdfVariableElement(header1, baseURL)
            End If
        Else
            If headerN <> "" Then
                headerHtml = New HtmlToPdfVariableElement(headerN, baseURL)
            End If
        End If

        headerHtml.FitHeight = True

        pdfPage.Header.AddElement(headerHtml)

    End Sub

    'Federico Leone
    'esempio d'uso : 
    'hash = parsePdf("c:\pdfFirmato.pdf", "true")
    Public Function parsePdf(ByVal pdf As String, ByVal isSigned As String) As String


        Dim i As Integer

        On Error Resume Next

        If My.Computer.FileSystem.GetFileInfo(pdf).Length = 0 Then

            If Err.Number = 0 Then

                '-- se non ci sono stati errori e il file è a taglia zero
                Return "0#File a taglia 0"

            End If

        End If

        On Error GoTo err

        Dim reader As PdfReader = New PdfReader(pdf)
        Dim parser As PdfReaderContentParser = New PdfReaderContentParser(reader)
        'Dim out As IO.StreamWriter = New IO.StreamWriter(txt, False, System.Text.Encoding.ASCII)
        Dim out As String
        Dim resp As String = ""

        Dim totAnnotation As Integer = 0
        Dim totExtra As Integer = 0

        Dim db As New DbUtil
        out = ""

        'Se il file dovrebbe essere firmato, ma in realtà non lo è, restituiamo errore
        If ((isSigned = "1" Or UCase(isSigned) = "TRUE") And reader.AcroFields.GetSignatureNames.Count = 0) Then

            parser = Nothing
            reader.Close()
            Return "0#Il file non è firmato digitalmente"

        End If

        For i = 1 To reader.NumberOfPages

            out = out & parser.ProcessContent(i, New SimpleTextExtractionStrategy()).GetResultantText()
            out = out & parser.ProcessContent(i, New ImageListener()).imgTxt

            On Error Resume Next

            Dim pageDict As PdfDictionary
            Dim annotationArray As PdfArray

            pageDict = reader.GetPageN(i)

            '-- Recupero il numero di annotations utilizzate ( area di testo aggiunte, disegni, sottolineature, figure etc)
            totAnnotation = totAnnotation + pageDict.GetAsArray(PdfName.ANNOTS).Size

            '-- Tutti questi extra sembrano essere sempre a 0. L'unica collezione corretta sembra essere la annots
            totExtra = totExtra + pageDict.GetAsArray(PdfName.HIGHLIGHT).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.ARTBOX).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.EMBEDDEDFILES).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.VIDEO).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.ANIMATION).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.CIRCLE).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.POLYLINE).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.POLYGON).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.POLYGON).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.FIGURE).Size
            totExtra = totExtra + pageDict.GetAsArray(PdfName.FREETEXT).Size
            'totExtra = totExtra + pageDict.GetAsArray(PdfName.ALL).Size

            totAnnotation = totAnnotation + totExtra

            On Error GoTo err

        Next

        If totAnnotation > 0 Then
            '-- tolgo dal totale il numero di firme embedded (vengono viste come annotations del pdf)
            totAnnotation = totAnnotation - reader.AcroFields.GetSignatureNames.Count
        End If


        On Error Resume Next

        '-- Aggiungo a quanto gia preso anche il contenuto di eventuali campi 'MODULO'. In assenza di questi ultimi lascio inalterato l'hash finale per mantenere
        '-- massima la retrocompatibilità 
        Dim pdfFormFields = reader.AcroFields
        Dim contenutoForm As String = ""

        '-- Itero sulle colonne della select e per ogni nomeColonna provo a cercare il corrispettivo
        '-- field nel pdf e ci carico il valore associato che mi ritorna la vista

        Dim campo As KeyValuePair(Of String, AcroFields.Item)

 
        If Not pdfFormFields.Fields Is Nothing Then

            If pdfFormFields.Fields.Count - reader.AcroFields.GetSignatureNames.Count > 0 Then

                '-- se sono presenti campi modulo ( escludo i campi firma, che fanno parte del set acroFields o che hanno nella key 'pades' )
                '--                                                                                                 ( abbiamo verificato empiricamente che la firma embedded invisibile per qualche strano motivo
                '--                                                                                                   finisce tra i campi 'form' )
                For Each campo In pdfFormFields.Fields

                    '-- se il campo non è tra quelli di firma
                    If reader.AcroFields.GetSignatureNames.Contains(campo.Key) = False And campo.Key.ToLower.Contains("pades") = False Then
                        contenutoForm = CStr(contenutoForm) & campo.Key & "=" & pdfFormFields.GetField(campo.Key) & ";"
                    End If

                    'If campo.Key.ToLower.Contains("pades") = True Then
                    'If totAnnotation > 0 Then
                    'totAnnotation = totAnnotation - 1
                    'End If
                    'End If

                Next
            End If

        End If

        If contenutoForm <> "" Then
            out = out & CStr(contenutoForm)
        End If

        pdfFormFields = Nothing
        campo = Nothing


        On Error GoTo err

        resp = "1#" & getSHA1Hash(Trim(out))

        '-- Se sono presenti 'aggiunte' al file pdf aggiungo il loro numero in coda all'hash
        If totAnnotation > 0 Then
            resp = resp & "-" & CStr(totAnnotation)
        End If

        If (db.init() = True) Then

            db.trace("Risposta dal metodo parsePdf() per il file " & pdf & " : " & resp, "parsePdf()")
            db.close()

        End If

        parser = Nothing
        reader.Close()

        reader = Nothing

        Return resp
err:

        Dim errore As String = Err.Description

        Err.Clear()

        If (db.init() = True) Then

            db.trace("Risposta dal metodo parsePdf() per il file " & pdf & " : 0#" & Err.Description, "parsePdf()")
            db.close()

        End If

        Err.Clear()

        Return CStr("0#" & CStr(errore))

    End Function


    Function getSHA1Hash(ByVal strToHash As String) As String
        Dim sha1Obj As New System.Security.Cryptography.SHA1CryptoServiceProvider
        Dim bytesToHash() As Byte = System.Text.Encoding.ASCII.GetBytes(strToHash)

        bytesToHash = sha1Obj.ComputeHash(bytesToHash)

        Dim strResult As String = ""

        For Each b As Byte In bytesToHash
            strResult += b.ToString("x2")
        Next

        Return strResult
    End Function

    Function getSha1FileHash(ByVal pathFile As String) As String

        Dim sha1Obj As New System.Security.Cryptography.SHA1CryptoServiceProvider
        Dim bytesToHash() As Byte = ReadFile(pathFile)
        bytesToHash = sha1Obj.ComputeHash(bytesToHash)

        Dim strResult As String = ""

        For Each b As Byte In bytesToHash
            strResult += b.ToString("x2")
        Next

        Return strResult

    End Function

    'Reads a file.
    Public Function ReadFile(ByVal fileName As String) As Byte()
        Dim f As New FileStream(fileName, FileMode.Open, FileAccess.Read)
        Dim size As Integer = Fix(f.Length)
        Dim data(size) As Byte
        size = f.Read(data, 0, size)
        f.Close()
        Return data

    End Function

    Public Sub writeToFile(byteData() As Byte, file As String)

        Dim oFileStream As System.IO.FileStream
        oFileStream = New System.IO.FileStream(file, System.IO.FileMode.Create)
        oFileStream.Write(byteData, 0, byteData.Length)
        oFileStream.Close()

    End Sub

    'Reads a file.
    Public Function ReadTextFile(ByVal fileName As String) As String

        Dim TextFile As New StreamReader(fileName)
        Dim Content As String

        ReadTextFile = ""
        Content = TextFile.ReadLine()

        While Not Content Is Nothing

            ReadTextFile = ReadTextFile & Content
            Content = TextFile.ReadLine()

        End While

        TextFile.Close()


    End Function

    Public Function checkIsTrusted(cnCertificatore As String, dataFirma As Date, tslFromTable As String, tsl_online As String, pathTsl As String, urlTsl As String, Optional countryName As String = "IT") As Boolean

        Dim db As New DbUtil

        checkIsTrusted = False

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
                strSql = "select a.id " & _
                    " from CTL_TrustServiceList a with(nolock) " & _
                    "           left join CTL_Transcodifica b on dztNome = 'CountryName' and Sistema = 'PREFISSI_STATI_EU' and ValOut = CountryName " & _
                    " where deleted = 0 and '" & Replace(strDataFirma, "'", "''") & "' >= StatusStartingTime and '" & Replace(strDataFirma, "'", "''") & "' <= isnull(StatusEndTime,'2999-11-29 01:01:00.000') and FullServiceName = '" & Replace(cnCertificatore, "'", "''") & "' " & _
                    "           and ( isnull(b.ValIn, CountryName) = '" & Replace(countryName, "'", "''") & "' OR isnull(b.ValOut, CountryName) = '" & Replace(countryName, "'", "''") & "' )"

                If (db.init()) Then

                    Dim sqlComm As New SqlCommand(strSql, db.sqlConn)
                    Dim r As SqlDataReader = sqlComm.ExecuteReader()

                    '-- se ritorna dei record
                    If (r.Read() = True) Then

                        checkIsTrusted = True

                    Else

                        checkIsTrusted = False

                    End If

                    r.Close()
                    r = Nothing
                    db.close()
                    sqlComm = Nothing

                End If

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

                            checkIsTrusted = True
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

            db.trace("ERRORE ricerca trusted CA." & ex.Message, "checkIsTrusted()")

        End Try

        Return checkIsTrusted

    End Function



    Public Function IniRead(ByVal FileName As String, ByVal Section As String, ByVal Key As String) As String
        Dim objIniFile As New clsFilesIni(FileName)
        IniRead = objIniFile.GetString(Section, Key, "<Not_Found>")
    End Function

    Public Function getNomeFileFromPath(pathFile As String) As String

        If pathFile = "" Then Return ""

        Dim vett() As String

        vett = Split(pathFile, "\")
        Return vett(UBound(vett))

    End Function

    Private Function CertificateHandler(ByVal sender As Object, ByVal certificate As System.Security.Cryptography.X509Certificates.X509Certificate, ByVal chain As X509Chain, ByVal SSLerror As SslPolicyErrors) As Boolean
        Return True
    End Function

    Public Function invokeService(endPoint As String, soapAction As String, soapEnvelope As String, parametri As List(Of KeyValuePair(Of String, String))) As String

        Dim request As HttpWebRequest = CreateWebRequest(endPoint, soapAction)
        Dim soapEnvelopeXml As New XmlDocument

        '-- questo handler mi permette di evitare errori del tipo : 
        '-- Dettagli eccezione: System.Security.Authentication.AuthenticationException: Il certificato remoto non è stato ritenuto valido dalla procedura di convalida.
        '-- visto tutti gli indirizzi di docER (o almeno quelli di test) avevano questo problema.
        System.Net.ServicePointManager.ServerCertificateValidationCallback = AddressOf CertificateHandler

        soapEnvelope = finalizzaSoapEnvelope(parametri, soapEnvelope)

        soapEnvelopeXml.LoadXml(soapEnvelope)

        Dim stream As Stream = request.GetRequestStream()
        soapEnvelopeXml.Save(stream)

        Dim response As HttpWebResponse = request.GetResponse()
        Dim rd As New StreamReader(response.GetResponseStream())
        Dim soapResult As String = rd.ReadToEnd()

        Return soapResult

    End Function

    Public Function CreateWebRequest(ByVal endPoint As String, ByVal soapAction As String) As HttpWebRequest

        Dim webRequest As HttpWebRequest = Net.WebRequest.Create(endPoint)
        webRequest.ContentType = "application/soap+xml;charset=UTF-8;action=""" & soapAction & """"
        webRequest.Accept = "text/xml"
        webRequest.Method = "POST"
        Return webRequest

    End Function

    Public Function finalizzaSoapEnvelope(parametri As List(Of KeyValuePair(Of String, String)), soapEnvelope As String) As String

        For Each pair As KeyValuePair(Of String, String) In parametri

            Dim key As String = pair.Key
            Dim value As String = pair.Value

            soapEnvelope = Replace(soapEnvelope, "@@@" & key & "@@@", XmlEncode(value))

        Next

        Return soapEnvelope

    End Function

    Public Function XmlEncode(str As String) As String

        Dim s As String = ""
        Dim caratteriAmmessi As String = ""
        Dim i As Integer
        Dim tmp As String = ""
        Dim c As String = ""
        Dim l As Integer

        On Error Resume Next

        caratteriAmmessi = "QWERTYUIOPASDFGHJKLZXCVBNMòàùè%$£€~@ +1234567890'ì:\/!$%()=^{[]}_-?&;.,*+#"

        s = Replace(str, "&", "&amp;")
        s = Replace(s, "<", "&lt;")
        s = Replace(s, ">", "&gt;")
        s = Replace(s, """", "&quot;")
        s = Replace(s, "'", "&apos;")

        l = Len(s)

        For i = 1 To l

            c = Mid(s, i, 1)

            If (AscW(c) < 10) Then
                c = " "
            End If

            If (InStr(1, UCase(caratteriAmmessi), UCase(c)) > 0) Then
                c = c
            Else
                c = "&#" & AscW(c) & ";"
            End If


            tmp = tmp & c

        Next i


        XmlEncode = tmp

        Err.Clear()


    End Function



End Module
