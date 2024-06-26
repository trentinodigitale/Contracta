USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_GARA] 
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
			@CUP=CUP
		from CTL_DOC with(nolock)
			inner join Document_Bando with(nolock) on id=idHeader
			where id=@idDoc
	
	select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) and right(jumpcheck,27) = 'GARA_COMUNICAZIONE_GENERICA' and StatoFunzionale='InLavorazione'
	
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
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck,Note)
		VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Generica',@Fascicolo,@Body,@ProtocolloBAndo,@idDoc,@azienda,'0-GARA_COMUNICAZIONE_GENERICA','' )		
		
		set @id=SCOPE_IDENTITY()

		--INSERIMENTO RICHIESTARISPOSTA DELLA COMUNICAZIONE PRINCIPALE
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','RichiestaRisposta','no')

		 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','CIG',@CIG)

		 insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','CUP',@CUP)


		 
		 -- lista dei fornitori - creiamo le singole comunicazioni		 
		 
		 -- Se siamo su un invito e non sono scaduti i termini per la presentazione delle offerte, allora va a tutti gli invitati
		 if @TipoBandoGara = 3 and @DataScadenzaOfferta > GETDATE()
		 BEGIN
			insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,Azienda,Destinatario_Azi,Data,JumpCheck) 
				select @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,@ProtocolloBAndo,'',@azienda,IdAzi,getDate(),'0-GARA_COMUNICAZIONE_GENERICA' 
					from CTL_DOC_Destinatari 			
						where idheader=@idDoc 
		 END
		 -- altrimenti a tutti coloro che hanno sottoposto offerta
		 ELSE IF @DataScadenzaOfferta < GETDATE()
		 BEGIN
			 insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,Azienda,Destinatario_Azi,Data,JumpCheck) 
				select distinct @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,@ProtocolloBAndo,'',@azienda,Azienda,getDate(),'0-GARA_COMUNICAZIONE_GENERICA' 
					from [BANDO_SDA_LISTA_OFFERTE]
						where idheader=@idDoc 				
				
		 END

	
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
