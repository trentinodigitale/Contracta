USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PARAMETRI_PCP_DETTAGLI_FROM_USER]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_PARAMETRI_PCP_DETTAGLI_FROM_USER] as


	select
		idpfu as ID_FROM,
		c.idcontesti as IdRow , 
		c.nomeContesto as Descrizione , 
		c.PurposeId as PCP_PurposeID , 
		c.BaseAddress as PCP_BaseAddress
	from 
		PDND_Contesti c
		cross join profiliUtente
	

GO
