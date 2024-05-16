USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PUBBLICITA_LEGALE_APPROVE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[MAIL_PUBBLICITA_LEGALE_APPROVE] as
select
	'RICHIESTA PREVENTIVO' as nomedoc
	,  d.id as iddoc
	, lngSuffisso as LNG	
	, d.TipoDoc
	, d.Protocollo as Protocollo
	, d.Body
	, p.pfuNome
	, CA1.APS_Note
	, LBV.DMV_DescML as RuoloApprovatore
	, LBV2.DMV_DescML as StatoFunzionale

from ctl_doc d with(NOLOCK)
		cross join Lingue with(NOLOCK)	
		--MI PRENDO IL MIN Approved CI POSSONO ESSSERE PIù Approved NELLA TABLE
		inner join ( 
						select min(APS_APC_Cod_Node) as APS_APC_Cod_Node ,APS_ID_DOC 
							from CTL_ApprovalSteps  with(NOLOCK) 
								where APS_Doc_Type='PUBBLICITA_LEGALE' and APS_State='sent' group by APS_ID_DOC 
					 ) as CA  on CA.APS_ID_DOC=d.Id
		
		inner join CTL_ApprovalSteps CA1  with(NOLOCK) on CA1.APS_APC_Cod_Node=CA.APS_APC_Cod_Node and CA.APS_ID_DOC=CA1.APS_ID_DOC and CA1.APS_Doc_Type='PUBBLICITA_LEGALE'
		inner join LIB_DomainValues LBV with(NOLOCK) on LBV.DMV_DM_ID='UserRole' and LBV.DMV_Cod=CA1.APS_UserProfile
		inner join ProfiliUtente P  with(NOLOCK) on P.IdPfu=CA1.APS_IdPfu
		inner join LIB_DomainValues LBV2 with(NOLOCK) on LBV2.DMV_DM_ID='Statofunzionale' and LBV2.DMV_Cod=d.StatoFunzionale
				
	where d.TipoDoc='PUBBLICITA_LEGALE'	
	
GO
