USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_PUBBLICITA_LEGALE_NOT_APPROVE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  view [dbo].[OLD_MAIL_PUBBLICITA_LEGALE_NOT_APPROVE] as
select
	'RICHIESTA PREVENTIVO' as nomedoc
	, 'Gestione Pubblicità Legale | Documenti in Carico' as cartella
	, d.id as iddoc
	, lngSuffisso as LNG	
	, d.TipoDoc
	, d.Protocollo as Protocollo
	, d.Body
	, p.pfuNome
	, case when ISNULL(cast(CA1.APS_Note as nvarchar(MAX)),'') <> '' then '<p><b>Motivazione: </b>' + cast(CA1.APS_Note as nvarchar(MAX))  + '</p>' else '' end as APS_Note
	, LBV.DMV_DescML as RuoloApprovatore
	, LBV2.DMV_DescML as StatoFunzionale 
from ctl_doc d with(NOLOCK)
		inner join ctl_doc r with(NOLOCK) on r.id = d.linkeddoc 
		cross join Lingue with(NOLOCK)	
		--MI PRENDO IL MIN DENIED CI POSSONO ESSSERE PIù DENIED NELLA TABLE
		inner join ( 
						select min(APS_APC_Cod_Node) as APS_APC_Cod_Node ,APS_ID_DOC 
							from CTL_ApprovalSteps  with(NOLOCK) 
								where APS_Doc_Type='PUBBLICITA_LEGALE' and APS_State='Denied' group by APS_ID_DOC 
					 ) as CA  on CA.APS_ID_DOC=r.Id
		
		inner join CTL_ApprovalSteps CA1  with(NOLOCK) on CA1.APS_APC_Cod_Node=CA.APS_APC_Cod_Node and CA.APS_ID_DOC=CA1.APS_ID_DOC and CA1.APS_Doc_Type='PUBBLICITA_LEGALE'
		inner join LIB_DomainValues LBV with(NOLOCK) on LBV.DMV_DM_ID='UserRole' and LBV.DMV_Cod=CA1.APS_UserProfile
		inner join LIB_DomainValues LBV2 with(NOLOCK) on LBV2.DMV_DM_ID='Statofunzionale' and LBV2.DMV_Cod=r.StatoFunzionale
		inner join ProfiliUtente P  with(NOLOCK) on P.IdPfu=CA1.APS_IdPfu
				
	where d.TipoDoc='PUBBLICITA_LEGALE_RIFIUTA'	
	
GO
