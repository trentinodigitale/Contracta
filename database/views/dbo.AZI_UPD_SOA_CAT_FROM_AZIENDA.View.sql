USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_SOA_CAT_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_UPD_SOA_CAT_FROM_AZIENDA]
AS
SELECT     idAziSOA as IdAzi, idAziSOA AS ID_FROM, *
FROM                             dbo.Document_Aziende_SOA 

GO
