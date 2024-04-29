Imports System.Text
Imports System

'<System.Runtime.InteropServices.ComVisible(False)> _
Public Class ImageListener : Implements iTextSharp.text.pdf.parser.IRenderListener

    Public imgTxt As String = ""

    Public Sub BeginTextBlock() Implements iTextSharp.text.pdf.parser.IRenderListener.BeginTextBlock

    End Sub

    Public Sub EndTextBlock() Implements iTextSharp.text.pdf.parser.IRenderListener.EndTextBlock

    End Sub

    Public Sub RenderImage(ByVal info As iTextSharp.text.pdf.parser.ImageRenderInfo) Implements iTextSharp.text.pdf.parser.IRenderListener.RenderImage

        'imgTxt = imgTxt + Convert.ToBase64String(info.GetImage.GetImageAsBytes())
        'imgTxt = imgTxt + Encoding.UTF8.GetString(info.GetImage.GetImageAsBytes())
        'imgTxt = Convert.ToBase64String(info.GetImage.GetImageAsBytes())
        'Console.WriteLine(info.GetImage.GetStreamBytes.Length)

        Try
            imgTxt = imgTxt & "" & info.GetImage.GetImageAsBytes.Length
        Catch ex As Exception
            imgTxt = imgTxt & ""
        End Try

    End Sub

    Public Sub RenderText(ByVal info As iTextSharp.text.pdf.parser.TextRenderInfo) Implements iTextSharp.text.pdf.parser.IRenderListener.RenderText

    End Sub

End Class