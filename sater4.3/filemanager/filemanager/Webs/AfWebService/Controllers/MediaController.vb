Imports System.Web.Mvc
Imports System.Drawing
Imports System.Drawing.Imaging
Imports ImageProcessor
Imports ImageProcessor.Processors
Imports ImageProcessor.Plugins.WebP.Imaging.Formats
imports LazZiya.ImageResize


Namespace Controllers
    Public Class MediaController
        Inherits Controller


        Private Shared ReadOnly Property imagerversion As String = "2.01.10"
        Private Shared Property _usecache As Boolean?
        Private Shared Property _cachedir As String
        Private Shared Function UseCache As Boolean
            If Not _usecache.HasValue
                _usecache = Not String.IsNullOrWhiteSpace(cachedir) AndAlso My.Computer.FileSystem.DirectoryExists(cachedir)
            End If
            Return _usecache.Value
        End Function
        Private Shared Function cachedir As String
            If String.IsNullOrWhiteSpace(_cachedir)
                _cachedir =System.Web.Configuration.WebConfigurationManager.AppSettings("cache_folder")
                If Not String.IsNullOrWhiteSpace(_cachedir) Then
                    _cachedir = _cachedir.Trim("\").Trim("/")
                End If
            End If
            Return _cachedir
        End Function

        Private Class FileExistsEntry
            Public Property exists As Boolean
            Public Property fullpath As String
        End Class
        Private Shared Function ExistsCachefile(filename As String) As FileExistsEntry
            Dim ret As New FileExistsEntry
            If UseCache
                ret.fullpath = cachedir & "\" & filename
                ret.exists = My.Computer.FileSystem.FileExists(ret.fullpath)
            End If
            Return ret
        End Function


        <route("imgresize/{id}")>
        Function imgresize(id As String, w As String,h As String) As FileResult
            
            Dim UseCache As Boolean=False
            Dim SRCbuffer As Byte() = Nothing
            Dim targetfile As FileExistsEntry = Nothing
            Dim hash As String = Nothing
            Dim usewebp As Boolean = False
            Dim webpquality As Integer  = 95


            Dim ImageFormat As ImageFormat = ImageFormat.Jpeg
            Dim _w As Integer? = Nothing
            If Not String.IsNullOrWhiteSpace(w) AndAlso isnumeric(w) Then _w = CInt(w)
            Dim _h As Integer? = Nothing
            If Not String.IsNullOrWhiteSpace(h) AndAlso isnumeric(h) Then _h = CInt(h)

            Dim OUTPUTFORMAT As ImageFormat = ImageFormat.Png
            Dim contenttype As String = "image/png"
            If usewebp
                OUTPUTFORMAT =ImageFormat.Png
            End If

            If UseCache
                hash = AfCommon.Tools.HashTools.GetStringsHash(id, If(_w.HasValue, _w.ToString,"ND"), if(_h.HasValue,_h.ToString,"ND"), contenttype,usewebp.ToString, webpquality).Replace("-", "").ToLower
                Dim targetfilename As String = "RES_" & id & "_" & hash & ".dat"
                targetfile = ExistsCachefile(targetfilename)
                If targetfile.exists
                    If usewebp
                        contenttype = "image/webp"
                    End If
                    Response.CacheControl = "public"
                    Response.Cache.SetExpires(Date.Now.AddMonths(1))
                    Response.Cache.SetMaxAge(TimeSpan.FromDays(30))
                    Response.Cache.SetLastModified(Date.Now)
                    Response.AddHeader("pragma", "public")
                    Return New FilePathResult(targetfile.fullpath, contenttype)
                Else
                    Dim sourcefilename As String = "SRC_" & id & ".png"
                    Dim sourceexists As FileExistsEntry = ExistsCachefile(sourcefilename)
                    If sourceexists.exists
                        SRCbuffer = My.Computer.FileSystem.ReadAllBytes(sourceexists.fullpath)
                    Else
                        'TODO: Leggere il file dal Database
                        'SRCbuffer = DBREADER(?????)
                        If Not IsNothing(SRCbuffer)
                            writebytes(sourceexists.fullpath, SRCbuffer)
                        End If
                    End If
                End If
            Else
                'TODO: Leggere il file dal Database
                'SRCbuffer = DBREADER(?????)
            End If


           If Not IsNothing(SRCbuffer)

                Dim TGTbuffer As Byte() = Nothing
                Using img As Image = Image.FromStream(New System.IO.MemoryStream(SRCbuffer))
                    If _w.HasValue AndAlso _w.Value > 0 AndAlso _h.HasValue AndAlso _h.Value > 0
                        'TROVA LE PROPORZIONI GIUSTE
                        Dim newH As Integer = _w / img.Width * img.Height
                        Dim newW As Integer = _h / img.Height * img.Width
                        'Verifica se una delle due è maggiore del contenitore
                        If newH > _h
                            'VIENE RICALCOLATA SULLA BASE DI W
                            newH = _h
                            newW = _h / img.Height * img.Width
                        ElseIf newW > _w
                            'VIENE RICALCOLATA SUL VALORE DI H
                            newW = _w
                            newH = _w / img.Width * img.Height
                        Else
                            newH = _h
                            newW = _w
                        End If
                        Dim newimage As Image = Nothing
                        Select Case OUTPUTFORMAT.ToString
                            Case ImageFormat.Png.ToString
                                newimage = img.Scale(newW, newH).AddFrame(_w.Value, _h.Value, New ImageFrameOptions With {.FillColor = Color.White, .Thickness = 0})
                            Case Else
                                newimage = img.Scale(newW, newH).AddFrame(_w.Value - 1, _h.Value - 1, New ImageFrameOptions With {.FillColor = Color.White, .Thickness = 1})
                        End Select
                        Using ms As New System.IO.MemoryStream
                            newimage.Save(ms, OUTPUTFORMAT)
                            TGTbuffer = ms.ToArray
                        End Using
                        newimage.Dispose()
                        newimage = Nothing
                    ElseIf _w.HasValue AndAlso _w.Value > 0
                        Using newimage As Image = img.ScaleByWidth(_w.Value)
                            Using ms As New System.IO.MemoryStream
                                newimage.Save(ms, OUTPUTFORMAT)
                                TGTbuffer = ms.ToArray
                            End Using
                        End Using
                    ElseIf _h.HasValue AndAlso _h.Value > 0
                        Using newimage As Image = img.ScaleByHeight(_h.Value)
                            Using ms As New System.IO.MemoryStream
                                newimage.Save(ms, OUTPUTFORMAT)
                                TGTbuffer = ms.ToArray
                            End Using
                        End Using
                    Else
                        Using newimage As Image = img.Scale(img.Width, img.Height).AddFrame(img.Width, img.Height, New ImageFrameOptions With {.FillColor = Color.White, .Thickness = 0})
                            Using ms As New System.IO.MemoryStream
                                newimage.Save(ms, OUTPUTFORMAT)
                                TGTbuffer = ms.ToArray
                                If TGTbuffer.Length >= SRCbuffer.Length
                                    TGTbuffer = SRCbuffer
                                End If
                            End Using
                        End Using
                    End If
                End Using

                If usewebp
                    Dim webpFormat as new WebPFormat() With {.Quality = webpquality}
                    Using ms As New System.IO.MemoryStream(TGTbuffer)
                        Using imf As New ImageFactory(True)
                            Using outstream As New System.IO.MemoryStream
                                imf.Load(ms).Format(webpFormat).Save(outstream)
                                TGTbuffer = outstream.ToArray
                                contenttype = "image/webp"
                            End Using
                        End Using
                    End Using
                End If

                If Not IsNothing(TGTbuffer)
                    If UseCache
                        writebytes(targetfile.fullpath, TGTbuffer)
                        Response.CacheControl = "public"
                        Response.Cache.SetExpires(Date.Now.AddMonths(1))
                        Response.Cache.SetMaxAge(TimeSpan.FromDays(30))
                        Response.Cache.SetLastModified(Date.Now)
                        Response.AddHeader("pragma", "public")
                        Return New FilePathResult(targetfile.fullpath, contenttype)
                    Else
                        Return New FileContentResult(TGTbuffer, contenttype)
                    End If
                Else
                    Response.StatusCode = 404
                    Return Nothing
                End If
            Else
                Response.StatusCode = 404
                Return Nothing
            End If
        End Function

        Private Shared Function reabytes(path As String, Optional timeout As Integer = 5) As Byte()
            If Not String.IsNullOrWhiteSpace(path)
                Dim start As DateTime = Date.Now
                While date.Now.Subtract(start).TotalSeconds < timeout
                    Try
                        If My.Computer.FileSystem.FileExists(path)
                            Return My.Computer.FileSystem.ReadAllBytes(path)
                        Else
                            Return Nothing
                        End If
                    Catch ex As Exception
                        System.Threading.Thread.Sleep(100)
                    End Try
                End While
            End If
            Return Nothing
        End Function
        Private Shared Sub writebytes(path As String, buffer As Byte(), Optional timeout As Integer = 5, Optional append As Boolean = False)
            If Not String.IsNullOrWhiteSpace(path)
                Dim start As DateTime = Date.Now
                While Date.Now.Subtract(start).TotalSeconds < timeout
                    Try
                        My.Computer.FileSystem.WriteAllBytes(path, buffer, append)
                        Return
                    Catch ex As Exception
                        System.Threading.Thread.Sleep(100)
                    End Try
                End While
            End If
        End Sub

    End Class
End Namespace