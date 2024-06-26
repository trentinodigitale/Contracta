USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VARIAZIONE_GESTORE_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VARIAZIONE_GESTORE_FROM_USER]
as

	select u.idpfu as ID_FROM,
		   p.*
    	from profiliutente u with(nolock)
				inner join Document_Configurazione_Variazione_Gestore p with(nolock) on p.deleted = 0
				left join CTL_DOC d with(nolock) on d.tipodoc = 'VARIAZIONE_GESTORE' and d.deleted = 0 and d.StatoFunzionale = 'Confermato' 
GO
