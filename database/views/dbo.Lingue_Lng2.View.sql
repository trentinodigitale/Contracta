USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Lingue_Lng2]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Lingue_Lng2]
AS
SELECT Lingue.IdLng AS IdTab, 
       DescsLng2.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsLng2, Lingue 
 WHERE DescsLng2.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod >= DescsLng2.dscUltimaMod
UNION ALL
SELECT Lingue.IdLng AS IdTab, 
       DescsLng2.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsLng2, Lingue 
 WHERE DescsLng2.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod < DescsLng2.dscUltimaMod
GO
