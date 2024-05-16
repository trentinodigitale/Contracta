USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_REGISTRAZIONE_FORNITORE_GETDATA_FROM_EXTSERVICE_BY_CF]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_VIEW_REGISTRAZIONE_FORNITORE_GETDATA_FROM_EXTSERVICE_BY_CF] as

	SELECT 
	d.id, 
	d.IdPfu,
	d.GUID,
	da.codicefiscale,
	da.aziPartitaIVA

	FROM CTL_DOC d with (nolock)
		INNER JOIN Document_Aziende da with (nolock) ON (d.id = da.idHeader)
	WHERE d.TipoDoc = 'REGISTRAZIONE_FORNITORE'

GO
