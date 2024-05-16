USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PURCHASE_REQUEST_TESTATA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_PURCHASE_REQUEST_TESTATA] AS
	select * ,
			case when isnull([idPfuInCharge],0)=0 then '0' else '1' end as isInCharge,
			DataScadenza as DeliveryDate,
			Note as DeliveryNotes

		from ctl_doc a with(nolock) 
				inner join document_pr b with(nolock) on b.idheader = a.id
GO
