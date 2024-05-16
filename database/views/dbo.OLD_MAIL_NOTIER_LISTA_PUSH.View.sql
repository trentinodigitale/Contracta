USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_NOTIER_LISTA_PUSH]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_MAIL_NOTIER_LISTA_PUSH] AS
    SELECT AZI.idAzi as iddoc,
		 'I' as LNG,
		 aziRagioneSociale,
		 CONVERT(VARCHAR(10),getdate(),103) as DataOperazione,
		 CONVERT(VARCHAR(10),getdate(),108) as OrarioOperazione,
		 dbo.notier_conta_documenti_push(idazi, 'ORDINE') as TotOrdini,
		 dbo.notier_conta_documenti_push(idazi, 'DOCUMENTO_DI_TRASPORTO') as TotDDTreso,
		 dbo.notier_conta_documenti_push(idazi, 'NOTIFICA_MDN') as TotNotifiche
	   FROM aziende azi with(nolock)

GO
