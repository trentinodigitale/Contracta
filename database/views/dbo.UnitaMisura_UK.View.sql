USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_UK]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UnitaMisura_UK]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsUK.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsUK2.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsUK1.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsUK, dbo.DescsUK DescsUK1, dbo.GruppiUnitaMisura, dbo.DescsUK DescsUK2
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsUK.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsUK1.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsUK2.IdDsc
GO
