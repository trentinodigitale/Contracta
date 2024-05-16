USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempRicercaInfo]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempRicercaInfo] (@IdRic INT) AS
SELECT Aziende.aziRagioneSociale AS RagioneSociale, 
 CASE
   WHEN ProfiliUtente.pfuE_mail IS NULL THEN Aziende.aziE_mail
   WHEN len(rtrim(ltrim(ProfiliUtente.pfuE_mail))) = 0 THEN Aziende.aziE_mail
   ELSE ProfiliUtente.pfuE_mail 
 END AS EMail, 
 ProfiliUtente.pfuNome AS Utente
FROM Aziende
INNER JOIN ProfiliUtente on Aziende.IdAzi = ProfiliUtente.pfuIdAzi
INNER JOIN TempRicerche on ProfiliUtente.idPfu = TempRicerche.ricIdPfu
WHERE TempRicerche.IdRic = @IdRic
GO
