USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_Lng3]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[UnitaMisura_Lng3]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsLng3.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsLng32.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsLng31.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsLng3, dbo.DescsLng3 DescsLng31, dbo.GruppiUnitaMisura, dbo.DescsLng3 DescsLng32
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsLng3.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsLng31.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsLng32.IdDsc
GO
