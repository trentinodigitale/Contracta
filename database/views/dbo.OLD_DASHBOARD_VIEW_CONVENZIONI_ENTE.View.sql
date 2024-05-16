USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_CONVENZIONI_ENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_CONVENZIONI_ENTE]
AS

	-- Versione=1&data=2016-01-04&Attvita=98642&Nominativo=Federico 

	--CONVENZIONI CON QUOTE LE VEDONO GLI UTENTI DEGLI ENTI CON LE QUOTE
	SELECT 
		 C1.*
		 , c1.titolo as DOC_Name
		 , c1.protocollo as Protocol
		 , PU.Idpfu as Owner
		 , DC.id             AS Convenzione
		 , DC.IdentificativoIniziativa
		 , dc.TipoImporto
		 , DC.Macro_Convenzione as Macro_Convenzione_Filtro
		 , Dc.NumOrd
		 , AZI_Dest
		 , 'CONVENZIONE_ENTE' as OPEN_DOC_NAME

		,DC.TotaleOrdinato
		,DC.ReferenteFornitore
		,DC.DataInizio 
		,DC.DataFine
		,DC.DescrizioneIniziativa
		,DC.DataStipulaConvenzione
		,DC.Pagamento
		,DC.Valuta 
		,DC.Total 
		,DC.Completo
		,isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 ) as BDG_TOT_Residuo
		,DC.CIG_MADRE
		,DC.TipoConvenzione
		,DC.ConAccessori
		,DC.ImportoMinimoOrdinativo
		,DC.OrdinativiIntegrativi
		,DC.TipoScadenzaOrdinativo
		,DC.NumeroMesi
		,DC.DataScadenzaOrdinativo
		,year(DC.DataInizio) as Anno_inizio_convenzione
		,DC.Macro_Convenzione
		, case DC.Total
			when 0 then null
			else (DC.TotaleOrdinato/DC.Total)*100 
		  end	as PercErosione
		, year (DC.DataInizio) as AnnoPubConvenzione
		, year (dc.datafine) as AnnoScadConvenzione

		,DC.Ambito
		,DC.StatoContratto
		,DC.statoListino
		,dc.datadirittooblio
	  FROM CTL_DOC C1 with(nolock)
			INNER JOIN Document_Convenzione DC  with(nolock) ON C1.id=DC.id
			INNER JOIN ProfiliUtente PU  with(nolock) on PU.pfuvenditore=0 --on PU.idpfu=C1.Idpfu
			INNER JOIN aziende with(nolock) on idazi=PU.pfuidazi 
			INNER JOIN Document_Convenzione_Quote_Importo CQ with(nolock) on CQ.idHeader = C1.id and CQ.Azienda = PU.pfuidazi
	 WHERE C1.TipoDoc='CONVENZIONE' and C1.StatoFunzionale <> 'InLavorazione'
			AND DC.StatoConvenzione = 'Pubblicato'
			AND DC.Deleted = 0 
			AND PU.pfudeleted=0
			AND DC.GestioneQuote<>'senzaquote'
			AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'
			AND ( isnull(DataDirittoOblio,'3000-01-01') > GETDATE() or SUBSTRING(PU.pfuFunzionalita,466,1)=1 )
	UNION ALL

	--CONVENZIONI SENZA QUOTE CON LISTA ENTI VUOTA LE VEDONO TUTTI GLI UTENTI DEGLI ENTI
	SELECT 
		C1.*
		 , c1.titolo as DOC_Name
		 , c1.protocollo as Protocol
		 , PU.Idpfu as Owner
		 , DC.id             AS Convenzione
		 , DC.IdentificativoIniziativa
		 , dc.TipoImporto
		 , DC.Macro_Convenzione as Macro_Convenzione_Filtro
		 , Dc.NumOrd
		 , AZI_Dest
		 , 'CONVENZIONE_ENTE' as OPEN_DOC_NAME

		,DC.TotaleOrdinato
		,DC.ReferenteFornitore
		,DC.DataInizio 
		,DC.DataFine
		,DC.DescrizioneIniziativa
		,DC.DataStipulaConvenzione
		,DC.Pagamento
		,DC.Valuta 
		,DC.Total 
		,DC.Completo
		,isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 ) as BDG_TOT_Residuo
		,DC.CIG_MADRE
		,DC.TipoConvenzione
		,DC.ConAccessori
		,DC.ImportoMinimoOrdinativo
		,DC.OrdinativiIntegrativi
		,DC.TipoScadenzaOrdinativo
		,DC.NumeroMesi
		,DC.DataScadenzaOrdinativo
		,year(DC.DataInizio) as Anno_inizio_convenzione
		,DC.Macro_Convenzione
		, case DC.Total
			when 0 then null
			else (DC.TotaleOrdinato/DC.Total)*100 
		  end	as PercErosione
		, year (DC.DataInizio) as AnnoPubConvenzione
		, year (dc.datafine) as AnnoScadConvenzione

		,DC.Ambito
		,DC.StatoContratto
		,DC.statoListino
		,dc.datadirittooblio
	  FROM CTL_DOC C1 with(nolock)
		INNER JOIN Document_Convenzione DC with(nolock) ON C1.id=DC.id
		INNER JOIN ProfiliUtente PU with(nolock) on PU.pfuvenditore=0 --PU.idpfu=C1.Idpfu
		INNER JOIN aziende with(nolock) on idazi=PU.pfuidazi 
		LEFT OUTER JOIN Document_Convenzione_Plant E with(nolock) on DC.ID=E.IdHeader and PU.pfuidazi=E.AZI_Ente 	
	 WHERE C1.TipoDoc='CONVENZIONE' and C1.StatoFunzionale <> 'InLavorazione'
		AND DC.StatoConvenzione = 'Pubblicato'
		AND DC.Deleted = 0 
		AND PU.pfudeleted=0
		AND DC.GestioneQuote='senzaquote'
		AND (select count(*) from Document_Convenzione_Plant where DC.ID=IdHeader)=0
		AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'
		AND ( isnull(DataDirittoOblio,'3000-01-01') > GETDATE() or SUBSTRING(PU.pfuFunzionalita,466,1)=1)

	UNION ALL

	--CONVENZIONI SENZA QUOTE CON LISTA ENTI PIENA LE VEDONO GLIUTENTI DEGLI ENTI NELLA LISTA
	SELECT 
		 C1.*
		 , c1.titolo as DOC_Name
		 , c1.protocollo as Protocol
		 , PU.Idpfu as Owner
		 , DC.id             AS Convenzione
		 , DC.IdentificativoIniziativa
		 , dc.TipoImporto
		 , DC.Macro_Convenzione as Macro_Convenzione_Filtro
		 , Dc.NumOrd
		 , AZI_Dest
		 , 'CONVENZIONE_ENTE' as OPEN_DOC_NAME

		,DC.TotaleOrdinato
		,DC.ReferenteFornitore
		,DC.DataInizio 
		,DC.DataFine
		,DC.DescrizioneIniziativa
		,DC.DataStipulaConvenzione
		,DC.Pagamento
		,DC.Valuta 
		,DC.Total 
		,DC.Completo
		,isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 ) as BDG_TOT_Residuo
		,DC.CIG_MADRE
		,DC.TipoConvenzione
		,DC.ConAccessori
		,DC.ImportoMinimoOrdinativo
		,DC.OrdinativiIntegrativi
		,DC.TipoScadenzaOrdinativo
		,DC.NumeroMesi
		,DC.DataScadenzaOrdinativo
		,year(DC.DataInizio) as Anno_inizio_convenzione
		,DC.Macro_Convenzione
		, case DC.Total
			when 0 then null
			else (DC.TotaleOrdinato/DC.Total)*100 
		  end	as PercErosione
		, year (DC.DataInizio) as AnnoPubConvenzione
		, year (dc.datafine) as AnnoScadConvenzione

		,DC.Ambito
		,DC.StatoContratto
		,DC.statoListino
		,dc.datadirittooblio
	  FROM CTL_DOC C1 with(nolock)
		INNER JOIN Document_Convenzione DC with(nolock) ON C1.id=DC.id
		INNER JOIN ProfiliUtente PU with(nolock) on PU.pfuvenditore=0 --PU --PU.idpfu=C1.Idpfu 
		INNER JOIN aziende with(nolock) on idazi=PU.pfuidazi 
		INNER JOIN Document_Convenzione_Plant E with(nolock) on DC.ID=E.IdHeader and PU.pfuidazi=E.AZI_Ente 	
	WHERE C1.TipoDoc='CONVENZIONE' and C1.StatoFunzionale <> 'InLavorazione'
			AND DC.StatoConvenzione = 'Pubblicato'
			AND DC.Deleted = 0 
			AND PU.pfudeleted=0
			AND DC.GestioneQuote='senzaquote'
			AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'
			AND ( isnull(DataDirittoOblio,'3000-01-01') > GETDATE() or SUBSTRING(PU.pfuFunzionalita,466,1)=1)



GO
