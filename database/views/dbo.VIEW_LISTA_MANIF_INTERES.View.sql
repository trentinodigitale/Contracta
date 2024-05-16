USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_LISTA_MANIF_INTERES]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[VIEW_LISTA_MANIF_INTERES] as

	select	  man.* 
			, man.tipodoc as OPEN_DOC_NAME
			, man.LinkedDoc as idHeader
			, man.id as idRow
			, 
				--se sono sulle negoziata avviso come adesso
				--se sono affidamento diretto avvisi 'DaValutare'
			case 
				when dg.ProceduraGara = '15583' and dg.TipoBandoGara in ('4','5') then 
					case when isnull(d.StatoIscrizione,'') = '' then 'DaValutare' else d.StatoIscrizione end 
				else
					case when isnull(d.StatoIscrizione,'') = '' then 'Iscritto' else d.StatoIscrizione end 
			
			end as StatoManifestazioneInteresse

			--, isnull(esclAnn.body,escl.body) as Motivazione
			, case
				when escl.id is not null then escl.body
				when esclAnn.id is not null then esclAnn.body
				when Selez.id is not null then Selez.body
			end as Motivazione

			, isnull(p1.[Value], az.aziRagioneSociale) as aziRagioneSociale
			, dm1.vatValore_FT as codicefiscale
			, az.aziPartitaIVA
			, az.aziLocalitaLeg
			, az.aziE_Mail
			, case when sortPub.Id is null then NULL else d.ordinamento end as ordinamento
			, case when sortPub.Id is null then man.Protocollo else cast( isnull(d.ordinamento + 10000,20000) as varchar) end as ordina
		
		from ctl_doc man with(nolock)
			
				inner join CTL_DOC_Destinatari d with(nolock) on d.idHeader = man.LinkedDoc and man.Azienda = d.IdAzi
				inner join Document_Bando dg with(nolock) on dg.idHeader = man.LinkedDoc
				
				left join ctl_doc escl with(nolock) on escl.iddoc = man.id and escl.tipodoc = 'ESITO_ESCLUSA_MANIFESTAZIONE_INTERESSE' and escl.StatoFunzionale = 'Confermato' and escl.deleted = 0
				
				left join ctl_doc esclAnn with(nolock) on esclAnn.iddoc = man.id and esclAnn.tipodoc = 'ESITO_ANNULLA_MANIFESTAZIONE_INTERESSE' and esclAnn.StatoFunzionale = 'Confermato' and esclAnn.deleted = 0
				
				left join ctl_doc Selez with(nolock) on Selez.iddoc = man.id and Selez.tipodoc = 'ESITO_SELEZIONATO_MANIFESTAZIONE_INTERESSE' and Selez.StatoFunzionale = 'Confermato' and Selez.deleted = 0

				left join CTL_DOC p with(nolock) on p.LinkedDoc = man.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
				left join ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				left join document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id and p2.Ruolo_Impresa = 'Mandataria' and p2.tiporiferimento='RTI'

				inner join aziende az with(nolock) on isnull(p2.IdAzi,man.Azienda) =az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				inner join DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'

				--spostata sopra perchè è più veloce perchè il filtro è per linkeddoc quando viene chiamata
				--inner join CTL_DOC_Destinatari d with(nolock) on d.idHeader = man.LinkedDoc and man.Azienda = d.IdAzi

				left join CTL_DOC sortPub with(nolock) on sortPub.LinkedDoc = man.LinkedDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato'

		where man.deleted = 0 and man.tipodoc in ('MANIFESTAZIONE_INTERESSE') and man.StatoDoc = 'Sended' --and man.LinkedDoc = 85660
		--order by ordina


GO
