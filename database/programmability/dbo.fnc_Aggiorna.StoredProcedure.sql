USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[fnc_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[fnc_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'Functions'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdFnc,
                fncIdGrp,
                fncLocation,
                fncName,
                fncIcon,
                fncCaption,
                fncUserFunz,
                fncUse,
                fncHide,
                fncCommand,
                fncParam,
                fncCondition,
                fncOrder,
                fncUltimaMod, 
                fncDeleted AS flagDeleted
           FROM Functions
         ORDER BY IdFnc
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdFnc,
                fncIdGrp,
                fncLocation,
                fncName,
                fncIcon,
                fncCaption,
                fncUserFunz,
                fncUse,
                fncHide,
                fncCommand,
                fncParam,
                fncCondition,
                fncOrder,
                fncUltimaMod, 
                fncDeleted AS flagDeleted
           FROM Functions
         ORDER BY IdFnc
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdFnc,
                fncIdGrp,
                fncLocation,
                fncName,
                fncIcon,
                fncCaption,
                fncUserFunz,
                fncUse,
                fncHide,
                fncCommand,
                fncParam,
                fncCondition,
                fncOrder,
                fncUltimaMod, 
                fncDeleted AS flagDeleted
           FROM Functions
          WHERE fncUltimaMod > @lastDate
         ORDER BY IdFnc
        SELECT @lastDate = @ConfDate
   END
GO
