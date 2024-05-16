USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_RICHIESTA_CODIFICA_PRODOTTI_DA_EVADERE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_DASHBOARD_VIEW_RICHIESTA_CODIFICA_PRODOTTI_DA_EVADERE] as
select 
	Id,
	Tipodoc,
	Statodoc,
	Deleted,
	Titolo,
	Data,
	Protocollo,
	Statofunzionale,
	Datainvio,
	Body as Oggetto,
	IdPfuInCharge 
from ctl_doc

where TipoDoc='RICHIESTA_CODIFICA_PRODOTTI' and deleted=0 


GO
