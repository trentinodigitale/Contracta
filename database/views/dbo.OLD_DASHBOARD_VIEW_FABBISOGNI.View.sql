USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_FABBISOGNI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_DASHBOARD_VIEW_FABBISOGNI] as

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
		  B.datapresentazionerisposte as DataRiferimentoFine,
		  C.StatoFunzionale,
		 -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
		 --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
		 ISNULL(CV.Value,0) as NumeroPartecipanti,
		 ISNULL(B.RecivedIstanze,0) as NumeroRisposte
	from CTL_DOC C
		left join Document_Bando B on B.idheader=C.id
		left join Document_Bando_Riferimenti R on R.idHeader=C.Id
		left outer join CTL_DOC_VALUE CV on CV.IdHeader=C.id and DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'
	where tipodoc='BANDO_FABBISOGNI' and deleted=0

union

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
		  R.idpfu as OWNER,
		  B.datapresentazionerisposte as DataRiferimentoFine,
		  C.StatoFunzionale,
		 -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
		 --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
		  ISNULL(CV.Value,0) as NumeroPartecipanti,
		  ISNULL(B.RecivedIstanze,0) as NumeroRisposte

	from CTL_DOC C
		left join Document_Bando B on B.idheader=C.id
		left join Document_Bando_Riferimenti R on R.idHeader=C.Id
		left outer join CTL_DOC_VALUE CV on CV.IdHeader=C.id and DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'
	where tipodoc='BANDO_FABBISOGNI' and deleted=0

union
	
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
		  C.idPfuInCharge as OWNER,
		  B.datapresentazionerisposte as DataRiferimentoFine,
		  C.StatoFunzionale,
		 -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
		 --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
		 ISNULL(CV.Value,0) as NumeroPartecipanti,
		 ISNULL(B.RecivedIstanze,0) as NumeroRisposte
	from CTL_DOC C
		left join Document_Bando B on B.idheader=C.id
		left join Document_Bando_Riferimenti R on R.idHeader=C.Id
		left outer join CTL_DOC_VALUE CV on CV.IdHeader=C.id and DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'
	where tipodoc='BANDO_FABBISOGNI' and deleted=0


GO
