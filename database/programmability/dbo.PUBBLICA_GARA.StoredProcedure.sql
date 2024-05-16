USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PUBBLICA_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PUBBLICA_GARA] ( @idDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @tipodoc varchar(100)
	declare @dataRiferimentoInizio datetime
	declare @dataInvio datetime
	declare @newStatoFunzionale varchar(100)

	select  @tipodoc = a.tipodoc 
		   ,@dataRiferimentoInizio = isnull(b.DataRiferimentoInizio,getdate()) 
		   ,@dataInvio = a.DataInvio
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

		-- nel caso in cui la data non era stata inserita dall'utente ma calcolata all'invio in automatico
		-- allora la aggiorniamo con quella più recente che rappresenta l'effettiva pubblicazione
		if exists( select * from ctl_doc_value with(nolock) where @idDoc =  [IdHeader] and  'BANDO_GARA_TERMINI' =  [DSE_ID] and 'DataRiferimentoInizio' = [DZT_Name] and 'Auto' = [Value] )
		begin
			update Document_Bando set DataRiferimentoInizio = GETDATE()	where idheader = @idDoc		
			update ctl_doc_value set value = 'Reset'  where @idDoc =  [IdHeader] and  'BANDO_GARA_TERMINI' =  [DSE_ID] and 'DataRiferimentoInizio' = [DZT_Name] and 'Auto' = [Value]	
		end

	END
	
	IF @dataInvio is null
	BEGIN

		UPDATE CTL_DOC 
			set StatoDoc = 'Sended' 
				,DataInvio = GetDate() 
				, statoFunzionale = @newStatoFunzionale
			where id = @idDoc

	END
	ELSE
	BEGIN

		UPDATE CTL_DOC 
			set StatoDoc = 'Sended'
				, statoFunzionale = @newStatoFunzionale
			where id = @idDoc

	END

END



GO
