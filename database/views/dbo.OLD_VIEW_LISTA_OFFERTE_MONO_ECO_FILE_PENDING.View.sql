USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_LISTA_OFFERTE_MONO_ECO_FILE_PENDING]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_LISTA_OFFERTE_MONO_ECO_FILE_PENDING] AS
	select distinct d.LinkedDoc as idRow, -- id dell'offerta con allegati pending
					p.id as idHeader,	  -- id della pda utilizzato come chiave di ingresso
					o.Protocollo as ProtocolloOfferta
		from document_offerta_allegati a with(nolock) 
				inner join ctl_doc d with(Nolock) on d.id = Idheader and d.tipodoc = 'OFFERTA_ALLEGATI'
				inner join ctl_doc o with(Nolock) on o.id = d.LinkedDoc -- offerta
				inner join ctl_doc p with(nolock) on p.LinkedDoc = o.LinkedDoc and p.TipoDoc = 'PDA_MICROLOTTI' and p.Deleted = 0
		where /* p.id = 330489 and*/ a.SectionName = 'ECONOMICA' and a.statoFirma = 'SIGN_PENDING'
GO
