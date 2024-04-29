Public Class ComplexResponseModelType
    Public property esit As Boolean
    Public property out As String
    Public property techvalue As String
    Public property signscounter As Integer = 0
    Public property data As Object = Nothing
    Public sub New(esit As Boolean,out As String,Optional techvalue As String = "")
        Me.esit=esit
        Me.out =out
        Me.techvalue = techvalue
    End sub
End Class
