Imports System.Web.Mvc
Imports System.Web.Routing

Public Class Global_asax
    Inherits HttpApplication

    Sub Application_Start(sender As Object, e As EventArgs)
        ' Fires when the application is started

        AreaRegistration.RegisterAllAreas()
        RouteConfig.RegisterRoutes(RouteTable.Routes)

        'Try
        Dim virtualDirName As String = HttpRuntime.AppDomainAppVirtualPath
        'AfCommon.AppSettings.InitSettings(Server.MapPath("/AF_WebFileManager") & "\websettings.config")
        AfCommon.AppSettings.InitSettings(Server.MapPath(virtualDirName) & "\websettings.config")
        'Catch ex As Exception

        'End Try

    End Sub
End Class