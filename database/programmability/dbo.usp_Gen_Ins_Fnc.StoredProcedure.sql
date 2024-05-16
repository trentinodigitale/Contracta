USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_Fnc]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[usp_Gen_Ins_Fnc] (
  @IdGrp INT
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
, @ommit_mod BIT = 1
)

AS

DECLARE @grpName                                VARCHAR(200)
DECLARE @fncLocation                            VARCHAR(500)
DECLARE @fncName                                VARCHAR(500)                                                                                                                                                                          
DECLARE @fncCaption                             VARCHAR(500)                                                                       
DECLARE @fncIcon                                VARCHAR(500)
DECLARE @fncUserFunz                            VARCHAR(10)
DECLARE @fncUse                                 VARCHAR(20)
DECLARE @fncHide                                VARCHAR(100)
DECLARE @fncCommand                             VARCHAR(8000)                                                                      
DECLARE @fncParam                               VARCHAR(8000)
DECLARE @fncCondition                           VARCHAR(8000)
DECLARE @fncOrder                               VARCHAR(10)
DECLARE @fncParamNew                            VARCHAR(8000)
DECLARE @strTmp                                 VARCHAR(8000)
DECLARE @strTmp1                                VARCHAR(8000)
DECLARE @strTmp2                                VARCHAR(8000)
DECLARE @strTmp3                                VARCHAR(8000)
DECLARE @fncParamTmp                            VARCHAR(8000)
DECLARE @LenTmp                                 INT
DECLARE @IdMpModTmp                             VARCHAR(100)

DECLARE @IdMpMod_ADDROW                         INT
DECLARE @IdMpMod_DELETEARTICLE                  INT
DECLARE @IdMpMod_EDITSCORE                      INT
DECLARE @IdMpMod_EXECUTESEARCH1                 INT
DECLARE @IdMpMod_EXECUTESEARCH2                 INT
DECLARE @IdMpMod_INSERTARTICLE_FROMCATALOGUE1   INT
DECLARE @IdMpMod_INSERTARTICLE_FROMCATALOGUE2   INT
DECLARE @IdMpMod_SEARCH_COMPANY1                INT
DECLARE @IdMpMod_SEARCH_COMPANY2                INT

/*
-ADDROW	2871#Inserisci allegato
-DELETEARTICLE	2871#Cancella Allegato
-EDITSCORE TECNICA#TechnicalScore#4401#PartialTechnical#Calcola Punteggio Tecnico#ExpForTechnicalScore#PuntTecnicoInt
--EXECUTESEARCH show#4214
INSERTARTICLE_FROMCATALOGUE Show#C#351#357
SEARCH_COMPANY	Show#4395#4396#B#100#Ricerca Azienda
SEARCH_COMPANY 	Show#454#454#B#100
*/


IF NOT EXISTS (SELECT * FROM FunctionsGroups WHERE IdGrp = @IdGrp)
BEGIN
        RAISERROR ('Gruppo [%s] non trovato', 16, 1, @IdGrp)
        RETURN 99
END


PRINT ' '
PRINT '/* Generazione Funzioni */'
PRINT ' '

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdGrp                        INT'
        
        IF @ommit_mod = 0
        BEGIN
                PRINT 'DECLARE @IdMpMod_fnc_1                INT'
                PRINT 'DECLARE @IdMpMod_fnc_2                INT'
                PRINT 'DECLARE @IdMpMod_fnc_3                INT'
                PRINT 'DECLARE @IdMdlAtt                     INT'
                PRINT 'DECLARE @fncParamNew                  VARCHAR(200)'
        END

        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

PRINT ' '

SELECT @grpName = CASE WHEN grpName IS NOT NULL THEN '''' + RTRIM(grpName) + '''' ELSE 'NULL' END
  FROM FunctionsGroups
 WHERE IdGrp = @IdGrp
 
IF @ommit_identity = 0
BEGIN
        PRINT 'SET @IdGrp = ' + CAST(@IdGrp AS VARCHAR)
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT FunctionsGroups ON'
        PRINT ' '
        PRINT 'INSERT INTO FunctionsGroups (IdGrp, grpName)'
        PRINT '     VALUES (@IdGrp, ' + @grpName + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" FunctionsGroups'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT FunctionsGroups OFF'
        PRINT ' '
END
ELSE
BEGIN
        PRINT 'INSERT INTO FunctionsGroups (grpName)'
        PRINT '     VALUES (' + @grpName+ ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" FunctionsGroups'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET @IdGrp = @@IDENTITY'
        PRINT ' '
END

DECLARE crs CURSOR static FOR SELECT CASE WHEN fncLocation IS NOT NULL THEN '''' + fncLocation + '''' ELSE 'NULL' END
                            , CASE WHEN fncName IS NOT NULL THEN '''' + fncName + '''' ELSE 'NULL' END
                            , CASE WHEN fncCaption IS NOT NULL THEN '''' + RTRIM(fncCaption) + '''' ELSE 'NULL' END
                            , CASE WHEN fncIcon IS NOT NULL THEN '''' + fncIcon + '''' ELSE 'NULL' END
                            , ISNULL(CAST(fncUserFunz AS VARCHAR(10)), 'NULL')
                            , CASE WHEN fncUse IS NOT NULL THEN '''' + fncUse + '''' ELSE 'NULL' END
                            , ISNULL(CAST(fncHide AS VARCHAR(10)), 'NULL')
                            , CASE WHEN fncCommand IS NOT NULL THEN '''' + fncCommand + '''' ELSE 'NULL' END
                            , CASE WHEN fncParam IS NOT NULL THEN '''' + REPLACE(fncParam, '''', '''''') + '''' ELSE 'NULL' END
                            , CASE WHEN fncCondition IS NOT NULL THEN '''' + fncCondition + '''' ELSE 'NULL' END
                            , ISNULL(CAST(fncOrder AS VARCHAR(10)), 'NULL')
                         FROM Functions
                        WHERE fncIdGrp = @IdGrp
                          AND fncDeleted = 0
                        ORDER BY fncOrder

OPEN crs

FETCH NEXT FROM crs INTO @fncLocation, @fncName, @fncCaption, @fncIcon, @fncUserFunz, @fncUse, @fncHide, 
                         @fncCommand, @fncParam, @fncCondition, @fncOrder

WHILE @@FETCH_STATUS = 0
BEGIN
--        IF @ommit_mod = 1 OR @fncCommand NOT IN ('ADDROW', 'DELETEARTICLE', 'EDITSCORE', 'EXECUTESEARCH', 'INSERTARTICLE_FROMCATALOGUE', 'SEARCH_COMPANY')

        IF @ommit_mod = 0 AND REPLACE(@fncCommand, '''', '') IN ('ADDROW', 'DELETEARTICLE') AND @fncParam <> 'NULL' -- <-- Non è un errore
        BEGIN
                SET @fncParamTmp = REPLACE(@fncParam, '''', '')
                SET @LenTmp = CHARINDEX('#', @fncParamTmp)
                
                IF @LenTmp <> 0
                        SET @IdMpMod_ADDROW = LEFT(@fncParamTmp, @LenTmp - 1)
                ELSE
                        SET @IdMpMod_ADDROW = @fncParamTmp

                EXEC usp_gen_ins_mod @IdMpMod_ADDROW, @ommit_tran = 1, @ommit_declare = 1, @var_suffix = '_fnc_1'

                PRINT ' '                

                SET @LenTmp = CHARINDEX('#', @fncParam)

                IF @LenTmp <> 0
                        PRINT 'SET @fncParamNew = CAST(@IdMpMod_fnc_1 AS VARCHAR) + ''#'' + ''' + SUBSTRING(@fncParam, @LenTmp + 1, 200) + ''
                ELSE                        
                        PRINT 'SET @fncParamNew = CAST(@IdMpMod_fnc_1 AS VARCHAR)'
                        
                PRINT ' '                
                PRINT 'INSERT INTO Functions (fncIdGrp, fncLocation, fncName, fncCaption, fncIcon, fncUserFunz, fncUse, '
                PRINT '                       fncHide, fncCommand, fncParam, fncCondition, fncOrder)'
                PRINT '     VALUES (@IdGrp, ' + @fncLocation + ', ' + @fncName + ', ' + @fncCaption + ', ' + @fncIcon
                                              + ', ' + @fncUserFunz + ', ' + @fncUse + ', ' + @fncHide + ', ' + @fncCommand 
                                              + ', @fncParamNew, ' + @fncCondition + ', ' + @fncOrder + ')'
        END
        ELSE
        IF @ommit_mod = 0 AND REPLACE(@fncCommand, '''', '') IN ('EDITSCORE') AND @fncParam <> 'NULL' -- <-- Non è un errore
        BEGIN
                SET @fncParamTmp = REPLACE(@fncParam, '''', '')

                SET @strTmp = SUBSTRING (@fncParamTmp, CHARINDEX('#', @fncParamTmp) + 1, 8000)
                SET @strTmp = SUBSTRING (@strTmp, CHARINDEX('#', @strTmp) + 1, 8000)

                SET @IdMpMod_EDITSCORE = LEFT(@strTmp, CHARINDEX('#', @strTmp) - 1)

                SET @IdMpModTmp = CAST(@IdMpMod_EDITSCORE AS VARCHAR)
                SET @LenTmp = LEN(@IdMpModTmp)
                
                EXEC usp_gen_ins_mod @IdMpMod_EDITSCORE, @ommit_tran = 1, @ommit_declare = 1, @var_suffix = '_fnc_1'
                
                SET @strTmp1 = LEFT(@fncParamTmp, CHARINDEX(@IdMpModTmp, @fncParamTmp) - 1)
                SET @strTmp2 = SUBSTRING(@fncParamTmp, CHARINDEX(@IdMpModTmp, @fncParamTmp) + @LenTmp, 8000)
                
                PRINT ' '                
                PRINT 'SET @fncParamNew = ''' + @strTmp1 + ''' + CAST(@IdMpMod_fnc_1 AS VARCHAR) +  ''' + @strTmp2 + ''''
                PRINT ' '                
                PRINT 'INSERT INTO Functions (fncIdGrp, fncLocation, fncName, fncCaption, fncIcon, fncUserFunz, fncUse, '
                PRINT '                       fncHide, fncCommand, fncParam, fncCondition, fncOrder)'
                PRINT '     VALUES (@IdGrp, ' + @fncLocation + ', ' + @fncName + ', ' + @fncCaption + ', ' + @fncIcon
                                              + ', ' + @fncUserFunz + ', ' + @fncUse + ', ' + @fncHide + ', ' + @fncCommand 
                                              + ', @fncParamNew, ' + @fncCondition + ', ' + @fncOrder + ')'
        END
        ELSE
        IF @ommit_mod = 0 AND REPLACE(@fncCommand, '''', '') IN ('EXECUTESEARCH') AND @fncParam <> 'NULL' -- <-- Non è un errore
        BEGIN
                SET @IdMpMod_EXECUTESEARCH1 = ''
                SET @IdMpMod_EXECUTESEARCH2 = ''
                
                SET @fncParamTmp = REPLACE(@fncParam, '''', '')

                SET @strTmp = LEFT(@fncParamTmp, CHARINDEX('#', @fncParamTmp))
                SET @strTmp1 = SUBSTRING (@fncParamTmp, CHARINDEX('#', @fncParamTmp) + 1, 8000)
                
                IF CHARINDEX('#', @strTmp1) = 0
                BEGIN
                        SET @IdMpMod_EXECUTESEARCH1 = @strTmp1
                END
                ELSE
                BEGIN
                        SET @IdMpMod_EXECUTESEARCH1 = LEFT(@strTmp1, CHARINDEX('#', @strTmp1) - 1)
                        SET @IdMpMod_EXECUTESEARCH2 = SUBSTRING(@strTmp1, CHARINDEX('#', @strTmp1) + 1, 8000)
                END

                EXEC usp_gen_ins_mod @IdMpMod_EXECUTESEARCH1, @ommit_tran = 1, @ommit_declare = 1, @var_suffix = '_fnc_1'
                
                IF @IdMpMod_EXECUTESEARCH2 <> ''
                BEGIN
                        EXEC usp_gen_ins_mod @IdMpMod_EXECUTESEARCH2, @ommit_tran = 1, @ommit_declare = 1, @var_suffix = '_fnc_2'
                        PRINT ' '                
                        PRINT 'SET @fncParamNew = ''' + @strTmp + ''' + CAST(@IdMpMod_fnc_1 AS VARCHAR) + ''#'' + CAST(@IdMpMod_fnc_2 AS VARCHAR)'
                END
                ELSE
                BEGIN
                        PRINT ' '                
                        PRINT 'SET @fncParamNew = ''' + @strTmp + ''' + CAST(@IdMpMod_fnc_1 AS VARCHAR)'
                END
                
                PRINT ' '                
                PRINT 'INSERT INTO Functions (fncIdGrp, fncLocation, fncName, fncCaption, fncIcon, fncUserFunz, fncUse, '
                PRINT '                       fncHide, fncCommand, fncParam, fncCondition, fncOrder)'
                PRINT '     VALUES (@IdGrp, ' + @fncLocation + ', ' + @fncName + ', ' + @fncCaption + ', ' + @fncIcon
                                              + ', ' + @fncUserFunz + ', ' + @fncUse + ', ' + @fncHide + ', ' + @fncCommand 
                                              + ', @fncParamNew, ' + @fncCondition + ', ' + @fncOrder + ')'
        END
        ELSE
        IF @ommit_mod = 0 AND REPLACE(@fncCommand, '''', '') IN ('SEARCH_COMPANY') AND @fncParam <> 'NULL' -- <-- Non è un errore
        BEGIN
                SET @IdMpMod_SEARCH_COMPANY1 = ''
                SET @IdMpMod_SEARCH_COMPANY2 = ''
                
                SET @fncParamTmp = REPLACE(@fncParam, '''', '')

                SET @strTmp = LEFT(@fncParamTmp, CHARINDEX('#', @fncParamTmp))
                SET @strTmp1 = SUBSTRING (@fncParamTmp, CHARINDEX('#', @fncParamTmp) + 1, 8000)
                
                SET @IdMpMod_SEARCH_COMPANY1 = LEFT(@strTmp1, CHARINDEX('#', @strTmp1) - 1)
                
                SET @IdMpModTmp = CAST(@IdMpMod_SEARCH_COMPANY1 AS VARCHAR)
                
                SET @LenTmp = LEN(@IdMpModTmp)
                
                SET @strTmp2 = SUBSTRING (@fncParamTmp, CHARINDEX(@IdMpModTmp, @fncParamTmp) + @LenTmp + 1, 8000)
                
                SET @IdMpMod_SEARCH_COMPANY2 = LEFT(@strTmp2, CHARINDEX('#', @strTmp2) - 1)
                
                EXEC usp_gen_ins_mod @IdMpMod_SEARCH_COMPANY1, @ommit_tran = 1, @ommit_declare = 1, @var_suffix = '_fnc_1'
                EXEC usp_gen_ins_mod @IdMpMod_SEARCH_COMPANY2, @ommit_tran = 1, @ommit_declare = 1, @var_suffix = '_fnc_2'
                
                SET @IdMpModTmp = CAST(@IdMpMod_SEARCH_COMPANY2 AS VARCHAR)
                SET @LenTmp = LEN(@IdMpModTmp)

                SET @strTmp2 = SUBSTRING(@fncParamTmp, CHARINDEX(@IdMpModTmp, @fncParamTmp) +  @LenTmp, 8000)
                
                PRINT 'SET @fncParamNew = ''' + @strTmp + ''' + CAST(@IdMpMod_fnc_1 AS VARCHAR) + ''#'' + CAST(@IdMpMod_fnc_2 AS VARCHAR) + ''' + @strTmp2 + ''''
                
                PRINT ' '                
                PRINT 'INSERT INTO Functions (fncIdGrp, fncLocation, fncName, fncCaption, fncIcon, fncUserFunz, fncUse, '
                PRINT '                       fncHide, fncCommand, fncParam, fncCondition, fncOrder)'
                PRINT '     VALUES (@IdGrp, ' + @fncLocation + ', ' + @fncName + ', ' + @fncCaption + ', ' + @fncIcon
                                              + ', ' + @fncUserFunz + ', ' + @fncUse + ', ' + @fncHide + ', ' + @fncCommand 
                                              + ', @fncParamNew, ' + @fncCondition + ', ' + @fncOrder + ')'
        END
        ELSE
        BEGIN
                PRINT 'INSERT INTO Functions (fncIdGrp, fncLocation, fncName, fncCaption, fncIcon, fncUserFunz, fncUse, '
                PRINT '                       fncHide, fncCommand, fncParam, fncCondition, fncOrder)'
                PRINT '     VALUES (@IdGrp, ' + @fncLocation + ', ' + @fncName + ', ' + @fncCaption + ', ' + @fncIcon
                                              + ', ' + @fncUserFunz + ', ' + @fncUse + ', ' + @fncHide + ', ' + @fncCommand 
                                              + ', ' + @fncParam + ', ' + @fncCondition + ', ' + @fncOrder + ')'
        END
        
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" Functions'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '

        FETCH NEXT FROM crs INTO @fncLocation, @fncName, @fncCaption, @fncIcon, @fncUserFunz, @fncUse, @fncHide, 
                                 @fncCommand, @fncParam, @fncCondition, @fncOrder
END
CLOSE crs
DEALLOCATE crs

PRINT ' '
PRINT '/* Fine Generazione Funzioni */'
PRINT ' '

IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END











GO
