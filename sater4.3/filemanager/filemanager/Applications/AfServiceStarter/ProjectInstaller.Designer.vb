<System.ComponentModel.RunInstaller(True)> Partial Class ProjectInstaller
    Inherits System.Configuration.Install.Installer

    'Installer overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Component Designer
    'It can be modified using the Component Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.SPI = New System.ServiceProcess.ServiceProcessInstaller()
        Me.SI = New System.ServiceProcess.ServiceInstaller()
        '
        'SPI
        '
        Me.SPI.Account = System.ServiceProcess.ServiceAccount.LocalSystem
        Me.SPI.Password = Nothing
        Me.SPI.Username = Nothing
        '
        'SI
        '
        Me.SI.DisplayName = "AfServiceStarter"
        Me.SI.ServiceName = "AfServiceStarter"
        Me.SI.StartType = System.ServiceProcess.ServiceStartMode.Automatic
        '
        'ProjectInstaller
        '
        Me.Installers.AddRange(New System.Configuration.Install.Installer() {Me.SPI, Me.SI})

End Sub

    Friend WithEvents SPI As ServiceProcess.ServiceProcessInstaller
    Friend WithEvents SI As ServiceProcess.ServiceInstaller
End Class
