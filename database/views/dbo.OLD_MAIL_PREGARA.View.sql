USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_PREGARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  view [dbo].[OLD_MAIL_PREGARA] as
select
	'Strategie di Gara' as nomedoc,
	'Gestione Pregara | Documenti da Lavorare' as cartella
	, d.id as iddoc
	, lngSuffisso as LNG	
	, d.TipoDoc
	, d.Protocollo as Protocollo
	, d.Body
	, p.pfuNome
	,LBV.DMV_DescML as RuoloApprovatore
	
	, LBV2.DMV_DescML as StatoFunzionale

from ctl_doc d with(NOLOCK)
	
	inner join CTL_ApprovalSteps cas on d.id=cas.APS_ID_DOC and APS_State='incharge'
	inner join CTL_ApprovalSteps cas2 on d.id=cas2.APS_ID_DOC and cas.APS_APC_Cod_Node+1=cas2.APS_APC_Cod_Node
	left join ProfiliUtente p with(NOLOCK) on p.IdPfu=cas2.APS_IdPfu
	cross join Lingue with(NOLOCK)	
	inner join LIB_DomainValues LBV2 with(NOLOCK) on LBV2.DMV_DM_ID='Statofunzionale' and LBV2.DMV_Cod=d.StatoFunzionale
	inner join LIB_DomainValues LBV with(NOLOCK) on LBV.DMV_DM_ID='UserRole' and LBV.DMV_Cod=cas2.APS_UserProfile
	where d.TipoDoc='PREGARA'	
	
GO
