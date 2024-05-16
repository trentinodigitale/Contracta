USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_QUOTIDIANI_FORNITORI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_QUOTIDIANI_FORNITORI]
as 
select 
		Q.value as id, Q.value as Giornale ,F.value as Fornitore, 'I' as Lingua from 

		ctl_doc C
			inner join ctl_doc_value Q on Q.idheader = C.id and Q.DZT_Name ='Quotidiani'
			inner join ctl_doc_value F on F.idheader = c.id and F.dzt_name='Fornitore' and F.row=Q.row
	
		where tipodoc='QUOTIDIANI_FORNITORI' and statofunzionale='Confermato'
GO
