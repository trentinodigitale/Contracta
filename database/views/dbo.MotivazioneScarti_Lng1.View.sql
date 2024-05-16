USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_Lng1]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_Lng1]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng1.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng1
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng1.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsLng1.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng1.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsLng1.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng1
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng1.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsLng1.dscUltimaMod
GO
