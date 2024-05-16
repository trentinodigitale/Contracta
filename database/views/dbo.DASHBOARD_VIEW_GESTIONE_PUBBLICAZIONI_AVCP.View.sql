USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_GESTIONE_PUBBLICAZIONI_AVCP]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_GESTIONE_PUBBLICAZIONI_AVCP] as
select 
	id,
	idpfu,
	data,
	titolo,
	data as dataa,
	DataInvio ,
	Azienda as Azi_Ente,
	SIGN_ATTACH as allegato,
	note,
	'AVCP_LOG_FLUSSI' as OPEN_DOC_NAME
from CTL_DOC 
where tipodoc='AVCP_LOG_FLUSSI'

GO
