USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_RIPRISTINA_AZI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[VIEW_DOCUMENT_RIPRISTINA_AZI] as
	select a.*
	
		from ctl_doc a
				
		where Tipodoc='RIPRISTINA_AZI'


GO
