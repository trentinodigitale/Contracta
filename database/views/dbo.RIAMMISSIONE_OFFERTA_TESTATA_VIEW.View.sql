USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RIAMMISSIONE_OFFERTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[RIAMMISSIONE_OFFERTA_TESTATA_VIEW] as

select 
	C.id,
	C.IdPfu,
	C.idPfuInCharge,
	C.Titolo,
	C.TipoDoc,
	C.Protocollo,
	C.DataInvio,
	C.StatoFunzionale,
	C.Body,
	C.SIGN_ATTACH,
	C.NumeroDocumento,
	C.DataDocumento,
	C.Azienda,
	DB.CIG,
	DB.CUP,
	DB.NumeroIndizione,
	DB.DataIndizione,
	CV.value as USERRUP,
	B.Body as Oggetto,
	B.Protocollo as ProtocolloRiferimento,
	B.Fascicolo,
	CV1.Value as Azi_Dest
	from CTL_DOC C with(NOLOCK)
		inner join ctl_doc B with(NOLOCK) on B.id=C.LinkedDoc
		inner join Document_Bando DB with(NOLOCK) on DB.idHeader=C.LinkedDoc
		left join CTL_DOC_Value CV with(NOLOCK) on CV.idHeader=C.LinkedDoc and CV.DSE_ID='InfoTec_comune' and CV.DZT_Name='USERRUP' and CV.Row=0
		left join CTL_DOC_Value CV1 with(NOLOCK) on CV1.idHeader=C.id and CV1.DSE_ID='FORNITORE' and CV1.DZT_Name='AZI_Dest' and CV1.Row=0 
	where C.TipoDoc='RIAMMISSIONE_OFFERTA'


GO
