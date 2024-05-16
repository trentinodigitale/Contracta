USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEWER_LISTA_TEMPLATE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---------------------------------------------------------------
--nuova vista per visualizzare la lista di template
---------------------------------------------------------------

CREATE VIEW [dbo].[VIEWER_LISTA_TEMPLATE]
as

select 
	* 
from 
	ctl_doc,Document_VerbaleGara
where
	id=idheader
	and tipodoc='VERBALETEMPLATE'
	and deleted=0
	and ( ( isnull(Prevdoc,0)=0 and StatoFunzionale <> 'Variato')  or ( isnull(Prevdoc,0)<>0 and StatoFunzionale='Pubblicato' ) )


GO
