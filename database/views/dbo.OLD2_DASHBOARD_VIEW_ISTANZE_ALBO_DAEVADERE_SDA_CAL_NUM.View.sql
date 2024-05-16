USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL_NUM]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL_NUM] as
select 
	idPfu , 
	idPfu as id, 
	tipoDoc , 
	DataRiferimento2 as DataRiferimento ,
	count(*) as Num ,
	1 as bRead ,
	case tipoDoc 
		when 'CONFERMA_ISCRIZIONE_SDA' then 'Confermati'
		when 'ISTANZA_SDA_FARMACI' then 'Non Valutati'
		when 'ISTANZA_SDA_2' then 'Non Valutati'
		when 'INTEGRA_ISCRIZIONE_SDA' then 'Richiesta Integrazione'
		when 'SCARTO_ISCRIZIONE_SDA' then 'Scartati'
	end as Descrizione,
	max(titolosda) as titolosda
	,ProtocolloRiferimento
from DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL
group by  DataRiferimento2  , tipoDoc , idPfu,ProtocolloRiferimento




GO
