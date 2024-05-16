USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_LISTA_PROGRAMMAZIONI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_DASHBOARD_VIEW_LISTA_PROGRAMMAZIONI] as

	select 
		  Id,
		  C.IdPfu,
		  TipoDoc, 
		  StatoDoc, 
		  Data, 
		  Protocollo, 
		  Deleted,
		  Titolo,
		  DataInvio,
		  cast(Body as nvarchar(4000)) as Oggetto,
		  C.idpfu as OWNER,
		 
		  C.StatoFunzionale,
		 
		 tipodoc as OPEN_DOC_NAME
	from CTL_DOC C	
		where tipodoc='PROGRAMMAZIONE' and deleted=0 and StatoFunzionale='Confermato'
GO
