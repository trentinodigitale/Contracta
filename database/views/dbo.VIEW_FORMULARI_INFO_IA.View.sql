USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_FORMULARI_INFO_IA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_FORMULARI_INFO_IA] AS
	select 
		idheader,
	    id,
		idpfu,
		Release,
		Descrizione as DescrizioneEstesa,
		0 as idRow,
		ATV_Execute,
		Protocollo,
		DataInvio,
		DataPubblicazione
	from DASHBOARD_VIEW_FORMULARIO_ELENCO V with(NOLOCK)		
	--where OPEN_DOC_NAME='RELEASE_NOTES_IA'


GO
