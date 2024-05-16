USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RELEASE_NOTES_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[RELEASE_NOTES_CREATE_FROM_NEW] 
	( @idDoc int , @IdUser int )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Idazi as INT

	select @Idazi=pfuidazi from ProfiliUtente where IdPfu=@IdUser
	

	
	

	   -- CREO IL DOCUMENTO
		INSERT into CTL_DOC (IdPfu,  TipoDoc  , idpfuincharge ,Azienda )
			VALUES (@IdUser  , 'RELEASE_NOTES' , @IdUser ,@Idazi)


		set @id = SCOPE_IDENTITY()

		INSERT INTO CTL_DOC_Value (IdHeader,DSE_ID) 
		select @id,'DETTAGLI'

		
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
