USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_COLONNE_CALCOLATE_AMPIEZZA_DI_GAMMA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE procedure [dbo].[OLD_COLONNE_CALCOLATE_AMPIEZZA_DI_GAMMA]( @idDoc int ) 
as
begin

	set nocount on

	declare @idOfferta int
	declare @idmodAcquisto as int 
	declare @idModAmpGamma as Int
	declare @idBando INT
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
	declare @LinkedDoc			int
	declare @numero_decimali_modello INT
	declare @idHeaderLottoOfferto int
	declare @IdPdA int
	declare @ValoreDaEstrarre	float
	declare @SQL				nvarchar(max)
	declare @TipoDocModello as varchar (100)
	declare @JumpCheck as varchar (100)

	select  @idOfferta = LinkedDoc, @TipoDoc = TipoDoc from ctl_doc with(nolock) where id = @idDoc 

	select @idbando = LinkedDoc	from ctl_doc with(nolock) where id = @idOfferta

	select @idmodAcquisto = Value from ctl_doc_value with(nolock) where IdHeader = @idbando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello'
	
	select @idModAmpGamma = Value from ctl_doc_value with(nolock) where IdHeader = @idmodAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma'

	declare CurProg Cursor static for 
	Select v1.Value as DZT_Name , v2.Value as Formula, c3.Value as numero_decimali_modello
			from CTL_DOC_Value v1
				inner join CTL_DOC_VALUE v2 on v1.idheader = v2.idheader and v1.DSE_ID = v2.DSE_ID and v1.Row = v2.Row and v2.dzt_name = 'Formula'
				-- controlla che la colonna nel modello del tipo documento sia da calcolare
				inner join CTL_DOC_VALUE c1 on v1.idheader = c1.idheader and c1.DSE_ID = 'MODELLI' and c1.DZT_Name = 'DZT_Name' and c1.Value = v1.Value
				inner join CTL_DOC_VALUE c2 on v1.idheader = c2.idheader and c2.DSE_ID = 'MODELLI' and c2.DZT_Name='MOD_OffertaINPUT' and c2.Value = 'calc' and c1.row = c2.row
				left join CTL_DOC_VALUE c3 on  c3.IdHeader = c2.IdHeader and c3.DSE_ID = 'MODELLI' and c3.row = c2.row and c3.DZT_Name='Numero_Decimali'
			where v1.idHeader=@idModAmpGamma and v1.DSE_ID = 'CALCOLI' and v1.DZT_Name = 'DZT_Name'
			order by v1.Row

	open CurProg

	FETCH NEXT FROM CurProg INTO @DZT_Name , @Formula, @numero_decimali_modello
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		-- si crea l'indice delle righe da ciclare per fare i calcoli
		-- per ogni riga del documento 
		create table #Temp ( id  int )
		set @Select = 'insert into #Temp ( id ) select id from document_microlotti_dettagli where Tipodoc = ''' + @TipoDoc + ''' and idheader = ' + cast( @idDoc as varchar(20))
	
		EXEC ( @Select )

		declare CurRowDett Cursor static for 
			Select id from #Temp
				order by id

			open CurRowDett

			FETCH NEXT FROM CurRowDett  INTO @idRowDett
			WHILE @@FETCH_STATUS = 0
			BEGIN
				set @FormulaDaCalcolare = @Formula

				-- si prova a sostituire tutti gli attributi del modello nella formula e si calcola la riga
				declare CurDZT_Name Cursor static for 
					Select v1.Value as DZT_Name , v2.Value as Selezione , v3.Value as Descrizione
						from CTL_DOC_Value v1
							inner join CTL_DOC_VALUE v2 on v1.idheader = v2.idheader and v1.DSE_ID = v2.DSE_ID and v1.Row = v2.Row and v2.dzt_name = 'MOD_OffertaINPUT'
							inner join CTL_DOC_VALUE v3 on v1.idheader = v3.idheader and v1.DSE_ID = v3.DSE_ID and v1.Row = v3.Row and v3.dzt_name = 'Descrizione'
						where v1.idHeader=@idModAmpGamma and v1.DSE_ID = 'MODELLI' and v1.DZT_Name = 'DZT_Name'
						order by v1.Row

				open CurDZT_Name 

				FETCH NEXT FROM CurDZT_Name INTO @Attributo , @Selezione , @Descrizione
				WHILE @@FETCH_STATUS = 0
				BEGIN

				if charindex(  '[' + @Descrizione + ']' , @FormulaDaCalcolare  ) > 0 
				begin

					create table #Temp2 ( ValoreDaEstrarre  float)
					set @SQL = ' insert into #Temp2 ( ValoreDaEstrarre ) select ISNULL(' + @Attributo + ',0) from Document_microlotti_dettagli where Tipodoc = ''' + @TipoDoc + ''' and id = ' + cast( @idRowDett as varchar (20))
					
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
			set @SQL = 'update document_microlotti_dettagli set ' + @DZT_Name + ' =  null where Tipodoc = ''' + @TipoDoc + ''' and id = ' + cast( @idRowDett as varchar (20))
			--print @SQL
			exec( @SQL )

			--print @FormulaDaCalcolare
			-- compongo l'istruzione per aggiornare la colonna
			set @SQL = '
						BEGIN TRY 
							update document_microlotti_dettagli set ' + @DZT_Name + ' =  dbo.AF_PARSER(   ''' + @FormulaDaCalcolare + ''' ) where Tipodoc = ''' + @TipoDoc + ''' and id = ' + cast( @idRowDett as varchar (20)) 
						
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
							update document_microlotti_dettagli set ' + @DZT_Name + ' =  dbo.AFS_ROUND(   ' + @DZT_Name + ',' + cast(@numero_decimali_modello as varchar(100)) + ' ) where Tipodoc = ''' + @TipoDoc + ''' and id = ' + cast( @idRowDett as varchar (20))
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

		FETCH NEXT FROM CurProg INTO @DZT_Name , @Formula ,@numero_decimali_modello

	END
	CLOSE CurProg
	DEALLOCATE CurProg

end














GO
