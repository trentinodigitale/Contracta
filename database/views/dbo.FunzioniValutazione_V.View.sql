USE [AFLink_TND]
GO
/****** Object:  View [dbo].[FunzioniValutazione_V]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[FunzioniValutazione_V]
AS
SELECT FunzioniValutazione.IdFva AS IdTab, 
       DescsI.dscTesto AS TabTesto, 
       FunzioniValutazione.FvaValori  AS TabValori, 
       FunzioniValutazione.fvaDeleted AS TabDeleted,
       FunzioniValutazione.fvaUltimaMod AS tabUltimaMod
  FROM FunzioniValutazione, DescsI 
 WHERE FunzioniValutazione.fvaIdDsc = DescsI.IdDsc
   AND FunzioniValutazione.fvaUltimaMod >= DescsI.dscUltimaMod
UNION ALL
SELECT FunzioniValutazione.IdFva AS IdTab, 
       DescsI.dscTesto AS TabTesto, 
       FunzioniValutazione.FvaValori  AS TabValori, 
       FunzioniValutazione.fvaDeleted AS TabDeleted,
       DescsI.dscUltimaMod AS tabUltimaMod
  FROM FunzioniValutazione, DescsI 
 WHERE FunzioniValutazione.fvaIdDsc = DescsI.IdDsc
   AND FunzioniValutazione.fvaUltimaMod < DescsI.dscUltimaMod
GO
