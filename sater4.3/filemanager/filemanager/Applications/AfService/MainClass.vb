Imports AfCommon

Public Class MainClass



    Private Shared Sub ApplicactionUnHandledException(ByVal sender As Object, ByVal e As UnhandledExceptionEventArgs)

        Dim EX As Exception = e.ExceptionObject

        If Debugger.IsAttached Then
            Console.WriteLine("Press key to exit...")
            Console.ReadLine()
        End If

        Try


            Using dbm As New CTLDB.DatabaseManager(False, Nothing)

                dbm.traceError(EX, False)

            End Using


        Catch ex2 As Exception

        End Try

        End

    End Sub

    Public Shared Sub main(args() As String)

        AddHandler AppDomain.CurrentDomain.UnhandledException, AddressOf ApplicactionUnHandledException

        AfCommon.Tools.ConsoleTools.ApplyConsoleTricks()
        Dim runid As String = ""
        Dim settingsfile As String = "appsettings.config"
        If Not IsNothing(args) AndAlso args.Length > 0 Then

            For Each arg As String In args
                If arg.StartsWith("settingsfile:") Then
                    settingsfile = arg.Substring(arg.IndexOf(":", StringComparison.Ordinal) + 1)
                ElseIf arg.StartsWith("exec:") Then
                    runid = arg.Substring(arg.IndexOf(":", StringComparison.Ordinal) + 1)
                End If
            Next
        End If
        AppSettings.InitSettings(settingsfile)
        If Not String.IsNullOrWhiteSpace(runid) Then
            Dim s() As String = runid.Trim.Split("@")
            AfServiceLibrary.AfServiceManager.fx_run_worker(s(0), s(1))
        Else
            Console.ForegroundColor = ConsoleColor.Green
            Console.WriteLine("Job Service Ready")
            Console.ResetColor()

            '-- avvio del thread principale. dedicato alla gestione dei job 
            AfServiceLibrary.AfServiceManager.StartJobOrchestrator()

            '-- avvio del thread di pulizia dei file
            StorageManager.BlobManager.fx_init_purger()

            '-- avvio del thread di alert mail
            AfServiceLibrary.MailSenderManager.fx_init_mailsender()

            Do
                Console.ReadLine()
            Loop

        End If

    End Sub

End Class
