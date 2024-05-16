USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_SRC_DIR_RAPLEG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view  [dbo].[DASHBOARD_VIEW_SRC_DIR_RAPLEG] as 

select distinct 
			isold , 
			idAziDirTec as idAziPartecipante,
			idAziDirTec as idAziPartecipanteHide,
			NomeDirTec , 
			CognomeDirTec , 
			TelefonoDirTec , 
			EmailDirTec, 
			EmailDirTec as emailComunicazioni,
			RuoloDirTec 
from  dbo.Document_Aziende_DirTec
where not idAziDirTec is null
union
select distinct 
			isold , 
			idAziRapLeg as idAziPartecipante,
			idAziRapLeg as idAziPartecipanteHide, 
			NomeRapLeg as NomeDirTec , 
			CognomeRapLeg as CognomeDirTec, 
			TelefonoRapLeg as TelefonoDirTec, 
			EmailRapLeg as EmailDirTec , 
			EmailRapLeg as emailComunicazioni,
			RuoloRapLeg as RuoloDirTec 
from  dbo.Document_Aziende_RapLeg
where not idAziRapLeg is null



GO
