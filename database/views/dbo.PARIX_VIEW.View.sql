USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARIX_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[PARIX_VIEW] as 

	select case when isnumeric( sessionid ) = 1 then cast( sessionid as bigint ) else 0 end as idheader , 1 as IdRow , null as row , 'DATI_RAP_LEG' as DSE_ID , 
	case nome_campo  
		when  'RAGSOC' then 'aziRagioneSociale' 
		when 'PFUEMAIL'  then 'EmailRapLeg' 
		when 'NaGi'  then 'titolo' 
		--when 'RuoloRapLeg' then 'pfuRuoloAziendale' 
		else nome_campo 
	end as dzt_name 
	, valore as value  from Parix_Dati where sessionid <> 'LOG_PARIX' and isnumeric( sessionid ) = 1

	union all


	select case when isnumeric( sessionid ) = 1 then cast( sessionid as bigint ) else 0 end as idheader , 1 as IdRow , null as row , 'SCHEDA_OE' as DSE_ID , 
	case nome_campo  
		when  'RAGSOC' then 'aziRagioneSociale' 
		when 'PFUEMAIL'  then 'EmailRapLeg' 
		when 'NaGi'  then 'titolo' 
		--when 'RuoloRapLeg' then 'pfuRuoloAziendale' 
		else nome_campo 
	end as dzt_name 
	, valore as value  from Parix_Dati where sessionid <> 'LOG_PARIX' and isnumeric( sessionid ) = 1
	
GO
