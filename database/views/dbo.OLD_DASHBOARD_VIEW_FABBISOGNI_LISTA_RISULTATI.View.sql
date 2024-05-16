USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_FABBISOGNI_LISTA_RISULTATI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_FABBISOGNI_LISTA_RISULTATI] as
select 
		  a.id as Id,
		  C.IdPfu,
		  a.TipoDoc, 
		  
		  
		  a.Protocollo, 
		  a.Deleted,
		  a.Titolo,
		  a.Fascicolo,
		  a.DataInvio,
		  cast(c.Body as nvarchar(4000)) as Oggetto,
		  P.idpfu as OWNER,
		  B.DataRiferimentoFine,
		  CD.StatoIscrizione as StatoFunzionale,
		  P.pfuIdAzi,
		  CD.idpfu as idpfuinCharge,
		  CD.idHeader

	from CTL_DOC a
		inner join CTL_DOC c on c.tipoDoc = 'BANDO_FABBISOGNI' and a.LinkedDoc = c.id 
		left join  Document_Bando B on B.idheader=C.id
		inner join CTL_DOC_Destinatari CD on C.id=CD.idHeader-- and ISNULL(CD .idpfu,0) <> 0
		inner join ProfiliUtente P on P.pfuIdAzi=CD.IdAzi
	where a.tipodoc = 'ANALISI_FABBISOGNI' and a.deleted=0 and a.statofunzionale='Pubblicato'


GO
