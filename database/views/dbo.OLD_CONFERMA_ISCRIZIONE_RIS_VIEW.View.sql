USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CONFERMA_ISCRIZIONE_RIS_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD_CONFERMA_ISCRIZIONE_RIS_VIEW] as 
select d.*
	,i.Azienda as LegalPub
	,i.Protocollo as ProtocolloOfferta
from CTL_DOC  d
	inner join CTL_DOC r on d.LinkedDoc = r.id -- richiesta di integrazione
	inner join CTL_DOC i on r.LinkedDoc = i.id -- istanza
GO
