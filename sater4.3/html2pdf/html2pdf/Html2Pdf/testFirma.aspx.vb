Imports System.Text

Public Class testFirma
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim crypt As New Chilkat.Crypt2()
        Dim success As Boolean

        Dim pathFileP7M As String = "E:\temp\vecchieFirmeAF_con_nuove.pdf.p7m.p7m"
        Dim pathFileEstratto As String = "E:\temp\estratto"

        success = crypt.UnlockComponent("AFSLZN.CBX012020_qnMbzzsEprmC")

        If success Then

            Dim algoritmoHash As String
            Dim n As Integer = 0

            Dim pkcs7Data As New Chilkat.BinData
            pkcs7Data.LoadFile(pathFileP7M)

            While crypt.VerifyP7M(pathFileP7M, pathFileEstratto)


                For i = 0 To crypt.NumSignerCerts - 1

                    Dim json As Chilkat.JsonObject = crypt.LastJsonData
                    json.EmitCompact = False
                    json.Emit()

                    '-- ret examples : sha256, sha1
                    'algoritmoHash = json.StringOf("pkcs7.verify.digestAlgorithms[" & i & "]")
                    'algoritmoHash = json.StringOf("pkcs7.verify.signerInfo[" & i & "].signingAlgOid")
                    'algoritmoHash = json.StringOf("pkcs7.verify.signerInfo[" & i & "].cert.digestAlgName")
                    algoritmoHash = json.StringOf("pkcs7.verify.signerInfo[" & i & "].cert.digestAlgOid")

                    Response.Write("ALGORITMO " & i & " DI FIRMA : " & algoritmoHash)
                    Response.Write("<br/>")

                    Dim dataApposizioneFirma As Date

                    If crypt.HasSignatureSigningTime(i) Then
                        dataApposizioneFirma = crypt.GetSignatureSigningTime(i)
                    Else
                        dataApposizioneFirma = Nothing
                    End If

                    'Response.Write("ALGORITMO " & n & " DI FIRMA : " & crypt.OaepHash)
                    Response.Write("DATA APPOSIZIONE FIRMA " & i & " : " & dataApposizioneFirma)
                    Response.Write("<br/><br/><br/>")

                    'Dim sbJson As New Chilkat.StringBuilder
                    'Dim boolTest As Boolean = crypt.GetSignedAttributes(i, pkcs7Data, sbJson)

                    Dim revoked As Integer = New sign.Utils().verificaRevocaChilkat(crypt.GetSignerCert(i))

                    pathFileP7M = pathFileEstratto
                    pathFileEstratto = pathFileEstratto & "_" & n + i

                Next

                n += 1

            End While

            pkcs7Data.Dispose()
            pkcs7Data = Nothing
            crypt.Dispose()
            crypt = Nothing



            'success = crypt.VerifyP7M(pathFileP7M, pathFileEstratto)

            'If success Then

            '    '  Get each signer's signature digest.

            '    '  Load the .p7m into memory...
            '    Dim pkcs7Data As New Chilkat.BinData
            '    pkcs7Data.LoadFile(pathFileP7M)

            '    '  Check to see if this .p7m contains the binary bytes, or if it's
            '    '  already base64 encoded.  Get the 1st two bytes.  If the first two
            '    '  bytes are the us-ascii values "MI", then we have base64.
            '    Dim sbBase64 As New Chilkat.StringBuilder
            '    Dim hexStr As String = pkcs7Data.GetEncodedChunk(0, 2, "hex")
            '    sbBase64.Append(hexStr)


            '    Dim bHaveBase64 As Boolean = False
            '    If (sbBase64.ContentsEqual("4D49", True) = True) Then
            '        bHaveBase64 = True
            '        sbBase64.Clear()
            '        sbBase64.AppendBd(pkcs7Data, "utf-8", 0, 0)
            '    End If

            '    crypt.EncodingMode = "base64"
            '    Dim i As Integer = 0
            '    Dim digest As String

            '    While i < crypt.NumSignerCerts

            '        If (bHaveBase64) Then
            '            digest = crypt.Pkcs7ExtractDigest(i, sbBase64.GetAsString())
            '        Else
            '            digest = crypt.Pkcs7ExtractDigest(i, pkcs7Data.GetEncoded("base64"))
            '        End If

            '        If (crypt.LastMethodSuccess <> True) Then
            '            Response.Write(crypt.LastErrorText)
            '            Exit Sub
            '        End If

            '        Response.Write("Signer " & (i + 1) & " digest = " & digest)
            '        Response.Write("<br/>")
            '        i = i + 1

            '    End While



        Else

            Response.Write("errore." & crypt.LastErrorText)

        End If


    End Sub

End Class