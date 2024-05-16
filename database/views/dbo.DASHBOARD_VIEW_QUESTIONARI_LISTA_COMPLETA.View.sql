USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_QUESTIONARI_LISTA_COMPLETA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_QUESTIONARI_LISTA_COMPLETA] as
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
	where tipodoc = 'BANDO_FABB_QUALITATIVO' and deleted=0 



GO
