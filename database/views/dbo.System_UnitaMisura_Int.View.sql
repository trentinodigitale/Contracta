USE [AFLink_TND]
GO
/****** Object:  View [dbo].[System_UnitaMisura_Int]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[System_UnitaMisura_Int]
AS
SELECT UnitaMisura.IdUms, 
       DescsI.dscTesto AS umsNome_I, 
       DescsUK.dscTesto AS umsNome_UK, 
       DescsE.dscTesto AS umsNome_E, 
       UnitaMisura.umsIdGum, 
       DescsI2.dscTesto AS umsGruppoUM_I, 
       DescsUK2.dscTesto AS umsGruppoUM_UK, 
       DescsE2.dscTesto AS umsGruppoUM_E, 
       UnitaMisura.umsRapNorm, 
       UnitaMisura.umsUltimaMod, 
       DescsI1.dscTesto AS umsSimbolo_I, 
       DescsUK1.dscTesto AS umsSimbolo_UK,
       DescsE1.dscTesto AS umsSimbolo_E
  FROM UnitaMisura, DescsI, DescsUK, DescsE, DescsI  DescsI1, DescsUK DescsUK1, DescsE  DescsE1, GruppiUnitaMisura,
       DescsI DescsI2, DescsUK DescsUK2, DescsE DescsE2
 WHERE UnitaMisura.umsIdDscNome = DescsI.IdDsc 
       AND UnitaMisura.umsIdDscNome = DescsUK.IdDsc 
       AND UnitaMisura.umsIdDscNome = DescsE.IdDsc 
       AND UnitaMisura.umsIdDscSimbolo = DescsI1.IdDsc 
       AND UnitaMisura.umsIdDscSimbolo = DescsUK1.IdDsc 
       AND UnitaMisura.umsIdDscSimbolo = DescsE1.IdDsc 
       AND UnitaMisura.umsIdGum = GruppiUnitaMisura.IdGum 
       AND GruppiUnitaMisura.gumIdDscNome = DescsI2.IdDsc 
       AND GruppiUnitaMisura.gumIdDscNome = DescsUK2.IdDsc
       AND GruppiUnitaMisura.gumIdDscNome = DescsE2.IdDsc
GO
