USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_Catalogo_Desc_FRA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_Catalogo_Desc_FRA] (@IdAzi INT)
AS
SELECT Articoli.IdArt,
       Articoli.artIdAzi,
       DescsCSP.dscTesto AS artCsp,
       Articoli.artCode, 
       DescsUMS.dscTesto AS artUms,
       Aziende.aziRagioneSociale,
       DescsART.dscTesto AS artDesc,
       Articoli.artQMO,
       Articoli.artSitoWeb AS artWeb
  FROM Articoli, DescsFRA DescsART, ClassificazioneSP, DescsFRA DescsCSP, UnitaMisura, DescsFRA DescsUMS, Aziende
 WHERE Articoli.artIdDscDescrizione = DescsART.IdDsc
   AND ClassificazioneSP.cspvalue = Articoli.artCspValue
   AND DescsCSP.IdDsc = ClassificazioneSP.cspIdDsc
   AND UnitaMisura.IdUms = Articoli.artIdUms
   AND DescsUMS.IdDsc = UnitaMisura.umsIddscNome
   AND Articoli.artIdAzi = Aziende.IdAzi
   AND artIdazi = @IdAzi 
   AND artDeleted = 0
GO
