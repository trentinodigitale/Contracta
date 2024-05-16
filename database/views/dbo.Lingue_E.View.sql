USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Lingue_E]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Lingue_E]
AS
SELECT Lingue.IdLng AS IdTab, 
       DescsE.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsE, Lingue 
 WHERE DescsE.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod >= DescsE.dscUltimaMod
UNION ALL
SELECT Lingue.IdLng AS IdTab, 
       DescsE.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsE, Lingue 
 WHERE DescsE.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod < DescsE.dscUltimaMod
GO
