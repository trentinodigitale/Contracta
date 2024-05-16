USE [AFLink_TND]
GO
/****** Object:  View [dbo].[UnitaMisura_Lng4]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[UnitaMisura_Lng4]
AS
SELECT dbo.UnitaMisura.IdUms, dbo.DescsLng4.dscTesto AS umsNome, dbo.UnitaMisura.umsIdGum, DescsLng42.dscTesto AS umsGruppoUM, 
       dbo.UnitaMisura.umsRapNorm, DescsLng41.dscTesto AS umsSimbolo, dbo.UnitaMisura.umsDeleted AS flagDeleted, 
       dbo.GruppiUnitaMisura.gumDeleted
  FROM dbo.UnitaMisura, dbo.DescsLng4, dbo.DescsLng4 DescsLng41, dbo.GruppiUnitaMisura, dbo.DescsLng4 DescsLng42
 WHERE dbo.UnitaMisura.umsIdDscNome = dbo.DescsLng4.IdDsc
   AND dbo.UnitaMisura.umsIdDscSimbolo = DescsLng41.IdDsc
   AND dbo.UnitaMisura.umsIdGum = dbo.GruppiUnitaMisura.IdGum
   AND dbo.GruppiUnitaMisura.gumIdDscNome = DescsLng42.IdDsc
GO
