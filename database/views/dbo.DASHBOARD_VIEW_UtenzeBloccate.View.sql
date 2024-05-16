USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_UtenzeBloccate]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_UtenzeBloccate] as

select 
	aziRagioneSociale,
	Idpfu as Id,
	pfuNome,
	pfuLogin, 
	aziLog,
	pfuE_Mail as EMailUtente,
	aziE_Mail as EMAIL,
	case pfuStato
	      when 'block' THEN 0
	      else (DZT_ValueDef-ISNULL(pfuTentativiLogin,0)) 
	END AS NumeroTentativiRes,
	aziPartitaIVA as PartitaIVA,
	CASE ISNULL(pfuStato,'')
			WHEN 'block' THEN 'blocked'
			WHEN  '' THEN 'not-blocked'			
	END AS StatoUtenti,

    CASE ISNULL(pfuStato,'')
			WHEN 'block' THEN 'blocked'	
			WHEN '' THEN 'not-blocked'			
	 END AS StatoBlocco,
	 isnull(vatValore_FT,'') as azicodicefiscale,
	 [aziLocalitaLeg],
	 [aziIndirizzoLeg],
	 [aziCAPLeg],
	 [aziProvinciaLeg],
	 [aziStatoLeg]



from ProfiliUtente
inner join aziende on pfuidazi=idazi
left join DM_Attributi on lnk=idazi and idapp=1 and dztnome='codicefiscale' 
inner join lib_dictionary on dzt_Name='SYS_PWD_TENTATIVI_LOGIN'
where Idpfu > 0

-- select * from dm_attributi where lnk = 35152001 and idapp=1 and dztnome='codicefiscale' 


GO
