USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_I]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UnitaMisura_I]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsI.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsI2.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsI1.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsI, dbo.DescsI DescsI1, dbo.GruppiUnitaMisura, dbo.DescsI DescsI2
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsI.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsI1.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsI2.IdDsc
GO
