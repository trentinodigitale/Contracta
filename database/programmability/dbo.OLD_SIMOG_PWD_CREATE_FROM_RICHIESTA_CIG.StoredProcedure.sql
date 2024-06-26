USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SIMOG_PWD_CREATE_FROM_RICHIESTA_CIG]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_SIMOG_PWD_CREATE_FROM_RICHIESTA_CIG] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int

	declare @Rup INT
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @Body nvarchar( max )

	declare @CF_AMMINISTRAZIONE varchar(20)
	declare @CF_UTENTE varchar(20)
	declare @NumLotti int

	set @Errore=''	
	set @newId = 0
	set @Rup = 0

	IF EXISTS ( SELECT id from ctl_doc with(nolock) where id = @idDoc and tipodoc = 'RICHIESTA_SMART_CIG' )
		select @Rup = idpfuRup from Document_SIMOG_SMART_CIG with(nolock) where idHeader = @idDoc
	ELSE
		select @Rup = idpfuRup from Document_SIMOG_GARA with(nolock) where idHeader = @idDoc

	IF isnull(@Rup,0) = 0
	BEGIN

		SET @Errore = 'Rup non trovato'

	END
	ELSE
	BEGIN

		EXEC SIMOG_PWD_CREATE_FROM_IDPFU_RUP  @Rup , @newid output, @IdUser

	END

	if  ISNULL(@newId,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @newId as id
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END











GO
