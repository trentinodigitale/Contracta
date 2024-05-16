USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_VALUTAZIONE_TEC_ELAB_LOTTO_MINMAX]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE proc [dbo].[OLD_PDA_VALUTAZIONE_TEC_ELAB_LOTTO_MINMAX]( @idRowLottoOff int  )
as
begin

	declare @idRow				int 
	declare @i					int 
	declare @idPDA				int 

	declare @Formula			nvarchar(4000)
	declare @ValoreOfferta		float --nvarchar(4000)
	declare @AttributoCriterio	nvarchar(255)
	declare @Valori				nvarchar(255)
	declare @ValDom				nvarchar(255)
	declare @minimo				nvarchar(255)
	declare @massimo			nvarchar(255)
	declare @punteggio			float --nvarchar(255)
	declare @CriterioQuiz		varchar(50)
	declare @statmentSQL		varchar(4000)


	declare @NumeroLotto			varchar(50)
	declare @idHeaderLotto			int
	declare @VociMultiple			int
	declare @VociMultipleBase		int
	declare @idRowLottoOffVoce		int
	declare @fetch_status_voce		int
	declare @idBando				int
	declare @TipoDocBando			varchar(200)
	declare @idRowVoce				int
	declare @idHeaderOff			int
	declare @PesoVoce				float
	declare @PunteggioParziale		float
	declare @PunteggioMax			float
	declare @TipoGiudizioTecnico	varchar(50)
	declare @Voce	varchar(50)
	declare @divisione_lotti		varchar(50)
	

	declare @ValoreMassimo			float
	declare @ValoreMinimo			float
	
	declare @Vsogi varchar(50)

	declare @descError nvarchar(max)
	declare @errorNumber INT
	DECLARE @ErrorSeverity INT
    DECLARE @ErrorState INT
	
	select @NumeroLotto = o.NumeroLotto , @idHeaderLotto = o.idHeaderLotto , @idBando = d.linkedDoc 
			, @TipoDocBando = b.TipoDoc , @idHeaderOff = o.idHeader , @TipoGiudizioTecnico = isnull( TipoGiudizioTecnico , 'edit' )
			, @idPDA = d.id
			, @divisione_lotti = divisione_lotti
			from Document_MicroLotti_Dettagli o with(nolock)
				inner join Document_PDA_OFFERTE p with(nolock) on p.IdRow = o.idheader 
				inner join ctl_doc d with(nolock) on d.id = p.idheader
				inner join Ctl_Doc b with(nolock) on d.linkedDoc = b.id
				inner join Document_Bando ba with(nolock) on ba.idheader = b.id
				where o.Id = @idRowLottoOff



	set @VociMultipleBase = 0
	set @VociMultiple = 0
	-- se il lotto è a voci multiple si cicla sulle voci altrimenti la valutazione è diretta alla voce 0
	if exists( 	select NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where idHeaderLotto = @idHeaderLotto and TipoDoc = 'PDA_OFFERTE' and voce = 1 )
		set @VociMultipleBase = 1


	---------------------------------------------
	-- recupera il modello selezionato sul bando
	---------------------------------------------
	declare @IdDocModello int
	-- per il bando semplificato il modello si trova collegato allo SDA
	--if exists( select * from ctl_doc where tipodoc = 'BANDO_SEMPLIFICATO' and id = @idBando )
	--	select @IdDocModello = m.id from ctl_doc sem inner join ctl_doc m on m.linkedDoc = sem.linkedDoc and m.tipodoc = 'CONFIG_MODELLI_LOTTI' and m.deleted = 0 where sem.id = @idBando
	--else
		select @IdDocModello = id from ctl_doc with(nolock) where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando
	

	--per ogni punteggio oggettivo determina il valore in funzione dei dati inseriti
	--declare CrsLt cursor static for 
	declare CrsLt cursor fast_forward for  
		select p.idRow , Formula , AttributoCriterio , PunteggioMax 
			from Document_Microlotto_PunteggioLotto p with(nolock)
				inner join Document_Microlotto_Valutazione v with(nolock) on v.idRow = idRowValutazione and CriterioValutazione in ( 'quiz' )
				inner join LIB_Dictionary  with(nolock)on dbo.GetPos(AttributoCriterio, '.', 2 ) =  DZT_Name and DZT_Type = 2 -- solo gli attributi numerici
			where idHeaderLottoOff = @idRowLottoOff 
			order by v.idRow

	open CrsLt 
	fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax

	while @@fetch_status=0 
	begin 



		
		set @punteggio = '0'
		set @PunteggioParziale = 0 
		set @Voce = 0

		set @CriterioQuiz = dbo.GetPos(@Formula, '#=#', 2 )
		set @Valori		  = dbo.GetPos(@Formula, '#=#', 3 )

		
		set @AttributoCriterio = dbo.GetPos(@AttributoCriterio, '.', 2 )

		set @idRowLottoOffVoce = @idRowLottoOff


		-- La valutazione oggettiva deve essere fatta solo  min  max  rialzoMax  ribassoMax ,   domino e range sono fatte da altro processo
		IF @CriterioQuiz in  ( 'min' , 'max', 'rialzoMax', 'ribassoMax' )
		BEGIN

			-- determino per l'attributo se deve lavorare sulle voci o sul lotto
			--set @VociMultiple = 1
			 --dbo.ConditionLottoVoceModello( @IdDocModello , @AttributoCriterio , @divisione_lotti )
	 		set @VociMultiple = 0

			-- se è presente la riga zero allora la monolotto si gestisce come una lotti a voci
			if @Divisione_Lotti = '0' and  exists( select * from ctl_doc_value with(nolock) where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' ) 
				set @Divisione_Lotti = '1'

			if  @divisione_lotti = '0' -- per le gare senza lotti i dati sono presenti solo sulle righe
						or ( @VociMultipleBase = 1 and exists( 
													select  l.Value 
														from CTL_DOC_VALUE a with(nolock)
																inner join CTL_DOC_VALUE l  with(nolock) on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'
															where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @AttributoCriterio
																	and  l.Value = 'Voce' -- solo se è selezionato voce recupero i dati dalle voci altrimenti sempre dai lotti
												)
											)

			begin
				set @VociMultiple = 1
			end
		
			-- se il lotto è a voce per ogni voce viene determinato il punteggio e moltiplicato per il suo peso
			if @VociMultiple = 1
			begin

				declare CrsLtVoce cursor static for 
						select o.id , isnull( b.PesoVoce , 100 ) , isnull( b.Voce , b.numeroriga)
							from Document_MicroLotti_Dettagli o with(nolock)
								inner join Document_MicroLotti_Dettagli b  with(nolock) on b.idHeader = @idBando and b.TipoDoc = @TipoDocBando and o.NumeroLotto = isnull( b.NumeroLotto , '1' ) and o.Voce = isnull( b.Voce , b.numeroriga )  and isnull( o.variante , 0 ) = isnull( b.Variante , 0 ) 
							where o.idHeaderLotto = @idHeaderLotto and o.TipoDoc = 'PDA_OFFERTE' and o.voce <> 0 and o.idHeader = @idHeaderOff
							order by o.id

				open CrsLtVoce 
				fetch next from CrsLtVoce into @idRowLottoOffVoce , @PesoVoce , @Voce
				set @fetch_status_voce = @@fetch_status
			
			
		
			end
			else
				set @fetch_status_voce = 0
		


			while @fetch_status_voce = 0
			begin
		
				-- recupera il valore imputato da controllare con il quiz -- DA MIGLIORARE
				--select cast( '' as varchar( 4000)) as ValoreTemporaneo into #Temp
				select cast( 0.0 as float) as ValoreTemporaneo into #Temp
				set @statmentSQL = ' update #Temp set ValoreTemporaneo = cast( ' + @AttributoCriterio + ' as float ) from #Temp ,Document_MicroLotti_Dettagli  with(nolock) where Id = ' + cast(  @idRowLottoOffVoce as varchar(20) )
				exec( @statmentSQL  )
				--update #Temp set ValoreTemporaneo = '0.0' where rtrim(ValoreTemporaneo ) = ''
				--select @ValoreOfferta =  cast( isnull(ValoreTemporaneo ,'0.0' ) as float ) from #Temp
				select @ValoreOfferta =  isnull(ValoreTemporaneo ,0.0 ) from #Temp
				drop table #Temp


				


				if @CriterioQuiz = 'max'
				begin
				
					if @ValoreOfferta = 0.0
					begin
						set @Punteggio = 0
					end
					else
					begin

						select cast( 0.0 as float) as ValoreTemporaneo into #Temp3
						set @statmentSQL = ' 
						declare @MAX float
						select @MAX = max(cast( l.' + @AttributoCriterio + ' as float) ) 
							from Document_PDA_Offerte o  with(nolock) -- lotti offerti
								inner join  Document_MicroLotti_Dettagli l with(nolock)  on l.idheader = o.idrow and l.tipoDoc = ''PDA_OFFERTE'' and l.Voce = ' + @Voce + ' and l.NumeroLotto = ''' + @NumeroLotto + ''' -- offerte 
								inner join Document_MicroLotti_Dettagli V0 with(nolock)  on V0.idheader =  o.idrow and  V0.tipoDoc = ''PDA_OFFERTE'' and V0.Voce = 0 and V0.NumeroLotto = ''' + @NumeroLotto + ''' and V0.StatoRiga <> ''escluso''
								where o.idheader = ' + cast( @idPDA  as varchar(20)) + ' 
							
							
						update #Temp3 set ValoreTemporaneo = @MAX '
						exec( @statmentSQL  )

						--select @ValoreMassimo =  isnull(ValoreTemporaneo ,'') from #Temp3
						select @ValoreMassimo =  ValoreTemporaneo  from #Temp3
						drop table #Temp3

						--set @Punteggio = str( ( @ValoreOfferta / @ValoreMassimo ) , 20 , 10 )
						set @Punteggio = ( @ValoreOfferta / @ValoreMassimo ) 

					end

				end

				if @CriterioQuiz = 'min'
				begin

					if @ValoreOfferta = 0.0
					begin
						set @Punteggio = 1
					end
					else
					begin
				
						select cast( 0.0 as float ) as ValoreTemporaneo into #Temp2
						set @statmentSQL = ' 
						declare @MIN float
						select @MIN = min( cast( l.' + @AttributoCriterio + ' as float ) ) 
							from Document_PDA_Offerte o  with(nolock) -- lotti offerti
								inner join  Document_MicroLotti_Dettagli l with(nolock)  on l.idheader = o.idrow and l.tipoDoc = ''PDA_OFFERTE'' and l.Voce = ' + @Voce + ' and l.NumeroLotto = ''' + @NumeroLotto + ''' -- offerte 
								inner join Document_MicroLotti_Dettagli V0  with(nolock) on V0.idheader =  o.idrow and  V0.tipoDoc = ''PDA_OFFERTE'' and V0.Voce = 0 and V0.NumeroLotto = ''' + @NumeroLotto + ''' and V0.StatoRiga <> ''escluso''
								where o.idheader = ' + cast( @idPDA  as varchar(20)) + ' 
							
							
						update #Temp2 set ValoreTemporaneo =  @MIN '

						exec( @statmentSQL  )

						--select @ValoreMinimo =  isnull(ValoreTemporaneo ,'') from #Temp2
						select @ValoreMinimo =  ValoreTemporaneo  from #Temp2
						drop table #Temp2

						--set @Punteggio = str( ( @ValoreMinimo  /  @ValoreOfferta )  , 20 , 10 )
						set @Punteggio = ( @ValoreMinimo  /  @ValoreOfferta )  
					end

				end

				IF @CriterioQuiz = 'ribassoMax'
				BEGIN

					
					if @ValoreOfferta = 0.0
					begin
						set @Punteggio = 1
					end
					else
					begin

						set @Vsogi = dbo.GetPos(@Formula, '#=#', 3 )
				
						select cast( 0.0 as float ) as ValoreTemporaneo into #Temp22
						set @statmentSQL = '
						declare @MIN float
						select @MIN = min( cast( l.' + @AttributoCriterio + ' as float ) ) 
							from Document_PDA_Offerte o  with(nolock) -- lotti offerti
								inner join  Document_MicroLotti_Dettagli l with(nolock)  on l.idheader = o.idrow and l.tipoDoc = ''PDA_OFFERTE'' and l.Voce = ' + @Voce + ' and l.NumeroLotto = ''' + @NumeroLotto + ''' -- offerte 
								inner join Document_MicroLotti_Dettagli V0  with(nolock) on V0.idheader =  o.idrow and  V0.tipoDoc = ''PDA_OFFERTE'' and V0.Voce = 0 and V0.NumeroLotto = ''' + @NumeroLotto + ''' and V0.StatoRiga <> ''escluso''
								where o.idheader = ' + cast( @idPDA  as varchar(20)) + ' 


						update #Temp22 set ValoreTemporaneo =  @MIN'

						exec( @statmentSQL  )

						select @ValoreMinimo =  ValoreTemporaneo  from #Temp22
						drop table #Temp22

						-- Vai    = ValoreOfferta
						-- Vmin i = ValoreMinimo
						-- Vsogi  = costante imputata nella quiz.asp
						
						BEGIN TRY

							set @Punteggio = ( @Vsogi  - @ValoreOfferta ) / ( @Vsogi - @ValoreMinimo )

							if @Punteggio < 0
								set @Punteggio = 0

						END TRY 
						BEGIN CATCH  
     
							--questa gestione dell'errore è un controllo paracadute, per i controlli fatti 
							--a monte non dovremmo arrivarci. ma comunque ci tuteliamo da un punteggio minore di zero e da un division by zero

	 						set @errorNumber = ERROR_NUMBER()
							set @descError = ERROR_MESSAGE()
							SET @ErrorSeverity = ERROR_SEVERITY()
							SET @ErrorState = ERROR_STATE()

							-- Se l'errore è un Divide by zero 
							IF @errorNumber = 8134 
							BEGIN
								
								set @Punteggio = 0

							END
							ELSE
							BEGIN

								-- lo faccio ri-andare in errore se l'errore non è di division by zero
								 RAISERROR (@descError, -- Message text.  
									   @ErrorSeverity, -- Severity.  
									   @ErrorState -- State.  
									   );  

							END


						END CATCH 

					end


				END

				IF @CriterioQuiz = 'rialzoMax'
				BEGIN

					
					if @ValoreOfferta = 0.0
					begin
						set @Punteggio = 0
					end
					else
					begin

						set @Vsogi = dbo.GetPos(@Formula, '#=#', 3 )

						select cast( 0.0 as float) as ValoreTemporaneo into #Temp33
						set @statmentSQL = ' 
						declare @MAX float
						select @MAX = max(cast( l.' + @AttributoCriterio + ' as float) ) 
							from Document_PDA_Offerte o  with(nolock) -- lotti offerti
								inner join  Document_MicroLotti_Dettagli l  with(nolock)  on l.idheader = o.idrow and l.tipoDoc = ''PDA_OFFERTE'' and l.Voce = ' + @Voce + ' and l.NumeroLotto = ''' + @NumeroLotto + ''' -- offerte 
								inner join Document_MicroLotti_Dettagli V0  with(nolock) on V0.idheader =  o.idrow and  V0.tipoDoc = ''PDA_OFFERTE'' and V0.Voce = 0 and V0.NumeroLotto = ''' + @NumeroLotto + ''' and V0.StatoRiga <> ''escluso''
								where o.idheader = ' + cast( @idPDA  as varchar(20)) + ' 
							
							
						update #Temp33 set ValoreTemporaneo = @MAX '
						exec( @statmentSQL  )

						select @ValoreMassimo =  ValoreTemporaneo  from #Temp33
						drop table #Temp33

						-- Vai    = @ValoreOfferta
						-- Vmax i = @ValoreMassimo
						-- Vsogi  = costante imputata nella quiz.asp

						BEGIN TRY

							set @Punteggio = ( @ValoreOfferta  - @Vsogi ) / ( @ValoreMassimo - @Vsogi )

							if @Punteggio < 0
								set @Punteggio = 0

						END TRY 
						BEGIN CATCH  
     
							--questa gestione dell'errore è un controllo paracadute, per i controlli fatti 
							--a monte non dovremmo arrivarci. ma comunque ci tuteliamo da un punteggio minore di zero e da un division by zero

	 						set @errorNumber = ERROR_NUMBER()
							set @descError = ERROR_MESSAGE()
							SET @ErrorSeverity = ERROR_SEVERITY()
							SET @ErrorState = ERROR_STATE()

							-- Se l'errore è un Divide by zero 
							IF @errorNumber = 8134 
							BEGIN
								
								set @Punteggio = 0

							END
							ELSE
							BEGIN

								-- lo faccio ri-andare in errore se l'errore non è di division by zero
								 RAISERROR (@descError, -- Message text.  
									   @ErrorSeverity, -- Severity.  
									   @ErrorState -- State.  
									   );  

							END


						END CATCH
						
						

					end


				END
			
			
				if @VociMultiple = 1
				begin
			
			
					--calcolo il punteggio parziale della voce 
					set @PunteggioParziale = @PunteggioParziale + ( @PunteggioMax * @punteggio * ( @PesoVoce / 100.0 ))
			
			
					fetch next from CrsLtVoce into @idRowLottoOffVoce , @PesoVoce , @Voce
					set @fetch_status_voce = @@fetch_status
				
					if @fetch_status_voce <> 0 
						set @punteggio = @PunteggioParziale
			
				end
				else
					set @fetch_status_voce = 1

			end


			if @VociMultiple = 1
			begin
				close CrsLtVoce 
				deallocate CrsLtVoce
			END

			-- aggiorno il punteggio relativo
			if @VociMultiple = 1
			begin
				update Document_Microlotto_PunteggioLotto 
					set 
					   --Punteggio = round(   @punteggio  , 2 ) 
					   Punteggio = dbo.AFS_ROUND(   @punteggio  , 2 ) 
						--, PunteggioOriginale = round (   @punteggio   , 2 ) 
						, PunteggioOriginale = dbo.AFS_ROUND (   @punteggio   , 2 ) 
						, Giudizio = dbo.FormatFloat(  @punteggio  / @PunteggioMax )
					where idRow = @idRow


			end
			else
			begin
				update Document_Microlotto_PunteggioLotto 
					set 
					   --Punteggio = round(    @punteggio   * @PunteggioMax  , 2 ) 
					   Punteggio =  dbo.AFS_ROUND(    @punteggio   * @PunteggioMax  , 2 ) 
						--, PunteggioOriginale =round(    @punteggio   * @PunteggioMax  , 2 ) 
						, PunteggioOriginale = dbo.AFS_ROUND(    @punteggio   * @PunteggioMax  , 2 ) 
						, Giudizio =  dbo.FormatFloat( @punteggio   )
					where idRow = @idRow

			end


		end

		fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax
	end 
	close CrsLt 
	deallocate CrsLt


end




























GO
