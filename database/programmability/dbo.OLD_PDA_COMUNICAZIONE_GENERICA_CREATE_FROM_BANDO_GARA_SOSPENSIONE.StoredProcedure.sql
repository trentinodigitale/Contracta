USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_BANDO_GARA_SOSPENSIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_BANDO_GARA_SOSPENSIONE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @c as INT
	declare @n as INT
	declare @PrevDoc as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
	declare @Errore as nvarchar(2000)
	declare @CUP as varchar(20)
	declare @CIG as varchar(20)
	declare @ProtocolloBAndo as varchar(50)
	declare @VersioneLinkedDoc as varchar(50)
	
	
	set @Errore=''

	--Non può essere attivata se è già presente, anche se solo in lavorazione, un comando di Revoca, Proroga, Rettifica e Modifica della Gara;	

	IF EXISTS ( select * from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) and jumpcheck = '0-REVOCA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di sospensione non puo essere creato se non viene conclusa la revoca in corso sulla procedura'
	END

	IF EXISTS ( select * from ctl_doc with(nolock) where LinkedDoc=@idDoc and TipoDoc='PROROGA_GARA' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di sospensione non puo essere creato se non viene conclusa l''estensione in corso sulla procedura'
	END

	IF EXISTS ( select * from ctl_doc with(nolock) where LinkedDoc=@idDoc and TipoDoc='RETTIFICA_GARA' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di sospensione non puo essere creato se non viene conclusa la rettifica in corso sulla procedura'
	END

	IF EXISTS ( select * from ctl_doc with(nolock) where LinkedDoc=@idDoc and TipoDoc='BANDO_MODIFICA' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di sospensione non puo essere creato se non viene conclusa la modifica bando in corso sulla procedura'
	END
		

	set @id = null
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) and jumpcheck = '0-SOSPENSIONE_GARA' and StatoFunzionale='InLavorazione'
	

	if @Errore = '' and @id is null
	begin
		
		-- cambio statoFunzionale del Bando
		Update CTL_DOC set StatoFunzionale='InSospensione' where id=@idDoc 

		 --recupero un eventuale precedente sospensione inviata
		 Select 
			@PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			from CTL_DOC with(nolock) 
				where LinkedDoc=@idDoc and tipodoc='PDA_COMUNICAZIONE_GENERICA' 
					and JumpCheck='0-SOSPENSIONE_GARA' and Statofunzionale='Inviato'	


		--recupero campi per inserire la nuova comunicazione capogruppo
		Select 
			@IdPfu=IdPfu,
			@Fascicolo=Fascicolo,
			--@ProtocolloGenerale=ProtocolloGenerale,
			--@DataProtocolloGenerale=DataProtocolloGenerale,
			@ProtocolloRiferimento=ProtocolloRiferimento,
			@Body=Body,@azienda=azienda,
			@StrutturaAziendale=StrutturaAziendale 

			from CTL_DOC with(nolock) where id=@idDoc
		
		Select 
			@CIG=CIG,
			@CUP=CUP,
			@ProtocolloBAndo=Protocollo, 
			@VersioneLinkedDoc=case when TipoProceduraCaratteristica='RDO' then 'BANDO_GARA-RDO' else 'BANDO_GARA' end 

			from Document_Bando with(nolock) 
				inner join ctl_doc with(nolock) on id=idheader 
			where  idheader=@idDoc

		---Insert nella CTL_DOC per creare la comunicazione capogruppo
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,PrevDoc,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck,Note,VersioneLinkedDoc,Caption)
			VALUES(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Sospensione Procedura ' + @ProtocolloBAndo ,@PrevDoc,@Fascicolo,@Body,@ProtocolloBAndo,@idDoc,@azienda,@StrutturaAziendale,'0-SOSPENSIONE_GARA','',@VersioneLinkedDoc,'Sospensione Procedura' )

		set @Id = SCOPE_IDENTITY()	

		
		--INSERIMENTO CIG
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','CIG',@CIG)
		
		--INSERIMENTO CUP
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','CUP',@CUP)

		--INSERIMENTO RICHIESTARISPOSTA DELLA COMUNICAZIONE PRINCIPALE
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value) 
		 values	(@Id,'DIRIGENTE','0','RichiestaRisposta','no')
	end		
	
	-- rirorna l'id della nuova comunicazione appena creata se non ci sono stati errori
	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end	

END







GO
