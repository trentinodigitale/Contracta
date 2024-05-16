USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_LIB_DOMAINVALUES_LIB_MULTILINGUISMO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--vista per il dettaglio accessi utenti
---------------------------------------------------------------


CREATE VIEW [dbo].[VIEW_LIB_DOMAINVALUES_LIB_MULTILINGUISMO] as 
	

 select a.id, a.DMV_DM_ID,a.DMV_Cod,a.DMV_Father,a.DMV_Level,ISNULL( cast(ML_Description as nvarchar(max)),  a.DMV_DescML  ) as DMV_DescML,a.DMV_Image,a.DMV_Sort,a.DMV_CodExt,a.DMV_Module , a.DMV_Deleted 
	from 
		lib_domainvalues a WITH (NOLOCK) left outer join LIB_Multilinguismo WITH (NOLOCK) on   a.DMV_DescML = ML_KEY and ML_LNG = 'I' 
		




GO
