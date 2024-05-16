USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_UPDATE_DOMAIN]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





----------------------------------------------------------------------------------------------------------------
-- STORED CHE ESEGUE L'APPARIGLIMENTO TRA I VALORI NUOVI E VECCHI DI UN DOMINIO CUSTOM
-- IN CASO DI DIFFERENZE IL DOMINIO NELL'APPLICAZIONE VIENE AGGIORNATO E VIENE INSERITO 
-- UN DOCUMENTO DI TIPO 'GESTIONE_DOMINIO'
----------------------------------------------------------------------------------------------------------------
-- PARAMETRI:
-- @Domain = nome del dominio (DMV_DM_ID)
-- @IdHeaderDomNew = valore della colonna idHeader della CTL_DomainValues da cui leggere 
--                   i valori del dominio New
-- @ViewNameDomOld = nome della vista da eseguire per ottenere i valori del dominio in essere
-- @Caption = titolo del documento inserito nella CTL_DOC
-- @UpdateType = per adesso gestiamo il valore 'I' (solo inserimento) che inserisce solo i codici nuovi senza fare altro
--               se invece vale 'D' cancelliamo logicamente solo gli elementi non presenti nel dominio nuovo e con il codice esterno avvalorato
-- @Anomalie = eventuale stringa di anomalie gestite dal chiamante e inserite nelle note del documento (se non ve ne sono passare vuoto)
-- @IdDocDomUpd = parametro di output con l'ID del documento inserito (se i 2 domini sono identici vale -1)
----------------------------------------------------------------------------------------------------------------
CREATE  PROCEDURE [dbo].[SP_UPDATE_DOMAIN] 
	( @Domain varchar(100), @IdHeaderDomNew int  , @ViewNameDomOld varchar(100), @Caption varchar(100), 
			@UpdateType char(1), @Anomalie varchar(max),   @IdDocDomUpd int output )
AS
BEGIN

	set @IdDocDomUpd = -1

	declare @NumRowInserted int
	declare @NumRowDeleted int
	declare @NumRowUpdated int
	declare @DescrVar varchar(max)
	declare @Accapo varchar(5)
	declare @OverwriteOnUpdate varchar(10)

	--set @Accapo = '
--'
	
	set @Accapo = '<br/>'

	set @DescrVar = ''

	set @NumRowInserted = 0
	set @NumRowDeleted = 0
	set @NumRowUpdated = 0

	-- accede al parametro che stabilisce se sovrascrivere sull'update o se generare un nuovo codice
	set @OverwriteOnUpdate = NULL

	select @OverwriteOnUpdate = valore from CTL_Parametri 
				where contesto = 'SP_UPDATE_DOMAIN'
						and oggetto = @Domain
						and Proprieta = 'OverwriteOnUpdate'

	if @OverwriteOnUpdate is NULL
		set @OverwriteOnUpdate = 'NO'

	-- crea la tabella temporanea
	select top 0 * into #Temp_DomOld from GESTIONE_DOMINIO_A_ATC

	-- dimensiona le colonne come nella CTL_DomainValues per evitare errori di troncamento
	alter table #Temp_DomOld  alter column DMV_DM_ID varchar(500) COLLATE database_default
	alter table #Temp_DomOld  alter column DMV_COD varchar(500) COLLATE database_default
	alter table #Temp_DomOld  alter column DMV_FATHER varchar(255) COLLATE database_default
	alter table #Temp_DomOld  alter column DMV_DescML nvarchar(max) COLLATE database_default
	alter table #Temp_DomOld  alter column DMV_CodExt varchar(500) COLLATE database_default
	alter table #Temp_DomOld  alter column DMV_Module varchar(100) COLLATE database_default

	-- scarica i valori del dominio in essere in una tabella temporanea
	--exec ( 'select * into #Temp_DomOld from ' + @ViewNameDomOld + ' order by dmv_cod' )
	exec ( 'INSERT INTO #Temp_DomOld SELECT * FROM  ' + @ViewNameDomOld  )

	-- scarica i valori del dominio nuovo in una tabella temporanea
	select * into #Temp_DomNew from CTL_DomainValues where [idHeader] = @IdHeaderDomNew

	-- inserisce colonna stato (I,V,D,*)
	alter table #Temp_DomOld add [Status] char(1) COLLATE database_default

	update #Temp_DomOld set [Status] = '*' -- valore non variato
	
	-- inserisce i nuovi record (presenti nella NEW e non nella OLD)
	insert into #Temp_DomOld
	([DMV_DM_ID],  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], 
			[DMV_CodExt], [DMV_Module], [DMV_Deleted], [Status] )

			select n.[DMV_DM_ID],  n.[DMV_Cod], n.[DMV_Father], n.[DMV_Level], n.[DMV_DescML], n.[DMV_Image], n.[DMV_Sort], 
					n.[DMV_CodExt], n.[DMV_Module], n.[DMV_Deleted] , 'I'
				from #Temp_DomNew n
					left outer join #Temp_DomOld o on n.DMV_CodExt = o.DMV_CodExt
			where O.DMV_DM_ID is null


	set @NumRowInserted = @@ROWCOUNT

	if @NumRowInserted > 0
	begin

		if @DescrVar = ''
			set @DescrVar = 'Righe Inserite [' + CAST(@NumRowInserted as varchar(10)) + '] :' + @Accapo + @Accapo
		else
			set @DescrVar = @DescrVar + @Accapo + @Accapo + 'Righe Inserite [' + CAST(@NumRowInserted as varchar(10)) + '] :' + @Accapo + @Accapo

		select @DescrVar = @DescrVar + DMV_Cod + ' - ' + DMV_DescML  + @Accapo
			from #Temp_DomOld
				where [Status] = 'I'
	end

	-- se non si tratta di modalità SOLO INSERIMENTO effettua le eventuali cancellazioni logiche
	if @UpdateType <> 'I'
	begin

		if @UpdateType = 'D'
		begin
			-- cancella logicamente i record non più presenti (presenti nella OLD e non nella NEW)
			-- e con il codice esterno avvalorato
			update #Temp_DomOld set [DMV_Deleted] = 1 , [Status] = 'D'
				where [DMV_CodExt] in
							(
								select 	o.[DMV_CodExt]
									from #Temp_DomOld o 
										left outer join #Temp_DomNew n on n.DMV_CodExt = o.DMV_CodExt
								where n.DMV_DM_ID is null and o.[DMV_Deleted] = 0 and RTRIM(ISNULL(o.[DMV_CodExt],'')) <> ''
							)
		end
		else
		begin
				-- cancella logicamente i record non più presenti (presenti nella OLD e non nella NEW)
			update #Temp_DomOld set [DMV_Deleted] = 1 , [Status] = 'D'
				where [DMV_CodExt] in
							(
								select 	o.[DMV_CodExt]
									from #Temp_DomOld o 
										left outer join #Temp_DomNew n on n.DMV_CodExt = o.DMV_CodExt
								where n.DMV_DM_ID is null and o.[DMV_Deleted] = 0
							)
		end

		set @NumRowDeleted = @@ROWCOUNT

	end

	if @NumRowDeleted > 0
	begin
	
		if @DescrVar = ''
			set @DescrVar = 'Righe Cancellate [' + CAST(@NumRowDeleted as varchar(10)) + '] :' + @Accapo + @Accapo
		else
			set @DescrVar = @DescrVar + @Accapo + @Accapo + 'Righe Cancellate [' + CAST(@NumRowDeleted as varchar(10)) + '] :' + @Accapo + @Accapo

		select @DescrVar = @DescrVar + DMV_Cod + ' - ' + DMV_DescML  + @Accapo
			from #Temp_DomOld
				where [Status] = 'D'
	end

	
	
	-- se non si tratta di modalità SOLO INSERIMENTO effettua le eventuali variazioni di descrizione
	if @UpdateType <> 'I'
	begin

		-- estrazione di record con stesso codice esterno e descrizione diversa
		select 	@NumRowUpdated = COUNT(*)
			from #Temp_DomNew n
				inner join #Temp_DomOld o on n.DMV_CodExt = o.DMV_CodExt
		where o.[DMV_Deleted] = 0 and ltrim(rtrim(o.[DMV_DescML])) <> ltrim(rtrim(n.[DMV_DescML]))
				and O.[Status] <> 'I'

		-- se vi sono righe da variare esegue il cursore
		if @NumRowUpdated > 0
		begin

			declare @cod_ext varchar(200)
			declare @cod_int varchar(200)
			declare @Descr_Old varchar(max)
			declare @Descr_New varchar(max)
			declare @cod_int_New varchar(200)
			declare @Progr int

			if @DescrVar = ''
				set @DescrVar = 'Righe Variate [' + CAST(@NumRowUpdated as varchar(10)) + '] :' + @Accapo + @Accapo
			else
				set @DescrVar = @DescrVar + @Accapo + @Accapo + 'Righe Variate [' + CAST(@NumRowUpdated as varchar(10)) + '] :' + @Accapo + @Accapo
		

			declare crs cursor static
			for 
				
				select 	o.DMV_CodExt,ltrim(rtrim(o.[DMV_DescML])),ltrim(rtrim(n.[DMV_DescML])),O.DMV_Cod

						from #Temp_DomNew n
							inner join #Temp_DomOld o on n.DMV_CodExt = o.DMV_CodExt

					where o.[DMV_Deleted] = 0 and ltrim(rtrim(o.[DMV_DescML])) <> ltrim(rtrim(n.[DMV_DescML]))
										and O.[Status] <> 'I'

			open crs

			fetch next from crs into @cod_ext,@Descr_Old,@Descr_New,@cod_int

			while @@fetch_status = 0
			begin
				
					
					if @OverwriteOnUpdate = 'YES'
					begin
						
						-- sovrascrive la descrizione senza cancellazione logica
						update #Temp_DomOld 
							set [DMV_DescML] = @Descr_New ,  [Status] = 'V'
								where DMV_Cod = @cod_int

					end

					else

					begin

						-- mette a deleted il vecchio record
						update #Temp_DomOld set DMV_Deleted = 1,  [Status] = 'V'
							where DMV_Cod = @cod_int
				
						-- inserisce un nuovo record mettendo in coda al codice un progressivo per renderlo unico
						set @cod_int_New = [dbo].[AppendProgr2Str] (@cod_int)

						insert into #Temp_DomOld
							([DMV_DM_ID],  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], 
								[DMV_CodExt], [DMV_Module], [DMV_Deleted], [Status] )

								select [DMV_DM_ID],  @cod_int_New, [DMV_Father], [DMV_Level], @Descr_New, [DMV_Image], [DMV_Sort], 
											[DMV_CodExt], [DMV_Module], 0 , '*'
										from #Temp_DomOld
											where DMV_Cod = @cod_int

					end


					set @DescrVar = @DescrVar + @cod_int + ' - ' + @Descr_Old + ' - ' + @Descr_New  + @Accapo
				

					fetch next from crs into @cod_ext,@Descr_Old,@Descr_New,@cod_int
        
			end		-- while @@fetch_status = 0

			close crs

			deallocate crs

		end		-- if @NumRowUpdated > 0

	end		--if @UpdateType <> 'I'

	-- se ci sono state variazioni
	if @NumRowInserted > 0 or  @NumRowDeleted > 0 or  @NumRowUpdated > 0
	begin
		
		-- inserisce il documento nella CTL_DOC
		declare @newId int

		if @Anomalie <> ''
			set @DescrVar = @DescrVar + @Accapo + @Accapo + @Anomalie

		insert into CTL_DOC ( idpfu, TipoDoc, StatoDoc, Data,Caption ,JumpCheck,Titolo,PrevDoc,Note )
			select -20,'GESTIONE_DOMINIO','Saved',GETDATE(),@Caption,@Domain,@Caption,0, @DescrVar
		
		set @newId = SCOPE_IDENTITY()
		
		insert into CTL_DomainValues ( [idHeader], [DMV_DM_ID], [DMV_LNG], [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted])
		select 
				@newId,'DOMINIO', 'I',  [DMV_Cod], [DMV_Father], [DMV_Level], [DMV_DescML], [DMV_Image], [DMV_Sort], [DMV_CodExt], [DMV_Deleted]
			from 
				#Temp_DomOld


		set @IdDocDomUpd = @newId

		-- schedulo il conferma del documento
		insert into [dbo].[CTL_Schedule_Process]
			( [IdDoc], [IdUser], [DPR_DOC_ID], [DPR_ID] )
		values
			( @newId, - 20, 'GESTIONE_DOMINIO', 'CONFERMA') 

	end

	-- cancellazione aree di lavoro
	drop table #Temp_DomOld
	drop table #Temp_DomNew
	
END





GO
