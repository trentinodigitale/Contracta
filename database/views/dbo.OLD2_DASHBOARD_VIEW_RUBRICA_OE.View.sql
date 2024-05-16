USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_RUBRICA_OE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD2_DASHBOARD_VIEW_RUBRICA_OE] as
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
	,pfuRuoloAziendale
	
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

	, cf.vatValore_FV aS aziCodiceFiscale
	, p.pfuCodiceFiscale as Codicefiscale
	from 
		aziende a with (nolock)
		inner join profiliutente p with (nolock) on idazi=pfuidazi  --and pfudeleted=0
		left outer join DM_Attributi d1  with (nolock) on d1.lnk = idazi and D1.dztnome = 'TIPO_AMM_ER'
		left outer join DM_Attributi cf   with (nolock) on cf.lnk = idazi and cf.dztnome = 'codicefiscale'
		left outer join profiliutenteattrib u  with (nolock) on u.idpfu = p.idpfu and u.dztnome = 'Profilo' and attvalue in ( 'RapLegOE' , 'RapLegEnte' ) 
		left outer join LIB_DomainValues  with (nolock)  on dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
	where 
		
		azivenditore > 0  and
		azideleted = 0 
		--and pfunome <> '-' + pfulogin
		--escludo le aziende che sono RTI create dal sistema a fronte di una offerta
		and a.idazi not in (
			 select distinct value from 
				ctl_doc_value with(nolock) inner join ctl_doc with(nolock) on id=idheader and tipodoc='OFFERTA_PARTECIPANTI' 
				    where dse_id='TESTATA' and dzt_name='IdAziRTI' and isnull(value,'')<>'' and statofunzionale='pubblicato'
			 )
		

		and pfuVenditore=1





GO
