USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_FASCICOLO_GARA_DETTAGLI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create VIEW [dbo].[OLD_VIEW_FASCICOLO_GARA_DETTAGLI] as

	select 
		*
		, Tipodoc as OPEN_DOC_NAME
		from
			Document_Fascicolo_Gara_Documenti
GO
