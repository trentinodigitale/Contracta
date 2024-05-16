USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Gen_Ins_Dzt]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Gen_Ins_Dzt] (
  @IdDzt VARCHAR(10)
, @ommit_tran BIT = 0
, @ommit_declare BIT = 0
, @ommit_identity BIT = 1
, @error_ifexists BIT = 0
)

AS

DECLARE @dztNome                        VARCHAR(70)
DECLARE @dztValoreDef                   VARCHAR(200)
DECLARE @dztIdTid                       VARCHAR(10)
DECLARE @dztIdGum                       VARCHAR(10)
DECLARE @dztIdUmsDefault                VARCHAR(10)
DECLARE @dztLunghezza                   VARCHAR(10)
DECLARE @dztCifreDecimali               VARCHAR(10)
DECLARE @dztFRegObblig                  VARCHAR(10)
DECLARE @dztFAziende                    VARCHAR(10)
DECLARE @dztFArticoli                   VARCHAR(10)
DECLARE @dztFOFID                       VARCHAR(10)
DECLARE @dztTabellaSpeciale             VARCHAR(255)
DECLARE @dztCampoSpeciale               VARCHAR(255)
DECLARE @dztFMascherato                 VARCHAR(10)
DECLARE @dztUltimaMod                   VARCHAR(20)               
DECLARE @dztFQualita                    VARCHAR(10)
DECLARE @dztProfili                     VARCHAR(30)
DECLARE @dztMultiValue                  VARCHAR(10)
DECLARE @dztLocked                      VARCHAR(10)
DECLARE @dztDeleted                     VARCHAR(10)
DECLARE @dztVersoNavig                  VARCHAR(20)
DECLARE @dztInterno                     VARCHAR(10)
DECLARE @dztTipologiaStorico            VARCHAR(20)
DECLARE @dztMemStorico                  VARCHAR(20)
DECLARE @dztIsUnicode                   VARCHAR(10)
DECLARE @ITA                            VARCHAR(255)
DECLARE @UK                             VARCHAR(255)
DECLARE @ES                             VARCHAR(255)
DECLARE @FRA                            VARCHAR(255)
DECLARE @tidNome                        VARCHAR(255)

DECLARE @apatIdDzt                      VARCHAR(10)
DECLARE @apatIdApp                      VARCHAR(10)
DECLARE @apatDeleted                    VARCHAR(10)
DECLARE @apatUltimaMod                  VARCHAR(30)
DECLARE @apatTabellaSpeciale            VARCHAR(255)
DECLARE @apatCampoSpeciale              VARCHAR(255)
DECLARE @apatIsUnicode                  VARCHAR(10)

IF NOT EXISTS (SELECT * FROM DizionarioAttributi WHERE IdDzt = @IdDzt)
BEGIN
        RAISERROR ('Attributo [%s] non trovato', 16, 1, @IdDzt)
        RETURN 99
END

SELECT @dztNome = CASE WHEN dztNome IS NOT NULL THEN '''' + dztNome + '''' ELSE 'NULL' END
     , @dztValoreDef = CASE WHEN dztValoreDef IS NOT NULL THEN '''' + dztValoreDef + '''' ELSE 'NULL' END
     , @tidNome = CASE WHEN tidNome IS NOT NULL THEN '''' + RTRIM(tidNome) + '''' ELSE 'NULL' END
     , @dztIdTid = ISNULL(CAST(dztIdTid AS VARCHAR(10)), 'NULL')
     , @dztIdGum = ISNULL(CAST(dztIdGum AS VARCHAR(10)), 'NULL')
     , @dztIdUmsDefault = ISNULL(CAST(dztIdUmsDefault AS VARCHAR(10)), 'NULL')
     , @dztLunghezza = ISNULL(CAST(dztLunghezza AS VARCHAR(10)), 'NULL')
     , @dztCifreDecimali = ISNULL(CAST(dztCifreDecimali AS VARCHAR(10)), 'NULL')
     , @dztFRegObblig = ISNULL(CAST(dztFRegObblig AS VARCHAR(10)), 'NULL')
     , @dztFAziende = ISNULL(CAST(dztFAziende AS VARCHAR(10)), 'NULL')
     , @dztFArticoli = ISNULL(CAST(dztFArticoli AS VARCHAR(10)), 'NULL')
     , @dztFOFID = ISNULL(CAST(dztFOFID AS VARCHAR(10)), 'NULL')
     , @dztTabellaSpeciale = CASE WHEN dztTabellaSpeciale IS NOT NULL THEN '''' + dztTabellaSpeciale + '''' ELSE 'NULL' END
     , @dztCampoSpeciale = CASE WHEN dztCampoSpeciale IS NOT NULL THEN '''' + dztCampoSpeciale + '''' ELSE 'NULL' END
     , @dztFMascherato = ISNULL(CAST(dztFMascherato AS VARCHAR(10)), 'NULL')
--     , @dztUltimaMod = CASE WHEN CONVERT(VARCHAR(10), dztUltimaMod, 121) IS NOT NULL THEN '''' + CONVERT(VARCHAR(10), dztUltimaMod, 121) + '''' ELSE 'NULL' END
     , @dztUltimaMod = 'GETDATE()'
     , @dztFQualita = ISNULL(CAST(dztFQualita AS VARCHAR(10)), 'NULL')
     , @dztProfili = CASE WHEN dztProfili IS NOT NULL THEN '''' + dztProfili + '''' ELSE 'NULL' END
     , @dztMultiValue = ISNULL(CAST(dztMultiValue AS VARCHAR(10)), 'NULL')
     , @dztLocked = ISNULL(CAST(dztLocked AS VARCHAR(10)), 'NULL')
     , @dztDeleted = ISNULL(CAST(dztDeleted AS VARCHAR(10)), 'NULL')
     , @dztVersoNavig = CASE WHEN dztVersoNavig IS NOT NULL THEN '''' + dztVersoNavig + '''' ELSE 'NULL' END
     , @dztInterno = ISNULL(CAST(dztInterno AS VARCHAR(10)), 'NULL')
     , @dztTipologiaStorico = CASE WHEN dztTipologiaStorico IS NOT NULL THEN '''' + dztTipologiaStorico + '''' ELSE 'NULL' END
     , @dztMemStorico = ISNULL(CAST(dztMemStorico AS VARCHAR(10)), 'NULL')
     , @dztIsUnicode = ISNULL(CAST(dztIsUnicode AS VARCHAR(10)), 'NULL')
     , @ITA = CASE WHEN ita.dscTesto IS NOT NULL THEN '''' + REPLACE(ita.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
     , @UK = CASE WHEN uk.dscTesto IS NOT NULL THEN '''' + REPLACE(uk.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
     , @ES = CASE WHEN es.dscTesto IS NOT NULL THEN '''' + REPLACE(es.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
     , @FRA = CASE WHEN fra.dscTesto IS NOT NULL THEN '''' + REPLACE(fra.dscTesto, '''', '''''') + '''' ELSE 'NULL' END
  FROM DizionarioAttributi
     , TipiDati
     , DescsI ita
     , DescsUK uk
     , DescsE es
     , DescsFRA fra
 WHERE IdDzt = @IdDzt
   AND dztIdTid = IdTid
   AND dztIdDsc = ita.IdDsc
   AND dztIdDsc = uk.IdDsc
   AND dztIdDsc = es.IdDsc
   AND dztIdDsc = fra.IdDsc
   AND dztDeleted = 0  
  
IF @ommit_declare = 0
BEGIN  
        PRINT 'SET NOCOUNT ON'
        PRINT ' '
        PRINT 'DECLARE @IdDzt                        INT'
        PRINT 'DECLARE @IdDsc                        INT'
        PRINT 'DECLARE @IdTid                        INT'
        PRINT ' '
END

IF @error_ifexists = 1
BEGIN
        PRINT 'IF EXISTS (SELECT * FROM DizionarioAttributi WHERE dztNome = ' + @dztNome + ')'
        PRINT 'BEGIN '
        PRINT '         RAISERROR (''Attributo [' + REPLACE(@dztNome, '''', '') + '] già presente'', 16, 1)'
        PRINT '         RETURN'
        PRINT 'END '
        PRINT ' '
END

IF @ommit_tran = 0
BEGIN  
        PRINT 'BEGIN TRAN'
END

PRINT ' '
PRINT 'IF NOT EXISTS (SELECT * FROM DizionarioAttributi WHERE dztNome = ' + @dztNome + ')'
PRINT 'BEGIN '
PRINT ' '
PRINT '         SET @IdTid = NULL'
PRINT ' '
PRINT '         SELECT @IdTid = IdTid'
PRINT '           FROM TipiDati'
PRINT '          WHERE tidNome = ' + @tidNome
PRINT ' '
PRINT '         IF @IdTid IS NULL'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Tipo Dato non trovato'', 16, 1)'
PRINT '                 ROLLBACK TRAN'
PRINT '                 RETURN'
PRINT '         END'
PRINT ' '
PRINT '         INSERT INTO DescsI (dscTesto)'
PRINT '                 VALUES (' + @ITA + ')'
PRINT ' '
PRINT '         IF @@ERROR <> 0'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Errore "INSERT" DescsI'', 16, 1)'
PRINT '                 ROLLBACK TRAN'
PRINT '                 RETURN'
PRINT '         END'
PRINT ' '
PRINT '         SET @IdDsc = @@IDENTITY'
PRINT ' '
PRINT '         INSERT INTO DescsUK (IdDsc, dscTesto)'
PRINT '                 VALUES (@IdDsc, ' + @UK + ')'
PRINT ' '
PRINT '         IF @@ERROR <> 0'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Errore "INSERT" DescsUK'', 16, 1)'
PRINT '                 ROLLBACK TRAN'
PRINT '                 RETURN'
PRINT '         END'
PRINT ' '
PRINT '         INSERT INTO DescsE (IdDsc, dscTesto)'
PRINT '                 VALUES (@IdDsc, ' + @ES + ')'
PRINT ' '
PRINT '         IF @@ERROR <> 0'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Errore "INSERT" DescsES'', 16, 1)'
PRINT '                 ROLLBACK TRAN'
PRINT '                 RETURN'
PRINT '         END'
PRINT ' '
PRINT '         INSERT INTO DescsFRA (IdDsc, dscTesto)'
PRINT '                 VALUES (@IdDsc, ' + @FRA + ')'
PRINT ' '
PRINT '         IF @@ERROR <> 0'
PRINT '         BEGIN'
PRINT '                 RAISERROR(''Errore "INSERT" DescsFRA'', 16, 1)'
PRINT '                 ROLLBACK TRAN'
PRINT '                 RETURN'
PRINT '         END'
PRINT ' '


IF @ommit_identity = 0
BEGIN
        PRINT ' '
        PRINT '         SET @IdDzt = ' + @IdDzt
        PRINT ' '
        PRINT '         SET IDENTITY_INSERT DizionarioAttributi ON'
        PRINT ' '
        PRINT '         INSERT INTO DizionarioAttributi (IdDzt, dztNome, dztValoreDef, dztIdDsc, dztIdTid, dztIdGum, 
                                                         dztIdUmsDefault, dztLunghezza, dztCifreDecimali, dztFRegObblig,
                                                         dztFAziende, dztFArticoli, dztFOFID, dztTabellaSpeciale, dztCampoSpeciale,
                                                         dztFMascherato, dztUltimaMod, dztFQualita, dztProfili, dztMultiValue,
                                                         dztLocked, dztDeleted, dztVersoNavig, dztInterno, dztTipologiaStorico, 
                                                         dztMemStorico, dztIsUnicode)'
        PRINT '                 VALUES (@IdDzt, ' + @dztNome + ', ' + @dztValoreDef + ', @IdDsc, @IdTid'
                                        + ', ' + @dztIdGum + ', ' + @dztIdUmsDefault + ', ' + @dztLunghezza + ', ' + @dztCifreDecimali 
                                        + ', ' + @dztFRegObblig + ', ' + @dztFAziende + ', ' + @dztFArticoli + ', ' + @dztFOFID + ', ' + @dztTabellaSpeciale 
                                        + ', ' + @dztCampoSpeciale + ', ' + @dztFMascherato + ', ' + @dztUltimaMod + ', ' + @dztFQualita + ', ' + @dztProfili 
                                        + ', ' + @dztMultiValue + ', ' + @dztLocked + ', ' + @dztDeleted + ', ' + @dztVersoNavig + ', ' + @dztInterno 
                                        + ', ' + @dztTipologiaStorico + ', ' + @dztMemStorico + ', ' + @dztIsUnicode + ')'
        PRINT ' '
        PRINT '         IF @@ERROR <> 0'
        PRINT '         BEGIN'
        PRINT '                 RAISERROR(''Errore "INSERT" DizionarioAttributi'', 16, 1)'
        PRINT '                 ROLLBACK TRAN'
        PRINT '                 RETURN'
        PRINT '         END'
        PRINT ' '
        PRINT '         SET IDENTITY_INSERT DizionarioAttributi OFF'
END
ELSE
BEGIN
        PRINT '         INSERT INTO DizionarioAttributi (dztNome, dztValoreDef, dztIdDsc, dztIdTid, dztIdGum, 
                                                         dztIdUmsDefault, dztLunghezza, dztCifreDecimali, dztFRegObblig,
                                                         dztFAziende, dztFArticoli, dztFOFID, dztTabellaSpeciale, dztCampoSpeciale,
                                                         dztFMascherato, dztUltimaMod, dztFQualita, dztProfili, dztMultiValue,
                                                         dztLocked, dztDeleted, dztVersoNavig, dztInterno, dztTipologiaStorico, 
                                                         dztMemStorico, dztIsUnicode)'
        PRINT '                 VALUES (' + @dztNome + ', ' + @dztValoreDef + ', @IdDsc, @IdTid' 
                                        + ', ' + @dztIdGum + ', ' + @dztIdUmsDefault + ', ' + @dztLunghezza + ', ' + @dztCifreDecimali 
                                        + ', ' + @dztFRegObblig + ', ' + @dztFAziende + ', ' + @dztFArticoli + ', ' + @dztFOFID + ', ' + @dztTabellaSpeciale 
                                        + ', ' + @dztCampoSpeciale + ', ' + @dztFMascherato + ', ' + @dztUltimaMod + ', ' + @dztFQualita + ', ' + @dztProfili 
                                        + ', ' + @dztMultiValue + ', ' + @dztLocked + ', ' + @dztDeleted + ', ' + @dztVersoNavig + ', ' + @dztInterno 
                                        + ', ' + @dztTipologiaStorico + ', ' + @dztMemStorico + ', ' + @dztIsUnicode + ')'
        PRINT ' '
        PRINT '         IF @@ERROR <> 0'
        PRINT '         BEGIN'
        PRINT '                 RAISERROR(''Errore "INSERT" DizionarioAttributi'', 16, 1)'
        PRINT '                 ROLLBACK TRAN'
        PRINT '                 RETURN'
        PRINT '         END'
        PRINT ' '
        PRINT '         SET @IdDzt = @@IDENTITY'
        PRINT ' '
END

DECLARE crsApAt CURSOR STATIC FOR SELECT ISNULL(CAST(apatIdApp AS VARCHAR(10)), 'NULL')
                                       , ISNULL(CAST(apatDeleted AS VARCHAR(10)), 'NULL')
                                       , 'GETDATE()'
                                       , CASE WHEN apatTabellaSpeciale IS NOT NULL THEN '''' + apatTabellaSpeciale + '''' ELSE 'NULL' END
                                       , CASE WHEN apatCampoSpeciale IS NOT NULL THEN '''' + apatCampoSpeciale + '''' ELSE 'NULL' END
                                       , ISNULL(CAST(apatIsUnicode AS VARCHAR(10)), 'NULL')
                                    FROM AppartenenzaAttributi
                                   WHERE apatIdDzt = @IdDzt
                                     AND apatDeleted = 0

OPEN crsApAt

FETCH NEXT FROM crsApAt INTO @apatIdApp, @apatDeleted, @apatUltimaMod, @apatTabellaSpeciale, @apatCampoSpeciale, @apatIsUnicode

WHILE @@FETCH_STATUS = 0
BEGIN
        PRINT '         INSERT INTO AppartenenzaAttributi (apatIdDzt, apatIdApp, apatDeleted, apatUltimaMod, apatTabellaSpeciale, apatCampoSpeciale, apatIsUnicode)'
        PRINT '                 VALUES (@IdDzt, ' + @apatIdApp+ ', ' + @apatDeleted+ ', ' + @apatUltimaMod+ ', ' + @apatTabellaSpeciale
                                                      + ', ' + @apatCampoSpeciale+ ', ' + @apatIsUnicode + ')'
        PRINT ' '
        PRINT '         IF @@ERROR <> 0'
        PRINT '         BEGIN'
        PRINT '                 RAISERROR(''Errore "INSERT" AppartenenzaAttributi'', 16, 1)'
        PRINT '                 ROLLBACK TRAN'
        PRINT '                 RETURN'
        PRINT '         END'
        PRINT ' '
        
        FETCH NEXT FROM crsApAt INTO @apatIdApp, @apatDeleted, @apatUltimaMod, @apatTabellaSpeciale, @apatCampoSpeciale, @apatIsUnicode
END
CLOSE crsApAt
DEALLOCATE crsApAt

PRINT 'END '
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
