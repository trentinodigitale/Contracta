Imports System.Data.SqlClient
Imports System.IO

Public Class buste_offerta
    Inherits System.Web.UI.Page

    Dim strConnectionString As String = ConfigurationSettings.AppSettings("db.conn")
    Dim directoryFiles As String = ConfigurationSettings.AppSettings("app.dir_download")

    Dim TotElements As Integer = 0
    Dim CurrentElement As Integer = 0
    Dim NextElement As Integer = 0
    Dim percentage As Integer = 0
    Dim captionCurrentOperation As String = "Generazione pdf..."
    Dim finalResponseType As String = "file"

    Dim mp_idpfu As Integer = 0
    Dim mp_offerta_fittizia As Integer = 0
    Dim isMultiLotto As Boolean = True

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim idGara As String = CStr(Request.QueryString("IDDOC"))
        Dim progress_mode As String = CStr(Request.QueryString("progress_mode"))
        Dim guid As String = CStr(Request.QueryString("acckey")) '--access key tramite guid


        Try

            If String.IsNullOrEmpty(idGara) OrElse Not IsNumeric(idGara) Then
                Throw New Exception("Parametro IDDOC non valido")
            End If

            If String.IsNullOrEmpty(guid) Then
                Throw New Exception("Parametro di accesso obbligatorio")
            End If

            Call getIdpfuFromGuid(guid)

            If mp_idpfu <= 0 Then
                Throw New Exception("Sessione non valida")
            End If

            Select Case UCase(progress_mode)

                'Case "INITGUI"
                '    captionCurrentOperation = "Inizializzazione..."

                Case "START"
                    Call initProgress(idGara)

                Case "STEPS"
                    Call doStep(idGara)

                Case "END"
                    Call endProgress(idGara)

                Case Else
                    Throw New Exception("progress_mode non supportato")

            End Select


            If UCase(progress_mode) <> "END" Then
                Response.ContentType = "application/json"
                Response.Write(getOutput())
            End If
            
        Catch ex As Exception
            Response.ContentType = "application/json"
            Response.Write(getOutput(ex))
        End Try

    End Sub

    Private Sub initProgress(idGara As Integer)

        captionCurrentOperation = "Inizializzazione in corso..."

        '-- 1. ripulisco eventuali vecchi file
        Call pulisciFiles()

        '-- 2. genero l'offerta fittizia sulla quale invocare le stampe
        Call generaOffertaFittizia(idGara)

        '-- 3. Recupero il numero totale dei pdf da genere, ripristino i record come tutti "da fare" ed aggiorno i dati json di output
        Call initElems(idGara, "START")

    End Sub

    Private Sub endProgress(idGara As Integer)

        Dim dirLavoro As String = directoryFiles & mp_idpfu & "_stampe_pdf"

        '-- 1. Unisco tutti i pdf generati fino a questo momento ( tutti i pdf presenti nella cartella presi in ordine di nome file )
        Dim objPDF As New pdf
        Dim esito As String = objPDF.mergePdf(dirLavoro, dirLavoro & "\buste_offerta.pdf")

        If esito <> "" Then
            Throw New Exception("Errore generazione pdf complessivo:" & esito)
        End If

        '-- 2. Diamo il pdf in output

        Dim attach() As Byte = Nothing

        attach = ReadFile(dirLavoro & "\buste_offerta.pdf")

        Response.AddHeader("Cache-control", "no-store")
        Response.AddHeader("Pragma", "no-cache")
        Response.AddHeader("Expires", "0")
        Response.AddHeader("Content-Length", attach.Length.ToString())
        Response.Charset = Nothing
        Response.ContentType = "application/pdf"
        Response.AddHeader("Content-Disposition", "attachment; filename=buste_offerta.pdf")

        Response.BinaryWrite(attach)
        Response.Flush()

        '-- 3. cancelliamo i file temporanei
        Call pulisciFiles()

    End Sub

    Private Sub doStep(idGara As Integer)

        '-- 0. Recupero l'offerta su cui lavorare
        Call getOffertaFittizia(idGara)

        '-- 1. Recupero il prossimo id di pdf da generare ( il primo record con esitoRiga vuoto, gli altri avranno il valore 'pdf' )
        Call initElems(idGara, "STEPS")

        Dim idElem As Integer = getNextElemen()

        If idElem > 0 Then

            '-- 2. genero il pdf
            Dim nomePDF As String = generaPdfSingolo(IIf(isMultiLotto, idElem, mp_offerta_fittizia))

            '-- 4. metto l'elemento come 'fatto'
            Call elemDone(idElem)


        End If

        '-- 5. Aggiorno i contatori per l'output json 
        Call doPercentage()

    End Sub

    Private Sub doPercentage()

        Dim rimanenti As Integer = Me.TotElements - Me.CurrentElement

        percentage = (100 - ((rimanenti / TotElements) * 100))

    End Sub

    Private Sub initElems(idGara As Integer, mode As String)

        'Dim strSQL As String = "select count(id) as lotti from Document_MicroLotti_Dettagli with(nolock) where idheader = " & mp_offerta_fittizia & " and voce = 0"
        Dim strSQL As String = "select a.Divisione_lotti, b.tipodoc, a.TipoBando from Document_Bando a with(nolock) inner join ctl_doc b with(nolock)  on a.idheader = b.id  where b.id =" & idGara

        Dim sqlConn1 = New SqlConnection(strConnectionString)
        sqlConn1.Open()

        Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
        Dim rsDati As SqlDataReader = sqlComm.ExecuteReader()

        If rsDati.Read() Then

            Dim divisioneLotti As String = rsDati("Divisione_lotti")
            Dim tipoDoc As String = rsDati("tipodoc")
            Dim TipoBando As String = rsDati("TipoBando")

            If divisioneLotti.Equals("0") = False Then
                isMultiLotto = True
            Else
                isMultiLotto = False
            End If

            rsDati.Close()

            If isMultiLotto Then

                strSQL = "select count(id) as lotti from Document_MicroLotti_Dettagli with(nolock) where tipoDoc = '" & tipoDoc & "' and idheader = " & idGara & " and voce = 0"
                sqlComm = New SqlCommand(strSQL, sqlConn1)
                rsDati = sqlComm.ExecuteReader()
                rsDati.Read()

                TotElements = rsDati("lotti")

                rsDati.Close()

                If TotElements = 0 Then
                    sqlConn1.Close()
                    Throw New Exception("Nessun lotto da elaborare")
                End If

            Else
                TotElements = 1
            End If

            If mode = "START" Then

                'strSQL = "update Document_MicroLotti_Dettagli set esitoriga = '' where idHeader = " & CStr(mp_offerta_fittizia)
                'sqlComm = New SqlCommand(strSQL, sqlConn1)
                'sqlComm.ExecuteNonQuery()

                'svuto azienda e l'idpfu
                strSQL = "update ctl_doc set azienda = NULL, IdPfu = null, idPfuInCharge = null where id = " & CStr(mp_offerta_fittizia)
                sqlComm = New SqlCommand(strSQL, sqlConn1)
                sqlComm.ExecuteNonQuery()

                If isMultiLotto Then

                    'svuoto i record della microlotti dettagli 
                    strSQL = "delete from Document_MicroLotti_Dettagli where TipoDoc = 'OFFERTA' and IdHeader = " & CStr(mp_offerta_fittizia)
                    sqlComm = New SqlCommand(strSQL, sqlConn1)
                    sqlComm.ExecuteNonQuery()

                    'li reinserisco ( per essere sicuri di averli tutti, a prescindere dai parametri )
                    strSQL = "exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', " & idGara & ", " & mp_offerta_fittizia & ", 'IdHeader', " & _
                                "' Id,IdHeader,TipoDoc,EsitoRiga ', " & _
                                "' Tipodoc=''" & tipoDoc & "'' ', " & _
                                "' TipoDoc, EsitoRiga ', " & _
                                "' ''OFFERTA'' as TipoDoc, '''' as EsitoRiga '," & _
                                "' id '"

                    sqlComm = New SqlCommand(strSQL, sqlConn1)
                    sqlComm.ExecuteNonQuery()

                    '-- popolo la colonna idHeaderLotto e svuoto ValoreImportoLotto
                    strSQL = "update D 		set idheaderLotto = S.id, ValoreImportoLotto = NULL 	from Document_MicroLotti_Dettagli D inner join ( select id, NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where idheader = " & mp_offerta_fittizia & " and voce = 0 and tipodoc = 'OFFERTA' 				) as S on S.NumeroLotto = D.NumeroLotto 	where d.IdHeader = " & mp_offerta_fittizia & " and tipodoc = 'OFFERTA' "

                    sqlComm = New SqlCommand(strSQL, sqlConn1)
                    sqlComm.ExecuteNonQuery()

                    'genero i record per la ctl_doc_section_model
                    strSQL = "insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) select id , 'OFFERTA_BUSTA_ECO' ,  'MODELLI_LOTTI_" & TipoBando & "_MOD_Offerta' from Document_MicroLotti_Dettagli with (nolock) where idHeader = " & mp_offerta_fittizia & " and TipoDoc = 'OFFERTA' and Voce = 0"
                    sqlComm = New SqlCommand(strSQL, sqlConn1)
                    sqlComm.ExecuteNonQuery()

                End If


            End If

        Else

            sqlConn1.Close()
            Throw New Exception("Errore recupero record sulla document_bando")

        End If

        sqlConn1.Close()


    End Sub

    Private Sub elemDone(idElem As String)


        Dim sqlConn1 = New SqlConnection(strConnectionString)
        sqlConn1.Open()

        Dim strSQL As String = "update Document_MicroLotti_Dettagli set esitoriga = 'pdf' where id = " & CStr(idElem)
        Dim sqlComm = New SqlCommand(strSQL, sqlConn1)
        sqlComm.ExecuteNonQuery()

        sqlConn1.Close()


    End Sub

    Private Function getNextElemen() As Integer

        Dim strSQL As String = "select top 1 id, NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where idheader = " & mp_offerta_fittizia & " and voce = 0 and esitoriga = '' order by 1 asc"
        Dim nextElem As Integer = -1

        Dim sqlConn1 = New SqlConnection(strConnectionString)
        sqlConn1.Open()

        Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
        Dim rsDati As SqlDataReader = sqlComm.ExecuteReader()

        If rsDati.Read() Then

            nextElem = rsDati("id")
            Me.CurrentElement = rsDati("NumeroLotto")
            rsDati.Close()

        Else

            '-- consideriamo tutto fatto
            Me.NextElement = Me.TotElements

        End If

        sqlConn1.Close()

        Return nextElem

    End Function

    Private Function getOffertaFittizia(idGara As Integer)

        Dim sqlConn1 = New SqlConnection(strConnectionString)
        sqlConn1.Open()

        Dim strSQL As String = "select top 1 id from ctl_doc with(nolock) where linkeddoc = " & idGara & " and Deleted = 1 and JumpCheck = 'SAMPLE' order by 1 desc"

        Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
        Dim rsDati As SqlDataReader = sqlComm.ExecuteReader()

        If rsDati.Read() Then

            mp_offerta_fittizia = rsDati("id")
            sqlConn1.Close()

        Else

            sqlConn1.Close()
            Throw New Exception("Offerta fittizia non trovata")

        End If


        Return mp_offerta_fittizia

    End Function

    Private Sub generaOffertaFittizia(idGara As Integer)

        Dim strSQL As String = "EXEC OFFERTA_CREATE_FROM_BANDO_GARA " & idGara & ", " & mp_idpfu

        Dim sqlConn1 = New SqlConnection(strConnectionString)
        sqlConn1.Open()

        Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
        Dim rsDati As SqlDataReader = sqlComm.ExecuteReader()

        If rsDati.Read() Then

            mp_offerta_fittizia = rsDati("id")
            rsDati.Close()

            strSQL = "update ctl_doc set Deleted = 1, JumpCheck = 'SAMPLE' where id = " & CStr(mp_offerta_fittizia)
            sqlComm = New SqlCommand(strSQL, sqlConn1)
            sqlComm.ExecuteNonQuery()
            sqlConn1.Close()

        Else

            rsDati.Close()
            sqlConn1.Close()
            Throw New Exception("Errore creazione offerta fittizia")

        End If

    End Sub

    Private Sub pulisciFiles()

        Dim dirLavoro As String = mp_idpfu & "_stampe_pdf"

        DeleteDirectory(directoryFiles & dirLavoro)

    End Sub

    Private Sub DeleteDirectory(path As String)

        Try
            If Directory.Exists(path) Then
                For Each filepath As String In Directory.GetFiles(path)
                    File.Delete(filepath)
                Next

                For Each dir As String In Directory.GetDirectories(path)
                    DeleteDirectory(dir)
                Next
                Directory.Delete(path)
            End If
        Catch ex As Exception
            '-- la pulizia dei file non deve portare ad un errore, se rimangono appesi ci penserà il garbage collector applicativo
        End Try


    End Sub

    Private Function getOutput(Optional errore As Exception = Nothing) As String

        Dim status As String = "OK"
        Dim err_source As String = "null"
        Dim err_desc As String = "null"

        If Not IsNothing(errore) Then

            err_source = errore.Source
            err_desc = errore.Message
            status = "ERROR"

        End If

        Dim outJson As String = "{" & _
            """TotElements"":" & Me.TotElements & "," & _
            """CurrentElement"":" & Me.CurrentElement & "," & _
            """NextElement"":" & Me.NextElement & "," & _
            """percentage"":" & Me.percentage & "," & _
            """captionCurrentOperation"":""" & Me.captionCurrentOperation & """," & _
            """finalResponseType"":""file""," & _
            """currentStatus"":""" & status & """," & _
            """output"":null," & _
            """error"":{" & _
            """source"":""" & err_source & """," & _
            """description"":""" & escapeJson(err_desc) & """" & _
            "}}"

        Return outJson

    End Function

    Public Function escapeJson(str As String) As String

        '--ripulisco i caratteri non ammessi
        escapeJson = NormString(str)

        Dim acapo As String = Chr(13) & Chr(10)

        escapeJson = Replace(escapeJson, "\", "\\")
        escapeJson = Replace(escapeJson, """", "\""")
        escapeJson = Replace(escapeJson, acapo, " ")

    End Function

    Public Function NormString(str As String) As String

        Dim strOk As String = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.:,;''|!""£$%&/()=?^+*§°ç"

        Dim Tmp As String = str

        Dim ValueOut As String = ""

        While Tmp <> ""

            Dim NCH As String = Left(Tmp, 1)

            If InStr(strOk, UCase(NCH)) > 0 Then

                ValueOut = ValueOut & NCH

            End If

            Tmp = Right(Tmp, Len(Tmp) - 1)

        End While

        NormString = ValueOut

    End Function

    Public Sub getIdpfuFromGuid(guid As String)

        Dim sqlConn = New SqlConnection(strConnectionString)
        sqlConn.Open()

        Dim strSql As String = "select idpfu from CTL_ACCESS_BARRIER with(nolock) where guid = '" & Replace(guid, "'", "''") & "' and datediff(SECOND, data,getdate()) <= 30"

        Dim sqlComm As New SqlCommand(strSql, sqlConn)
        Dim rs As SqlDataReader = sqlComm.ExecuteReader()

        If (rs.Read) Then

            mp_idpfu = rs("idpfu")

        End If

        rs.Close()
        sqlConn.Close()
        sqlComm = Nothing
        rs = Nothing
        sqlConn = Nothing

    End Sub

    Private Function generaPdfSingolo(id As Integer) As String

        Dim strSQL As String = ""
        Dim urlPage As String = ""
        Dim typeDoc As String = ""

        If isMultiLotto Then
            strSQL = "select dbo.CNV_ESTESA('#SYS.SYS_WEBSERVERAPPLICAZIONE_INTERNO##SYS.SYS_strVirtualDirectory#/report/OFFERTA_BUSTA_ECO.asp','I') as pageUrl"
            typeDoc = "OFFERTA_BUSTA_ECO"
        Else
            strSQL = "select dbo.CNV_ESTESA('#SYS.SYS_WEBSERVERAPPLICAZIONE_INTERNO##SYS.SYS_strVirtualDirectory#/report/OFFERTA_PRODOTTI.asp','I') as pageUrl"
            typeDoc = "OFFERTA"
        End If

        Dim sqlConn1 = New SqlConnection(strConnectionString)
        sqlConn1.Open()

        Dim sqlComm As New SqlCommand(strSQL, sqlConn1)
        Dim rsDati As SqlDataReader = sqlComm.ExecuteReader()

        If rsDati.Read() Then
            urlPage = rsDati("pageUrl") & "?backoffice=yes&IDDOC=" & id & "&TYPEDOC=" & typeDoc

            If isMultiLotto = False Then
                urlPage = urlPage & "&BUSTA=BUSTA_ECONOMICA"
            End If

        Else
            Throw New Exception("Errore nel recupero dell'indirizzo di stampa")
        End If

        Dim dirLavoro As String = directoryFiles & mp_idpfu & "_stampe_pdf"
        Dim pdfPath As String = dirLavoro & "\" & id & ".pdf"

        If Not Directory.Exists(dirLavoro) Then
            Directory.CreateDirectory(dirLavoro)
        End If

        Try
            '-- diamo al singolo pdf il nome file coincidente con l'ID tabellare, così da renderli sequenziali
            ConvertURLToPDF(urlPage, pdfPath, "", "", "", True)
        Catch ex As Exception
            Throw New Exception("Errore nella generazione del pdf")
        End Try

        Return pdfPath

    End Function

End Class