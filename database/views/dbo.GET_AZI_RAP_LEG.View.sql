USE [AFLink_TND]
GO
/****** Object:  View [dbo].[GET_AZI_RAP_LEG]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[GET_AZI_RAP_LEG] as 


	SELECT az.idAzi , --l'idazi è la chiave di ingresso su questa vista

			left( d1.vatValore_FV , 16 ) as CFTIM ,		-- Codice fiscale ALFANUMERICO (16) X 
			left( d2.vatValore_FV , 40 ) as COGTIM ,	-- Cognome ALFANUMERICO (40)  
			left( d3.vatValore_FV , 20 ) as NOMETIM		-- Nome ALFANUMERICO (20) 
		from aziende az with(nolock)
				inner join DM_Attributi d1 with(nolock) on d1.idApp = 1 and d1.lnk = az.idAzi and d1.dztNome = 'CFRapLeg'
				left join DM_Attributi d2 with(nolock) on d2.idApp = 1 and d2.lnk = az.idAzi and d2.dztNome = 'CognomeRapLeg'	
				left join DM_Attributi d3 with(nolock) on d3.idApp = 1 and d3.lnk = az.idAzi and d3.dztNome = 'NomeRapLeg'
		where d1.vatValore_FV <> ''

	UNION 	--Nel caso in cui l'OE è una persona fisica, non sarà presente in ADRIER in questo caso il CF dell'azienda è quello da usare come rappresentante legale. Con quel CF prendiamo l'utente collegato per recuperare nome e cognome.

	SELECT az.IdAzi,
			left( p.pfuCodiceFiscale , 16 ) as CFTIM ,
			left( p.pfuCognome , 40 ) as COGTIM ,
			left( p.pfunomeutente , 20 ) as NOMETIM
		from AZIENDE az with(nolock)
				inner join DM_Attributi dm1 with(nolock) on dm1.lnk = az.IdAzi and dm1.dztNome = 'codicefiscale' and dm1.idApp = 1
				inner join ProfiliUtente p with(nolock) on p.pfuIdAzi = az.IdAzi and p.pfuCodiceFiscale = dm1.vatValore_FT and p.pfuDeleted = 0
		where az.aziIdDscFormaSoc = 845577 --professionisti

GO
