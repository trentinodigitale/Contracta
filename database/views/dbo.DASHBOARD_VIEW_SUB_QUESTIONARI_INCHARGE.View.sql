USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_SUB_QUESTIONARI_INCHARGE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_SUB_QUESTIONARI_INCHARGE] as
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
		  idPfuInCharge as OWNER,
		  C.StatoFunzionale,
		  
		  C.idpfuinCharge,
		  C.datascadenza
		  

	from CTL_DOC C				
	where tipodoc = 'SUB_QUESTIONARIO_FABBISOGNI' and deleted=0 


GO
