USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[test_usp_Gen_Ins_Tid]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[test_usp_Gen_Ins_Tid] (
  @IdTid INT
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
)

AS

DECLARE @IdTidNew                       INT
DECLARE @tidNome                        VARCHAR(255)
DECLARE @tidTipoMem                     VARCHAR(20)
DECLARE @tidTipoDom                     VARCHAR(20)
DECLARE @tidSistema                     VARCHAR(20)
DECLARE @tidOper                        VARCHAR(20)
DECLARE @tidQuery                       VARCHAR(8000)

DECLARE @tdrRelOrdine                   VARCHAR(10)
DECLARE @tdrCodice                      VARCHAR(100) 
DECLARE @tdrCodiceEsterno               VARCHAR(100)
DECLARE @tdrCodiceRaccordo              VARCHAR(100)

DECLARE @dgCodiceInterno                VARCHAR(150)
DECLARE @dgCodiceEsterno                VARCHAR(150)
DECLARE @dgPath                         VARCHAR(255)
DECLARE @dgLivello                      VARCHAR(10)
DECLARE @dgFoglia                       VARCHAR(10)
DECLARE @dgLenPathPadre                 VARCHAR(10)
DECLARE @dgCodiceRaccordo               VARCHAR(150)

DECLARE @ITA                            VARCHAR(255)
DECLARE @UK                             VARCHAR(255)
DECLARE @ES                             VARCHAR(255)
DECLARE @FRA                            VARCHAR(255)

--

IF NOT EXISTS (SELECT * FROM TipiDati WHERE IdTid = @IdTid)
BEGIN
        RAISERROR ('TipoDato [%d] non trovato', 16, 1, @IdTid)
        RETURN 99
END
SELECT @tidNome     = CASE WHEN tidNome IS NOT NULL THEN '''' + RTRIM(tidNome) + '''' ELSE 'NULL' END
     , @tidTipoMem  = ISNULL(CAST(tidTipoMem AS VARCHAR(10)), 'NULL')
     , @tidTipoDom  = CASE WHEN tidTipoDom IS NOT NULL THEN '''' + tidTipoDom + '''' ELSE 'NULL' END
     , @tidSistema  = ISNULL(CAST(tidSistema AS VARCHAR(10)), 'NULL')
     , @tidOper     = ISNULL(CAST(tidOper AS VARCHAR(10)), 'NULL')
     , @tidQuery    =  CASE WHEN tidQuery IS NOT NULL THEN '''' + REPLACE(CAST(tidQuery AS VARCHAR(8000)), '''', '''''') + '''' ELSE 'NULL' END
  FROM TipiDati
 WHERE IdTid = @IdTid 

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdTid                        INT'
        PRINT 'DECLARE @IdDsc                        INT'
        PRINT 'DECLARE @IdDg                         INT'
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN
        PRINT 'BEGIN TRAN'
END


/* Domini Chiusi */

DECLARE crs CURSOR STATIC FOR SELECT ISNULL(CAST(tdrRelOrdine AS VARCHAR(10)), 'NULL') 
                                   , CASE WHEN tdrCodice IS NOT NULL THEN '''' + tdrCodice + '''' ELSE 'NULL' END
                                   , CASE WHEN tdrCodiceEsterno IS NOT NULL THEN '''' + tdrCodiceEsterno + '''' ELSE 'NULL' END
                                   , CASE WHEN tdrCodiceRaccordo IS NOT NULL THEN '''' + tdrCodiceRaccordo + '''' ELSE 'NULL' END
                                   , CASE WHEN ITA.dscTesto IS NOT NULL THEN '''' + REPLACE(ITA.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
                                FROM TipiDatiRange
                                   , DescsI ITA
                               WHERE tdrIdDsc = ITA.IdDsc
                                 AND tdrIdTid = @IdTid
                                 AND tdrDeleted = 0 and  tdrcodiceesterno is not null
                              ORDER BY tdrRelOrdine
 
OPEN crs
 
 
FETCH NEXT FROM crs INTO @tdrRelOrdine, @tdrCodice, @tdrCodiceEsterno, @tdrCodiceRaccordo, 
                         @ITA

WHILE @@FETCH_STATUS = 0
BEGIN

        PRINT 'UPDATE TipiDatiRange '
		PRINT ' SET tdrCodiceEsterno = ' + @tdrCodiceEsterno + ''
		PRINT 'WHERE tdrIdTid = ' + cast(@IdTid as varchar(10)) + ' and tdrRelOrdine = ' + @tdrRelOrdine
        PRINT 'IF @@ERROR <> 0'
        PRINT 'BEGIN'
        PRINT '        RAISERROR(''Errore "INSERT" TipiDatiRange'', 16, 1)'
        PRINT '        ROLLBACK TRAN'
        PRINT '        RETURN'
        PRINT 'END'
        PRINT ' '

FETCH NEXT FROM crs INTO @tdrRelOrdine, @tdrCodice, @tdrCodiceEsterno, @tdrCodiceRaccordo, 
                         @ITA
END
 
CLOSE crs
DEALLOCATE crs
        

IF @ommit_tran = 0
BEGIN
        PRINT 'COMMIT TRAN'
END

IF @ommit_declare = 0
BEGIN
        PRINT 'SET NOCOUNT OFF'
END





GO
