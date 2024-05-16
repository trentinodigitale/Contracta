USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Verifica_Azienda_Info_Ext]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Verifica_Azienda_Info_Ext] 
(
	@session_id					varchar(250),
	@codice_fiscale				varchar(250),
	@idazi						INT
)
as
begin	
SET NOCOUNT ON
	declare @nome_campo varchar(500)
	declare @nome_campoINT varchar(500)
	declare @nome_campoTEC varchar(500)
	declare @valoreEsterno varchar(max)
	declare @valoreINTERNO varchar(max)
	declare @valoreINTERNOTEC varchar(max)
	declare @valoreEsternoTEC varchar(max)

	declare @sql varchar(max)

	declare @esito int
	set @esito = 1 -- i campi sono uguali
	set @sql=''
	


	-- se il sistema non ha ritornato niente per l'azienda che si sta censendo
	if not exists(select id from parix_dati with(nolock) where sessionId = @session_id and codice_fiscale = @codice_fiscale )
	begin 
		select 'i-dati-NON-sono-variati' as esito 
		return 0
	end

	select cast('' as varchar(max)) as campo_int into #tmp
	truncate table #tmp

	declare CurFields Cursor static for  
		select C.REL_ValueOutput,P.valore ,C.REL_ValueInput
			from CTL_Relations C with(NOLOCK)
				inner join 	Parix_Dati P with(NOLOCK) on P.nome_campo=C.REL_ValueOutput and sessionid=@session_id and codice_fiscale=@codice_fiscale
			where C.REL_Type='DICTIONARY_UPD_ANAG_EXT' 
			order by C.REL_idRow asc
			
	open CurFields

	FETCH NEXT FROM CurFields  INTO @nome_campo , @valoreEsterno, @nome_campoINT

	-- itero su tutti i campi ritornati da parix
	WHILE @@FETCH_STATUS = 0 and @esito > 0
	BEGIN
	
		IF @valoreEsterno <> '' 
		BEGIN
		
			set @valoreEsterno = ltrim(@valoreEsterno)
			set @valoreEsterno = rtrim(@valoreEsterno)
			set @valoreEsterno = upper(@valoreEsterno)
			set @valoreINTERNO = 'NON_TROVATO'
			set @valoreINTERNOTEC = 'NON_TROVATO'	
			set @valoreEsternoTEC = 'NON_TROVATO'	
			
			set @nome_campoTEC=''

			
			--SELECT PER CAPIRE SE PER IL CAMPO INTERNO ESISTE ANCHE UN TEC CHE TERMINA CON 2
			--LO STESSO NOME DEVE AVERE ANCHE IL CAMPO SULLA TABLE PARIX_DATI
			select @nome_campoTEC=DZT_Name 
				from LIB_Dictionary WITH(NOLOCK)
					inner join Parix_Dati WITH(NOLOCK) on sessionid=@session_id and codice_fiscale=@codice_fiscale and nome_campo=@nome_campoINT+'2'
				where DZT_Name=@nome_campoINT+'2'
			
			IF EXISTS (select * from  INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='Aziende' and COLUMN_NAME=@nome_campoINT)
			BEGIN				
				set @sql='insert into #tmp (campo_int) select ' + @nome_campoINT +'  from Aziende where IdAzi=' + cast(@idazi as varchar(50))
				--print @sql
				exec( @sql)
				select @valoreINTERNO=campo_int from #tmp
				truncate table #tmp
			END
			IF EXISTS (select * from DM_Attributi where lnk=@idazi and dztNome=@nome_campoINT)
			BEGIN
				set @sql='insert into #tmp (campo_int) select vatValore_FT from DM_ATTRIBUTI where idApp=1 and lnk=' + cast(@idazi as varchar(50)) + ' and dztNome=''' + @nome_campoINT +''''
				--print @sql
				exec( @sql)
				select @valoreINTERNO=campo_int from #tmp
				truncate table #tmp
			END

			if ISNULL(@nome_campoTEC,'') <> ''
			BEGIN
				IF EXISTS (select * from  INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='Aziende' and COLUMN_NAME=@nome_campoTEC)
				BEGIN				
					set @sql='insert into #tmp (campo_int) select ' + @nome_campoTEC +'  from Aziende where IdAzi=' + cast(@idazi as varchar(50))
					--print @sql
					exec( @sql)
					select @valoreINTERNOTEC=campo_int from #tmp
					truncate table #tmp

					set @sql='insert into #tmp (campo_int) select valore from Parix_Dati with(nolock) where sessionid=''' + @session_id + ''' and codice_fiscale='''+ @codice_fiscale + ''' and nome_campo=''' + @nome_campoTEC + ''''
					exec( @sql)
					select  @valoreEsternoTEC=campo_int from #tmp
					truncate table #tmp

					set @valoreINTERNOTEC = ltrim(@valoreINTERNOTEC)
					set @valoreINTERNOTEC = rtrim(@valoreINTERNOTEC)
					set @valoreINTERNOTEC = upper(@valoreINTERNOTEC)

					set @valoreEsternoTEC = ltrim(@valoreEsternoTEC)
					set @valoreEsternoTEC = rtrim(@valoreEsternoTEC)
					set @valoreEsternoTEC = upper(@valoreEsternoTEC)

				END
			END

			set @valoreINTERNO = ltrim(@valoreINTERNO)
			set @valoreINTERNO = rtrim(@valoreINTERNO)
			set @valoreINTERNO = upper(@valoreINTERNO)

			--LA PIVA FA ECCEZIONE, NEL CASO NON INIZIA PER IT il valore restituito dal sistema lo aggiungo
			IF @nome_campoINT = 'aziPartitaIVA'
			BEGIN
				IF upper(LEFT(@valoreEsterno,2)) <> 'IT'
				BEGIN
					set @valoreEsterno='IT'+@valoreEsterno
				END
			END
			--MI RECUPERO LA DESCRIZIONE CHE CORRISPONDE ALLA CODIFICA PER NAGI - aziIdDscFormasoc
			if  @nome_campoINT = 'aziIdDscFormasoc'
			BEGIN				
				select distinct @valoreINTERNO=upper(dscTesto)
					from tipidatirange, descsI
						where tdridtid = 131     and tdrdeleted=0     and IdDsc =  tdriddsc and tdrcodice=@valoreINTERNO
			END


			--SE I VALORI SONO DIVERSI E VALORE ESTERNO DEVE ESISTERE
			IF ( @valoreEsterno <> @valoreINTERNO or @valoreEsternoTEC <> @valoreINTERNOTEC ) and @valoreEsterno <> 'NON_TROVATO'
			BEGIN								
				set @esito = -1
			END
			
		END

		-- passo al campo successivo
		FETCH NEXT FROM CurFields INTO @nome_campo , @valoreEsterno , @nome_campoINT
		
	END 
	
	CLOSE CurFields
	DEALLOCATE CurFields
	
	
	
	IF @esito < 0
	BEGIN		
		select 'i-dati-sono-variati' as esito 
	END
	ELSE
	BEGIN
		select 'i-dati-NON-sono-variati' as esito 
	END

end







GO
