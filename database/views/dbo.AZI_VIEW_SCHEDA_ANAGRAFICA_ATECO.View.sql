USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_VIEW_SCHEDA_ANAGRAFICA_ATECO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[AZI_VIEW_SCHEDA_ANAGRAFICA_ATECO]
AS
SELECT idVat as id, 
	   vatvalore_ft as GerarchicoATECO_S,
	   lnk as idAzi 
from dm_attributi    with (nolock)
	where dztnome = 'ATECO' and idapp = 1
GO
