USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_WS_API_VIEW_AZI_WINNERS]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_WS_API_VIEW_AZI_WINNERS] AS
	select * 
		from WS_API_VIEW_PARTECIPANT_LIST
		where Aggiudicatario = 'S'
GO
