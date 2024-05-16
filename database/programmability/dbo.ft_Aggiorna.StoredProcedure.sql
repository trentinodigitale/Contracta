USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ft_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ft_Aggiorna](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'FolderTypes'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdFt,
                ftIdPf,
                ftIdDcm,
                ftUltimaMod,
                ftDeleted AS flagDeleted
           FROM FolderTypes
         ORDER BY IdFt
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdFt,
                ftIdPf,
                ftIdDcm,
                ftUltimaMod,
                ftDeleted AS flagDeleted
           FROM FolderTypes
         ORDER BY IdFt
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdFt,
                ftIdPf,
                ftIdDcm,
                ftUltimaMod,
                ftDeleted AS flagDeleted
           FROM FolderTypes
             WHERE ftUltimaMod > @lastDate
         ORDER BY IdFt
        SELECT @lastDate = @ConfDate
   END
GO
