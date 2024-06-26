USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_ModelloInfo]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_ModelloInfo] (@IdMdl INT) AS
SELECT Aziende.aziRagioneSociale AS RagioneSociale, Aziende.aziE_mail AS EMail, ProfiliUtente.pfuNome AS Utente
  FROM Aziende, PRofiliUtente, Modelli
 WHERE Aziende.IdAzi = ProfiliUtente.pfuIdAzi
   AND ProfiliUtente.idPfu = Modelli.mdlIdPfu
   AND Modelli.IdMdl = @IdMdl
   AND (ProfiliUtente.pfuE_mail IS NULL OR RTRIM(LTRIM(ProfiliUtente.pfuE_mail)) = '')
UNION ALL
SELECT Aziende.aziRagioneSociale AS RagioneSociale, ProfiliUtente.pfuE_mail AS EMail, ProfiliUtente.pfuNome AS Utente
  FROM Aziende, PRofiliUtente, Modelli
 WHERE Aziende.IdAzi = ProfiliUtente.pfuIdAzi
   AND ProfiliUtente.idPfu = Modelli.mdlIdPfu
   AND Modelli.IdMdl = @IdMdl
   AND (ProfiliUtente.pfuE_mail IS NOT NULL AND RTRIM(LTRIM(ProfiliUtente.pfuE_mail)) <> '')
GO
