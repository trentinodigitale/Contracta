USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PUBBLICITA_LEGALE_ANNULLA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  view [dbo].[MAIL_PUBBLICITA_LEGALE_ANNULLA] as
select
	'RICHIESTA PREVENTIVO' as nomedoc
	, 'Gestione Pubblicità Legale | Documenti in Carico' as cartella
	, r.id as iddoc
	, lngSuffisso as LNG	
	, d.TipoDoc
	, d.Protocollo as Protocollo
	, d.Body
	, p.pfuNome
	, LBV2.DMV_DescML as StatoFunzionale
	, LBV.DMV_DescML as RuoloApprovatore
	
from 
	ctl_doc R with(NOLOCK)

		inner join ctl_doc d with(NOLOCK) on d.id = r.LinkedDoc and d.TipoDoc='PUBBLICITA_LEGALE'	
		cross join Lingue with(NOLOCK)	
		--MI PRENDO IL max per prendere il richiedente 
		inner join ( 
						select max(APS_APC_Cod_Node) as APS_APC_Cod_Node ,APS_ID_DOC 
							from CTL_ApprovalSteps  with(NOLOCK) 
								where APS_Doc_Type='PUBBLICITA_LEGALE' and APS_State='sent'
								  group by APS_ID_DOC 
								
					 ) as CA  on CA.APS_ID_DOC=d.Id
		
		inner join CTL_ApprovalSteps CA1  with(NOLOCK) on CA1.APS_APC_Cod_Node=CA.APS_APC_Cod_Node and CA.APS_ID_DOC=CA1.APS_ID_DOC and CA1.APS_Doc_Type='PUBBLICITA_LEGALE'
		inner join LIB_DomainValues LBV with(NOLOCK) on LBV.DMV_DM_ID='UserRole' and LBV.DMV_Cod=CA1.APS_UserProfile
		inner join LIB_DomainValues LBV2 with(NOLOCK) on LBV2.DMV_DM_ID='Statofunzionale' and LBV2.DMV_Cod=d.StatoFunzionale
		inner join ProfiliUtente P  with(NOLOCK) on P.IdPfu=CA1.APS_IdPfu
				
	where r.tipodoc='PUBBLICITA_LEGALE_ANNULLA'
	



GO
