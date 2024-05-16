USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_USERDOC_UPD_BASE_FROM_DRAWER_USER_DOC]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_USERDOC_UPD_BASE_FROM_DRAWER_USER_DOC] AS
	SELECT 
		IdAzi
	   ,profiliutente.idpfu AS ID_FROM
	   ,profiliutente.idpfu as ID
	   ,pfuLogin as Fascicolo
	   ,pfuNome as Titolo
	   ,pfuE_Mail 
	   ,pfuTel
	   ,pfuCell
	   ,pfuPrefissoProt
	   ,pfuCodiceFiscale as CodiceFiscale
	   ,pfuprofili + '###' + pfufunzionalita     AS funzionalitautente
	   ,pfuRuoloAziendale
	   ,pfuIdLng as LinguaAll
	   ,IdAzi as Azienda
	   ,profiliutente.idpfu as Destinatario_User
	   ,' pfuLogin Fascicolo ' as Note
	   ,pfuResponsabileUtente
	   ,pfuCognome as Cognome
	   ,pfunomeutente as Nome
	   ,case when pfuRuoloAziendale='LEGALE RAPPRESENTANTE' then ' pfuRuoloAziendale codicefiscale ' else ' codicefiscale ' end as NotEditable
	   ,pfuDataCreazione
	  FROM AZIENDE with (nolock)
			inner join profiliutente  with (nolock) on idazi=pfuidazi
GO
