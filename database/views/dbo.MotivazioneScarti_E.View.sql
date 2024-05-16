USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_E]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_E]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsE.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsE
 WHERE MotivazioneScarti.MtsIdDsc = DescsE.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsE.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsE.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsE.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsE
 WHERE MotivazioneScarti.MtsIdDsc = DescsE.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsE.dscUltimaMod
GO
