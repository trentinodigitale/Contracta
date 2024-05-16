USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Lingue_UK]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Lingue_UK]
AS
SELECT Lingue.IdLng AS IdTab, 
       DescsUK.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsUK, Lingue 
 WHERE DescsUK.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod >= DescsUK.dscUltimaMod
UNION ALL
SELECT Lingue.IdLng AS IdTab, 
       DescsUK.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsUK, Lingue 
 WHERE DescsUK.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod < DescsUK.dscUltimaMod
GO
