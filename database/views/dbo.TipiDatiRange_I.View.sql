USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_I]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TipiDatiRange_I]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsI.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsI 
 WHERE TipiDatiRange.tdrIdDsc = DescsI.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsI.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsI.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsI.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsI 
 WHERE TipiDatiRange.tdrIdDsc = DescsI.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsI.dscUltimaMod
GO
