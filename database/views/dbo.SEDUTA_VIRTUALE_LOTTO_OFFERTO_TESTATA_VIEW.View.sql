USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SEDUTA_VIRTUALE_LOTTO_OFFERTO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[SEDUTA_VIRTUALE_LOTTO_OFFERTO_TESTATA_VIEW] as
select
	D.id,
	'' as StatoFunzionale ,
	'' as Caption,
	b.Protocollo as ProtocolloRiferimento,
	B.body as Body,
	case 
		when isnull(D.cig,'')='' then ba.cig
	else
		d.cig
	end as cig
	,D.descrizione, D.NumeroLotto,
	DO.aziRagioneSociale
from document_microlotti_dettagli D with(NOLOCK) 
	inner join Document_PDA_OFFERTE DO with(NOLOCK) on DO.IdRow=D.IdHeader 
	inner join CTL_DOC PDA with(NOLOCK) on PDA.id=DO.IdHeader 
	inner join CTL_DOC B with(NOLOCK) on B.id=PDA.LinkedDoc 
	inner join document_bando ba with(NOLOCK) on ba.idHeader=b.id
where  D.TipoDoc='PDA_OFFERTE' and D.Voce = 0 
GO
