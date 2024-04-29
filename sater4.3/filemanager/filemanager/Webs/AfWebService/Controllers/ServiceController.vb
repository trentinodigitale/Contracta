Imports System.Web.Mvc

Namespace Controllers
    Public Class ServiceController
        Inherits Controller

        Function Index As ActionResult
            Return Json(New With{.status = "OK", .servertime = Date.Now.ToString("o")},JsonRequestBehavior.AllowGet)
        End Function

        <Route("service/1.0/{fx}")>
        function service_rest(fx As String,type As String) As JsonResult
            Dim ret As New JsonResultModelType
            Try
                Select Case fx
                    Case "enqueaction"          'ACCODA UNA OPERAZIONE PER IL SERVIZIO

                End Select
            Catch ex As Exception
                ret.esit=False
                ret.message= ex.Message
            End Try

            Return Json(ret,JsonRequestBehavior.AllowGet)
        End function
    End Class
End Namespace