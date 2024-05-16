USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_Export_Listini_Prodotti]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[DASHBOARD_SP_VIEW_Export_Listini_Prodotti]
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

			--, case 
			--	when isnull(NumProd.num, 0) = 0 then lv.FabbisognoTotale --da vedere
			--	else lv.FabbisognoTotale / NumProd.Num				
			--  end as FabbisognoTotale
			, case 
				when coalesce(NumProd.num,NumProdN.num, 0) = 0 then lv.Quantita --da vedere
				else cast( lv.Quantita as float ) / cast( isnull( NumProd.Num ,NumProdN.Num ) as float ) 				
			  end as FabbisognoTotale

			, aziPda.aziPartitaIVA
			, aziPda.aziRagioneSociale
			, isnull( pag.DENOMINAZIONE_ARTICOLO_FORNITORE ,pa.DENOMINAZIONE_ARTICOLO_FORNITORE ) as DENOMINAZIONE_ARTICOLO_FORNITORE 
			--intervento
			,	case 
					when @nIsExcel = 1 then isnull(domTP.DMV_DescML,isnull( pag.Tipo_Prodotto, pa.Tipo_Prodotto))
					else isnull( pag.Tipo_Prodotto, pa.Tipo_Prodotto)
				end as Tipo_Prodotto
			--, pag.Tipo_Prodotto
			, isnull( pag.CODICE_ARTICOLO_FORNITORE , pa.CODICE_ARTICOLO_FORNITORE ) as CODICE_ARTICOLO_FORNITORE
			, isnull( pag.TIPOLOGIA_DM ,  pa.TIPOLOGIA_DM ) as  TIPOLOGIA_DM
			, isnull( pag.NumeroRepertorio ,pa.NumeroRepertorio ) as NumeroRepertorio 
			, isnull( pag.CODICE_CND , pa.CODICE_CND  ) as CODICE_CND 
			, isnull( pag.ClasseCE , pa.ClasseCE ) as ClasseCE
			, isnull( pag.CodiceAttribuitoFabbricante , pa.CodiceAttribuitoFabbricante ) as CodiceAttribuitoFabbricante
			, isnull( pag.NomeCommercialeModello , pa.NomeCommercialeModello ) as NomeCommercialeModello
			, isnull( pag.PartitaIVAFabbricante , pa.PartitaIVAFabbricante ) as PartitaIVAFabbricante
			, isnull( pag.RagioneSocialeFabbricante , pa.RagioneSocialeFabbricante ) as RagioneSocialeFabbricante
			, isnull( pag.UDIDI , pa.UDIDI ) as UDIDI 
			, isnull( pag.CODICE_EAN , pa.CODICE_EAN ) as CODICE_EAN
			, lv.CodiceATC 
			, lv.PrincipioAttivo 
			, isnull( pag.CodiceAIC , pa.CodiceAIC ) as CodiceAIC
			, isnull( pag.TipoMedicinale , pa.TipoMedicinale ) as TipoMedicinale
			, isnull( pag.IVA_PERC ,  pa.IVA_PERC ) as  IVA_PERC
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
			, isnull( pag.QuantitaMinimaGara , pa.QuantitaMinimaGara ) as QuantitaMinimaGara
			, po.PREZZO_OFFERTO_PER_UM 
			, isnull( pag.UnitadiMisuraAcquisto , pa.UnitadiMisuraAcquisto ) as UnitadiMisuraAcquisto
			, isnull( pag.PrezzoAcquistoIVAesclusa , pa.PrezzoAcquistoIVAesclusa ) as PrezzoAcquistoIVAesclusa
			, isnull( pag.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1 , pa.ULTERIORE_PERC_DI_SCONTO_FISSATA_DA_AIFA1  ) as PercSconto
			, NULL as PercentualeSconto2
			, NULL as PercentualeSconto3
			, isnull( pag.CONFEZIONAMENTO_PRIMARIO , pa.CONFEZIONAMENTO_PRIMARIO ) as CONFEZIONAMENTO_PRIMARIO
			, isnull( pag.ConfezionamentoSecondario , pa.ConfezionamentoSecondario  ) as ConfezionamentoSecondario 
			, isnull( pag.TipizzazioneProdotto , pa.TipizzazioneProdotto ) as TipizzazioneProdotto 
			, isnull( pag.Temperatura	, pa.Temperatura	 ) as Temperatura	
			, isnull( pag.MODALITA_DI_CONSERVAZIONE_DOM , pa.MODALITA_DI_CONSERVAZIONE_DOM ) as MODALITA_DI_CONSERVAZIONE_DOM
			, isnull( pag.ClassificazioneADR , pa.ClassificazioneADR ) as  ClassificazioneADR
			, isnull( pag.CodiceSmaltimento , pa.CodiceSmaltimento ) as CodiceSmaltimento
			, isnull( pag.VitaUtileReferenza , pa.VitaUtileReferenza ) as VitaUtileReferenza
			, isnull( pag.NoteABS , pa.NoteABS ) as NoteABS

			--nuove voci nel dizionario dei modelli di acquisto per il cliente ESTAR.
			, isnull( pag.DurataInMesi , pa.DurataInMesi ) as DurataInMesi
			, isnull( pag.NoteOE , pa.NoteOE ) as NoteOE
			, isnull( pag.PrezzoConfezionePrimaria , pa.PrezzoConfezionePrimaria ) as PrezzoConfezionePrimaria
			, isnull( pag.QuantitaUMOfferta , pa.QuantitaUMOfferta ) as QuantitaUMOfferta
			, isnull( pag.ScontoConfezioneMinimaVendita , pa.ScontoConfezioneMinimaVendita ) as ScontoConfezioneMinimaVendita 
			, isnull( pag.CodiceParafarmaco  , pa.CodiceParafarmaco ) as CodiceParafarmaco
			, isnull( pag.NumeroLottoESTAR , pa.NumeroLottoESTAR ) as NumeroLottoESTAR 
			, isnull( pag.PrezzoPubblicoConfezione , pa.PrezzoPubblicoConfezione  ) as PrezzoPubblicoConfezione 
			, isnull( pag.PrezzoExfactoryConfezione , pa.PrezzoExfactoryConfezione ) as PrezzoExfactoryConfezione 
			, isnull(  pag.PrezzoPubblicoUnitario , pa.PrezzoPubblicoUnitario  ) as PrezzoPubblicoUnitario 
			, isnull( pag.PrezzoExfactoryUnitario , pa.PrezzoExfactoryUnitario ) as PrezzoExfactoryUnitario 
			, isnull( pag.ScontoPrezzoPubblico , pa.ScontoPrezzoPubblico ) as ScontoPrezzoPubblico 
			, isnull( pag.ScontoPrezzoExfactory , pa.ScontoPrezzoExfactory ) as ScontoPrezzoExfactory 
			, isnull( pag.ScontoNonInLineaCalcolatiAutomaticamente , pa.ScontoNonInLineaCalcolatiAutomaticamente ) as ScontoNonInLineaCalcolatiAutomaticamente 
			, isnull( pag.RiferimentoScontoForzato , pa.RiferimentoScontoForzato ) as RiferimentoScontoForzato 
			, isnull( pag.MotivazioneScontoForzato , pa.MotivazioneScontoForzato  ) as MotivazioneScontoForzato 
			, isnull( pag.ProdottoEsclusivo , pa.ProdottoEsclusivo  ) as ProdottoEsclusivo  
			, isnull( pag.PrezzoSecretato , pa.PrezzoSecretato  ) as PrezzoSecretato 
			, isnull( pag.ATCDiDettaglio , pa.ATCDiDettaglio ) as ATCDiDettaglio 
			, isnull( pag.PresenzaDMConnessiAlProdotto , pa.PresenzaDMConnessiAlProdotto  ) as PresenzaDMConnessiAlProdotto 
			, isnull( pag.PresenzaLattice , pa.PresenzaLattice  ) as PresenzaLattice 
			, isnull( pag.TracciatoDMDedicati , pa.TracciatoDMDedicati  ) as TracciatoDMDedicati 

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

			--azienda che ha fatto l'offerta
			INNER JOIN aziende aziPda WITH (NOLOCK) on aziPda.idazi = pda.idAziPartecipante


			-- prodotto offerto
			inner join Document_MicroLotti_Dettagli po WITH (NOLOCK) on pda.idrow = po.IdHeader and po.TipoDoc = 'PDA_OFFERTE' and isnull(lb.NumeroLotto, '1') = isnull(po.NumeroLotto, '1') and ( lv.numeroriga = po.NumeroRiga or lv.voce = po.voce )		



			--------------------------------------------
			----- VECCHIO DOCUMENTO DI AMPIEZZA GAMMA
			--------------------------------------------

			--offerta ampiezza di gamma
			left join ctl_doc as ag WITH (NOLOCK) on pda.IdMsg = ag.LinkedDoc and ag.TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' 
				and ag.VersioneLinkedDoc =	case 
												when db.divisione_lotti = '0'  then '1-' + cast(isnull(lv.numeroriga, '1') as varchar)
												else lv.NumeroLotto + '-' + cast(isnull(lv.Voce, '1') as varchar) 
											end
			--prodotti offerta ampiezza di gamma
			left join Document_MicroLotti_Dettagli as pag WITH (NOLOCK) on pag.IdHeader = ag.Id and pag.TipoDoc = ag.TipoDoc

			--numero di righe prodotti presenti sul documento di offerta ampiezza di gamma
			left join(select IdHeader, count(*) as Num from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' group by IdHeader) as NumProd on NumProd.IdHeader = ag.Id 



			--------------------------------------------
			----- NUOVO DOCUMENTO DI AMPIEZZA GAMMA
			--------------------------------------------

			left join Document_MicroLotti_Dettagli pa WITH (NOLOCK) on pa.IdHeader = pda.IdMsg and pa.TipoDoc = 'OFFERTA_AMPIEZZA' and isnull(lb.NumeroLotto, '1') = isnull(pa.NumeroLotto, '1') and ( lv.numeroriga = pa.NumeroRiga or lv.voce = pa.voce )		

			--numero di righe prodotti presenti sul documento di offerta ampiezza di gamma
			left join( select IdHeader, isnull(NumeroLotto, '1') as NumeroLotto, isnull( voce , NumeroRiga) as Voce  , count(*) as Num 
							from Document_MicroLotti_Dettagli with(nolock) 
							where TipoDoc = 'OFFERTA_AMPIEZZA' 
							group by IdHeader, isnull(NumeroLotto, '1') , isnull( voce , NumeroRiga)
							
						)  as NumProdN on NumProdN.IdHeader =  pda.IdMsg  and isnull(lb.NumeroLotto, '1') = NumProdN.NumeroLotto and ( lv.numeroriga = NumProdN.Voce or lv.voce = NumProdN.Voce )		



		

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
