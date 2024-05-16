USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_TEST_PCP_TESTATA_FROM_USER]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_TEST_PCP_TESTATA_FROM_USER] as


	select
		idpfu as ID_FROM,
		a.CodicePiattaformaAnac as VersioneLinkedDoc 

	from profiliUtente u with(nolock)
		cross join PDND_Dati_ANAC a with(nolock)
		
	

GO
