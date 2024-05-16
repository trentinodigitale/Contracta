USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ca_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ca_Aggiorna](@LastDate datetime = null OUTPUT) 
AS
DECLARE @ConfDate datetime
SELECT @ConfDate = umdUltimaMod FROM Srv_UltimaMod WHERE umdNome = N'CompanyArea'
IF (@ConfDate IS null) /* Non Accade */
   BEGIN
         SELECT @LastDate = GETDATE()
         SELECT IdCa IdTab,
                caIdCt,
                caType,
                caIdMpMod,
                caOrder,
                caIdMultiLng,
                caRange,
                caDeleted flagDeleted,
                caUltimaMod,
                caIdGrp,
                caAreaName
           FROM CompanyArea
         ORDER BY IdCa
   END 
ELSE 
   BEGIN
        IF (@LastDate IS NULL)
         SELECT IdCa IdTab,
                caIdCt,
                caType,
                caIdMpMod,
                caOrder,
                caIdMultiLng,
                caRange,
                caDeleted flagDeleted,
                caUltimaMod,
                caIdGrp,
                caAreaName
           FROM CompanyArea
         ORDER BY IdCa
        ELSE
        IF (@LastDate < @ConfDate)
         SELECT IdCa IdTab,
                caIdCt,
                caType,
                caIdMpMod,
                caOrder,
                caIdMultiLng,
                caRange,
                caDeleted flagDeleted,
                caUltimaMod,
                caIdGrp,
                caAreaName
           FROM CompanyArea
          WHERE caUltimaMod > @LastDate
         ORDER BY IdCa
        SELECT @LastDate = @ConfDate
   END
GO
