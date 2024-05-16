USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONV_SOSTITUZIONE_REF_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CONV_SOSTITUZIONE_REF_CREATE_FROM_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @id as INT
	declare @Errore as nvarchar(2000)

	set @Errore = ''

	-- cerco una versione precedente del documento
	set @id = null
	select @id = id from CTL_DOC WITH(NOLOCK) where TipoDoc in ( 'CONV_SOSTITUZIONE_REF' ) and LinkedDoc = @idDoc and deleted = 0 and StatoFunzionale = 'InLavorazione'

	IF @id is null
	BEGIN

			INSERT into CTL_DOC ( IdPfu, idPfuInCharge, TipoDoc, 	Titolo,  LinkedDoc )
						values ( @IdUser , @IdUser, 'CONV_SOSTITUZIONE_REF','Cambio Referente Fornitore',@idDoc)

			set @id = SCOPE_IDENTITY()

			INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name, value)
								select @id, 'TESTATA', 'Mandataria', b.Mandataria
									from ctl_doc a with(nolock)
											inner join Document_Convenzione b with(nolock) ON a.id = b.id 
									where a.id = @idDoc

			INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name, value)
								select @id, 'TESTATA', 'Utente', b.ReferenteFornitore
									from ctl_doc a with(nolock)
											inner join Document_Convenzione b with(nolock) ON a.id = b.id 
									where a.id = @idDoc

	END

	if @Errore = ''
	begin

		select @Id as id

	end
	else
	begin

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	end

END



GO
