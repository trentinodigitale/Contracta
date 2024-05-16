USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_Lng2]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_Lng2]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng2.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng2
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng2.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsLng2.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng2.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsLng2.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng2
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng2.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsLng2.dscUltimaMod
GO
