USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_NOTIER_LISTA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_NOTIER_LISTA] AS
    SELECT AZI.idAzi as iddoc,
		 'I' as LNG,
		 aziRagioneSociale,
		 CONVERT(VARCHAR(10),getdate(),103) as DataOperazione,
		 CONVERT(VARCHAR(10),getdate(),108) as OrarioOperazione,
		 dbo.notier_conta_documenti(idazi, 'ORDINE') as TotOrdini,
		 dbo.notier_conta_documenti(idazi, 'DOCUMENTO_DI_TRASPORTO') as TotDDTreso,
		 dbo.notier_conta_documenti(idazi, 'NOTIFICA_MDN') as TotNotifiche
	   FROM aziende azi with(nolock)
			 --INNER JOIN Document_NoTIER_ListaDocumenti_lavoro notier with(nolock) ON notier.idazi = azi.idazi and notier.deleted = 0


GO
