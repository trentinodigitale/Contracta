Public Class frm_text_editor
    Public Sub New(content As String)
        ' This call is required by the designer.
        InitializeComponent()        
        Me.content = content
        Me.txt_content.Text = Me.content                
    End Sub

    Public property content As String = ""
    Private Sub cmd_save_Click(sender As Object, e As EventArgs) Handles cmd_save.Click
        Me.content = Me.txt_content.Text
        Me.Close
    End Sub
    Private Sub cmd_cancel_Click(sender As Object, e As EventArgs) Handles cmd_cancel.Click
        Me.Close
    End Sub
End Class