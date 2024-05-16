USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_Lng2]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[UnitaMisura_Lng2]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsLng2.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsLng22.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsLng21.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsLng2, dbo.DescsLng2 DescsLng21, dbo.GruppiUnitaMisura, dbo.DescsLng2 DescsLng22
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsLng2.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsLng21.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsLng22.IdDsc
GO
