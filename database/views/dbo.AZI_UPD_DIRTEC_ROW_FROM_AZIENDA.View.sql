USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_DIRTEC_ROW_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_UPD_DIRTEC_ROW_FROM_AZIENDA]
AS
SELECT     
            idAziDirTec as IdAzi, 
            idAziDirTec AS ID_FROM,

			*


FROM        Document_Aziende_DirTec   where isOld = 0

GO
