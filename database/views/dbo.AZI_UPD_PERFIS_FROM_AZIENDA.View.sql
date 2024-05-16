USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AZI_UPD_PERFIS_FROM_AZIENDA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AZI_UPD_PERFIS_FROM_AZIENDA]
AS
SELECT      dbo.Aziende.aziRagioneSociale, 
			dbo.Aziende.aziPartitaIVA, 
			dbo.Aziende.IdAzi, 
            dbo.Aziende.IdAzi AS ID_FROM,

		   DM_1.vatValore_FT AS LuogoEmissioneDocRic,
		   DM_2.vatValore_FT AS DocRilasciatoDa,
		   DM_3.vatValore_FT AS CognomePF,
		   DM_4.vatValore_FT AS NomePF,
		   DM_3.vatValore_FT AS CognomePF2,
		   DM_4.vatValore_FT AS NomePF2,
		   DM_5.vatValore_FT AS codicefiscale,
		   
		   dbo.GetDateValueAzi( Aziende.IdAzi , 'DataNascitaPF' ) AS DataNascitaPF,

		   DM_7.vatValore_FT AS SessoPF,
		   DM_8.vatValore_FT AS ComuneNascitaPF,
		   DM_9.vatValore_FT AS ProvinciaNascitaPF,
		   
		   DM_10.vatValore_FT AS TipoDocRiconoscimento,
		   DM_11.vatValore_FT AS NumeroDocRiconoscimento,

		   dbo.GetDateValueAzi( Aziende.IdAzi , 'DataEmissioneDocRic' ) AS DataEmissioneDocRic,
		   dbo.GetDateValueAzi( Aziende.IdAzi , 'DataScadenzaDocRic' ) AS DataScadenzaDocRic




FROM         dbo.Aziende 
LEFT OUTER JOIN DM_Attributi AS DM_1 ON Aziende.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'LuogoEmissioneDocRic'
LEFT OUTER JOIN DM_Attributi AS DM_2 ON Aziende.IdAzi = DM_2.lnk AND DM_2.idApp = 1 AND DM_2.dztNome = 'DocRilasciatoDa'
LEFT OUTER JOIN DM_Attributi AS DM_3 ON Aziende.IdAzi = DM_3.lnk AND DM_3.idApp = 1 AND DM_3.dztNome = 'CognomePF'
LEFT OUTER JOIN DM_Attributi AS DM_4 ON Aziende.IdAzi = DM_4.lnk AND DM_4.idApp = 1 AND DM_4.dztNome = 'NomePF'
LEFT OUTER JOIN DM_Attributi AS DM_5 ON Aziende.IdAzi = DM_5.lnk AND DM_5.idApp = 1 AND DM_5.dztNome = 'codicefiscale'

--LEFT OUTER JOIN DM_Attributi AS DM_6 ON Aziende.IdAzi = DM_6.lnk AND DM_6.idApp = 1 AND DM_6.dztNome = 'DataNascitaPF'
LEFT OUTER JOIN DM_Attributi AS DM_7 ON Aziende.IdAzi = DM_7.lnk AND DM_7.idApp = 1 AND DM_7.dztNome = 'SessoPF'
LEFT OUTER JOIN DM_Attributi AS DM_8 ON Aziende.IdAzi = DM_8.lnk AND DM_8.idApp = 1 AND DM_8.dztNome = 'ComuneNascitaPF'
LEFT OUTER JOIN DM_Attributi AS DM_9 ON Aziende.IdAzi = DM_9.lnk AND DM_9.idApp = 1 AND DM_9.dztNome = 'ProvinciaNascitaPF'

LEFT OUTER JOIN DM_Attributi AS DM_10 ON Aziende.IdAzi = DM_10.lnk AND DM_10.idApp = 1 AND DM_10.dztNome = 'TipoDocRiconoscimento'
LEFT OUTER JOIN DM_Attributi AS DM_11 ON Aziende.IdAzi = DM_11.lnk AND DM_11.idApp = 1 AND DM_11.dztNome = 'NumeroDocRiconoscimento'
--LEFT OUTER JOIN DM_Attributi AS DM_12 ON Aziende.IdAzi = DM_12.lnk AND DM_12.idApp = 1 AND DM_12.dztNome = 'DataEmissioneDocRic'
--LEFT OUTER JOIN DM_Attributi AS DM_13 ON Aziende.IdAzi = DM_13.lnk AND DM_13.idApp = 1 AND DM_13.dztNome = 'DataScadenzaDocRic'

GO
