USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_MODULO_TEMPLATE_REQUEST_CREATE_FOR]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE PROCEDURE [dbo].[OLD2_MODULO_TEMPLATE_REQUEST_CREATE_FOR] 
	( @idDoc int , @IdUser int ,@JumpCheck_FROM as varchar(500) , @NoReturn as int = 0 )
AS
--Versione=1&data=2016-10-21&Attivita=126293&Nominativo=Sabato
--Versione=2&data=2019-02-18&Attivita=159567&Nominativo=Sabato

BEGIN
	SET NOCOUNT ON;

	declare @Id					as INT
	declare @c					as INT
	declare @n					as INT
	declare @Body				as nvarchar(2000)
	declare @azienda			as varchar(50)
	declare @Fascicolo			as varchar(50)
	declare @Protocollo			as varchar(50)
	declare @StatoFunzionale	as varchar(100)
	declare @IdPfu				as INT

	declare @Modello_Modulo		as varchar (500)

	declare @tipoDoc			as varchar(500)
	declare @JumpCheck			as varchar(500)
	declare @Errore				as nvarchar(max)
	declare @IsNewDoc			int
	declare @Versione			as varchar(20)
	declare @isrti as int
	declare @IdOfferta as int
	declare @idTemplate int

	
	set @isrti=1
	set @IsNewDoc = 0
	
	
	set @Id = 0 
	set @IdOfferta = 0

	set @Errore = ''


	
	if exists( select id from CTL_DOC with(nolock) where id = @idDoc and TipoDoc in (  'TEMPLATE_CONTEST'  )  ) 
	begin
		select @idTemplate = @idDoc , @JumpCheck  = @JumpCheck_FROM , @Versione = Versione from CTL_DOC with(nolock)   where id = @idDoc 
	end
	else
	begin

	
		if @JumpCheck_FROM not in ('DGUE_RTI','DGUE_AUSILIARIE','DGUE_ESECUTRICI','DGUE_SUBAPPALTO')
		BEGIN
			-- recupero l'id del template
			select @idTemplate = t.id , @JumpCheck  = t.JumpCheck , @Versione = t.Versione
				from ctl_doc I with(nolock) 
					inner join CTL_DOC t with(nolock)  on t.linkeddoc = I.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
					where I.id = @idDoc and T.JumpCheck=@JumpCheck_FROM
		END
		ELSE
		BEGIN
			-- recupero l'id del template
			select @idTemplate = t.id , @JumpCheck  = @JumpCheck_FROM , @Versione = t.Versione,@IdOfferta=O.id
				from ctl_doc I with(nolock)  ---RISPOSTA
					inner join ctl_doc IR with(nolock)  on IR.id=I.LinkedDoc and IR.TipoDoc='RICHIESTA_COMPILAZIONE_DGUE'
					inner join ctl_doc O with(nolock)  on  IR.LinkedDoc=O.id --and O.TipoDoc='OFFERTA'
					inner join CTL_DOC t with(nolock)  on t.linkeddoc = O.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
					where I.id = @idDoc  and T.JumpCheck=@JumpCheck_FROM

			

			-- se non trovo il template specifico provo con quello della mandataria ( BASE ) 
			if isnull( @idTemplate , 0 ) = 0 
			begin

				-- recupero l'id del template
				select @idTemplate = t.id , @JumpCheck  = 'DGUE_MANDATARIA',@IdOfferta=O.id
					from ctl_doc I with(nolock)  ---RISPOSTA
						inner join ctl_doc IR with(nolock)  on IR.id=I.LinkedDoc and IR.TipoDoc='RICHIESTA_COMPILAZIONE_DGUE'
						inner join ctl_doc O with(nolock)  on  IR.LinkedDoc=O.id --and O.TipoDoc='OFFERTA'
						inner join CTL_DOC t with(nolock)  on t.linkeddoc = O.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
						where I.id = @idDoc  and T.JumpCheck='DGUE_MANDATARIA'
			end


		END

	end

	if isnull( @idTemplate , 0 ) = 0 
	begin
		-- provo a navigare per le istanze
		select @idTemplate = t.id , @JumpCheck  = @JumpCheck_FROM , @Versione = t.Versione
			from ctl_doc I with(nolock)  ---RISPOSTA
				inner join CTL_DOC t with(nolock)  on t.linkeddoc = i.LinkedDoc and t.deleted = 0 and t.TipoDoc = 'TEMPLATE_CONTEST'  
				where I.id = @idDoc  
	end


	if isnull( @idTemplate , 0 ) = 0 
	begin
		-- ritorna l'errore
		set @Errore = 'Errore, non e'' stato trovato il template per la generazione' 
	end

	set @Versione  = isnull( @Versione , 0 ) 

	--set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @idTemplate as varchar )

	Select @IdPfu=IdPfu, @azienda = azienda , @Fascicolo=Fascicolo, @Protocollo=Protocollo  , @StatoFunzionale  = StatoFunzionale 
		from CTL_DOC with(nolock)  where id=@idDoc
	
	select @Id = Id from ctl_doc with(nolock)  where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idDoc

	
	--- verifico se esiste un documento creato per aprirlo
	if isnull( @Id , 0 ) = 0 
	begin
		
		--consento la creazione solo se il documento sorgnte è in lavorazione
		if @StatoFunzionale='InLavorazione'
		BEGIN

			---Insert nella CTL_DOC per creare il modulo di esempio
			insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,JumpCheck , Caption ,idPfuInCharge ,VersioneLinkedDoc , Versione )
				VALUES(@IdUser,'MODULO_TEMPLATE_REQUEST','Modulo di Esempio',@Fascicolo,@Body,@Protocollo ,@idDoc,@azienda,@JumpCheck , 'Modulo - ' + @JumpCheck  , @IdUser, case when @JumpCheck = 'DGUE' then '' when @JumpCheck = 'DGUE_MANDATARIA' then 'DGUE_MANDATARIA'  else  @JumpCheck end , @Versione )

			set @Id = SCOPE_IDENTITY()	

			--ogni documento avrà sempre la sua rappresentazione
			if @Versione < '2'
			begin

				set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @id  as varchar )


				--associo il modello per la compilazione del modulo 
				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO' , @Modello_Modulo )
				insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO_SAVE' , @Modello_Modulo ) --+ '_SAVE')

			end

			-- si riportano sul documento appena creato i dati di base recuperati dal modulo presente sul bando ( me,sda,rdo,gara..... )
			-- recupero il modulo del template
			declare @IdModTemplate int
			select @IdModTemplate = Id from ctl_doc where deleted = 0 and TipoDoc = 'MODULO_TEMPLATE_REQUEST' and linkeddoc = @idTemplate
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				select @Id , DSE_ID, Row, DZT_Name, Value 
					from CTL_DOC_Value with(nolock) 
					where IdHeader = @IdModTemplate and DSE_ID in (  'MODULO' , 'ITERAZIONI' , 'UUID' ) 

			set @IsNewDoc = 1
		
		END
		else
		BEGIN
			set @Errore='Documento non presente'
		END

	end
	else
	begin
		--ogni documento avrà sempre la sua rappresentazione
		set @Modello_Modulo = 'MODULO_TEMPLATE_REQUEST_' + cast( @id  as varchar )
	end

	
	--inserisco sentinella per offerte che non sono in RTI
	if @IdOfferta = 0
		set @IdOfferta = @idDoc

	IF NOT EXISTS (select id 
						from CTL_DOC with (nolock) 
							inner join CTL_DOC_Value with (nolock) on Id=IdHeader and DSE_ID='RTI' and  DZT_Name='PartecipaFormaRTI' 
						where Id=@IdOfferta and Value='1'
				)
	BEGIN
		SET @isrti=0
	END
	
	-- aggiorna l'idpfu in charge con l'utente dell'istanza, ma solo se non è già generato il file da firmare , 
	--serve a controllare il CF del file allegato
	if isnull( @Id , 0 ) <> 0 
	begin
		update ctl_doc set idPfuInCharge = @idPfu where id =  @Id and isnull( SIGN_HASH , '' ) = ''
		update ctl_doc set Caption=case when @isrti=0 then 'Modulo - DGUE' else  'Modulo - ' + @JumpCheck end  where Id=@Id
	end
	
	
	-- se non esiste il modello per la compilazione lo creo
	if not exists( select * from CTL_Models with(nolock)  where MOD_ID = @Modello_Modulo ) and @Versione < '2'
	begin

		exec MAKE_MODULO_TEMPLATE_REQUEST @idTemplate , @Modello_Modulo , @Id

	end


	-- se il documento è nuovo dopo aver generato il modello per la compilazione inizializzo i dati indicati dalla caratteristica sorgente
	if @IsNewDoc = 1 and @Versione < '2'
	begin
		exec TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE  @idTemplate , @Modello_Modulo , @Id 
	end	


	
	if @IsNewDoc = 1 and @Versione = '2'
	begin	
		
		-- se la versione = 2 allora il DGUE è gestito dalla pagina \Application\CustomDoc\TEMPLATE_REQUEST.ASP
		-- in questo caso popolo il documento di esempio con tutte le coppie valori
		-- relative a campi che hanno SorgenteCampo Valorizzato
		-- exec ESPD_FIELD_DEFAULT_VALUE   @idTemplate
		exec TEMPLATE_REQUEST_INIT_FIELD_FROM_SORGENTE_VER2  @idTemplate , @Id 

		
		
		
	end 

	if @Errore = ''
	begin	
		if @NoReturn = 0
				-- ritorna l'id della nuova comunicazione appena creata
			select @Id as id,'' as Errore
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end



END
























GO
