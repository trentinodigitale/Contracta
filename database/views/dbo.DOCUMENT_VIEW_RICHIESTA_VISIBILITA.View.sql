USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_VIEW_RICHIESTA_VISIBILITA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DOCUMENT_VIEW_RICHIESTA_VISIBILITA]
as
select 
	c.* 
    , case statofunzionale 
		when 'InLavorazione' then ' DataTermineConcordata  '
		else ' Titolo  Body  DataTermineVisibilita  Allegato  '
	 end as Not_Editable
	, ca.Allegato
	, ca.IdHeader
	, ca.idrow
from 
	ctl_doc c
		left join ctl_doc_allegati ca on id=idheader
			
where 
	tipodoc='RICHIESTA_VISIBILITA'

GO
