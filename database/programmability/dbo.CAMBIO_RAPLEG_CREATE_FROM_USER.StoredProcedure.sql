USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CAMBIO_RAPLEG_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[CAMBIO_RAPLEG_CREATE_FROM_USER] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT	
	declare @Errore as nvarchar(2000)



	set @Errore = ''


		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC 
						where  deleted = 0 
								and TipoDoc in ( 'CAMBIO_RAPLEG' ) 
								and statofunzionale = 'InLavorazione'
								and idpfu=@IdUser

		if @id is  null
		begin
			 -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo, Azienda
					 )
				select top 1
					@IdUser as idpfu , 'CAMBIO_RAPLEG' as TipoDoc ,  
					'Cambio Rappresentante Legale' as Titolo, 
					pfuidazi as Azienda
				from profiliUtente 
				where idpfu = @IdUser
				

				set @id = @@identity	
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
