USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Com_DPE_PLANT_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[Document_Com_DPE_PLANT_VIEW] AS
select p.* 
		,'COM_DPE_RISPOSTA_PLANT' as PLANTGrid_OPEN_DOC_NAME
		--, '' as PLANTGrid_ID_DOC

	from Document_Com_DPE_Plant p

GO
