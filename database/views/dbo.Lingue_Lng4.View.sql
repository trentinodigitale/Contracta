USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Lingue_Lng4]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Lingue_Lng4]
AS
SELECT Lingue.IdLng AS IdTab, 
       DescsLng4.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsLng4, Lingue 
 WHERE DescsLng4.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod >= DescsLng4.dscUltimaMod
UNION ALL
SELECT Lingue.IdLng AS IdTab, 
       DescsLng4.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsLng4, Lingue 
 WHERE DescsLng4.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod < DescsLng4.dscUltimaMod
GO
