USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFIG_MODELLI_LOTTI_VINCOLI_FROM_MODELLI_LOTTI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CONFIG_MODELLI_LOTTI_VINCOLI_FROM_MODELLI_LOTTI] as
Select * 
,IdHeader as ID_FROM
from Document_Vincoli with(nolock)
	
GO
