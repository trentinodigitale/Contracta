Imports System.ServiceProcess

Public Class AfService

    Protected Overrides Sub OnStart(ByVal args() As String)
        MainClass.init
    End Sub

    Protected Overrides Sub OnStop()
        MainClass.Abort
    End Sub

End Class
