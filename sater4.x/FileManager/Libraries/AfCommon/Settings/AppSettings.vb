Public Class AppSettings
    Private shared _item As SettingsManager
    Private shared settingsfile As String = ""
    Public Shared ReadOnly Property item As SettingsManager
        Get
            If IsNothing(_item) Then Throw New Exception("SettingsManager Not Initialized")
            Return _item
        End Get
    End Property

    Public shared sub InitSettings(_settingsfile As String)        
        AppSettings.settingsfile = _settingsfile
        _item = New SettingsManager(appsettings.settingsfile)
    End sub
End Class
