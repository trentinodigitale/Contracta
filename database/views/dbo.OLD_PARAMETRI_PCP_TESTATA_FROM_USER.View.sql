USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_PCP_TESTATA_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_PARAMETRI_PCP_TESTATA_FROM_USER] as


	select
		idpfu as ID_FROM,
		c.kid as URL_CLIENT , 
		c.ClientId as VersioneLinkedDoc ,
		a.CodicePiattaformaAnac as NumeroDocumento
		,a.PRIVATE_KEY as Body
	from profiliUtente u with(nolock)
		cross join PDND_Contesti c with(nolock)
		cross join PDND_Dati_ANAC a with(nolock)
		
	

GO
