USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_PEG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DOCUMENT_PEG]
AS
SELECT      *,ResidualBudget as RDA_ResidualBudget,inBudget as RDA_inBudget,id as PEG_ID
FROM         Document_Esito

GO
