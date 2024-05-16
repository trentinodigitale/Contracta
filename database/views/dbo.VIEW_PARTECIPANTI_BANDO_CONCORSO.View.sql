USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PARTECIPANTI_BANDO_CONCORSO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[VIEW_PARTECIPANTI_BANDO_CONCORSO] as

	SELECT 
			o.Id,
			o.LinkedDoc as IdHeader
			,o.Tipodoc
			, az.aziRagioneSociale as aziRagioneSociale
			, dm1.vatValore_FT as codicefiscale
			, az.aziPartitaIVA
			, az.aziLocalitaLeg
			, az.aziE_Mail

			--, case when p2.Ruolo_Impresa = 'Mandataria' then 'M' else 'T' end as flg_ruolo -- T STA PER MANDANTE, M PER MANDATARIA
			
			,p2.Ruolo_Impresa

			,case
				when p2.TipoRiferimento='RTI' then p2.Ruolo_Impresa 
				when p2.TipoRiferimento='AUSILIARIE' then + 'Ausiliara'
				when p2.TipoRiferimento='ESECUTRICI' then  + 'Esecutrice'
				else ''	
					
			end as Ruolo_Impresa_Esteso
			,p2.idrow
			,o.Protocollo
			

		FROM 
				ctl_doc o with(nolock)

				LEFT JOIN CTL_DOC p with(nolock) on p.LinkedDoc = o.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
				LEFT JOIN ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				LEFT JOIN document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id /*and p2.Ruolo_Impresa = 'Mandataria'*/ --and p2.tiporiferimento='RTI'


				LEFT JOIN aziende az with(nolock) on isnull(p2.IdAzi,o.Azienda) = az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				LEFT JOIN DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'

				-- risale sul bando concorso
				inner join ctl_doc bando with(nolock) on bando.id = o.LinkedDoc and bando.Deleted = 0 and bando.TipoDoc = 'BANDO_CONCORSO'

				

		WHERE o.tipodoc in ('RISPOSTA_CONCORSO') and o.deleted = 0 and o.StatoFunzionale = 'Inviato' 

		--and o.LinkedDoc = 472586






GO
