USE [AFLink_TND]
GO
/****** Object:  View [dbo].[notier_lista_aziende]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[notier_lista_aziende] as
	SELECT azi.aziRagioneSociale as ragSoc, azi.aziPartitaIVA as piva, dm1.vatValore_FT as pid,dm2.vatValore_FT as cf,ROW_NUMBER() OVER(ORDER BY azi.aziRagioneSociale ASC) as riga
		FROM aziende azi WITH (nolock)
			INNER JOIN dm_attributi dm1 WITH (nolock) ON dm1.lnk = azi.idazi
														 AND dm1.dztnome = 'PARTICIPANTID'
														 AND ISNULL(dm1.vatValore_FT , '') != '' 
			INNER JOIN dm_attributi dm2 WITH (nolock) ON dm2.lnk = azi.idazi
														 AND dm2.dztnome = 'codicefiscale'
														 AND ISNULL(dm2.vatValore_FT , '') != '' 
		where azi.aziDeleted = 0 
GO
