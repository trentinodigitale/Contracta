USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Lic_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Lic_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'LicenzeControlli'
IF (@ConfDate IS NULL) /* Non Accade */
     BEGIN
        SELECT @lastDate = GETDATE()
        SELECT IdLic,rtrim(LicSource) AS LicSource,rtrim(LicKeyLicense) AS LicKeyLicense, LicTipo, rtrim(LicProfilo) AS LicProfilo, LicDeleted AS flagDeleted, LicUltimaMod
         FROM LicenzeControlli
         ORDER BY IdLic
     END 
ELSE 
     BEGIN
         IF (@lastDate IS NULL)
             SELECT IdLic,rtrim(LicSource) AS LicSource,rtrim(LicKeyLicense) AS LicKeyLicense, LicTipo, rtrim(LicProfilo) AS LicProfilo, LicDeleted AS flagDeleted, LicUltimaMod
             FROM LicenzeControlli
             ORDER BY IdLic
         ELSE
         IF (@lastDate < @ConfDate)
             SELECT IdLic,rtrim(LicSource) AS LicSource,rtrim(LicKeyLicense) AS LicKeyLicense, LicTipo, rtrim(LicProfilo) AS LicProfilo, LicDeleted AS flagDeleted, LicUltimaMod
             FROM LicenzeControlli
             WHERE LicUltimaMod > @lastDate
             ORDER BY IdLic
             SELECT @lastDate = @ConfDate
     END
GO
