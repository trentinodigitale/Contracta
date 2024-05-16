USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_BANDO_FABBISOGNI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_BANDO_FABBISOGNI] 
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
	
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) and jumpcheck = '1-FABBISOGNI_COMUNICAZIONE_GENERICA' and StatoFunzionale='InLavorazione'
	
	if @Errore = '' and @id is null
	begin
		
		---Insert nella CTL_DOC per creare la comunicazione capogruppo
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck,Note)
			VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Generica',@Fascicolo,@Body,@ProtocolloBAndo,@idDoc,@azienda,'1-FABBISOGNI_COMUNICAZIONE_GENERICA' ,'' )		
		
		set @id = SCOPE_IDENTITY()

		--INSERIMENTO RICHIESTARISPOSTA DELLA COMUNICAZIONE PRINCIPALE
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
			values	(@Id,'DIRIGENTE','0','RichiestaRisposta','si')
					 
		-- creiamo le singole comunicazioni	una per ente destinatario
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,Azienda,Destinatario_Azi,Destinatario_User, Data,JumpCheck) 
			select @IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,@ProtocolloBAndo,'',@azienda,IdAzi, ISNULL(idpfu,0), getDate(),'1-FABBISOGNI_COMUNICAZIONE_GENERICA' 
				from CTL_DOC_Destinatari with(nolock)	
				where idheader=@idDoc 

		-- per tutte le comunicazioni figlie destinate ad un azienda e non ad un utente ( Destinatario_User a 0 ) aggiungiamo come destinatari mail tutti gli utenti dell'azienda
		--		con il profilo FabbOperativo
		INSERT INTO CTL_DOC_Destinatari( idHeader, IdPfu, IdAzi, aziRagioneSociale )
			select a.id, p.idpfu, a.Destinatario_Azi, ''
				from ctl_doc a with(nolock)
						inner join profiliutente p with(nolock) on p.pfuIdAzi = a.Destinatario_Azi and p.pfuDeleted = 0
						inner join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = p.idpfu and pa.dztNome = 'Profilo' and pa.attValue = 'FabbOperativo'
				where a.LinkedDoc = @Id and a.tipodoc = 'PDA_COMUNICAZIONE_GARA' and a.Destinatario_User = 0

	end


	-- ritorna l'id della nuova comunicazione appena creata se non ci sono stati errori
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
