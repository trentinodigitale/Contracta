USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[tdr_Aggiorna_I]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[tdr_Aggiorna_I] (@LastDate datetime = null OUTPUT) AS
 DECLARE @ConfDate datetime
 SELECT @ConfDate = umdUltimaMod FROM Srv_UltimaMod WHERE umdNome = 'TipiDatiRange'
 IF (@ConfDate IS null) /* Non accade */
 BEGIN
  SELECT @LastDate = GETDATE()
  SELECT IdTab, tabTesto, tdrIdDsc, tdrIdTid, tdrRelOrdine, tdrCodice,tdrDeleted as flagDeleted,tdrCodiceEsterno
   FROM TipiDatiRange_I
   ORDER BY IdTab
 END ELSE BEGIN
  IF (@LastDate IS NULL)
  SELECT IdTab, tabTesto, tdrIdDsc, tdrIdTid, tdrRelOrdine, tdrCodice,tdrDeleted as flagDeleted,tdrCodiceEsterno
    FROM TipiDatiRange_I
    ORDER BY IdTab
  ELSE
   IF (@LastDate < @ConfDate)
     SELECT IdTab, tabTesto, tdrIdDsc, tdrIdTid, tdrRelOrdine, tdrCodice,tdrDeleted as flagDeleted,tdrCodiceEsterno
     FROM TipiDatiRange_I
     WHERE tabUltimaMod > @LastDate
     ORDER BY IdTab
  SELECT @LastDate = @ConfDate
 END
GO
