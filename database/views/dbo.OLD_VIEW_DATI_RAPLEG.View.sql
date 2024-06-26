USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_DATI_RAPLEG]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_VIEW_DATI_RAPLEG] AS
	select  a.idAzi,
			b.vatValore_FT as CognomeRapLeg,
			c.vatValore_FT as NomeRapLeg,
			d.vatValore_FT as CFRapLeg,
			e.vatValore_FT as LocalitaRapLeg,
			f.vatValore_FT as DataRapLeg,
			g.vatValore_FT as ResidenzaRapLeg,
			h.vatValore_FT as IndResidenzaRapLeg
		from aziende a with(nolock)
				left join dm_attributi b with(nolock) ON b.lnk = a.IdAzi and b.dztNome = 'CognomeRapLeg'
				left join dm_attributi c with(nolock) ON c.lnk = a.IdAzi and c.dztNome = 'NomeRapLeg'
				left join dm_attributi d with(nolock) ON d.lnk = a.IdAzi and d.dztNome = 'CFRapLeg'
				left join dm_attributi e with(nolock) ON e.lnk = a.IdAzi and e.dztNome = 'LocalitaRapLeg'
				left join dm_attributi f with(nolock) ON f.lnk = a.IdAzi and f.dztNome = 'DataRapLeg'
				left join dm_attributi g with(nolock) ON g.lnk = a.IdAzi and g.dztNome = 'ResidenzaRapLeg'
				left join dm_attributi h with(nolock) ON h.lnk = a.IdAzi and h.dztNome = 'IndResidenzaRapLeg'

	
	
GO
