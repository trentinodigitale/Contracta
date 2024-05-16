USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_CONVENZIONI_MONITORAGGIO_CONVENZIONI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_DASHBOARD_VIEW_CONVENZIONI_MONITORAGGIO_CONVENZIONI] as

	SELECT 
			C.id

			--	Registro di sistema Convenzione
			, C.Protocollo

			--•	Numero Convezione completa
			, DC.NumOrd
		
			--•	Convenzione completa
			, c.titolo

			--•	Stato
			, C.StatoFunzionale


			--•	Ragione sociale Fornitore
			, DC.Mandataria

			--•	CF Fornitore
			, dm.vatValore_FV as CodiceFiscale

			--•	Partita IVA Fornitore
			, az.aziPartitaIVA

			--•	Data inizio validità convenzione
			, dc.DataInizio

			--•	Data fine validità convenzione
			, dc.DataFine

			--•	Macro Convenzione
			, dc.Macro_Convenzione

			--•	Procedura ( gara ) 
			, B.Body

			--•	Numero gara
			, G.CIG  as NumeroGara


			--•	Registro di sistema procedura
			, B.Protocollo as ProtocolloRiferimento
		
			--•	Numero Lotto
			, l.NumeroLotto

			--•	CIG lotto
			, R.CIG

			--•	Importo lotto (Valore a base d'asta gara)
			, rl.ValoreImportoLotto
		
			--•	Importo lotto (Ripartizione valore per lotto)
			, l.importo


			--•	AREA MERCEOLOGICA
			--, Merceologia.value as Merceologia
			, DC.Merceologia

			--•	Importo originario convenzione
			, DC.TotalOrigine

			--•	Esteso (si/no)
			,  CASE 
					WHEN DC.TotalOrigine is null THEN 'no' 
					WHEN isnull(DC.Total,0) =isnull( DC.TotalOrigine,0) THEN 'no'
					WHEN isnull(DC.Total,0) <> isnull(DC.TotalOrigine,0) THEN 'si'
					ELSE 'no' 
				END as Estensioni

			, DC.Ambito
			--, Ambito.value as Ambito


	
		FROM ctl_doc c with(nolock) 
			inner join Document_Convenzione DC with(nolock) on C.id=DC.id	
			INNER JOIN AZIENDE az with(nolock) on az.idazi = DC.Mandataria
			inner join DM_Attributi dm with(nolock) on dm.lnk = az.IdAzi and dm.idApp = 1 and dm.dztNome = 'CodiceFiscale'
			inner join Document_Convenzione_Lotti l with(nolock) on l.idHeader = c.id

			inner join (
						 select distinct idheader , numerolotto , CIG 
							from document_microlotti_dettagli r with(nolock) 
							where r.tipodoc = 'convenzione' 
						 ) as R on R.idheader = c.id and r.NumeroLotto = l.NumeroLotto
					 

			--left join CTL_DOC_Value Merceologia with(nolock) ON Merceologia.IdHeader = c.id and Merceologia.dse_id = 'TESTATA_PRODOTTI' and Merceologia.DZT_Name = 'Merceologia' 
			--left join CTL_DOC_Value Ambito with(nolock) ON Ambito.IdHeader = c.id and Ambito.dse_id = 'TESTATA_PRODOTTI' and Ambito.DZT_Name = 'Ambito' 

			left join ctl_doc B with(nolock) on B.id = dc.idBando
			left join document_bando G with(nolock) on B.id = G.idHeader
			left join Document_MicroLotti_Dettagli rl with(nolock) on rl.IdHeader = b.id and b.TipoDoc = rl.TipoDoc and rl.NumeroLotto = l.NumeroLotto and rl.voce = '0' 



	where DC.Deleted = 0 and C.Deleted = 0 and C.tipodoc='CONVENZIONE'
			AND C.StatoFunzionale <> 'InLavorazione'
GO
