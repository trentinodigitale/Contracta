USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AVCP_CONFIG_FROM_AVCP_CONFIG_VIEWER]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[AVCP_CONFIG_FROM_AVCP_CONFIG_VIEWER] as
select 
	idazi as ID_FROM,	
	idazi  as Azienda,
	'InLavorazione' as StatoFunzionale	
from aziende
where azivenditore = 0 and azideleted=0 
GO
