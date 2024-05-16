USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_COLONNE_CALCOLATE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[OLD_COLONNE_CALCOLATE]( @idDoc int ) 
as
begin

	set nocount on
	--declare @iddoc				int
	declare @idDocModello		int
	declare @DZT_Name			varchar(200)
	declare @Formula			nvarchar(max)
	declare @FormuladaCalcolare nvarchar(max)
	
	declare @Aggregazione		varchar(100)
	declare @divisione_lotti	varchar(10)
	
	declare @Cod				varchar(200)
	declare @modellobando		varchar(200)
	declare @TipoDoc			varchar(200)
	declare @Select				nvarchar(max)
	declare @idRowDett			int
	declare @Colonna			varchar(200)

	declare @Attributo			varchar(200) 
	declare @Selezione			varchar(200)
	declare @Descrizione		nvarchar(max)
	declare @LottoVoce			varchar(100)
	declare @Complex			varchar(100)
	declare @idBando			int
	declare @LinkedDoc			int
	declare @numero_decimali_modello INT

	declare @idHeaderLottoOfferto int
	declare @IdPdA int

	declare @ValoreDaEstrarre	float
	declare @SQL				nvarchar(max)
	declare @TipoDocModello as varchar (100)

	set @TipoDocModello='CONFIG_MODELLI_LOTTI'

	--set @iddoc	= 142900--<ID_DOC>

	select @TipoDoc = TipoDoc , @LinkedDoc = LinkedDoc from CTL_DOC where id = @iddoc


	if @Tipodoc in ( 'BANDO_SDA' )
	begin
		set @Colonna = 'MOD_Bando'
		set @idBando = @idDoc
	end
	else if @Tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA' )
	begin
		set @Colonna = 'MOD_BandoSempl'
		set @idBando = @idDoc	end
	else if @Tipodoc in ( 'OFFERTA' ,'OFFERTA_ASTA' )
	begin
		set @Colonna = 'MOD_OffertaInput'
		set @idBando = @LinkedDoc
	end
	else if @Tipodoc in ( 'PDA_COMUNICAZIONE_OFFERTA_RISP' )
	begin
		set @Colonna = 'MOD_Offerta'
		select   @idBando=CPDA.LinkedDoc	
		  from ctl_doc C --PDA_COMUNICAZIONE_OFFERTA_RISP
		  inner join ctl_doc C1 on C1.id=C.LinkedDoc --PDA_COMUNICAZIONE_OFFERTA
		  inner join ctl_doc C2 on C2.id=C1.LinkedDoc --PDA_COMUNICAZIONE
		  inner join ctl_doc CPDA on CPDA.id=C2.LinkedDoc --PDA_MICROLOTTI
		where C.id = @idDoc 
	end
	else if @Tipodoc in ( 'RETT_VALORE_ECONOMICO' )
	begin
		
		set @Colonna = 'MOD_Offerta' --perchè non dove toccare la parte tecnica
		
		--recupero id header lotto offerto
		select @idHeaderLottoOfferto=idheader from document_microlotti_dettagli where id=@LinkedDoc
		
		--recupero idpda
		select @IdPdA=idheader from DOCUMENT_PDA_OFFERTE where idrow=@idHeaderLottoOfferto
		
		--recupero idbando
		select @idBando=linkeddoc from ctl_doc where id=@IdPdA

		--setto il tipodoc per il recupero delle righe da modificare
		set @TipoDoc='RETT_VALORE_ECONOMICO_DEST'
	end
	else if @Tipodoc = 'CONVENZIONE'
	begin
		
		set @Colonna = 'MOD_Convenzione'
		set @idBando = @idDoc
			
		set @TipoDocModello = 'CONFIG_MODELLI'

	end
	else if @Tipodoc = 'LISTINO_CONVENZIONE'
	begin
		
		set @Colonna = 'MOD_PerfListino'
		set @idBando = @LinkedDoc
			
		set @TipoDocModello = 'CONFIG_MODELLI'

	end 
	else if @Tipodoc in ( 'CONVENZIONE_ADD_PRODOTTI' , 'CONVENZIONE_UPD_PRODOTTI')
	begin
		
		set @Colonna = 'MOD_Convenzione'
		set @idBando = @LinkedDoc
			
		set @TipoDocModello = 'CONFIG_MODELLI'

	end
	
	-- debug
	--print @Colonna


	select @Cod = b.TipoBando ,@divisione_lotti = divisione_lotti , @Complex = Complex from Document_Bando b  where b.idHeader = @idBando
	
	select @idDocModello = id from ctl_doc where tipodoc = @TipoDocModello and deleted = 0 and linkeddoc = @idBando
	
	-- debug
	--print @idDocModello

	--recupero modello bando associato
	select @modellobando=modellobando + '_LOTTI' from Document_Modelli_MicroLotti where codice=@Cod


	-- partendo dal modello si cicla su tutte le colonne da calcolare
	-- ciclo per ogni colonna da calcolare se è da calcolare
	declare CurProg Cursor static for 
		Select v1.Value as DZT_Name , v2.Value as Formula , v3.Value as Aggregazione,c3.Value as numero_decimali_modello
			from CTL_DOC_Value v1
				inner join CTL_DOC_VALUE v2 on v1.idheader = v2.idheader and v1.DSE_ID = v2.DSE_ID and v1.Row = v2.Row and v2.dzt_name = 'Formula'
				inner join CTL_DOC_VALUE v3 on v1.idheader = v3.idheader and v1.DSE_ID = v3.DSE_ID and v1.Row = v3.Row and v3.dzt_name = 'Aggregazione'

				-- controlla che la colonna nel modello del tipo documento sia da calcolare
				inner join CTL_DOC_VALUE c1 on v1.idheader = c1.idheader and c1.DSE_ID = 'MODELLI' and c1.DZT_Name = 'DZT_Name' and c1.Value = v1.Value
				inner join CTL_DOC_VALUE c2 on v1.idheader = c2.idheader and c2.DSE_ID = 'MODELLI' and c2.DZT_Name = @Colonna and c2.Value = 'calc' and c1.row = c2.row
				left join CTL_DOC_VALUE c3 on  c3.IdHeader = c2.IdHeader and c3.DSE_ID = 'MODELLI' and c3.row = c2.row and c3.DZT_Name='Numero_Decimali'
			where v1.idHeader=@idDocModello and v1.DSE_ID = 'CALCOLI' and v1.DZT_Name = 'DZT_Name'
			order by v1.Row
	
	open CurProg

	FETCH NEXT FROM CurProg INTO @DZT_Name , @Formula , @Aggregazione,@numero_decimali_modello
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- debug
		--print @DZT_Name
		--print @Formula
		--print @Aggregazione

		set @LottoVoce = dbo.ConditionLottoVoceModello(  @idDocModello , @DZT_Name , @divisione_lotti )
		--print '@LottoVoce - ' + @LottoVoce

		-- si crea l'indice delle righe da ciclare per fare i calcoli
		-- per ogni riga del documento del tipo coerente con lotto / voce
		create table #Temp ( id  int )
		set @Select = 'insert into #Temp ( id ) select id from document_microlotti_dettagli where idheader = ' + cast( @idDoc as varchar(20)) + ' and Tipodoc = ''' + @TipoDoc + ''' ' +  @LottoVoce 
		--print @Select
		EXEC ( @Select )

		-- debug
		--select * from #Temp


		declare CurRowDett Cursor static for 
			Select id from #Temp
				order by id

		open CurRowDett

		FETCH NEXT FROM CurRowDett  INTO @idRowDett
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- si prende la formula
			set @FormulaDaCalcolare = @Formula
			--print @FormulaDaCalcolare
			-- si prova a sostituire tutti gli attributi del modello nella formula e si calcola la riga
			declare CurDZT_Name Cursor static for 
				Select v1.Value as DZT_Name , v2.Value as Selezione , v3.Value as Descrizione
					from CTL_DOC_Value v1
						inner join CTL_DOC_VALUE v2 on v1.idheader = v2.idheader and v1.DSE_ID = v2.DSE_ID and v1.Row = v2.Row and v2.dzt_name = @Colonna
						inner join CTL_DOC_VALUE v3 on v1.idheader = v3.idheader and v1.DSE_ID = v3.DSE_ID and v1.Row = v3.Row and v3.dzt_name = 'Descrizione'
					where v1.idHeader=@idDocModello and v1.DSE_ID = 'MODELLI' and v1.DZT_Name = 'DZT_Name'
					order by v1.Row

			open CurDZT_Name 

			FETCH NEXT FROM CurDZT_Name INTO @Attributo , @Selezione , @Descrizione
			WHILE @@FETCH_STATUS = 0
			BEGIN

				

				if charindex(  '[' + @Descrizione + ']' , @FormulaDaCalcolare  ) > 0 
				begin

					create table #Temp2 ( ValoreDaEstrarre  float)
					set @SQL = ' insert into #Temp2 ( ValoreDaEstrarre ) select ISNULL(' + @Attributo + ',0) from Document_microlotti_dettagli where id = ' + cast( @idRowDett as varchar (20))
					
					-- debug
					--print @Sql  


					exec( @Sql  )
					select @ValoreDaEstrarre  = ValoreDaEstrarre from #Temp2
					drop Table #Temp2

					set @FormulaDaCalcolare  = replace( @FormulaDaCalcolare , '[' + @Descrizione + ']' , '(' + str( @ValoreDaEstrarre , 20 , 20 ) + ')' ) 
				end


				FETCH NEXT FROM CurDZT_Name INTO @Attributo , @Selezione , @Descrizione
			END 
			CLOSE CurDZT_Name 
			DEALLOCATE CurDZT_Name 

			--inizializzo valore a null
			set @SQL = 'update document_microlotti_dettagli set ' + @DZT_Name + ' =  null where id = ' + cast( @idRowDett as varchar (20))
			--print @SQL
			exec( @SQL )

			--print @FormulaDaCalcolare
			-- compongo l'istruzione per aggiornare la colonna
			set @SQL = '
						BEGIN TRY 
							update document_microlotti_dettagli set ' + @DZT_Name + ' =  dbo.AF_PARSER(   ''' + @FormulaDaCalcolare + ''' ) where id = ' + cast( @idRowDett as varchar (20)) 
						
						+ '

						END TRY
						BEGIN CATCH  
						END CATCH
						'
			-- debug
			--print @SQL

			exec( @SQL )
			if ISNULL(@numero_decimali_modello,-1)>=0
			BEGIN
			set @SQL = '
						BEGIN TRY 
							update document_microlotti_dettagli set ' + @DZT_Name + ' =  dbo.AFS_ROUND(   ' + @DZT_Name + ',' + cast(@numero_decimali_modello as varchar(100)) + ' ) where id = ' + cast( @idRowDett as varchar (20))
						+ '
						
						END TRY
						BEGIN CATCH  
						END CATCH
						'
				-- debug
				--print @SQL

				exec( @SQL )
			END   

			FETCH NEXT FROM CurRowDett  INTO @idRowDett
		END 
		CLOSE CurRowDett 
		DEALLOCATE CurRowDett 

		drop table #Temp



		---- se la formula è a livello di voce si riporta a livello di lotto solo se non c'è la variante
		--if @LottoVoce = ' and Voce <> 0 ' and not ( @Tipodoc in ( 'BANDO_SEMPLIFICATO' , 'BANDO_GARA' , 'BANDO_ASTA' ) and @Complex = '1' )
		--begin

		--	set @SQL = 'update document_microlotti_dettagli set ' + @DZT_Name + ' = ValoreAggregato 
		--		from document_microlotti_dettagli 
		--			inner join ( select ' + case when @Aggregazione = 'somma' then ' sum ' else ' avg ' end + ' ( cast( ' + @DZT_Name + ' as float ) ) as ValoreAggregato , NumeroLotto as N_Lotto
		--							from document_microlotti_dettagli where idheader = ' + cast( @idDoc  as varchar(20)) + ' and Tipodoc = ''' + @Tipodoc + ''' and Voce <> 0 group by NumeroLotto 
		--							) as a on a.N_Lotto = NumeroLotto
		--				where idheader = ' + cast( @idDoc  as varchar(20)) + ' and Tipodoc = ''' + @Tipodoc + ''' and Voce = 0  
		--		'
		--		--print @SQL
		--		exec( @SQL ) 

		--end
		 
		FETCH NEXT FROM CurProg INTO @DZT_Name , @Formula , @Aggregazione,@numero_decimali_modello
	END 
	CLOSE CurProg
	DEALLOCATE CurProg



end



















GO
