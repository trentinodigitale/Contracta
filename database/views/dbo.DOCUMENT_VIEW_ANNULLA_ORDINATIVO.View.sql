USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_VIEW_ANNULLA_ORDINATIVO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DOCUMENT_VIEW_ANNULLA_ORDINATIVO] as
select 
	ctl_doc.*
	,RDA_DataCreazione
	,RDA_DataScad
	,CIG
	,O.RDA_AZI as AziendaOrdinativo
	,NumeroConvenzione
	,IdAziDest as IdAziDestOrdinativo
	--,TipoDoc as OPEN_DOC_NAME
	,value as Allegato
	,IdHeader
	,DSE_ID
	,idRow
	, case statofunzionale 
		when 'InLavorazione' then ''
		else ' Titolo  Note  Allegato  '
	 end as Not_Editable
from 
	ctl_doc 
		inner join document_odc O on linkeddoc=rda_id
		left join ctl_doc_value on id=idheader
where 
	TipoDoc='ANNULLA_ORDINATIVO'
GO
