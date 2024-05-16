USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_document_cambio_ruolo_utente]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_document_cambio_ruolo_utente] as
	
		select 
		
			idRow, 
			idHeader, 
			dse_id,
			row, 
			dzt_name, 
			case when dse_id = 'SCELTA_RUOLO' and dzt_name in ('PI','PO', 'scelta_RUP','scelta_RUP_PDG') and isnull(value,'') = '' then '0'
				else Value
			end as Value

		from ctl_doc_value with(nolock)
	
	union

		select 
		--se trovo la relazione mette 1 per far vedere la sezione altri dati
			id as idRow, 
			id as idHeader, 
			'SCELTA_RUOLO' as dse_id,
			0 as row,
			'Visualizza_Altri_Dati' dzt_name, 
			case when ISNULL(CR.REL_ValueOutput,'') <> '' then '1' else '0'  end as value
		from ctl_doc C  with(nolock)
				inner join ProfiliUtente P  with(nolock) on C.IdPfu=P.IdPfu 
				left join CTL_Relations CR  with(nolock) on CR.REL_ValueInput=P.pfuIdAzi and CR.REL_Type='AOO_ENTE'
		where TipoDoc='CAMBIO_RUOLO_UTENTE'

	union

		select 	
			C.id as idRow, 
			C.id as idHeader, 
			'SCELTA_RUOLO' as dse_id,
			0 as row,
			'NotEditable' as dzt_name, 
			--PER UTENTI azienda Master puo essere esclusa dal controllo kpf 347050 
			case when ( C2.id is null and M.mpIdAziMaster IS null ) then ' scelta_RUP_PDG '  else ' ' end as value
		from ctl_doc C  with(nolock)
				inner join ProfiliUtente P  with(nolock) on C.IdPfu=P.IdPfu 
				left join marketplace M with(nolock)  on M.mpLog='PA' and m.mpIdAziMaster=P.pfuIdAzi and M.mpDeleted=0
				left join ctl_doc C2  with(nolock) on C2.Azienda=P.pfuIdAzi and C2.TipoDoc='ACCORDO_CREA_GARE' and c2.StatoFunzionale='Inviato'
 		where C.TipoDoc='CAMBIO_RUOLO_UTENTE'
	
	union 
		select 	
			C.id as idRow, 
			C.id as idHeader, 
			'SCELTA_RUOLO' as dse_id,
			0 as row,
			'AziProfili' as dzt_name, 
			aziProfili as value
		from ctl_doc C  with(nolock)
				inner join ProfiliUtente P  with(nolock) on C.IdPfu=P.IdPfu 
				inner  join Aziende  A with(nolock)  on A.IdAzi = P.pfuidazi
		where C.TipoDoc='CAMBIO_RUOLO_UTENTE'

GO
