USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AQ_ABILITAZIONE_RILANCIO_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AQ_ABILITAZIONE_RILANCIO_TESTATA_VIEW]  AS
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
	C.SIGN_ATTACH,
	C.SIGN_HASH,
	C.SIGN_LOCK,
	CIG,
	AQ.Protocollo as protocolloriferimento,
	AQ.Body as BodyContratto,
	P.pfuCodiceFiscale as codicefiscale,
	D.Value as RUP
	from CTL_DOC C with(nolock)
		inner join Document_Bando DB with(nolock) on DB.idHeader=C.LinkedDoc
		inner join CTL_DOC AQ with(nolock) on AQ.Id=DB.idHeader
		inner join CTL_DOC_VALUE d  on AQ.id = d.idheader and DSE_ID='InfoTec_comune' and DZT_Name = 'UserRUP' 
		inner join ProfiliUtente P with(nolock) on P.IdPfu=C.IdPfu
	where C.TipoDoc='AQ_ABILITAZIONE_RILANCIO'
GO
