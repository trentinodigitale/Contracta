USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_UK]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TipiDatiRange_UK]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsUK.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsUK 
 WHERE TipiDatiRange.tdrIdDsc = DescsUK.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsUK.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsUK.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsUK.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsUK 
 WHERE TipiDatiRange.tdrIdDsc = DescsUK.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsUK.dscUltimaMod
GO
