USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_FABBISOGNI_ANALISI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_DASHBOARD_VIEW_FABBISOGNI_ANALISI] as

	select 
		  C.Id,
		  C.IdPfu,
		  c.TipoDoc, 
		  C.StatoDoc, 
		  C.Data, 
		  C.Protocollo, 
		  C.Deleted,
		  C.Titolo,
		  C.DataInvio,
		  cast(a.Body as nvarchar(4000)) as Oggetto,
		  C.idpfu as OWNER,
		  B.DataRiferimentoFine,
		  C.StatoFunzionale,
		 -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
		 --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
		 ISNULL(CV.Value,0) as NumeroPartecipanti,
		 ISNULL(B.RecivedIstanze,0) as NumeroRisposte
	from CTL_DOC C
		inner join CTL_DOC A on A.id =C.LinkedDoc
		left join Document_Bando B on B.idheader=C.LinkedDoc
		left join Document_Bando_Riferimenti R on R.idHeader=C.LinkedDoc
		left outer join CTL_DOC_VALUE CV on CV.IdHeader=C.LinkedDoc and DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'
	where C.tipodoc='ANALISI_FABBISOGNI' and C.deleted=0

union

	select 
		  C.Id,
		  C.IdPfu,
		  C.TipoDoc, 
		  C.StatoDoc, 
		  C.Data, 
		  C.Protocollo, 
		  C.Deleted,
		  C.Titolo,
		  C.DataInvio,
		  cast(a.Body as nvarchar(4000)) as Oggetto,
		  R.idpfu as OWNER,
		  B.DataRiferimentoFine,
		  C.StatoFunzionale,
		 -- (select count(*) from ctl_doc_destinatari where idheader=id ) as NumeroPartecipanti,
		 --(select count(*) from ctl_doc_destinatari where idheader=id and StatoIscrizione='Completato') as NumeroRisposte
		  ISNULL(CV.Value,0) as NumeroPartecipanti,
		  ISNULL(B.RecivedIstanze,0) as NumeroRisposte

	from CTL_DOC C
		inner join CTL_DOC A on A.id =C.LinkedDoc
		left join Document_Bando B on B.idheader=C.LinkedDoc
		left join Document_Bando_Riferimenti R on R.idHeader=C.LinkedDoc
		left outer join CTL_DOC_VALUE CV on CV.IdHeader=C.LinkedDoc and DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'
	where C.tipodoc='ANALISI_FABBISOGNI' and C.deleted=0







GO
