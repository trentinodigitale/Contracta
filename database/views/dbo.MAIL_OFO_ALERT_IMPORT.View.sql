USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_OFO_ALERT_IMPORT]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_OFO_ALERT_IMPORT] AS
	select c.id as iddoc,
			'I' as LNG,
			c.NumeroDocumento,
			C.Body,
			d.ProjectDescription, 
			d.OrderId,
			d.PaymentConditionDescription
		from ctl_doc c with(nolock)
				inner join document_ofo d with(nolock) on d.idHeader = c.Id
GO
