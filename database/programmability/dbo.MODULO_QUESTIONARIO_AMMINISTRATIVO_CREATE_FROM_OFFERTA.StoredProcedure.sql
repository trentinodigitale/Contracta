USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODULO_QUESTIONARIO_AMMINISTRATIVO_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[MODULO_QUESTIONARIO_AMMINISTRATIVO_CREATE_FROM_OFFERTA]
	( @idDoc int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	declare @Modello_Modulo		as varchar (500)
	declare @IdQuest as int
	declare @IdGara as int

	set @Errore = ''

	SET NOCOUNT ON

	set @id = 0
	
	
	--if @Errore = ''
	--begin
		--La make doc from riapre il documento corrente in lavorazione o confermato se esiste altrimenti lo crea nuovo
		select @id=id from CTL_DOC with(nolock) where LinkedDoc=@idDoc and TipoDoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and deleted=0 
	--END

	--CREA IL DOC
	if ISNULL(@id,0)=0 --and @Errore = ''
	begin

		
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , deleted  ,LinkedDoc,Body,Fascicolo )
			select @idUser, 'MODULO_QUESTIONARIO_AMMINISTRATIVO' ,  azienda , 0 , id , body ,C.Fascicolo
				from CTL_DOC C with(NOLOCK) 
				WHERE  C.Id=@idDoc 						
					
		set @id=SCOPE_IDENTITY()


		--recupero id gara dall'offerta
		set @IdGara=0
		select @IdGara=linkeddoc from ctl_doc with (nolock) where id = @idDoc

		--recupero il questionario amministrativo dalla gara
		set @IdQuest=0
		select @IdQuest=id 
			from ctl_doc with (nolock) 
			where tipodoc='QUESTIONARIO_AMMINISTRATIVO' 
				and linkeddoc = @IdGara
				and isnull(jumpcheck,'') = ''

		-- gli associo il modello per la rappresentazione e salvataggio
		set @Modello_Modulo = 'MODULO_QUESTIONARIO_AMMINISTRATIVO_' + cast(  @IdQuest as varchar(20))

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO' , @Modello_Modulo )
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO_SAVE' , @Modello_Modulo ) --+ '_SAVE')

		-- genero i modelli ed il template per il MODULO_QUESTIONARIO_AMMINISTRATIVO
		--exec MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO @IdQuest

	end

	
	--ritorno id del modulo questionario per poterlo aprire
	if @Errore = '' and ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @id as id
				
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end



END

	
GO
