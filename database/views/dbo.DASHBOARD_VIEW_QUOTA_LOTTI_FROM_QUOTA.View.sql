USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_QUOTA_LOTTI_FROM_QUOTA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_QUOTA_LOTTI_FROM_QUOTA] AS
select 
	C.id as ID_FROM,
	DQ.NumeroLotto,
	DQ.descrizione,
	DQ.Importo,
	DQ.Importo_Q_Lotto,
	DQ.Residuo,
	DQ.Importo as Importo_Allocato_Prec,
	DQ.ImportoRichiesto
	from ctl_doc  C
		inner join Aziende on Azienda=IdAzi
		inner join QUOTA_LOTTI_VIEW DQ on DQ.idHeader=C.id
	where C.TipoDoc='QUOTA'
GO
