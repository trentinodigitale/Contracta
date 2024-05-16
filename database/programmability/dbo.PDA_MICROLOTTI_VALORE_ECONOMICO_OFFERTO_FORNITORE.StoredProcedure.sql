USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_VALORE_ECONOMICO_OFFERTO_FORNITORE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE Proc [dbo].[PDA_MICROLOTTI_VALORE_ECONOMICO_OFFERTO_FORNITORE] (  @IdPDA int , @NumeroLotto varchar(100) , @idMsgOfferta int)
as
begin

	declare @IdLotto as Int 

	declare @Criterio as varchar(100)

	declare @ListaModelliMicrolotti as varchar(500)
	declare @FormulaEconomica as nvarchar (4000)
	declare @strSql as nvarchar (4000)

	declare @NumeroDecimali				int
	declare @FieldBaseAsta				varchar(200)
	declare @FieldQuantita				varchar(200)
	declare @BaseAstaUnitaria	int


	declare @idOfferta					int
	declare @idHeaderLotto				int
	 
	declare @MultiVoce					int
	declare @idBando					int
	declare @NR  int
 

	--select @IdPDA = idheader , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli where id = @IdDoc

	-- determino il criterio di aggiudicazione della gara
	if exists( select id from ctl_doc where isnull( jumpcheck , '' ) <> '' and id = @IdPDA)
	begin
		select @idBando = LinkedDoc , @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando , @NumeroDecimali = isnull( NumDec , 5 ) , @BaseAstaUnitaria = isnull( BaseAstaUnitaria , 0 ) 
			 from Document_Bando 
				inner join CTL_DOC on LinkedDoc = idheader
				where id = @IdPDA
	end
	else
	begin

		set @NumeroDecimali = 5 
		set @BaseAstaUnitaria = 1
		select @Criterio = 
							case when isnull(TM.criterioformulazioneofferte,'' ) <> '' 
								then TM.criterioformulazioneofferte 
								else DP.criterioformulazioneofferte 
							end   
		     , @ListaModelliMicrolotti = 
							case when isnull(TM.ListaModelliMicrolotti, '' ) <> '' 
									then TM.ListaModelliMicrolotti 
									else DP.ListaModelliMicrolotti 
							end  
			 from TAB_MESSAGGI_FIELDS TM
					inner join CTL_DOC on LinkedDoc = idMsg
					inner join document_pda_testata DP on DP.idheader=id
				where id = @IdPDA

	end
	
	

	select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
		from Document_Modelli_MicroLotti_Formula 
		where @Criterio = CriterioFormulazioneOfferte
			and @ListaModelliMicrolotti = Codice


	declare @IdDocModello int
	set @IdDocModello=-1
	-- per il bando semplificato il modello si trova collegato allo SDA
	--if exists( select * from ctl_doc where tipodoc = 'BANDO_SEMPLIFICATO' and id = @idBando )
	--	select @IdDocModello = m.id from ctl_doc sem inner join ctl_doc m on m.linkedDoc = sem.linkedDoc and m.tipodoc = 'CONFIG_MODELLI_LOTTI' and m.deleted = 0 where sem.id = @idBando
	--else
		select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando
	
	
	--se non lo troviamo andiamo arecuperare il modello per come era memorizzato prima
	if @IdDocModello=-1
	   select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and titolo=@ListaModelliMicrolotti and statofunzionale='Pubblicato'

	--set @MultiVoce = 0
	--if exists( select id from Document_MicroLotti_Dettagli where idheader = @IdPDA and TipoDoc = 'PDA_MICROLOTTI' and  @NumeroLotto = NumeroLotto and voce = 1 )
	--	set @MultiVoce = 1

	---- se ci sono le voci controllo se è stato indicato come criterio di compilazione i lotto o la voce
	--if @MultiVoce = 1 and exists( 
	--										select  l.Value 
	--											from CTL_DOC_VALUE a
	--												inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'
	--												where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FormulaEconomica
	--														and  l.Value = 'Voce' -- solo se è selezionato voce recupero i dati dalle voci altrimenti sempre dai lotti
	--									)
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

	--	--per voci singole si calcola il Valore Economico direttamente sul lotto
		
	--	select @IdLotto  =  O.ID 
	--		from Document_MicroLotti_Dettagli P
	--		inner join Document_PDA_OFFERTE d on d.idheader = p.idheader and d.IdMsgFornitore = @idMsgOfferta
	--		inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' 
	--														--and O.statoRiga in ('Valutato' , 'Conforme' ,  'verificasuperata' , 'Saved'  , '' , 'SospettoAnomalo' ) 
	--															and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
	--		where  
	--			--P.ID = @IdDoc and 
	--			P.IdHeader = @IdPDA and
	--			P.Voce = 0 and P.NumeroLotto = @NumeroLotto


	--	-- seguo il calcolo economico se è stata superata la soglia del punteggio minimo 
	--	set @strSql =  'Update 
	--		Document_MicroLotti_Dettagli
	--		set ValoreEconomico =   ' + @FormulaEconomica + ' 
	--		, ValoreImportoLotto = round( ' + 
					
	--					CASE 
	--						when @FieldQuantita <> '' and  @Criterio = '15536' /*prezzo*/ then  @FormulaEconomica + ' * ' + @FieldQuantita 
	--						when @FieldQuantita = '' and  @Criterio = '15536' /*prezzo*/ then  @FormulaEconomica 
	--						when @FieldQuantita <> '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * ' + @FormulaEconomica + ' ) / 100 ) ' + case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end
	--						when @FieldQuantita = '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * ' + @FormulaEconomica + ' ) / 100 ) ' 
									
	--						else '' 
								
	--					--end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
	--					end +  ' , 2 ) 
	--		, ValoreSconto =  ' + 
					
	--					CASE 
	--						when @Criterio <> '15536' /*percentuale*/ then  @FormulaEconomica 
	--						when @Criterio = '15536' /*prezzo*/ then  ' 100 - (  ' + case  when @FieldQuantita <> '' then ' ( ' + @FormulaEconomica + ' * ' + @FieldQuantita + ' ) ' else  @FormulaEconomica end  + ' /  ' + @FieldBaseAsta + ' ) * 100  ' 
									
	--						else '0' 
								
	--					--end +  ' , ' + cast( @NumeroDecimali as varchar ) + ' ) 
	--					end +  '  
	--		where tipodoc = ''PDA_OFFERTE''  and 
	--		id  = ' + cast( @IdLotto as varchar(20))

	--	--print @strSql
	--	exec ( @strSql )

	--	-- seguo il calcolo del ribasso 
	--	set @strSql =  'Update 
	--		Document_MicroLotti_Dettagli
	--			set ValoreRibasso = round( ' + @FieldBaseAsta + case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end + '  - ValoreImportoLotto  , 2 ) 
	--		where tipodoc = ''PDA_OFFERTE''  and 
	--		id  = ' + cast( @IdLotto as varchar(20))

	--	--print @strSql
	--	exec ( @strSql )



	--end
	--else
	--begin
		
	--	-- altrimenti si fa risalire il valore dalle righe
	--	select @IdLotto = O.ID ,@idOfferta =  O.idheader , @idHeaderLotto =  O.idHeaderLotto
	--		from Document_MicroLotti_Dettagli P
	--		inner join Document_PDA_OFFERTE d on d.idheader = p.idheader and d.IdMsgFornitore = @idMsgOfferta
	--		inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' 
	--													--and O.statoRiga in ('Valutato' , 'Conforme' , 'verificasuperata'  , 'Saved' , '' , 'SospettoAnomalo') 
	--													and P.NumeroLotto = O.NumeroLotto
	--													and O.Voce = 0
	--		where  
	--			P.IdHeader = @IdPDA and
	--			P.NumeroLotto = @NumeroLotto and
	--			P.Voce = 0 



	--	-- se il valore è al prezzo il valore economico si ottiene sommando il prezzo unitario per la QT se presente e riportandolo sulla voce 0
	--	if @Criterio = '15536'  -- prezzo
	--	begin
				

	--		set @strSql =  'Update 
	--			Document_MicroLotti_Dettagli
	--			set ValoreEconomico =   ' + @FormulaEconomica + CASE when @FieldQuantita <> '' then  ' * ' + @FieldQuantita else '' end +  '
	--			where tipodoc = ''PDA_OFFERTE''  and 
	--			idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--			idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--			Voce <> 0 '
						

	--		--print @strSql
	--		exec ( @strSql )
					
					
	--			Update Document_MicroLotti_Dettagli
	--				set ValoreEconomico =  round(  (	-- SOMMA DEI VALORI DELLE SINGOLE VOCI
	--											select sum( ValoreEconomico ) 
	--												from Document_MicroLotti_Dettagli 
	--													where tipodoc = 'PDA_OFFERTE'  and 
	--														idHeader  =  @idOfferta and
	--														idHeaderLotto = @idHeaderLotto and
	--														Voce <> 0 
	--										) , 2 )
	--				where id  = @IdLotto 

	--			Update Document_MicroLotti_Dettagli
	--				set ValoreImportoLotto = ValoreEconomico  

	--				where id  = @IdLotto 


	--		-- calcolo lo sconto applicato
	--		CREATE TABLE #TempValoriVociP
	--		(
	--			ValoreEconomicoVoce float NULL ,
	--			ValoreEconomicoBaseAsta  float null
	--		)
					

	--		set @strSql =  'insert into #TempValoriVociP (  ValoreEconomicoVoce ,  ValoreEconomicoBaseAsta )
	--			select 
	--				ValoreEconomico ,
	--					' + @FieldBaseAsta +  CASE when @FieldQuantita <> '' and @BaseAstaUnitaria = 1 then  ' * ' + @FieldQuantita else '' end +  '  as ValoreEconomicoBaseAsta   
	--			from Document_MicroLotti_Dettagli
	--			where tipodoc = ''PDA_OFFERTE''  and 
	--			idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--			idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--			Voce <> 0 '						

	--		--print @strSql
	--		exec ( @strSql )
					
					
	--		Update 
	--			Document_MicroLotti_Dettagli
	--				set ValoreSconto =   (	-- ricalcolo lo sconto sulla base asta
	--											select  (( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
	--																					/ 
	--															sum( ValoreEconomicoBaseAsta ) ) * 100 
	--												from #TempValoriVociP
	--									)
	--				, ValoreRibasso =    round ( (	select  ( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
																								
	--												from #TempValoriVociP
	--									) , 2 ) 
	--			where id  = @IdLotto 


						
	--		drop table #TempValoriVociP
				
	
	--	end
	--	else
	--	begin  -- sconto
				
	--		-- se il valore è come sconto il valore economico si ottiene trasformando la percentuale in prezzo, moltiplicando per le qt.
	--		-- anche il valore base asta unitaria per la qt e poi facendo il rapporto sui totali si ottiene la perc di 

	--		CREATE TABLE #TempValoriVoci
	--		(
	--			ValoreEconomicoVoce float NULL ,
	--			ValoreEconomicoBaseAsta  float null
	--		)
					
	--		set @strSql =  'insert into #TempValoriVoci ( ValoreEconomicoVoce , ValoreEconomicoBaseAsta )
	--			select 
						
	--					(' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * ' + @FormulaEconomica + ' / 100 ) )' + CASE when @FieldQuantita <> ''  and @BaseAstaUnitaria = 1 then  ' * ' + @FieldQuantita else '' end +  '   as ValoreEconomicoVoce   ,
	--					' + @FieldBaseAsta +  CASE when @FieldQuantita <> ''  and @BaseAstaUnitaria = 1 then  ' * ' + @FieldQuantita else '' end +  '  as ValoreEconomicoBaseAsta   
	--			from Document_MicroLotti_Dettagli
	--			where tipodoc = ''PDA_OFFERTE''  and 
	--			idHeader  = ' + cast( @idOfferta as varchar(20)) + ' and
	--			idHeaderLotto = ' + cast( @idHeaderLotto as varchar(20)) + ' and
	--			Voce <> 0 '
						

	--		--print @strSql
	--		exec ( @strSql )
					
					
	--		Update 
	--			Document_MicroLotti_Dettagli
	--				set ValoreEconomico =  (	-- ricalcolo lo sconto sulla base asta
	--											select  (( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
	--																					/ 
	--															sum( ValoreEconomicoBaseAsta ) ) * 100 
	--												from #TempValoriVoci
	--									)
	--					, ValoreImportoLotto = (	-- somo i valori delle singole voci
	--											select round(  sum( ValoreEconomicoVoce )  , 2 ) from #TempValoriVoci
	--									)
	--					, ValoreSconto = (	-- ricalcolo lo sconto sulla base asta
	--											select  (( sum( ValoreEconomicoBaseAsta ) - sum( ValoreEconomicoVoce ) ) 
	--																					/ 
	--															sum( ValoreEconomicoBaseAsta ) ) * 100 
	--												from #TempValoriVoci
	--									)
	--			where id  = @IdLotto 


	--		Update Document_MicroLotti_Dettagli
	--			set ValoreRibasso = ( select   sum( ValoreEconomicoBaseAsta ) from #TempValoriVoci ) - ValoreImportoLotto 
	--			where id  = @IdLotto 


	
	--		drop table #TempValoriVoci
					

	--	end

			
	--end




	declare @nRiportaBaseAstaUnitaria	int
	declare @divisione_lotti			varchar(50)
	declare @TipoDoc					varchar(200)

	declare @ValoreEconomico			float
	declare @ValoreSconto				float
	declare @ValoreRibasso				float
	declare @ValoreEconomicoBaseAsta	float
	declare @RigaZero					int

	declare @SorgenteVoce				varchar(50)
	declare @LottoVoce					varchar(50)

	create table #TempValori (  ValoreImportoLotto float )

	select @divisione_lotti = divisione_lotti from document_bando where idheader = @idBando

	if @divisione_lotti = '0' and exists( select * from ctl_doc_value where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
		set @RigaZero = 1
	else
		set @RigaZero = 0
			
	-----------------------------------------------------------------
	-- calcolo il valore offerto recuperandolo dalle voci se necessario
	-----------------------------------------------------------------
	select @LottoVoce =  l.Value 
			from CTL_DOC_VALUE a
				inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce' and l.DSE_ID = 'MODELLI'
				where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FormulaEconomica  and a.DSE_ID = 'MODELLI'
 	

	select @NR = count(*) from Document_MicroLotti_Dettagli where idheader = @IdPDA and Tipodoc =  'PDA_MICROLOTTI'


	if ( @divisione_lotti <> '0'  and @LottoVoce in ( 'Lotto' , 'LottoVoce' ))
		or 
		( @divisione_lotti = '0' and @RigaZero = 1 and @LottoVoce in ( 'Lotto' , 'LottoVoce' )) -- LE GARE SENZA LOTTI VENGONO PRESE DALLO VOCE ZERO SOLO SE PRESENTE E LA RICHIESTA DI COMPILAZIONE E PER LOTTO
		or 
		@divisione_lotti = '2' -- per le gare a lotti ma senza voci
		or
		(  @divisione_lotti = '0' and @RigaZero = 1 and isnull( @NR , 0 ) = 1 ) -- per le gare senza lotti che prevedono la sola riga zero i dati vanno presi dalla riga zero

		set @SorgenteVoce = ' = ''0'' '
	else
		set @SorgenteVoce = ' <> ''0'' '
	

	set @strSql =  'insert into #TempValori (  ValoreImportoLotto ) select round( sum (   ' + 
					
					CASE 
						when @FieldQuantita <> '' and  @Criterio = '15536' /*prezzo*/ then  'O.' + @FormulaEconomica + ' * O.' + @FieldQuantita 
						when @FieldQuantita = '' and  @Criterio = '15536' /*prezzo*/ then   ' cast ( O.' + @FormulaEconomica + ' as float ) '
						when @FieldQuantita <> '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  O.' + @FieldBaseAsta + ' - ( O.' + @FieldBaseAsta + ' * cast( O.' + @FormulaEconomica + ' as float ) ) / 100 ) ' + case when @BaseAstaUnitaria = 1 then ' * O.' + @FieldQuantita else '' end
						when @FieldQuantita = '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  O.' + @FieldBaseAsta + ' - ( O.' + @FieldBaseAsta + ' * cast( O.' + @FormulaEconomica + ' as float ) ) / 100 ) ' 
									
						else '' 
								
					end +  '  ) , 2 )
			from Document_MicroLotti_Dettagli P
			inner join Document_PDA_OFFERTE d on d.idheader = p.idheader and d.IdMsgFornitore = ' + cast( @idMsgOfferta as varchar(30)) + '
			inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = ''PDA_OFFERTE''
														and P.NumeroLotto = O.NumeroLotto
			where  
				P.tipodoc = ''PDA_MICROLOTTI''  and 
				P.IdHeader = ' + cast( @IdPDA as varchar(30)) + ' and
				P.NumeroLotto = ' + @NumeroLotto + ' and
				P.Voce = 0
				and (( isnull( O.Voce , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + ''' <> ''0'' ) or ( isnull( O.numeroriga , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + '''  = ''0'' ) )'

		
	exec ( @strSql )
	--print @strSql

	select  @ValoreEconomico = sum( ValoreImportoLotto ) from #TempValori
														
	truncate table #TempValori


	-----------------------------------------------------------------
	-- calcolo il valore base asta  recuperandolo dalle voci se necessario
	-----------------------------------------------------------------
	select @LottoVoce =  l.Value 
			from CTL_DOC_VALUE a
				inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'  and l.DSE_ID = 'MODELLI'
				where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FieldBaseAsta  and a.DSE_ID = 'MODELLI'
						--and  l.Value in ( 'Lotto' , 'LottoVoce' )


	if ( @divisione_lotti <> '0'  and @LottoVoce in ( 'Lotto' , 'LottoVoce' ))
		or 
		( @divisione_lotti = '0' and @RigaZero = 1 and @LottoVoce in ( 'Lotto' , 'LottoVoce' )) -- LE GARE SENZA LOTTI VENGONO PRESE DALLO VOCE ZERO SOLO SE PRESENTE E LA RICHIESTA DI COMPILAZIONE E PER LOTTO
		or 
		@divisione_lotti = '2' -- per le gare a lotti ma senza voci
		or
		(  @divisione_lotti = '0' and @RigaZero = 1 and isnull( @NR , 0 ) = 1 ) -- per le gare senza lotti che prevedono la sola riga zero i dati vanno presi dalla riga zero

		set @SorgenteVoce = ' = ''0'' '
	else
		set @SorgenteVoce = ' <> ''0'' '
	

	--set @strSql =  'insert into #TempValori (  ValoreImportoLotto ) select sum (  round( O.' + @FieldBaseAsta + ' , 2 ) ) 
	--		from Document_MicroLotti_Dettagli P
	--		inner join Document_PDA_OFFERTE d on d.idheader = p.idheader and d.IdMsgFornitore = ' + cast( @idMsgOfferta as varchar(30)) + '
	--		inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = ''PDA_OFFERTE''
	--													and P.NumeroLotto = O.NumeroLotto
	--		where  
	--			P.tipodoc = ''PDA_MICROLOTTI''  and 
	--			P.IdHeader = ' + cast( @IdPDA as varchar(30)) + ' and
	--			P.NumeroLotto = ' + @NumeroLotto + ' and
	--			P.Voce = 0
	--			and (( isnull( O.Voce , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + ''' <> ''0'' ) or ( isnull( O.numeroriga , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + '''  = ''0'' ) )'

	set @strSql =  'insert into #TempValori (  ValoreImportoLotto ) select  round( sum (  P.' + @FieldBaseAsta + '  ) , 2 ) 
			from Document_MicroLotti_Dettagli P
			where  
				P.tipodoc = ''PDA_MICROLOTTI''  and 
				P.IdHeader = ' + cast( @IdPDA as varchar(30)) + ' and
				P.NumeroLotto = ' + @NumeroLotto + ' and
				(( isnull( P.Voce , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + ''' <> ''0'' ) or ( isnull( P.numeroriga , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + '''  = ''0'' ) )'

		
	exec ( @strSql )
	--print @strSql

	select  @ValoreEconomicoBaseAsta = sum( ValoreImportoLotto ) from #TempValori
														
	drop table #TempValori


	-----------------------------------------------------------------
	-- ricalcolo lo sconto sulla base asta
	-----------------------------------------------------------------

	set @ValoreSconto  = (( @ValoreEconomicoBaseAsta - @ValoreEconomico ) / @ValoreEconomicoBaseAsta ) * 100 
	set @ValoreRibasso = @ValoreEconomicoBaseAsta -@ValoreEconomico

	-- in valore offerto metto lo sconto o il @ValoreEconomico in funzione se il criterio è prezzo o percentuale

	select @IdLotto  =  O.ID 
		from Document_MicroLotti_Dettagli P
		inner join Document_PDA_OFFERTE d on d.idheader = p.idheader and d.IdMsgFornitore = @idMsgOfferta
		inner join Document_MicroLotti_Dettagli O on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' 
															and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
		where  
			P.IdHeader = @IdPDA and
			P.TipoDoc = 'PDA_MICROLOTTI' and 
			P.Voce = 0 and P.NumeroLotto = @NumeroLotto

	Update 
		Document_MicroLotti_Dettagli
			set   ValoreEconomico			=  case when  @Criterio = '15536' /*prezzo*/  then @ValoreEconomico else @ValoreSconto end
				, ValoreImportoLotto	= @ValoreEconomico
				, ValoreSconto			= @ValoreSconto
				, ValoreRibasso			= @ValoreRibasso
		where id  = @IdLotto 


	-- nel caso in cui la compilazione dell'offerta è espressa in percentuale ed il dato è stato richiesto per lotto o lottovoce ( quindi direttamente inserito per la riga zero ) allora lo sconto non si desume dal rapporto ma si prende direttamente quello della cella richiesta
	-- abbiamo leggermente rivisto la considerazione perchè se l'offerta è richiesta in percentuale la colonna è a video ed in questo caso è coerente prendere il dato mostrato piuttosto che ricalcolato
	if		
		@Criterio <> '15536' /*percentuale*/
		--and
		--@SorgenteVoce = ' = ''0'' ' -- dato recuperato dalla riga zero, le considerazioni sono state fatte poco sopra

	begin
		set @strSql =' update Document_MicroLotti_Dettagli set ValoreSconto = ' +  @FormulaEconomica + ' where id = ' + cast ( @IdLotto as varchar(20) )
		exec ( @strSql )
	end



end
















GO
