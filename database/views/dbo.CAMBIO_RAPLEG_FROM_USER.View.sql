USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CAMBIO_RAPLEG_FROM_USER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CAMBIO_RAPLEG_FROM_USER] as 
select
	idpfu as ID_FROM,
	pfuidazi as Azienda
from 
ProfiliUtente,aziende
GO
