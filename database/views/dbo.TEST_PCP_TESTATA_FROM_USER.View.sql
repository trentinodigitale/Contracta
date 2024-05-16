USE [AFLink_TND]
GO
/****** Object:  View [dbo].[TEST_PCP_TESTATA_FROM_USER]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[TEST_PCP_TESTATA_FROM_USER] as


	select
		idpfu as ID_FROM,
		a.CodicePiattaformaAnac as VersioneLinkedDoc 

	from profiliUtente u with(nolock)
		cross join PDND_Dati_ANAC a with(nolock)
		
	

GO
