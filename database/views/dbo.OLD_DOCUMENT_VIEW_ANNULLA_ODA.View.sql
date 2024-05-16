USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DOCUMENT_VIEW_ANNULLA_ODA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select * from DOCUMENT_VIEW_ANNULLA_ODA where 
CREATE view [dbo].[OLD_DOCUMENT_VIEW_ANNULLA_ODA] as
select 
	a.*
	,ord.datainvio as RDA_DataCreazione
	--,RDA_DataScad
	,CIG
	,ord.azienda as AziendaOrdinativo
	--,NumeroConvenzione
	,ord.Destinatario_Azi as IdAziDestOrdinativo
	--,TipoDoc as OPEN_DOC_NAME
	,value as Allegato
	,a.id as idHeader
	,DSE_ID
	,isnull( v.idRow , 0 ) as idRow
	--,a.Note As Motivazioni
	, case a.statofunzionale 
		when 'InLavorazione' then ''
		else ' Titolo  Note  Allegato  '
	 end as Not_Editable
from 
	ctl_doc a
		inner join ctl_doc  Ord on a.linkeddoc=ord.id 
		inner join document_oda O on a.linkeddoc=o.idheader 

		left join ctl_doc_value v on a.id=v.idheader
--where 
--	TipoDoc='ANNULLA_ODA'
GO
