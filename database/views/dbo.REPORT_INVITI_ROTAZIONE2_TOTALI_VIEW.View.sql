USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_INVITI_ROTAZIONE2_TOTALI_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[REPORT_INVITI_ROTAZIONE2_TOTALI_VIEW] AS

select 
	
	DI.idHeader,
	SUM(ISNULL(NumInvitiVirtuali,0) ) as TOT_NumInvitiVirtuali ,
	SUM(ISNULL(NumInvitiReali,0)) as TOT_NumInvitiReali ,
	SUM(ISNULL(NumInvitiVirtuali,0) ) + SUM(ISNULL(NumInvitiReali,0)) as TOT_INVITI
		
	from DOCUMENT_BANDO_INVITI_LAVORI DI with(nolock)
	group by idHeader,idAzi
GO
