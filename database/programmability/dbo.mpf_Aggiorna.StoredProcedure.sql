USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpf_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpf_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPFolder'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdMpf, mpfIdMp, mpfIType, mpfSubType, mpfIdMultilng, mpfSource, mpfCreateSubFolder, mpfHidden, mpfFnzuPos, mpfFunzionalita, mpfDeleted AS flagDeleted, mpfUltimaMod, mpfIcona, mpfUse, mpfIdGrp
   FROM MPFolder
   ORDER BY IdMpf
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdMpf, mpfIdMp, mpfIType, mpfSubType, mpfIdMultilng, mpfSource, mpfCreateSubFolder, mpfHidden, mpfFnzuPos, mpfFunzionalita, mpfDeleted AS flagDeleted, mpfUltimaMod, mpfIcona, mpfUse, mpfIdGrp
   FROM MPFolder
   ORDER BY IdMpf
  ELSE
   IF (@lastDate < @ConfDate)
        SELECT IdMpf, mpfIdMp, mpfIType, mpfSubType, mpfIdMultilng, mpfSource, mpfCreateSubFolder, mpfHidden, mpfFnzuPos, mpfFunzionalita, mpfDeleted AS flagDeleted, mpfUltimaMod, mpfIcona, mpfUse, mpfIdGrp
         FROM MPFolder
        WHERE mpfUltimaMod > @lastDate
        ORDER BY IdMpf
   SELECT @lastDate = @ConfDate
 END
GO
