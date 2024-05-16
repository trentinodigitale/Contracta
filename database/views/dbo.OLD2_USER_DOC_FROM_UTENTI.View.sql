USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_USER_DOC_FROM_UTENTI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_USER_DOC_FROM_UTENTI]
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
	, pfuProfili
	,aziProfili
	, aziVenditore
	, a.attValue as Plant
	, case 
			when dbo.PARAMETRI('ANAG_DOCUMENTAZIONE_DOCUMENT','AreaValutazione','HIDE','',-1)='0' then 1
			when dbo.PARAMETRI('ANAG_DOCUMENTAZIONE_DOCUMENT','AreaValutazione','HIDE','',-1)<>'0' then 0   
			when p1.IdPfu is null then 0 else 1 end as ProfiloAlbo

  FROM AZIENDE with (nolock)
  left join profiliutente with (nolock)  on idazi=pfuidazi
  left outer join (Select max(ID) as PrevDoc,Destinatario_User from CTL_DOC with (nolock) where tipodoc='USERDOC_UPD_BASE' group by Destinatario_User) as m on Destinatario_User=profiliutente.Idpfu
  left join profiliutenteattrib a with(nolock)  on profiliutente.idpfu = a.idpfu and a.dztnome = 'Plant'
  left outer join profiliutenteattrib p1 with (nolock) on p1.idpfu=profiliutente.idpfu  and p1.dztNome = 'Profilo' and p1.attValue in (  'ALBO_VALUTATORE'  )

GO
