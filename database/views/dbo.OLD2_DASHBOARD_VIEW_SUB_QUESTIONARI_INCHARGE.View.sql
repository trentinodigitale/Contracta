USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_SUB_QUESTIONARI_INCHARGE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_SUB_QUESTIONARI_INCHARGE] as
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
		  
		  C.idpfuinCharge
		  

	from CTL_DOC C				
	where tipodoc = 'SUB_QUESTIONARIO_FABBISOGNI' and deleted=0 


GO
