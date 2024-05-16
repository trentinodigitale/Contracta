USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODULO_TEMPLATE_REQUEST_CREATE_FROM_TEMPLATE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE  PROCEDURE [dbo].[MODULO_TEMPLATE_REQUEST_CREATE_FROM_TEMPLATE] 
	( @idDoc int , @IdUser int  )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;

	declare @Id					as INT
	declare @c					as INT
	declare @n					as INT
	declare @Body				as nvarchar(2000)
	declare @azienda			as varchar(50)
	declare @Fascicolo			as varchar(50)
	declare @Protocollo			as varchar(50)
	declare @StatoFunzionale	as varchar(50)
	declare @IdPfu				as INT

	declare @Modello_Modulo		as varchar (500)

	declare @tipoDoc			as varchar(500)
	declare @JumpCheck			as varchar(500)
	declare @Errore				as nvarchar(max)
	declare @IsNewDoc			int
	declare @versione			as varchar(50)

	set @IsNewDoc = 0
	set @Id = 0 
	set @Errore = ''
	--set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @idDoc as varchar )

	Select @IdPfu=IdPfu, @Fascicolo=Fascicolo, @Protocollo=Protocollo, @JumpCheck  = JumpCheck  , 
	@StatoFunzionale  = StatoFunzionale , @versione = isnull( versione , '' ) from CTL_DOC with(nolock) where id=@idDoc
	
	select @Id = Id from ctl_doc with(nolock) where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idDoc

	--- verifico se esiste un documento creato per aprirlo
	if isnull( @Id , 0 ) = 0 
	begin	

	

		---Insert nella CTL_DOC per creare il modulo di esempio
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck , Caption ,idPfuInCharge , versione)
			VALUES(@IdUser,'MODULO_TEMPLATE_REQUEST','Modulo di Esempio',@Fascicolo,@Body,@Protocollo ,@idDoc,@azienda,@JumpCheck , 'Definizione Request - ' + @JumpCheck , @IdUser , @versione)

		set @Id = SCOPE_IDENTITY()	

		if @versione = '' 
		begin
			set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @Id as varchar )

			--associo il modello per la compilazione del modulo 
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO' , @Modello_Modulo )
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO_SAVE' , @Modello_Modulo + '_SAVE' )
		end
		-- indico che il documento è nuovo
		set @IsNewDoc = 1

	end
	else
	begin
		--ogni documento avrà sempre la sua rappresentazione
		set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @Id  as varchar )
	end

	--else
	--begin

	--	----associo il modello per la compilazione del modulo 
	--	--delete from CTL_DOC_SECTION_MODEL where IdHeader = @Id
	--	--insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO' , @Modello_Modulo )
	--	--insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO_SAVE' , @Modello_Modulo )

	--	---- tolgo eventuali iterazioni generate nell'esempio precedente
	--	--delete from CTL_DOC_Value where idheader = @id and DSE_ID = 'ITERAZIONI'
		

	--end

	-- per le prime versioni era necessario avere il template
	if @versione = '' 
	begin

		-- se il template è in lavorazione allora il modello precedente deve essere cancellato e ricreato
		--if @StatoFunzionale = 'InLavorazione'
		begin

			delete from CTL_Models where [MOD_ID] = @Modello_Modulo
			delete from CTL_ModelAttributes where [MA_MOD_ID] = @Modello_Modulo
			delete from CTL_ModelAttributeProperties where [MAP_MA_MOD_ID] = @Modello_Modulo

		end

		-- se non esiste il modello per la compilazione lo creo
		if not exists( select mod_id from CTL_Models with(nolock) where MOD_ID = @Modello_Modulo )
		begin

			exec MAKE_MODULO_TEMPLATE_REQUEST @idDoc , @Modello_Modulo , @Id

		end

		-- se il documento è nuovo dopo aver generato il modello per la compilazione inizializzo i dati indicati dalla caratteristica sorgente
		--if @IsNewDoc = 1
		begin
			exec TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE  @idDoc , @Modello_Modulo , @Id 
		end

	end


	if @Errore = ''
	begin	
			-- ritorna l'id della nuova comunicazione appena creata
		select @Id as id
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end



END













GO
