USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[apat_Aggiorna]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[apat_Aggiorna](@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'AppartenenzaAttributi'
 IF (@ConfDate IS NULL) /* Non Accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT IdApAt, apatIdDzt, apatIdApp, apatDeleted AS flagDeleted, apatUltimaMod
   FROM AppartenenzaAttributi
   ORDER BY IdApAt
 END ELSE BEGIN
  IF (@lastDate IS NULL)
  SELECT IdApAt, apatIdDzt, apatIdApp, apatDeleted AS flagDeleted, apatUltimaMod
   FROM AppartenenzaAttributi
   ORDER BY IdApAt
  ELSE
   IF (@lastDate < @ConfDate)
  SELECT IdApAt, apatIdDzt, apatIdApp, apatDeleted AS flagDeleted, apatUltimaMod
   FROM AppartenenzaAttributi
        WHERE apatUltimaMod > @lastDate
        ORDER BY IdApAt
   SELECT @lastDate = @ConfDate
 END
GO
