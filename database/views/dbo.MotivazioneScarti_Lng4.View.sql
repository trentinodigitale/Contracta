USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_Lng4]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_Lng4]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng4.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng4
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng4.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsLng4.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsLng4.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsLng4.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsLng4
 WHERE MotivazioneScarti.MtsIdDsc = DescsLng4.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsLng4.dscUltimaMod
GO
