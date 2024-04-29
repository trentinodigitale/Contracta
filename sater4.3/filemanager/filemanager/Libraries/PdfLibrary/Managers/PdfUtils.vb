Imports System.Configuration
Imports System.Data.SqlClient
Imports System.Security.Cryptography.X509Certificates
Imports EvoPdf
Imports iTextSharp.text.pdf
Imports iTextSharp.text.pdf.parser
Imports iTextSharp.text.pdf.security
Imports Org.BouncyCastle.Cms
Imports Org.BouncyCastle.X509
Imports Org.BouncyCastle.X509.Store
Imports StorageManager

Public Class PdfUtils

    ''' <summary>
    ''' Calcolo dell'HASH di un file PDF basato sul contenuto partendo da un file su Disco
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="filepath">percorso del file</param>
    ''' <param name="Signed">File firmato o no</param>
    ''' <returns></returns>
    Public Shared Function GetPdfHash(Dbm As CTLDB.DatabaseManager, filepath As String, Signed As Boolean) As String
        Dim B As BlobEntryModelType = BlobManager.create_blob_from_file(Dbm,filepath,"",False)
        return GetPdfHash(Dbm,B,False)
    End Function
    ''' <summary>
    ''' Calcolo dell'HASH di un file PDF basato sul contenuto partendo da un BLOG
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="Signed"></param>
    ''' <returns></returns>
    Public Shared Function GetPdfHash(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, Signed As Boolean, Optional filePath As String = "", Optional bControlloOnlyHash As Boolean = False) As String
        Return GetPdfHash_10(Dbm, B, Signed, filePath, bControlloOnlyHash)
    End Function

    Private Shared Function GetPdfHash_10(Dbm As CTLDB.DatabaseManager, B As BlobEntryModelType, Signed As Boolean, Optional filePath As String = "", Optional bControlloOnlyHash As Boolean = False) As String
        Dim i As Integer
        Dim resp As String = ""

        If String.IsNullOrEmpty(filePath) AndAlso Not B.size > 0 Then
            resp = "0#File a taglia 0"
        Else
            Try

                Dim ClearFile As String

                If String.IsNullOrEmpty(filePath) Then
                    ClearFile = BlobManager.GetPureFileOnDisk(Dbm, B, True)
                Else

                    ClearFile = filePath

                    If My.Computer.FileSystem.FileExists(ClearFile) = False Then
                        Throw New Exception("PDF non trovato sul file system")
                    End If

                    If My.Computer.FileSystem.GetFileInfo(ClearFile).Length = 0 Then
                        Throw New Exception("File a taglia 0")
                    End If

                End If

                Using reader As PdfReader = New PdfReader(ClearFile)

                    Dim parser As PdfReaderContentParser = New PdfReaderContentParser(reader)
                    'Dim out As IO.StreamWriter = New IO.StreamWriter(txt, False, System.Text.Encoding.ASCII)
                    Dim out As String

                    Dim totAnnotation As Integer = 0
                    Dim totExtra As Integer = 0
                    out = ""

                    'Se il file dovrebbe essere firmato, ma in realtà non lo è, restituiamo errore
                    If Signed And reader.AcroFields.GetSignatureNames.Count = 0 And bControlloOnlyHash = False Then
                        parser = Nothing
                        reader.Close()

                        'Ritorno un messaggio diverso di errore a seconda della presenza dello sviluppo certification_33216
                        Dim cert_req_33215 As String = "0"

                        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("select dbo.PARAMETRI('CERTIFICATION','certification_req_33216','Visible','0', -1) as val_flag", Nothing)
                            If dr.Read Then
                                cert_req_33215 = dr("val_flag")
                            End If
                        End Using


                        If cert_req_33215 = "0" Then
                            Return "0#Il file non e' firmato digitalmente"
                        Else
                            Return "0#Attenzione il file inserito non risulta firmato digitalmente"
                        End If

                    End If

                        For i = 1 To reader.NumberOfPages
                        Try
                            out = out & parser.ProcessContent(i, New SimpleTextExtractionStrategy()).GetResultantText()
                            out = out & parser.ProcessContent(i, New ImageListener()).imgTxt

                            Dim pageDict As PdfDictionary = reader.GetPageN(i)
                            '-- Recupero il numero di annotations utilizzate ( area di testo aggiunte, disegni, sottolineature, figure etc)
                            totAnnotation += fx_count_pdf_Annotation(pageDict, PdfName.ANNOTS)
                            '-- Tutti questi extra sembrano essere sempre a 0. L'unica collezione corretta sembra essere la annots
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.HIGHLIGHT)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.ARTBOX)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.EMBEDDEDFILES)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.VIDEO)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.ANIMATION)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.CIRCLE)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.POLYLINE)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.POLYGON)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.POLYGON)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.FIGURE)
                            totExtra += fx_count_pdf_Annotation(pageDict, PdfName.FREETEXT)
                            'totExtra = totExtra + pageDict.GetAsArray(PdfName.ALL).Size
                            totAnnotation += totExtra
                        Catch ex As Exception
                            Dbm.RegisterLogError("Error On Page :" & i & " : " & ex.Message, "/AF_WebFileManager/", "errore generazione pdf hash")
                            Throw New Exception("Errore Durante il calcolo dell'hash PDF")
                        End Try
                    Next
                    If totAnnotation > 0 Then
                        '-- tolgo dal totale il numero di firme embedded (vengono viste come annotations del pdf)
                        totAnnotation = totAnnotation - reader.AcroFields.GetSignatureNames.Count
                    End If


                    'On Error Resume Next

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
                    resp = "1#" & AfCommon.Tools.HashTools.getSHA1Hash(Trim(out), True)
                    '-- Se sono presenti 'aggiunte' al file pdf aggiungo il loro numero in coda all'hash
                    If totAnnotation > 0 Then
                        resp = resp & "-" & CStr(totAnnotation)
                    End If
                    Dbm.TraceDB("Risposta dal metodo parsePdf() per il file " & B.filename & " : " & resp, "parsePdf()")
                    parser = Nothing
                    reader.Close()
                    'reader = Nothing

                End Using

                '-- non cancelliamo il file dal file system se si proviene da una generazione pdf hash su un file già presente a sistema
                If String.IsNullOrEmpty(filePath) Then
                    My.Computer.FileSystem.DeleteFile(ClearFile)
                End If

            Catch ex As Exception
                Dbm.TraceDB("Risposta dal metodo parsePdf() per il file " & B.filename & " : 0#" & ex.Message, "parsePdf()")
                resp = CStr("0#" & CStr(ex.Message))
            End Try
        End If
        Return resp
    End Function

    Private shared Function fx_count_pdf_Annotation(pageDict As PdfDictionary,key As PdfName) As Long
        If Not IsNothing(pageDict)
            Dim annArray As PdfArray = pageDict.GetAsArray(key)
            If Not IsNothing(annArray)
                Return annArray.Size
            End If
        End If
        Return 0
    End Function
    ''' <summary>
    ''' Generazione di un file PDF
    ''' </summary>
    ''' <param name="query"></param>
    ''' <returns></returns>
    Public Shared Function generaPdf(jobid As String, query As Hashtable) As String
        Try
            Dim url As String
            Dim pdf As String
            Dim pageSize As String
            Dim pageOrientation As String
            Dim fitWith As String
            Dim isPdfA As Boolean = False

            Dim footerKey As String = ""
            Dim lngPrefix As String = ""
            Dim mediaType As String = ""

            '-- Controllo sui parametri obbligatori
            If (query("url") = Nothing Or query("pdf") = Nothing) Then
                Return "0#Parametro url o pdf mancanti"
            End If
            'url = UrlDecode(Request.QueryString("url")) 'url che ci restituirà la pagina html
            'url = Server.UrlDecode(Request.QueryString("url"))
            url = CStr(query("url"))
            pdf = query("pdf") 'percorso completo di nome del file pdf da generare
            '-- Parametri opzionali 
            pageSize = query("pagesize")
            pageOrientation = query("pageorientation")
            fitWith = query("fitwith")

            footerKey = CStr(query("ml_footer"))
            lngPrefix = CStr(query("lng_prefix"))
            mediaType = CStr(query("media_type"))

            If (UCase(CStr(query("PDF_A"))) = "YES" Or CStr(query("PDF_A")) = "1") Then
                isPdfA = True
            End If

            If lngPrefix = "" Then
                lngPrefix = "I"
            End If

            If mediaType = "" Then
                mediaType = "screen"
            End If

            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                Dbm.AppendOperation("Generating Pdf from :" & url)
            End Using

            Dim buffer As Byte() = url_to_pdf(url, pageSize, pageOrientation, fitWith, isPdfA, footerKey, lngPrefix, mediaType) 'scrive il pdf creato a partire dalla pagina html sul percorso specificato

            Using Dbm As New CTLDB.DatabaseManager(False, Nothing, "", jobid, jobid)
                Dbm.AppendOperation("Pdf Generation Complete")
            End Using

            My.Computer.FileSystem.WriteAllBytes(pdf, buffer, False)

            Return "1#File pdf generato con successo"

        Catch ex As Exception
            Return "0#errore ( " & 0 & " ) : " & ex.Message
        End Try
    End Function
    ''' <summary>
    ''' Url di una pagina in pdf con la libreria evopdf
    ''' </summary>
    ''' <param name="url"></param>
    ''' <param name="pageSize"></param>
    ''' <param name="pageOrientation"></param>
    ''' <param name="fitWidth"></param>
    ''' <param name="isPdfA"></param>
    ''' <param name="footerKey"></param>
    ''' <param name="lngPrefix"></param>
    ''' <param name="mediaType"></param>
    ''' <param name="strHtmlFooterPaging"></param>
    ''' <returns></returns>
    Private shared function url_to_pdf(url As String, pageSize As String, pageOrientation As String, fitWidth As String, _
                                            isPdfA As Boolean, Optional footerKey As String = "", Optional lngPrefix As String = "I", Optional mediaType As String = "screen", _
                                            Optional strHtmlFooterPaging As String = "") As Byte()
        ' PDF converter. Può prendere come parametro l'html width del foglio
        ' Il default with per l'HTML viewer è di 1024 pixels.
        Dim pdfConverter As New PdfConverter()
        ' license key
        pdfConverter.LicenseKey = afcommon.statics.evo_pdf_7_5_licenceKey
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

        If Not String.IsNullOrWhiteSpace(pageSize)
            Dim names As String() = System.Enum.GetNames(gettype(PdfPageSize))
            Dim values As PdfPageSize() = System.Enum.GetValues(gettype(PdfPageSize))
            For i As Integer = 0 To values.Length -1
                If names(i).ToLower = pageSize.ToLower
                    pdfConverter.PdfDocumentOptions.PdfPageSize = values(i)
                    Exit For
                End If
            Next
        End If
        pdfConverter.PdfDocumentOptions.PdfPageOrientation = PdfPageOrientation.Portrait
        If Not String.IsNullOrWhiteSpace(pageOrientation)
            Select Case pageOrientation.ToUpper
                Case "PORTRAIT"
                    pdfConverter.PdfDocumentOptions.PdfPageOrientation = PdfPageOrientation.Portrait
                Case "LANDSCAPE"
                    pdfConverter.PdfDocumentOptions.PdfPageOrientation = PdfPageOrientation.Landscape
            End Select
        End If
        Select Case fitWidth
            Case "NO","0"
                pdfConverter.PdfDocumentOptions.FitWidth = False
        End Select
        pdfConverter.PdfDocumentOptions.PdfCompressionLevel = PdfCompressionLevel.Normal
        pdfConverter.PdfDocumentOptions.ShowHeader = False
        pdfConverter.PdfDocumentOptions.EmbedFonts = True
        pdfConverter.PdfDocumentOptions.LiveUrlsEnabled = False
        pdfConverter.JavaScriptEnabled = True
        pdfConverter.InterruptSlowJavaScript = True
        pdfConverter.PdfConverterConcurrencyLevel = -1
        pdfConverter.PdfDocumentOptions.JpegCompressionEnabled = True
        If Not String.IsNullOrWhiteSpace(footerKey)
            '-- AGGIUNGO LA PAGINAZIONE AUTOMATICA SFRUTTANDO UN FOOTER HTML AGGIUNTO MANUALMENTE
            Dim footerHeight As Integer = 20
            Dim ml_key As String = footerKey
            '-- se footerKey contiene @@@ mi aspetto una forma del tipo 20@@@ML_FOOTER_PDF_PAGING
            If footerKey.Contains("@@@") Then                
                Dim vet() As String = footerKey.Trim.Split("@@@")
                If vet.Length > 0
                    footerHeight = CInt(vet(0))
                Else
                    footerHeight = 20
                End If
                If vet.Length > 1
                    ml_key = CInt(vet(1))
                End If              
            End If
            If String.IsNullOrWhiteSpace(lngPrefix) Then
                lngPrefix = "IT"
            End If
            If Not String.IsNullOrWhiteSpace(strHtmlFooterPaging)
                pdfConverter.PdfDocumentOptions.ShowFooter = True
                'pdfConverter.PdfDocumentOptions.BottomSpacing = 1
                pdfConverter.PdfFooterOptions.FooterHeight = 20
                Dim footerHtmlWithPageNumbers As New HtmlToPdfVariableElement(strHtmlFooterPaging, "")
                'footerHtmlWithPageNumbers.FitHeight = True
                pdfConverter.PdfFooterOptions.AddElement(footerHtmlWithPageNumbers)
                'Aggiungere test per mettere o meno la linea di separazione per il footer
                'If True Then
                'Dim footerWidth As Single = pdfConverter.PdfDocumentOptions.PdfPageSize.Width - pdfConverter.PdfDocumentOptions.LeftMargin - pdfConverter.PdfDocumentOptions.RightMargin
                'Dim footerLine As New LineElement(0, 0, footerWidth, 0)
                'pdfConverter.PdfFooterOptions.AddElement(footerLine)
                'End If
            End If
            '-- FINE GESTIONE AUTOMATICA PAGINAZIONE
        Else
            pdfConverter.PdfDocumentOptions.ShowFooter = False
        End If
        pdfConverter.HttpRequestCookies.Clear()
        '-- il default della libreria è screen, ma in alcuni contesti può esserci utile passa print per fargli prendere i css che hanno media type print
        pdfConverter.MediaType = mediaType
        Dim buffer As Byte() = Nothing
        Using ms As New System.IO.MemoryStream
            pdfConverter.SavePdfFromUrlToStream(url,ms)
            buffer = ms.ToArray
        End Using
        pdfConverter = Nothing        
        Return buffer
    End Function


    ''' <summary>
    ''' Estrae il contenuto dai un file P7M partendo da un Blob
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="SaveToDb"></param>
    ''' <returns></returns>
    Public shared function ExtractP7M(Dbm As CTLDB.DatabaseManager,B As BlobEntryModelType,SaveToDb As Boolean) As BlobEntryModelType             
        Dim source_tempfile As String  = BlobManager.GetPureFileOnDisk(Dbm,B,True)
        Dim target_file As String = CTLDB.DatabaseManager.GetTempFileName
        Dim fname As String = B.filename
        ExtractP7M(Dbm,source_tempfile,target_file,fname)
        My.Computer.FileSystem.DeleteFile(source_tempfile)
        Dim RET As BlobEntryModelType = BlobManager.create_blob_from_file(Dbm,target_file,fname,SaveToDb)
        My.Computer.FileSystem.DeleteFile(target_file)
        'BlobManager.fx_calculate_hash(Dbm,RET)
        Return RET
    End function
    ''' <summary>
    ''' ''' Estrae il contenuto dai un file P7M partendo da un file su disco
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="source_filename"></param>
    ''' <param name="target_file"></param>
    ''' <param name="filename"></param>
    ''' <param name="recursive"></param>
    ''' <returns></returns>

    Private Shared Function ExtractP7MBouncy(Dbm As CTLDB.DatabaseManager, source_filename As String, target_file As String, ByRef filename As String, Optional recursive As Boolean = False) As Long
        Try

            Dim signedfile As CmsSignedData = Nothing
            Using fs As New System.IO.FileStream(source_filename, IO.FileMode.Open)
                signedfile = New CmsSignedData(fs)
            End Using
            Dim certStore As IX509Store = signedfile.GetCertificates("Collection")
            Dim certs As ICollection = certStore.GetMatches(New X509CertStoreSelector())
            Dim signerStore As SignerInformationStore = signedfile.GetSignerInfos()
            Dim signers As ICollection = signerStore.GetSigners()
            For Each tempCertification In certs
                Dim certification As Org.BouncyCastle.X509.X509Certificate = CType(tempCertification, Org.BouncyCastle.X509.X509Certificate)
                For Each tempSigner In signers
                    Dim signer As SignerInformation = CType(tempSigner, SignerInformation)
                    'If Not signer.Verify(certification.GetPublicKey())
                    '    Dbm.RunException("Invalid Signer")
                    'End If
                Next
            Next
            'SAVE NEW FILE
            Using fsout As New System.IO.FileStream(target_file, IO.FileMode.Create, IO.FileAccess.Write)
                signedfile.SignedContent.Write(fsout)
                filename = filename.Substring(0, filename.LastIndexOf(".", StringComparison.Ordinal))
            End Using
            Return ExtractP7MBouncy(Dbm, target_file, target_file, filename, True)

        Catch ex As Exception
            If Not recursive Then
                Throw ex
                'Dbm.RunException(ex.Message, ex)
            Else
                target_file = source_filename
            End If
        End Try

        Return New System.IO.FileInfo(target_file).Length

    End Function

    Private Shared Function ExtractP7MChilkat(Dbm As CTLDB.DatabaseManager, source_filename As String, target_file As String, ByRef filename As String, Optional recursive As Boolean = False) As Long

        Try

            Dim crypt As New Chilkat.Crypt2()
            Dim verificaP7mChilkat As Boolean = False

            MainUtils.UnlockChilkat(Dbm)

            Dim success As Boolean = crypt.VerifyP7M(source_filename, target_file)

            If success Then
                Return ExtractP7MChilkat(Dbm, target_file, target_file, filename, True)
            Else

                Throw New Exception("Busta P7M non valida." & crypt.LastErrorText)

            End If

        Catch ex As Exception

            If Not recursive Then
                Dbm.RunException(ex.Message, ex)
            Else
                target_file = source_filename
            End If

        End Try

        Return New System.IO.FileInfo(target_file).Length

    End Function

    Public Shared Function ExtractP7M(Dbm As CTLDB.DatabaseManager, source_filename As String, target_file As String, ByRef filename As String, Optional recursive As Boolean = False) As Long

        Try
            Dbm.AppendOperation("Chiamata a ExtractP7MBouncy")
            Return ExtractP7MBouncy(Dbm, source_filename, target_file, filename, recursive)
        Catch ex As Exception
            Dbm.AppendOperation("Chiamata a ExtractP7MChilkat")
            Return ExtractP7MChilkat(Dbm, source_filename, target_file, filename, recursive)
        End Try

    End Function

    ''' <summary>
    ''' Verifica firma PDF
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="Att_Hash"></param>
    ''' <param name="attIdMsg"></param>
    ''' <param name="attOrderFile"></param>
    ''' <param name="attIdObj"></param>
    ''' <param name="idAzi"></param>
    ''' <param name="firmeMultipleIncrociate"></param>
    ''' <returns></returns>
    Public shared function verifyPdfSigned(Dbm As CTLDB.DatabaseManager,B As BlobEntryModelType, _
                                           Att_Hash As String, attIdMsg As String, attOrderFile As String, attIdObj As String, idAzi As String, _
                                           Optional firmeMultipleIncrociate As Boolean = False) As AfCommon.ComplexResponseModelType
        Dim SU As New sign.Utils(Dbm)
        If Not String.IsNullOrWhiteSpace(Att_Hash)
            SU.ATT_Hash = Att_Hash
        End If
        If Not String.IsNullOrWhiteSpace(attIdMsg)
            SU.attIdMsg = attIdMsg
        End If
        If Not String.IsNullOrWhiteSpace(attOrderFile)
            SU.attOrderFile = attOrderFile
        End If
        If Not String.IsNullOrWhiteSpace(attIdObj)
            SU.attIdObj = attIdObj
        End If
        If Not String.IsNullOrWhiteSpace(idAzi)
            SU.idAzi = idAzi
        End If
        return SU.verifyPdfSigned(B,firmeMultipleIncrociate)
    End function


    ''' <summary>
    ''' Verifica firma P7M
    ''' </summary>
    ''' <param name="Dbm"></param>
    ''' <param name="B"></param>
    ''' <param name="Att_Hash"></param>
    ''' <param name="attIdMsg"></param>
    ''' <param name="attOrderFile"></param>
    ''' <param name="attIdObj"></param>
    ''' <param name="idAzi"></param>
    ''' <param name="firmeMultipleIncrociate"></param>
    ''' <returns></returns>
    Public shared function verifyP7MSigned(Dbm As CTLDB.DatabaseManager,B As BlobEntryModelType, _
                                           Att_Hash As String, attIdMsg As String, attOrderFile As String, attIdObj As String, idAzi As String, _
                                           Optional firmeMultipleIncrociate As Boolean = False) As AfCommon.ComplexResponseModelType
        Dim SU As New sign.Utils(Dbm)
        If Not String.IsNullOrWhiteSpace(Att_Hash)
            SU.ATT_Hash = Att_Hash
        End If
        If Not String.IsNullOrWhiteSpace(attIdMsg)
            SU.attIdMsg = attIdMsg
        End If
        If Not String.IsNullOrWhiteSpace(attOrderFile)
            SU.attOrderFile = attOrderFile
        End If
        If Not String.IsNullOrWhiteSpace(attIdObj)
            SU.attIdObj = attIdObj
        End If
        If Not String.IsNullOrWhiteSpace(idAzi)
            SU.idAzi = idAzi
        End If
        return SU.verifyP7M(B,firmeMultipleIncrociate)
    End function

End Class
