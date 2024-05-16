USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ANNULLA_ORDINATIVO]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_DASHBOARD_VIEW_ANNULLA_ORDINATIVO] as
select 
	--P.Idpfu as Owner
	Idpfu as Owner
	,ctl_doc.*
	,RDA_DataCreazione
	,RDA_DataScad
	,CIG
	,O.RDA_AZI as AziendaOrdinativo
	,NumeroConvenzione
	,IdAziDest as IdAziDestOrdinativo
	,TipoDoc as OPEN_DOC_NAME
	,id_convenzione as convenzione
	,ctl_doc.Destinatario_Azi as AZI_Dest
from 
	ctl_doc  with(nolock) 
		inner join document_odc O  with(nolock) on linkeddoc=rda_id
			--inner join profiliutente P with(nolock)  on azienda=pfuidazi
where 
	TipoDoc='ANNULLA_ORDINATIVO'
	and deleted=0




GO
