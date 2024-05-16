USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_CONCORSO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_CONCORSO] 
( @idDoc int , @IdUser int  ) as
BEGIN
	SET NOCOUNT ON;
	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloBAndo as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
	declare @TipoBandoGara as varchar(20)
	declare @DataScadenzaOfferta as datetime
	declare @CIG as varchar(20)
	declare @CUP as varchar(20)
	declare @IdDocPrimaFase as int

	set @IdDocPrimaFase = 0

	set @Errore=''
	
	set @id = null

	--recupero campi per inserire la nuova comunicazione capogruppo
		Select 
			@IdPfu=IdPfu,
			@Fascicolo=Fascicolo,
			@ProtocolloBAndo=Protocollo,
			@Body=Body,
			@azienda=azienda,
			@TipoBandoGara=TipoBandoGara,
			@DataScadenzaOfferta=DataScadenzaOfferta,
			@CIG=CIG,
			@CUP=CUP,
			@IdDocPrimaFase = ISNULL(linkeddoc,0)
		from CTL_DOC with(nolock)
			inner join Document_Bando with(nolock) on id=idHeader
			where id=@idDoc
	
	select @id = id 
		from CTL_DOC WITH (NOLOCK)
		where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) 
		and right(jumpcheck,31) = 'CONCORSO_COMUNICAZIONE_GENERICA' and StatoFunzionale='InLavorazione'
	
	--SE TROVA LA COMUNICAZIONE, CREATA PRIMA DELLA SCADENZA LA INVALIDA
	--QUESTO PERCHE' IL NUMERO DI INVITATI NON E' DETTO CHE SIA LO STESSO DEI PARTECIPANTI
	IF @id is not null
	BEGIN
		if EXISTS (select * from ctl_doc where id=@id and ctl_doc.Data < @DataScadenzaOfferta)
		BEGIN
			update ctl_doc set StatoFunzionale='Invalidato' , StatoDoc='Invalidate' where id=@id
			set @id= null
		END
	END

	if @Errore = '' and @id is null
	begin
		
		
		---Insert nella CTL_DOC per creare la comunicazione capogruppo
		insert into 
			CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck,Note)
			VALUES
			(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Generica',@Fascicolo,@Body,@ProtocolloBAndo,@idDoc,@azienda,'0-CONCORSO_COMUNICAZIONE_GENERICA','' )		
		
		set @id=SCOPE_IDENTITY()

		-- Inserisco nella CTL_DOC_SECTION_MODEL il modello specifico di dettagli per il bando concorso

		insert into CTL_DOC_SECTION_MODEL (idheader, DSE_ID, MOD_Name)
			values
			(
				@id,
				'DETTAGLI',
				'PDA_COMUNICAZIONE_GENERICA_CONCORSO_DETTAGLIGriglia'
			)

		--INSERIMENTO RICHIESTARISPOSTA DELLA COMUNICAZIONE PRINCIPALE
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','RichiestaRisposta','no')

		 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','CIG',@CIG)

		 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','CUP',@CUP)



		CREATE TABLE #TempDestinatari_Comunicazioni(
			
			[Azienda] int,
			[Progressivo_Risposta] [varchar] (200) collate DATABASE_DEFAULT
		)


		-- Se siamo su un invito ( TipoBandoGara = 3 sul secondo giro del concorso) e non sono scaduti i termini per la presentazione delle risposte, allora va a tutti gli invitati
		-- che provengono dalla prima fase
		if @TipoBandoGara = '3' and @DataScadenzaOfferta > GETDATE()
		BEGIN	
			insert into #TempDestinatari_Comunicazioni
				(Azienda,Progressivo_Risposta)
			select 
				Azienda, Progressivo_Risposta

				from CTL_DOC_Destinatari C with (nolock)
					inner join BANDO_CONCORSO_LISTA_OFFERTE PF on StatoDoc ='Sended' and Azienda = idazi
			where C.idheader=@idDoc and PF.idHeader =@IdDocPrimaFase
		END
		-- altrimenti se scadenza superata a tutti coloro che hanno sottoposto risposta
		ELSE IF @DataScadenzaOfferta < GETDATE()
		BEGIN
				
			
			 --insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,Azienda,Destinatario_Azi,Data,JumpCheck) 
				--select distinct @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,@ProtocolloBAndo,'',@azienda,Azienda,getDate(),'0-GARA_COMUNICAZIONE_GENERICA' 
				--	from [BANDO_SDA_LISTA_OFFERTE]
				--		where idheader=@idDoc 				
			
			--CURSORE SULLA VISTA BANDO_CONCORSO_LISTA_OFFERTE
				--SELECT * FROM  BANDO_CONCORSO_LISTA_OFFERTE where idheader=@idDoc 

				--begin
					--inserisco nella ctl_doc  la com di dettaglio

					--inserisco nella ctl_doc_value il progressivo risposta

				--end
				insert into #TempDestinatari_Comunicazioni
				(Azienda,Progressivo_Risposta)
				select 
						Azienda, Progressivo_Risposta
						from 
							BANDO_CONCORSO_LISTA_OFFERTE 
						where 
							idheader = @idDoc and StatoFunzionale <> 'Annullato'
		END

		DECLARE @IdDocIstance as int = -1
		DECLARE cursorComunicazione CURSOR FOR
			select 
				Azienda, Progressivo_Risposta
				from 
					#TempDestinatari_Comunicazioni

		OPEN cursorComunicazione

		-- Dichiarazione delle variabili che conterranno i valori selezionati dal cursore
		DECLARE @AziendaIstance as varchar(max)
		DECLARE @Progressivo_RispostaIstance as varchar (max)
				
		-- Recupera il primo record dal cursore
		FETCH NEXT FROM cursorComunicazione INTO @AziendaIstance,@Progressivo_RispostaIstance
		WHILE @@FETCH_STATUS = 0
		BEGIN
								
			insert into CTL_DOC (	IdPfu,
									TipoDoc,
									Titolo,
									Fascicolo,
									LinkedDoc,
									Body,
									ProtocolloRiferimento,
									ProtocolloGenerale,
									Azienda,
									Destinatario_Azi,
									Data,
									JumpCheck) 
				values
				(
					@IdPfu,
					'PDA_COMUNICAZIONE_GARA',
					'Comunicazione Generica',
					@Fascicolo,
					@Id,
					@Body,
					@ProtocolloBAndo,
					'',
					@azienda,
					@AziendaIstance,
					getDate(),
					'0-CONCORSO_COMUNICAZIONE_GENERICA' 
				)	

			set @IdDocIstance = SCOPE_IDENTITY()
					

			INSERT INTO [dbo].[CTL_DOC_Value]
						(
							[IdHeader]
							,[DSE_ID]
							,[Row]
							,[DZT_Name]
							,[Value]
						)
					VALUES
						(
							@IdDocIstance
							,'ANONIMATO' --DSE_ID
							,0 -- Row
							,'Progressivo_Risposta' --DZT_Name
							,@Progressivo_RispostaIstance --Value
						)

			-- Inserisco nella CTL_DOC_SECTION_MODEL il modello specifico di testata per il bando concorso

			insert into CTL_DOC_SECTION_MODEL (idheader, DSE_ID, MOD_Name)
				values
				(
					@IdDocIstance,
					'TESTATA',
					'PDA_COMUNICAZIONE_GARA_TESTATA_CONCORSO'
				)

			FETCH NEXT FROM cursorComunicazione INTO @AziendaIstance,@Progressivo_RispostaIstance
		END
		-- Chiudi il cursore
		CLOSE cursorComunicazione
		DEALLOCATE cursorComunicazione

		 

	
	end


	-- rirorna l'id della nuova comunicazione appena creata se non ci sono stati errori
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id,'' as Errore
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end	



END


GO
