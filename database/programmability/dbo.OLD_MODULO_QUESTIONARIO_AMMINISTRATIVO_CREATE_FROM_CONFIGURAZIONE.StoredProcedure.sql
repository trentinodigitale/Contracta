USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_MODULO_QUESTIONARIO_AMMINISTRATIVO_CREATE_FROM_CONFIGURAZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_MODULO_QUESTIONARIO_AMMINISTRATIVO_CREATE_FROM_CONFIGURAZIONE]
	( @idDoc int  , @idUser int )
AS
BEGIN
	declare @id int		
	declare @Errore as nvarchar(4000)
	declare @Modello_Modulo		as varchar (500)

	set @Errore = ''

	SET NOCOUNT ON

	set @id = 0

	--<img src="../images/Domain/State_OK.gif"><br>La "Lista sezioni/note/parametri" è stata modificata, è necessario eseguire il comando Verifica Informazioni

	-- Controllo che il questionario sia compilato corretamente
	IF EXISTS (SELECT Id FROM CTL_DOC WITH(NOLOCK) WHERE Id=@idDoc AND ISNULL(Note,'') <> '<img src="../images/Domain/State_ok.png">')
	BEGIN
		set @Errore = 'Per visualizzare esempio questionario necessario correggere gli errori di compilazione'
	END
	
	
	if @Errore = ''
	begin
		--La make doc from riapre il documento corrente in lavorazione o confermato se esiste altrimenti lo crea nuovo
		select @id=id from CTL_DOC with(nolock) where LinkedDoc=@idDoc and TipoDoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and deleted=0 
	END

	--CREA IL DOC
	if ISNULL(@id,0)=0 and @Errore = ''
	begin
		--CREA IL DOCUMENTO
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , deleted  ,LinkedDoc,Body,Fascicolo )
			select @idUser, 'MODULO_QUESTIONARIO_AMMINISTRATIVO' ,  azienda , 0 , id , body ,C.Fascicolo
				from CTL_DOC C with(NOLOCK) 
				WHERE  C.Id=@idDoc 						
					
		set @id=SCOPE_IDENTITY()


		-- gli associo il modello per la rappresentazione e salvataggio
		set @Modello_Modulo = 'MODULO_QUESTIONARIO_AMMINISTRATIVO_' + cast(  @idDoc as varchar(20))

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO' , @Modello_Modulo )
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) values ( @Id  , 'MODULO_SAVE' , @Modello_Modulo ) --+ '_SAVE')




	end


	--if @Errore = ''
	--BEGIN
		-- aggiorno il modello ( da ottimizzare per farlo solo quando è cambiato )
	--	exec MAKE_MODULO_QUESTIONARIO_AMMINISTRATIVO @idDoc
	--END
	--tolgo il pdf eventualmente generato
	if @Errore = ''
	begin
		update CTL_DOC  set sign_hash='', sign_lock='', SIGN_ATTACH='' where Id = @id
	end
	
	if @Errore = '' and ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
				
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end



END

	
GO
