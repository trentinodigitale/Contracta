USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VERBALETEMPLATE_DETTAGLI_FROM_VERBALETEMPLATE ]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--nuova vista per visualizzare la lista di template
---------------------------------------------------------------

create VIEW [dbo].[VERBALETEMPLATE_DETTAGLI_FROM_VERBALETEMPLATE ]
as
select 
	D.idheader as ID_FROM, 
	D.* 
from 
	ctl_doc,
	document_verbalegara T,
	Document_VerbaleGara_dettagli D
	
where
	tipodoc='VERBALETEMPLATE'
	and id=T.idheader
	and T.idheader=D.idheader
	and deleted=0

GO
