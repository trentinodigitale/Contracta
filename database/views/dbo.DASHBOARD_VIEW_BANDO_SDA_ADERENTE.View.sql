USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDO_SDA_ADERENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_BANDO_SDA_ADERENTE] as 

select b.IdRow as ID_FROM , p.idpfu as idPfu_aderente, d.* ,s.*
from CTL_DOC  d  with(nolock) 
		inner join dbo.Document_Bando s  with(nolock) on id = idheader
		inner join CTL_DOC_Value b  with(nolock) on b.IdHeader = d.id and DSE_ID = 'ENTI' and DZT_Name = 'AZI_Ente' 
		inner join profiliutente p  with(nolock) on b.Value = p.pfuidazi
where d.deleted = 0 and TipoDoc in ( 'BANDO_SDA' ) and d.statoFunzionale = 'Pubblicato'
      and DataPresentazioneRisposte < getDate() and getDate() < DataScadenza



GO
