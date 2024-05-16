USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_VALUTAZIONE_TEC_ELAB_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[OLD2_PDA_VALUTAZIONE_TEC_ELAB_LOTTO]( @idRowLottoOff int  )
as
begin

	declare @idRow				int 
	declare @i					int 

	declare @Formula			nvarchar(max)
	declare @ValoreOfferta		nvarchar(max)
	declare @AttributoCriterio	nvarchar(max)
	declare @Valori				nvarchar(max)
	declare @ValDom				nvarchar(max)
	declare @minimo				nvarchar(max)
	declare @massimo			nvarchar(max)
	declare @punteggio			nvarchar(255)
	declare @CriterioQuiz		varchar(50)
	declare @statmentSQL		varchar(max)


	declare @NumeroLotto			varchar(50)
	declare @idHeaderLotto			int
	declare @VociMultiple			int
	declare @VociMultipleBase		int
	declare @idRowLottoOffVoce		int
	declare @fetch_status_voce		int
	declare @idBando				int
	declare @TipoDocBando			varchar(2000)
	declare @idRowVoce				int
	declare @idHeaderOff			int
	declare @PesoVoce				float
	declare @PunteggioParziale		float
	declare @PunteggioMax			float
	declare @TipoGiudizioTecnico	varchar(50)
	declare @idPDA					int
	declare @divisione_lotti		varchar(50)
	declare @ModAttribPunteggio			as varchar(50)
	declare @bCalcoloMinMax			int

	set @bCalcoloMinMax = 0
	
	select cast( '' as varchar( 4000)) as ValoreTemporaneo into #Temp_PDA_VALUTAZIONE_TEC_ELAB_LOTTO

	select @NumeroLotto = o.NumeroLotto , @idHeaderLotto = o.idHeaderLotto , @idBando = d.linkedDoc 
			, @TipoDocBando = b.TipoDoc , @idHeaderOff = o.idHeader , @TipoGiudizioTecnico = isnull( TipoGiudizioTecnico , 'edit' )
			, @idPDA = p.idheader
			, @divisione_lotti = divisione_lotti
			from Document_MicroLotti_Dettagli o with(nolock)
				inner join Document_PDA_OFFERTE p with(nolock) on p.IdRow = o.idheader 
				inner join ctl_doc d with(nolock) on d.id = p.idheader
				inner join Ctl_Doc b with(nolock) on d.linkedDoc = b.id
				inner join Document_Bando ba with(nolock) on ba.idheader = b.id
				where o.Id = @idRowLottoOff


	select @ModAttribPunteggio = ModAttribPunteggio
	   from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and ( N_Lotto = @NumeroLotto or N_Lotto is null )

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
	declare CrsLt cursor static for 
		select p.idRow , Formula , AttributoCriterio , PunteggioMax 
			from Document_Microlotto_PunteggioLotto p with(nolock)
				inner join Document_Microlotto_Valutazione v with(nolock) on v.idRow = idRowValutazione and CriterioValutazione in ( 'quiz' )
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


		-- Alzo un flag per determinare la presenza di a valutazione oggettiva per min  max  rialzoMax  ribassoMax  per innescare il calcolo solo se necessario
		IF @CriterioQuiz in  ( 'min' , 'max', 'rialzoMax', 'ribassoMax' )
		BEGIN
			set @bCalcoloMinMax = 1
		end

		-- la valutazione oggettiva deve essere fatta solo domino e range, min e max sono fatte da altro processo
		if @CriterioQuiz in  ( 'dominio' , 'range' )
		begin


			set @idRowLottoOffVoce = @idRowLottoOff



			-- determino per l'attributo se deve lavorare sulle voci o sul lotto
			--set @VociMultiple = 1
			 --dbo.ConditionLottoVoceModello( @IdDocModello , @AttributoCriterio , @divisione_lotti )
	 		set @VociMultiple = 0

			-- se è presente la riga zero allora la monolotto si gestisce come una lotti a voci
			if @Divisione_Lotti = '0' and  exists( select IdRow  from ctl_doc_value with(nolock) where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' ) 
				set @Divisione_Lotti = '1'


			if  @divisione_lotti = '0' -- per le gare senza lotti i dati sono presenti solo sulle righe
							or ( @VociMultipleBase = 1 and exists( 
													select  l.Value 
														from CTL_DOC_VALUE a with(nolock)
															inner join CTL_DOC_VALUE l with(nolock) on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'
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
						
						select o.id , b.PesoVoce 
							from Document_MicroLotti_Dettagli o with(nolock)
								inner join Document_MicroLotti_Dettagli b with(nolock) on b.idHeader = @idBando and b.TipoDoc = @TipoDocBando and o.NumeroLotto = isnull( b.NumeroLotto , '1' ) and o.Voce = isnull( b.Voce , b.numeroriga )  and isnull( o.variante , 0 ) = isnull( b.Variante , 0 ) 
							where o.idHeaderLotto = @idHeaderLotto and o.TipoDoc = 'PDA_OFFERTE' and o.voce <> 0 and o.idHeader = @idHeaderOff
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
				set @statmentSQL = ' update #Temp_PDA_VALUTAZIONE_TEC_ELAB_LOTTO set ValoreTemporaneo = ' + ISNULL(@AttributoCriterio,'') + ' from #Temp_PDA_VALUTAZIONE_TEC_ELAB_LOTTO ,Document_MicroLotti_Dettagli with(nolock) where Id = ' + cast(  @idRowLottoOffVoce as varchar(20) )
				exec( @statmentSQL  )
				select @ValoreOfferta =  isnull(ValoreTemporaneo ,'') from #Temp_PDA_VALUTAZIONE_TEC_ELAB_LOTTO
				

				if @CriterioQuiz = 'dominio'
				begin
				
					set @i = 1
					set @ValDom = isnull( dbo.GetPos(@Valori, '#~#',@i ) , '' ) 

					-- esamina il dominio alla ricerca di una corrispondenza
					while @ValDom <> '' 
					begin
					   
					   --se sono numerici e l'attributo del criterio è numerico faccio il cast a float per confrontarli
					   if ISNUMERIC(@ValDom)=1 and ISNUMERIC(@ValoreOfferta)=1 and exists(select DZT_Name from lib_dictionary with(nolock) where dzt_name=@AttributoCriterio and dzt_type='2')
					   begin

						  if cast(@ValDom as float) =  cast(@ValoreOfferta as float)
						  begin
							 set @punteggio = dbo.GetPos(@Valori, '#~#',@i + 3)
							 break
						  end

					   end
					   else
					   begin

						  if @ValDom = @ValoreOfferta
						  begin
							 set @punteggio = dbo.GetPos(@Valori, '#~#',@i + 3)
							 break
						  end

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
					IF  @TipoGiudizioTecnico  = 'edit' or @ModAttribPunteggio = 'punteggio'  -- nel caso sia richiesto di inserire punteggio
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
				IF  @TipoGiudizioTecnico  = 'edit' or @ModAttribPunteggio = 'punteggio'  -- nel caso sia richiesto di inserire punteggio
				begin
					update Document_Microlotto_PunteggioLotto set Punteggio = cast( @punteggio as float ) , PunteggioOriginale = cast( @punteggio as float )  where idRow = @idRow

					-- assegno anche il giudizio con lo stesso valore
					update Document_Microlotto_PunteggioLotto set Giudizio = dbo.FormatFloat( cast( @punteggio as float ) / @PunteggioMax ) where idRow = @idRow
				end
				else
				begin
					update Document_Microlotto_PunteggioLotto set Punteggio = cast( @punteggio as float ) * @PunteggioMax  , PunteggioOriginale = cast( @punteggio as float ) * @PunteggioMax  where idRow = @idRow

					-- assegno anche il giudizio con lo stesso valore
					update Document_Microlotto_PunteggioLotto set Giudizio = dbo.FormatFloat( cast( @punteggio as float )  ) where idRow = @idRow
				end

			end

		end


		fetch next from CrsLt into @idRow , @Formula , @AttributoCriterio , @PunteggioMax
	end 
	close CrsLt 
	deallocate CrsLt



	----------------------------------------------------------------
	----------------------------------------------------------------
	-- SI INNESCA IL CALCOLO DEI CRITERI PER MIN E MAX che avverrà solo se tutte le offerte sono state aperte
	----------------------------------------------------------------
	----------------------------------------------------------------
	if @bCalcoloMinMax = 1
		
		exec PDA_VALUTAZIONE_TEC_LOTTO_MINMAX  @idPDA , @NumeroLotto 



	----------------------------------------------------------------
	----------------------------------------------------------------
	-- SI INNESCA IL CALCOLO DEI CRITERI EREDITATI nel caso di Rilancio competitivo
	----------------------------------------------------------------
	----------------------------------------------------------------
	exec PDA_VALUTAZIONE_TEC_LOTTO_EREDITATO  @idRowLottoOff

	drop table #Temp_PDA_VALUTAZIONE_TEC_ELAB_LOTTO
end








GO
