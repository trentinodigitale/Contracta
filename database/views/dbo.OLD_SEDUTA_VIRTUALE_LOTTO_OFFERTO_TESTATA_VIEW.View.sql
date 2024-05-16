USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SEDUTA_VIRTUALE_LOTTO_OFFERTO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD_SEDUTA_VIRTUALE_LOTTO_OFFERTO_TESTATA_VIEW] as
select
	D.id,
	'' as StatoFunzionale ,
	'' as Caption,
	b.Protocollo as ProtocolloRiferimento,
	B.body as Body,
	D.cig,D.descrizione, D.NumeroLotto,
	DO.aziRagioneSociale
from document_microlotti_dettagli D with(NOLOCK) 
	inner join Document_PDA_OFFERTE DO with(NOLOCK) on DO.IdRow=D.IdHeader 
	inner join CTL_DOC PDA with(NOLOCK) on PDA.id=DO.IdHeader 
	inner join CTL_DOC B with(NOLOCK) on B.id=PDA.LinkedDoc 
where  D.TipoDoc='PDA_OFFERTE' and D.Voce = 0 

GO
