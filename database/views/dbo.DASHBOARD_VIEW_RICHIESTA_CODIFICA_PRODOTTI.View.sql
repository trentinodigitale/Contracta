USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTA_CODIFICA_PRODOTTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_RICHIESTA_CODIFICA_PRODOTTI] as
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
    P.idpfu as OWNER 
from ctl_doc
inner join ProfiliUtente P on Azienda=pfuIdAzi
where TipoDoc='RICHIESTA_CODIFICA_PRODOTTI' and deleted=0

GO
