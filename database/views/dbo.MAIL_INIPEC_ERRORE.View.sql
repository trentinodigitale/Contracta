USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_INIPEC_ERRORE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[MAIL_INIPEC_ERRORE]
AS
SELECT
	a.idRow as iddoc,
	a.msgError, 
	a.idRichiesta, 
	a.outputWS, 
	a.inputWS, 
	a.operazioneRichiesta, 
	a.DataExecuted, 
	a.integrazione, 
	b.TipoDoc,
	'I' as LNG
	FROM
		Services_Integration_Request a with (nolock) 
			INNER JOIN CTL_DOC b with (nolock) ON a.idRichiesta  = b.Id
	WHERE b.tipoDoc = 'INIPEC'

GO
