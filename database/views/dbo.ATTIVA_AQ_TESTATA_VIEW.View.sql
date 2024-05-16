USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ATTIVA_AQ_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ATTIVA_AQ_TESTATA_VIEW] AS 
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
	C.[DataScadenza], 
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
	DB.CIG,
	B.Azienda 
	from CTL_DOC C with(NOLOCK) 
		inner join Document_Bando DB with(nolock) on DB.idHeader=C.LinkedDoc	
		inner join CTL_DOC B with(nolock) on DB.idHeader=B.id	
		where C.TipoDoc='ATTIVA_AQ'
		
		
		
		
GO
