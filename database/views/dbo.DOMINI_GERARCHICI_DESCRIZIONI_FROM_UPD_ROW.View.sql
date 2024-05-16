USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOMINI_GERARCHICI_DESCRIZIONI_FROM_UPD_ROW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[DOMINI_GERARCHICI_DESCRIZIONI_FROM_UPD_ROW] as

select d.id as  ID_FROM 
	, lngSuffisso AS Lingua  
	, isnull( ML_Description  ,DMV_DescML ) as  Descrizione

	from  LIB_DomainValues d
		cross join Lingue
		left outer join LIB_Multilinguismo on lngSuffisso = ML_LNG and ML_KEY = DMV_DescML and ML_Context = 0
GO
