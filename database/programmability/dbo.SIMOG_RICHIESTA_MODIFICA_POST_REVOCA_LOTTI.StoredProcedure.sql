USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SIMOG_RICHIESTA_MODIFICA_POST_REVOCA_LOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SIMOG_RICHIESTA_MODIFICA_POST_REVOCA_LOTTI] ( @idGara INT, @idUser INT )
AS
BEGIN

	SET NOCOUNT ON

	--declare @RichiestaCigSimog varchar(10) = ''

	--select @RichiestaCigSimog = RichiestaCigSimog  from Document_Bando with(nolock) where idHeader = @idGara

	--IF @RichiestaCigSimog = 'si'
	--BEGIN

	--	--se esiste una precedente richiesta cig inviata con successo
	--	IF exists (	select id from CTL_DOC with (nolock) where LinkedDoc = @idGara and TipoDoc='RICHIESTA_CIG' and StatoFunzionale='Inviato' and Deleted=0 )
	--	BEGIN

	--		--se c'era una precedente richiesta di modifica in lavorazione la cancelliamo logicamente, per far vincere questa nuova
	--		UPDATE CTL_DOC
	--				set deleted = 1
	--			where LinkedDoc = @idGara and deleted = 0 and TipoDoc = 'RICHIESTA_CIG' and StatoFunzionale = 'InLavorazione' and JumpCheck = 'MODIFICA'

	--		CREATE TABLE #TempCheck
	--		(
	--			[id] varchar(20) collate DATABASE_DEFAULT NULL,
	--			[errore] nvarchar(1000) collate DATABASE_DEFAULT NULL
	--		) 

	--		insert into #TempCheck  
	--			exec RICHIESTA_CIG_CREATE_FROM_BANDO_MODIFICA_CIG @idGara, @idUser

	--		declare @idDocSimog varchar(20) = ''

	--		select @idDocSimog = id from #TempCheck 

	--		if isnumeric(@idDocSimog) = 1
	--		begin

	--			UPDATE Document_SIMOG_LOTTI
	--					set note_canc = 'Revoca lotto',
	--						MOTIVO_CANCELLAZIONE_LOTTO = '4'
	--				where idHeader = cast( @idDocSimog as int) and AzioneProposta = 'Delete'
				
	--			-- potrebbe bloccarsi la schedulazione ??
	--			INSERT INTO CTL_Schedule_Process ( iddoc, iduser, DPR_DOC_ID, DPR_ID)
	--									  values ( @idGara, @idUser, 'RICHIESTA_CIG', 'SEND' )


	--		end


	--	END

	--END

END
GO
