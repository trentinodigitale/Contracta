USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_UK]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_UK]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsUK.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsUK
 WHERE MotivazioneScarti.MtsIdDsc = DescsUK.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsUK.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsUK.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsUK.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsUK
 WHERE MotivazioneScarti.MtsIdDsc = DescsUK.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsUK.dscUltimaMod
GO
