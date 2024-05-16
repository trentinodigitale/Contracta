USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOMINI_GERARCHICI_FROM_UPD_ROW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DOMINI_GERARCHICI_FROM_UPD_ROW] as
select id as  ID_FROM , id as LinkedDoc , 'Upd' as JumpCheck , ' DMV_Cod ' as NotEditable  
	,DMV_Cod , DMV_CodExt
from  LIB_DomainValues 
GO
