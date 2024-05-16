USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TESTATA_PRODOTTI_CONVENZIONE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_TESTATA_PRODOTTI_CONVENZIONE] as 
select
	*
from ctl_doc_value where DSE_ID='TESTATA_PRODOTTI'

union all

select 
	DC.id as idrow,
	DC.id as idHeader,
	'TESTATA_PRODOTTI' as DSE_ID,
	0 as row,
	'Ambito' as Dzt_name,
	Ambito as Value
from ctl_doc C
	inner join Document_convenzione DC on C.id=DC.id
	where c.deleted=0 and tipodoc='CONVENZIONE'

union all

select 
	DC.id as idrow,
	DC.id as idHeader,
	'TESTATA_PRODOTTI' as DSE_ID,
	0 as row,
	'Merceologia' as Dzt_name,
	Merceologia as Value
from ctl_doc C
	inner join Document_convenzione DC on C.id=DC.id
	where c.deleted=0 and tipodoc='CONVENZIONE'

	union all

select 
	DC.id as idrow,
	DC.id as idHeader,
	'TESTATA_PRODOTTI' as DSE_ID,
	0 as row,
	'NotEditable' as Dzt_name,
	ISNULL(NotEditable,'') as Value
from ctl_doc C
	inner join Document_convenzione DC on C.id=DC.id
	where c.deleted=0 and tipodoc='CONVENZIONE'

	union all

select 
	DC.id as idrow,
	DC.id as idHeader,
	'TESTATA_PRODOTTI' as DSE_ID,
	0 as row,
	'MSGTEXT' as Dzt_name,
	case when ISNULL(StatoListino,'') in ('Inviato','Confermato') then 'NON_CARICARE' else 'SI_CARICARE' end as Value
from ctl_doc C
	inner join Document_convenzione DC on C.id=DC.id
	where c.deleted=0 and tipodoc='CONVENZIONE'


union all

select 
	DC.id as idrow,
	DC.id as idHeader,
	'TESTATA_PRODOTTI' as DSE_ID,
	0 as row,
	'DPCM' as Dzt_name,
	DPCM as Value
from ctl_doc C
	inner join Document_convenzione DC on C.id=DC.id
	where c.deleted=0 and tipodoc='CONVENZIONE'

GO
