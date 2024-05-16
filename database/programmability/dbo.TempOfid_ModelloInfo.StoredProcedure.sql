USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOfid_ModelloInfo]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.TempOfid_ModelloInfo    Script Date: 04/07/2000 17.55.24 ******/
CREATE PROCEDURE [dbo].[TempOfid_ModelloInfo] (@IdMdl INT) AS
SELECT Aziende.aziRagioneSociale AS RagioneSociale, 
 CASE
   WHEN ProfiliUtente.pfuE_mail IS NULL THEN Aziende.aziE_mail
   WHEN len(rtrim(ltrim(ProfiliUtente.pfuE_mail))) = 0 THEN Aziende.aziE_mail
   ELSE ProfiliUtente.pfuE_mail 
 END AS EMail, 
 ProfiliUtente.pfuNome AS Utente,
 aziende.idAzi 
FROM Aziende
INNER JOIN ProfiliUtente on Aziende.IdAzi = ProfiliUtente.pfuIdAzi
INNER JOIN TempModelli on ProfiliUtente.idPfu = TempModelli.mdlIdPfu
WHERE TempModelli.IdMdl = @IdMdl
GO
