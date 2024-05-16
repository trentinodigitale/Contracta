USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TempRicercheArt_Dett_I]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TempRicercheArt_Dett_I] AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsI.dscTesto AS artDesc, Articoli.artQMO AS artQMO,
       Web.artWeb
  FROM TempRicercheArticoli, Articoli, Aziende, DescsI, ArtWeb AS Web
 WHERE TempRicercheArticoli.racIdArt = Articoli.IdArt
   AND Articoli.artIdAzi = Aziende.IdAzi
   AND Articoli.artIdDscDescrizione = DescsI.IdDsc       
   AND Articoli.IdArt = Web.IdArt
UNION ALL
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsI.dscTesto AS artDesc, Articoli.artQMO AS artQMO,
       CAST(NULL AS NVARCHAR(4000)) AS artWeb
  FROM TempRicercheArticoli, Articoli, Aziende, DescsI
 WHERE TempRicercheArticoli.racIdArt = Articoli.IdArt
   AND Articoli.artIdAzi = Aziende.IdAzi
   AND Articoli.artIdDscDescrizione = DescsI.IdDsc       
   AND Articoli.IdArt NOT IN (SELECT IdArt FROM ArtWeb)
GO
