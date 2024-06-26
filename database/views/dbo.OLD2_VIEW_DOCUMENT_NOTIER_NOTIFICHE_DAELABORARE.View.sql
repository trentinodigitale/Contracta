USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_DOCUMENT_NOTIER_NOTIFICHE_DAELABORARE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_VIEW_DOCUMENT_NOTIER_NOTIFICHE_DAELABORARE] AS
	SELECT id, numRetry
		FROM Document_NoTIER_ListaDocumenti WITH(NOLOCK) 
				left join CTL_Relations with(nolock) on REL_Type = 'NOTIER_TIPI_DOC_NOTIFICHE_IMR' and REL_ValueInput = CHIAVE_TIPODOCUMENTO
		WHERE deleted = 0 
				and ( CHIAVE_TIPODOCUMENTO = 'NOTIFICA_MDN' OR REL_idRow IS NOT NULL )
				and xmlDett is null 
				and ( numRetry is null OR numRetry < 10 )
GO
