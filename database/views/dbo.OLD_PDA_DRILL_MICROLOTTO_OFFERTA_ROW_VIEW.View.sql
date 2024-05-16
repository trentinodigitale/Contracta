USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_DRILL_MICROLOTTO_OFFERTA_ROW_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_PDA_DRILL_MICROLOTTO_OFFERTA_ROW_VIEW] as
select 
		IdRow
		,m.*
	from Document_MicroLotti_Dettagli m with(nolock) 
			inner join Document_PDA_OFFERTE o with(nolock) on m.idheader = o.idRow and m.tipoDoc = 'PDA_OFFERTE' -- o.IdMsgFornitore =  m.idheader
GO
