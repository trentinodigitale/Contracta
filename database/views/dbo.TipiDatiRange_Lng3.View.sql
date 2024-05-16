USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_Lng3]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[TipiDatiRange_Lng3]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsLng3.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsLng3 
 WHERE TipiDatiRange.tdrIdDsc = DescsLng3.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsLng3.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsLng3.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsLng3.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsLng3 
 WHERE TipiDatiRange.tdrIdDsc = DescsLng3.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsLng3.dscUltimaMod
GO
