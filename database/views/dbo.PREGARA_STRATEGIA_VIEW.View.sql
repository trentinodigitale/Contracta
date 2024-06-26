USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PREGARA_STRATEGIA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[PREGARA_STRATEGIA_VIEW] AS
select
	DB.*,
	CVT.Value as PunteggioTecnico,
	CVE.Value as PunteggioEconomico
from CTL_DOC C with(nolock) 
		left join Document_Bando DB with(nolock) on DB.idHeader=C.id
		left join CTL_DOC_Value CVT with(nolock) on CVT.IdHeader=C.Id and CVT.DSE_ID='CRITERI_ECO' and CVT.DZT_Name='PunteggioTecnico' 
		left join CTL_DOC_Value CVE with(nolock) on CVE.IdHeader=C.Id and CVE.DSE_ID='CRITERI_ECO' and CVE.DZT_Name='PunteggioEconomico' 
	where C.TipoDoc='PREGARA'
GO
