USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SEDUTA_VIRTUALE_LOTTO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[SEDUTA_VIRTUALE_LOTTO_TESTATA_VIEW] as
select
	D.id,
	'' as StatoFunzionale ,
	'' as Caption,
	b.Protocollo as ProtocolloRiferimento,
	B.body as Body,
	D.cig,D.descrizione, D.NumeroLotto
from document_microlotti_dettagli D with(NOLOCK) 
	inner join CTL_DOC PDA with(NOLOCK) on PDA.id=D.IdHeader 
	inner join CTL_DOC B with(NOLOCK) on B.id=PDA.LinkedDoc 
where  D.TipoDoc in ('PDA_MICROLOTTI','PDA_CONCORSO') and D.Voce = 0 



GO
