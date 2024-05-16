USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CESSAZIONE_UTENTI_CREATE_FROM_GESTIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CESSAZIONE_UTENTI_CREATE_FROM_GESTIONE] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	SET NOCOUNT ON;

	declare @id as int
	declare @Errore nvarchar(2000)
	declare @JumpCheck nvarchar(2000)

	set @errore=''
	set @id=0
	
	if @idDoc = -1
	BEGIN
		set @JumpCheck='OE'
	END
	if @idDoc = -2
	BEGIN
		set @JumpCheck='ENTI'
	END
	--- Se esiste già non chiuso Apro quello
	select  @Id=id 
		from CTL_DOC with(nolock) 
			where TipoDoc in ( 'CESSAZIONE_UTENTI')
				and StatoFunzionale <> 'Chiuso' and Deleted = 0 and JumpCheck =@JumpCheck

	IF @Id = 0
	BEGIN

		Insert into CTL_DOC ( IdPfu , TipoDoc , Caption , JumpCheck)
			select @idUser , 'CESSAZIONE_UTENTI' ,'Gestione Cessazione Utenti degli ' + @JumpCheck , @JumpCheck
		
		set @Id = SCOPE_IDENTITY()
	END


	if @Errore = ''
	begin

		-- rirorna l'id del doc appena creato o quello del doc in lavorazione
		select @Id as id
	
	end
	else
	begin

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	end

END




GO
