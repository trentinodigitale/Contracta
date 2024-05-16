USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PARAMETRI_SDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create VIEW [dbo].[VIEW_PARAMETRI_SDA] AS
SELECT
	PS.*,
	--PS.idheader as id,
	PA.scelta_classi_libera 
from 
	document_parametri_sda PS
	inner join Document_Parametri_Abilitazioni PA on PA.idheader = PS.idheader 
	
GO
