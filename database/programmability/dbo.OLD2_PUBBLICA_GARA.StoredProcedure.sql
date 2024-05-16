USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PUBBLICA_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_PUBBLICA_GARA] ( @idDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @tipodoc varchar(100)
	declare @dataRiferimentoInizio datetime
	declare @newStatoFunzionale varchar(100)

	select  @tipodoc = a.tipodoc 
		   ,@dataRiferimentoInizio = isnull(b.DataRiferimentoInizio,getdate()) 
	from ctl_doc a with(nolock)
			left join Document_Bando  b with(nolock) ON b.idheader = a.id
	where a.id = @idDoc

	-----------------------------------------------------------------
	-- se data per presentare le offerte è maggiore di oggi passo il bando_semplificato/bando_gara
	-- nello stato di 'pubblicato' e schedulo un processo per far passare il documento in
	-- 'PresOfferte' quando tale data viene raggiunta.
	--	se invece la data di pres. offerta è minore o uguale di ora, il documento passa direttamente in 'PresOfferte'.
	-------------------------------

	IF @dataRiferimentoInizio > getdate()
	BEGIN
		
		SET @newStatoFunzionale = 'Pubblicato'
		
		-- Se esisteva un processo già schedulato vado ad aggiornarne la data, altrimenti lo creo
		IF EXISTS ( select id from CTL_Schedule_Process with(nolock) where DPR_DOC_ID = 'BANDO_SEMPLIFICATO' and DPR_ID = 'PASSA_A_PRES_OFFERTE' and idDoc = @idDoc and state = 0 )
		BEGIN

			UPDATE CTL_Schedule_Process
				SET DataRequestExec = @dataRiferimentoInizio
			where DPR_DOC_ID = 'BANDO_SEMPLIFICATO' and DPR_ID = 'PASSA_A_PRES_OFFERTE' and idDoc = @idDoc and state = 0
				
		END
		ELSE
		BEGIN

				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID, DataRequestExec,State )
								values ( @idDoc, @idUser, 'BANDO_SEMPLIFICATO', 'PASSA_A_PRES_OFFERTE', @dataRiferimentoInizio, 0)

		END

	END
	ELSE
	BEGIN

		SET @newStatoFunzionale = 'PresOfferte'

	END
	
	UPDATE CTL_DOC 
		set StatoDoc = 'Sended' 
			,DataInvio = GetDate() 
			, statoFunzionale = @newStatoFunzionale
		where id = @idDoc

END



GO
