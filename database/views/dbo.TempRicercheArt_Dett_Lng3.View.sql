USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TempRicercheArt_Dett_Lng3]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[TempRicercheArt_Dett_Lng3] AS
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsLng3.dscTesto AS artDesc, Articoli.artQMO AS artQMO,
       Web.artWeb
  FROM TempRicercheArticoli, Articoli, Aziende, DescsLng3, ArtWeb AS Web
 WHERE TempRicercheArticoli.racIdArt = Articoli.IdArt
   AND Articoli.artIdAzi = Aziende.IdAzi
   AND Articoli.artIdDscDescrizione = DescsLng3.IdDsc       
   AND Articoli.IdArt = Web.IdArt
UNION ALL
SELECT Articoli.IdArt, Articoli.artIdAzi, Articoli.artCspValue, Articoli.artCode, Articoli.artIdUms, 
       Aziende.aziRagioneSociale, DescsLng3.dscTesto AS artDesc, Articoli.artQMO AS artQMO,
       CAST(NULL AS NVARCHAR(4000)) AS artWeb
  FROM TempRicercheArticoli, Articoli, Aziende, DescsLng3
 WHERE TempRicercheArticoli.racIdArt = Articoli.IdArt
   AND Articoli.artIdAzi = Aziende.IdAzi
   AND Articoli.artIdDscDescrizione = DescsLng3.IdDsc       
   AND Articoli.IdArt NOT IN (SELECT IdArt FROM ArtWeb)
GO
