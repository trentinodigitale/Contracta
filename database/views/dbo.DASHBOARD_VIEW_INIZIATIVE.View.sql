USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_INIZIATIVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_INIZIATIVE] as 
	SELECT  
		id , 
		case when deleted=1 then 'Annullato' else StatoFunzionale end as StatoFunzionale, 
		cast(NumeroDocumento as BIGINT) as NumeroDocumento , 
		--NumeroDocumento,
		isnull( Body , titolo ) as Titolo 
	FROM ctl_doc C with(NOLOCK)
	WHERE isnumeric(numerodocumento) = 1 and TipoDoc = 'INIZIATIVA' --and deleted = 0
		and StatoFunzionale <> 'Variato'






GO
