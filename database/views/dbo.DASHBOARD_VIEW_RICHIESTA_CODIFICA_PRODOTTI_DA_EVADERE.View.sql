USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTA_CODIFICA_PRODOTTI_DA_EVADERE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_RICHIESTA_CODIFICA_PRODOTTI_DA_EVADERE] as
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
		IdPfuInCharge ,
		IdPfu,
		az.aziRagioneSociale
	from ctl_doc with(nolock)
			left join aziende az with(nolock) ON az.idazi = azienda 
	where TipoDoc='RICHIESTA_CODIFICA_PRODOTTI' and deleted=0 



GO
