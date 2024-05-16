USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_DRILL_MICROLOTTO_OFFERTA_ROW_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[PDA_DRILL_MICROLOTTO_OFFERTA_ROW_VIEW] as
select 
		o.IdRow	,m.*
	from Document_MicroLotti_Dettagli m with(nolock) 
			inner join Document_PDA_OFFERTE o with(nolock) on m.idheader = o.idRow and m.tipoDoc = 'PDA_OFFERTE' -- o.IdMsgFornitore =  m.idheader
			inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = o.IdMsgFornitore and d.NumeroLotto = m.NumeroLotto and d.TipoDoc = 'OFFERTA' and isnull( d.Voce , 0 ) = 0 
			inner join ctl_doc_value l  with(nolock)  on l.IdHeader = o.IdMsgFornitore and l.DZT_Name = 'LettaBusta' and l.Value = '1' and l.Row = d.id and l.dse_id = 'OFFERTA_BUSTA_ECO'
		where isnull( m.voce , 0 ) = 0 




GO
