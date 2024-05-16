USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_HD_MESSAGE_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Document_HD_MESSAGE_VIEW]
AS
select 
	doc.*
	, 'HD_MESSAGE' as CONVERSAZIONEGrid_OPEN_DOC_NAME
	,doc.id as CONVERSAZIONEGrid_ID_DOC
 from ctl_doc doc where deleted = 0 and tipodoc = 'HD_MESSAGE'
	

GO
