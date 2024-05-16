USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_SCHEDA_ANAGRAFICA_IPA]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_SCHEDA_ANAGRAFICA_IPA] AS

	select a.IdAzi,
			dn.*,
			dn.ID_NOTIER as IDNOTIER,
			dn.ID_PEPPOL as PARTICIPANTID,
			case
				when dn.ID_IPA = 'CODICE_FISCALE' then ''
				else dn.ID_IPA
			end as CodiceIPA
		from aziende a with(Nolock)
				inner join DM_Attributi dm1 with(nolock) on dm1.lnk = a.IdAzi and dm1.dztNome = 'codicefiscale' and dm1.idApp = 1
				inner join Document_NoTIER_Destinatari dn with(nolock) on dn.piva_cf = dm1.vatValore_FT and dn.bDeleted = 0 and dn.ID_IPA <> ''

GO
