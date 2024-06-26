USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AQ_QUOTA_BASE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AQ_QUOTA_BASE_VIEW] AS
SELECT 
	DQ.*,
	C.Body,
	PREV.datascadenzaQ as datascadenzaA
FROM 
	Document_Convenzione_Quote DQ with(nolock)
		inner join CTL_DOC C with(nolock) on C.Id=DQ.idHeader and C.TipoDoc='AQ_QUOTA'
		left join Document_Convenzione_Quote PREV with(nolock) on PREV.idHeader=C.PrevDoc 
		
GO
