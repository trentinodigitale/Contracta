USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Mail_Template_DOC_USED]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_Mail_Template_DOC_USED] as 
   select distinct DOC_ID from dbo.LIB_Documents with(nolock)
		inner join dbo.CTL_Mail_Template with(nolock) on charindex(  '###' + DOC_ID + '###' , Multi_Doc  ) > 0
	
	UNION 	
		
	select distinct cast(dcmitype as varchar(5)) + ';' + cast(dcmisubtype as varchar(5)) as DOC_ID from DOCUMENT with(nolock)
		inner join dbo.CTL_Mail_Template with(nolock) on charindex(  '###' + cast(dcmitype as varchar(5)) + ';' + cast(dcmisubtype as varchar(5)) + '###' ,Multi_Doc  ) > 0
		where dcmitype=55
		and dcmdeleted=0
		--and dcminput=0

GO
