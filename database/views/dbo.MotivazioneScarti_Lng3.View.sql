USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_Lng3]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_Lng3]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng3.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng3
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng3.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsLng3.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng3.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsLng3.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng3
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng3.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsLng3.dscUltimaMod
GO
