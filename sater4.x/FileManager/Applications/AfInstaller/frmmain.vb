Public Class frmmain
    Private Sub cmd_create_setup_Click(sender As Object, e As EventArgs) Handles cmd_create_setup.Click
        Try
            SetupManager.fx_create_Setup()
        Catch ex As Exception
            MsgBox(ex.Message,MsgBoxStyle.Critical,"Errore nella creazione del setup")
        End Try
        
    End Sub

    Private Sub cmd_deploy_setup_Click(sender As Object, e As EventArgs) Handles cmd_deploy_setup.Click
        Try
            SetupManager.fx_deploy_Setup()
        Catch ex As Exception
            MsgBox(ex.Message,MsgBoxStyle.Critical,"Errore di installazione")
        End Try        
    End Sub
End Class