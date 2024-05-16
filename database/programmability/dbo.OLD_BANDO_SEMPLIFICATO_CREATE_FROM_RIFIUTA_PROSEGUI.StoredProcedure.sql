USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_SEMPLIFICATO_CREATE_FROM_RIFIUTA_PROSEGUI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_BANDO_SEMPLIFICATO_CREATE_FROM_RIFIUTA_PROSEGUI] ( @idDoc int  , @idUser int )
AS
BEGIN

	declare @id int

	set @Id = 0

	SET NOCOUNT ON;

	-- cerca una versione precedente del documento
	select @Id = value from CTL_DOC_VALUE
	where idheader = @idDoc and DSE_ID = 'ID_DOC_DI_COPIA' and DZT_NAME='ID_BANDO_COPIA' 

	-- se non viene trovato allora si crea il nuovo documento
	if isnull(@Id , 0 ) = 0 
	begin

		-- rirorna l'errore
		select 'Errore' as id , 'Errore documento non trovato.' as Errore		

	end
	else
	begin

		-- rirorna l'id del BANDO
		select @id as id

	end

END








GO
