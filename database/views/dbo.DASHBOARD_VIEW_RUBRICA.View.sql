USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RUBRICA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[DASHBOARD_VIEW_RUBRICA] as
select 
	a.*
--	,p.*
    ,p.idpfu
	,pfuCognome
	,pfunomeutente
	,pfuLogin
	,pfuE_Mail
	,pfuE_Mail as EmailComunicazioni
	,pfuTel
	,pfuCell
	,pfuNome 
	
	
	--, dbo.GetRuoliUser( p.idpfu ) as RuoloUtente
	--, dbo.GetProfiliUser( p.idpfu ) as pfuprofili
	--, dbo.GetRuoliUserExcel( p.idpfu ) as RuoloUtenteExcel
	--, dbo.GetProfiliUserExcel( p.idpfu ) as pfuprofiliExcel

	, case when u.idpfu is null then 'No' else 'Si' end as QualificaRapLeg
	, d1.vatValore_FT aS TIPO_AMM_ER	
	, SUBSTRING ( dmv_father ,1 , charindex('-',dmv_father)-1 ) as PrimoLivelloStruttura
    , pfuDataCreazione
	, 
	CASE ISNULL(pfudeleted,0)
			when 1 then  'deleted'
			else
			CASE ISNULL(pfustato,'')
				WHEN 'block' THEN 'blocked'
				WHEN  '' THEN 'not-blocked'			
			end 
	END AS StatoUtenti
	, d2.vatValore_FT as aziCodiceFiscale
	, p.pfuCodiceFiscale
	from 
		aziende a with (nolock) 
		inner join profiliutente p  with (nolock) on idazi=pfuidazi  --and pfudeleted=0
		left outer join DM_Attributi d1  with (nolock) on d1.lnk = idazi and D1.dztnome = 'TIPO_AMM_ER'
		left outer join DM_Attributi d2  with (nolock) on d2.lnk = idazi and D2.dztnome = 'CodiceFiscale'
		left outer join profiliutenteattrib u  with (nolock) on u.idpfu = p.idpfu and u.dztnome = 'Profilo' and attvalue in ( 'RapLegOE' , 'RapLegEnte' ) 
		left outer join LIB_DomainValues  with (nolock) on dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
	where 
		
		aziacquirente=3 and
		azideleted = 0
		and p.idpfu > 0
		and charindex( '@'  , pfuprofili ) = 0 



GO
