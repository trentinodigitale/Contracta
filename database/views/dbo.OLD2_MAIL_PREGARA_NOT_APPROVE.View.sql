USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_PREGARA_NOT_APPROVE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[OLD2_MAIL_PREGARA_NOT_APPROVE] as
select
	'Strategie di Gara' as nomedoc,

	'Gestione Pregara | Documenti in Carico' as cartella
	,  d.id as iddoc
	, lngSuffisso as LNG	
	, d.TipoDoc
	, d.Protocollo as Protocollo
	, d.Body
	, p.pfuNome
	, case when ISNULL(cast(CA1.APS_Note as nvarchar(MAX)),'') <> '' then '<p><b>Motivazione: </b>' + cast(CA1.APS_Note as nvarchar(MAX))  + '</p>' else '' end as APS_Note
	, LBV.DMV_DescML as RuoloApprovatore

from ctl_doc d with(NOLOCK)
		cross join Lingue with(NOLOCK)	
		--MI PRENDO IL MIN DENIED CI POSSONO ESSSERE PIù DENIED NELLA TABLE
		inner join ( 
						select min(APS_APC_Cod_Node) as APS_APC_Cod_Node ,APS_ID_DOC 
							from CTL_ApprovalSteps  with(NOLOCK) 
								where APS_Doc_Type='PREGARA' and APS_State='Denied' group by APS_ID_DOC 
					 ) as CA  on CA.APS_ID_DOC=d.Id
		
		inner join CTL_ApprovalSteps CA1  with(NOLOCK) on CA1.APS_APC_Cod_Node=CA.APS_APC_Cod_Node and CA.APS_ID_DOC=CA1.APS_ID_DOC and CA1.APS_Doc_Type='PREGARA'
		inner join LIB_DomainValues LBV with(NOLOCK) on LBV.DMV_DM_ID='UserRole' and LBV.DMV_Cod=CA1.APS_UserProfile
		inner join ProfiliUtente P  with(NOLOCK) on P.IdPfu=CA1.APS_IdPfu
				
	where d.TipoDoc='PREGARA'	
	
GO
