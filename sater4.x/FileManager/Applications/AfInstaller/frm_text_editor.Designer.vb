<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frm_text_editor
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
        Me.components = New System.ComponentModel.Container()
        Me.pnl_buttons = New System.Windows.Forms.Panel()
        Me.cmd_cancel = New System.Windows.Forms.Button()
        Me.cmd_save = New System.Windows.Forms.Button()
        Me.ContextMenuStrip1 = New System.Windows.Forms.ContextMenuStrip(Me.components)
        Me.txt_content = New System.Windows.Forms.TextBox()
        Me.pnl_buttons.SuspendLayout
        Me.SuspendLayout
        '
        'pnl_buttons
        '
        Me.pnl_buttons.Controls.Add(Me.cmd_cancel)
        Me.pnl_buttons.Controls.Add(Me.cmd_save)
        Me.pnl_buttons.Dock = System.Windows.Forms.DockStyle.Bottom
        Me.pnl_buttons.Location = New System.Drawing.Point(0, 458)
        Me.pnl_buttons.Name = "pnl_buttons"
        Me.pnl_buttons.Size = New System.Drawing.Size(1046, 82)
        Me.pnl_buttons.TabIndex = 1
        '
        'cmd_cancel
        '
        Me.cmd_cancel.Font = New System.Drawing.Font("Microsoft Sans Serif", 13.8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0,Byte))
        Me.cmd_cancel.Location = New System.Drawing.Point(193, 13)
        Me.cmd_cancel.Name = "cmd_cancel"
        Me.cmd_cancel.Size = New System.Drawing.Size(161, 57)
        Me.cmd_cancel.TabIndex = 1
        Me.cmd_cancel.Text = "Annulla"
        Me.cmd_cancel.UseVisualStyleBackColor = true
        '
        'cmd_save
        '
        Me.cmd_save.Font = New System.Drawing.Font("Microsoft Sans Serif", 13.8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0,Byte))
        Me.cmd_save.Location = New System.Drawing.Point(14, 13)
        Me.cmd_save.Name = "cmd_save"
        Me.cmd_save.Size = New System.Drawing.Size(161, 57)
        Me.cmd_save.TabIndex = 0
        Me.cmd_save.Text = "Salva"
        Me.cmd_save.UseVisualStyleBackColor = true
        '
        'ContextMenuStrip1
        '
        Me.ContextMenuStrip1.ImageScalingSize = New System.Drawing.Size(20, 20)
        Me.ContextMenuStrip1.Name = "ContextMenuStrip1"
        Me.ContextMenuStrip1.Size = New System.Drawing.Size(61, 4)
        '
        'txt_content
        '
        Me.txt_content.Dock = System.Windows.Forms.DockStyle.Fill
        Me.txt_content.Font = New System.Drawing.Font("Microsoft Sans Serif", 10.2!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0,Byte))
        Me.txt_content.Location = New System.Drawing.Point(0, 0)
        Me.txt_content.MaxLength = 0
        Me.txt_content.Multiline = true
        Me.txt_content.Name = "txt_content"
        Me.txt_content.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txt_content.Size = New System.Drawing.Size(1046, 458)
        Me.txt_content.TabIndex = 3
        Me.txt_content.WordWrap = false
        '
        'frm_text_editor
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(8!, 16!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(1046, 540)
        Me.Controls.Add(Me.txt_content)
        Me.Controls.Add(Me.pnl_buttons)
        Me.Name = "frm_text_editor"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent
        Me.Text = "Text Editor"
        Me.pnl_buttons.ResumeLayout(false)
        Me.ResumeLayout(false)
        Me.PerformLayout

End Sub

    Friend WithEvents pnl_buttons As Panel
    Friend WithEvents cmd_cancel As Button
    Friend WithEvents cmd_save As Button
    Friend WithEvents ContextMenuStrip1 As ContextMenuStrip
    Friend WithEvents txt_content As TextBox
End Class
