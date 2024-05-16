USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_TS_AZI_FINALIZZA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_TS_AZI_FINALIZZA] AS

	select a.idRow as iddoc
			, 'I' as LNG	
			, gara.Protocollo as protocolloGara
			, gara.Body as oggettoGara
			, a.statoRichiesta as esitoInvio
			, a.msgError as msgError
	from Services_Integration_Request a with(nolock)
			inner join Services_Integration_Request b with(nolock) on b.idRow = a.idRichiesta
			inner join CTL_DOC offe with(nolock) on offe.id = b.idRichiesta
			inner join CTL_DOC gara with(nolock) on gara.id = offe.LinkedDoc
	where a.operazioneRichiesta = 'checkStatus'

	UNION ALL

	select b.idRow as iddoc
			, 'I' as LNG	
			, gara.Protocollo as protocolloGara
			, gara.Body as oggettoGara
			, b.statoRichiesta as esitoInvio
			, b.msgError as msgError
	from Services_Integration_Request b with(nolock)
			inner join CTL_DOC offe with(nolock) on offe.id = b.idRichiesta
			inner join CTL_DOC gara with(nolock) on gara.id = offe.LinkedDoc
	where b.operazioneRichiesta = 'sendRDA'

	
	
GO
