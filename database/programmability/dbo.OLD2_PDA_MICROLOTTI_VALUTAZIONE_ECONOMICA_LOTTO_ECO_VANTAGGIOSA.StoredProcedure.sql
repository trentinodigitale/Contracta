USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_ECO_VANTAGGIOSA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE proc [dbo].[OLD2_PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_ECO_VANTAGGIOSA] ( @idDoc int , @IdPFU int ) as
BEGIN

	--declare @idDoc int
	--declare @IdPFU as Int 
	
	--set @idDoc = 109512  
	--set @idPfu = 42727  

	declare @Debug int
	set @Debug = 0

	declare @IdLotto as Int 
	declare @IdPDA as Int 
	declare @IdCom as Int 
	declare @pfuIdLng as Int 
	declare @Allegato as Varchar(255) 
	declare @StatoRiga as Varchar(255) 
	declare @NumeroLotto as Varchar(255) 
	declare @Max float

	declare @idBando int
	declare @Criterio as varchar(100)
	declare @TipoDoc as varchar(100)
	declare @Fascicolo as varchar(100)

	declare @ListaModelliMicrolotti as varchar(500)
	declare @FormulaEconomica as nvarchar (max)
	declare @strSql as nvarchar (max)
	declare @strSqlExec as nvarchar (max)

	declare @FormulaEcoSDA as nvarchar (max)
	declare @MAX_PunteggioTecnico		float
	declare @MAX_PunteggioEconomico		float
	declare @ValoreEconomico			float
	declare @OffertaMigliore			float
	declare @PunteggioTecMin			float
	declare @Coefficiente_X				float
	declare @alfa						float

	declare @NumeroDecimali				varchar(20)
	declare @FieldBaseAsta				varchar(200)
	declare @FieldQuantita				varchar(200)


	declare @Valore_Offerta				float
	declare @Media_Valori_Offerti		float
	declare @Massimo_Valore_Offerta		float
	declare @Minimo_Valore_Offerta		float

	declare @Media_Sconti_Offerti		float
	declare @Massimo_Sconto_Offerta		float
	declare @Minimo_Sconto_Offerta		float
	declare @ScontoMigliore				float	
	declare @ScontoOfferto				float


	declare @Media_Ribassi_Offerti		float
	declare @Massimo_Ribasso_Offerta	float
	declare @Minimo_Ribasso_Offerta		float
	declare @ValoreEconomicoBaseAsta	float
	declare @NumeroOfferte				float
	declare @ValoreRibasso				float
	declare @ValoreSconto				float
	

					
	declare @idOfferta					int
	declare @idHeaderLotto				int
	 
	declare @MultiVoce					int
	declare @Versione					varchar(50)

	declare @idRow_V					int
	declare @AttributoBase				varchar(500)
	
	declare @PunteggioECO_TipoRip		varchar(50)
	
	declare @CriterioAggiudicazioneGara varchar(50)
	declare @bEffettuaArrotondamento    int
	set @bEffettuaArrotondamento = 1

	--set @IdDoc=<ID_DOC> --47998--48294--
	--set @IdPFU=<ID_USER> --35774--

	select @IdPDA = idheader , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where id = @IdDoc
	
	-- determino se il lotto è a voci multiple
	set @MultiVoce = 0
	if exists( select id from Document_MicroLotti_Dettagli  with(nolock)  where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 )
		set @MultiVoce = 1


	-- recupero la vesrione della gara
	select @idBando = idheader , @Versione = isnull( B.Versione  , '' )
		from CTL_DOC P  with(nolock) 
			inner join CTL_DOC B  with(nolock)  on B.id = P.Linkeddoc --Bando
			inner join document_bando G  with(nolock)  on G.idheader = B.id
		where P.id = @IdPDA


	-- se la gara ha una versione >= 2 si valutano le N formule
	if @Versione >= '2'
	begin

		if @Debug = 1 print 'Nuona Versione'
		
		-- recupero il criterio di valutazione  del lotto, serve ad evitare gli arrotondamenti dei punteggi per le gare al prezzo
		select 	
				@CriterioAggiudicazioneGara = CriterioAggiudicazioneGara ,
				@PunteggioECO_TipoRip=PunteggioECO_TipoRip
			from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where  idBando = @idBando and N_Lotto = @NumeroLotto
		if @CriterioAggiudicazioneGara in ( '15531' /*Prezzo*/  )
		begin
			set @bEffettuaArrotondamento = 0
		end


		select O.id as idLO into #allOFF
			from Document_PDA_OFFERTE d  with(nolock) 
				inner join Document_MicroLotti_Dettagli O  with(nolock)  on  d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.NumeroLotto	= @NumeroLotto and O.voce = 0 
			where d.IdHeader = @IdPDA

		-- si vuotano i valori prima di effettuare i calcoli
		update O
			set O.ValoreOfferta =  null 
			from Document_MicroLotti_Dettagli O  
				inner join #allOFF on id = idLO 




		--select @PunteggioECO_TipoRip = Value from CTL_DOC_Value where idheader = @idBando and DZT_Name = 'PunteggioECO_TipoRip' and DSE_ID = 'CRITERI_ECO_TESTATA'

		-- per ogni offerta si calcola il valore economico
		exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO   @idDoc , @IdPFU 

		create table #TempValori ( idLO int , IdMSG int , C_Base_Asta float , ValoreImportoLotto float , ValoreRibasso float , ValoreSconto float ,valoreOfferto float )
		create table #TempValutaz ( idRowVal  int )

		-- determina se i criteri di valutazione economica sono ripartiti per lotto e li colleziona in una tabella temporanea
		if exists(select d.id from Document_MicroLotti_Dettagli d  with(nolock) 
						inner join Document_Microlotto_Valutazione_ECO v  with(nolock)  on v.TipoDoc = 'LOTTO' and v.idHeader = d.id
							where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) 
							and d.idheader = @idBando  
							and NumeroLotto = @NumeroLotto and Voce = 0
				 )
		begin
			insert into #TempValutaz ( idRowVal ) 
				select v.idRow as idRowValutazione 
					from Document_MicroLotti_Dettagli d   with(nolock) 
						inner join Document_Microlotto_Valutazione_ECO v  with(nolock)  on v.TipoDoc = 'LOTTO' and v.idHeader = d.id

						where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) 
							and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0
						order by v.idRow
		end
		else
		begin
			insert into #TempValutaz ( idRowVal )
				select d.idRow as idRowValutazione 
					from Document_Microlotto_Valutazione_ECO d   with(nolock) 
					where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando 
					order by d.idRow
		end
		
		-----------------------------------------------------------
		-- per ogni formula determina il punteggio da attribuire
		-----------------------------------------------------------
		declare crs_F cursor static for 
				select  idRow, PunteggioMax,  dbo.GetPos( AttributoBase , '.' , 2 ) , dbo.GetPos( AttributoValore , '.' , 2 ) , isnull( Coefficiente_X , 0 ) , FormulaEcoSDA, FormulaEconomica, CriterioFormulazioneOfferte , isnull(alfa,0)
					from #TempValutaz 
						inner join Document_Microlotto_Valutazione_ECO  with(nolock)  on idRowVal = idRow
					--where FormulaEcoSDA <> 'Valutazione soggettiva' --Evito la valutazione delle formule "Valutazione soggettiva"
						-- NON posso escludere la valutazione soggettiva altrimenti non farei la ri parametrazione
					order by idRowVal

		open crs_F 

		declare @AttributoValore				varchar(500)
		declare @SQLCalcoloValori				nvarchar(max)
		declare @CriterioFormulazioneOfferte	varchar(50)

		fetch next from crs_F into @idRow_V, @MAX_PunteggioEconomico, @AttributoBase, @AttributoValore, @Coefficiente_X, @FormulaEcoSDA, @FormulaEconomica, @CriterioFormulazioneOfferte ,@alfa
		while @@fetch_status=0 
		begin 




			IF @FormulaEcoSDA <> 'Valutazione soggettiva'
			BEGIN

				if isnull( @AttributoBase , '' ) = ''
					set @AttributoBase = @AttributoValore						 
										  

				-----------------------------------------------------------
				-- recupera i valori del criterio economico da porre a valutazione
				-----------------------------------------------------------
				truncate table #TempValori


				
				if @CriterioFormulazioneOfferte = '15536' --prezzo
					set @SQLCalcoloValori = 
							'insert into #TempValori ( idLO , IdMSG , C_Base_Asta , ValoreImportoLotto , ValoreRibasso , ValoreSconto , ValoreOfferto )
							
							select O.Id as idLO , d.IdMSG , isnull(cast( P.' + @AttributoBase + ' as float ),0) as C_Base_Asta , isnull(cast ( O.' + @AttributoValore + ' as float),0) as ValoreImportoLotto ,   isnull(cast(P.' + @AttributoBase + ' as float) ,0) -  isnull(cast( O.' + @AttributoValore + ' as float) ,0) as ValoreRibasso , case when cast(P.' + @AttributoBase + ' as float) = 0 then 0 else 100 - isnull( ((  isnull(cast( O.' + @AttributoValore + ' as float) ,0) /  cast(P.' + @AttributoBase + ' as float) ) * 100),0) end as  ValoreSconto , isnull( cast ( O.' + @AttributoValore + ' as float) ,0) as valoreOfferto

								from Document_MicroLotti_Dettagli P  with(nolock) 
									inner join Document_PDA_OFFERTE d  with(nolock)  on d.idheader = p.idheader
									inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = ''PDA_OFFERTE'' and O.statoRiga in (''Valutato'' ,''ValutatoECO'', ''Conforme'' ,  ''verificasuperata'' , '''' ) and P.NumeroLotto = O.NumeroLotto
									where  
										P.ID = ' + cast( @IdDoc as varchar(30)) + ' and O.Voce = 0'
				else --offerta in percentuale percentuale
					set @SQLCalcoloValori = 
							'insert into #TempValori ( idLO , IdMSG , C_Base_Asta , ValoreImportoLotto , ValoreRibasso , ValoreSconto , ValoreOfferto)
							
							select O.Id as idLO , d.IdMSG , isnull(cast( P.' + @AttributoBase + ' as float ),0) as C_Base_Asta , isnull( cast ( P.' + @AttributoBase + ' as float ),0) - ( ( isnull(cast ( O.' + @AttributoValore + ' as float ),0) * isnull(cast ( P.' + @AttributoBase + ' as float ),0) ) / 100 ) as ValoreImportoLotto ,  ( ( isnull(cast ( O.' + @AttributoValore + ' as float ),0) * isnull(cast ( P.' + @AttributoBase + ' as float ),0) ) / 100 ) as ValoreRibasso ,  isnull(cast ( O.' + @AttributoValore + ' as float ),0)  as  ValoreSconto , isnull( cast( O.' + @AttributoValore + ' as float) ,0) as valoreOfferto
								from Document_MicroLotti_Dettagli P  with(nolock) 
									inner join Document_PDA_OFFERTE d  with(nolock)  on d.idheader = p.idheader
									inner join Document_MicroLotti_Dettagli O  with(nolock)  on d.idRow = O.idheader and O.TipoDoc = ''PDA_OFFERTE'' and O.statoRiga in (''Valutato'',''ValutatoECO'' , ''Conforme'' ,  ''verificasuperata'' , '''' ) and P.NumeroLotto = O.NumeroLotto								where  
										P.ID = ' + cast( @IdDoc as varchar(30)) + ' and O.Voce = 0'
		



				exec ( @SQLCalcoloValori ) 
				if @Debug = 1 print @SQLCalcoloValori

				-- si recuperano le informazioni di valutazione : punteggio eco , attributo base asta, attributo da confrontare, se prezzo  o perc. ecc..
				select @OffertaMigliore = min(O.ValoreImportoLotto )

						,@Media_Valori_Offerti = sum(O.ValoreImportoLotto ) / count(*)
						,@Massimo_Valore_Offerta = max(O.ValoreImportoLotto )
						,@Minimo_Valore_Offerta = min(O.ValoreImportoLotto )

						,@Media_Sconti_Offerti = sum(O.ValoreSconto ) / count(*)
						,@Massimo_Sconto_Offerta = max(O.ValoreSconto )
						,@Minimo_Sconto_Offerta = min(O.ValoreSconto )

						,@Media_Ribassi_Offerti = sum(O.ValoreRibasso ) / count(*)
						,@Massimo_Ribasso_Offerta = max(O.ValoreRibasso )
						,@Minimo_Ribasso_Offerta = min(O.ValoreRibasso )

						,@ScontoMigliore= max(O.ValoreSconto )
						,@ValoreEconomicoBaseAsta = sum(O.C_Base_Asta ) / count(*)
					
						,@NumeroOfferte = count (*) 

	
						from #TempValori O

				if @Debug = 1 print 'calcolato variabili'

				----------------------------------------------------------
				-- per ogni fornitore calcolo il punteggio  relativo al lotto della iesima formula
				----------------------------------------------------------
				declare crs cursor static for 
						select idLO ,  ValoreImportoLotto
							from  #TempValori 


				open crs 
				fetch next from crs into @IdLotto , @ValoreEconomico
				while @@fetch_status=0 
				begin 

						if @Debug = 1 print 'Formula - [' + isnull( @FormulaEcoSDA , '' )  + ']'

						-- seguo il calcolo del punteggio totale
						set @strSql = ' ' + @FormulaEcoSDA + ' '
						--print @strSql 
						--SET @strSql = REPLACE( @strSql , ' Media Valori Offerti ' , '  cast( ' + str( @Media_Valori_Offerti ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Massimo Valore Offerta ' , '  cast( ' + str( @Massimo_Valore_Offerta ,40 ,20 ) + ' as float ) ' )
						--SET @strSql = REPLACE( @strSql , ' Minimo Valore Offerta ' , '  cast( ' + str( @Minimo_Valore_Offerta ,40 ,20 ) + ' as float )  ' )


						--SET @strSql = REPLACE( @strSql , ' Coefficiente X ' , ' cast( ' + str( @Coefficiente_X ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Alfa ' , ' cast( ' + str( @alfa ,40 ,20 ) + ' as float )  ' )

				

						--SET @strSql = REPLACE( @strSql , ' Punteggio ' , ' cast( ' + str( @MAX_PunteggioEconomico ,40 ,20 ) + ' as float )  ' )

						--SET @strSql = REPLACE( @strSql , ' Offerta Migliore ' , '  cast( ' + str( @OffertaMigliore ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Offerta Corrente ' , '  cast( ' + str( @ValoreEconomico ,40 ,20 ) + ' as float )  ' )

						--SET @strSql = REPLACE( @strSql , ' Valore Offerta ' , '  cast( ' + str( @ValoreEconomico ,40 ,20 ) + ' as float )  ' )


						--SET @strSql = REPLACE( @strSql , ' Sconto Corrente ' , '  ValoreSconto  ' )
						--SET @strSql = REPLACE( @strSql , ' Massimo Sconto Offerto ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Sconto Offerto ' , '  ValoreSconto ' )
						--SET @strSql = REPLACE( @strSql , ' Sconto Migliore ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Sconto Peggiore ' , '  cast( ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Media Sconti Offerti ' , '  cast( ' + str( @Media_Sconti_Offerti ,40 ,20 ) + ' as float )  ' )


						--SET @strSql = REPLACE( @strSql , ' Ribasso Corrente ' , '  ValoreRibasso  ' )
						--SET @strSql = REPLACE( @strSql , ' Massimo Ribasso Offerto ' , '  cast( ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Ribasso Offerto ' , '  ValoreRibasso ' )
						--SET @strSql = REPLACE( @strSql , ' Ribasso Migliore ' , '  cast( ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Ribasso Peggiore ' , '  cast( ' + str( @Minimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
						--SET @strSql = REPLACE( @strSql , ' Media Ribassi Offerti ' , '  cast( ' + str( @Media_Ribassi_Offerti ,40 ,20 ) + ' as float )  ' )

						--SET @strSql = REPLACE( @strSql , ' Valore Base Asta ' , '  cast( ' + str( @ValoreEconomicoBaseAsta ,40 ,20 ) + ' as float )  ' )

						--SET @strSql = REPLACE( @strSql , ' Numero Offerte ' , '  cast( ' + str( @NumeroOfferte ,40 ,20 ) + ' as float )  ' )
						
						SET @strSql = REPLACE( @strSql , ' Media Valori Offerti ' , ' ' + str( @Media_Valori_Offerti ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Massimo Valore Offerta ' , ' ' + str( @Massimo_Valore_Offerta ,40 ,20 ) + ' ' )
						SET @strSql = REPLACE( @strSql , ' Minimo Valore Offerta ' , ' ' + str( @Minimo_Valore_Offerta ,40 ,20 ) + '  ' )


					
						SET @strSql = REPLACE( @strSql , ' Coefficiente X ' , ' ' + str( @Coefficiente_X ,40 ,20 ) + '  ' )
																																				
						SET @strSql = REPLACE( @strSql , ' Alfa ' , ' ' + str( @alfa ,40 ,20 ) + '  ' )

				
																																			

						SET @strSql = REPLACE( @strSql , ' Punteggio ' , ' ' + str( @MAX_PunteggioEconomico ,40 ,20 ) + '  ' )

						SET @strSql = REPLACE( @strSql , ' Offerta Migliore ' , ' ' + str( @OffertaMigliore ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Offerta Corrente ' , ' ' + str( @ValoreEconomico ,40 ,20 ) + '  ' )

						SET @strSql = REPLACE( @strSql , ' Valore Offerta ' , ' ' + str( @ValoreEconomico ,40 ,20 ) + '  ' )


						SET @strSql = REPLACE( @strSql , ' Sconto Corrente ' , '  ValoreSconto  ' )
						
						SET @strSql = REPLACE( @strSql , ' Massimo Sconto Offerto ' , ' ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Sconto Offerto ' , '  ValoreSconto ' )
						
						SET @strSql = REPLACE( @strSql , ' Sconto Migliore ' , ' ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Sconto Peggiore ' , ' ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Media Sconti Offerti ' , ' ' + str( @Media_Sconti_Offerti ,40 ,20 ) + '  ' )


						SET @strSql = REPLACE( @strSql , ' Ribasso Corrente ' , '  ValoreRibasso  ' )
						
						SET @strSql = REPLACE( @strSql , ' Massimo Ribasso Offerto ' , ' ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Ribasso Offerto ' , '  ValoreRibasso ' )
						
						SET @strSql = REPLACE( @strSql , ' Ribasso Migliore ' , ' ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Ribasso Peggiore ' , ' ' + str( @Minimo_Ribasso_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Media Ribassi Offerti ' , ' ' + str( @Media_Ribassi_Offerti ,40 ,20 ) + '  ' )

						SET @strSql = REPLACE( @strSql , ' Valore Base Asta ' , ' ' + str( @ValoreEconomicoBaseAsta ,40 ,20 ) + '  ' )

						SET @strSql = REPLACE( @strSql , ' Numero Offerte ' , ' ' + str( @NumeroOfferte ,40 ,20 ) + '  ' )
				
						
						-- PERCENTUALI
						SET @strSql = REPLACE( @strSql , ' Percentuale Corrente ' , '  ValoreSconto  ' )
						--SET @strSql = REPLACE( @strSql , ' Massima Percentuale Offerta ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
						SET @strSql = REPLACE( @strSql , ' Massima Percentuale Offerta ' , ' ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + '  ' )
						SET @strSql = REPLACE( @strSql , ' Minima Percentuale Offerta ' , ' ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + ' ' )
						SET @strSql = REPLACE( @strSql , ' Percentuale Offerta ' , '  ValoreSconto ' )
						--SET @strSql = REPLACE( @strSql , ' Percentuale Migliore ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
						SET @strSql = REPLACE( @strSql , ' Percentuale Migliore ' , ' ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + '  ' )
						--SET @strSql = REPLACE( @strSql , ' Percentuale Peggiore ' , '  cast( ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
						SET @strSql = REPLACE( @strSql , ' Percentuale Peggiore ' , ' ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + ' ' )

						--SET @strSql = REPLACE( @strSql , ' Media Percentuali Offerte ' , '  cast( ' + str( @Media_Sconti_Offerti ,40 ,20 ) + ' as float )  ' )
						SET @strSql = REPLACE( @strSql , ' Media Percentuali Offerte ' , ' ' + str( @Media_Sconti_Offerti ,40 ,20 ) + ' ' )
						
						SET @strSql = REPLACE( @strSql , ' SE VERO CHE ' , ' case when ' )
						SET @strSql = REPLACE( @strSql , ' ALLORA ' , ' then ' )
						SET @strSql = REPLACE( @strSql , ' ALTRIMENTI ' , ' else ' )
						SET @strSql = REPLACE( @strSql , ' POTENZA ' , ' Power ' )

						if CHARINDEX ( ' case when ' , @strSql ) > 0 
						begin
							if CHARINDEX ( ' POI ' , @strSql ) > 0 
							begin
								SET @strSql = REPLACE( @strSql , ' POI ' , ' end ' )
							end
							else
							begin
								SET @strSql =  @strSql + ' end '
							end
						end 


						if @Debug = 1 print 'Formula - [' + isnull( @strSql , '' )  + ']'
						--select * from  Document_Microlotto_PunteggioLotto_ECO
						--inizializzo il punteggio a zero (0)
						set @strSqlExec =  'Update 
							Document_Microlotto_PunteggioLotto_ECO
							set Punteggio = 0 
							from Document_Microlotto_PunteggioLotto_ECO
								inner join  #TempValori t  on idHeaderLottoOff = idLO
							where idHeaderLottoOff = ' + cast( @IdLotto as varchar(30)) + '
								and idRowValutazione   = ' + cast( @idRow_V as varchar(20))

						exec ( @strSqlExec )
						if @Debug = 1 print @strSqlExec

						----LO INSERISCO PER PREVENIRE GLI ERRORI DI divide-by-zero error.  			
						BEGIN TRY  							
							-- seguo il calcolo del punteggio totale
							set @strSqlExec =  'Update 
								Document_Microlotto_PunteggioLotto_ECO
							
								set Punteggio = ( dbo.AF_PARSER( replace(  
											replace(''' + @strSql + ''' ,''ValoreSconto'',str(ValoreSconto,40,20) ) 
										,''ValoreRibasso'',str(valoreribasso,40,20) ) )  )

								from Document_Microlotto_PunteggioLotto_ECO
									inner join  #TempValori on idHeaderLottoOff = idLO
								where idHeaderLottoOff = ' + cast( @IdLotto as varchar(30)) + '
									and idRowValutazione   = ' + cast( @idRow_V as varchar(20))

							exec ( @strSqlExec )
						END TRY  
						BEGIN CATCH  						

								Update Document_MicroLotti_Dettagli	set 
									EsitoRiga = 'Uno dei criteri della valutazione economica ha generato eccezione, verificare la formula applicata'
								where tipodoc =  'PDA_OFFERTE' 
									and Id = @IdLotto 
							
						END CATCH; 

						if @Debug = 1 print @strSqlExec


						if @MAX_PunteggioEconomico > 0
						BEGIN
							
							-- CALCOLO IL COEFFICIENTE
							update Document_Microlotto_PunteggioLotto_ECO
									SET giudizio = punteggio / @MAX_PunteggioEconomico
								where idHeaderLottoOff = @IdLotto and idRowValutazione = @idRow_V 

						END



						if @bEffettuaArrotondamento = 1 
						begin

							update Document_Microlotto_PunteggioLotto_ECO
									SET punteggio = dbo.AFS_ROUND ( punteggio , 2 )
								where idHeaderLottoOff = @IdLotto and idRowValutazione = @idRow_V 

							--set @strSqlExec =  'Update 
							--	Document_Microlotto_PunteggioLotto_ECO
							
							--	'
							
							--	+ 'set Punteggio = round( dbo.AF_PARSER( replace(  
							--				replace(''' + @strSql + ''' ,''ValoreSconto'',str(ValoreSconto,40,20) ) 
							--		  ,''ValoreRibasso'',str(valoreribasso,40,20) ) ) , 2 )

							--	from Document_Microlotto_PunteggioLotto_ECO
							--		inner join  #TempValori on idHeaderLottoOff = idLO
							--	where idHeaderLottoOff = ' + cast( @IdLotto as varchar(30)) + '
							--		and idRowValutazione   = ' + cast( @idRow_V as varchar(20))

						end







					fetch next from crs into @IdLotto , @ValoreEconomico

				end 
				close crs 
				deallocate crs

			END -- fine IF evitare calcolo su formula 'valutazione soggettiva'
			else
			begin

				truncate table #TempValori
				
				set @SQLCalcoloValori = 
							'insert into #TempValori ( idLO  ,valoreOfferto )
							select O.Id as idLO , ' +  case when @AttributoValore = '' then ' 0 ' else ' isnull(O.' + @AttributoValore + ',0) as valoreOfferto ' end + '
								from Document_MicroLotti_Dettagli P  with(nolock) 
									inner join Document_PDA_OFFERTE d  with(nolock)  on d.idheader = p.idheader
									inner join Document_MicroLotti_Dettagli O  with(nolock)  on d.idRow = O.idheader and O.TipoDoc = ''PDA_OFFERTE'' and O.statoRiga in (''Valutato'' ,''ValutatoECO'', ''Conforme'' ,  ''verificasuperata'' , '''' ) and P.NumeroLotto = O.NumeroLotto
									where  
										P.ID = ' + cast( @IdDoc as varchar(30)) + ' and O.Voce = 0'
		

				exec ( @SQLCalcoloValori ) 
				if @Debug = 1 print @SQLCalcoloValori

			end

			-- si riparametra per formula se richiesto
			if @PunteggioECO_TipoRip in ( 'Criterio' , 'CriterioETotale' )
			begin

				SELECT @Max = max(Punteggio )
					from Document_Microlotto_PunteggioLotto_ECO 
					where idRowValutazione = @idRow_V 
						and idHeaderLottoOff in ( select  idLO  from  #TempValori )

				update Document_Microlotto_PunteggioLotto_ECO
					set PunteggioRiparametrato = ( Punteggio / @Max ) * @MAX_PunteggioEconomico ,
						PunteggioOriginale = Punteggio 
					where idRowValutazione = @idRow_V 
						and idHeaderLottoOff in ( select  idLO  from  #TempValori )

				update Document_Microlotto_PunteggioLotto_ECO
					set Punteggio = PunteggioRiparametrato
					where idRowValutazione = @idRow_V 
						and idHeaderLottoOff in ( select  idLO  from  #TempValori )
			end
			
			
			-- riporto sulla riga di valutazione il valore inserito dall'OE nell'offerta
			update O
					set ValoreOfferto = t.ValoreOfferto
				from Document_Microlotto_PunteggioLotto_ECO O
					inner join  #TempValori t on idHeaderLottoOff = idLO
					where idRowValutazione = @idRow_V 
						
			

			-- si passa alla formula successiva
			fetch next from crs_F into @idRow_V, @MAX_PunteggioEconomico, @AttributoBase, @AttributoValore, @Coefficiente_X, @FormulaEcoSDA, @FormulaEconomica, @CriterioFormulazioneOfferte ,@alfa 

		end 
		close crs_F 
		deallocate crs_F



		-- si calcola il punteggio totale e si riporta sul lotto 
		update O
			set O.ValoreOfferta =  str( P.Punteggio ,20 , 10 ),
				O.PunteggioEconomicoAssegnato =  P.PunteggioEconomicoAssegnato
			from Document_MicroLotti_Dettagli O
				inner join ( select sum( Punteggio ) as Punteggio , sum( PunteggioOriginale ) as PunteggioEconomicoAssegnato  , idHeaderLottoOff
								from Document_Microlotto_PunteggioLotto_ECO
									inner join #TempValori on idHeaderLottoOff = idLO 
								group by  idHeaderLottoOff
							) as P on P.idHeaderLottoOff = O.id

		
		-- si riparametra se richiesto
		if @PunteggioECO_TipoRip in ( 'PunteggioTotale' , 'CriterioETotale' )
		begin

			-- prendo i criteri specializzati sul lotto se presenti
			select @MAX_PunteggioEconomico = PunteggioEconomico
				from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and N_Lotto = @NumeroLotto 
			
			select @Max = max( cast( O.ValoreOfferta as float ) )
				from Document_MicroLotti_Dettagli O  with(nolock) 
					inner join #TempValori on id = idLO 
			update O
				set O.ValoreOfferta =str( ( cast( ValoreOfferta as float ) / @Max ) * @MAX_PunteggioEconomico ,20 , 10 )
				from Document_MicroLotti_Dettagli O
					inner join #TempValori on id = idLO 

		end



		---- si aggiunge il punteggio tecnico
		--update O
		--	set O.ValoreOfferta =  str( round(  isnull( cast( ValoreOfferta as float ) , 0 )  , 2 ) + PunteggioTecnico ,20 , 10 )
		--	from Document_MicroLotti_Dettagli O
		--		inner join #TempValori on id = idLO 


		---- si aggiunge il punteggio tecnico
		if @bEffettuaArrotondamento = 1 
		begin

			update O
				--set O.ValoreOfferta =  str( round(  isnull( cast( o.ValoreOfferta as float ) , 0 )  , 2 ) + --o.PunteggioTecnico ,20 , 10 )
				set O.ValoreOfferta =  str( dbo.AFS_ROUND(  isnull( cast( o.ValoreOfferta as float ) , 0 )  , 2 ) + isnull( o.PunteggioTecnico , 0 ) ,20 , 10 )
				from Document_MicroLotti_Dettagli O
					inner join #allOFF on id = idLO 
				where O.statoRiga in ('Valutato' ,'ValutatoECO', 'Conforme' ,  'verificasuperata' , '' ) 

		end
		else
		begin

			update O
				--set O.ValoreOfferta =  str( round(  isnull( cast( o.ValoreOfferta as float ) , 0 )  , 2 ) + --o.PunteggioTecnico ,20 , 10 )
				set O.ValoreOfferta =  str( (  isnull( cast( o.ValoreOfferta as float ) , 0 ) ) + isnull( o.PunteggioTecnico , 0 ) ,20 , 10 )
				from Document_MicroLotti_Dettagli O
					inner join #allOFF on id = idLO 
				where O.statoRiga in ('Valutato' ,'ValutatoECO', 'Conforme' ,  'verificasuperata' , '' ) 

		end



		drop table #TempValori
		drop table #TempValutaz
		drop table #allOFF
	end
	else
	begin

		-- determino il criterio di calcolo economico definito sulla gara
		select  @TipoDoc = o.TipoDoc , @Criterio = b.criterioformulazioneofferte , @ListaModelliMicrolotti = b.TipoBando
				, @MAX_PunteggioEconomico = v1.Value
				, @MAX_PunteggioTecnico   = v2.Value
				, @FormulaEcoSDA          = v3.Value
				, @PunteggioTecMin		  = v4.Value
				, @Coefficiente_X		  = v5.Value
				, @NumeroDecimali		  = isnull( b.NumDec , 5 )
				, @IdPDA = p.idheader
				, @idBando = o.LinkedDoc
			FROM Document_MicroLotti_Dettagli P
				inner join ctl_doc o on p.idheader = o.id
				inner join dbo.Document_Bando b on o.LinkedDoc = b.idHeader
				inner join CTL_DOC_VALUE  v1 on v1.idheader = b.idHeader and v1.DSE_ID = 'CRITERI_ECO' and  v1.DZT_Name = 'PunteggioEconomico'
				inner join CTL_DOC_VALUE  v2 on v2.idheader = b.idHeader and v2.DSE_ID = 'CRITERI_ECO' and  v2.DZT_Name = 'PunteggioTecnico'
				inner join CTL_DOC_VALUE  v3 on v3.idheader = b.idHeader and v3.DSE_ID = 'CRITERI_ECO' and  v3.DZT_Name = 'FormulaEcoSDA'
				inner join CTL_DOC_VALUE  v4 on v4.idheader = b.idHeader and v4.DSE_ID = 'CRITERI_ECO' and  v4.DZT_Name = 'PunteggioTecMin'
				inner join CTL_DOC_VALUE  v5 on v5.idheader = b.idHeader and v5.DSE_ID = 'CRITERI_ECO' and  v5.DZT_Name = 'Coefficiente_X'

				where P.id= @IdDoc

		select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
			from Document_Modelli_MicroLotti_Formula  with(nolock) 
			where @Criterio = CriterioFormulazioneOfferte
				and @ListaModelliMicrolotti = Codice


		-- prendo i criteri specializzati sul lotto se presenti
		select @MAX_PunteggioEconomico = PunteggioEconomico
				, @MAX_PunteggioTecnico   = PunteggioTecnico
				, @FormulaEcoSDA          = FormulaEcoSDA
				, @PunteggioTecMin		  = PunteggioTecMin
				, @Coefficiente_X		  = Coefficiente_X
			from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and N_Lotto = @NumeroLotto 

	
		------------------------------------------------------------
		---- determino il valore economico dei lotti offerti
		------------------------------------------------------------
		exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO   @idDoc , @IdPFU 
	



		----------------------------------------------------------
		-- recupera i dati usati come parametri nelle formule
		----------------------------------------------------------
		select @OffertaMigliore = min(O.ValoreImportoLotto )

					,@Media_Valori_Offerti = sum(O.ValoreImportoLotto ) / count(*)
					,@Massimo_Valore_Offerta = max(O.ValoreImportoLotto )
					,@Minimo_Valore_Offerta = min(O.ValoreImportoLotto )

					,@Media_Sconti_Offerti = sum(O.ValoreSconto ) / count(*)
					,@Massimo_Sconto_Offerta = max(O.ValoreSconto )
					,@Minimo_Sconto_Offerta = min(O.ValoreSconto )

					,@Media_Ribassi_Offerti = sum(O.ValoreRibasso ) / count(*)
					,@Massimo_Ribasso_Offerta = max(O.ValoreRibasso )
					,@Minimo_Ribasso_Offerta = min(O.ValoreRibasso )

					,@ScontoMigliore= max(O.ValoreSconto )

					,@NumeroOfferte = count (*) 

				from Document_MicroLotti_Dettagli P  with(nolock) 
					inner join Document_PDA_OFFERTE d  with(nolock)  on d.idheader = p.idheader
					inner join Document_MicroLotti_Dettagli O   with(nolock)  on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme' ,  'verificasuperata' , '' , 'ValutatoECO' ) and P.NumeroLotto = O.NumeroLotto
				where P.ID = @IdDoc and O.Voce = 0

		----------------------------------------------------------
		-- recupera la base asta dal lotto in gara
		----------------------------------------------------------
		select @ValoreEconomicoBaseAsta = ValoreImportoLotto
			from Document_MicroLotti_Dettagli P with(nolock) 
				where  P.ID = @IdDoc 

  
  
												
													
				
																										
				
		----------------------------------------------------------
		-- per ogni fornitore calcolo il punteggio finale relativo al lotto
		----------------------------------------------------------
		declare crs cursor static for 
				select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto , o.ValoreImportoLotto
					from Document_MicroLotti_Dettagli P  with(nolock) 
						inner join Document_PDA_OFFERTE d  with(nolock)  on d.idheader = p.idheader
						inner join Document_MicroLotti_Dettagli O  with(nolock)  on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme' , 'verificasuperata' , '' ,'ValutatoECO' ) and P.NumeroLotto = O.NumeroLotto
					where P.ID = @IdDoc  and O.voce = 0


		open crs 
		fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @ValoreEconomico
		while @@fetch_status=0 
		begin 

			IF @FormulaEcoSDA <> 'Valutazione soggettiva'
			BEGIN

				-- seguo il calcolo del punteggio totale
				set @strSql = ' ' + @FormulaEcoSDA + ' '
				--print @strSql 

				--SET @strSql = REPLACE( @strSql , ' Media Valori Offerti ' , '  cast( ' + str( @Media_Valori_Offerti ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Massimo Valore Offerta ' , '  cast( ' + str( @Massimo_Valore_Offerta ,40 ,20 ) + ' as float ) ' )
				--SET @strSql = REPLACE( @strSql , ' Minimo Valore Offerta ' , '  cast( ' + str( @Minimo_Valore_Offerta ,40 ,20 ) + ' as float )  ' )

				--SET @strSql = REPLACE( @strSql , ' Coefficiente X ' , ' cast( ' + str( @Coefficiente_X ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Punteggio ' , ' cast( ' + str( @MAX_PunteggioEconomico ,40 ,20 ) + ' as float )  ' )

				--SET @strSql = REPLACE( @strSql , ' Offerta Migliore ' , '  cast( ' + str( @OffertaMigliore ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Offerta Corrente ' , '  cast( ' + str( @ValoreEconomico ,40 ,20 ) + ' as float )  ' )

				--SET @strSql = REPLACE( @strSql , ' Valore Offerta ' , '  cast( ' + str( @ValoreEconomico ,40 ,20 ) + ' as float )  ' )


				--SET @strSql = REPLACE( @strSql , ' Sconto Corrente ' , '  ValoreSconto  ' )
				--SET @strSql = REPLACE( @strSql , ' Massimo Sconto Offerto ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Sconto Offerto ' , '  ValoreSconto ' )
				--SET @strSql = REPLACE( @strSql , ' Sconto Migliore ' , '  cast( ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Sconto Peggiore ' , '  cast( ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Media Sconti Offerti ' , '  cast( ' + str( @Media_Sconti_Offerti ,40 ,20 ) + ' as float )  ' )


				--SET @strSql = REPLACE( @strSql , ' Ribasso Corrente ' , '  ValoreRibasso  ' )
				--SET @strSql = REPLACE( @strSql , ' Massimo Ribasso Offerto ' , '  cast( ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Ribasso Offerto ' , '  ValoreRibasso ' )
				--SET @strSql = REPLACE( @strSql , ' Ribasso Migliore ' , '  cast( ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Ribasso Peggiore ' , '  cast( ' + str( @Minimo_Ribasso_Offerta ,40 ,20 ) + ' as float )  ' )
				--SET @strSql = REPLACE( @strSql , ' Media Ribassi Offerti ' , '  cast( ' + str( @Media_Ribassi_Offerti ,40 ,20 ) + ' as float )  ' )

				--SET @strSql = REPLACE( @strSql , ' Valore Base Asta ' , '  cast( ' + str( @ValoreEconomicoBaseAsta ,40 ,20 ) + ' as float )  ' )

				--SET @strSql = REPLACE( @strSql , ' Numero Offerte ' , '  cast( ' + str( @NumeroOfferte ,40 ,20 ) + ' as float )  ' )


				SET @strSql = REPLACE( @strSql , ' Media Valori Offerti ' , ' ' + str( @Media_Valori_Offerti ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Massimo Valore Offerta ' , ' ' + str( @Massimo_Valore_Offerta ,40 ,20 ) + ' ' )
				SET @strSql = REPLACE( @strSql , ' Minimo Valore Offerta ' , ' ' + str( @Minimo_Valore_Offerta ,40 ,20 ) + '  ' )

				SET @strSql = REPLACE( @strSql , ' Coefficiente X ' , ' ' + str( @Coefficiente_X ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Punteggio ' , ' ' + str( @MAX_PunteggioEconomico ,40 ,20 ) + '  ' )

				SET @strSql = REPLACE( @strSql , ' Offerta Migliore ' , ' ' + str( @OffertaMigliore ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Offerta Corrente ' , ' ' + str( @ValoreEconomico ,40 ,20 ) + '  ' )

				SET @strSql = REPLACE( @strSql , ' Valore Offerta ' , '   ' + str( @ValoreEconomico ,40 ,20 ) + '  ' )


				SET @strSql = REPLACE( @strSql , ' Sconto Corrente ' , '  ValoreSconto  ' )
				SET @strSql = REPLACE( @strSql , ' Massimo Sconto Offerto ' , '  ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Sconto Offerto ' , '  ValoreSconto ' )
				SET @strSql = REPLACE( @strSql , ' Sconto Migliore ' , '  ' + str( @Massimo_Sconto_Offerta ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Sconto Peggiore ' , '  ' + str( @Minimo_Sconto_Offerta ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Media Sconti Offerti ' , '  ' + str( @Media_Sconti_Offerti ,40 ,20 ) + '  ' )


				SET @strSql = REPLACE( @strSql , ' Ribasso Corrente ' , '  ValoreRibasso  ' )
				SET @strSql = REPLACE( @strSql , ' Massimo Ribasso Offerto ' , ' ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Ribasso Offerto ' , '  ValoreRibasso ' )
				SET @strSql = REPLACE( @strSql , ' Ribasso Migliore ' , ' ' + str( @Massimo_Ribasso_Offerta ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Ribasso Peggiore ' , '  ' + str( @Minimo_Ribasso_Offerta ,40 ,20 ) + '  ' )
				SET @strSql = REPLACE( @strSql , ' Media Ribassi Offerti ' , '  ' + str( @Media_Ribassi_Offerti ,40 ,20 ) + '  ' )

																																	

				SET @strSql = REPLACE( @strSql , ' Valore Base Asta ' , '  ' + str( @ValoreEconomicoBaseAsta ,40 ,20 ) + '  ' )

				SET @strSql = REPLACE( @strSql , ' Numero Offerte ' , ' ' + str( @NumeroOfferte ,40 ,20 ) + '  ' )

				SET @strSql = REPLACE( @strSql , ' SE VERO CHE ' , ' case when ' )
				SET @strSql = REPLACE( @strSql , ' ALLORA ' , ' then ' )
				SET @strSql = REPLACE( @strSql , ' ALTRIMENTI ' , ' else ' )
				SET @strSql = REPLACE( @strSql , ' POTENZA ' , ' Power ' )

				if CHARINDEX ( ' case when ' , @strSql ) > 0 
				begin
					if CHARINDEX ( ' POI ' , @strSql ) > 0 
					begin
						SET @strSql = REPLACE( @strSql , ' POI ' , ' end ' )
					end
					else
					begin
						SET @strSql =  @strSql + ' end '
					end
				end 

				-- seguo il calcolo del punteggio totale
				set @strSqlExec =  'Update 
					Document_MicroLotti_Dettagli
					set ValoreOfferta = str(  round( dbo.AF_PARSER( replace(  
								replace(''' + @strSql + ''' ,''ValoreSconto'',str(ValoreSconto,40,20) ) 
							,''ValoreRibasso'',str(valoreribasso,40,20) ) ) , 2 )
							   + PunteggioTecnico  , 30 , 20 ) 
					--set ValoreOfferta = str(  dbo.AFS_round( ( ' + @strSql + ' ) , 2 )   + isnull( PunteggioTecnico , 0 )  , 30 , 20 ) 
					where tipodoc = ''PDA_OFFERTE'' and 
					id  = ' + cast( @IdLotto as varchar(20))


				--print @strSqlExec
				exec ( @strSqlExec )

			END

			fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @ValoreEconomico
		end 
		close crs 
		deallocate crs

	end

	-- determina la graduatoria del lotto
	EXEC PDA_GRADUATORIA_LOTTO  @idPDA , @NumeroLotto 


END



































GO
