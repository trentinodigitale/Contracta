USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SEDUTA_VIRTUALE_LOTTO_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_SEDUTA_VIRTUALE_LOTTO_TESTATA_VIEW] as
select
	D.id,
	'' as StatoFunzionale ,
	'' as Caption,
	b.Protocollo as ProtocolloRiferimento,
	B.body as Body		
from document_microlotti_dettagli D with(NOLOCK) 
	inner join CTL_DOC PDA with(NOLOCK) on PDA.id=D.IdHeader 
	inner join CTL_DOC B with(NOLOCK) on B.id=PDA.LinkedDoc 
where  D.TipoDoc='PDA_MICROLOTTI' and D.Voce = 0 




GO
