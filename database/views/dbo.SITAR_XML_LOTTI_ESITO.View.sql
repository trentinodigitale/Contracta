USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_XML_LOTTI_ESITO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[SITAR_XML_LOTTI_ESITO] as 


	select [idRow], [idHeader],
			[NumeroLotto], [W3OGGETTO2], [W3CIG], 

			l.FILE_ALLEGATO,
			l.W9LOESIPROC			
		from Document_OCP_LOTTI_AGGIUDICATI L with(nolock)
GO
