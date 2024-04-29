

''' <summary>
''' La classe è un gestore di tabelle DATABASE Basate su Classi .NET definite e denominate con il tipo (T)
''' </summary>
Public Class DbClassTools
    Private shared ReadOnly FixedTables As New Hashtable

    ''' <summary>
    ''' restituisce il nome SQL della tabella che ospita la classe
    ''' </summary>
    ''' <param name="T"></param>
    ''' <param name="Dbm"></param>
    ''' <param name="Create"></param>
    ''' <returns></returns>

    Public shared function GetTableName(T As System.Type, Optional Dbm As DatabaseManager = Nothing, Optional Create As Boolean = False) As String
        If Create
            DbClassTools.CreateTable(T,dbm,nothing)
        End If
        Return T.FullName.Replace(".","_").Trim("_")
    End Function

    Private Shared Function GetTypeFields(t As Type) As List(Of String)
        Dim ret As New List(Of String)
        For Each P As System.Reflection.PropertyInfo In GetDbProperties(t)
            If P.GetIndexParameters.Length = 0 Then
                ret.Add(P.Name)
            End If
        Next
        Return ret
    End Function

    Private Shared Function GetDbProperties(T As Type) As System.Reflection.PropertyInfo()

        '---
        '-- tutte le proprietà della classe che iniziano per "_" non vengono usate per il DB. ma trattate solo per un uso locale
        '---

        Dim localProps As New List(Of System.Reflection.PropertyInfo)

        For Each P As System.Reflection.PropertyInfo In T.GetProperties

            If Not P.Name.StartsWith("_") Then
                localProps.Add(P)
            End If

        Next

        Return localProps.ToArray

    End Function

    ''' <summary>
    ''' Crea la tabella SQL se non presente
    ''' </summary>
    ''' <param name="T"></param>
    ''' <param name="Dbm"></param>
    ''' <param name="I"></param>
    ''' <param name="InsertFields"></param>
    ''' <param name="InsertParams"></param>
    ''' <param name="ParamValues"></param>
    ''' <param name="UpdateFields"></param>
    ''' <returns></returns>
    Private shared function CreateTable(T As Type, Dbm As DatabaseManager,I As Object, _
                                         Optional byref InsertFields As List(Of String) = Nothing,optional byref InsertParams As List(Of String) = Nothing, _
                                         Optional byref ParamValues As Hashtable = Nothing,Optional byref UpdateFields As List(Of String) = Nothing) As String
        Dim DbFields As New List(Of KeyValuePair(Of String,String))
        InsertFields  = New List(Of String)
        InsertParams = New List(Of String)
        ParamValues = New Hashtable
        UpdateFields = New List(Of String)

        For Each P As System.Reflection.PropertyInfo In GetDbProperties(T)
            Select Case P.PropertyType.FullName
                Case GetType(String).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "varchar(max)"))
                Case GetType(Integer).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "int NOT NULL"))
                Case GetType(Integer?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "int"))
                Case GetType(Long).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "bigint NOT NULL"))
                Case GetType(Long?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "bigint"))
                Case GetType(Double).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "float NOT NULL"))
                Case GetType(Double?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "float"))
                Case GetType(DateTime).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "datetime NOT NULL"))
                Case GetType(DateTime?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "datetime"))
                Case GetType(Boolean).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "bit NOT NULL"))
                Case GetType(Boolean?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "bit"))
                Case GetType(Byte()).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "varbinary(max)"))
                Case GetType(Guid).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "uniqueidentifier NOT NULL"))
                Case GetType(Guid?).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "uniqueidentifier"))
                Case GetType(Hashtable).FullName
                    DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "nvarchar(max)"))
                Case Else
                    If P.PropertyType.IsEnum Then
                        DbFields.Add(New KeyValuePair(Of String, String)(P.Name, "int"))
                    Else
                        Throw New Exception("Invalid Property Type For [" & P.PropertyType.FullName & "]")
                    End If
            End Select
            If DbFields.Last.Key.ToLower = "id" Then

                If DbFields.Last.Value = "varchar(max)" Then
                    DbFields(DbFields.Count - 1) = New KeyValuePair(Of String, String)(DbFields.Last.Key, "varchar(450)")
                End If
            End If


            If Not IsNothing(I) Then
                Dim value As Object = P.GetValue(I, Nothing)
                If Not IsNothing(value) Then

                    Select Case P.PropertyType.FullName
                        Case GetType(Hashtable).FullName
                            value = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(value)
                        Case Else
                            If P.PropertyType.IsEnum Then
                                value = CInt(value)
                            End If
                    End Select
                End If


                If Not IsNothing(value) Then
                    InsertFields.Add("[" & P.Name & "]")
                    InsertParams.Add("@" & P.Name)
                    ParamValues("@" & P.Name) = value
                    UpdateFields.Add("[" & P.Name & "] = @" & P.Name)
                Else
                    UpdateFields.Add("[" & P.Name & "] = NULL")
                End If
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
        Dim tablename As String = GetTableName(T)
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
        Return tablename
    End function

    ''' <summary>
    ''' Salva un elemento nella tabella corrispondente il suo tipo (T) con insert opzionale
    ''' </summary>
    ''' <param name="I"></param>
    ''' <param name="Dbm"></param>
    ''' <param name="DoInsert">Indica se effettuare una insert oppure no</param>
    ''' <param name="tablename">Nome della tabella che compete il tipo</param>
    Public Shared Sub fx_save_instance(I As Object, Dbm As DatabaseManager, DoInsert As Boolean, Optional ByRef tablename As String = "", Optional DO_UPDATE As Boolean = True)
        Dim ParamValues As New Hashtable
        Dim UpdateFields As New List(Of String)
        Dim InsertFields As New List(Of String)
        Dim InsertParams As New List(Of String)
        tablename = CreateTable(I.GetType, Dbm, I, InsertFields, InsertParams, ParamValues, UpdateFields)

        If DoInsert Then
            Dim command As String = ""
            If DO_UPDATE Then
                command = "
                                        IF NOT EXISTS(SELECT [id] FROM [" & tablename & "] with(nolock) WHERE id = @id)
                                            BEGIN
                                                INSERT INTO [" & tablename & "](" & String.Join(",", InsertFields.ToArray) & ") VALUES (" & String.Join(",", InsertParams.ToArray) & ")
                                            END
                                        ELSE
                                            BEGIN
                                                UPDATE [" & tablename & "] SET " & String.Join(",", UpdateFields.ToArray) & " WHERE [id] = @id
                                            END                                "

            Else
                command = "
                                        IF NOT EXISTS(SELECT [id] FROM [" & tablename & "] with(nolock) WHERE id = @id)
                                            BEGIN
                                                INSERT INTO [" & tablename & "](" & String.Join(",", InsertFields.ToArray) & ") VALUES (" & String.Join(",", InsertParams.ToArray) & ")
                                            END
                                       "
            End If
            Dim affected As Integer = Dbm.ExecuteNonQuery(command, ParamValues)
        End If
    End Sub

    ''' <summary>
    ''' Salva l'istanza di un oggetto nella tabella corrispondente il suo tipo (T)
    ''' </summary>
    ''' <param name="I"></param>
    ''' <param name="Dbm"></param>
    ''' <param name="tablename"></param>
    Public Shared Sub fx_save_instance(I As Object, Dbm As DatabaseManager, Optional ByRef tablename As String = "", Optional DO_UPDATE As Boolean = True)
        DbClassTools.fx_save_instance(I, Dbm, True, tablename, DO_UPDATE)
    End Sub
    ''' <summary>
    ''' Aggiorna una istanza di tipo (T) con i campi indicati
    ''' </summary>
    ''' <typeparam name="T"></typeparam>
    ''' <param name="O"></param>
    ''' <param name="idvalue"></param>
    ''' <param name="fields"></param>
    ''' <param name="Dbm"></param>
    ''' <param name="excludedfields"></param>
    Public shared sub fx_update_instance(Of T)(O As T, idvalue As Object, fields As Hashtable,Dbm As DatabaseManager,excludedfields As String())
        DbClassTools.fx_save_instance(O,Dbm,False)
        Dim ParamValues As new Hashtable
        Dim UpdateFields As New List(Of String)

        For Each P As System.Reflection.PropertyInfo In GetDbProperties(GetType(T))

            If IsNothing(excludedfields) OrElse excludedfields.Length = 0 Then
                If Not fields.ContainsKey(P.Name) Then Continue For
            ElseIf excludedfields.ToList.Contains(P.Name) Then
                Continue For
            End If
            Dim value As Object = Nothing
            If Not IsNothing(fields) Then
                value = fields(P.Name)
            Else
                value = P.GetValue(O, Nothing)
            End If
            If Not IsNothing(value) Then

                Select Case P.PropertyType.FullName
                    Case GetType(Hashtable).FullName
                        value = AfCommon.Tools.Serialization.JsonSerialize(Of Hashtable)(value)
                End Select
            End If
            If Not IsNothing(value) Then
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


    ''' <summary>
    ''' restituisce l'istanza di un oggetto di tipo (T) in base al suo id
    ''' </summary>
    ''' <typeparam name="T"></typeparam>
    ''' <param name="id"></param>
    ''' <param name="Dbm"></param>
    ''' <param name="fields"></param>
    ''' <param name="ExcludeFields"></param>
    ''' <param name="tablename"></param>
    ''' <returns></returns>
    Public Shared Function fx_get_instance(Of T)(id As Object, Dbm As DatabaseManager, fields As String(), Optional ExcludeFields As Boolean = False, Optional ByRef tablename As String = "", Optional withNoLock As Boolean = False) As T
        Dim I As T = Nothing
        Dim params As New Hashtable
        params("@id") = id
        tablename = GetTableName(Activator.CreateInstance(Of T).GetType)
        Dim query As String = "SELECT * FROM [" & tablename & "] " & If(withNoLock, "with(nolock)", "") & " WHERE [id] = @id"
        Dim AllFields As List(Of String) = GetTypeFields(GetType(T))
        Dim Flist As New List(Of String)
        If Not IsNothing(fields) AndAlso fields.Length > 0 Then

            If Not ExcludeFields Then

                For fn As Integer = 0 To fields.Length - 1
                    If Not fields(fn).StartsWith("[") Then fields(fn) = "[" & fields(fn)
                    If Not fields(fn).EndsWith("]") Then fields(fn) = fields(fn) & "]"
                    Flist.Add(fields(fn))
                Next
            Else
                For Each f As String In AllFields
                    If fields.ToArray.Contains(f) Then Continue For
                    Flist.Add("[" & f & "]")
                Next
            End If
            query = "SELECT " & String.Join(",", Flist.ToArray) & " FROM [" & GetTableName(Activator.CreateInstance(Of T).GetType) & "] " & If(withNoLock, "with(nolock)", "") & " WHERE [id] = @id"
        End If
        Using dr As SqlClient.SqlDataReader = Dbm.ExecuteReader(query, params)
            Dim columns As New Hashtable
            For cnpos As Integer = 0 To dr.FieldCount - 1
                Dim name As String = dr.GetName(cnpos)
                columns(name.Trim.ToLower) = cnpos
            Next
            If dr.Read Then
                I = Activator.CreateInstance(Of T)

                For Each P As System.Reflection.PropertyInfo In GetDbProperties(I.GetType)

                    If columns.ContainsKey(P.Name.ToLower) Then
                        Dim value As Object = dr(P.Name)
                        If Not IsNothing(value) AndAlso IsDBNull(value) Then
                            value = Nothing
                        End If
                        Select Case P.PropertyType.FullName
                            Case GetType(Hashtable).FullName
                                If IsNothing(value) OrElse String.IsNullOrWhiteSpace(value) Then
                                    value = New Hashtable
                                Else
                                    value = AfCommon.Tools.Serialization.JsonDeserialize(Of Hashtable)(value)
                                End If
                        End Select
                        P.SetValue(I, value, Nothing)
                    Else
                        P.SetValue(I, Nothing, Nothing)
                    End If
                Next
            End If
        End Using
        Return I
    End Function
End Class
