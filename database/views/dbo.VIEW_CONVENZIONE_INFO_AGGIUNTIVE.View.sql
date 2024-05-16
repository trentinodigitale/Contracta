USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONVENZIONE_INFO_AGGIUNTIVE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_CONVENZIONE_INFO_AGGIUNTIVE] as 
select
	*
from ctl_doc_value where DSE_ID='INFO_AGGIUNTIVE'

union

select 
	DC.id as idrow,
	DC.id as idHeader,
	'INFO_AGGIUNTIVE' as DSE_ID,
	0 as row,
	'NotEditable' as Dzt_name,
	ISNULL(NotEditable,'') as Value
from ctl_doc C
	inner join Document_convenzione DC on C.id=DC.id
	where c.deleted=0 and tipodoc='CONVENZIONE'
GO
