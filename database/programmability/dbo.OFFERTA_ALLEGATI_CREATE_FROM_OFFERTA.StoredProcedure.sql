USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_ALLEGATI_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OFFERTA_ALLEGATI_CREATE_FROM_OFFERTA] 
	( @idOff int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT	
	declare @Errore as nvarchar(2000)

	set @Id=0
	set @Errore = ''

	select @Id=id 
		from CTL_DOC 
			where LinkedDoc = @idOff and Deleted=0 and TipoDoc='OFFERTA_ALLEGATI'

	
	-- controllo lo stato dell'istanza
	if @Id = 0
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita non esiste un documento "Offerta Allegati" per l''offerta' 
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
