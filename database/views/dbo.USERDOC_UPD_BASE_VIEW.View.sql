USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USERDOC_UPD_BASE_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[USERDOC_UPD_BASE_VIEW]
AS
	SELECT 
		--IdAzi
	doc.id ,
	   pfu.idpfu as idpfu
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
	   --,IdAzi as Azienda
	   ,pfu.idpfu as Destinatario_User
	   ,' pfuLogin Fascicolo ' as Note
	   ,pfuResponsabileUtente
	   ,pfuCognome as Cognome
	   ,pfunomeutente as Nome
	   ,case when pfuRuoloAziendale='LEGALE RAPPRESENTANTE' then ' pfuRuoloAziendale codicefiscale ' else ' codicefiscale ' end as NotEditable
	   ,pfuDataCreazione
	   , doc.Protocollo 
	   , doc.ProtocolloGenerale 
	   , DOC.statodoc
	   , doc.StatoFunzionale 
	   , doc.data
	   ,CASE ISNULL(pfudeleted,0)
				when 1 then  'deleted'
				else
				CASE ISNULL(pfustato,'')
					WHEN 'block' THEN 'blocked'
					WHEN  '' THEN 'not-blocked'			
				end 
		END AS StatoUtenti 
	  FROM CTL_DOC doc
		  inner join profiliutente pfu on doc.idpfu = pfu.idpfu
	--	  left outer join (Select max(ID) as PrevDoc,Destinatario_User from CTL_DOC where tipodoc='USER_DOC' group by Destinatario_User) as m on Destinatario_User=profiliutente.Idpfu

GO
