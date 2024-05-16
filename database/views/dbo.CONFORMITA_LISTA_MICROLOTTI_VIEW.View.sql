USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFORMITA_LISTA_MICROLOTTI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[CONFORMITA_LISTA_MICROLOTTI_VIEW] as
select 
			 d.id as idDoc			
			, cast( m.NumeroLotto as int ) as Ordinamento 
--			, m.id as Ordinamento 
			, do.id as iddettaglio
			, case 
				--when m.Exequo = 0 and m.Aggiudicata <> 0 then aziRagioneSociale 
				when m.Exequo = 0 and m.Aggiudicata <> 0 and isnull( CVL.TipoAggiudicazione , b.TipoAggiudicazione ) in (  'monofornitore' , '' )  then aziRagioneSociale 
				when m.Exequo = 0 and m.Aggiudicata <> 0 and isnull( CVL.TipoAggiudicazione , b.TipoAggiudicazione ) not in (  'monofornitore' , '' )  then 'Aggiudicatari multipli'
				when m.Aggiudicata = 0 and  m.Exequo = 0 then 'Nessuna offerta conforme'
				else 'Exequo' 
			  end as aziRagioneSociale
			, m.* 
--			, case when isnull( id_Doc , 0  ) = 0 then 1 else 0 end as bRead
		from Document_MicroLotti_Dettagli m with(nolock) 

			inner join CTL_DOC d with(nolock) on d.id = m.idheader and m.tipodoc = 'CONFORMITA_MICROLOTTI'

			left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata

--			left outer join ( select distinct id_Doc from CTL_DOC_READ with(nolock) where DOC_NAME = 'PDA_DRILL_MICROLOTTO' ) as r on id_Doc = m.id
			inner join CTL_DOC do with(nolock) on do.linkeddoc = m.id and do.tipodoc = 'CONFORMITA_MICROLOTTI_OFF'

			--salgo sulla PDA
			inner join ctl_doc PDA with(nolock) on PDA.id = d.LinkedDoc
			
			--salgo sulla GARA
			inner join document_bando b with(nolock) on b.idheader = PDA.Linkeddoc
			inner join ctl_doc gara with(nolock) on gara.id = PDA.LinkedDoc

			inner join document_microlotti_dettagli DB with (nolock) on DB.idheader =	gara.id and db.tipodoc=gara.tipodoc and db.voce=0 and isnull(db.numerolotto,1)= m.NumeroLotto

			--per recuperare TipoAggiudicazione del lotto
			left outer join  View_Criteri_Valutazione_Lotto CVL with (nolock) on  CVL.idheader = DB.id
GO
