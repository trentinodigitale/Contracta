Namespace COMVerificaEstesaFirma

    Public Class AFLinkSign

        Public Sub New()

        End Sub

        Public Function firmaEstesaCOM(mode As String, pdf As String, isSigned As String, signedfile As String, att_hash As String, attIdMsg As String, attOrderFile As String, attIdObj As String, idAzi As String) As String
            firmaEstesaCOM = New pdf().firmaEstesaCOM(mode, pdf, isSigned, signedfile, att_hash, attIdMsg, attOrderFile, attIdObj, idAzi)
        End Function

    End Class

End Namespace
