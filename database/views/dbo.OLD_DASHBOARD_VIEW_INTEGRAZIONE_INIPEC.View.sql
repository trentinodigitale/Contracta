USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_INTEGRAZIONE_INIPEC]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_INTEGRAZIONE_INIPEC]
AS

select 
	Id as id,
	Protocollo,
	StatoDoc,
	Data as DataIns,
	DataInvio,
	StatoFunzionale,
	(select count(*) from Document_inipec b where a.id = b.idHeader) as Num
	from CTL_DOC a with (nolock)
	where TipoDoc = 'INIPEC'
	AND deleted = 0
GO
