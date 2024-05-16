USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_USERDOC_UPD_BASE_FROM_USER_DOC_READONLY]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD2_USERDOC_UPD_BASE_FROM_USER_DOC_READONLY]
AS
SELECT 
    IdAzi
   , profiliutente.idpfu AS ID_FROM
   ,profiliutente.idpfu as ID
   ,pfuLogin as Fascicolo
   ,pfuNome as Titolo
   ,pfuE_Mail 
   ,pfuTel
   ,pfuCell
   ,pfuPrefissoProt
   ,pfuCodiceFiscale as CodiceFiscale
   , pfuprofili + '###' + pfufunzionalita     AS funzionalitautente
   ,pfuRuoloAziendale
   ,pfuIdLng as LinguaAll
   ,IdAzi as Azienda
   ,profiliutente.idpfu as Destinatario_User
   ,' pfuLogin Fascicolo ' as Note
   , PrevDoc
   ,pfuResponsabileUtente
   ,pfuCognome as Cognome
   ,pfunomeutente as Nome
   ,case when pfuRuoloAziendale='LEGALE RAPPRESENTANTE' then ' pfuRuoloAziendale codicefiscale ' else ' codicefiscale ' end as NotEditable
   ,pfuDataCreazione
   ,CASE ISNULL(pfudeleted,0)
			when 1 then  'deleted'
			else
			CASE ISNULL(pfustato,'')
				WHEN 'block' THEN 'blocked'
				WHEN  '' THEN 'not-blocked'			
			end 
	END AS StatoUtenti 
  FROM AZIENDE
  inner join profiliutente on idazi=pfuidazi
  left outer join (Select max(ID) as PrevDoc,Destinatario_User from CTL_DOC where tipodoc='USER_DOC' group by Destinatario_User) as m on Destinatario_User=profiliutente.Idpfu
GO
