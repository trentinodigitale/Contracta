
Public Class MainClass

    private shared TR As System.Threading.Thread=Nothing
    Private shared ReadOnly ActiveServices As New Hashtable

    ''' <summary>
    ''' Inizializza il thread per la gestione delle applicazioni presenti nel file di configurazione del servizio (avvia e mantiene vive le applicazioni)
    ''' </summary>
    Public shared sub init
        TR=New System.Threading.Thread(AddressOf LookServices)
        TR.SetApartmentState(Threading.ApartmentState.STA)
        TR.Start
    End sub
    ''' <summary>
    ''' Killa brutalmente tutte le applicazioni che sono in esecuzione e monitorate al presente servizio
    ''' </summary>
    Public shared sub Abort
        While True
            Try
                For each k As String In ActiveServices.Keys
                    Dim P As System.Diagnostics.Process = ActiveServices(k)
                    If Not IsNothing(P) AndAlso Not P.HasExited Then P.Kill
                Next
                Exit While
            Catch ex As Exception

            End Try
        End While
        If Not IsNothing(TR) And TR.IsAlive Then TR.Abort
    End sub

    Private shared sub LookServices
        While True
            Try
                'READ CONFIG FILE
                Dim configfile As String = System.AppDomain.CurrentDomain.BaseDirectory() & "\config.txt"
                If Not My.Computer.FileSystem.FileExists(configfile)
                    My.Computer.FileSystem.WriteAllText(configfile,"",False)
                End If
                Using fs As New System.IO.FileStream(configfile,IO.FileMode.Open)
                    Using sr As New IO.StreamReader(fs)
                        While Not sr.EndOfStream
                            Dim line As String = sr.ReadLine
                            If String.IsNullOrWhiteSpace(line) Then Continue While
                            If line.Trim.StartsWith("#") Then Continue While

                            Dim filename As String = ""
                            Dim arguments As String = ""
                            If line.Contains(",") Then
                                filename = line.Substring(0, line.IndexOf(",")).Trim(",")
                                arguments = line.Substring(line.IndexOf(",") + 1).Trim(",")
                            Else
                                filename = line
                            End If
                            Dim key As String = filename & "_" & arguments

                            If ActiveServices.ContainsKey(key.ToLower) Then
                                Dim P As System.Diagnostics.Process = ActiveServices(key.ToLower)
                                If Not P.HasExited Then Continue While
                            End If

                            Dim SPI As New System.Diagnostics.ProcessStartInfo(filename, arguments)
                            SPI.WindowStyle = ProcessWindowStyle.Hidden
                            dim NP As System.Diagnostics.Process = System.Diagnostics.Process.Start(SPI)
                            ActiveServices(key.ToLower) = NP
                        End While
                    End Using
                End Using
            Catch ex As Exception
            End Try
            System.Threading.Thread.Sleep(5000)
        End While
    End sub
End Class
