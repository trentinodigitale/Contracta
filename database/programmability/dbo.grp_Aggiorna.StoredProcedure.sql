USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[grp_Aggiorna]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[grp_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'FunctionsGroups'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdGrp,
                grpName,
                grpUltimaMod,
                grpDeleted flagDeleted
           FROM FunctionsGroups
         ORDER BY IdGrp
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdGrp,
                grpName,
                grpUltimaMod,
                grpDeleted flagDeleted
           FROM FunctionsGroups
         ORDER BY IdGrp
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdGrp,
                grpName,
                grpUltimaMod,
                grpDeleted flagDeleted
           FROM FunctionsGroups
          WHERE grpUltimaMod > @lastDate
         ORDER BY IdGrp
        SELECT @lastDate = @ConfDate
   END
GO
