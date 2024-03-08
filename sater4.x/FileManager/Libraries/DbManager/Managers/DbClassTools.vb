Public Class DbClassTools
    Private shared FixedTables As New Hashtable

    Public shared function GetTableName(T As System.Type) As String
        Return T.FullName.Replace(".","_").Trim("_")
    End function

    Private shared function GetTypeFields(t As Type) As List(Of String)
        Dim ret As New List(Of String)
        For each P As System.Reflection.PropertyInfo In t.GetProperties
            If P.GetIndexParameters.Length = 0
                ret.Add(P.Name)
            End If
        Next
        Return ret
    End function
    Public shared Sub fx_save_instance(I As Object, Dbm As DatabaseManager,DoInsert As Boolean)
        Dim DbFields As New List(Of KeyValuePair(Of String,String))

        Dim InsertFields As New List(Of String)
        Dim InsertParams As New List(Of String)
        Dim ParamValues As new Hashtable
        Dim UpdateFields As New List(Of String)
        For each P As System.Reflection.PropertyInfo In I.GetType.GetProperties
            Select Case P.PropertyType.FullName
                Case GetType(String).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"varchar(max)"))
                Case GetType(Integer).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"int NOT NULL"))
                Case GetType(Integer?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"int"))
                Case GetType(Long).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"bigint NOT NULL"))
                Case GetType(Long?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"bigint"))
                Case GetType(Double).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"float NOT NULL"))
                Case GetType(Double?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"float"))
                Case GetType(DateTime).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"datetime NOT NULL"))
                Case GetType(DateTime?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"datetime"))
                Case GetType(Boolean).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"bit NOT NULL"))
                Case GetType(Boolean?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"bit"))
                Case GetType(Byte()).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"varbinary(max)"))
                Case GetType(Guid).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"uniqueidentifier NOT NULL"))
                Case GetType(Guid?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"uniqueidentifier"))
                Case GetType(Hashtable).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"nvarchar(max)"))                             
                Case Else
                    If P.PropertyType.IsEnum
                        DbFields.Add(New KeyValuePair(Of String, String)(P.Name,"int"))                             
                    Else
                        Throw New Exception("Invalid Property Type For [" & P.PropertyType.FullName & "]")
                    End If                    
            End Select
            If DbFields.Last.Key.ToLower = "id"
                If DbFields.Last.Value = "varchar(max)"
                    DbFields(DbFields.Count-1) = New KeyValuePair(Of String, String)(DbFields.Last.Key,"varchar(450)")
                End If
            End If
            

            Dim value As Object = P.GetValue(I,Nothing)
            If Not IsNothing(value)
                Select Case P.PropertyType.FullName
                    Case GetType(Hashtable).FullName
                        value = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(value)
                    Case Else
                        If P.PropertyType.IsEnum
                            value = CInt(value)
                        End If
                End Select
            End If
            

            If Not IsNothing(value)
                InsertFields.Add("[" & P.Name & "]")
                InsertParams.Add("@" & P.Name)
                ParamValues("@" & P.Name) = value    
                UpdateFields.Add("[" & P.Name & "] = @" & P.Name)            
            Else
                UpdateFields.Add("[" & P.Name & "] = NULL")
            End If            
        Next

        Dim fields As New List(Of String)
        Dim keys As New List(Of String)
        For each Dbf As KeyValuePair(Of String,String) in DbFields
            fields.Add("[" & Dbf.Key & "] " & Dbf.Value)
            If Dbf.Key.ToLower = "id"
                keys.Add("[" & Dbf.Key & "] ASC")
            End If
        Next
        Dim tablename As String = GetTableName(I.GetType)
        If Not FixedTables.ContainsKey(tablename.Trim.ToLower)
            'VERIFICA L'ESISTENZA DELLA TABELLA
            Dim params As New Hashtable
            params("@tablename") = tablename
            Dim TableExists As Boolean=False
            Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader("SELECT [name] FROM sysobjects WHERE name = @tablename and xtype='U'",params)
                TableExists = dr.Read
            End Using
            If Not TableExists
                'CREATE TABLE
                Dim queryNewTable As New List(Of String)
                With queryNewTable
                    .Add("      SET ANSI_NULLS ON")
                    .Add("      SET QUOTED_IDENTIFIER ON")
                    .Add("      SET ANSI_PADDING ON")
                    .Add("      CREATE TABLE [dbo].[" & tablename & "](")
                    'ADD FIELDS
                    .Add("                  " & String.Join("," & vbCrLf,fields.ToArray) & ",")
                    .Add(vbCrLf)
                    .Add("                  CONSTRAINT [PK_"  & tablename & "] PRIMARY KEY CLUSTERED")
                    .Add("                  (")
                    .Add("                  " & String.Join(",",keys.ToArray))
                    .Add("                  ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]")
                    .Add("      ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]")
                    .Add("      SET ANSI_PADDING OFF")
                End With
                Dbm.ExecuteNonQuery(String.Join(vbCrLf,queryNewTable.ToArray),Nothing)
            End If
            FixedTables(tablename.Trim.ToLower) = True              
        End If

        If DoInsert
            Dim command As String = "
                                        IF NOT EXISTS(SELECT [id] FROM [" & tablename & "] WHERE id = @id)
                                            BEGIN
                                                INSERT INTO [" & tablename & "](" & String.Join(",",InsertFields.ToArray) & ") VALUES (" & String.Join(",",InsertParams.ToArray) & ")
                                            END
                                        ELSE
                                            BEGIN
                                                UPDATE [" & tablename & "] SET " & String.Join(",",UpdateFields.ToArray) &  " WHERE [id] = @id
                                            END                                "
            dim affected As Integer = Dbm.ExecuteNonQuery(command,ParamValues)
        End If        
    End Sub

    Public shared Sub fx_save_instance(I As Object,Dbm As DatabaseManager)
        DbClassTools.fx_save_instance(I,Dbm,True)
    End Sub
    Public shared sub fx_update_instance(Of T)(O As T, idvalue As Object, fields As Hashtable,Dbm As DatabaseManager,excludedfields As String())
        DbClassTools.fx_save_instance(O,Dbm,False)
        Dim ParamValues As new Hashtable
        Dim UpdateFields As New List(Of String)
        For each P As System.Reflection.PropertyInfo In GetType(T).GetProperties            
            If IsNothing(excludedfields) OrElse excludedfields.Length = 0
                If Not fields.ContainsKey(P.Name) Then Continue For
            ElseIf excludedfields.ToList.Contains(P.Name)
                Continue For                
            End If
            Dim value As Object = Nothing
            If Not IsNothing(fields)
                value = fields(P.Name)
            Else
                value = P.GetValue(O,Nothing)
            End If
            If Not IsNothing(value)
                Select Case P.PropertyType.FullName
                    Case GetType(Hashtable).FullName
                        value = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(value)
                End Select
            End If
            If Not IsNothing(value)
                ParamValues("@" & P.Name) = value    
                UpdateFields.Add("[" & P.Name & "] = @" & P.Name)            
            Else
                UpdateFields.Add("[" & P.Name & "] = NULL")
            End If
        Next
        ParamValues("@id") = idvalue                
        Dim tablename As String = GetTableName(GetType(T))
        Dim command As String = "UPDATE [" & tablename & "] SET " & String.Join(",",UpdateFields.ToArray) &  " WHERE [id] = @id"
        Dbm.ExecuteNonQuery(command,ParamValues)
    End sub

    Public shared function fx_get_instance(Of T)(id As Object,Dbm As DatabaseManager,fields As String(),Optional ExcludeFields As Boolean = False) As T
        Dim I As T = Nothing
        Dim params As New Hashtable
        params("@id") = id
        Dim query As String = "SELECT * FROM [" & GetTableName(Activator.CreateInstance(Of T).GetType) & "] WHERE [id] = @id"
        
        Dim AllFields As List(Of String) = GetTypeFields(GetType(T))
        Dim Flist As New List(Of String)
        If Not IsNothing(fields) AndAlso fields.Length > 0
            If Not ExcludeFields
                For fn As Integer = 0 To fields.Length - 1
                    If Not fields(fn).StartsWith("[") Then fields(fn) = "[" & fields(fn)
                    If Not fields(fn).EndsWith("]") Then fields(fn) = fields(fn) & "]"
                    Flist.Add(fields(fn))
                Next
            Else
                For each f As String In AllFields
                    If fields.ToArray.Contains(f) Then Continue For 
                    Flist.Add("[" & f & "]")
                Next
            End If
            query = "SELECT " & String.Join(",",Flist.ToArray) & " FROM [" & GetTableName(Activator.CreateInstance(Of T).GetType) & "] WHERE [id] = @id"
        End If
        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(query,params)
            Dim columns As New Hashtable
            For cnpos As Integer = 0 To dr.FieldCount -1
                Dim name As String = dr.GetName(cnpos)
                columns(name.Trim.ToLower) = cnpos
            Next
            If dr.Read
                I = Activator.CreateInstance(Of T)
                For each P As System.Reflection.PropertyInfo In I.GetType.GetProperties
                    If Columns.ContainsKey(P.Name.ToLower)
                        Dim value As Object = dr(P.Name)
                        If Not IsNothing(value) AndAlso IsDBNull(value) Then 
                            value = Nothing
                        End If
                        Select Case P.PropertyType.FullName
                            Case GetType(Hashtable).FullName
                                If IsNothing(value) OrElse String.IsNullOrWhiteSpace(value)
                                    value = New Hashtable
                                Else
                                    value = AfCommon.Tools.Serialization.JsonDeserialize(Of Hashtable)(value)
                                End If
                        End Select
                        P.SetValue(I,value,Nothing)
                    Else
                        P.SetValue(I,Nothing,Nothing)
                    End If
                Next
            End If
        End Using
        Return I
    End function
End Class
