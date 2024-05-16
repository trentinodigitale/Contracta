USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_SORTEGGIO_OFFERTA_DETTAGLI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_PDA_SORTEGGIO_OFFERTA_DETTAGLI] as
select 
			 d.id as idDoc			
			, cast( NumeroLotto as int ) as Ordinamento 
			, d.id as iddettaglio
			, a.aziRagioneSociale
			, attr.vatValore_FT as codicefiscale
			, m.* 
			, RC.titolo as Progressivo_risposta
		from Document_MicroLotti_Dettagli m with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = m.idheader and m.tipodoc = 'PDA_SORTEGGIO_OFFERTA'
			--salgo sulla com di raggruppa
			left join ctl_doc COM with (nolock) on Com.id = d.LinkedDoc 
			--salgo sulla pda
			left join ctl_doc PDA with (nolock) on PDA.id = COM.LinkedDoc 
			--sulla risposta sulla pda stato ammessa
			left join document_pda_offerte R with (nolock) on R.IdHeader = PDA.id and R.idAziPartecipante =  m.Aggiudicata and R.StatoPDA = '2'
			--sulla risposta
			left join ctl_doc RC with (nolock) on RC.id = R.IdMsgFornitore
			left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata
			left outer join DM_Attributi attr with(nolock) on attr.lnk = a.idazi and attr.dztNome = 'codicefiscale'

GO
