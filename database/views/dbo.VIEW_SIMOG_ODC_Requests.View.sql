USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_SIMOG_ODC_Requests]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_SIMOG_ODC_Requests] 
AS
SELECT 
	idheader  as id,
	value as ID_DOC_GET_SIMOG
	from 
		ctl_Doc_value with (nolock)
		where dse_id = 'SIMOG_GET'
				and DZT_Name ='ID_DOC_GET_CIG'

GO
