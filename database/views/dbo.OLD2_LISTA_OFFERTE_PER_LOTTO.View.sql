USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_LISTA_OFFERTE_PER_LOTTO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_LISTA_OFFERTE_PER_LOTTO] as

	SELECT o.* 
			, o.tipodoc as OPEN_DOC_NAME
			, o.LinkedDoc as idHeader
			, isnull(p1.[Value], az.aziRagioneSociale) as aziRagioneSociale
			, dm1.vatValore_FT as codicefiscale
			, az.aziPartitaIVA
			, az.aziLocalitaLeg
			, az.aziE_Mail

			, d.NumeroLotto
			, d.Descrizione
		FROM ctl_doc o with(nolock)

				INNER JOIN Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = o.id and d.TipoDoc = 'OFFERTA' and d.Voce = 0

				LEFT JOIN CTL_DOC p with(nolock) on p.LinkedDoc = o.id and p.TipoDoc = 'OFFERTA_PARTECIPANTI' and p.StatoFunzionale = 'Pubblicato' and p.deleted = 0
--				LEFT JOIN ctl_doc_value p1 with(nolock) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''
				LEFT JOIN ctl_doc_value p1 with(nolock,index( [ICX_CTL_DOC_VALUE_IdHeader_DSE_id_DZT_name])) on p1.idheader = p.id and p1.DSE_ID = 'TESTATA_RTI' and p1.DZT_Name = 'DenominazioneATI' and isnull(p1.value,'') <> ''

				LEFT JOIN document_offerta_partecipanti p2 with(nolock) ON p2.idheader = p.id and p2.Ruolo_Impresa = 'Mandataria' and p2.tiporiferimento='RTI'

				INNER JOIN aziende az with(nolock) on isnull(p2.IdAzi,o.Azienda) = az.IdAzi --Mandataria o azienda partecipante se non è in RTI
				INNER JOIN DM_Attributi dm1 with(nolock) ON dm1.lnk = az.idazi and dm1.dztNome = 'codicefiscale'

		WHERE o.tipodoc in ('OFFERTA','OFFERTA_ASTA') and o.deleted = 0 and o.StatoFunzionale = 'Inviato' --and o.LinkedDoc=83835 and d.NumeroLotto = 1


GO
