USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TED_ESITO_VERIFICA_PUBBLICAZIONE_F03]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_TED_ESITO_VERIFICA_PUBBLICAZIONE_F03] ( @idRicPub int, @idUser int, @success int, @status varchar(100), @status_msg nvarchar(max), @no_doc_ojs varchar(100), @publication_date varchar(100), @ted_link nvarchar(1000), @simulato int = 0 )
AS
BEGIN
	
	SET NOCOUNT ON

	update Document_TED_GARA
				set TED_VER_PUB_STATUS = @status,
					TED_VER_PUB_STATUS_MSG = @status_msg,
					TED_VER_PUB_NO_DOC_OJS = @no_doc_ojs,
					TED_VER_PUB_PUBBLICATION_DATE = @publication_date,
					TED_VER_PUB_TED_LINK = @ted_link
			where idHeader = @idRicPub

	-- POSSIBILI STATI : 
	--		SERVICE_ERROR: errore sui parametri immessi, errore di business validation o errore di indisponibilità del servizio Simog
	--		TED_ERROR: errore in fase di invio del formulario al TED (es. accesso non consentito)
	--		RECEPTION_ERROR: il formulario inviato presenta uno o più errori
	--		IN_PROGRESS: è in corso la verifica del formulario
	--		NOT_PUBLISHED: la richiesta di pubblicazione del formulario è stata rifiutata
	--		PUBLISHED: il formulario è pubblicato su TED

	IF @status = 'PUBLISHED' or @simulato = 1
	BEGIN
		
		update CTL_DOC
				set DataDocumento = GETDATE(),
					DataInvio = GETDATE(),
					StatoFunzionale = 'PubTed'	--pubblicata ted
			where Id = @idRicPub

		--INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
		--							values ( @idRicPub, @idUser, 'TED', 'ALERT_VERIFICA_PUB' )

	END
	ELSE IF @status IN (  'SERVICE_ERROR', 'TED_ERROR', 'RECEPTION_ERROR', 'NOT_PUBLISHED' )
	BEGIN

		update CTL_DOC
				set DataDocumento = GETDATE(),
					DataInvio = GETDATE(),
					StatoFunzionale = 'Rifiutato'
			where Id = @idRicPub

		--INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
		--					values ( @idRicPub, @idUser, 'TED', 'ALERT_VERIFICA_PUB' )
	
	END
	ELSE -- IN CASO DI IN_PROGRESS
	BEGIN
		
		--aggiorniamo solo la data di ultima verifica di questa richiesta di pubblicazione. il servizio di verifica ordina sulla colonna DataDocumento per elaborare le richieste in modo circolare
		update CTL_DOC
				set DataDocumento = GETDATE()
			where Id = @idRicPub

	END

END

GO
