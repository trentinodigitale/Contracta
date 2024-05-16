USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_MODULO_TEMPLATE_REQUEST_CREATE_FROM_ISTANZA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE  PROCEDURE [dbo].[OLD_MODULO_TEMPLATE_REQUEST_CREATE_FROM_ISTANZA] 
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
	
	set @IsNewDoc = 0
	
	declare @idTemplate int
	set @Id = 0 
	set @Errore = ''

	-- recupero l'id del template
	select @idTemplate = t.id , @JumpCheck  = t.JumpCheck
		from ctl_doc I
			inner join CTL_DOC t on t.linkeddoc = I.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'
			where I.id = @idDoc

	if isnull( @idTemplate , 0 ) = 0 
	begin
		-- ritorna l'errore
		set @Errore = 'Errore, non è stato trovato il template per la generazione' 
	end


	--set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @idTemplate as varchar )

	Select @IdPfu=IdPfu, @azienda = azienda , @Fascicolo=Fascicolo, @Protocollo=Protocollo  , @StatoFunzionale  = StatoFunzionale 
		from CTL_DOC where id=@idDoc
	
	select @Id = Id from ctl_doc where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idDoc

	--- verifico se esiste un documento creato per aprirlo
	if isnull( @Id , 0 ) = 0 
	begin	


		---Insert nella CTL_DOC per creare il modulo di esempio
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck , Caption ,idPfuInCharge )
			VALUES(@IdUser,'MODULO_TEMPLATE_REQUEST','Modulo di Esempio',@Fascicolo,@Body,@Protocollo ,@idDoc,@azienda,@JumpCheck , 'Modulo - ' + @JumpCheck , @IdUser )

		set @Id = SCOPE_IDENTITY()	

		--ogni documento avrà sempre la sua rappresentazione
		set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @id  as varchar )


		--associo il modello per la compilazione del modulo 
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO' , @Modello_Modulo )
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO_SAVE' , @Modello_Modulo ) --+ '_SAVE')


		-- si riportano sul documento appena creato i dati di base recuperati dal modulo presente sul bando ( me,sda,rdo,gara..... )
		-- recupero il modulo del template
		declare @IdModTemplate int
		select @IdModTemplate = Id from ctl_doc where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idTemplate
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @Id , DSE_ID, Row, DZT_Name, Value 
				from CTL_DOC_Value 
				where IdHeader = @IdModTemplate and DSE_ID in (  'MODULO' , 'ITERAZIONI' ) 

		set @IsNewDoc = 1

	end
	else
	begin
		--ogni documento avrà sempre la sua rappresentazione
		set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @id  as varchar )
	end



	-- aggiorna l'idpfu in charge con l'utente dell'istanza, ma solo se non è già generato il file da firmare , serve a controllare il CF del file allegato
	update ctl_doc set idPfuInCharge = @idPfu where id =  @Id and isnull( SIGN_HASH , '' ) = ''


	-- se non esiste il modello per la compilazione lo creo
	if not exists( select * from CTL_Models where MOD_ID = @Modello_Modulo )
	begin

		exec MAKE_MODULO_TEMPLATE_REQUEST @idTemplate , @Modello_Modulo , @Id

	end


	-- se il documento è nuovo dopo aver generato il modello per la compilazione inizializzo i dati indicati dalla caratteristica sorgente
	if @IsNewDoc = 1
	begin
		exec TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE  @idTemplate , @Modello_Modulo , @Id 
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
