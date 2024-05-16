USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Proc [dbo].[OLD2_PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO] (  @idDoc int , @IdPFU int )
as
begin

	--declare @IdPFU as Int 
	--declare @idDoc int

	
	--set @idDoc = 95439  
	--set @idPfu = 45094  



	declare @IdLotto					Int 
	declare @IdPDA						Int 
	declare @idOfferta					int
	declare @idHeaderLotto				int
	declare @StatoRiga					Varchar(255) 
	declare @NumeroLotto				Varchar(255) 

	-- LA STORED E' OBSOLETA e le operazioni sono state fatte singolarmente
	-- per questo si richiama la procedura singola per tutte le offerte presenti
	-- e si commenta tutto il pregresso come traccia storica nel caso qualche ragionamento si sia perso

	declare crs cursor static for 
		select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto, d.IdMsgFornitore , O.idHeaderLotto
			from Document_MicroLotti_Dettagli P
			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader
			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' ,'ValutatoECO', 'Conforme' ,  'verificasuperata' , 'Saved'  , '' , 'SospettoAnomalo' ) and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
			where  
				P.ID = @IdDoc and P.Voce = 0

	open crs 
	fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto, @idOfferta, @idHeaderLotto
	while @@fetch_status=0 
	begin 

		-- per ogni offerta si eseguono le operazioni per calcolare il valore offerto
		exec PDA_MICROLOTTI_VALORE_ECONOMICO_OFFERTO_FORNITORE @IdPDA ,  @NumeroLotto  , @idOfferta  
		

		fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto, @idOfferta, @idHeaderLotto
	end 
	close crs 
	deallocate crs





	--declare @Criterio as varchar(100)
	----declare @TipoDoc as varchar(100)
	----declare @Fascicolo as varchar(100)

	--declare @ListaModelliMicrolotti as varchar(500)
	--declare @FormulaEconomica as nvarchar (4000)
	--declare @strSql as nvarchar (4000)

	--declare @NumeroDecimali				int
	--declare @FieldBaseAsta				varchar(200)
	--declare @FieldQuantita				varchar(200)
	--declare @BaseAstaUnitaria	int

	 
	--declare @MultiVoce					int
	--declare @idBando					int

	--declare @nRiportaBaseAstaUnitaria  int
	--declare @divisione_lotti		varchar(50)

	--select @IdPDA = idheader , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli where id = @IdDoc

	---- determino il criterio di aggiudicazione della gara
	--if exists( select id from ctl_doc where isnull( jumpcheck , '' ) <> '' and id = @IdPDA)
	--begin
	--	select @idBando = LinkedDoc , @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando , @NumeroDecimali = isnull( NumDec , 5 ) , @BaseAstaUnitaria = isnull( BaseAstaUnitaria , 0 ) 
	--			, @divisione_lotti = divisione_lotti
	--		 from Document_Bando 
	--			inner join CTL_DOC on LinkedDoc = idheader
	--			where id = @IdPDA
	--end
	--else
	--begin
	--	set @NumeroDecimali = 5 
	--	set @BaseAstaUnitaria = 1
	--	set @divisione_lotti = '1'
	--	select @Criterio = 
	--						case when isnull(TM.criterioformulazioneofferte,'' ) <> '' 
	--							then TM.criterioformulazioneofferte 
	--							else DP.criterioformulazioneofferte 
	--						end   
	--	     , @ListaModelliMicrolotti = 
	--						case when isnull(TM.ListaModelliMicrolotti, '' ) <> '' 
	--								then TM.ListaModelliMicrolotti 
	--								else DP.ListaModelliMicrolotti 
	--						end  
	--		 from TAB_MESSAGGI_FIELDS TM
	--				inner join CTL_DOC on LinkedDoc = idMsg
	--				inner join document_pda_testata DP on DP.idheader=id
	--			where id = @IdPDA

	--end
	
	

	--select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
	--	from Document_Modelli_MicroLotti_Formula 
	--	where @Criterio = CriterioFormulazioneOfferte
	--		and @ListaModelliMicrolotti = Codice


	--declare @IdDocModello int
	---- per il bando semplificato il modello si trova collegato allo SDA
	----if exists( select * from ctl_doc where tipodoc = 'BANDO_SEMPLIFICATO' and id = @idBando )
	----	select @IdDocModello = m.id from ctl_doc sem inner join ctl_doc m on m.linkedDoc = sem.linkedDoc and m.tipodoc = 'CONFIG_MODELLI_LOTTI' and m.deleted = 0 where sem.id = @idBando
	----else
	--	select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando
	


	--set @MultiVoce = 0
	----if exists( select id from Document_MicroLotti_Dettagli where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 )
	----tratto gli exequo su voce multipla come voce singola (aggiunta condizione and Exequo <> 1)
	--if exists( select id from Document_MicroLotti_Dettagli where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 and  isnull( Exequo , 0 )  <> 1)
	--	set @MultiVoce = 1

	---- se ci sono le voci controllo se è stato indicato come criterio di compilazione i lotto o la voce
	--if @divisione_lotti = '0' or (  @MultiVoce = 1 and exists( 
	--										select  l.Value 
	--											from CTL_DOC_VALUE a
	--												inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'
	--												where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FormulaEconomica
	--														and  l.Value = 'Voce' -- solo se è selezionato voce recupero i dati dalle voci altrimenti sempre dai lotti
	--									)
	--							)
	--begin
	--	set @MultiVoce = 1
	--end
	--else
	--begin
	--	set @MultiVoce = 0
	--end




	------------------------------------------------------------
	---- determino il valore economico dei lotti offerti
	------------------------------------------------------------
	----print @MultiVoce
	--if @MultiVoce = 0
	--begin
		
	--	--determino se devo riportare la baste asta unitaria (quando il lotto è a voci e lo stato è Exequo)
	--    if exists (select id from Document_MicroLotti_Dettagli where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 and  isnull( Exequo , 0 )  = 1 )
	--    begin
	--		set @nRiportaBaseAstaUnitaria=1
	--    end

	--	--per voci singole si calcola il Valore Economico direttamente sul lotto
	--	declare crs cursor static for 
	--		select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto, O.idheader , O.idHeaderLotto
	--			from Document_MicroLotti_Dettagli P
	--			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader
	--			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' , 'Conforme' ,  'verificasuperata' , 'Saved'  , '' , 'SospettoAnomalo' ) and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
	--			where  
	--				P.ID = @IdDoc and P.Voce = 0

	--	open crs 
	--	fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto, @idOfferta, @idHeaderLotto
	--	while @@fetch_status=0 
	--	begin 
				
	--			-- SOMMA DEI VALORI BASE ASTA DELLE SINGOLE VOCI (con o senza la quantità a seconda di @BaseAstaUnitaria)
	--			if @nRiportaBaseAstaUnitaria = 1 
	--			begin
	--				set @strSql =  'Update Document_MicroLotti_Dettagli
	--					set ' + @FieldBaseAsta + ' =  (
	--												select sum( ' + @FieldBaseAsta + case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end  + ' ) 
	--													from Document_MicroLotti_Dettagli 
	--														where tipodoc = ''PDA_OFFERTE''  and 
	--															idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--															idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--															Voce <> 0 
	--											)
	--					where id   = ' + cast( @IdLotto as varchar(20))

	--				exec (@strSql)

	--			end


	--			-- seguo il calcolo economico se è stata superata la soglia del punteggio minimo 
	--			set @strSql =  'Update 
	--				Document_MicroLotti_Dettagli
	--				set ValoreEconomico =   ' + @FormulaEconomica + ' 
	--				, ValoreImportoLotto = round( ' + 
					
	--							CASE 
	--								when @FieldQuantita <> '' and  @Criterio = '15536' /*prezzo*/ then  @FormulaEconomica + ' * ' + @FieldQuantita 
	--								when @FieldQuantita = '' and  @Criterio = '15536' /*prezzo*/ then   ' cast ( ' + @FormulaEconomica + ' as float ) '
	--								when @FieldQuantita <> '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * cast( ' + @FormulaEconomica + ' as float ) ) / 100 ) ' + case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end
	--								when @FieldQuantita = '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * cast( ' + @FormulaEconomica + ' as float ) ) / 100 ) ' 
									
	--								else '' 
								
	--							--end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
	--							end +  ' , 2 ) 
	--				, ValoreSconto =  ' + 
					
	--							CASE 
	--								when @Criterio <> '15536' /*percentuale*/ then   ' cast ( ' + @FormulaEconomica + ' as float ) '
	--								--when @Criterio = '15536' /*prezzo*/ then  ' 100 - (  ' + @FormulaEconomica + ' /  ' + @FieldBaseAsta + ' ) * 100  ' 
	--								when @Criterio = '15536' /*prezzo*/ then  ' 100 - (  ' + case  when @FieldQuantita <> '' then ' ( cast( ' + @FormulaEconomica + ' as float ) * ' + @FieldQuantita + ' ) ' else ' cast( ' +   @FormulaEconomica + ' as float ) ' end  + ' /  ' + @FieldBaseAsta + ' ) * 100  ' 
									
	--								else '0' 
								
	--							--end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
	--							end +  '  
	--				where tipodoc = ''PDA_OFFERTE''  and 
	--				id  = ' + cast( @IdLotto as varchar(20))

	--			--print @strSql
	--			exec ( @strSql )

	--			-- seguo il calcolo del ribasso 
	--			set @strSql =  'Update 
	--				Document_MicroLotti_Dettagli
	--					set ValoreRibasso = round( ' + @FieldBaseAsta + case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end + '  - ValoreImportoLotto  , 2 ) 
	--				where tipodoc = ''PDA_OFFERTE''  and 
	--				id  = ' + cast( @IdLotto as varchar(20))

	--			--print @strSql
	--			exec ( @strSql )

	--			-- seguo il calcolo economico anche per la base asta
	--			set @strSql =  'Update 
	--				Document_MicroLotti_Dettagli
	--				set  ValoreImportoLotto = round( ' + 
					
	--							CASE 
	--								when @FieldQuantita <> ''  then  @FieldBaseAsta + '  * ' + @FieldQuantita 
	--								when @FieldQuantita = '' then   @FieldBaseAsta 
	--							end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
	--				where tipodoc = ''PDA_MICROLOTTI''  and NumeroLotto = ''' + @NumeroLotto + ''' and Voce = 0 and 
	--				idheader  = ' + cast( @IdPDA as varchar(20))

	--			--print @strSql
	--			--exec ( @strSql )



			

	--		fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto, @idOfferta, @idHeaderLotto
	--	end 
	--	close crs 
	--	deallocate crs

	--end
	--else
	--begin
		
	--	-- altrimenti si fa risalire il valore dalle righe
	--	declare crs cursor static for 
	--		select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto , O.idheader , O.idHeaderLotto
	--			from Document_MicroLotti_Dettagli P
	--			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader
	--			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' 
	--														and O.statoRiga in ('Valutato' , 'Conforme' , 'verificasuperata'  , 'Saved' , '' , 'SospettoAnomalo') 
	--														and P.NumeroLotto = O.NumeroLotto
	--														and O.Voce = 0
	--			where  
	--				P.ID = @IdDoc 

	--	open crs 
	--	fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @idOfferta, @idHeaderLotto
	--	while @@fetch_status=0 
	--	begin 



	--			-- se il valore è al prezzo il valore economico si ottiene sommando il prezzo unitario per la QT se presente e riportandolo sulla voce 0
	--			if @Criterio = '15536'  -- prezzo
	--			begin
				
	
	--				--set @strSql =  'Update 
	--				--	Document_MicroLotti_Dettagli
	--				--	set ValoreEconomico =  round( ' + @FormulaEconomica + CASE when @FieldQuantita <> '' then  ' * ' + @FieldQuantita else '' end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
	--				--	where tipodoc = ''PDA_OFFERTE''  and 
	--				--	idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--				--	idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--				--	Voce <> 0 '

	--				set @strSql =  'Update 
	--					Document_MicroLotti_Dettagli
	--					set ValoreEconomico =   ' + @FormulaEconomica + CASE when @FieldQuantita <> '' then  ' * ' + @FieldQuantita else '' end +  '
	--					where tipodoc = ''PDA_OFFERTE''  and 
	--					idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--					idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--					Voce <> 0 '
						

	--				--print @strSql
	--				exec ( @strSql )
					
					
	--				Update Document_MicroLotti_Dettagli
	--					set ValoreEconomico =  round(  (	-- SOMMA DEI VALORI DELLE SINGOLE VOCI
	--												select sum( ValoreEconomico ) 
	--													from Document_MicroLotti_Dettagli 
	--														where tipodoc = 'PDA_OFFERTE'  and 
	--															idHeader  =  @idOfferta and
	--															idHeaderLotto = @idHeaderLotto and
	--															Voce <> 0 
	--											) , 2 )
	--					where id  = @IdLotto 

	--				Update Document_MicroLotti_Dettagli
	--					set ValoreImportoLotto = ValoreEconomico  

	--					where id  = @IdLotto 


	--				-- calcolo lo sconto applicato
	--				CREATE TABLE #TempValoriVociP
	--				(
	--					ValoreEconomicoVoce float NULL ,
	--					ValoreEconomicoBaseAsta  float null
	--				)
					

	--				set @strSql =  'insert into #TempValoriVociP (  ValoreEconomicoVoce ,  ValoreEconomicoBaseAsta )
	--					select 
	--						ValoreEconomico ,
	--						 ' + @FieldBaseAsta +  CASE when @FieldQuantita <> '' and @BaseAstaUnitaria = 1 then  ' * ' + @FieldQuantita else '' end +  '  as ValoreEconomicoBaseAsta   
	--					from Document_MicroLotti_Dettagli
	--					where tipodoc = ''PDA_OFFERTE''  and 
	--					idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--					idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--					Voce <> 0 '						

	--				--print @strSql
	--				exec ( @strSql )
					
					
	--				Update 
	--					Document_MicroLotti_Dettagli
	--						set ValoreSconto =   (	-- ricalcolo lo sconto sulla base asta
	--													select  (( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
	--																							/ 
	--																	sum( ValoreEconomicoBaseAsta ) ) * 100 
	--														from #TempValoriVociP
	--											)
	--						, ValoreRibasso =    round ( (	select  ( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
																								
	--														from #TempValoriVociP
	--											) , 2 ) 
	--					where id  = @IdLotto 


	--				-- aggiorno anche la base asta sul lotto gara
	--				--Update 
	--				--	Document_MicroLotti_Dettagli
	--				--		set ValoreImportoLotto =   (	-- ricalcolo lo sconto sulla base asta
	--				--									select round(  sum( ValoreEconomicoBaseAsta )  , @NumeroDecimali )
	--				--										from #TempValoriVociP
	--				--							)
	--				--	where tipodoc = 'PDA_MICROLOTTI' and voce = 0 and idheader  = @IdPDA and NumeroLotto = @NumeroLotto					

					
	--				drop table #TempValoriVociP
				
	
	--			end
	--			else
	--			begin  -- sconto
				
	--				-- se il valore è come sconto il valore economico si ottiene trasformando la percentuale in prezzo, moltiplicando per le qt.
	--				-- anche il valore base asta unitaria per la qt e poi facendo il rapporto sui totali si ottiene la perc di 

	--				CREATE TABLE #TempValoriVoci
	--				(
	--					ValoreEconomicoVoce float NULL ,
	--					ValoreEconomicoBaseAsta  float null
	--				)
					
	--				set @strSql =  'insert into #TempValoriVoci ( ValoreEconomicoVoce , ValoreEconomicoBaseAsta )
	--					select 
						
	--						 (' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * ' + @FormulaEconomica + ' / 100 ) )' + CASE when @FieldQuantita <> ''  and @BaseAstaUnitaria = 1 then  ' * ' + @FieldQuantita else '' end +  '   as ValoreEconomicoVoce   ,
	--						 ' + @FieldBaseAsta +  CASE when @FieldQuantita <> ''  and @BaseAstaUnitaria = 1 then  ' * ' + @FieldQuantita else '' end +  '  as ValoreEconomicoBaseAsta   
	--					from Document_MicroLotti_Dettagli
	--					where tipodoc = ''PDA_OFFERTE''  and 
	--					idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--					idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--					Voce <> 0 '
						

	--				--print @strSql
	--				exec ( @strSql )
					
					
	--				Update 
	--					Document_MicroLotti_Dettagli
	--						set ValoreEconomico =  (	-- ricalcolo lo sconto sulla base asta
	--													select  (( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
	--																							/ 
	--																	sum( ValoreEconomicoBaseAsta ) ) * 100 
	--														from #TempValoriVoci
	--											)
	--							, ValoreImportoLotto = (	-- somo i valori delle singole voci
	--													select round(  sum( ValoreEconomicoVoce )  , 2 ) from #TempValoriVoci
	--											)
	--							, ValoreSconto = (	-- ricalcolo lo sconto sulla base asta
	--													select  (( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
	--																							/ 
	--																	sum( ValoreEconomicoBaseAsta ) ) * 100 
	--														from #TempValoriVoci
	--											)
	--					where id  = @IdLotto 


	--				Update Document_MicroLotti_Dettagli
	--					set ValoreRibasso = ( select   sum( ValoreEconomicoBaseAsta ) from #TempValoriVoci ) - ValoreImportoLotto 
	--					where id  = @IdLotto 


	--				-- aggiorno anche la base asta sul lotto gara
	--				--Update 
	--				--	Document_MicroLotti_Dettagli
	--				--		set ValoreImportoLotto =   (	-- ricalcolo lo sconto sulla base asta
	--				--									select round(  sum( ValoreEconomicoBaseAsta )  , @NumeroDecimali )
	--				--										from #TempValoriVoci
	--				--							)
	--				--	where tipodoc = 'PDA_MICROLOTTI' and voce = 0 and idheader  = @IdPDA and NumeroLotto = @NumeroLotto					
	--				drop table #TempValoriVoci
					

	--			end

	--		fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto , @idOfferta, @idHeaderLotto
	--	end 
	--	close crs 
	--	deallocate crs
	
	
	--end


end























GO
