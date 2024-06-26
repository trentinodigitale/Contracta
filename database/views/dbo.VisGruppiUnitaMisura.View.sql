USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VisGruppiUnitaMisura]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VisGruppiUnitaMisura]
AS
SELECT GruppiUnitaMisura.IdGum, DescsI.dscTesto AS gumDscI, DescsUK.dscTesto AS gumDscUk, DescsE.dscTesto AS gumDscE 
  FROM GruppiUnitaMisura, DescsI, DescsUK, DescsE
 WHERE GruppiUnitaMisura.gumIdDscNome = DescsI.IdDsc 
   AND GruppiUnitaMisura.gumIdDscNome = DescsUK.IdDsc
   AND GruppiUnitaMisura.gumIdDscNome = DescsE.IdDsc
GO
