USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_INVIOMAIL]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_INVIOMAIL] AS
SELECT lngSuffisso AS LNG, IdPfu AS iddoc
     , IdAzi
     , aziLog  
     , aziRagioneSociale
     , aziPartitaIVA
     , pfuNome 
     , pfuLogin 
     , pfue_mail
     , dbo.fnc_Decrypt(pfuPassword) AS [Password]
     , mpmcMail AS MailBody
  FROM Aziende 
     , ProfiliUtente
     , Lingue
     , MPMailCensimento
 WHERE IdAzi = pfuIdAzi
   AND IdAzi = mpmcIdAzi
   AND pfuIdLng = IdLng
   AND IdAzi <> 35152001
   AND mpmcDeleted = 0


GO
