USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_FRA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UnitaMisura_FRA]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsFRA.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsFRA2.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsFRA1.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsFRA, dbo.DescsFRA DescsFRA1, dbo.GruppiUnitaMisura, dbo.DescsFRA DescsFRA2
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsFRA.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsFRA1.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsFRA2.IdDsc
GO
