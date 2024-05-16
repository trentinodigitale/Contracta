USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Lingue_I]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Lingue_I]
AS
SELECT Lingue.IdLng AS IdTab, 
       DescsI.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsI, Lingue 
 WHERE DescsI.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod >= DescsI.dscUltimaMod
UNION ALL
SELECT Lingue.IdLng AS IdTab, 
       DescsI.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsI, Lingue 
 WHERE DescsI.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod < DescsI.dscUltimaMod
GO
