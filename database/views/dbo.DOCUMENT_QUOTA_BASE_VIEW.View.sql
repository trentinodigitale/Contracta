USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_QUOTA_BASE_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DOCUMENT_QUOTA_BASE_VIEW] AS
	SELECT cq.idRow,
			cq.idHeader,
			cq.importo,
			c.Body,
			cq.Value_tec__Azi,
			cq.Importo_Allocato_Prec
	FROM ctl_doc c 
		left join Document_Convenzione_Quote cq on cq.idHeader=c.id

GO
