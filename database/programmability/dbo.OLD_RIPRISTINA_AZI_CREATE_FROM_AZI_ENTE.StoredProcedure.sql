USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RIPRISTINA_AZI_CREATE_FROM_AZI_ENTE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_RIPRISTINA_AZI_CREATE_FROM_AZI_ENTE] 
	( @idDoc int , @IdUser int ,@provenienza varchar(200) = ''  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @IdAzi as int
	set @IdAzi = @idDoc

	declare @Id as INT
	set @Id = 0
		
	declare @Errore as nvarchar(2000)

	declare @TipoDoc nvarchar(20)
	set @TipoDoc = 'RIPRISTINA_AZI'
	
	declare @Deleted as INT

	set @Errore = ''

	declare @aziAcquirente int
	declare @caption nvarchar(100)

	-- Check Azienda disattivata
	select @Deleted=aziDeleted, @aziAcquirente = aziAcquirente from aziende where idazi=@IdAzi

	if @aziAcquirente > 0 
		begin
			set @caption = 'Ripristina Ente'
		end
	else
		begin	
			set @caption = 'Ripristina Azienda'
		end

	if @Deleted = 0 
		begin
			set @Errore = 'Operazione non consentita, azienda gia'' attiva'
		end

	if @Errore = '' 
	begin
		-- Check documento 'RIPRISTINA_AZI' già presente nello stato funziona inLavorazione 
		select @id = id 
			from ctl_doc with(nolock)
			where tipodoc = @TipoDoc and StatoFunzionale = 'InLavorazione' and Azienda = @idDoc and deleted = 0
		
		--se il documento di ripristino non esiste lo creo    
		IF @Id = 0 
			BEGIN
				--inserisco nella ctl_doc		
				insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_User,  StatoFunzionale,IdPfuInCharge, jumpcheck, caption)
					values ( @IdUser, @TipoDoc, 'Saved' , 'Riattivazione' , '', @IdAzi , NULL ,'InLavorazione', NULL , '', @caption)
			
				set @Id = SCOPE_IDENTITY()
			END
	END

	if @Errore = ''
		begin
			-- rirorna l'id del nuovo dlocumento appena creato
			select @Id as id
		end
	else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
END

GO
