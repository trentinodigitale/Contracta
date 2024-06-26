USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONFORMITA_MICROLOTTI_OFF_DETTAGLI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_CONFORMITA_MICROLOTTI_OFF_DETTAGLI] as
select 
			 d.id as idDoc			
			, cast( m.NumeroLotto as int ) as Ordinamento 
			, d.id as iddettaglio
			, a.aziRagioneSociale
			, do.id as idHeaderLottoOfferto , o.IdMsgFornitore 
			, case when isnull( b.Divisione_lotti , '0' ) = '0' then o.IdMsgFornitore  else do.id  end as IdOffertaLotto
			, m.* 
		from Document_MicroLotti_Dettagli m with(nolock) 
			inner join CTL_DOC d with(nolock) on d.id = m.idheader and m.tipodoc = 'CONFORMITA_MICROLOTTI_OFF'
			left outer join aziende a with(nolock) on a.idazi = m.Aggiudicata

			-- risale al documento di conformita per conoscere la PDA
			inner join Document_MicroLotti_Dettagli dc with(nolock) on dc.id = d.LinkedDoc
			inner join CTL_DOC c with(nolock) on c.id = dc.idheader and c.tipodoc = 'CONFORMITA_MICROLOTTI'
			inner join CTL_DOC p with(nolock) on p.id = c.LinkedDoc and p.tipodoc = 'PDA_MICROLOTTI'
			inner join Document_Bando b with(nolock) on b.idHeader = p.LinkedDoc  -- BANDO


			-- recupero l'offerta del fornitore
			inner join Document_PDA_OFFERTE o on o.idheader = c.LinkedDoc and o.idAziPartecipante = m.Aggiudicata and o.StatoPDA in ( '2','22' )
			--left outer join Document_MicroLotti_Dettagli do on o.IdMsgFornitore = do.idheader and do.TipoDoc ='OFFERTA' and do.Voce = 0 and do.NumeroLotto = m.NumeroLotto 
			--inner join Document_MicroLotti_Dettagli do on o.IdMsgFornitore = do.idheader and do.TipoDoc ='OFFERTA' and ( ( do.Voce = 0 and do.NumeroLotto = m.NumeroLotto ) or (b.Divisione_lotti = 0 and do.NumeroRiga=0) )
			left outer join Document_MicroLotti_Dettagli do on o.IdMsgFornitore = do.idheader and do.TipoDoc ='OFFERTA' and ( ( do.Voce = 0 and do.NumeroLotto = m.NumeroLotto ) or (b.Divisione_lotti = 0 and do.NumeroRiga=0) )

			where 

				 ( do.Voce= 0 and do.NumeroLotto = m.NumeroLotto ) or (b.Divisione_lotti = 0 and (do.NumeroRiga=0 or do.id is null ) )

			









GO
