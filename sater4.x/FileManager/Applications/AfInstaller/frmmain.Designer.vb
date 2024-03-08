<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frmmain
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
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

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.cmd_create_setup = New System.Windows.Forms.Button()
        Me.cmd_deploy_setup = New System.Windows.Forms.Button()
        Me.SuspendLayout
        '
        'cmd_create_setup
        '
        Me.cmd_create_setup.Font = New System.Drawing.Font("Microsoft Sans Serif", 13.8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0,Byte))
        Me.cmd_create_setup.Location = New System.Drawing.Point(29, 24)
        Me.cmd_create_setup.Name = "cmd_create_setup"
        Me.cmd_create_setup.Size = New System.Drawing.Size(351, 57)
        Me.cmd_create_setup.TabIndex = 1
        Me.cmd_create_setup.Text = "Crea File di Installazione"
        Me.cmd_create_setup.UseVisualStyleBackColor = true
        '
        'cmd_deploy_setup
        '
        Me.cmd_deploy_setup.Font = New System.Drawing.Font("Microsoft Sans Serif", 13.8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0,Byte))
        Me.cmd_deploy_setup.Location = New System.Drawing.Point(29, 114)
        Me.cmd_deploy_setup.Name = "cmd_deploy_setup"
        Me.cmd_deploy_setup.Size = New System.Drawing.Size(351, 57)
        Me.cmd_deploy_setup.TabIndex = 2
        Me.cmd_deploy_setup.Text = "Distribuisci Installazione"
        Me.cmd_deploy_setup.UseVisualStyleBackColor = true
        '
        'frmmain
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(8!, 16!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(425, 204)
        Me.Controls.Add(Me.cmd_deploy_setup)
        Me.Controls.Add(Me.cmd_create_setup)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.MaximizeBox = false
        Me.Name = "frmmain"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "AF Installation Assistant"
        Me.ResumeLayout(false)

End Sub

    Friend WithEvents cmd_create_setup As Button
    Friend WithEvents cmd_deploy_setup As Button
End Class
