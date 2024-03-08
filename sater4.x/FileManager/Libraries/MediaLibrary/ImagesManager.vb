Imports System.Drawing
Imports System.Drawing.Drawing2D
Imports System.Drawing.Imaging
Imports System.IO

Public Class ImagesManager
    Public Class ImageResultModelType
        Public Property extension As String
        Public Property contenttype As String
        Public Property buffer As Byte()
    End Class

    Public Shared Function resizeimage(buffer As Byte(), width As Integer?, height As Integer?, cachefolder As String) As Byte()
        Dim RET As ImagesManager.ImageResultModelType = ImagesManager.fx_get_image(buffer, width, height, String.Empty,String.Empty,".jpg")
        Return RET.buffer
    End Function


    Private Shared Function fx_get_image(input As Byte(), w As Integer?, h As Integer?, switch As String, bgcolor As String, extension As String) As ImageResultModelType
        If Not w.HasValue Then w = 0
        If Not h.HasValue Then h = 0

        Dim RET As New ImageResultModelType
        'Try
        With RET
            Select Case extension.Trim(".").ToLower
                Case "png"
                    .contenttype = "image/png"
                Case "tif"
                    .contenttype = "image/tif"
                Case "bmp"
                    .contenttype = "image/bmp"
                Case "jpg", "jpeg"
                    .contenttype = "image/jpeg"
            End Select
        End With


        Using IMAGEFX As New ImageTools(input)
            If w.Value = 0 AndAlso h.Value = 0
                If Not RET.contenttype = "application/octet-stream" Then
                    RET.contenttype = "image/png"
                End If
                RET.buffer = input
            Else
                If String.IsNullOrEmpty(switch)
                    Dim filled As Boolean = h.Value > 0 AndAlso w.Value > 0
                    RET.buffer = IMAGEFX.GetImage(w.Value, h.Value, True, filled, True, "", ImageTools.quality.High, extension.ToString)
                ElseIf String.IsNullOrWhiteSpace(bgcolor) OrElse switch = "s"
                    Select Case switch.ToLower
                        Case "s"
                            RET.buffer = ResizeImage_new(input, w, h, bgcolor)
                        Case "ad"
                            'CENTRA L'IMMAGINE IN UN RETTANGOLO AVENTE LE MISURE ESATTE
                            Dim InputImage As Global.System.Drawing.Image = Global.System.Drawing.Image.FromStream(New Global.System.IO.MemoryStream(input))
                            If h = 0 Then h = w
                            If w = 0 Then w = h
                            'TROVO LE MISURE PER L'IMMAGINE per il resize iniziale
                            Dim h_ratio As Double = h / InputImage.Height
                            Dim w_ratio As Double = w / InputImage.Width

                            Dim newH As Double = 0
                            Dim newW As Double = 0
                            If h_ratio > w_ratio
                                newH = w_ratio * InputImage.Height
                                newW = w_ratio * InputImage.Width
                            Else
                                newH = h_ratio * InputImage.Height
                                newW = h_ratio * InputImage.Width
                            End If
                            Dim newinput As Byte() = IMAGEFX.GetImage(w, h, True, True, True, bgcolor, ImageTools.quality.High, extension.ToString)

                            RET.buffer = newinput


                        Case "w"
                            'PRENDE IL CENTRO DELL'IMMAGINE
                            If w.Value = 0 Then w = h.Value
                            If h.Value = 0 Then h = w.Value
                            RET.buffer = GetImageZoomStretch(input, w.Value, h.Value)
                        Case "t"
                            'ATTESTA L'IMMAGINA NELLA PARTE ALTA
                            RET.buffer = IMAGEFX.GetImage(w.Value, h.Value, True, True, False, "", ImageTools.quality.High, extension.ToString, True)
                        Case "vc"
                            'TAGLIA L'IMMAGINE IN VERTICARE SE SUPERA L'ALTEZZA (Vertical CUT)
                            RET.buffer = IMAGEFX.GetImage(w.Value, h.Value, True, True, False, "", ImageTools.quality.High, extension.ToString, False, , True)
                        Case "hc"
                            RET.buffer = IMAGEFX.GetImage(w.Value, h.Value, True, True, False, "", ImageTools.quality.High, extension.ToString, False, , False, True)
                        Case "ac"
                            Dim im As Image = System.Drawing.Image.FromStream(New IO.MemoryStream(input))
                            If im.Height > im.Width Then
                                switch = "vc"
                            Else
                                switch = "hc"
                            End If
                            Return fx_get_image(input, w, h, switch, bgcolor, extension)
                        Case Else
                            'SOLO RESIZE
                            RET.buffer = IMAGEFX.GetImage(w.Value, h.Value, True, False, False, "", ImageTools.quality.High, extension.ToString,,)
                    End Select
                Else
                    'JOIN IMAGES
                    If switch = "bg" Then
                        'RET.buffer = IMAGEFX.GetImage(w.Value,h.Value, True, True,True,bgcolor, Auxesia.ImageTools.quality.High, extension.ToString)
                        RET.buffer = ResizeImage_new(input, w.Value, h.Value, bgcolor)
                    Else
                        'NON TRATTA L'IMMAGINE MA FA IL RESIZE E LO STRETCH
                        'RET.buffer = IMAGEFX.GetImage(w.Value,h.Value, False, True, True, "", Auxesia.ImageTools.quality.High, extension.ToString)
                        RET.buffer = ResizeImage_new(input, w.Value, h.Value, bgcolor)
                    End If
                End If
            End If
        End Using

        Return RET
    End Function

    Private Shared Function GetImageZoomStretch(inputimage() As Byte, ByVal maxW As Integer, ByVal maxH As Integer) As Byte()
        Dim buffer() As Byte = Nothing
        Using istream As New MemoryStream(inputimage)
            Using imgTmp As Bitmap = CType(System.Drawing.Image.FromStream(istream), Bitmap)
                Dim ratio As Double = 0
                If imgTmp.Width < imgTmp.Height Then
                    ratio = maxW / imgTmp.Width
                    If (CInt(imgTmp.Height * ratio) < maxH) Then
                        ratio = maxH / imgTmp.Height
                    End If
                Else
                    ratio = maxH / imgTmp.Height
                    If (CInt(imgTmp.Width * ratio) < maxW) Then
                        ratio = maxW / imgTmp.Width
                    End If
                End If
                Dim resizeW As Integer = CInt(imgTmp.Width * ratio)
                Dim resizeH As Integer = CInt(imgTmp.Height * ratio)

                Using resized As Bitmap = New Bitmap(resizeW, resizeH, PixelFormat.Format24bppRgb)
                    resized.SetResolution(imgTmp.HorizontalResolution, imgTmp.VerticalResolution)
                    Dim g As Graphics = Graphics.FromImage(resized)
                    Dim fill As Brush = New SolidBrush(Color.White)
                    g.FillRectangle(fill, 0, 0, resizeW, resizeH)
                    g.CompositingQuality = CompositingQuality.HighQuality
                    g.SmoothingMode = SmoothingMode.HighQuality
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic
                    g.CompositingQuality = CompositingQuality.HighQuality
                    g.DrawImage(imgTmp, 0, 0, resizeW, resizeH)
                    g.Dispose()

                    Dim cropX As Integer = 0
                    Dim cropY As Integer = 0
                    If resizeW > maxW Then
                        cropX = (resizeW - maxW) / 2
                    End If
                    If resizeH > maxH Then
                        cropY = (resizeH - maxH) / 2
                    End If

                    Dim rect As Rectangle = New Rectangle(cropX, cropY, maxW, maxH)
                    Using cropped As Bitmap = resized.Clone(rect, resized.PixelFormat)
                        Using oStream As New MemoryStream()
                            cropped.Save(oStream, ImageFormat.Jpeg)
                            buffer = oStream.ToArray()
                        End Using
                    End Using
                End Using
            End Using
        End Using
        Return buffer
    End Function


    Private Shared Function ResizeImage_new(input As Byte(), ByVal Width As Integer, ByVal Height As Integer, bgcolor As String) As Byte()

        Dim ret As Byte() = Nothing
        Using imgPhoto As Bitmap = Bitmap.FromStream(New System.IO.MemoryStream(input))
            If Width = 0 Then Width = imgPhoto.Width
            If Height = 0 Then Height = imgPhoto.Height

            Dim sourceWidth As Integer = imgPhoto.Width
            Dim sourceHeight As Integer = imgPhoto.Height
            Dim sourceX As Integer = 0
            Dim sourceY As Integer = 0
            Dim destX As Integer = 0
            Dim destY As Integer = 0
            Dim nPercent As Single = 0
            Dim nPercentW As Single = 0
            Dim nPercentH As Single = 0
            nPercentW = (CSng(Width) / CSng(sourceWidth))
            nPercentH = (CSng(Height) / CSng(sourceHeight))

            If nPercentH < nPercentW Then
                nPercent = nPercentH
                destX = System.Convert.ToInt16((Width - (sourceWidth * nPercent)) / 2)
            Else
                nPercent = nPercentW
                destY = System.Convert.ToInt16((Height - (sourceHeight * nPercent)) / 2)
            End If
            Dim destWidth As Integer = CInt((sourceWidth * nPercent))
            Dim destHeight As Integer = CInt((sourceHeight * nPercent))
            Using msout As New System.IO.MemoryStream
                Using bmPhoto As Bitmap = New Bitmap(Width, Height, PixelFormat.Format32bppRgb)
                    bmPhoto.SetResolution(imgPhoto.HorizontalResolution, imgPhoto.VerticalResolution)
                    Dim grPhoto As Graphics = Graphics.FromImage(bmPhoto)

                    Dim backcolor As Global.System.Drawing.Color = Color.White
                    Try
                        If Not String.IsNullOrWhiteSpace(bgcolor)
                            If bgcolor = "t"
                                backcolor = System.Drawing.Color.Transparent
                            Else
                                backcolor = Global.System.Drawing.ColorTranslator.FromHtml(IIf(bgcolor.ToString.StartsWith("#"), bgcolor, "#" & bgcolor))
                            End If
                        End If
                    Catch ex As Exception
                    End Try
                    grPhoto.Clear(backcolor)

                    grPhoto.InterpolationMode = InterpolationMode.HighQualityBicubic
                    grPhoto.DrawImage(imgPhoto, New Rectangle(destX, destY, destWidth, destHeight), New Rectangle(sourceX, sourceY, sourceWidth, sourceHeight), GraphicsUnit.Pixel)
                    grPhoto.Dispose()
                    bmPhoto.Save(msout, ImageFormat.Jpeg)
                End Using
                ret = msout.ToArray
            End Using
        End Using
        Return ret
    End Function

End Class
