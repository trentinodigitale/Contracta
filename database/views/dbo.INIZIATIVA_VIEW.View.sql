USE [AFLink_TND]
GO
/****** Object:  View [dbo].[INIZIATIVA_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[INIZIATIVA_VIEW]	as
select
	id,
	tipodoc,
	numerodocumento,
	PrevDoc,
	Body,
	Idpfu,
	Protocollo,
	DataInvio,
	Case when Deleted=1 then 'Annullato' else StatoFunzionale end as StatoFunzionale
from ctl_doc with(NOLOCK)
where TipoDoc = 'INIZIATIVA'
GO
