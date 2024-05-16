USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TipiDatiRange_E]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TipiDatiRange_E]
AS
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsE.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       TipiDatiRange.tdrUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsE 
 WHERE TipiDatiRange.tdrIdDsc = DescsE.IdDsc
   AND TipiDatiRange.tdrUltimaMod >= DescsE.dscUltimaMod
UNION ALL
SELECT TipiDatiRange.IdTdr AS IdTab, 
       DescsE.dscTesto AS tabTesto, 
       TipiDatiRange.tdrIdDsc, 
       TipiDatiRange.tdrIdTid, 
       TipiDatiRange.tdrRelOrdine, 
       DescsE.dscUltimaMod AS tabUltimaMod,
       TipiDatiRange.tdrCodice,
       TipiDatiRange.tdrDeleted,
       TipiDatiRange.tdrCodiceEsterno
  FROM TipiDatiRange, DescsE 
 WHERE TipiDatiRange.tdrIdDsc = DescsE.IdDsc
   AND TipiDatiRange.tdrUltimaMod < DescsE.dscUltimaMod
GO
