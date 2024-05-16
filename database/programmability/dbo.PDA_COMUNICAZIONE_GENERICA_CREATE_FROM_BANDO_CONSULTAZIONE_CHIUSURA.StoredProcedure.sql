USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_BANDO_CONSULTAZIONE_CHIUSURA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_BANDO_CONSULTAZIONE_CHIUSURA] 
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
	
	declare @JumpCheck as varchar(200)
	declare	@statoAgg as varchar(200)
	declare @CriterioAggiudicazioneGara varchar(100)

	set @Errore=''
	
	set @id = null

	--SE NON SONO PERVENUTE RISPOSTE NON HA SENSO CREARE LA COMUNICAZIONE
	IF NOT EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='RISPOSTA_CONSULTAZIONE' and StatoFunzionale='Inviato' )
	BEGIN
		set @Errore = 'Il documento non puo essere creato in quanto sulla Consultazione Preliminare non risultano pervenute risposte'
	END

	
	if @Errore = '' and @id is null
	begin
		--recupero campi per inserire la nuova comunicazione capogruppo
		Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloBAndo=Protocollo,@Body=Body,@azienda=azienda from CTL_DOC where id=@idDoc
		


		declare @Note as nvarchar(max)
		set @JumpCheck='0-BANDO_CONSULTAZIONE_GENERICA_CHIUSURA'
		set @CriterioAggiudicazioneGara='99999'
		set @Note=dbo.RisolvoTemplatePDAMicrolotti(@idDoc,@JumpCheck,@statoAgg,@CriterioAggiudicazioneGara)

		

		---Insert nella CTL_DOC per creare la comunicazione capogruppo
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck,Note)
		VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Generica di Chiusura',@Fascicolo,@Body,@ProtocolloBAndo,@idDoc,@azienda,'0-BANDO_CONSULTAZIONE_GENERICA_CHIUSURA',@Note )		
		
		set @id=SCOPE_IDENTITY()

		--INSERIMENTO RICHIESTARISPOSTA DELLA COMUNICAZIONE PRINCIPALE
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','RichiestaRisposta','no')

		 -- lista dei fornitori - creiamo le singole comunicazioni
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,Azienda,Destinatario_Azi,Data,JumpCheck,Note) 
			select @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica di Chiusura',@Fascicolo,@Id,@Body,@ProtocolloBAndo,'',@azienda,Azienda,getDate(),'0-BANDO_CONSULTAZIONE_GENERICA_CHIUSURA' ,@Note
				from ctl_doc 			
				where LinkedDoc=@idDoc and TipoDoc='RISPOSTA_CONSULTAZIONE' and StatoFunzionale='Inviato'
	
	
	
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
