USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_Lng4]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[TipiDatiRange_Lng4]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsLng4.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsLng4 
 WHERE TipiDatiRange.tdrIdDsc = DescsLng4.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsLng4.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsLng4.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsLng4.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsLng4 
 WHERE TipiDatiRange.tdrIdDsc = DescsLng4.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsLng4.dscUltimaMod
GO
