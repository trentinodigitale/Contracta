USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ANNULLA_ORDINATIVO_EVASI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_DASHBOARD_VIEW_ANNULLA_ORDINATIVO_EVASI] as
select 
	P.Idpfu as Owner
	,ctl_doc.*
	,RDA_DataCreazione
	,RDA_DataScad
	,CIG
	,O.RDA_AZI as AziendaOrdinativo
	,NumeroConvenzione
	,IdAziDest as IdAziDestOrdinativo
	,TipoDoc as OPEN_DOC_NAME
	,id_convenzione as convenzione
from 
	ctl_doc 
		inner join document_odc O on linkeddoc=rda_id
		inner join profiliutente P0 on idPfuInCharge=P0.idpfu
		inner join profiliutente P on P0.pfuidazi=P.pfuidazi
where 
	TipoDoc='ANNULLA_ORDINATIVO' and Statofunzionale in ('Approved','Denied')
	and deleted=0


GO
