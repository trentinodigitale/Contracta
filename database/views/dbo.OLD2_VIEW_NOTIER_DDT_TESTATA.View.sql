USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_NOTIER_DDT_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_VIEW_NOTIER_DDT_TESTATA] AS

	select [IdRow], [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value]
		from ctl_doc_value a with(nolock)
		where a.DSE_ID = 'DESPATCHADVICE'


	UNION ALL

	select   [IdRow]
			, [IdHeader]
		 	, 'DESPATCHADVICE' as [DSE_ID]
			, [Row]
			, 'NotEditable' as [DZT_Name] 
			, ' OrderReference_ID , OrderReference_IssueDate , OrderTypeCode ' as [Value]
		from ctl_doc_value b with(nolock)
		where b.DSE_ID = 'NOTIER' and b.DZT_Name = 'ordine_associato' and b.[Value] = '1'

	UNION ALL

	select  a.id as [IdRow]
			, a.id as IdHeader
		 	, 'DESPATCHADVICE' as [DSE_ID]
			, 0 as [Row]
			, 'NotEditable' as [DZT_Name] 
			, '' as [Value]
		from ctl_doc a with(nolock)
				left join ctl_doc_value b with(nolock) on b.DSE_ID = 'NOTIER' and b.DZT_Name = 'ordine_associato' and b.[Value] = '1'
		where a.TipoDoc = 'NOTIER_DDT' and b.IdRow is null


GO
