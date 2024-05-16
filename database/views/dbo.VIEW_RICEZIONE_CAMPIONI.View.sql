USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_RICEZIONE_CAMPIONI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_RICEZIONE_CAMPIONI] as
select 
	C.*
	, C1.Value as ProtocolloBando
	from ctl_doc C left outer join ctl_doc_value C1 on C.id=C1.idheader
where tipodoc='ricezione_campioni'
GO
