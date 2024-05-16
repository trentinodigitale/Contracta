USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RETTIFICA_CONVENZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_RETTIFICA_CONVENZIONE] as
	select rett.id as iddoc
			,'I' as LNG

			, rett.Note
			, rett.Protocollo

			, conv.Titolo as TitoloConvenzione
			, conv.Protocollo as ProtocolloConvenzione
			, dt.DescrizioneEstesa as BodyConvenzione

		from CTL_DOC rett with(nolock)
				inner join CTL_DOC conv with(nolock) ON conv.id = rett.LinkedDoc
				inner join document_convenzione dt with(nolock) on dt.id = conv.id
		where rett.tipodoc in ('RETTIFICA_CONVENZIONE')

GO
