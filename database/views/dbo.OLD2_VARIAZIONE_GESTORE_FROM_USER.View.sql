USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VARIAZIONE_GESTORE_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_VARIAZIONE_GESTORE_FROM_USER]
as

select 
	   u.idpfu as ID_FROM,
	   p.*
    
from profiliutente u
inner join Document_Configurazione_Variazione_Gestore p on p.deleted = 0
left outer join CTL_DOC d on d.tipodoc = 'VARIAZIONE_GESTORE' and d.deleted = 0 and d.StatoFunzionale = 'Confermato' 

GO
