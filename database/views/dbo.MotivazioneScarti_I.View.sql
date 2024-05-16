USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_I]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_I] AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsI.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsI
 WHERE MotivazioneScarti.MtsIdDsc = DescsI.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsI.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsI.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsI.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsI
 WHERE MotivazioneScarti.MtsIdDsc = DescsI.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsI.dscUltimaMod
GO
