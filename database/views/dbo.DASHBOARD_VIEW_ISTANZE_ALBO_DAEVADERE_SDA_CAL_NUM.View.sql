USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL_NUM]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL_NUM] as
select 
	idPfu , 
	idPfu as id, 
	tipoDoc , 
	DataRiferimento2 as DataRiferimento ,
	count(*) as Num ,
	1 as bRead ,
	case 
		when tipoDoc  = 'CONFERMA_ISCRIZIONE_SDA' then 'Confermati'
		when left ( tipoDoc , 11 ) = 'ISTANZA_SDA'  then 'Non Valutati'		
		when tipoDoc  = 'INTEGRA_ISCRIZIONE_SDA' then 'Richiesta Integrazione'
		when tipoDoc  = 'SCARTO_ISCRIZIONE_SDA' then 'Scartati'
	end as Descrizione,
	max(titolosda) as titolosda
	,ProtocolloRiferimento
from DASHBOARD_VIEW_ISTANZE_ALBO_DAEVADERE_SDA_CAL
group by  DataRiferimento2  , tipoDoc , idPfu,ProtocolloRiferimento




GO
