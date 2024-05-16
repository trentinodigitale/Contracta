USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MotivazioneScarti_FRA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[MotivazioneScarti_FRA]
AS
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsFRA.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       MotivazioneScarti.MtsUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsFRA
 WHERE MotivazioneScarti.MtsIdDsc = DescsFRA.IdDsc
   AND MotivazioneScarti.MtsUltimaMod >= DescsFRA.dscUltimaMod
UNION ALL
SELECT MotivazioneScarti.IdMts AS IdTab, 
       DescsFRA.dscTesto AS tabTesto, 
       MotivazioneScarti.MtsIdDsc AS tabCode, 
       MotivazioneScarti.MtsDeleted AS tabDeleted,
       DescsFRA.dscUltimaMod AS tabUltimaMod
  FROM MotivazioneScarti, DescsFRA
 WHERE MotivazioneScarti.MtsIdDsc = DescsFRA.IdDsc
   AND MotivazioneScarti.MtsUltimaMod < DescsFRA.dscUltimaMod
GO
