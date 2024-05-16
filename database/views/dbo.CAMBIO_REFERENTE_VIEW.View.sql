USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CAMBIO_REFERENTE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CAMBIO_REFERENTE_VIEW] AS
select 
	C.*,
	CV.Value as Utente,
	CV2.value as Filtro_Nuovo_Utente

from ctl_doc C
	left join CTL_DOC_Value CV on CV.IdHeader=C.id and CV.DSE_ID='DOCUMENT' and CV.DZT_Name='Utente' and CV.Row=0
	left join CTL_DOC_Value CV2 on CV2.IdHeader=C.id and CV2.DSE_ID='DOCUMENT' and CV2.DZT_Name='Filtro_Nuovo_Utente' and CV2.Row=0


where C.TipoDoc='CAMBIO_REFERENTE'
GO
