USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ISTANZA_AlboFornitori_DISPLAY_CLASSI_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ISTANZA_AlboFornitori_DISPLAY_CLASSI_VIEW] as
	select 
		 CT.IdRow, 
		 CT.IdHeader, 
		 DSE_ID, 
		 Row, 
		 DZT_Name,
		 value
	

	from CTL_DOC_VALUE CT
	where DSE_ID='DISPLAY_CLASSI'

union

	Select 
		DB.IdRow,
		id as idheader,
		'DISPLAY_CLASSI' as DSE_ID,
		0 as row,
		'ClasseIscriz_Bando' as DZT_Name,
		ClasseIscriz as value
		
	from
	ctl_doc 
	inner join document_bando DB on DB.idheader=LinkedDoc
	where tipodoc like 'ISTANZA_Albo%' 
GO
