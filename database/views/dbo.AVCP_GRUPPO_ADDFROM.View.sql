USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_GRUPPO_ADDFROM]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AVCP_GRUPPO_ADDFROM] as
Select 
*,
id as IndRow,
aziragionesociale as ragionesociale

from ExtendedDomain_BDG_Fornitori

GO
