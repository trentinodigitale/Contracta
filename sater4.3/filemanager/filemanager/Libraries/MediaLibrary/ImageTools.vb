Imports System.Drawing
Imports System.Drawing.Drawing2D
Imports System.Drawing.Imaging
Imports System.IO
Imports System.Net.Mime

Public Class ImageTools
    Implements IDisposable
    Dim original() As Byte = Nothing
    Public Sub New(ByVal original As Byte())
        Me.original = original
    End Sub
    Public Enum quality
        Low = 0
        [Default] = 1
        High = 2
        Original = 3
    End Enum

    Private Function GetImageZoomStretch(ByVal maxW As Integer, ByVal maxH As Integer) As Byte()
        Dim buffer() As Byte = Nothing
        Using istream As New MemoryStream(Me.original)
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





    Public Function CheckIsImage(ByVal buffer() As Byte) As Byte()
        Try
            Dim InputImage As Global.System.Drawing.Image = Nothing
            InputImage = Global.System.Drawing.Image.FromStream(New Global.System.IO.MemoryStream(buffer))
            Return buffer
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    Public Class ImgSize
        Public w As Integer = 0
        Public h As Integer = 0
        Public Sub New()
        End Sub
    End Class
    Public Function GetImage_result_size(ByVal maxwidth As Integer, ByVal maxheight As Integer, ByVal keepaspect As Boolean, ByVal fill As Boolean, ByVal stretch As Boolean, Optional ByVal PutOnTop As Boolean = False, Optional ByVal Transparent As Boolean = False, Optional ByVal Vertical_Cut As Boolean = False, Optional ByVal Horizontal_Cut As Boolean = False, Optional ByRef errormessage As String = "") As ImgSize
        Dim ret As New ImgSize

        errormessage = ""
        Dim cut_h As Integer = 0
        Dim cut_w As Integer = 0
        If Vertical_Cut = True Then
            cut_h = maxheight
            maxheight = 0
        ElseIf Horizontal_Cut = True Then
            cut_w = maxwidth
            maxwidth = 0
        End If
        Dim buffer() As Byte = Me.original

        Try
            Dim BG_H As Integer = 0
            Dim BG_W As Integer = 0
            Dim InputImage As Global.System.Drawing.Image = Nothing
            InputImage = Global.System.Drawing.Image.FromStream(New Global.System.IO.MemoryStream(buffer))
            Dim S_H As Integer = maxheight
            Dim S_W As Integer = maxwidth
            Dim FILLED As Boolean = fill
            S_H = Math.Abs(S_H)
            S_W = Math.Abs(S_W)
            If S_H = 0 AndAlso S_W = 0 Then
                ret = New ImgSize() With {.w = InputImage.Width, .h = InputImage.Height}
            Else
                BG_H = S_H
                BG_W = S_W

                Dim w As Double = 0
                Dim h As Double = 0
                Dim W2 As Integer = 0
                Dim H2 As Integer = 0
                w = InputImage.Size.Width
                h = InputImage.Size.Height
                If S_H = 0 Then S_H = h
                If S_W = 0 Then S_W = w
                Dim factor As Double = 0
                If keepaspect OrElse Not stretch Then
                    If Not stretch Then
                        If S_H > h Then S_H = h
                        If S_W > w Then S_W = w
                    End If
                    'Verifica della prossimità dei 2 valori nell'avvicinarsi al valore finale
                    If S_H > 0 AndAlso S_W > 0 Then
                        factor = (S_H / h)
                        If factor > (S_W / w) Then
                            factor = (S_W / w)
                        End If
                    ElseIf S_H = 0 Then

                        factor = (S_W / w)
                    ElseIf S_W = 0 Then
                        factor = (S_H / h)
                    End If
                    If S_H = 0 Then S_H = h * factor
                    If S_W = 0 Then S_W = w * factor
                    W2 = Int(w * factor)
                    H2 = Int(h * factor)
                Else
                    W2 = maxwidth
                    H2 = maxheight
                End If
                If FILLED Then
                    ret = New ImgSize() With {.w = BG_W, .h = BG_H}
                Else
                    ret = New ImgSize() With {.w = W2, .h = H2}
                End If
            End If
        Catch ex As Exception
            errormessage = ex.Message & vbCrLf & ex.StackTrace
        Finally
            Global.System.GC.GetTotalMemory(False)
        End Try
        Return ret
    End Function
    Public Function MixImages(images()() As Byte, images_per_line As Integer, ByVal quality As ImageTools.quality, ByVal format As String) As Byte()
        Dim IMAGEFormat As Global.System.Drawing.Imaging.ImageFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
        Select Case format.ToLower
            Case Global.System.Drawing.Imaging.ImageFormat.Bmp.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Bmp
            Case Global.System.Drawing.Imaging.ImageFormat.Emf.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Emf
            Case Global.System.Drawing.Imaging.ImageFormat.Exif.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Exif
            Case Global.System.Drawing.Imaging.ImageFormat.Gif.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Gif
            Case Global.System.Drawing.Imaging.ImageFormat.Icon.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Icon
            Case Global.System.Drawing.Imaging.ImageFormat.Jpeg.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
            Case Global.System.Drawing.Imaging.ImageFormat.MemoryBmp.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.MemoryBmp
            Case Global.System.Drawing.Imaging.ImageFormat.Png.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Png
            Case Global.System.Drawing.Imaging.ImageFormat.Tiff.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Tiff
            Case Global.System.Drawing.Imaging.ImageFormat.Wmf.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Wmf
            Case Else
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
        End Select

        Select Case Int(quality)
            Case Is < 1
                quality = ImageTools.quality.Low
            Case 1
                quality = ImageTools.quality.Default
            Case Else
                quality = ImageTools.quality.High
        End Select


        Dim Bitmaps As New List(Of Bitmap)
        For Each ib As Byte() In images
            Bitmaps.Add(System.Drawing.Bitmap.FromStream(New IO.MemoryStream(ib)))
        Next
        Dim width As Integer = 0
        Dim maxheight As Integer = 0
        Dim line As Integer = 0
        Dim lft As Integer = 0
        Dim w As Integer = 0
        For Each bm As Bitmap In Bitmaps
            w += bm.Width
            lft += 1
            If w > width Then width = w
            If lft = images_per_line Then
                lft = 0
                w = 0
            End If
            If bm.Height > maxheight Then maxheight = bm.Height
        Next
        Dim Height As Integer = 0
        If Bitmaps.Count / images_per_line = Int(Bitmaps.Count / images_per_line) Then
            Height = maxheight * Bitmaps.Count / images_per_line
        Else
            Height = maxheight * (Int(Bitmaps.Count / images_per_line) + 1)
        End If

        Dim bm_result As New Bitmap(width, Height)


        Using gr As Graphics = Graphics.FromImage(bm_result)
            Dim x As Integer = 0
            Dim y As Integer = 0
            For Each bm As Bitmap In Bitmaps
                gr.DrawImage(bm, x, y, bm.Width, bm.Height)
                x += bm.Width
                If x + bm.Width > bm_result.Width Then
                    x = 0
                    y += maxheight
                End If
            Next
        End Using
        For Each bm As Bitmap In Bitmaps
            bm.Dispose()
        Next
        Dim ret() As Byte
        Using msout As New IO.MemoryStream
            bm_result.Save(msout, IMAGEFormat)
            ret = msout.ToArray
        End Using
        Return ret
    End Function


    ''' <summary>
    ''' Restituisce una immagine elaborata
    ''' </summary>
    ''' <param name="maxwidth">Larghezza massima (0 per infinito)</param>
    ''' <param name="maxheight">Altezza massima (0 per infinito)</param>
    ''' <param name="keepaspect">Conserva l'aspetto dell'immagine originale</param>
    ''' <param name="fill">Riempie l'area con uno sfondo</param>
    ''' <param name="stretch">Deforma l'immagine se necessario</param>
    ''' <param name="bgcolor">Colore dello sfondo di riempimento</param>
    ''' <param name="quality">Qualità dell'immagine di output</param>
    ''' <param name="format">Formato</param>
    ''' <param name="PutOnTop">Attesta l'immagine nella parte alta</param>
    ''' <param name="Transparent">Sfondo Trasparent</param>
    ''' <param name="Vertical_Cut">taglia verticalmente (maxheight)</param>
    ''' <param name="Horizontal_Cut">taglia orizzontalmente (maxwidth)</param>
    ''' <returns>Buffer contentente l'immagine</returns>
    ''' <remarks></remarks>
    Public Function GetImage(ByVal maxwidth As Integer, ByVal maxheight As Integer, ByVal keepaspect As Boolean, ByVal fill As Boolean, ByVal stretch As Boolean, ByVal bgcolor As String, ByVal quality As ImageTools.quality, ByVal format As String, Optional ByVal PutOnTop As Boolean = False, Optional ByVal Transparent As Boolean = False, Optional ByVal Vertical_Cut As Boolean = False, Optional ByVal Horizontal_Cut As Boolean = False, Optional ByRef errormessage As String = "") As Byte()

        'Return Me.original

        errormessage = ""
        'If Vertical_Cut = False AndAlso Horizontal_Cut = False
        '    If maxheight > 0 AndAlso maxwidth = 0
        '        Vertical_Cut = True
        '    ElseIf maxwidth  > 0 AndAlso maxheight = 0
        '        Horizontal_Cut = True
        '    End If
        'End If
        Dim cut_h As Integer = 0
        Dim cut_w As Integer = 0
        If Vertical_Cut = True Then
            cut_h = maxheight
            maxheight = 0
        ElseIf Horizontal_Cut = True Then
            cut_w = maxwidth
            maxwidth = 0
        End If
        Dim buffer() As Byte = Me.original
        Dim ret() As Byte = Nothing
        Dim IMAGEFormat As Global.System.Drawing.Imaging.ImageFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
        Select Case format.Trim(".").ToLower
            Case Global.System.Drawing.Imaging.ImageFormat.Bmp.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Bmp
            Case Global.System.Drawing.Imaging.ImageFormat.Emf.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Emf
            Case Global.System.Drawing.Imaging.ImageFormat.Exif.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Exif
            Case Global.System.Drawing.Imaging.ImageFormat.Gif.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Gif
            Case Global.System.Drawing.Imaging.ImageFormat.Icon.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Icon
            Case Global.System.Drawing.Imaging.ImageFormat.Jpeg.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
            Case Global.System.Drawing.Imaging.ImageFormat.MemoryBmp.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.MemoryBmp
            Case Global.System.Drawing.Imaging.ImageFormat.Png.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Png
            Case Global.System.Drawing.Imaging.ImageFormat.Tiff.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Tiff
            Case Global.System.Drawing.Imaging.ImageFormat.Wmf.ToString.ToLower
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Wmf
            Case Else
                IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
        End Select

        Select Case Int(quality)
            Case Is < 1
                quality = ImageTools.quality.Low
            Case 1
                quality = ImageTools.quality.Default
            Case Else
                quality = ImageTools.quality.High
        End Select


        Try
            Dim BG_H As Integer = 0
            Dim BG_W As Integer = 0
            Dim InputImage As Global.System.Drawing.Image = Nothing
            InputImage = Global.System.Drawing.Image.FromStream(New Global.System.IO.MemoryStream(buffer))
            Dim S_H As Integer = maxheight
            Dim S_W As Integer = maxwidth
            Dim FILLED As Boolean = fill
            S_H = Math.Abs(S_H)
            S_W = Math.Abs(S_W)
            If S_H = 0 AndAlso S_W = 0 AndAlso quality = ImageTools.quality.Original Then
                Using msout As New IO.MemoryStream
                    InputImage.Save(msout, IMAGEFormat)
                    ret = msout.ToArray
                End Using
            Else

                Try
                    ImageHelper.RotateImageByExifOrientationData(InputImage, True)
                Catch ex As Exception

                End Try




                BG_H = S_H
                BG_W = S_W

                Dim w As Double = 0
                Dim h As Double = 0
                Dim W2 As Integer = 0
                Dim H2 As Integer = 0
                w = InputImage.Size.Width
                h = InputImage.Size.Height
                If S_H = 0 Then S_H = h
                If S_W = 0 Then S_W = w
                Dim factor As Double = 0
                If keepaspect OrElse Not stretch Then
                    If Not stretch Then
                        If S_H > h Then S_H = h
                        If S_W > w Then S_W = w
                    End If
                    'Verifica della prossimità dei 2 valori nell'avvicinarsi al valore finale
                    If S_H > 0 AndAlso S_W > 0 Then
                        factor = (S_H / h)
                        If factor > (S_W / w) Then
                            factor = (S_W / w)
                        End If
                    ElseIf S_H = 0 Then
                        factor = (S_W / w)
                        S_H = h * factor
                    ElseIf S_W = 0 Then
                        factor = (S_H / h)
                        S_W = w * factor
                    End If
                    If S_H = 0 Then S_H = h * factor
                    If S_W = 0 Then S_W = w * factor
                    W2 = Int(w * factor)
                    H2 = Int(h * factor)
                Else
                    W2 = maxwidth
                    H2 = maxheight
                End If

                'Dim newimage As New Bitmap(W2, H2)
                'Dim thumbGraph As Graphics = Graphics.FromImage(newimage)
                'thumbGraph.CompositingQuality = CompositingQuality.HighQuality
                'thumbGraph.SmoothingMode = SmoothingMode.HighQuality
                'thumbGraph.DrawImage(InputImage, 0, 0, W2, H2)
                'InputImage.Dispose

                'Using ms As New System.IO.MemoryStream
                '    newimage.Save(ms, IMAGEFormat.Png)
                '    Return ms.ToArray
                'End Using

                If Not Transparent      'Verifica se effettivamente l'immagine è trasparente
                    Dim currentGraphic As System.Drawing.Bitmap = System.Drawing.Bitmap.FromStream(New System.IO.MemoryStream(Me.original))
                    If Not currentGraphic.GetPixel(0,0).A = 255
                        Transparent = True
                    End If
                End If
                If Not Transparent AndAlso format.Trim(".").ToLower = "png"
                    IMAGEFormat = Global.System.Drawing.Imaging.ImageFormat.Jpeg
                End If

                Dim bmPhoto As Drawing.Bitmap = New Drawing.Bitmap(W2, H2)
                'bmPhoto.SetResolution(InputImage.HorizontalResolution, InputImage.VerticalResolution)
                Dim grPhoto As Drawing.Graphics = Global.System.Drawing.Graphics.FromImage(bmPhoto)

                

                Select Case quality
                    Case ImageTools.quality.Low
                        grPhoto.CompositingQuality = Global.System.Drawing.Drawing2D.CompositingQuality.HighSpeed
                        grPhoto.SmoothingMode = Drawing.Drawing2D.SmoothingMode.HighSpeed
                        grPhoto.InterpolationMode = Global.System.Drawing.Drawing2D.InterpolationMode.Low
                        grPhoto.CompositingQuality = Global.System.Drawing.Drawing2D.CompositingQuality.HighSpeed
                    Case ImageTools.quality.Default
                        grPhoto.CompositingQuality = Global.System.Drawing.Drawing2D.CompositingQuality.Default
                        grPhoto.SmoothingMode = Drawing.Drawing2D.SmoothingMode.Default
                        grPhoto.InterpolationMode = Global.System.Drawing.Drawing2D.InterpolationMode.Default
                        grPhoto.CompositingQuality = Global.System.Drawing.Drawing2D.CompositingQuality.Default
                    Case ImageTools.quality.High
                        grPhoto.CompositingQuality = CompositingQuality.HighQuality
                        grPhoto.SmoothingMode = SmoothingMode.HighQuality
                        'grPhoto.DrawImage(InputImage, 0, 0, W2, H2)
                End Select



                'grPhoto.DrawImage(InputImage, New Global.System.Drawing.Rectangle(0, 0, W2, H2), New Global.System.Drawing.Rectangle(0, 0, CInt(w), CInt(h)), Global.System.Drawing.GraphicsUnit.Pixel)
                grPhoto.DrawImage(InputImage, New Global.System.Drawing.Rectangle(0, 0, W2, H2))



                'Dim bmPhoto As Bitmap = ResizeImage_new(InputImage, W2, H2, bgcolor)


                If FILLED Then


                    'bgcolor = "#000000"
                    'CREATE SFONDO
                    Dim brush As New SolidBrush(Color.Transparent)
                    Dim backcolor As Global.System.Drawing.Color = Color.White
                    Try
                        If Transparent Then
                            backcolor = Color.Transparent
                        ElseIf Not String.IsNullOrWhiteSpace(bgcolor)
                            backcolor = Global.System.Drawing.ColorTranslator.FromHtml(IIf(bgcolor.ToString.StartsWith("#"), bgcolor, "#" & bgcolor))
                        End If
                    Catch ex As Exception
                    End Try
                    'OVERLAP IMAGES
                    Using msout As New IO.MemoryStream
                        If Vertical_Cut = True Then
                            BG_H = bmPhoto.Height
                            If maxwidth > 0
                                BG_W = maxwidth
                            Else
                                BG_W = InputImage.Width
                            End If
                        ElseIf Horizontal_Cut = True Then
                            BG_W = bmPhoto.Width
                            If maxheight > 0
                                BG_H = maxheight
                            Else
                                BG_H = InputImage.Height
                            End If
                        End If


                        Dim retimage As Image = Me.FillImage(bmPhoto, backcolor, BG_W, BG_H, PutOnTop)



                        'RESIZE IMAGE
                        If Vertical_Cut = True AndAlso retimage.Height > cut_h Then
                            retimage = CropImage(retimage, cut_h, retimage.Width)
                        ElseIf Horizontal_Cut = True AndAlso retimage.Width > cut_w Then
                            retimage = CropImage(retimage, retimage.Height, cut_w)
                        End If
                        retimage.Save(msout, IMAGEFormat)
                        ' Me.FillImage(bmPhoto, backcolor, BG_W, BG_H, PutOnTop).Save(msout, IMAGEFormat)
                        ret = msout.ToArray
                    End Using
                Else
                    'RESIZE IMAGE
                    If Vertical_Cut = True AndAlso bmPhoto.Height > cut_h Then
                        bmPhoto = New Bitmap(CropImage(bmPhoto, cut_h, bmPhoto.Width))
                    ElseIf Horizontal_Cut = True AndAlso bmPhoto.Width > cut_w Then
                        bmPhoto = New Bitmap(CropImage(bmPhoto, bmPhoto.Height, cut_w))
                    End If
                    Dim retimage As Image = Me.FillImage(bmPhoto, System.Drawing.Color.White, W2, H2, PutOnTop)
                    Using msout As New System.IO.MemoryStream
                        retimage.Save(msout, IMAGEFormat)
                        ret = msout.ToArray
                    End Using
                    'Using msout As New IO.MemoryStream
                    '    bmPhoto.Save(msout, IMAGEFormat)
                    '    ret = msout.ToArray
                    'End Using
                End If
                bmPhoto = Nothing
                InputImage = Nothing
                buffer = Nothing
            End If
        Catch ex As Exception
            errormessage = ex.Message & vbCrLf & ex.StackTrace
        Finally
            Global.System.GC.GetTotalMemory(False)
        End Try
        Return ret
    End Function

    Private Shared Function ResizeImage_new(imgphoto As Image, ByVal Width As Integer, ByVal Height As Integer, bgcolor As String) As Bitmap
        Dim ret As Bitmap = Nothing
        If Width = 0 Then Width = imgphoto.Width
        If Height = 0 Then Height = imgphoto.Height

        Dim sourceWidth As Integer = imgphoto.Width
        Dim sourceHeight As Integer = imgphoto.Height
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


        Dim bmPhoto As Bitmap = New Bitmap(Width, Height, PixelFormat.Format32bppRgb)
        bmPhoto.SetResolution(imgphoto.HorizontalResolution, imgphoto.VerticalResolution)
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
        grPhoto.DrawImage(imgphoto, New Rectangle(destX, destY, destWidth, destHeight), New Rectangle(sourceX, sourceY, sourceWidth, sourceHeight), GraphicsUnit.Pixel)
        grPhoto.Dispose()
        ret = bmPhoto

        Return ret
    End Function



    Public Function CropImage(ByVal sourceImage As Bitmap, ByVal height As Int32, ByVal width As Int32) As Image
        Try
            Dim resultImage As Bitmap = New Bitmap(width, height)
            Dim resultGraphics As Graphics = Graphics.FromImage(resultImage)
            resultGraphics.DrawImage(sourceImage, 0, 0)
            Return resultImage
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Private Function FillImage(ByVal immagine As Image, ByVal bgcolor As Global.System.Drawing.Color, ByVal Width As Integer, ByVal height As Integer, ByVal PutOnTop As Boolean) As Image
        Dim EntireBitMap As New Bitmap(Width, height)
        Dim brush As New SolidBrush(bgcolor)
        Dim x As Integer = 0
        Dim y As Integer = 0

        If PutOnTop Then
            x = Int((EntireBitMap.Width / 2) - (immagine.Width / 2))
            y = 0
        Else
            x = Int((EntireBitMap.Width / 2) - (immagine.Width / 2))
            y = Int(((EntireBitMap.Height / 2) - (immagine.Height / 2)))
        End If

        Using G As Graphics = Graphics.FromImage(EntireBitMap)
            With G
                .DrawImage(immagine, x, y, immagine.Width, immagine.Height)
                If Width = immagine.Width AndAlso height = immagine.Height Then
                    Using P As New Pen(bgcolor, 1)
                        .DrawLine(P, 0, 0, Width, 0)
                        .DrawLine(P, 0, 0, 0, height)
                        .DrawLine(P, 0, height, Width, height)
                        .DrawLine(P, Width, height, Width, 0)
                    End Using
                Else
                    If PutOnTop Then
                        .FillRectangle(brush, 0, y + immagine.Height, EntireBitMap.Width, EntireBitMap.Height - immagine.Height)                 'OK
                        .FillRectangle(brush, 0, 0, x + 1, EntireBitMap.Height)                                 'OK                 'LEFT RECTANGLE
                        .FillRectangle(brush, EntireBitMap.Width - x - 1, 0, x + 1, EntireBitMap.Height)        'OK                 'RIGHT RECTANGLE
                    Else
                        .FillRectangle(brush, 0, 0, EntireBitMap.Width, y + 1)                                  'OK                 'TOP RECTANGLE
                        .FillRectangle(brush, 0, 0, x + 1, EntireBitMap.Height)                                 'OK                 'LEFT RECTANGLE
                        .FillRectangle(brush, 0, EntireBitMap.Height - y - 1, EntireBitMap.Width, y + 1)        'OK                 'BOTTOM RECTANGLE
                        .FillRectangle(brush, EntireBitMap.Width - x - 1, 0, x + 1, EntireBitMap.Height)        'OK                 'RIGHT RECTANGLE
                    End If
                End If
                .Save()
            End With
        End Using
        Return EntireBitMap
    End Function
    Private disposedValue As Boolean = False        ' To detect redundant calls
    ' IDisposable
    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposedValue Then
            If disposing Then
                ' TODO: free other state (managed objects).
                Me.original = Nothing
            End If
            ' TODO: free your own state (unmanaged objects).
            ' TODO: set large fields to null.
        End If
        Me.disposedValue = True
    End Sub
#Region " IDisposable Support "
    ' This code added by Visual Basic to correctly implement the disposable pattern.
    Public Sub Dispose() Implements IDisposable.Dispose
        ' Do not change this code.  Put cleanup code in Dispose(ByVal disposing As Boolean) above.
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub
#End Region
End Class


Module ImageHelper
    Function RotateImageByExifOrientationData(ByVal sourceFilePath As String, ByVal targetFilePath As String, ByVal targetFormat As ImageFormat, ByVal Optional updateExifData As Boolean = True) As RotateFlipType
        Dim bmp = New Bitmap(sourceFilePath)
        Dim fType As RotateFlipType = RotateImageByExifOrientationData(bmp, updateExifData)

        If fType <> RotateFlipType.RotateNoneFlipNone Then
            bmp.Save(targetFilePath, targetFormat)
        End If

        Return fType
    End Function

    Function RotateImageByExifOrientationData(ByVal img As Image, ByVal Optional updateExifData As Boolean = True) As RotateFlipType
        Dim orientationId As Integer = &H0112
        Dim fType = RotateFlipType.RotateNoneFlipNone

        If img.PropertyIdList.Contains(orientationId) Then
            Dim pItem = img.GetPropertyItem(orientationId)
            fType = GetRotateFlipTypeByExifOrientationData(pItem.Value(0))

            If fType <> RotateFlipType.RotateNoneFlipNone Then
                img.RotateFlip(fType)
                If updateExifData Then img.RemovePropertyItem(orientationId)
            End If
        End If

        Return fType
    End Function

    Function GetRotateFlipTypeByExifOrientationData(ByVal orientation As Integer) As RotateFlipType
        Select Case orientation
            Case 2
                Return RotateFlipType.RotateNoneFlipX
            Case 3
                Return RotateFlipType.Rotate180FlipNone
            Case 4
                Return RotateFlipType.Rotate180FlipX
            Case 5
                Return RotateFlipType.Rotate90FlipX
            Case 6
                Return RotateFlipType.Rotate90FlipNone
            Case 7
                Return RotateFlipType.Rotate270FlipX
            Case 8
                Return RotateFlipType.Rotate270FlipNone
            Case Else
                Return RotateFlipType.RotateNoneFlipNone
        End Select
    End Function
End Module
