USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CRITERIO_CALCOLO_ANOMALIA_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_CRITERIO_CALCOLO_ANOMALIA_CREATE_FROM_PDA_MICROLOTTI] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT

	set @Errore = ''

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'CRITERIO_CALCOLO_ANOMALIA' ) and JumpCheck='PDA_MICROLOTTI'

		if @id is null
		begin
			   -- altrimenti lo creo
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,  
					LinkedDoc,
					JumpCheck
					 )
					select 
							@IdUser as idpfu , 'CRITERIO_CALCOLO_ANOMALIA' as TipoDoc ,  
							'Criterio Calcolo Anomalia' as Titolo,  
							 d.id as LinkedDoc,d.TipoDoc
									
						from CTL_DOC d
						where d.id = @idDoc

				set @id = SCOPE_IDENTITY()
				

		end
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
