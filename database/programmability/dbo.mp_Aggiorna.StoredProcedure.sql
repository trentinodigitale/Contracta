USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[mp_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[mp_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'MarketPlace'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdMp, mpLog, mpRagioneSociale, mpURL, mpIdAziMaster, mpIdLng, mpTenderMaxAziende, mpTenderggScadenza, mpCatalogoUnico, mpVisibilitaInterna, mpVisibilitaEsterna, cast(substring(mpOpzioni, 2, 1) AS bit) AS mpLavoraOffLine, mpDeleted AS flagDeleted, mpUltimaMod, cast(substring(mpOpzioni, 8, 1) AS bit) AS bDestSingleSel
   FROM MarketPlace
     ORDER BY IdMp
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdMp, mpLog, mpRagioneSociale, mpURL, mpIdAziMaster, mpIdLng, mpTenderMaxAziende, mpTenderggScadenza, mpCatalogoUnico, mpVisibilitaInterna, mpVisibilitaEsterna, cast(substring(mpOpzioni, 2, 1) AS bit) AS mpLavoraOffLine, mpDeleted AS flagDeleted, mpUltimaMod, cast(substring(mpOpzioni, 8, 1) AS bit) AS bDestSingleSel
   FROM MarketPlace
     ORDER BY IdMp
  ELSE
   IF (@lastDate < @ConfDate)
     SELECT IdMp, mpLog, mpRagioneSociale, mpURL, mpIdAziMaster, mpIdLng, mpTenderMaxAziende, mpTenderggScadenza, mpCatalogoUnico, mpVisibilitaInterna, mpVisibilitaEsterna, cast(substring(mpOpzioni, 2, 1) AS bit) AS mpLavoraOffLine, mpDeleted AS flagDeleted, mpUltimaMod, cast(substring(mpOpzioni, 8, 1) AS bit) AS bDestSingleSel
     FROM MarketPlace
     WHERE mpUltimaMod > @lastDate
     ORDER BY IdMp
  SELECT @lastDate = @ConfDate
 END
GO
