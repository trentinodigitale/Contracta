USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Variazione_Dati_Azienda_CREATE_DOC]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[Variazione_Dati_Azienda_CREATE_DOC] 
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
	declare @idpfu as int
	declare @id as int
	declare @gg_scadenza as INT
	declare @DataScadenza as datetime
	declare @num_riga as int
	set @num_riga=0
	set @idpfu=0

	set @sql=''

	select cast('' as varchar(max)) as campo_int into #tmp
	truncate table #tmp

	--Faccio un controllo se per caso esiste un documento ancora in corso per il fornitore
	IF EXISTS (select * from ctl_doc where tipodoc='VARIAZIONE_DATI_AZIENDA' and deleted=0 and Destinatario_Azi=@idazi and StatoFunzionale='InLavorazione')
	BEGIN
		--rimuove eventuali schedulazioni di chiusure di documenti che metterò ad ANNULLATI PRIMA DI CREARNE UNO NUOVO
		update CS 
			set CS.State=1
			from CTL_Schedule_Process CS with(NOLOCK)
				inner join ctl_doc C with(NOLOCK) on CS.IdDoc=C.id and C.tipodoc='VARIAZIONE_DATI_AZIENDA' and C.deleted=0 
													and C.Destinatario_Azi=@idazi and C.StatoFunzionale='InLavorazione'		
		
		update ctl_doc 
			set StatoFunzionale='Annullato' 
			where tipodoc='VARIAZIONE_DATI_AZIENDA' and deleted=0 
				and Destinatario_Azi=@idazi and StatoFunzionale='InLavorazione'

		update CTL_Attivita 
			set ATV_Execute='si' 
			where ATV_DocumentName='VARIAZIONE_DATI_AZIENDA' 
				and ATV_IdAzi=@idazi and ATV_Execute='no'

		
	END
	--SE AZIENDA HA UN SOLO UTENTE VALORIZZO @IDPFU e lo setto sul documento che creo
	IF EXISTS (select max(idpfu) from ProfiliUtente where pfuIdAzi=@idazi and pfudeleted=0 group by pfuIdAzi having count(*) = 1 )
	BEGIN 
		select @idpfu=max(idpfu) 
			from ProfiliUtente 
			where pfuIdAzi=@idazi and pfudeleted=0 
			group by pfuIdAzi 
			having count(*) = 1 
	END
	--RECUPERO DA CONFIGURAZIONE DI SISTEMA IL NUMERO DI GIORNI PER LA SCADENZA
	select @gg_scadenza=GiorniScadenza from Document_Configurazione_Variazione_Gestore where deleted=0

	set @DataScadenza =  convert(  datetime , convert( varchar(10) , dateadd( day , @gg_scadenza ,getdate()) , 126 ) + 'T23:59:59.000', 126 )

	--CREO IL DOCUMENTO
	insert into ctl_doc (IdPfu,NumeroDocumento,TipoDoc,Titolo,Data,DataScadenza,Destinatario_Azi,idPfuInCharge)
		select @idpfu,@session_id,'VARIAZIONE_DATI_AZIENDA','Variazione Dati Azienda',GETDATE(),@DataScadenza,@idazi,@idpfu

	set @id=SCOPE_IDENTITY()

	--INSERISCO ATTIVITA' PER L'AZIENDA
	insert into ctl_attivita (ATV_Object, ATV_DateInsert, ATV_Obbligatory, ATV_Execute,ATV_ExpiryDate, ATV_DocumentName, ATV_IdDoc, ATV_IdPfu,ATV_IdAzi )
		Select 'Variazione Dati Azienda ', getdate()   ,'no'			,	'no'	 ,@DataScadenza,	'VARIAZIONE_DATI_AZIENDA' as tipoDoc			, @id	   , NULL  ,@idazi 
		
	--SCHEDULAZIONE DI UN PROCESSO PER EFFETTUARE IL INVIO D'UFFICIO SE NON VIENE FATTO DA UTENTE
	Insert into CTL_Schedule_Process (IdDoc,IdUser,DPR_DOC_ID,DPR_ID,DataRequestExec)
		select @id,-20,'VARIAZIONE_DATI_AZIENDA','SEND_UFFICIO',@DataScadenza

	--POPOLA LA GRIGLIA DELLE INFORMAZIONI
	declare CurFields Cursor static for  
		select C.REL_ValueOutput,P.valore ,C.REL_ValueInput
			from CTL_Relations C with(NOLOCK)
				left join 	Parix_Dati P with(NOLOCK) on P.nome_campo=C.REL_ValueOutput and sessionid=@session_id and codice_fiscale=@codice_fiscale
			where C.REL_Type='DICTIONARY_UPD_ANAG_EXT' 
			order by C.REL_idRow asc
			
	open CurFields

	FETCH NEXT FROM CurFields  INTO @nome_campo , @valoreEsterno, @nome_campoINT

	-- itero su tutti i campi ritornati da parix
	WHILE @@FETCH_STATUS = 0 
	BEGIN	
		
			set @valoreEsterno = ltrim(@valoreEsterno)
			set @valoreEsterno = rtrim(@valoreEsterno)
			set @valoreINTERNOTEC = 'NON_TROVATO'	
			set @valoreEsternoTEC = 'NON_TROVATO'	
			
			--SELECT PER CAPIRE SE PER IL CAMPO INTERNO ESISTE ANCHE UN TEC CHE TERMINA CON 2
			--LO STESSO NOME DEVE AVERE ANCHE IL CAMPO SULLA TABLE PARIX_DATI
			set @nome_campoTEC=''
			select @nome_campoTEC=DZT_Name 
				from LIB_Dictionary WITH(NOLOCK)
					inner join Parix_Dati WITH(NOLOCK) on sessionid=@session_id and codice_fiscale=@codice_fiscale and nome_campo=@nome_campoINT+'2'
				where DZT_Name=@nome_campoINT+'2'



			set @valoreINTERNO = NULL
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

					set @sql='insert into #tmp (campo_int) select valore from Parix_Dati where sessionid=''' + @session_id + ''' and codice_fiscale='''+ @codice_fiscale + ''' and nome_campo=''' + @nome_campoTEC + ''''
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
			--SE I VALORI SONO DIVERSI SVUOTO IL VALORE INTERNO
			--if @valoreEsternoTEC <> @valoreINTERNOTEC
			--BEGIN
			--	set @valoreINTERNO=''
			--END
			--LA PIVA FA ECCEZIONE, NEL CASO NON INIZIA PER IT il valore restituito dal sistema lo aggiungo
			IF @nome_campoINT = 'aziPartitaIVA'
			BEGIN
				IF upper(LEFT(@valoreEsterno,2)) <> 'IT' and isnull(@valoreEsterno,'') <> ''
				BEGIN
					set @valoreEsterno='IT'+@valoreEsterno
				END
			END

			--MI RECUPERO LA DESCRIZIONE CHE CORRISPONDE ALLA CODIFICA PER NAGI - aziIdDscFormasoc
			if  @nome_campoINT = 'aziIdDscFormasoc'
			BEGIN				
				select distinct @valoreINTERNO=dscTesto
					from tipidatirange, descsI
						where tdridtid = 131     and tdrdeleted=0     and IdDsc =  tdriddsc and tdrcodice=@valoreINTERNO
			END

		--	IF ( ISNULL(@valoreINTERNO,'') <> '' or ISNULL(@valoreEsterno,'') <> '' )
		--	BEGIN
				Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
					select @id,'DETTAGLI','Descrizione',@num_riga,Isnull(ML_Description,DZT_DescML)
						from LIB_Dictionary WITH(NOLOCK)
							left join LIB_Multilinguismo with(NOLOCK) on ML_KEY=DZT_DescML and ML_LNG='I'
						where DZT_Name=@nome_campoINT

				Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
					select @id,'DETTAGLI','Dati_Sistema',@num_riga,@valoreINTERNO

				Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
					select @id,'DETTAGLI','Dati_Esterni',@num_riga,@valoreEsterno				

				Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
					select @id,'DETTAGLI','colonnatecnica',@num_riga,@nome_campoINT
				
				--SE IL DATO ESTERNO E' VUOTO OPPURE I DATI SONO UGUALI NON RENDO EDITABILE LA SCELTA
				IF (  ISNULL(@valoreEsterno,'') = '' or ( upper(ISNULL(@valoreINTERNO,'')) = upper(ISNULL(@valoreEsterno,'')) ) )
				BEGIN
					Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
						select @id,'DETTAGLI','NonEditabili',@num_riga,' Scelta_Dati_Azienda '
					
					Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
						select @id,'DETTAGLI','Scelta_Dati_Azienda',@num_riga,NULL
				END
				ELSE
				BEGIN
					--SE IL DATO INTERNO E' VUOTO BLOCCO LA SCELTA SU SATO INTEGRAZIONE
					IF (  ISNULL(@valoreINTERNO,'') = '' )
					BEGIN
						Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
							select @id,'DETTAGLI','NonEditabili',@num_riga,' Scelta_Dati_Azienda '
					END
					ELSE
					BEGIN
						Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
							select @id,'DETTAGLI','NonEditabili',@num_riga,''
					END
					Insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Row,Value)
						select @id,'DETTAGLI','Scelta_Dati_Azienda',@num_riga,'Dato_Integrazione'
				END					

		--	END
			set @num_riga=@num_riga+1
		-- passo al campo successivo
		FETCH NEXT FROM CurFields INTO @nome_campo , @valoreEsterno , @nome_campoINT
		
	END 
	
	CLOSE CurFields
	DEALLOCATE CurFields


end






GO
