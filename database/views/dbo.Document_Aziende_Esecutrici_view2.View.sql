USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Aziende_Esecutrici_view2]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Aziende_Esecutrici_view2] as 
select idAziRTI ,PIVA_CF , idAziPartecipante ,idazi as idAziPartecipanteHide , aziRagioneSociale  from Document_Aziende_RTI as s inner join Aziende as a  on a.idAzi = s.idAziPartecipante and isOld = 0
GO
