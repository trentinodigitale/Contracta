USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AZI_TO_DELETE_VERIFICATO_CREATE_FROM_AZI_ENTE]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AZI_TO_DELETE_VERIFICATO_CREATE_FROM_AZI_ENTE] ( @IdDoc int  , @idUser int )
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @id INT	
	DECLARE @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @TipoDoc nvarchar(100)
	declare @caption nvarchar(100)

	set @TipoDoc = 'AZI_TO_DELETE_VERIFICATO'
	set @IdAzi = @idDoc
	set @Id = 0
	set @Errore= ''
	set @caption = 'Verifica Fornitore da Cessare'


	-- Check documento 'AZI_TO_DELETE_VERIFICATO' già presente nello stato funziona inLavorazione 
	select @id = id 
			from ctl_doc with(nolock)
				where tipodoc = @TipoDoc and StatoFunzionale = 'InLavorazione' and Azienda = @IdAzi and deleted = 0 

	--se il documento di verifica non esiste lo creo    
	IF @Id = 0 
		BEGIN
			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_User, StatoFunzionale,IdPfuInCharge, jumpcheck, caption)
				values ( @IdUser, @TipoDoc, 'Saved' , @caption , '', @IdAzi , NULL ,'InLavorazione', NULL , '', @caption)
			
			set @Id = SCOPE_IDENTITY()
		END


	if @Errore = ''
		begin
			-- rirorna l'id del nuovo documento appena creato
			select @Id as id
		end
	else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
END
GO
