USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_EleRDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOModOfid_EleRDO] (@IdMdl INT) AS
  SELECT ModelliAziende.*,
  ISNULL(Offerte.offStato,255) AS mazCStato,
  ISNULL(CASE Offerte.offStato
   WHEN 0 THEN 'Non Ricevuta '
   WHEN 1 THEN 'In Corso'
   WHEN 2 THEN 'In Corso'
   WHEN 3 THEN 'Spedita'
  END,'Non Inviabile') AS mazDStato,
  Aziende.aziRagioneSociale,
  Aziende.aziE_Mail
 FROM ModelliAziende
  LEFT OUTER JOIN Offerte ON ModelliAziende.mazIdOff = Offerte.IdOff
  INNER JOIN Aziende ON ModelliAziende.mazIdAzi = Aziende.IdAzi
 WHERE mazIdMdl = @IdMdl
 ORDER BY IdMaz
GO
