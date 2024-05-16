USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODULO_TEMPLATE_REQUEST_VER2_CREATE_FROM_TEMPLATE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[MODULO_TEMPLATE_REQUEST_VER2_CREATE_FROM_TEMPLATE] 
	( @idDoc int , @IdUser int  )
AS
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

	set @IsNewDoc = 0
	set @Id = 0 
	set @Errore = ''
	--set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @idDoc as varchar )

	Select @IdPfu=IdPfu, @Fascicolo=Fascicolo, @Protocollo=Protocollo, @JumpCheck  = JumpCheck  , @StatoFunzionale  = StatoFunzionale from CTL_DOC where id=@idDoc
	
	select @Id = Id from ctl_doc where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idDoc

	--- verifico se esiste un documento creato per aprirlo
	if isnull( @Id , 0 ) = 0 
	begin	


		---Insert nella CTL_DOC per creare il modulo di esempio
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck , Caption ,idPfuInCharge , Versione )
			VALUES(@IdUser,'MODULO_TEMPLATE_REQUEST','Modulo di Esempio',@Fascicolo,@Body,@Protocollo ,@idDoc,@azienda,@JumpCheck , 'Definizione Request - ' + @JumpCheck , @IdUser , '2' )
			--VALUES(@IdUser,'MODULO_TEMPLATE_REQUEST_VER2','Modulo di Esempio',@Fascicolo,@Body,@Protocollo ,@idDoc,@azienda,@JumpCheck , 'Definizione Request - ' + @JumpCheck , @IdUser , '2' )

		set @Id = SCOPE_IDENTITY()	


		-- indico che il documento è nuovo
		set @IsNewDoc = 1

	end


	-- se il documento è nuovo dopo aver generato il modello per la compilazione inizializzo i dati indicati dalla caratteristica sorgente
	--if @IsNewDoc = 1
	--begin
	--	exec TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE  @idDoc , @Modello_Modulo , @Id 
	--end


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
