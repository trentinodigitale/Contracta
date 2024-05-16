USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_COMUNICAZIONE_DETTAGLI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PDA_COMUNICAZIONE_DETTAGLI_VIEW] as
	select 
		Id,
		LinkedDoc,
		AziRagioneSociale,
		StatoFunzionale,
		DataInvio,
		ID as DETTAGLIGrid_ID_DOC,
		tipodoc as DETTAGLIGrid_OPEN_DOC_NAME
	from 
		CTL_DOC 
			inner join aziende on idazi=Destinatario_azi
	where tipodoc in ( 'PDA_COMUNICAZIONE_GARA' , 'PDA_COMUNICAZIONE_OFFERTA' )   and deleted=0
GO
