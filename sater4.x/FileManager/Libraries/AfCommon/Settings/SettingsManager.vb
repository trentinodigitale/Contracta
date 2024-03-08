Public Class SettingsManager
    Public property settingsfile As String
    Public sub New(settingsfile As String)
        Me.settingsfile = settingsfile
    End sub
    Private Settings As Hashtable = Nothing
    Private LastUpdate As DateTime? = Nothing
    Private checkOk As Boolean = False

    Default Public ReadOnly Property item(key As String) As String
        Get
            Dim ret As Object = getconfig(key)
            If IsNothing(ret) Then ret = String.Empty
            Return ret
        End Get
    End Property
    private function getconfig(key As String) As String
        If String.IsNullOrWhiteSpace(key) Then Return Nothing
        If String.IsNullOrWhiteSpace(Me.settingsfile) Then Throw New Exception("SettingsFile is empty")

        '-- se ho già verifico la presenza del file di config non accedo al file system
        If Not checkOk AndAlso Not My.Computer.FileSystem.FileExists(Me.settingsfile) Then

            'VERIFICA SE E' PRESENTE IL PATH
            If Me.settingsfile.Contains("/") OrElse Me.settingsfile.Contains("\") Then
                Throw New Exception("Settings file not set or not exists: " & Me.settingsfile)
            Else
                'SET CURRENT DIRECTORY
                Dim processTorun As String = System.Reflection.Assembly.GetEntryAssembly().Location
                Me.settingsfile = New System.IO.FileInfo(processTorun).DirectoryName & "\" & Me.settingsfile
            End If

        End If

        If Not checkOk AndAlso Not My.Computer.FileSystem.FileExists(Me.settingsfile) Then
            Throw New Exception("Settings file not set or not exists: " & Me.settingsfile)
        End If

        checkOk = True

        If IsNothing(Me.Settings) OrElse(Not LastUpdate.HasValue OrElse Date.Now.Subtract(LastUpdate.Value).TotalMinutes > 5) Then

            LastUpdate = Date.Now

            Dim NewSettings = New Hashtable

            Using ms As New System.IO.MemoryStream(My.Computer.FileSystem.ReadAllBytes(Me.settingsfile))
                Using sr As New System.IO.StreamReader(ms)
                    While Not sr.EndOfStream
                        Dim line As String = sr.ReadLine()
                        If String.IsNullOrWhiteSpace(line) Then Continue While
                        If line.Trim.StartsWith("--") OrElse line.Trim.StartsWith("'") OrElse line.Trim.StartsWith("//") Then Continue While
                        If line.Contains(":") Then
                            Dim skey As String = line.Substring(0, line.IndexOf(":", StringComparison.Ordinal)).Trim
                            Dim svalue As String = line.Substring(line.IndexOf(":", StringComparison.Ordinal) + 1).Trim
                            NewSettings(skey.Trim.ToLower) = svalue
                        End If
                    End While
                End Using
            End Using

            Me.Settings = NewSettings


        End If
        Return Me.Settings(key.Trim.ToLower)
    End function
End Class
