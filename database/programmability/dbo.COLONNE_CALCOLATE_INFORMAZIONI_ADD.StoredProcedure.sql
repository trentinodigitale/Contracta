USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COLONNE_CALCOLATE_INFORMAZIONI_ADD]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[COLONNE_CALCOLATE_INFORMAZIONI_ADD]( @idDoc int ) 
as
begin


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
	declare @TipoDocM			varchar(MAx)
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
	declare @modello as varchar(max)

	---set @iddoc	= 84075--<ID_DOC>

	set @Colonna = 'MOD_Modello'

	select @TipoDoc = TipoDoc , @LinkedDoc = LinkedDoc from CTL_DOC where id = @iddoc
	--print 	@TipoDoc 
	
	IF @TipoDoc = 'UPD_MERC_ADDITIONAL_INFO'
	BEGIN
		declare CurMod Cursor static for 
		select MOD_Name as modello from CTL_DOC_SECTION_MODEL where IdHeader=@idDoc and DSE_ID='MERC_ADDITIONAL_INFO_CLASSE_DETTAGLI'
	END
	ELSE
	BEGIN
		declare CurMod Cursor static for 
		select 
			DSE_ID as modello
		from CTL_DocumentSections 
		where DSE_DOC_ID=@TipoDoc  and DES_Table='Document_MicroLotti_Dettagli' 
	END

	open CurMod

	FETCH NEXT FROM CurMod 	INTO @modello
		WHILE @@FETCH_STATUS = 0
		BEGIN
		select @idDocModello = id from ctl_doc where tipodoc = 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and deleted = 0 and Titolo=REPLACE(REPLACE(@modello,'INFO_ADD_',''),'_Mod_Modello','') and StatoFunzionale in ('Pubblicato')
		set @modellobando=@modello
				
				IF @TipoDoc = 'UPD_MERC_ADDITIONAL_INFO'
					set @TipoDocM='UPD_MERC_ADDITIONAL_INFO'
				else
					set @TipoDocM= @modello + '_' +cast( @LinkedDoc as varchar(20))
		
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

				
					
					-- si crea l'indice delle righe da ciclare per fare i calcoli
					-- per ogni riga del documento del tipo coerente con lotto / voce
					create table #Temp ( id  int )
					set @Select = 'insert into #Temp ( id ) select id from document_microlotti_dettagli where idheader = ' + cast( @idDoc as varchar(20)) + ' and Tipodoc = ''' + @TipoDocM + ''''
					--print @Select
					EXEC ( @Select )

					-- debug
					select * from #Temp


					declare CurRowDett Cursor static for 
						Select id from #Temp
							order by id

					open CurRowDett

					FETCH NEXT FROM CurRowDett  INTO @idRowDett
					WHILE @@FETCH_STATUS = 0
					BEGIN

						-- si prende la formula
						set @FormulaDaCalcolare = @Formula

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
								set @SQL = ' insert into #Temp2 ( ValoreDaEstrarre ) select ' + @Attributo + ' from Document_microlotti_dettagli where id = ' + cast( @idRowDett as varchar (20))
					
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


						-- compongo l'istruzione per aggiornare la colonna
						set @SQL = 'update document_microlotti_dettagli set ' + @DZT_Name + ' =  dbo.AF_PARSER(   ''' + @FormulaDaCalcolare + ''' ) where id = ' + cast( @idRowDett as varchar (20))

						-- debug
						--print @SQL

						exec( @SQL )
						if ISNULL(@numero_decimali_modello,-1)>=0
						BEGIN
						set @SQL = 'update document_microlotti_dettagli set ' + @DZT_Name + ' =  dbo.AFS_ROUND(   ' + @DZT_Name + ',' + cast(@numero_decimali_modello as varchar(100)) + ' ) where id = ' + cast( @idRowDett as varchar (20))

							-- debug
							--print @SQL

							exec( @SQL )
						END   

						FETCH NEXT FROM CurRowDett  INTO @idRowDett
					END 
					CLOSE CurRowDett 
					DEALLOCATE CurRowDett 

					drop table #Temp


		 
					FETCH NEXT FROM CurProg INTO @DZT_Name , @Formula , @Aggregazione,@numero_decimali_modello
				END 
				CLOSE CurProg
				DEALLOCATE CurProg


	FETCH NEXT FROM CurMod 	INTO @modello
		END 



	CLOSE CurMod
	DEALLOCATE CurMod	
	

end


























GO
