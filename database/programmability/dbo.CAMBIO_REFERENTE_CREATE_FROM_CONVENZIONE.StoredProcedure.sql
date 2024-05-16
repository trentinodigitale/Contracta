USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CAMBIO_REFERENTE_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CAMBIO_REFERENTE_CREATE_FROM_CONVENZIONE] ( @idDoc int , @IdUser int , @forzaCopia int = 0, @idOut int = 0 out  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @id as INT
	declare @Errore as nvarchar(2000)

	set @Errore = ''

	-- cerco una versione precedente del documento
	set @id = null
	IF @forzaCopia=0
	BEGIN
		select @id = id from CTL_DOC WITH(NOLOCK) where TipoDoc in ( 'CAMBIO_REFERENTE' ) and LinkedDoc = @idDoc and deleted = 0 and StatoFunzionale = 'InLavorazione'
	END

	IF @id is null
	BEGIN

		INSERT into CTL_DOC ( IdPfu,  TipoDoc, 	Titolo,  LinkedDoc,VersioneLinkedDoc,Caption,idPfuInCharge )
					--values ( @IdUser, 'CAMBIO_REFERENTE','Cambio Gestore Convenzione',@idDoc,'CONVENZIONE','Cambio Gestore Convenzione',@IdUser)
					select 
						@IdUser, 'CAMBIO_REFERENTE','Cambio Gestore Convenzione',@idDoc,'CONVENZIONE','Cambio Gestore Convenzione',idpfu
							from CTL_DOC where Id = @idDoc


		set @id = SCOPE_IDENTITY()

		INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name, value,Row)
					select @id, 'DOCUMENT', 'Utente', a.IdPfu,0
						from ctl_doc a with(nolock)											
						where a.id = @idDoc

		INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name, value,Row)
					select @id, 'DOCUMENT', 'Filtro_Nuovo_Utente','GestoreNegoziElettro',0
						from ctl_doc a with(nolock)											
						where a.id = @idDoc

		-- Aggiunge il RUP SUL DOCUMENTO
		INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name, value,Row)
					select @id, 'INFO_RUP', 'UserRUP', a.UserRUP,0
						from Document_Convenzione  a with(nolock)											
						where a.ID = @idDoc

		-- Aggiunge il RUP ORIGINARIO SUL DOCUMENTO
		INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name, value,Row)
					select @id, 'INFO_RUP', 'UserRUP_ORIGINARIO', a.UserRUP,0
						from Document_Convenzione  a with(nolock)											
						where a.ID = @idDoc


	END

	IF @forzaCopia = 0
	BEGIN
		if @Errore = ''
		begin
			-- rirorna l'id della Commissione
			select @Id as id
	
		end
		else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
	END
	ELSE
		SET @idOut = @id

END




GO
