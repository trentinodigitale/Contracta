USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_GARA_AQ_QUOTE_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_BANDO_GARA_AQ_QUOTE_TESTATA_VIEW] as
select
	C.[Id],
    C.[IdPfu], 
	C.[IdDoc], 
	C.[TipoDoc], 
	C.[StatoDoc], 
	C.[Data], 
	C.[Protocollo], 
	C.[PrevDoc], 
	C.[Deleted], 
	C.[Titolo], 
	C.[Body], 
	C.[DataInvio], 
	C.[ProtocolloRiferimento], 
	C.[ProtocolloGenerale], 
	C.[Fascicolo], 
	C.[Note], 
	C.[DataProtocolloGenerale], 
	C.[LinkedDoc], 
	C.[JumpCheck], 
	C.[StatoFunzionale], 
	C.[DataDocumento], 
	C.[Caption],
	C.Azienda,
	CIG,
	DataRiferimentoFine as Datascadenza,
	ImportoBaseAsta as total,
	TotaleOrdinato,
	ImportoBaseAsta - TotaleOrdinato as BDG_TOT_Residuo
from CTL_DOC C with(nolock)
	inner join Document_Bando AQ with(nolock) on AQ.idHeader=C.id
	left outer join (
						Select sum(ImportoQuota) as TotaleOrdinato,idHeader
							from CTL_DOC with(nolock)
								inner join Document_Convenzione_Quote_Importo with(nolock) on id = idheader
							where TipoDoc='BANDO_GARA' 
							group by (idHeader)

		) as AL2 on AL2.idHeader = C.id
	
GO
