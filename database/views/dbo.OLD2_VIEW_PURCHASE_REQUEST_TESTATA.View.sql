USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_PURCHASE_REQUEST_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_VIEW_PURCHASE_REQUEST_TESTATA] AS
	select * 
		from ctl_doc a with(nolock) 
				inner join document_pr b with(nolock) on b.idheader = a.id
GO
