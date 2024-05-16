USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_Lng1]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[TipiDatiRange_Lng1]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsLng1.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsLng1 
 WHERE TipiDatiRange.tdrIdDsc = DescsLng1.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsLng1.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsLng1.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsLng1.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsLng1 
 WHERE TipiDatiRange.tdrIdDsc = DescsLng1.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsLng1.dscUltimaMod
GO
