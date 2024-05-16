USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_Lng1]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[UnitaMisura_Lng1]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsLng1.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsLng12.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsLng11.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsLng1, dbo.DescsLng1 DescsLng11, dbo.GruppiUnitaMisura, dbo.DescsLng1 DescsLng12
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsLng1.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsLng11.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsLng12.IdDsc
GO
