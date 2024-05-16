USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DRAWER_USER_DOC]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_DRAWER_USER_DOC] AS
	SELECT 
		IdAzi
	   , b.idpfu AS ID_FROM
	   , b.idpfu as ID
	   , b.idpfu
	   , pfuLogin as Fascicolo
	   , pfuNome as Titolo
	   , pfuE_Mail 
	   , pfuTel
	   , pfuCell
	   , pfuCodiceFiscale as CodiceFiscale
	   , pfuprofili + '###' + pfufunzionalita     AS funzionalitautente
	   , pfuRuoloAziendale
	   , pfuIdLng as LinguaAll
	   , IdAzi as Azienda
	   , ' pfuLogin Fascicolo ' as Note
	   , pfuResponsabileUtente
	   , pfuCognome as Cognome
	   , pfunomeutente as Nome
	   , case when pfuRuoloAziendale='LEGALE RAPPRESENTANTE' then ' pfuRuoloAziendale ' else '  ' end as NotEditable
	   , pfuProfili
	   , aziProfili
	   , aziVenditore
	   , nazione

	  FROM AZIENDE a with (nolock)
			left join profiliutente b with (nolock) on idazi=pfuidazi
			left join profiliutenteattrib c with(nolock)  on b.idpfu = c.idpfu and c.dztnome = 'Plant'

GO
