USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertDMAttributiStorico]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[InsertDMAttributiStorico] (@dztNome VARCHAR(50), @DataValidita VARCHAR(10) = NULL)
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
DECLARE @DataValiditaOut     VARCHAR(10)
DECLARE @dztTipologiaStorico VARCHAR(10)
DECLARE @dztMemStorico       INT
IF NOT EXISTS (SELECT * FROM DizionarioAttributi WHERE dztNome = @dztNome)
   BEGIN
        RAISERROR ('Attributo [%s] non trovato in DizionarioAttributi', 16, 1, @dztNome)
        RETURN
   END
IF NOT EXISTS (SELECT * FROM DizionarioAttributi WHERE dztNome = @dztNome AND dztTipologiaStorico IS NOT NULL AND dztMemStorico IS NOT NULL)
   BEGIN
        RAISERROR ('L''attributo [%s] non _ stato configurato correttamente per la storicizzazione', 16, 1, @dztNome)
        RETURN
   END
IF @DataValidita IS NOT NULL AND ISDATE (@DataValidita) <> 1
   BEGIN
        RAISERROR ('Data [%s] non valida', 16, 1, @DataValidita)
        RETURN
   END
IF @DataValidita IS NULL 
BEGIN
      SELECT @dztTipologiaStorico = dztTipologiaStorico, @dztMemStorico = dztMemStorico
        FROM DizionarioAttributi
       WHERE dztNome = @dztNome
      IF @dztTipologiaStorico = 'ann'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(YEAR,  @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'bim'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(MONTH,  2 * @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'dec'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(DAY,  10 * @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'gio'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(DAY,  @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'men'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(MONTH,  @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'sem'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(MONTH,  6 * @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'set'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(DAY,  7 * @dztMemStorico, GETDATE()), 120)
         END
      ELSE
      IF @dztTipologiaStorico = 'tri'
         BEGIN
              SET @DataValiditaOut = CONVERT(VARCHAR(10), DATEADD(MONTH,  3 * @dztMemStorico, GETDATE()), 120)
         END
      ELSE       
         BEGIN
                RAISERROR ('PeriodicitO [%s] non gestita', 16, 1, @dztTipologiaStorico)
                RETURN
         END
END
ELSE
BEGIN
      SET @DataValiditaOut = @DataValidita
END
BEGIN TRAN
INSERT INTO DM_AttributiStorico (idApp, lnk, vatiddzt, vatidUMS, vatidUMSDscNome, vatidUMSDscSimbolo,
                                 dztNome, dztMultiValue, dztIdTid, vatValore_FT, isDsccsx, vatTipoMem, DataValidita)
SELECT idApp, lnk, vatiddzt, vatidUMS, vatidUMSDscNome, vatidUMSDscSimbolo,
                                 dztNome, dztMultiValue, dztIdTid, vatValore_FT, isDsccsx, vatTipoMem, @DataValiditaOut
  FROM DM_Attributi 
 WHERE dztNome = @dztNome
COMMIT TRAN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
