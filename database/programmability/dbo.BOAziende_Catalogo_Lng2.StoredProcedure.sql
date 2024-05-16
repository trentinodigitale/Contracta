USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOAziende_Catalogo_Lng2]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOAziende_Catalogo_Lng2] (@IdAzi INT)
AS
SELECT Articoli.IdArt,
       Articoli.artIdAzi,
       Articoli.artCspValue,
       Articoli.artCode, 
       Articoli.artIdUms,
       Aziende.aziRagioneSociale,
       DescsLng2.dscTesto AS artDesc,
       Articoli.artQMO,
       Articoli.artSitoWeb AS artWeb
  FROM Articoli, DescsLng2, Aziende
 WHERE Articoli.artIdDscDescrizione = DescsLng2.IdDsc
   AND Articoli.artIdAzi = Aziende.IdAzi
   AND Articoli.artIdazi = @IdAzi 
   AND Articoli.artDeleted = 0
GO
