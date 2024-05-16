USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PARAMETRI_INFO_ADD]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE view [dbo].[DASHBOARD_VIEW_PARAMETRI_INFO_ADD] as
  select c.*
	from CTL_DOC C with(nolock)
		--	inner join dbo.Document_Parametri_SDA  DP on C.ID=DP.IDHEADER
	  where C.Statodoc='Sent' and c.tipodoc = 'PARAMETRI_INFO_ADD'



GO
