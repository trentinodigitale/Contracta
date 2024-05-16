USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFERMA_ISCRIZIONE_RIS_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[CONFERMA_ISCRIZIONE_RIS_VIEW] as 
select d.*
	,i.Azienda as LegalPub
	,i.Protocollo as ProtocolloOfferta
	,bando.protocollo as ProtocolloCapostipite
	,i.StatoFunzionale as  StatoFunzionaleIstanza
from CTL_DOC  d
	inner join CTL_DOC r on d.LinkedDoc = r.id -- richiesta di integrazione
	inner join CTL_DOC i on r.LinkedDoc = i.id -- istanza
	left join CTL_DOC_VIEW bando ON bando.id = i.LinkedDoc  -- bando sda


GO
