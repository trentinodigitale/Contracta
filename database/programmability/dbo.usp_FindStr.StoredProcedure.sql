USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_FindStr]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_FindStr] (@strIn VARCHAR(1000), @strOut VARCHAR(1000) = '', @GenUpd TINYINT = 0)
AS

DECLARE @TabName                        VARCHAR(80)
DECLARE @TabNameTmp                     VARCHAR(80)
DECLARE @ColName                        VARCHAR(80)
DECLARE @ColType                        VARCHAR(30)
DECLARE @SQLCmd                         VARCHAR(8000)
DECLARE @strTmp                         VARCHAR(8000)
DECLARE @strOrg                         VARCHAR(8000)
DECLARE @Div                            CHAR(1)


IF ISNULL(RTRIM(@strIn), '') = ''
BEGIN
        RAISERROR ('Parametro @strIn non valorizzato', 16, 1)
        RETURN 99
END

IF @GenUpd > 2
BEGIN
        SET @GenUpd = 0
END

IF @GenUpd > 0 AND ISNULL(RTRIM(@strOut), '') = ''
BEGIN
        RAISERROR ('Parametro @strOut non valorizzato', 16, 1)
        RETURN 99
END


SET @strOrg = @strIn
SET @strTmp = '''%' + @strIn + '%'''
SET @strIn  = '''''' + @strIn + ''''''
SET @strOut = '''''' + @strOut + ''''''


IF @GenUpd > 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' ' 
        PRINT 'BEGIN TRAN'
        PRINT ' ' 
END

DECLARE crs CURSOR STATIC FOR SELECT '[' + tab.Table_Name + ']'
                                   , '[' + col.Column_Name + ']'
                                   , col.Data_Type
                                   , CASE col.Data_Type 
                                          WHEN 'nchar'    THEN '2'
                                          WHEN 'ntext'    THEN '2'
                                          WHEN 'nvarchar' THEN '2'
                                          ELSE '1'
                                     END
                                FROM Information_Schema.Tables tab
                                   , Information_Schema.Columns col
                               WHERE tab.Table_Name = col.Table_Name
                                 AND tab.Table_Type = 'BASE TABLE'
                                 AND col.Data_Type IN ('char', 'nchar', 'ntext', 'text', 'nvarchar', 'varchar')
                                 AND col.Character_Maximum_Length >= LEN(@strOrg)
                              ORDER BY tab.Table_Name, col.Ordinal_Position
                              
OPEN crs 

FETCH NEXT FROM crs INTO @TabName, @ColName, @ColType, @Div

WHILE @@FETCH_STATUS = 0
BEGIN
        IF @GenUpd = 0
        BEGIN
                SET @SQLCmd = 
'IF EXISTS (SELECT * FROM ' + @TabName + ' WITH(NOLOCK) WHERE ' + @ColName + ' LIKE ' + @strTmp + ' AND DATALENGTH(' + @ColName + ') / ' + @Div + ' > 8000)
BEGIN
        PRINT ''*' + @TabName + ''' + REPLICATE ('' '', 50 - LEN(''' + @TabName + ''')) + ''' + @ColName + ''' + REPLICATE ('' '', 50 - LEN(''' + @ColName + ''')) + ''' + @ColType + '''
END
ELSE
IF EXISTS (SELECT * FROM ' + @TabName + ' WITH(NOLOCK) WHERE ' + @ColName + ' LIKE ' + @strTmp + ' AND DATALENGTH(' + @ColName + ') / ' + @Div + ' < 8000)
BEGIN
        PRINT '' ' + @TabName + ''' + REPLICATE ('' '', 50 - LEN(''' + @TabName + ''')) + ''' + @ColName + ''' + REPLICATE ('' '', 50 - LEN(''' + @ColName + ''')) + ''' + @ColType + '''
END'
        END
        ELSE
        IF @GenUpd = 1
        BEGIN
                SET @SQLCmd = 
'IF EXISTS (SELECT * FROM ' + @TabName + ' WITH(NOLOCK) WHERE ' + @ColName + ' LIKE ' + @strTmp + ')
BEGIN
PRINT 
''UPDATE ' + @TabName + '
   SET ' + @ColName + ' = REPLACE(CAST(' + @ColName + ' AS VARCHAR(8000)), ' + @strIn + ', ' + @strOut + ')' + '
 WHERE ' + @ColName + ' LIKE ''' + @strTmp + '''''
PRINT '' ''
PRINT
''IF @@ERROR <> 0
BEGIN
        RAISERROR (''''Errore "UPDATE" ' + @TabName + '.' + @ColName + ''''', 16, 1)
        ROLLBACK TRAN
        RETURN
END''
PRINT '' ''
END'
        END
        ELSE
        IF @GenUpd = 2
        BEGIN
                SET @TabNameTmp = REPLACE(REPLACE(@TabName, '[', ''), ']', '') + '_' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20), GETDATE(), 121), '-', ''), ':', ''), '.', ''), ' ', '')
                SET @SQLCmd = 
'IF EXISTS (SELECT * FROM ' + @TabName + ' WITH(NOLOCK) WHERE ' + @ColName + ' LIKE ' + @strTmp + ')
BEGIN
PRINT 
''SELECT * INTO [Save_' + @TabNameTmp + '] FROM ' + @TabName + '''
PRINT '' ''
PRINT
''UPDATE ' + @TabName + '
   SET ' + @ColName + ' = REPLACE(CAST(' + @ColName + ' AS VARCHAR(8000)), ' + @strIn + ', ' + @strOut + ')' + '
 WHERE ' + @ColName + ' LIKE ''' + @strTmp + '''''
PRINT '' ''
PRINT
''IF @@ERROR <> 0
BEGIN
        RAISERROR (''''Errore "UPDATE" ' + @TabName + '.' + @ColName + ''''', 16, 1)
        ROLLBACK TRAN
        RETURN
END''
PRINT '' ''
END'
        END
        
        EXEC (@SQLCmd)
--        PRINT @SQLCmd
        FETCH NEXT FROM crs INTO @TabName, @ColName, @ColType, @Div
END

CLOSE crs
DEALLOCATE crs

IF @GenUpd > 0
BEGIN
        PRINT ' ' 
        PRINT 'COMMIT TRAN'
        PRINT ' ' 
        PRINT 'SET NOCOUNT OFF'
END

GO
