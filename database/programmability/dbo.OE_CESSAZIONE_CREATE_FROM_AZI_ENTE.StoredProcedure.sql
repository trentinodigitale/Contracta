USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OE_CESSAZIONE_CREATE_FROM_AZI_ENTE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OE_CESSAZIONE_CREATE_FROM_AZI_ENTE] 
	( @idDoc int , @IdUser int ,@provenienza varchar(200) = ''  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	
	declare @Deleted as INT

	set @Errore = ''

	select @Deleted=aziDeleted from aziende where idazi=@idDoc

	if @Deleted = 1 
	begin
	
		set @Errore = 'Azienda gia'' cessata'
		
	end

	if @Errore = '' 
	begin
		
		set @id = null
		select @id = id 
			from Document_Aziende with(nolock)
				 where IdAzi = @idDoc and TipoOperAnag = 'OE_CESSAZIONE'
			
			
		if ( @id is null or @provenienza = 'CESSAZIONE_UTENTI' or @Deleted=0)
		begin
		
			INSERT into Document_Aziende( aziragionesociale , idAzi  , IdPfu , TipoOperAnag )
					select 	aziragionesociale , IdAzi, @IdUser , 'OE_CESSAZIONE'
						FROM Aziende where idazi=@idDoc


			set @Id = SCOPE_IDENTITY() 

		end



	end
		
	if @Errore = '' 
	begin
		--QUANDO VENGO DA CESSAZIONE_UTENTI serve schedulare INVIO
		if ( @provenienza = 'CESSAZIONE_UTENTI' )
		BEGIN
			insert into CTL_Schedule_Process ( IdDoc,IdUser,DPR_DOC_ID,DPR_ID )
				select @id,@IdUser,'AZI_CESSAZIONE','SEND'
		END
	end

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
