USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOMINI_GERARCHICI_DESCRIZIONI_FROM_ID_ROW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[DOMINI_GERARCHICI_DESCRIZIONI_FROM_ID_ROW] as

select id as  ID_FROM , lngSuffisso AS Lingua  
	from  LIB_DomainValues ,Lingue
GO
