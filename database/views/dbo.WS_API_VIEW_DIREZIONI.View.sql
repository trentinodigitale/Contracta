USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WS_API_VIEW_DIREZIONI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[WS_API_VIEW_DIREZIONI] AS
	select idaz as idAzi,
			cast( idaz  as varchar(20)) + '#'  + strut.Path as Codice, 
			isnull(Descrizione,'') as Descrizione 
		from AZ_STRUTTURA strut with(nolock)
		where strut.path > '\0000\0000'
	
GO
