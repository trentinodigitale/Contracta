USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PARAMETRI_ALBO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_PARAMETRI_ALBO] AS
SELECT
	*,
	idheader as id
from Document_Parametri_Abilitazioni
GO
