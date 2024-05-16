USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_BANDO_COPERTINA_SDA_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_BANDO_COPERTINA_SDA_FROM_USER] as 
select 
	idpfu as ID_FROM , 
	pfuidazi as Azienda,
	p.NumGiorniDomandaPartecipazione,
	ISNULL(L.DZT_ValueDef,2) as  versione

from profiliutente
left outer join Document_Parametri_SDA p on p.deleted = 0
left join LIB_Dictionary L on dzt_name='SYS_VERSIONE_BANDO_SDA'

GO
