USE [AFLink_TND]
GO
/****** Object:  View [dbo].[NUOVO_RILANCIO_COMPETITIVO_LOTTI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[NUOVO_RILANCIO_COMPETITIVO_LOTTI_VIEW] as 


	select		
			d.id 
			, d.IdHeader 
			, d.TipoDoc 
			, 
				case 
					when pl.StatoRiga = 'AggiudicazioneDef'  then d.StatoRiga
					else null
				end as	StatoRiga
			 
			, d.NumeroLotto
			, pl.Descrizione
			, pl.CIG
			, d.NoteLotto
			, d.EsitoRiga 
			, dbo.GetIdoneiLottoAQ( p.id , d.NumeroLotto  ) as aziRagioneSociale 
			, 
				case 
					when pl.StatoRiga = 'AggiudicazioneDef' then ''
					else ' StatoRiga '
				end as NotEditable

		from Document_MicroLotti_Dettagli d
			inner join CTL_DOC n with(nolock) on n.id = d.IdHeader
			inner join CTL_DOC b with(nolock) on b.id = n.LinkedDoc
			inner join CTL_DOC p with(nolock) on b.id = p.LinkedDoc and p.TipoDoc = 'PDA_MICROLOTTI' and p.deleted = 0 
			inner join Document_MicroLotti_Dettagli pl with(nolock) on pl.IdHeader = p.Id and pl.TipoDoc = 'PDA_MICROLOTTI' and pl.NumeroLotto = d.NumeroLotto and pl.Voce = 0
	where d.tipodoc = 'NUOVO_RILANCIO_COMPETITIVO'

GO
