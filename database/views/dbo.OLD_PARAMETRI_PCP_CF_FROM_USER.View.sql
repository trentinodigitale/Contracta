USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_PCP_CF_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[OLD_PARAMETRI_PCP_CF_FROM_USER] as


	select
		idpfu as ID_FROM,
		
		[PCP_regCodiceComponente]

	from profiliUtente u with(nolock)
		cross join PDND_Dati_ANAC a with(nolock)
GO
