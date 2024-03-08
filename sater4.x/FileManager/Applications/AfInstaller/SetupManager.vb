Public Class SetupManager
    Public shared Sub fx_create_Setup
        Dim Entries As New List(Of ZipEntry)
        Dim filestorestore As New Hashtable

        If MsgBox("Aggiungere AF ServiceFileManager al Setup?",MsgBoxStyle.YesNo)=MsgBoxResult.Yes
            Using fdfm As New OpenFileDialog() With {.title = "Seleziona l'eseguibile per l'applicazione AF ServiceFileManager",.Filter ="executable|*.exe"}
                If fdfm.ShowDialog=DialogResult.OK
                    Dim appdir As String = New System.IO.FileInfo(fdfm.FileName).DirectoryName
                    Entries.Add(New ZipEntry(appdir,Nothing,True, "010_af_servicefilemanager"))
                    If MsgBox("Modificare il file di configurazione per l'applicazione?",MsgBoxStyle.YesNo,"File di Configurazione") = MsgBoxResult.Yes
                        Dim configfile As String = appdir & "\appsettings.config"
                        Dim content As String = ""
                        If My.Computer.FileSystem.FileExists(configfile)
                            filestorestore(configfile) = My.Computer.FileSystem.ReadAllBytes(configfile)
                            content = My.Computer.FileSystem.ReadAllText(configfile)
                        End If
                        Using frmeditor As New frm_text_editor(content)
                            frmeditor.ShowDialog
                            If Not content = frmeditor.content
                                content  = frmeditor.content
                                If Not MsgBox("Applicare le modifiche anche al file originale?",MsgBoxStyle.YesNo)=MsgBoxResult.Yes
                                    If filestorestore.ContainsKey(configfile)
                                        filestorestore.Remove(configfile)
                                    End If
                                End If
                            End If
                        End Using
                        My.Computer.FileSystem.WriteAllText(configfile,content,False)
                    End If

                    If MsgBox("Aggiungere le dipendenze Microsoft Visual C++ Redistributable per Visual Studio 2015, 2017 e 2019?",MsgBoxStyle.YesNo,"Aggiungi Dipendenze")=MsgBoxResult.Yes
                        'AGGIUNGE LE DIPENDENZE
                        Entries.Add(New ZipEntry("",My.Resources.VC_redist_x86,False,"100_dependencies/vc_redist.x86.exe"))
                        Entries.Add(New ZipEntry("",My.Resources.VC_redist_x64,False,"100_dependencies/vc_redist.x64.exe"))
                    End If
                End If
            End Using
        End If

        If MsgBox("Aggiungere AF Service Starter al Setup?",MsgBoxStyle.YesNo,"AF Service Starter")=MsgBoxResult.Yes
            Using fdss As New OpenFileDialog() With {.Title = "Seleziona l'eseguibile per l'applicazione AF ServiceStarter",.Filter ="executable|*.exe"}
                If fdss.ShowDialog=DialogResult.OK
                    Entries.Add(New ZipEntry(new IO.FileInfo(fdss.FileName).DirectoryName,Nothing,True,"020_af_servicestarter"))
                End If
            End Using
        End If


        If MsgBox("Aggiungere AF Web File Manager al Setup?",MsgBoxStyle.YesNo)=MsgBoxResult.Yes
            Using fdfm As New OpenFileDialog() With {.title = "Seleziona il web.config per la Web Application AF WebFileManager",.Filter ="Web Config|web.config"}
                If fdfm.ShowDialog=DialogResult.OK
                    Dim appdir As String = New System.IO.FileInfo(fdfm.FileName).DirectoryName
                    Entries.Add(New ZipEntry(appdir,Nothing,True, "050_af_webfilemanager"))
                    Dim OverWriteConfigFile As Boolean=False
                    Dim config_originalcontent As Byte() = Nothing
                    If MsgBox("Modificare il file di configurazione per l'applicazione?",MsgBoxStyle.YesNo,"File di Configurazione") = MsgBoxResult.Yes
                        Dim configfile As String = appdir & "\websettings.config"
                        Dim content As String = ""
                        If My.Computer.FileSystem.FileExists(configfile)
                            filestorestore(configfile) = My.Computer.FileSystem.ReadAllBytes(configfile)
                            content = My.Computer.FileSystem.ReadAllText(configfile)
                        End If
                        Using frmeditor As New frm_text_editor(content)
                            frmeditor.ShowDialog
                            If Not content = frmeditor.content
                                content  = frmeditor.content
                                If Not MsgBox("Applicare le modifiche anche al file originale?",MsgBoxStyle.YesNo)=MsgBoxResult.Yes
                                    If filestorestore.ContainsKey(configfile)
                                        filestorestore.Remove(configfile)
                                    End If
                                End If
                            End If
                        End Using
                        My.Computer.FileSystem.WriteAllText(configfile,content,False)
                    End If
                End If
            End Using
        End If

        If Entries.Count > 0
            Dim buffer As Byte() = CreateZipRecursive(Entries)
            Using fs As New SaveFileDialog With {.Title = "Salva il File di Setup",.Filter = "Af Setup|*.afsetup"}
                If fs.ShowDialog  = DialogResult.OK
                    My.Computer.FileSystem.WriteAllBytes(fs.FileName,buffer,False)
                    MsgBox("Setup Creato con Successo",MsgBoxStyle.Information,"Setup Pronto")
                Else
                    MsgBox("Setup Cancellato", MsgBoxStyle.Exclamation,"Setup Cancellato")
                End If
            End Using
        Else
            MsgBox("Setup Cancellato", MsgBoxStyle.Exclamation,"Setup Cancellato")
        End If
        For each k As String In filestorestore.Keys
            My.Computer.FileSystem.WriteAllBytes(k,filestorestore(k),False)
        Next
    End Sub


    Private shared function Archive_To_Directory(ms As System.IO.MemoryStream,targetdirectory As String) As Boolean
        Try
            ms.Seek(0,IO.SeekOrigin.Begin)
            Using Z As Ionic.Zip.ZipFile = Ionic.Zip.ZipFile.Read(ms)
                Z.ExtractAll(targetdirectory,Ionic.Zip.ExtractExistingFileAction.OverwriteSilently)
            End Using
            Return True
        Catch ex As Exception
            MsgBox(ex.Message,MsgBoxStyle.Critical,"Errore di Installazione")
            Return False
        End Try
    End function
    Public shared sub fx_deploy_Setup()
        Dim appinstalled As Integer = 0
        Dim dipinstalled As Integer = 0
        Dim af_servicefilemanager_file As String = ""
        Using fd As New openfiledialog With {.Title = "Carica il file di setup",.Filter = "Af Setup|*.afsetup"}
            Dim dipdir As String = ""
            If fd.ShowDialog = DialogResult.OK
                Using Z As Ionic.Zip.ZipFile = Ionic.Zip.ZipFile.Read(fd.FileName)
                    Z.FlattenFoldersOnExtract = True
                    For each ZE As Ionic.Zip.ZipEntry in Z.Entries
                        Select Case ZE.FileName
                            Case "010_af_servicefilemanager"
                                If MsgBox("Installare AF ServiceFileManager?",MsgBoxStyle.YesNo,"AF ServiceFileManager")=MsgBoxResult.Yes
                                    Using fdt As New FolderBrowserDialog() With {.Description = "Selezionare la cartella di destinazione dei files"}
                                        If fdt.ShowDialog =DialogResult.OK
                                            Using ms As New System.IO.MemoryStream
                                                ZE.Extract(ms)
                                                if Not Archive_To_Directory(ms,fdt.SelectedPath)
                                                    Return
                                                Else
                                                    af_servicefilemanager_file = fdt.SelectedPath & "\AF_ServiceFileManager.exe"
                                                    appinstalled += 1
                                                End If
                                            End Using                      
                                        End If
                                    End Using
                                End If
                            Case "020_af_servicestarter"
                                If MsgBox("Installare AF Service Starter?",MsgBoxStyle.YesNo,"AF Service Starter")=MsgBoxResult.Yes
                                    Using fdt As New FolderBrowserDialog() With {.Description = "Selezionare la cartella di destinazione dei files"}
                                        If fdt.ShowDialog =DialogResult.OK
                                            Using ms As New System.IO.MemoryStream
                                                ZE.Extract(ms)
                                                if Not Archive_To_Directory(ms,fdt.SelectedPath)
                                                    Return
                                                Else
                                                    appinstalled += 1
                                                    If Not String.IsNullOrWhiteSpace(af_servicefilemanager_file) AndAlso MsgBox("Inserire il percorso all'applicazione AF Service file Manager nel file di configurazione del servizio" & vbCrLf & "Questa operazione rimuoverà le entry esistenti. Continuare?",MsgBoxStyle.YesNo,"Startup File")=MsgBoxResult.Yes
                                                        Dim config As String = fdt.SelectedPath & "\config.txt"
                                                        My.Computer.FileSystem.WriteAllText(config,af_servicefilemanager_file,False)
                                                    End If

                                                    dim S As ServiceProcess.ServiceController = System.ServiceProcess.ServiceController.GetServices().ToList.Find(Function(m) m.ServiceName.ToLower = "afservicestarter")
                                                    If IsNothing(S)
                                                        If MsgBox("Installare il servizio in Windows?",MsgBoxStyle.YesNo,"Installazione Servizio Windows")=MsgBoxResult.Yes
                                                            Dim winfolder As String = Environment.GetEnvironmentVariable("windir")
                                                            Dim iufound As Boolean=False
                                                            If My.Computer.FileSystem.DirectoryExists(winfolder & "\microsoft.NET\Framework")
                                                                For each dir As String In My.Computer.FileSystem.GetDirectories(winfolder & "\microsoft.NET\Framework", FileIO.SearchOption.SearchTopLevelOnly)                                                                                                                                
                                                                    If New IO.DirectoryInfo(dir).Name.StartsWith("v4") AndAlso My.Computer.FileSystem.FileExists(dir & "\installutil.exe")
                                                                        iufound = True
                                                                        Shell(dir & "\installutil.exe " & fdt.SelectedPath & "\AfServiceStarter.exe", AppWinStyle.NormalFocus,True)
                                                                        S = System.ServiceProcess.ServiceController.GetServices().ToList.Find(Function(m) m.ServiceName.ToLower = "afservicestarter")
                                                                        Exit For
                                                                    End If                                                                
                                                                Next
                                                            End If
                                                            If Not iufound
                                                                MsgBox("Installutil.exe (v.4) non trovato",MsgBoxStyle.Critical,"Installutil.exe non trovato")
                                                            Else
                                                                If Not IsNothing(S)
                                                                    if MsgBox("Servizio Installato con successo. Avviare il servizio?",MsgBoxStyle.YesNo,"Avvio Servizio")=MsgBoxResult.Yes
                                                                        S.Start()
                                                                    End If
                                                                Else
                                                                    MsgBox("Installazione Servizio Windows Fallita",MsgBoxStyle.Exclamation,"Installazione Servizio Windows Fallita")
                                                                End If
                                                            End If
                                                        End If
                                                    End If
                                                End If
                                            End Using
                                        End If
                                    End Using
                                End If
                            Case "050_af_webfilemanager"
                                If MsgBox("Installare AF Web File Manager?",MsgBoxStyle.YesNo,"AF Web File Manager")=MsgBoxResult.Yes
                                    Using fdt As New FolderBrowserDialog() With {.Description = "Selezionare la cartella di destinazione dei files"}
                                        If fdt.ShowDialog =DialogResult.OK
                                            Using ms As New System.IO.MemoryStream
                                                ZE.Extract(ms)
                                                if Not Archive_To_Directory(ms,fdt.SelectedPath)
                                                    Return
                                                else
                                                    appinstalled += 1
                                                End If
                                            End Using 
                                        End If
                                    End Using
                                End If
                            Case else
                                If ZE.FileName.StartsWith("100_dependencies")
                                    Dim FI as New IO.FileInfo(ZE.FileName)
                                    If MsgBox("Installare la dipendenza " & FI.name & "?",MsgBoxStyle.YesNo,FI.Name)=MsgBoxResult.Yes
                                        If String.IsNullOrWhiteSpace(dipdir) Then dipdir = gettempdirectory
                                        ZE.Extract(dipdir)
                                        Shell(dipdir & "\" & FI.Name, AppWinStyle.NormalFocus,True)
                                        dipinstalled+=1
                                    End If
                                End If
                        End Select
                    Next
                End Using
            Else
                MsgBox("Installazione Annullata", MsgBoxStyle.Exclamation,"Installazione Annullata")
            End If
        End Using
        If appinstalled > 0 OrElse dipinstalled > 0
            MsgBox("Applicazioni Installate : " & appinstalled & vbCrLf & "Dipendenze Installate : " & dipinstalled,MsgBoxStyle.Information,"Riepilogo Installazione")
        End If
    End sub


    Private Class ZipEntry
        Public property isfolder As Boolean=False
        Public property folder As String
        Public property file As Byte()
        Public property archivename As String
        Public sub New(folder As String,file As Byte(),isfolder As Boolean, archivename As String)
            Me.folder = folder
            Me.file = file
            Me.isfolder = isfolder
            Me.archivename = archivename
        End sub
    End Class
    Private shared Function CreateZipRecursive(items As IEnumerable(Of ZipEntry)) As Byte()
        Dim NewList As New List(Of ZipEntry)
        For each ZE As ZipEntry In items.ToList.FindAll(Function(m) m.isfolder = True)
            Using ms As New System.IO.MemoryStream
                Using Z As New Ionic.Zip.ZipFile()
                    For each file As String In My.Computer.FileSystem.GetFiles(ZE.folder, FileIO.SearchOption.SearchAllSubDirectories)
                        Dim FI As New System.IO.FileInfo(file)
                        Dim directory As String = FI.DirectoryName.Substring(ZE.folder.Length)
                        Z.AddEntry((directory & "\" & FI.Name).Trim("\"),My.Computer.FileSystem.ReadAllBytes(FI.FullName))
                    Next
                    Z.Save(ms)
                    NewList.Add(New ZipEntry("",ms.ToArray,False,ZE.archivename))
                End Using
            End Using
        Next
        NewList.AddRange(items.ToList.FindAll(Function(m) m.isfolder = False).ToArray)
        Dim tempfile As String = gettempfilename
        Using ms As New System.IO.MemoryStream
            Using Z As New Ionic.Zip.ZipFile()
                For each ZE As ZipEntry In NewList
                    Z.AddEntry(ZE.archivename,ZE.file)
                Next
                Z.Save(ms)
            End Using
            Return ms.ToArray
        End Using
    End Function


    Private shared function gettempfilename As String
        Dim tempdir As String = My.Computer.FileSystem.SpecialDirectories.Temp
        Return tempdir & "\" & Guid.NewGuid.ToString.Replace("-","")
    End function
    Private shared function gettempdirectory As String
        Dim tempdir As String = My.Computer.FileSystem.SpecialDirectories.Temp
        Dim targetdir As String = tempdir & "\" & Guid.NewGuid.ToString.Replace("-","")
        My.Computer.FileSystem.CreateDirectory(targetdir)
        Return targetdir
    End function
End Class
