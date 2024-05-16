USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ESTRAZIONE_LISTINI_CONVENZIONI_DETTAGLI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







create VIEW [dbo].[VIEW_ESTRAZIONE_LISTINI_CONVENZIONI_DETTAGLI] as

	select 
		DE.*
		, DE.Tipodoc as OPEN_DOC_NAME
		--, path
		--, DF.Tipodoc as TipoDocBando
		from
			Document_Estrazione_ListiniConvenzioni DE with (nolock)
			
GO
