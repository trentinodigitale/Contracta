USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AZI_UPD_SCHEDA_ANAGRAFICA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_AZI_UPD_SCHEDA_ANAGRAFICA] AS
    SELECT id as iddoc,
		 'I' as LNG,
		 aziRagioneSociale,
		 CONVERT(VARCHAR(10),aziDataCreazione,103) as DataOperazione,
		 CONVERT(VARCHAR(10),aziDataCreazione,108) as OrarioOperazione,
		 dbo.modifiche_scheda_anagrafica(idazi, Evidenzia,id ) as Variazioni
	   FROM Document_Aziende with(nolock)
			 





GO
