USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_Export_Listini_Prodotti]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_DASHBOARD_VIEW_Export_Listini_Prodotti]  as 

select 
		--filtro
		 d.Id as id
		, db.cig as NumeroGara
		, case	
				when db.Divisione_lotti = '0' then db.cig
				else lb.CIG 
		  end as cig
		, REPLACE(REPLACE(d.Titolo , ';', ' '), CHAR(13) + CHAR(10) , '')  AS NomeProcedura
		, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara, TipoBandoGara )  as DescTipoProcedura
		, aziPda.aziPartitaIVA as PIvaOperatoreEconomico

		, case
			when ro.StatoRiga IN ('AggiudicazioneDef') then 'si'
			else 'no'
		end as TuttiOperatoriEconomici
		
		--griglia
		, REPLACE(REPLACE(CAST(d.Body AS VARCHAR(150)), ';', ' '), CHAR(13) + CHAR(10), '')	 AS Oggetto
		, lb.NumeroLotto
		, lb.Descrizione as DescrizioneLotto
		
		

	from CTL_DOC d WITH (NOLOCK) --bando_gara
		--info bando_gara
		INNER JOIN Document_Bando db WITH (NOLOCK) on d.id = db.idheader
		--lotti bando_gara 
		inner join Document_MicroLotti_Dettagli lb WITH (NOLOCK) on d.Id = lb.IdHeader and d.TipoDoc = lb.TipoDoc and lb.Voce = 0 
		--sublotti bando_gara 
		inner join Document_MicroLotti_Dettagli lv WITH (NOLOCK) on d.Id = lv.IdHeader and d.TipoDoc = lv.TipoDoc and lb.NumeroLotto = lv.NumeroLotto  --and lv.AmpiezzaGamma = 1
		--documento pda
		inner join CTL_DOC as dpda WITH (NOLOCK) on dpda.LinkedDoc = d.id and dpda.Deleted = 0 and dpda.TipoDoc = 'PDA_MICROLOTTI'
		--offerte pda
		inner join Document_PDA_OFFERTE as pda WITH (NOLOCK) on pda.IdHeader = dpda.Id
		--lotti offerte
		inner join Document_MicroLotti_Dettagli ro WITH (NOLOCK) on ro.idHeader = pda.IdRow and ro.TipoDoc = 'PDA_OFFERTE' and lv.NumeroLotto = ro.NumeroLotto and lv.Voce = ro.Voce
		--azienda che ha fatto l'offerta
		INNER JOIN aziende aziPda WITH (NOLOCK) on aziPda.idazi = pda.idAziPartecipante
		--offerta ampiezza di gamma
		inner join ctl_doc as ag WITH (NOLOCK) on pda.IdMsg = ag.LinkedDoc and ag.TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' and ag.VersioneLinkedDoc = lv.NumeroLotto + '-' + cast(lv.Voce as varchar)
	where
		d.Deleted = 0 and
		d.StatoFunzionale not in  ('InLavorazione','Rifiutato','InApprove') and 
		(getdate() >= db.DataScadenzaOfferta)




GO
