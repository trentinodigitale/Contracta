USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PROROGA_ALBO_FROM_AZIENDA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[PROROGA_ALBO_FROM_AZIENDA] as
select 
idazi as ID_FROM ,
idazi as Azienda
from Aziende 
GO
