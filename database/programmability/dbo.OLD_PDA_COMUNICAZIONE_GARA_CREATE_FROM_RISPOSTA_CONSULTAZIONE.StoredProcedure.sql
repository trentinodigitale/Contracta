USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_GARA_CREATE_FROM_RISPOSTA_CONSULTAZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_GARA_CREATE_FROM_RISPOSTA_CONSULTAZIONE] 
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

	set @Errore=''
	
	set @id = null

	----SE NON SONO PERVENUTE RISPOSTE NON HA SENSO CREARE LA COMUNICAZIONE
	--IF NOT EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='RISPOSTA_CONSULTAZIONE' and StatoFunzionale='Inviato' )
	--BEGIN
	--	set @Errore = 'Il documento non puo essere creato in quanto sulla Consultazione Preliminare non risultano pervenute risposte'
	--END

	
	if @Errore = '' and @id is null
	begin
		--recupero campi per inserire la nuova comunicazione capogruppo
		Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloBAndo=Protocollo,@Body=Body,@azienda=azienda from CTL_DOC where id=@idDoc
		
		-----Insert nella CTL_DOC per creare la comunicazione capogruppo
		--insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck,Note)
		--VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Generica',@Fascicolo,@Body,@ProtocolloBAndo,@idDoc,@azienda,'0-BANDO_CONSULTAZIONE_GENERICA','' )		
		
		--set @id=SCOPE_IDENTITY()

		----INSERIMENTO RICHIESTARISPOSTA DELLA COMUNICAZIONE PRINCIPALE
		--insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		-- values	(@Id,'DIRIGENTE','0','RichiestaRisposta','no')

		 -- lista dei fornitori - creiamo le singole comunicazioni
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,Azienda,Destinatario_Azi,Data,JumpCheck,Caption ) 

			select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione Integrativa',@Fascicolo,@idDoc,@Body,@ProtocolloBAndo,'',Destinatario_Azi,Azienda,getDate(),
			'1-BANDO_CONSULTAZIONE_COMUNICAZIONE_RISPOSTA'  --'0-BANDO_CONSULTAZIONE_GENERICA' 
			  ,'Comunicazione Integrativa'

				from ctl_doc 			

				where id=@idDoc and TipoDoc='RISPOSTA_CONSULTAZIONE' --and StatoFunzionale='Inviato'
	
		
		set @id=SCOPE_IDENTITY()
	
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
