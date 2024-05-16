USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ums_Aggiorna_E]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[ums_Aggiorna_E] (@lastDate DATETIME = NULL OUTPUT) AS
 DECLARE @ConfDate DATETIME
 /* La tabella unita misura viene aggiornata INTeramente */
 SELECT @ConfDate = umdUltimaMod FROM srv_UltimaMod WHERE umdNome = 'UnitaMisura'
 IF (@ConfDate IS NULL) /* Non accade */
 BEGIN
  SELECT @lastDate = GETDATE()
  SELECT *
   FROM UnitaMisura_E
   ORDER BY IdUms
 END ELSE BEGIN
  IF (@lastDate IS NULL)
   SELECT *
    FROM UnitaMisura_E
    ORDER BY IdUms
  ELSE
   IF (@lastDate < @ConfDate)
    SELECT *
     FROM UnitaMisura_E
     ORDER BY IdUms
  SELECT @lastDate = @ConfDate
 END
GO
