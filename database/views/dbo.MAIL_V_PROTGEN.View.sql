USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_V_PROTGEN]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_V_PROTGEN] AS
	SELECT	id,
			Appl_Sigla,
			Appl_Id_Evento
			descrizione, 
			oggetto,
			flag_annullato,
			id as idDoc, 
			'I' as LNG
		FROM v_protgen WITH(NOLOCK)
		
GO
