USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_MODELLO69]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_MODELLO69]
AS
SELECT a.idaggiudicatrice as fornitore ,a.serie,NumRegistrazione, DataRegistrazione,b.*
,	case when isnull( StatoRepertorio , '' ) = '' then 'InCorso'
		else StatoRepertorio 
	end as StatoRepertorio 
FROM           document_repertorio a ,Document_Mod69 b
where a.IdRepertorio=b.ID_Repertorio

GO
