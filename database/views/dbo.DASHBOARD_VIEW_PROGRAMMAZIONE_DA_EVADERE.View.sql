USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROGRAMMAZIONE_DA_EVADERE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PROGRAMMAZIONE_DA_EVADERE]  as
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
		  B.DataPresentazioneRisposte as DataRiferimentoFine,
		  C.StatoFunzionale,
		  P.pfuIdAzi,
		  C.idpfuinCharge,
		  CD.statoiscrizione

	from CTL_DOC C
		left join  Document_Bando B on B.idheader=C.id
		inner join CTL_DOC_Destinatari CD on C.id=CD.idHeader
		inner join ProfiliUtente P on P.pfuIdAzi=CD.IdAzi
	where tipodoc = 'BANDO_PROGRAMMAZIONE' and deleted=0 and ISNULL(CD .idpfu,0)=0 and ISNULL(CD.StatoIscrizione,'') <> 'Completato' and ISNULL(CD.StatoIscrizione,'') <> 'Annullato'
	and C.StatoFunzionale <> 'InLavorazione'


GO
