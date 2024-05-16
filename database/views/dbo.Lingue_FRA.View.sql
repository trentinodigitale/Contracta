USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Lingue_FRA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Lingue_FRA]
AS
SELECT Lingue.IdLng AS IdTab, 
       DescsFRA.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsFRA, Lingue 
 WHERE DescsFRA.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod >= DescsFRA.dscUltimaMod
UNION ALL
SELECT Lingue.IdLng AS IdTab, 
       DescsFRA.dscTesto AS tabTesto, 
       Lingue.lngSuffisso,
       Lingue.lngDeleted, 
       Lingue.lngUltimaMod AS tabUltimaMod
  FROM DescsFRA, Lingue 
 WHERE DescsFRA.IdDsc = Lingue.lngIdDsc
   AND Lingue.lngUltimaMod < DescsFRA.dscUltimaMod
GO
