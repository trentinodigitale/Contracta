USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_FABBISOGNI_LISTA_COMPLETA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_FABBISOGNI_LISTA_COMPLETA] as
select 
		  CD.idrow as Id,
		  C.IdPfu,
		  TipoDoc, 
		  StatoDoc, 
		  Data, 
		  Protocollo, 
		  Deleted,
		  Titolo,
		  DataInvio,
		  cast(Body as nvarchar(4000)) as Oggetto,
		  P.idpfu as OWNER,
		  B.DataRiferimentoFine,
		  CD.StatoIscrizione as StatoFunzionale,
		  P.pfuIdAzi,
		  CD.idpfu as idpfuinCharge,
		  CD.idHeader

	from CTL_DOC C
		left join  Document_Bando B on B.idheader=C.id
		inner join CTL_DOC_Destinatari CD on C.id=CD.idHeader-- and ISNULL(CD .idpfu,0) <> 0
		inner join ProfiliUtente P on P.pfuIdAzi=CD.IdAzi
	where tipodoc = 'BANDO_FABBISOGNI' and deleted=0 


GO
