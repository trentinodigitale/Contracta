USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFORMITA_MICROLOTTI_OFF_TESTATA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[CONFORMITA_MICROLOTTI_OFF_TESTATA] as

	select 
			 d.*
			, b.Divisione_lotti 
		from CTL_DOC d with(nolock) 

			-- risale al documento di conformita per conoscere la PDA
			inner join Document_MicroLotti_Dettagli dc with(nolock) on dc.id = d.LinkedDoc
			inner join CTL_DOC c with(nolock) on c.id = dc.idheader and c.tipodoc = 'CONFORMITA_MICROLOTTI'
			inner join CTL_DOC p with(nolock) on p.id = c.LinkedDoc and p.tipodoc = 'PDA_MICROLOTTI'
			inner join Document_Bando b with(nolock) on b.idHeader = p.LinkedDoc  -- BANDO
GO
