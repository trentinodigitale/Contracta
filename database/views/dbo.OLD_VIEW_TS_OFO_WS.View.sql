USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_TS_OFO_WS]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_VIEW_TS_OFO_WS] AS 
	select idazi as id,
			idazi as ID_AZI,
			replace(aziPartitaIVA,'IT','') as CHIAVE			
		from aziende with(nolock)
GO
