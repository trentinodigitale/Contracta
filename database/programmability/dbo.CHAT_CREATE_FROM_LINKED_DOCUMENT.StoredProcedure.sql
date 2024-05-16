USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CHAT_CREATE_FROM_LINKED_DOCUMENT]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[CHAT_CREATE_FROM_LINKED_DOCUMENT]
	( @idDoc int , @IdUser int )
AS
BEGIN
SET NOCOUNT ON;

	declare @Id as INT
	declare @linkeddoc as INT

	--recupero il linkedDoc del documento
	select @linkeddoc=linkeddoc from ctl_doc where id=@idDoc
	
	-- verifico se esiste un documento CHAT nel sistema per utente
	select @Id = id from CTL_DOC where LinkedDoc = @linkeddoc and deleted = 0 and TipoDoc in ('CHAT')  and IdPfu=@IdUser
	if @Id is null
	begin
		-- CREO IL DOCUMENTO
		INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,LinkedDoc )
			VALUES (@IdUser  , 'CHAT' , @IdUser ,@linkeddoc)
		
		set @id = SCOPE_IDENTITY()

		
		
	end
	-- Nella ctl_doc_destinatari si mette l'idpfu del compilatore 
	-- del documento sul quale attivo la conversazione e idpfuincharge dello stesso se non sono presenti
	declare @idpfudest int
	Select 	@idpfudest=idpfu from ctl_doc where id=@linkeddoc
	--SE NON CI STA LI INSERISCE
		IF NOT EXISTS (Select * from CTL_DOC_Destinatari where idHeader=@id and IdPfu=@idpfudest)
		BEGIN
			INSERT INTO CTL_DOC_Destinatari (idHeader,IdPfu,aziRagioneSociale)
			Select @id,@idpfudest,0
		END	
		Select 	@idpfudest=ISNULL(idPfuInCharge,0) from ctl_doc where id=@linkeddoc
		IF @idpfudest > 0
		BEGIN
			IF NOT EXISTS (Select * from CTL_DOC_Destinatari where idHeader=@id and IdPfu=@idpfudest)
			BEGIN
				INSERT INTO CTL_DOC_Destinatari (idHeader,IdPfu,aziRagioneSociale)
				Select @id,@idpfudest,0
			END			
		END
	

	if  ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
	
	end
	else
	begin

		select 'Errore' as id , 'ERROR' as Errore

	end
END
GO
