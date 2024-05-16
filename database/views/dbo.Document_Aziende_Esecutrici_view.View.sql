USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Esecutrici_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Aziende_Esecutrici_view] as
select idRow , 
		Document_Aziende_Esecutrici.idAzi as idAziPartecipante, 
		Document_Aziende_Esecutrici.idAzi as idAziPartecipanteHide, 
		idMsg , 
		ProtocolloBando , 
		aziRagioneSociale , 
		idAziEsecutrice as Bil 

from Document_Aziende_Esecutrici 
	left outer join aziende as a on a.idazi =  idAziEsecutrice
GO
