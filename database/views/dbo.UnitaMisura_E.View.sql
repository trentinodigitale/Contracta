USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_E]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UnitaMisura_E]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsE.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsE2.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsE1.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsE, dbo.DescsE DescsE1, dbo.GruppiUnitaMisura, dbo.DescsE DescsE2
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsE.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsE1.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsE2.IdDsc
GO
