USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AVCP_IMPORT_CSV]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD2_AVCP_IMPORT_CSV] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	--declare @idDoc int
	--declare @IdUser int 
	--set @idDoc = 170739
	--set @IdUser = 35774

	declare @Idrow  int
	declare @idheader int
	declare @Anno nvarchar(50)
	declare @NumeroAutorita nvarchar(200)
	declare @Cig nvarchar(200)

	declare @CurrentCig  nvarchar(200)

	declare @CFprop nvarchar(50)
	declare @Denominazione nvarchar(300)
	declare @Scelta_contraente nvarchar(50)
	declare @ImportoAggiudicazione  float
	declare @DataInizio datetime
	declare @Datafine   datetime
	declare @ImportoSommeLiquidate float
	declare @Oggetto  nvarchar(4000)
	declare @DataPubblicazione datetime
	declare @Warning  nvarchar(4000)
	declare @Gruppo nvarchar(200)
	declare @Ruolopartecipante nvarchar(200) 
	declare @Estero char(1)
	declare @Codicefiscale  varchar(50)
	declare @CodicefiscaleEstero  varchar(50) 
	declare @Ragionesociale nvarchar(80)
	declare @aggiudicatario char(1)	
	declare @Protocollo varchar(50)
	declare @FascicoloGara varchar(50)
	declare @VersioneGara int
	declare @CurrentNumeroAutorita varchar(50)
	declare @CurrentGruppo varchar(200)
	declare @FascicoloLotto varchar(50)
	declare @VersioneLotto int
	declare @IdOE int
	declare @flagMakeNew	int
	declare @idDocGara int
	declare @idDocLotto int
	declare @idDocLottoPrev int
	declare @LinkedDocLotto int
	declare @Azienda as int
	declare @MinRowGruppo int
	declare @MaxRowGruppo int
	
				
	-- inizializzo variabili
	set @VersioneGara = 0
	set @CurrentNumeroAutorita = ''
	set @CurrentGruppo = ''
	set @MinRowGruppo = 0 

	set @CurrentCig = ''

	select @Azienda = Azienda from CTL_DOC with(nolock) where id = @idDoc

	-- utilizzo una tabella temporanea per raccogliere i partecipanti ad un gruppo 
	--CREATE TABLE #Temp_AVCP_partecipanti(
	DECLARE @Temp_AVCP_partecipanti TABLE (
		[Idrow] [int] IDENTITY(1,1) NOT NULL,
		[Ruolopartecipante] [nvarchar](200) NULL,
		[Estero] [char](1) NULL,
		[Codicefiscale] [varchar](50) NULL,
		[Ragionesociale] [nvarchar](800) NULL,
		[aggiudicatario] [char](1) NULL
	) 

	---CREO UNA TABLE per inserire i nuovi lotti creati in modo da chiamare la stored dei controlli su gli id presenti nella stessa
	CREATE TABLE #TEMP_LOTTI_NEW (
		[Id_Lotto] [int] NOT NULL
	)

	
	-- cursore sulla tabella di lavoro
	declare CurImportCSV Cursor static for  
		select Idrow, Anno, NumeroAutorita, Cig, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate, Oggetto, DataPubblicazione, Warning, Gruppo, Ruolopartecipante, Estero, Codicefiscale, CodicefiscaleEstero, Ragionesociale, aggiudicatario
			from document_AVCP_Import_CSV
			where idheader = @idDoc and isnull( cast( warning as varchar (4000)), '' ) = ''
				order by Idrow

	open CurImportCSV

	-- prendo il primo record
	FETCH NEXT FROM CurImportCSV  INTO @Idrow, @Anno, @NumeroAutorita, @Cig, @CFprop, @Denominazione, @Scelta_contraente, @ImportoAggiudicazione, @DataInizio, @Datafine, @ImportoSommeLiquidate, @Oggetto, @DataPubblicazione, @Warning, @Gruppo, @Ruolopartecipante, @Estero, @Codicefiscale, @CodicefiscaleEstero, @Ragionesociale, @aggiudicatario

	-- ciclo su tutti  i record finche ci sono
	WHILE @@FETCH_STATUS = 0
	BEGIN

		--print '-- LETTO NUOVO RECORD -- '
		--print '@Idrow = ' + cast(  @Idrow as varchar )

		-- se trovo NumeroAutorita  ( allora creo un nuovo AVCP_GARA ) e mi tro su una riga con cig
		if isnull( @NumeroAutorita , '' ) <> '' 
		begin

			--print 'TROVATO NUMERO AUTORITA ' + @NumeroAutorita

			-- se è differente dalla versione precedente
			if isnull( @NumeroAutorita , '' ) <> @CurrentNumeroAutorita
			begin

				--print 'NUMERO AUTORITA DIFFERENTE DAL PRECEDENTE.VERIFICO SE CREO'

				-- se esiste nel sistema mi prendo i riferimenti
				set @VersioneGara = 0

				select @VersioneGara  = versione 
					from CTL_DOC with(nolock)
						inner join dbo.document_AVCP_lotti with(nolock) on id = idheader
					where tipoDoc = 'AVCP_GARA' and statoFunzionale = 'Pubblicato' and Cig = @NumeroAutorita and deleted = 0 
				

				-- se non esiste
				if isnull( @VersioneGara , 0 ) = 0
				begin 

					--PRINT 'CREO GARA'

					-- creo un nuovo AVCP_GARA
					INSERT INTO ctl_doc (tipodoc,statoFunzionale, data , datainvio , PrevDoc,LinkedDoc,idpfu,Azienda)
						values( 'AVCP_GARA','Pubblicato' , getdate() , getdate() , 0 , 0 , @IdUser , @Azienda )

					-- mi prendo i riferimenti
					SET @idDocGara = SCOPE_IDENTITY()
					set @VersioneGara = @idDocGara 
					SET @FascicoloGara = 'AVCP-' + cast(@VersioneGara as varchar ) 

					EXEC ctl_GetNewProtocol 'ANAC' , '', @Protocollo output
					 
					UPDATE ctl_doc SET  versione = @VersioneGara , Fascicolo = @FascicoloGara , Protocollo = @Protocollo
						WHERE id = @idDocGara 
						
					INSERT INTO Document_AVCP_Lotti
							  ( idheader, Anno, Cig, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate, Oggetto, DataPubblicazione )
						select @idDocGara, Anno, @NumeroAutorita, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate, 'Gara numero ' + isnull(@NumeroAutorita,'') , DataPubblicazione 	
							from document_AVCP_Import_CSV with(nolock)
							where Idrow = @Idrow
											
						
				end
				else
					set @VersioneGara = 0
				
				set @CurrentNumeroAutorita = @NumeroAutorita
			end
		end
		

			
		--print '@MinRowGruppo = ' + cast(  @MinRowGruppo as varchar )
		--print '@MaxRowGruppo = ' + cast(  @MaxRowGruppo as varchar )
		--print '--------------------------------'


		-- se trovo gruppo <> gruppo corrente oppure è iniziato un nuovo lotto devo scaricare l'eventuale gruppo aperto
		--if isnull( @Gruppo , '' ) <> @CurrentGruppo	 or isnull( @Cig , '' ) <> ''
		if isnull( @Gruppo , '' ) <> @CurrentGruppo	 or isnull( @Cig , '' ) <> @CurrentCig
		begin
		
			-- se gruppo corrente è pieno
			if @CurrentGruppo <> ''
			begin

				set @IdOE = 0
				
				-- verifico il gruppo corrente se esisteva
				select @IdOE = id   from CTL_DOC with(nolock)
					inner join CTL_DOC_VALUE  with(nolock) on id = idheader and dzt_name = 'RagioneSociale'
					where TipoDoc = 'AVCP_GRUPPO' and value = @CurrentGruppo and LinkedDoc = @VersioneLotto and StatoFunzionale = 'Pubblicato' and deleted = 0 
					
				if isnull( @IdOE , 0 ) <> 0	
				begin
					-- se è cambiato 
					if dbo.AVCP_IMPORT_CSV_IS_GRUPPO_CHANGED( @IdDoc , @IdOE , @MinRowGruppo , @MaxRowGruppo ) = 1
					begin
						-- metto a modificato la versione precedente
						update CTL_DOC set StatoFunzionale = 'Variato' , deleted = 1 where id = @IdOE

						-- creo il nuovo gruppo con la  collezione caricata in memoria 			
						exec AVCP_IMPORT_CSV_MAKE_GRUPPO  @IdOE , @VersioneLotto , @FascicoloLotto , @IdDoc , @MinRowGruppo , @MaxRowGruppo  , @IdUser , @Azienda
						
					end
				end
			
				-- altrimenti
				else
				begin
				
					--print '-- INSERISCO nuovo gruppo --'
					--print '@MinRowGruppo = ' + cast(  @MinRowGruppo as varchar )
					--print '@MaxRowGruppo = ' + cast(  @MaxRowGruppo as varchar )
					--print '--------------------------------'
					
					-- creo il nuovo gruppo con la  collezione caricata in memoria 			
					exec AVCP_IMPORT_CSV_MAKE_GRUPPO  @IdOE , @VersioneLotto , @FascicoloLotto , @IdDoc , @MinRowGruppo , @MaxRowGruppo  , @IdUser , @Azienda
				end

				
				
				-- svuoto collezione temporanea
				delete from @Temp_AVCP_partecipanti
				set @MinRowGruppo = 0
				set @MaxRowGruppo = 0

				--print '-- SVUOTO RIGHE DEL GRUPPO --'
				--print '@MinRowGruppo = ' + cast(  @MinRowGruppo as varchar )
				--print '@MaxRowGruppo = ' + cast(  @MaxRowGruppo as varchar )
				--print '--------------------------------'
				
			
			end
			-- gruppo corrente = gruppo
			set @CurrentGruppo = @Gruppo
			
		end

		
		-- se trovo Cig 
		--if isnull( @Cig , '' ) <> ''
		if isnull( @Cig , '' ) <> @CurrentCig
		begin
			-- NumeroAutorita è vuoto 
			if isnull( @NumeroAutorita , '' ) = ''
			begin
				--svuoto il riferimento alla @VersioneGara
				set @VersioneGara = 0
				set @CurrentNumeroAutorita = ''
				
			end

			-- se esiste nel sistema mi prendo i riferimenti
			set @VersioneLotto = 0
			set @LinkedDocLotto = 0
			select @VersioneLotto = versione , @idDocLottoPrev = id , @FascicoloLotto = Fascicolo , @LinkedDocLotto = LinkedDoc
				from CTL_DOC with(nolock)
					inner join dbo.document_AVCP_lotti with(nolock) on id = idheader
				where tipoDoc = 'AVCP_LOTTO' and statoFunzionale = 'Pubblicato' and Cig = @Cig and deleted = 0
			
			if isnull( @VersioneLotto , 0 ) <> 0
			begin

				-- Annullo eventuali OE caricati in passato ma non più presenti
				exec AVCP_IMPORT_CSV_DELETE_OLD_OE  @Idrow , @idDoc , @idDocLottoPrev , @IdUser
				
				-- se è da modificare ( è cambiato rispetto alla versione presente )
				if dbo.AVCP_IMPORT_CSV_IS_LOTTO_CHANGED( @Idrow , @idDoc ,@idDocLottoPrev ) = 1
				begin

					-- cambio lo stato a variato 
					update CTL_DOC set StatoFunzionale = 'Variato' , deleted = 1 where id = @idDocLottoPrev
					
					-- creo un nuovo AVCP_LOTTO ( scorro i record alla ricerca degli importi ) -- mi prendo i riferimenti
					exec AVCP_IMPORT_CSV_MAKE_LOTTO  @Idrow , @idDoc , @idDocLottoPrev output , @VersioneLotto output, @FascicoloLotto output , @LinkedDocLotto output 
					
				end
			end			
			-- se non esiste
			else
			begin

				set @LinkedDocLotto = @VersioneGara

				-- creo un nuovo AVCP_LOTTO ( scorro i record alla ricerca degli importi )-- mi prendo i riferimenti
				exec AVCP_IMPORT_CSV_MAKE_LOTTO  @Idrow , @idDoc , @idDocLottoPrev output , @VersioneLotto output, @FascicoloLotto output , @LinkedDocLotto output 

			end
			
			set @CurrentCig = isnull( @Cig , '' )	
			
		end			
					
		
		-- se gruppo è vuoto ed OE <> '' ( quindi è un OE singolo )
		if isnull( @Gruppo , '' ) = '' and isnull( @Ragionesociale , '' ) <> ''
		begin
		
			-- verifico se l'OE esiste 
			set @IdOE = 0
			set @flagMakeNew = 0
			
			select @IdOE = id  from CTL_DOC  with(nolock)
				inner join dbo.document_AVCP_partecipanti with(nolock) on id = idheader 
				where TipoDoc = 'AVCP_OE' and LinkedDoc = @VersioneLotto and StatoFunzionale = 'Pubblicato' and ( @Codicefiscale = Codicefiscale or @CodicefiscaleEstero = Codicefiscale )
						and deleted = 0 

			if isnull( @IdOE , 0 ) <> 0	
			begin
				-- se  è da cambiato
				if exists( select id from CTL_DOC with(nolock)
								inner join dbo.document_AVCP_partecipanti with(nolock) on id = idheader 
								where id = @IdOE and ( Ragionesociale <> @Ragionesociale or aggiudicatario <> @aggiudicatario or Estero <> @Estero ) and deleted = 0
						)
				begin
					-- cambio lo stato all'OE precedente
					update CTL_DOC set StatoFunzionale = 'Variato' , deleted = 1 where id = @IdOE
					--inserisce il riferimento al nuovo lotto nella table #TEMP_LOTTI_NEW per fare i controlli successivamente
					insert into #TEMP_LOTTI_NEW ( Id_Lotto ) values ( @VersioneLotto )

					-- creo il nuovo
					set @flagMakeNew = 1
				end	
				
			end
			else
			begin
				-- creo il nuovo OE
					set @flagMakeNew = 1
			end
			
			-- se devo creare il nuovo OE
			if @flagMakeNew = 1
			begin

				EXEC ctl_GetNewProtocol 'ANAC' , '', @Protocollo output

				INSERT INTO ctl_doc ( tipodoc, statoFunzionale,  data, datainvio , PrevDoc, LinkedDoc,  idpfu, Azienda , Fascicolo , Protocollo)
					values ( 'AVCP_OE' , 'Pubblicato' , getdate() , getdate() , @IdOE , @VersioneLotto , @IdUser , @Azienda , @FascicoloLotto , @Protocollo)

				set @IdOE = @@identity

                INSERT INTO Document_avcp_partecipanti
                         ( IdHeader, RuoloPartecipante, Estero, CodiceFiscale, RagioneSociale, Aggiudicatario)
					values( @IdOE , @RuoloPartecipante, @Estero, case when isnull( @Estero , '') = '1' then @CodicefiscaleEstero else @CodiceFiscale end , @RagioneSociale, @Aggiudicatario )

			end

				
		end
		
		-- se gruppo è pieno 
		if isnull( @Gruppo  , '' ) <> ''
		begin
			if @MinRowGruppo = 0
				set @MinRowGruppo = @idrow
			set @MaxRowGruppo = @idrow

			-- aggiungo l'OE alla collezzione in memoria
			insert into @Temp_AVCP_partecipanti (  RuoloPartecipante, Estero, CodiceFiscale, RagioneSociale, Aggiudicatario)
				values( @RuoloPartecipante, @Estero, case when isnull( @Estero , '') = '1' then @CodicefiscaleEstero else @CodiceFiscale end , @RagioneSociale, @Aggiudicatario )



			--print '-- AGGIORNO LE RIGHE DEL GRUPPO --'
			--print '@MinRowGruppo = ' + cast(  @MinRowGruppo as varchar )
			--print '@MaxRowGruppo = ' + cast(  @MaxRowGruppo as varchar )
			--print '--------------------------------'
							
		end
			


		-- fine ciclo
		FETCH NEXT FROM CurImportCSV  INTO @Idrow, @Anno, @NumeroAutorita, @Cig, @CFprop, @Denominazione, @Scelta_contraente, @ImportoAggiudicazione, @DataInizio, @Datafine, @ImportoSommeLiquidate, @Oggetto, @DataPubblicazione, @Warning, @Gruppo, @Ruolopartecipante, @Estero, @Codicefiscale, @CodicefiscaleEstero, @Ragionesociale, @aggiudicatario
	END
	 
	CLOSE CurImportCSV
	DEALLOCATE CurImportCSV

			
			
	-- se gruppo corrente è pieno
	if @CurrentGruppo <> ''
	begin
	
		set @IdOE = 0
		
		-- verifico il gruppo corrente se esisteva
		select @IdOE = id  from CTL_DOC with(nolock)
			inner join CTL_DOC_VALUE with(nolock) on id = idheader and dzt_name = 'RagioneSociale'
			where TipoDoc = 'AVCP_GRUPPO' and value = @CurrentGruppo and LinkedDoc = @VersioneLotto and StatoFunzionale = 'Pubblicato' and deleted = 0 

		if isnull( @IdOE , 0 ) <> 0	
		begin
			-- se è cambiato 
			if dbo.AVCP_IMPORT_CSV_IS_GRUPPO_CHANGED( @IdDoc , @IdOE , @MinRowGruppo , @MaxRowGruppo  ) = 1
			begin
				-- metto a modificato la versione precedente
				update CTL_DOC set StatoFunzionale = 'Variato' , deleted = 1 where id = @IdOE

				-- creo il nuovo gruppo con la  collezione caricata in memoria 			
				exec AVCP_IMPORT_CSV_MAKE_GRUPPO  @IdOE , @VersioneLotto , @FascicoloLotto , @IdDoc , @MinRowGruppo , @MaxRowGruppo  , @IdUser , @Azienda
				
			end
		end
		else		-- altrimenti
		begin
			-- creo il nuovo gruppo con la  collezione caricata in memoria 			
			exec AVCP_IMPORT_CSV_MAKE_GRUPPO  @IdOE , @VersioneLotto , @FascicoloLotto , @IdDoc , @MinRowGruppo , @MaxRowGruppo ,  @IdUser , @Azienda
		end

	end

	-- cursore sulla table #TEMP_LOTTI_NEW per eseguire la stored dei WARNING
	declare @Id_Lotto INT   
	declare CurProg_LOTTI Cursor Static for 

	select Id_Lotto from #TEMP_LOTTI_NEW  
		
	open CurProg_LOTTI

	FETCH NEXT FROM CurProg_LOTTI 
	INTO @Id_Lotto
		WHILE @@FETCH_STATUS = 0
			BEGIN       
				  
				  EXEC AVCP_CONTROLLI_DOCUMENT_AVCP @Id_Lotto
				 			 
				FETCH NEXT FROM CurProg_LOTTI 
			   INTO @Id_Lotto
			 END 

	CLOSE CurProg_LOTTI
	DEALLOCATE CurProg_LOTTI

	drop table #TEMP_LOTTI_NEW
	
		
end			









GO
