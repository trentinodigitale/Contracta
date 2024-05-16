USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_PDA_SORTEGGIO_OFFERTA_DETTAGLI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_PDA_SORTEGGIO_OFFERTA_DETTAGLI] as
select 
			 d.id as idDoc			
			, cast( NumeroLotto as int ) as Ordinamento 
			, d.id as iddettaglio
			, aziRagioneSociale
			, attr.vatValore_FT as codicefiscale
			, m.* 
		from Document_MicroLotti_Dettagli m with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = m.idheader and m.tipodoc = 'PDA_SORTEGGIO_OFFERTA'
			left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata
			left outer join DM_Attributi attr with(nolock) on attr.lnk = a.idazi and attr.dztNome = 'codicefiscale'


GO
