USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONFORMITA_LISTA_MICROLOTTI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_CONFORMITA_LISTA_MICROLOTTI_VIEW] as
select 
			 d.id as idDoc			
			, cast( NumeroLotto as int ) as Ordinamento 
--			, m.id as Ordinamento 
			, do.id as iddettaglio
			, case when Exequo = 0 and m.Aggiudicata <> 0
				then aziRagioneSociale 
				when m.Aggiudicata = 0 and  Exequo = 0 then 'Nessuna offerta conforme'
				else 'Exequo' 
				end as aziRagioneSociale
			, m.* 
--			, case when isnull( id_Doc , 0  ) = 0 then 1 else 0 end as bRead
		from Document_MicroLotti_Dettagli m with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = m.idheader and m.tipodoc = 'CONFORMITA_MICROLOTTI'
			left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata
--			left outer join ( select distinct id_Doc from CTL_DOC_READ with(nolock) where DOC_NAME = 'PDA_DRILL_MICROLOTTO' ) as r on id_Doc = m.id
			inner join CTL_DOC do with(nolock) on do.linkeddoc = m.id and do.tipodoc = 'CONFORMITA_MICROLOTTI_OFF'
GO
