USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ESCLUDI_LOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[VIEW_ESCLUDI_LOTTI] as
	select 
		C.*
		, C1.Value as ProtocolloBando
		, OP.StatoPDA
		from ctl_doc C with(nolock)
			left outer join ctl_doc_value C1 with(nolock) on C.id=C1.idheader
			--left outer join ctl_doc O with(nolock) on O.id = C.LinkedDoc and O.TipoDoc = 'OFFERTA' and O.Deleted = 0 
			--left outer join ctl_doc P with(nolock) on P.LinkedDoc = O.LinkedDoc and p.TipoDoc = 'PDA_MICROLOTTI' and P.Deleted = 0 
			--left outer join document_pda_offerte OP with(nolock) on OP.IdHeader = P.Id and OP.IdMsg = O.Id
			left outer join document_pda_offerte OP with(nolock) on OP.IdHeader = c.IdDoc and OP.IdMsg = c.LinkedDoc

		where C.tipodoc='ESCLUDI_LOTTI'

GO
