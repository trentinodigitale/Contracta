USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_DIRTEC_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_UPD_DIRTEC_FROM_AZIENDA]
AS
SELECT     a.aziRagioneSociale,
			a.aziPartitaIVA, 
            a.IdAzi, 
            a.IdAzi AS ID_FROM,

			s.*


FROM         dbo.Aziende as a 
			left outer join  dbo.Document_Aziende_DirTec   as s  on  a.idAzi = s.idAziDirTec and isOld = 0

GO
