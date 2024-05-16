USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mpdg_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mpdg_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MPDominiGerarchici'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdMpDg, mpdgIdMp, mpdgIdDg, mpdgTipo, dgCodiceInterno AS mpdgValue, dgCodiceEsterno AS mpdgCode, mpdgShowPath, mpdgDeleted AS flagDeleted, mpdgUltimaMod
   FROM MPDominiGerarchici, DominiGerarchici
  WHERE mpdgIdDg = IdDg
     ORDER BY IdMpDg
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdMpDg, mpdgIdMp, mpdgIdDg, mpdgTipo, dgCodiceInterno AS mpdgValue, dgCodiceEsterno AS mpdgCode, mpdgShowPath, mpdgDeleted AS flagDeleted, mpdgUltimaMod
   FROM MPDominiGerarchici, DominiGerarchici
  WHERE mpdgIdDg = IdDg
     ORDER BY IdMpDg
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdMpDg, mpdgIdMp, mpdgIdDg, mpdgTipo, dgCodiceInterno AS mpdgValue, dgCodiceEsterno AS mpdgCode, mpdgShowPath, mpdgDeleted AS flagDeleted, mpdgUltimaMod
   FROM MPDominiGerarchici, DominiGerarchici
  WHERE mpdgIdDg = IdDg AND mpdgUltimaMod > @lastDate
     ORDER BY IdMpDg
  SELECT @lastDate = @ConfDate
 END
GO
