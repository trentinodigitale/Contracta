USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_CE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_CE] (
  @IdConfEvent VARCHAR(10)
, @ommit_ed BIT = 0
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @CeParam                                        VARCHAR(200)
DECLARE @CeValue                                        VARCHAR(2000)
DECLARE @CeIdEventDoc                                   VARCHAR(50)
DECLARE @CeUltimamod                                    VARCHAR(10)
DECLARE @CeDeleted                                      VARCHAR(10)

DECLARE @RC                                             INT

IF NOT EXISTS (SELECT * FROM EgdConfigEvent WHERE IdConfEvent = @IdConfEvent AND CeDeleted = 0)
BEGIN
        RAISERROR ('Record [%s] non trovato in EgdConfigEvent', 16, 1, @IdConfEvent)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @CeParam = CASE WHEN CeParam IS NOT NULL THEN '''' + RTRIM(CeParam) + '''' ELSE 'NULL' END
     , @CeValue = CASE WHEN CeValue IS NOT NULL THEN '''' + RTRIM(CeValue) + '''' ELSE 'NULL' END
     , @CeIdEventDoc = ISNULL(CAST(CeIdEventDoc AS VARCHAR(10)), 'NULL')
     , @CeUltimamod = 'GETDATE()'
     , @CeDeleted = ISNULL(CAST(CeDeleted AS VARCHAR(10)), 'NULL')
  FROM EgdConfigEvent
 WHERE IdConfEvent = @IdConfEvent 
   AND CeDeleted = 0
   
IF @ommit_ed = 0
BEGIN
        SET @CeIdEventDoc = '@IdEventDoc'
END

PRINT ' '
PRINT '/* Generazione Record (EgdConfigEvent) */'
PRINT ' '

IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT EgdConfigEvent ON'
        PRINT ' '
        PRINT 'INSERT INTO EgdConfigEvent (IdConfEvent, CeParam, CeValue, CeIdEventDoc, CeUltimamod, CeDeleted)'
        PRINT '     VALUES (' + @IdConfEvent  + ',' + @CeParam + ', ' + @CeValue + ', ' + @CeIdEventDoc + ', '  + @CeUltimamod + ', '  
                              + @CeDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" EgdConfigEvent'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT EgdConfigEvent OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO EgdConfigEvent (CeParam, CeValue, CeIdEventDoc, CeUltimamod, CeDeleted)'
        PRINT '     VALUES (' + @CeParam + ', ' + @CeValue + ', ' + @CeIdEventDoc + ', '  + @CeUltimamod + ', '  
                              + @CeDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" EgdConfigEvent'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
END


PRINT ' '
PRINT '/* Fine Generazione Record (EgdConfigEvent) */'
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
