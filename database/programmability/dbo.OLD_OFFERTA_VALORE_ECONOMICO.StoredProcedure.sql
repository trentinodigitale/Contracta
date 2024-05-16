USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OFFERTA_VALORE_ECONOMICO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Proc [dbo].[OLD_OFFERTA_VALORE_ECONOMICO] (  @idDoc int )
as
begin

	declare @IdLotto as Int 
	--declare @IdPFU as Int 
	declare @IdPDA as Int 
	--declare @IdCom as Int 
	--declare @pfuIdLng as Int 
	--declare @Allegato as Varchar(255) 
	declare @StatoRiga as Varchar(255) 
	declare @NumeroLotto as Varchar(255) 

	--declare @idDoc int
	declare @Criterio as varchar(100)
	--declare @TipoDoc as varchar(100)
	--declare @Fascicolo as varchar(100)

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

	declare @nRiportaBaseAstaUnitaria	int
	declare @divisione_lotti			varchar(50)
	declare @TipoDoc					varchar(200)
	declare @TipoDocBando					varchar(200)

	declare @ValoreEconomico			float
	declare @ValoreSconto				float
	declare @ValoreRibasso				float
	declare @ValoreEconomicoBaseAsta	float
	declare @RigaZero					int

	--declare @idDoc int
	--set @idDoc = 73540

	--select @IdPDA = idheader , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli where id = @IdDoc
	select @idBando = linkedDoc , @TipoDoc = Tipodoc from CTL_DOC where id = @IdDoc
	if @TipoDoc='PDA_COMUNICAZIONE_OFFERTA_RISP'
	BEGIN
	    select   @idBando=CPDA.LinkedDoc
		  from ctl_doc C --PDA_COMUNICAZIONE_OFFERTA_RISP
			  inner join ctl_doc C1 on C1.id=C.LinkedDoc --PDA_COMUNICAZIONE_OFFERTA
			  inner join ctl_doc C2 on C2.id=C1.LinkedDoc --PDA_COMUNICAZIONE
			  inner join ctl_doc CPDA on CPDA.id=C2.LinkedDoc --PDA_MICROLOTTI
	    where C.id = @idDoc 
	END

	if @TipoDoc='RETT_VALORE_ECONOMICO'
	BEGIN
		
		 select   @idBando=CPDA.LinkedDoc
		  from ctl_doc C --RETT_VALORE_ECONOMICO
			  inner join document_microlotti_dettagli C1 on C1.id=C.LinkedDoc --PDA_OFFERTE
			  inner join Document_PDA_OFFERTE PO on PO.idrow = C1.IdHeader -- OFFERTE DULLA PDA
			  inner join ctl_doc CPDA on CPDA.id=PO.IdHeader --PDA_MICROLOTTI
	    where C.id = @idDoc 

		set @TipoDoc = 'RETT_VALORE_ECONOMICO_DEST'

	END
	

	-- determino il criterio di aggiudicazione della gara
	select  @Criterio = criterioformulazioneofferte , @ListaModelliMicrolotti = TipoBando , @NumeroDecimali = isnull( NumDec , 5 ) , @BaseAstaUnitaria = isnull( BaseAstaUnitaria , 0 ) 
				, @divisione_lotti = divisione_lotti
		from Document_Bando 
		where idheader = @idBando

	select @TipoDocBando = TipoDoc from ctl_doc where id = @idBando
 
 	if exists( select * from ctl_doc_value where idheader = @idBando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1' )
		set @RigaZero = 1
	else
		set @RigaZero = 0

	select @FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
		from Document_Modelli_MicroLotti_Formula 
		where @Criterio = CriterioFormulazioneOfferte
			and @ListaModelliMicrolotti = Codice


	declare @IdDocModello int
	select @IdDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and linkeddoc = @idBando
	


	set @MultiVoce = 0
	
	-- se esiste un record con voce o numero riga diverso da zero
	if exists( select id from Document_MicroLotti_Dettagli where idheader = @idDoc and TipoDoc = @TipoDoc and  ( isnull( voce , 0 )  = 1 or isnull(numeroriga , 0 ) = 1 ))
		set @MultiVoce = 1


	create table #TempValori ( NumeroLotto varchar(50) collate DATABASE_DEFAULT,  ValoreImportoLotto float )
	declare @SorgenteVoce varchar(50)
	declare @LottoVoce varchar(50)
	

	-----------------------------------------------------------------
	-- calcolo il valore offerto recuperandolo dalle voci se necessario
	-----------------------------------------------------------------
	select @LottoVoce =  l.Value 
			from CTL_DOC_VALUE a
				inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce'  and l.DSE_ID = 'MODELLI'
				where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FormulaEconomica and a.DSE_ID = 'MODELLI'
			

	

	if ( @divisione_lotti <> '0'  and @LottoVoce in ( 'Lotto' , 'LottoVoce' ))
		or 
		( @divisione_lotti = '0' and @RigaZero = 1 and @LottoVoce in ( 'Lotto' , 'LottoVoce' )) -- LE GARE SENZA LOTTI VENGONO PRESE DALLO VOCE ZERO SOLO SE PRESENTE E LA RICHIESTA DI COMPILAZIONE E PER LOTTO
		or 
		@divisione_lotti = '2' -- per le gare a lotti ma senza voci
		or
		@divisione_lotti = '0' and  @MultiVoce = 0 --  la gara è senza lotti ma è presente la sola riga zero 

		set @SorgenteVoce = ' = ''0'' '
	else
		set @SorgenteVoce = ' <> ''0'' '
	

	set @strSql =  'insert into #TempValori ( NumeroLotto ,  ValoreImportoLotto ) select isnull( NumeroLotto , ''1'' ) as NumeroLotto , dbo.AFS_ROUND( sum (   ' + 
					
					CASE 
						when @FieldQuantita <> '' and  @Criterio = '15536' /*prezzo*/ then  @FormulaEconomica + ' * ' + @FieldQuantita 
						when @FieldQuantita = '' and  @Criterio = '15536' /*prezzo*/ then   ' cast ( ' + @FormulaEconomica + ' as float ) '
						when @FieldQuantita <> '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * cast( ' + @FormulaEconomica + ' as float ) ) / 100 ) ' + case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end
						when @FieldQuantita = '' and  @Criterio <> '15536' /*percentuale*/ then  ' (  ' + @FieldBaseAsta + ' - ( ' + @FieldBaseAsta + ' * cast( ' + @FormulaEconomica + ' as float ) ) / 100 ) ' 
									
						else '' 
								
					end +  '  ) , 2 )
			from Document_MicroLotti_Dettagli
			where tipodoc = ''' + @TipoDoc  + '''  and 
				idheader  = ' + cast( @idDoc as varchar(20))
				+ ' and (( isnull( Voce , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + ''' <> ''0'' ) or ( isnull( numeroriga , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + '''  = ''0'' ) )
			group by isnull( NumeroLotto , ''1'' ) 
				'

	print (@FormulaEconomica)	
	exec ( @strSql )

	select  @ValoreEconomico = sum( ValoreImportoLotto ) from #TempValori
														

	-- aggiorno il valore di ogni lotto sulle righe dell'offerta -- viene poi cifrato dal modello
	set @strSql = 'update Document_MicroLotti_Dettagli set ValoreImportoLotto = vil 
					from Document_MicroLotti_Dettagli
						inner join ( select NumeroLotto as nl ,  ValoreImportoLotto as vil from  #TempValori  ) as a on nl = NumeroLotto 
						where tipodoc = ''' + @TipoDoc  + '''  and 
						idheader  = ' + cast( @idDoc as varchar(20)) + ' and Voce = 0
					'
	exec ( @strSql )


	-----------------------------------------------------------------
	-- se la gara prevede la compilazione dei dati sulle voci, non è richiesta la qt ed è al prezzo
	-- si riporta il valore anche nella colonna che esprime il valore economico del lotto
	-----------------------------------------------------------------
	if 	 @Criterio = '15536' /*prezzo*/ and @FieldQuantita = '' and @SorgenteVoce = ' <> ''0'' '
	begin

		-- se la colonna di destinazione è un INT la funzione STR genera una eccezione
		if exists( select 	s.name  from syscolumns c 	inner join sysobjects o on o.id = c.id 	inner join systypes s on c.xusertype = s.xusertype where o.name = 'Document_MicroLotti_Dettagli' and s.name ='int' and c.name = @FormulaEconomica ) 
			set @strSql = 'update Document_MicroLotti_Dettagli set ' + @FormulaEconomica + ' = cast( vil  as int ) '
		else
			set @strSql = 'update Document_MicroLotti_Dettagli set ' + @FormulaEconomica + ' = str( vil  , 40 , 20 ) '
		
		set @strSql = @strSql + '
						from Document_MicroLotti_Dettagli
							inner join ( select NumeroLotto as nl ,  ValoreImportoLotto as vil from  #TempValori  ) as a on nl = NumeroLotto 
							where tipodoc = ''' + @TipoDoc  + '''  and 
							idheader  = ' + cast( @idDoc as varchar(20)) + ' and Voce = 0
						'
		exec ( @strSql )

	end


	truncate table #TempValori

	-----------------------------------------------------------------
	-- calcolo il valore base asta  recuperandolo dalle voci se necessario
	-----------------------------------------------------------------
	select @LottoVoce =  l.Value 
			from CTL_DOC_VALUE a
				inner join CTL_DOC_VALUE l on a.IdHeader = l.IdHeader and  a.Row = l.Row and l.DZT_Name = 'LottoVoce' and l.DSE_ID = 'MODELLI'
				where a.idheader = @IdDocModello and a.DZT_Name = 'DZT_Name' and a.value = @FieldBaseAsta and a.DSE_ID = 'MODELLI'
						--and  l.Value in ( 'Lotto' , 'LottoVoce' )


	if ( @divisione_lotti <> '0'  and @LottoVoce in ( 'Lotto' , 'LottoVoce' ))
		or 
		( @divisione_lotti = '0' and @RigaZero = 1 and @LottoVoce in ( 'Lotto' , 'LottoVoce' )) -- LE GARE SENZA LOTTI VENGONO PRESE DALLO VOCE ZERO SOLO SE PRESENTE E LA RICHIESTA DI COMPILAZIONE E PER LOTTO
		or 
		@divisione_lotti = '2' -- per le gare a lotti ma senza voci
		or
		@divisione_lotti = '0' and  @MultiVoce = 0 --  la gara è senza lotti ma è presente la sola riga zero 

		set @SorgenteVoce = ' = ''0'' '
	else
		set @SorgenteVoce = ' <> ''0'' '
	

	set @strSql =  'insert into #TempValori (  ValoreImportoLotto ) select dbo.AFS_ROUND(  sum (  ' + @FieldBaseAsta +  case when @BaseAstaUnitaria = 1 then ' * ' + @FieldQuantita else '' end+ '  ), 2  )
					from Document_MicroLotti_Dettagli
					where tipodoc = ''' + @TipoDocBando  + '''  and 
						idheader  = ' + cast( @idBando as varchar(20))
				+ ' and (( isnull( Voce , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + ''' <> ''0'' ) or ( isnull( numeroriga , 0 ) ' + @SorgenteVoce + ' and ''' + @divisione_lotti + '''  = ''0'' ) )'

	-- nel caso di gare a lotti la base asta è da considerare solo per i lotti dove si risponde
	if @divisione_lotti <> '0'
	begin
		set @strSql =  @strSql + ' and numerolotto in ( select distinct numerolotto from Document_MicroLotti_Dettagli where tipodoc = ''' + @TipoDoc  + '''  and idheader  = ' + cast( @idDoc as varchar(20)) + ' )  '
	end

	exec ( @strSql )

	select  @ValoreEconomicoBaseAsta = sum( ValoreImportoLotto ) from #TempValori
														
	drop table #TempValori





	-----------------------------------------------------------------
	-- ricalcolo lo sconto sulla base asta
	-----------------------------------------------------------------

	set @ValoreSconto  = (( @ValoreEconomicoBaseAsta - @ValoreEconomico ) / @ValoreEconomicoBaseAsta ) * 100 
	set @ValoreRibasso = @ValoreEconomicoBaseAsta -@ValoreEconomico

												

	-----------------------------------------------------------------
	-- aggiorno i dati dell'offerta
	-----------------------------------------------------------------
	delete from CTL_DOC_VALUE where idheader = @idDoc and dzt_name in ( 'ValoreRibasso', 'ValoreEconomico', 'ValoreSconto' ,'ValoreEconomicoBaseAsta' ) and [DSE_ID] = 'TOTALI'
	insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value ) values (@idDoc , 'TOTALI' , 0 ,  'ValoreRibasso' , str(  @ValoreRibasso , 30 , 20 ) )
	insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value ) values (@idDoc , 'TOTALI' , 0 , 'ValoreEconomico', str( @ValoreEconomico , 30 , 20 ) )
	insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value ) values (@idDoc , 'TOTALI' , 0 ,  'ValoreSconto' , str( @ValoreSconto , 30 , 20 ) )
	insert into CTL_DOC_VALUE ( idheader ,DSE_ID , [Row] , DZT_Name , Value ) values (@idDoc , 'TOTALI' , 0 ,  'ValoreEconomicoBaseAsta' , str( @ValoreEconomicoBaseAsta ,30 , 20 ))
	



end







































GO
