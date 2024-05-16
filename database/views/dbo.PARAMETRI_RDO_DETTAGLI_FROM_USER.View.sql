USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PARAMETRI_RDO_DETTAGLI_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PARAMETRI_RDO_DETTAGLI_FROM_USER] as
select
	idpfu as ID_FROM,
	DMV_Cod,
	DMV_Cod as Tipologia
from LIB_DomainValues 
cross join profiliUtente
where  DMV_DM_ID = 'Tipologia' and DMV_Cod in ( '1'  ,'3') --solo forniture e servizi

GO
