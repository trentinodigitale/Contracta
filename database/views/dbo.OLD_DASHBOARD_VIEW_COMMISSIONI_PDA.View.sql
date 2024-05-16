USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_COMMISSIONI_PDA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_COMMISSIONI_PDA]
as 

select 
	
	CG1.idheader
	,CG1.row
	,CG1.IdRow
	,CG1.dse_id 
	,CG1.value as NominativoCommissioneAggiudicatrice
	,CG1.value as NominativoCommissioneGiudicatrice
	,CG2.value as RuoloCommissione
	,CG3.value as CodiceFiscale
	,CG4.value as Cognome
	,CG5.value as Nome
	,CG6.value as RagioneSociale
	,CG7.value as RuoloUtente
	, case 
		when isnull(P1.idpfu,0)=0 then CG5.value + ' ' + CG4.value
		else P1.pfunome
		end as NominativoCommissione

	from ctl_doc P
		inner join ctl_doc_value CG1 on P.id=CG1.idheader and CG1.dse_id='COMMISSIONE_GARA_D' and CG1.dzt_name='NominativoCommissioneAggiudicatrice' 
		inner join ctl_doc_value CG2 on P.id=CG2.idheader and CG2.dse_id='COMMISSIONE_GARA_D' and CG2.dzt_name='RuoloCommissione' and CG2.row=CG1.row
		left join ctl_doc_value CG3 on P.id=CG3.idheader and CG3.dse_id='COMMISSIONE_GARA_D' and CG3.dzt_name='CodiceFiscale' and CG3.row=CG2.row
		left join ctl_doc_value CG4 on P.id=CG4.idheader and CG4.dse_id='COMMISSIONE_GARA_D' and CG4.dzt_name='Cognome' and CG4.row=CG3.row
		left join ctl_doc_value CG5 on P.id=CG5.idheader and CG5.dse_id='COMMISSIONE_GARA_D' and CG5.dzt_name='Nome' and CG5.row=CG4.row
		left join ctl_doc_value CG6 on P.id=CG6.idheader and CG6.dse_id='COMMISSIONE_GARA_D' and CG6.dzt_name='RagioneSociale' and CG6.row=CG5.row
		left join ctl_doc_value CG7 on P.id=CG7.idheader and CG7.dse_id='COMMISSIONE_GARA_D' and CG7.dzt_name='RuoloUtente' and CG7.row=CG6.row
		
		left join profiliutente P1 on P1.idpfu=cast(CG1.value as int)
	where P.TipoDoc='PDA_MICROLOTTI'

union 	

select 
	
	CG1.idheader
	,CG1.row
	,CG1.IdRow
	,CG1.dse_id 
	,CG1.value as NominativoCommissioneAggiudicatrice
	,CG1.value as NominativoCommissioneGiudicatrice
	,CG2.value as RuoloCommissione
	,CG3.value as CodiceFiscale
	,CG4.value as Cognome
	,CG5.value as Nome
	,CG6.value as RagioneSociale
	,CG7.value as RuoloUtente
	, case 
		when isnull(P1.idpfu,0)=0 then CG5.value + ' ' + CG4.value
		else P1.pfunome
		end as NominativoCommissione

	from ctl_doc P
		inner join ctl_doc_value CG1 on P.id=CG1.idheader and CG1.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG1.dzt_name='NominativoCommissioneGiudicatrice' 
		inner join ctl_doc_value CG2 on P.id=CG2.idheader and CG2.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG2.dzt_name='RuoloCommissione' and CG2.row=CG1.row
		left join ctl_doc_value CG3 on P.id=CG3.idheader and CG3.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG3.dzt_name='CodiceFiscale' and CG3.row=CG2.row
		left join ctl_doc_value CG4 on P.id=CG4.idheader and CG4.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG4.dzt_name='Cognome' and CG4.row=CG3.row
		left join ctl_doc_value CG5 on P.id=CG5.idheader and CG5.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG5.dzt_name='Nome' and CG5.row=CG4.row
		left join ctl_doc_value CG6 on P.id=CG6.idheader and CG6.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG6.dzt_name='RagioneSociale' and CG6.row=CG5.row
		left join ctl_doc_value CG7 on P.id=CG7.idheader and CG7.dse_id='COMMISSIONE_GIUDICATRICE_D' and CG7.dzt_name='RuoloUtente' and CG7.row=CG6.row
		left join profiliutente P1 on P1.idpfu=cast(CG1.value as int)

	where P.TipoDoc='PDA_MICROLOTTI'
	--and P.id=73435

union 
select 
	
	CG1.idheader
	,CG1.row
	,CG1.IdRow
	,CG1.dse_id 
	,CG1.value as NominativoCommissioneAggiudicatrice
	,CG1.value as NominativoCommissioneGiudicatrice
	,CG2.value as RuoloCommissione
	,CG3.value as CodiceFiscale
	,CG4.value as Cognome
	,CG5.value as Nome
	,CG6.value as RagioneSociale
	,CG7.value as RuoloUtente
	, case 
		when isnull(P1.idpfu,0)=0 then CG5.value + ' ' + CG4.value
		else P1.pfunome
		end as NominativoCommissione

	from ctl_doc P
		inner join ctl_doc_value CG1 on P.id=CG1.idheader and CG1.dse_id='COMMISSIONE_ECONOMICA_C' and CG1.dzt_name='NominativoCommissioneGiudicatrice' 
		inner join ctl_doc_value CG2 on P.id=CG2.idheader and CG2.dse_id='COMMISSIONE_ECONOMICA_C' and CG2.dzt_name='RuoloCommissione' and CG2.row=CG1.row
		left join ctl_doc_value CG3 on P.id=CG3.idheader and CG3.dse_id='COMMISSIONE_ECONOMICA_C' and CG3.dzt_name='CodiceFiscale' and CG3.row=CG2.row
		left join ctl_doc_value CG4 on P.id=CG4.idheader and CG4.dse_id='COMMISSIONE_ECONOMICA_C' and CG4.dzt_name='Cognome' and CG4.row=CG3.row
		left join ctl_doc_value CG5 on P.id=CG5.idheader and CG5.dse_id='COMMISSIONE_ECONOMICA_C' and CG5.dzt_name='Nome' and CG5.row=CG4.row
		left join ctl_doc_value CG6 on P.id=CG6.idheader and CG6.dse_id='COMMISSIONE_ECONOMICA_C' and CG6.dzt_name='RagioneSociale' and CG6.row=CG5.row
		left join ctl_doc_value CG7 on P.id=CG7.idheader and CG7.dse_id='COMMISSIONE_ECONOMICA_C' and CG7.dzt_name='RuoloUtente' and CG7.row=CG6.row
		
		left join profiliutente P1 on P1.idpfu=cast(CG1.value as int)
	where P.TipoDoc='PDA_MICROLOTTI'




GO
