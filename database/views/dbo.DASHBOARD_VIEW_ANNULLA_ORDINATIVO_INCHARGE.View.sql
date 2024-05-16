USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ANNULLA_ORDINATIVO_INCHARGE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_ANNULLA_ORDINATIVO_INCHARGE] as 
select 
	
	ctl_doc.*
	,RDA_DataCreazione
	,RDA_DataScad
	,CIG
	,O.RDA_AZI as AziendaOrdinativo
	,NumeroConvenzione
	,IdAziDest as IdAziDestOrdinativo
	,TipoDoc as OPEN_DOC_NAME
	,id_convenzione as convenzione
from 
	ctl_doc  with(nolock) 
		inner join document_odc O  with(nolock) on linkeddoc=rda_id
			
where 
	TipoDoc='ANNULLA_ORDINATIVO'
	and deleted=0



GO
