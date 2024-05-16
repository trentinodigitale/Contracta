USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_FRA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TipiDatiRange_FRA]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsFRA.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsFRA 
 WHERE TipiDatiRange.tdrIdDsc = DescsFRA.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsFRA.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsFRA.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsFRA.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsFRA 
 WHERE TipiDatiRange.tdrIdDsc = DescsFRA.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsFRA.dscUltimaMod
GO
