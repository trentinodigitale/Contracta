USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_VIEW_Export_Listini_Prodotti]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD2_DASHBOARD_SP_VIEW_Export_Listini_Prodotti]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output,
 @nIsExcel						int = 0
)
as
begin
	
	set nocount on
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_Export_Listini_Prodotti' , 'V',  @AttrName  ,  @AttrValue ,  @AttrOp )

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
		
		--griglia
		, REPLACE(REPLACE(CAST(d.Body AS VARCHAR(150)), ';', ' '), CHAR(13) + CHAR(10), '')	 AS Oggetto
		, case when db.Divisione_lotti = '0' then '1' else lb.NumeroLotto end as NumeroLotto
		, lv.Descrizione as DescrizioneLotto
		
		-- estrazione
		--, db.cig as CIG_MADRE
		, case	
				when db.Divisione_lotti = '0' then db.cig
				else lb.CIG 
		  end as CIG_MADRE

		, lv.Descrizione as DescrizioneLottoGara
		, lb.NumeroLotto as Lotto

		, case 
			when isnull(NumProd.num, 0) = 0 then lv.FabbisognoTotale --da vedere
			else lv.FabbisognoTotale / NumProd.Num				
		  end as FabbisognoTotale

		, aziPda.aziPartitaIVA
		, aziPda.aziRagioneSociale
		, pag.DENOMINAZIONE_ARTICOLO_FORNITORE 
		--intervento
		,	case 
				when @nIsExcel = 1 then isnull(domTP.DMV_DescML,pag.Tipo_Prodotto)
				else pag.Tipo_Prodotto
			end as Tipo_Prodotto
		--, pag.Tipo_Prodotto
		, pag.CODICE_ARTICOLO_FORNITORE 
		, pag.TIPOLOGIA_DM
		, pag.NumeroRepertorio 
		, pag.CODICE_CND 
		, pag.ClasseCE
		, pag.CodiceAttribuitoFabbricante
		, pag.NomeCommercialeModello
		, pag.PartitaIVAFabbricante
		, pag.RagioneSocialeFabbricante
		, pag.UDIDI 
		, pag.CODICE_EAN
		, pag.CodiceATC 
		, lv.PrincipioAttivo 
		, pag.CodiceAIC
		, pag.TipoMedicinale
		, pag.IVA_PERC
		--intervento
		--,	case 
		--		when  @AttrOp = '' then isnull(domUM.DMV_DescML,lv.UnitadiMisura)
		--		else lv.UnitadiMisura
		--	end as UnitadiMisura

		,case
				when @nIsExcel = 1 then isnull(domUM.DMV_DescML,lv.UnitadiMisura)
				else lv.UnitadiMisura
		end as UnitadiMisura

		--, lv.UnitadiMisura
		, pag.QuantitaMinimaGara
		, po.PREZZO_OFFERTO_PER_UM 
		, pag.UnitadiMisuraAcquisto
		, pag.PrezzoAcquistoIVAesclusa
		, pag.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1 as PercSconto
		, NULL as PercentualeSconto2
		, NULL as PercentualeSconto3
		, pag.CONFEZIONAMENTO_PRIMARIO
		, pag.ConfezionamentoSecondario 
		, pag.TipizzazioneProdotto
		, pag.Temperatura	
		, pag.MODALITA_DI_CONSERVAZIONE_DOM
		, pag.ClassificazioneADR
		, pag.CodiceSmaltimento
		, pag.VitaUtileReferenza
		, pag.NoteABS

		--nuove voci nel dizionario dei modelli di acquisto per il cliente ESTAR.
		, pag.DurataInMesi
		, pag.NoteOE
		, pag.PrezzoConfezionePrimaria
		, pag.QuantitaUMOfferta
		, pag.ScontoConfezioneMinimaVendita 
		, pag.CodiceParafarmaco  
		, pag.NumeroLottoESTAR 
		, pag.PrezzoPubblicoConfezione 
		, pag.PrezzoExfactoryConfezione 
		, pag.PrezzoPubblicoUnitario 
		, pag.PrezzoExfactoryUnitario 
		, pag.ScontoPrezzoPubblico 
		, pag.ScontoPrezzoExfactory 
		, pag.ScontoNonInLineaCalcolatiAutomaticamente 
		, pag.RiferimentoScontoForzato 
		, pag.MotivazioneScontoForzato 
		, pag.ProdottoEsclusivo 
		, pag.PrezzoSecretato 
		, pag.ATCDiDettaglio 
		, pag.PresenzaDMConnessiAlProdotto 
		, pag.PresenzaLattice 
		, pag.TracciatoDMDedicati 

		--campi compilabili
		, NULL as CodiceProdotto
		, NULL as NumeroAtto
		, NULL as Anno
		, NULL as ProtocolloContratto
		, NULL as SottocodiceContratto
		, NULL as CONTRATTO
		, NULL as CIG_Derivato
		, NULL as DATA_INIZIO_PERIODO_VALIDITA 
		, NULL as DATA_FINE_PERIODO_VALIDITA
		, NULL as TipoAtto
		, NULL as AnnoMese
		, NULL as DescrizioneAtto
		, NULL as Notes

		, NULL as ProdottiPredecessori
		, NULL as PercentualeVitaUtileMinima
		, NULL as ValoreObiettivoDelParametroQualità
		, NULL as PesoPercentualeDelParametroQualità
		, NULL as ValoreObiettivoDelParametroLogistica
		, NULL as PesoPercentualeDelParametroLogistica
		, NULL as ValoreObiettivoDelParametroUrgenze
		, NULL as PesoPercentualeDelParametroUrgenze
		, NULL as TempoConsegnaSTANDARDcontrattualizzato
		, NULL as TempoConsegnaURGENZEcontrattualizzato
		, NULL as ApplicazionePenaliContratto
		, NULL as ApplicazionePenaliRidotte50Percento
		, NULL as PeriodicitàCalcoloVendorRating

	into #TemplistaProdotti		
	from CTL_DOC d WITH (NOLOCK) --bando_gara
		--info bando_gara
		INNER JOIN Document_Bando db WITH (NOLOCK) on d.id = db.idheader
		--lotti bando_gara 
		inner join Document_MicroLotti_Dettagli lb WITH (NOLOCK) on d.Id = lb.IdHeader and d.TipoDoc = lb.TipoDoc and (lb.Voce = 0 or lb.NumeroRiga = 0)
		--sublotti bando_gara 
		inner join Document_MicroLotti_Dettagli lv WITH (NOLOCK) on d.Id = lv.IdHeader and d.TipoDoc = lv.TipoDoc and isnull(lb.NumeroLotto, '1') = isnull(lv.NumeroLotto, '1')	and lv.AmpiezzaGamma = '1'		
		--documento pda
		inner join CTL_DOC as dpda WITH (NOLOCK) on dpda.LinkedDoc = d.id and dpda.Deleted = 0 and dpda.TipoDoc = 'PDA_MICROLOTTI'
		--offerte pda
		inner join Document_PDA_OFFERTE as pda WITH (NOLOCK) on pda.IdHeader = dpda.Id

		-- prodotto offerto
		inner join Document_MicroLotti_Dettagli po WITH (NOLOCK) on pda.idrow = po.IdHeader and po.TipoDoc = 'PDA_OFFERTE' and isnull(lb.NumeroLotto, '1') = isnull(po.NumeroLotto, '1') and ( lv.numeroriga = po.NumeroRiga or lv.voce = po.voce )		


		--azienda che ha fatto l'offerta
		INNER JOIN aziende aziPda WITH (NOLOCK) on aziPda.idazi = pda.idAziPartecipante
		--offerta ampiezza di gamma
		left join ctl_doc as ag WITH (NOLOCK) on pda.IdMsg = ag.LinkedDoc and ag.TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' 
			and ag.VersioneLinkedDoc =	case 
											when db.divisione_lotti = '0'  then '1-' + cast(isnull(lv.numeroriga, '1') as varchar)
											else lv.NumeroLotto + '-' + cast(isnull(lv.Voce, '1') as varchar) 
										end
		--prodotti offerta ampiezza di gamma
		left join Document_MicroLotti_Dettagli as pag WITH (NOLOCK) on pag.IdHeader = ag.Id and pag.TipoDoc = ag.TipoDoc
		--numero di righe prodotti presenti sul documento di offerta ampiezza di gamma
		left outer join(select IdHeader, count(*) as Num from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' group by IdHeader) as NumProd on NumProd.IdHeader = ag.Id 
		
		--intervento
		--mi acquisisco la descrizione del campo del dominio UnitadiMisura
		left join (
				select dmv_cod, dmv_descml
					from lib_domainvalues with(nolock)
					where dmv_dm_id ='A_UM' and dmv_Father like '%BASE%' 
				   ) as domUM on domUM.dmv_cod = lv.UnitadiMisura
		--mi acquisisco la descrizione del campo del dominio tipo_prodotto
		left join (
				select dmv_cod, dmv_descml
					from lib_domainvalues with(nolock)
					where dmv_dm_id ='tipo_prodotto'
				   ) as domTP on domTP.dmv_cod = pag.Tipo_Prodotto
	where
		d.TipoDoc in ('BANDO_GARA','BANDO_SEMPLIFICATO','BANDO_CONCORSO') and
		d.Deleted = 0 and
		d.StatoFunzionale not in  ('InLavorazione','Rifiutato','InApprove') and 
		(getdate() >= db.DataScadenzaOfferta)
		and db.tipobandogara not in ('4','5') -- per escludere gli avvisi dell'AFFIDAMENTO DIRETTO A DUE FASI

	
	set @SQLCmd =  'select * from 
						#TemplistaProdotti where 1 = 1 '
	
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and  ' + @SQLWhere

	if 	@Filter <> ''
		set   @SQLCmd = @SQLCmd +  ' and  ' + @Filter 
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort

	--print @SQLCmd

	exec (@SQLCmd)

	

end 


GO
