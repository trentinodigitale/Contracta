USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_NON_AGGIUDICAZIONE_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_NON_AGGIUDICAZIONE_DOCUMENT_VIEW] AS
	SELECT 
		NA.*,
		CASE
			WHEN ISNULL(tipoScheda,'') <> '' THEN tipoScheda
			WHEN TipoSoglia = 'sotto' OR pcp_TipoScheda = 'P7_1_2' THEN 'NAG'
			WHEN TipoSoglia = 'sopra' THEN 'A1_29'
		END AS pcp_TipoScheda
			FROM CTL_DOC NA WITH(NOLOCK)
			INNER JOIN CTL_DOC PDA WITH(NOLOCK) ON NA.LinkedDoc = PDA.Id
			INNER JOIN CTL_DOC BG WITH(NOLOCK) ON PDA.LinkedDoc = BG.Id
			INNER JOIN Document_Bando B WITH(NOLOCK) ON BG.Id = b.idHeader
			INNER JOIN Document_PCP_Appalto A WITH(NOLOCK) ON BG.Id = a.idHeader
			LEFT JOIN Document_PCP_Appalto_Schede WITH(NOLOCK) ON IdDoc_Scheda = NA.Id 
GO
