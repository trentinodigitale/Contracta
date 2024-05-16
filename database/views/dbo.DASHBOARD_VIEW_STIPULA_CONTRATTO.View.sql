USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_STIPULA_CONTRATTO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_STIPULA_CONTRATTO] as
--Versione=2&data=2013-08-29&Attvita=43317&Nominativo=enrico
select 
	Rep , DataStipula , e.* 
from 
	DASHBOARD_VIEW_ESITO_GARA e
	inner join Document_Repertorio on Protocol = ProtocolloBando
	and Document_Repertorio.idAggiudicatrice=e.idAggiudicatrice
	

GO
