USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ASTA_VALUTAZIONE_RILANCIO_TEC]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc  [dbo].[ASTA_VALUTAZIONE_RILANCIO_TEC](  @idDoc int , @idBando int , @idRowLottoOff int  )
as
begin

	declare @idRow				int 
	declare @i					int 

	declare @Formula			nvarchar(4000)
	declare @ValoreOfferta		nvarchar(4000)
	declare @AttributoCriterio	nvarchar(255)
	declare @Valori				nvarchar(255)
	declare @ValDom				nvarchar(255)
	declare @minimo				nvarchar(255)
	declare @massimo			nvarchar(255)
	declare @punteggio			nvarchar(255)
	declare @CriterioQuiz		varchar(50)
	declare @statmentSQL		varchar(4000)


	declare @NumeroLotto			varchar(50)
	declare @idHeaderLotto			int
	declare @VociMultiple			int
	declare @VociMultipleBase		int
	declare @idRowLottoOffVoce		int
	declare @fetch_status_voce		int
	declare @TipoDocBando			varchar(200)
	declare @idRowVoce				int
	declare @idHeaderOff			int
	declare @PesoVoce				float
	declare @PunteggioParziale		float
	declare @PunteggioMax			float
	declare @TipoGiudizioTecnico	varchar(50)
	declare @idPDA					int
	declare @divisione_lotti		varchar(50)
	
	
	select  @TipoDocBando = b.TipoDoc , @TipoGiudizioTecnico = isnull( TipoGiudizioTecnico , 'edit' )
			, @divisione_lotti = divisione_lotti
			from Ctl_Doc B
				inner join Document_Bando ba on ba.idheader = b.id
				where B.Id = @idBando


	set @VociMultipleBase = 0
	set @VociMultiple = 0

	-- se il lotto è a voci multiple si cicla sulle voci altrimenti la valutazione è diretta alla voce 0
	set @VociMultipleBase = 1


	---------------------------------------------
	-- recupera il modello selezionato sul bando
	---------------------------------------------
	declare @IdDocModello int
	select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando
	

	--per ogni punteggio oggettivo determina il valore in funzione dei dati inseriti
	declare CrsLt cursor static for 
		select p.idRow , Formula , AttributoCriterio , PunteggioMax 
			from Document_Microlotto_PunteggioLotto p
				inner join Document_Microlotto_Valutazione v on v.idRow = idRowValutazione and CriterioValutazione in ( 'quiz' )
			where idHeaderLottoOff = @idRowLottoOff 
			order by v.idRow

	open CrsLt 
	fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax

	while @@fetch_status=0 
	begin 



		
		set @punteggio = '0'
		set @PunteggioParziale = 0 

		set @CriterioQuiz = dbo.GetPos(@Formula, '#=#', 2 )
		set @Valori		  = dbo.GetPos(@Formula, '#=#', 3 )
		set @AttributoCriterio = dbo.GetPos(@AttributoCriterio, '.', 2 )

		-- la valutazione oggettiva deve essere fatta solo domino e range, min e max sono fatte da altro processo
		if @CriterioQuiz in  ( 'dominio' , 'range' )
		begin


			--set @idRowLottoOffVoce = @idRowLottoOff



			-- determino per l'attributo se deve lavorare sulle voci o sul lotto
			set @VociMultiple = 1
			 --dbo.ConditionLottoVoceModello( @IdDocModello , @AttributoCriterio , @divisione_lotti )
	 		--set @VociMultiple = 0

			--if  @divisione_lotti = '0' -- per le gare senza lotti i dati sono presenti solo sulle righe
			--				or ( @VociMultipleBase = 1 and exists( 
			--										select  l.Value 
			--											from CTL_DOC_VALUE a
			--												inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'
			--												where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @AttributoCriterio
			--														and  l.Value = 'Voce' -- solo se è selezionato voce recupero i dati dalle voci altrimenti sempre dai lotti
			--									)
			--					)
			--begin
			--	set @VociMultiple = 1
			--end
		
			-- se il lotto è a voce per ogni voce viene determinato il punteggio e moltiplicato per il suo peso
			if @VociMultiple = 1
			begin

				declare CrsLtVoce cursor static for 
						select o.id , b.PesoVoce 
							--from Document_MicroLotti_Dettagli o
							--inner join Document_MicroLotti_Dettagli b on b.idHeader = @idBando and b.TipoDoc = @TipoDocBando and o.NumeroLotto = isnull( b.NumeroLotto , '1' ) and o.Voce = isnull( b.Voce , b.numeroriga )  and isnull( o.variante , 0 ) = isnull( b.Variante , 0 ) 
							--where o.idHeaderLotto = @idHeaderLotto and o.TipoDoc = 'PDA_OFFERTE' and o.voce <> 0 and o.idHeader = @idHeaderOff
							--order by o.id						select o.id , b.PesoVoce 
							from Document_MicroLotti_Dettagli o
								inner join Document_MicroLotti_Dettagli b on b.idHeader = @idBando and b.TipoDoc = @TipoDocBando and b.numeroriga  = o.NumeroRiga
							where o.idHeader = @idDoc and o.TipoDoc = 'OFFERTA_ASTA' 
							order by o.id

				open CrsLtVoce 
				fetch next from CrsLtVoce into @idRowLottoOffVoce , @PesoVoce
				set @fetch_status_voce = @@fetch_status
			
			
		
			end
			else
				set @fetch_status_voce = 0
		


			while @fetch_status_voce = 0
			begin
		
				-- recupera il valore imputato da controllare con il quiz -- DA MIGLIORARE
				select cast( '' as varchar( 4000)) as ValoreTemporaneo into #Temp
				set @statmentSQL = ' update #Temp set ValoreTemporaneo = ' + @AttributoCriterio + ' from #Temp ,Document_MicroLotti_Dettagli where Id = ' + cast(  @idRowLottoOffVoce as varchar(20) )
				exec( @statmentSQL  )
				select @ValoreOfferta =  isnull(ValoreTemporaneo ,'') from #Temp
				drop table #Temp


				if @CriterioQuiz = 'dominio'
				begin
				
					set @i = 1
					set @ValDom = isnull( dbo.GetPos(@Valori, '#~#',@i ) , '' ) 

					-- esamina il dominio alla ricerca di una corrispondenza
					while @ValDom <> '' 
					begin


						if @ValDom = @ValoreOfferta
						begin
							set @punteggio = dbo.GetPos(@Valori, '#~#',@i + 3)
							break
						end

						set @i = @i + 4
						set @ValDom = dbo.GetPos(@Valori, '#~#',@i )
					end
				

				end

				if @CriterioQuiz = 'range'
				begin

					set @i = 1
					set @minimo  = isnull( dbo.GetPos(@Valori, '#~#',@i + 1) , '' ) 
					set @massimo = isnull( dbo.GetPos(@Valori, '#~#',@i + 2) , '' ) 

					-- esamina il dominio alla ricerca di una corrispondenza
					while @minimo <> '' or @massimo <> ''
					begin


						if @minimo = '' 
						begin
							if cast( @ValoreOfferta as float ) < cast( @massimo as float)
							begin
								set @punteggio = dbo.GetPos(@Valori, '#~#',@i + 3)
								break
							end
						end
						else
						if @massimo = '' 
						begin
							if cast( @minimo as float ) <= cast( @ValoreOfferta as float ) 
							begin
								set @punteggio = dbo.GetPos(@Valori, '#~#',@i + 3)
								break
							end
						end
						else
						if cast( @minimo as float ) <= cast( @ValoreOfferta as float )  and  cast( @ValoreOfferta as float ) < cast( @massimo as float)
						begin
							set @punteggio = dbo.GetPos(@Valori, '#~#',@i + 3)
							break
						end


						set @i = @i + 4
						set @minimo  = isnull( dbo.GetPos(@Valori, '#~#',@i + 1) , '' ) 
						set @massimo = isnull( dbo.GetPos(@Valori, '#~#',@i + 2) , '' ) 
					end
				

				end
			
			
				if @VociMultiple = 1
				begin
			
			
					--calcolo il punteggio parziale della voce 
					IF  @TipoGiudizioTecnico  = 'edit'
						set @PunteggioParziale = @PunteggioParziale + ( cast( @punteggio as float ) * @PesoVoce / 100.0 )
					else
						set @PunteggioParziale = @PunteggioParziale + ( @PunteggioMax * cast( @punteggio as float ) * @PesoVoce / 100.0 )
			
			
					fetch next from CrsLtVoce into @idRowLottoOffVoce , @PesoVoce
					set @fetch_status_voce = @@fetch_status
				
					if @fetch_status_voce <> 0 
						set @punteggio = str( @PunteggioParziale , 25 , 10 )
			
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
				-- siccome il punteggio viene espresso come sommatoria dei punteggi sulle voci il risultato viene arrotondato a due decimali
				update Document_Microlotto_PunteggioLotto set Punteggio = round( cast( @punteggio as float ) , 2 )  , PunteggioOriginale = round(  cast( @punteggio as float ) , 2 )  where idRow = @idRow

				-- assegno anche il giudizio con lo stesso valore
				update Document_Microlotto_PunteggioLotto set Giudizio = dbo.FormatFloat( cast( @punteggio as float ) / @PunteggioMax  ) where idRow = @idRow

			end
			else
			begin
				IF  @TipoGiudizioTecnico  = 'edit'
					update Document_Microlotto_PunteggioLotto set Punteggio = cast( @punteggio as float ) , PunteggioOriginale = cast( @punteggio as float )  where idRow = @idRow
				else
					update Document_Microlotto_PunteggioLotto set Punteggio = cast( @punteggio as float ) * @PunteggioMax  , PunteggioOriginale = cast( @punteggio as float ) * @PunteggioMax  where idRow = @idRow

				-- assegno anche il giudizio con lo stesso valore
				update Document_Microlotto_PunteggioLotto set Giudizio = dbo.FormatFloat( cast( @punteggio as float )  ) where idRow = @idRow

			end


		end


		fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax
	end 
	close CrsLt 
	deallocate CrsLt



	-- riporta il punteggio sull'offerta
	delete from CTL_DOC_VALUE where idheader = @idDoc and dzt_name in ( 'PunteggioTecnico' ) and [DSE_ID] = 'TOTALI'
	insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value ) 
		select @idDoc , 'TOTALI' , 0 ,  'PunteggioTecnico' , sum( Punteggio )
			from Document_Microlotto_PunteggioLotto 
			where idHeaderLottoOff = @idRowLottoOff  


end






GO
