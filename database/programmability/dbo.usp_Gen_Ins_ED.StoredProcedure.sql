USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_ED]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Gen_Ins_ED] (
  @IdEventDoc VARCHAR(10)
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)
AS

DECLARE @EdIDocType                                     VARCHAR(10)
DECLARE @EdIDocsubType                                  VARCHAR(10)
DECLARE @EdSez                                          VARCHAR(200)
DECLARE @EdSort                                         VARCHAR(10)
DECLARE @EdIdHae                                        VARCHAR(10)
DECLARE @EdUltimaMod                                    VARCHAR(10)
DECLARE @EdDeleted                                      VARCHAR(10)

DECLARE @RC                                             INT
DECLARE @IdConfEvent                                    VARCHAR(10)

IF NOT EXISTS (SELECT * FROM EgdEventDoc WHERE IdEventDoc = @IdEventDoc AND EdDeleted = 0)
BEGIN
        RAISERROR ('Record [%s] non trovato in EgdEventDoc', 16, 1, @IdEventDoc)
        RETURN 99
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdEventDoc                              INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END

SELECT @EdIDocType = ISNULL(CAST(EdIDocType AS VARCHAR(10)), 'NULL')
     , @EdIDocsubType = ISNULL(CAST(EdIDocsubType AS VARCHAR(10)), 'NULL')
     , @EdSez = CASE WHEN EdSez IS NOT NULL THEN '''' + RTRIM(EdSez) + '''' ELSE 'NULL' END
     , @EdSort = ISNULL(CAST(EdSort AS VARCHAR(10)), 'NULL')
     , @EdIdHae = ISNULL(CAST(EdIdHae AS VARCHAR(10)), 'NULL')
     , @EdUltimaMod = 'GETDATE()'
     , @EdDeleted = ISNULL(CAST(EdDeleted AS VARCHAR(10)), 'NULL')
  FROM EgdEventDoc 
 WHERE IdEventDoc = @IdEventDoc 
   AND EdDeleted = 0

PRINT ' '
PRINT '/* Generazione Record (EgdEventDoc) */'
PRINT ' '

IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT 'SET @IdEventDoc = ' + CAST(@IdEventDoc AS VARCHAR)
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT EgdEventDoc ON'
        PRINT ' '
        PRINT 'INSERT INTO EgdEventDoc (IdEventDoc, EdIDocType, EdIDocsubType, EdSez, EdSort, EdIdHae, EdUltimaMod, EdDeleted)'
        PRINT '     VALUES (@IdEventDoc, ' + @EdIDocType + ', ' + @EdIDocsubType + ', ' + @EdSez + ', '  + @EdSort + ', '  
                            + @EdIdHae + ', '  + @EdUltimaMod + ', '
                            + @EdDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" EgdEventDoc'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET IDENTITY_INSERT EgdEventDoc OFF'
END
ELSE
BEGIN
        PRINT 'INSERT INTO EgdEventDoc (EdIDocType, EdIDocsubType, EdSez, EdSort, EdIdHae, EdUltimaMod, EdDeleted)'
        PRINT '     VALUES (' + @EdIDocType + ', ' + @EdIDocsubType + ', ' + @EdSez + ', '  + @EdSort + ', '  
                            + @EdIdHae + ', '  + @EdUltimaMod + ', '
                            + @EdDeleted + ')'
        PRINT ' '
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" EgdEventDoc'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '
        PRINT 'SET @IdEventDoc = @@IDENTITY'
END

PRINT ' '
PRINT '/* Fine Generazione Record (EgdEventDoc) */'
PRINT ' '


DECLARE crsCE CURSOR STATIC FOR SELECT IdConfEvent
                                  FROM EgdConfigEvent
                                 WHERE ceIdEventDoc = @IdEventDoc
                                   AND ceDeleted = 0
                                 ORDER BY IdConfEvent
                               
OPEN crsCE

FETCH NEXT FROM crsCE INTO @IdConfEvent

WHILE @@FETCH_STATUS = 0
BEGIN
        SET @RC = 0
        
        EXEC @RC = usp_gen_ins_ce @IdConfEvent, 0, 1, 1, 1
        
        IF @RC <> 0
        BEGIN
                RAISERROR ('Errore "EXEC" usp_gen_ins_ce', 16, 1)
                CLOSE crsCE
                DEALLOCATE crsCE                
                RETURN 99
        END
        
        FETCH NEXT FROM crsCE INTO @IdConfEvent
END

CLOSE crsCE
DEALLOCATE crsCE


IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END






GO
