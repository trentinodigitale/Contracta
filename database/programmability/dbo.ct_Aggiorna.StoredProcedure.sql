USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ct_Aggiorna]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--===============================
--	CODICE STRUTTURA	=
--===============================
CREATE PROCEDURE [dbo].[ct_Aggiorna](@LastDate datetime = null OUTPUT) 
AS
DECLARE @ConfDate datetime
SELECT @ConfDate = umdUltimaMod FROM Srv_UltimaMod WHERE umdNome = N'CompanyTab'
IF (@ConfDate IS null) /* Non Accade */
   BEGIN
         SELECT @LastDate = GETDATE()
         SELECT IdCt IdTab,
                ctIdMp,
                ctItype,
                ctIsubtype,
                ctIdMultiLng,
                ctProfile,
                ctFnzuPos,
                ctOrder,
                ctDeleted flagDeleted,
                ctUltimaMod,
                ctPath,
                ctParent,
                ctTabType,
                ctIdGrp,
                ctTabname
           FROM CompanyTab
         ORDER BY IdCt
   END 
ELSE 
   BEGIN
        IF (@LastDate IS NULL)
         SELECT IdCt IdTab,
                ctIdMp,
                ctItype,
                ctIsubtype,
                ctIdMultiLng,
                ctProfile,
                ctFnzuPos,
                ctOrder,
                ctDeleted flagDeleted,
                ctUltimaMod,
                ctPath,
                ctParent,
                ctTabType,
                ctIdGrp,
                ctTabname
           FROM CompanyTab
         ORDER BY IdCt
        ELSE
        IF (@LastDate < @ConfDate)
         SELECT IdCt IdTab,
                ctIdMp,
                ctItype,
                ctIsubtype,
                ctIdMultiLng,
                ctProfile,
                ctFnzuPos,
                ctOrder,
                ctDeleted flagDeleted,
                ctUltimaMod,
                ctPath,
                ctParent,
                ctTabType,
                ctIdGrp,
                ctTabname
           FROM CompanyTab
          WHERE ctUltimaMod > @LastDate
         ORDER BY IdCt
        SELECT @LastDate = @ConfDate
   END
GO
