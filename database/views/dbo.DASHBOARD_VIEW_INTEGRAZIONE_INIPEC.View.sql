USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_INTEGRAZIONE_INIPEC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[DASHBOARD_VIEW_INTEGRAZIONE_INIPEC]
AS

select 
	Id as id,
	Protocollo,
	StatoDoc,
	Data as DataIns,
	DataInvio,
	StatoFunzionale,
	Num
	from CTL_DOC a with (nolock)
		left join (select count(*) as Num , idheader 
						from Document_inipec b with(nolock) 
						group by idheader
						) as n on a.id = n.idHeader
	where TipoDoc = 'INIPEC'
	AND deleted = 0
GO
