USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_NOTIER_INVOICE_DOCUMENT]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_VIEW_NOTIER_INVOICE_DOCUMENT] AS
	SELECT D.*,
			c1.Value as StatoFatturaPeppol,
			c2.Value as StatusReasonIMR
		FROM CTL_DOC D
				LEFT JOIN CTL_DOC_Value c1 with(nolock) ON c1.idheader = D.Id and c1.DSE_ID = 'NOTIER' and c1.DZT_Name = 'StatoFatturaPeppol'
				LEFT JOIN CTL_DOC_Value c2 with(nolock) ON c2.idheader = D.Id and c2.DSE_ID = 'NOTIER' and c2.DZT_Name = 'StatusReasonIMR' --non è usato


GO
