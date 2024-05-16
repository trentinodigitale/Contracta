USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CAMBIO_RUOLO_UTENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MAIL_CAMBIO_RUOLO_UTENTE] as 
	select  id as iddoc,
			'I' as LNG,
		 	doc.idPfuInCharge as IdPfuMittDoc,
			val1.Value as Nome,	
			val2.Value as Cognome,
			val3.Value as CodiceFiscale,
			val4.Value as Email,
			val5.Value as Telefono,

			case 
				 when ruolo_pi.Value = '1' then 'Punto Istruttore'
				 when ruolo_po.Value = '1' then 'Punto Ordinante'
				 when ruolo_rup.Value = '1' then 'Responsabile Unico del Procedimento'
				 else ''
			end as Ruolo

		from ctl_doc doc
				left join ctl_doc_value val1 ON doc.id = val1.idheader and val1.dse_id = 'UTENTE' and val1.dzt_name = 'Nome'
				left join ctl_doc_value val2 ON doc.id = val2.idheader and val2.dse_id = 'UTENTE' and val2.dzt_name = 'Cognome'
				left join ctl_doc_value val3 ON doc.id = val3.idheader and val3.dse_id = 'UTENTE' and val3.dzt_name = 'codicefiscale'
				left join ctl_doc_value val4 ON doc.id = val4.idheader and val4.dse_id = 'UTENTE' and val4.dzt_name = 'Email'
				left join ctl_doc_value val5 ON doc.id = val5.idheader and val5.dse_id = 'UTENTE' and val5.dzt_name = 'Telefono'

				left join ctl_doc_value ruolo_pi ON doc.id = ruolo_pi.idheader and ruolo_pi.dse_id = 'SCELTA_RUOLO' and ruolo_pi.dzt_name = 'PI'
				left join ctl_doc_value ruolo_po ON doc.id = ruolo_po.idheader and ruolo_po.dse_id = 'SCELTA_RUOLO' and ruolo_po.dzt_name = 'PO'
				left join ctl_doc_value ruolo_rup ON doc.id = ruolo_rup.idheader and ruolo_rup.dse_id = 'SCELTA_RUOLO' and ruolo_rup.dzt_name = 'scelta_RUP'
				

		where doc.TipoDoc = 'CAMBIO_RUOLO_UTENTE'
GO
