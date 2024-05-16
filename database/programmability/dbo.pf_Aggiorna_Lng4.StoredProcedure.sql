USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[pf_Aggiorna_Lng4]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pf_Aggiorna_Lng4](@lastDate DATETIME = NULL OUTPUT) 
AS
DECLARE @ConfDate DATETIME
SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'PublicFolders'
IF (@ConfDate IS NULL) /* Non Accade */
   BEGIN
         SELECT @lastDate = GETDATE()
         SELECT IdPf,
                pfIdGrp,
                pfPath,
                mlngDesc_Lng4 AS pfDescr,
                pfFoglia,
                pfIdMpfc,
                pfUltimaMod,
                pfDeleted AS flagDeleted
           FROM PublicFolders, Multilinguismo
         WHERE pfIdMultilng = IdMultilng
         ORDER BY IdPf
   END 
ELSE 
   BEGIN
        IF (@lastDate IS NULL)
         SELECT IdPf,
                pfIdGrp,
                pfPath,
                mlngDesc_Lng4 AS pfDescr,
                pfFoglia,
                pfIdMpfc,
                pfUltimaMod,
                pfDeleted AS flagDeleted
           FROM PublicFolders, Multilinguismo
         WHERE pfIdMultilng = IdMultilng
         ORDER BY IdPf
        ELSE
        IF (@lastDate < @ConfDate)
         SELECT IdPf,
                pfIdGrp,
                pfPath,
                mlngDesc_Lng4 AS pfDescr,
                pfFoglia,
                pfIdMpfc,
                pfUltimaMod,
                pfDeleted AS flagDeleted
           FROM PublicFolders, Multilinguismo
         WHERE pfIdMultilng = IdMultilng AND pfUltimaMod > @lastDate
         ORDER BY IdPf
        SELECT @lastDate = @ConfDate
   END
GO
