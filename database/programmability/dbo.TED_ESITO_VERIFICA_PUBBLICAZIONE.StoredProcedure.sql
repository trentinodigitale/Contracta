USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TED_ESITO_VERIFICA_PUBBLICAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TED_ESITO_VERIFICA_PUBBLICAZIONE] ( @idDocGara int, @idUser int, @success int, @status varchar(100), @status_msg nvarchar(max), @no_doc_ojs varchar(100), @publication_date varchar(100), @ted_link nvarchar(1000), @simulato int = 0 )
AS
BEGIN
	
	SET NOCOUNT ON

	declare @idRicPub int = 0
	declare @tipoDocRichiedente varchar(100)
	declare @tipoDoc varchar(100)
	declare @linkedDoc int
	declare @linked_id_doc int
	declare @tipoDocCollegato varchar(100) = ''
	declare @idDocCollegato INT
	declare @conferma_post_verificated int = 0
	declare @idAttesaElab INT
	declare @idPfuAttesa INT

	select @idRicPub = max(id) from CTL_DOC with(nolock) where LinkedDoc = @idDocGara and deleted = 0 and TipoDoc in (  'PUBBLICA_GARA_TED', 'RETTIFICA_GARA_TED'  ) and StatoFunzionale = 'InAttesaPubTed'

	select @tipoDoc = a.tipoDoc ,
			@linkedDoc = LinkedDoc,
			@linked_id_doc = IdDoc
		from ctl_doc a with(nolock) 
		where a.id = @idRicPub

	update Document_TED_GARA
				set TED_VER_PUB_STATUS = @status,
					TED_VER_PUB_STATUS_MSG = @status_msg,
					TED_VER_PUB_NO_DOC_OJS = @no_doc_ojs,
					TED_VER_PUB_PUBBLICATION_DATE = @publication_date,
					TED_VER_PUB_TED_LINK = @ted_link
			where idHeader = @idRicPub

	-- POSSIBILI STATI : 
	--	SERVICE_ERROR: errore sui parametri immessi, errore di business validation o errore di indisponibilità del servizio Simog
	--	TED_ERROR: errore in fase di invio del formulario al TED (es. accesso non consentito)
	--	RECEPTION_ERROR: il formulario inviato presenta uno o più errori
	--	IN_PROGRESS: è in corso la verifica del formulario
	--	NOT_PUBLISHED: la richiesta di pubblicazione del formulario è stata rifiutata
	--	PUBLISHED: il formulario è pubblicato su TED

	IF @status = 'PUBLISHED' or @simulato = 1
	BEGIN
		
		update CTL_DOC
				set DataDocumento = GETDATE(),
					DataInvio = GETDATE(),
					StatoFunzionale = 'PubTed'	--pubblicata ted
			where Id = @idRicPub

		INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
									values ( @idRicPub, @idUser, 'TED', 'ALERT_VERIFICA_PUB' )

		--sia per la pubblicazione della gara sia per la pubblicazione di un avviso di rettifico, andiamo ad aggiungere una riga nella griglia delle pubblicazione, con tipo 'GUUE', il numero ed il link del TED
		IF @tipodoc IN ( 'PUBBLICA_GARA_TED', 'RETTIFICA_GARA_TED' )
		BEGIN

			-- la gara non passa più nello stato di in attesa pubblicazione quindi non va finalizzata
			IF @conferma_post_verificated = 1 and  @tipodoc = 'PUBBLICA_GARA_TED'
			BEGIN

				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
									  VALUES ( @idDocGara, @idUser, 'BANDO_GARA', 'AFTER_APPROVE' )
			END

			DECLARE @rowGUUE INT = -1

			---- Cancelliamo una precedente riga di pubblicazione GUUE se presente
			--select @rowGUUE = a.Row 
			--	FROM CTL_DOC_VALUE a WITH(NOLOCK)
			--	WHERE a.idheader = @idDocGara and a.dse_id = 'InfoTec_DatePub' and a.DZT_Name = 'Pubblicazioni' and a.[value] = '01'

			---- Mettiamo la nuova riga nella posizione dove prima c'era il GUUE oppure ci mettiamo alla fine di altre eventuali righe

			--IF @rowGUUE >= 0
			--BEGIN
			--	DELETE FROM ctl_doc_value WHERE idheader = @idDocGara and dse_id = 'InfoTec_DatePub' and row = @rowGUUE
			--END
			--ELSE
			--BEGIN

				SELECT @rowGUUE = max(a.Row)
					FROM CTL_DOC_VALUE a WITH(NOLOCK)
					WHERE a.idheader = @idDocGara and a.dse_id = 'InfoTec_DatePub'

				set @rowGUUE = isnull(@rowGUUE,-1) + 1

			--END

			INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
								values ( @idDocGara, 'InfoTec_DatePub', @rowGUUE, 'Pubblicazioni', '01' )

			INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
								values ( @idDocGara, 'InfoTec_DatePub', @rowGUUE, 'FNZ_DEL', '' )

			INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
								values ( @idDocGara, 'InfoTec_DatePub', @rowGUUE, 'LblAttidiGara', '' )

			INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
								values ( @idDocGara, 'InfoTec_DatePub', @rowGUUE, 'NumeroPub', @no_doc_ojs )

			INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
								values ( @idDocGara, 'InfoTec_DatePub', @rowGUUE, 'DataPubblicazioneBando', left( @publication_date, 10 ) )

			INSERT INTO ctl_doc_value ( IdHeader, DSE_ID, row, DZT_Name, value )
								values ( @idDocGara, 'InfoTec_DatePub', @rowGUUE, 'TED_VER_PUB_TED_LINK', @ted_link )

		END
		
		IF @tipodoc = 'RETTIFICA_GARA_TED' 
		BEGIN

			-------------------------------------------
			--ESITO POSITIVO RICHIESTA DI RETTIFICA ---
			-------------------------------------------

			select @tipoDocCollegato = b.tipodoc,
					@idDocCollegato = b.Id
				from ctl_doc a with(nolock)
						inner join ctl_doc b with(nolock) on b.id = a.IdDoc
				where a.id = @idRicPub

			IF @conferma_post_verificated = 1
			BEGIN

				declare @generaModTed INT = 0

				IF @tipoDocCollegato = 'BANDO_MODIFICA'
				BEGIN
					
					set @generaModTed = 1

					INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
									values ( @idDocCollegato, @idUser, 'BANDO_MODIFICA', 'CONFERMA_COMPLETE' )

				END
				ELSE IF @tipoDocCollegato = 'PROROGA_GARA'
				BEGIN

					set @generaModTed = 1

					INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
									values ( @idDocCollegato, @idUser, 'PROROGA_GARA', 'SEND_COMPLETE' )

				END
				ELSE IF @tipoDocCollegato = 'RETTIFICA_GARA'
				BEGIN

					set @generaModTed = 1

					INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
									values ( @idDocCollegato, @idUser, 'RETTIFICA_GARA', 'SEND_COMPLETE' )

				END
				ELSE
				BEGIN
					
					--documento DELTA_TED
					--update ctl_doc
					--		set StatoFunzionale = 'Inviato'
					--	where id = @idDocCollegato

					-- una volta ottenuta una risposta positiva dal ted per l'esito del formulario, facciamo partire anchela modifica dei dati ted lato anac
					INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
									values ( @idDocCollegato, @idUser, 'DELTA_TED', 'SEND_WS' )
				

				END

				if @generaModTed = 1
				begin

					-- creiamo un documento di rettifica ted e ne scheduliamo l'invio.
					-- questo per allineare l'anac con le modifiche/rettifiche inviate al ted

					declare @newid int = 0
					EXEC DELTA_TED_CREATE_FROM_BANDO @idDocGara , @IdUser , 1, 1, @newid output

					if isnull(@newid,0) > 0
					begin

						update ctl_doc
								set DataInvio = getDate()
							where id = @newid

						INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
									values ( @newid, @idUser, 'DELTA_TED', 'SEND_WS' )
								
					end

				end

			END -- IF @conferma_post_verificated = 1

		END --END/ELSE DELL'IF <<IF @tipodoc = 'PUBBLICA_GARA_TED'>>

	END
	ELSE IF @status IN (  'SERVICE_ERROR', 'TED_ERROR', 'RECEPTION_ERROR', 'NOT_PUBLISHED' )
	BEGIN

		update CTL_DOC
				set DataDocumento = GETDATE(),
					DataInvio = GETDATE(),
					StatoFunzionale = 'Rifiutato'
			where Id = @idRicPub

		IF @conferma_post_verificated = 1
		BEGIN

			declare @prevStatoFunz varchar(200) = 'InLavorazione' --statofunzionale di default. vale sia per la richiesta di pubblicazione della gara che per la rettifica

			IF @tipodoc = 'PUBBLICA_GARA_TED'
			BEGIN

				-------------------------------------------------------------
				----IN CASO DI ERRORE FACCIO REGREDIRE LO STATO DELLA GARA --
				-------------------------------------------------------------

				declare @lastStep int = 0

				select @lastStep = max(aps_id_row) from CTL_ApprovalSteps a with(nolock) where APS_ID_DOC =  @idDocGara and APS_State = 'Approved'

				-- Se l'utente che ha fatto l'ultima approvazione è lo stesso che ha compilato il documento allora desumiamo che non c'è un passo di approvazione
				-- e possiamo regredire la gara nello stato di InLavorazione, altrimenti regrediamo InApprovazione
				IF EXISTS ( 
					select a.APS_ID_ROW 
						from CTL_ApprovalSteps a with(nolock)
								inner join CTL_ApprovalSteps b with(nolock) on b.APS_ID_DOC = a.APS_ID_DOC and b.APS_State = 'Compiled' and b.APS_IdPfu = a.APS_IdPfu
						where a.APS_ID_ROW = @lastStep )
				BEGIN

					set @prevStatoFunz = 'InLavorazione'

				END
				ELSE
				BEGIN
					set @prevStatoFunz = 'InApprove'
				END

			END
		
			IF @tipodoc = 'PUBBLICA_GARA_TED'
			BEGIN

				update ctl_doc
						set StatoFunzionale = @prevStatoFunz
					where id = @idDocGara

			END
			ELSE
			BEGIN

				-- per la rettifica
				update ctl_doc
						set StatoFunzionale = @prevStatoFunz
					where id = @linked_id_doc
			
			END

		END --IF @conferma_post_verificated = 1

		INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID)
							values ( @idRicPub, @idUser, 'TED', 'ALERT_VERIFICA_PUB' )
								--  values ( @idDocGara, @idUser, 'TED', 'ALERT_VERIFICA_PUB' )

		select @tipoDocCollegato = b.tipodoc,
				@idDocCollegato = b.Id
			from ctl_doc a with(nolock)
					inner join ctl_doc b with(nolock) on b.id = a.IdDoc
			where a.id = @idRicPub

	
	END
	ELSE -- IN CASO DI IN_PROGRESS
	BEGIN
		
		--aggiorniamo solo la data di ultima verifica di questa richiesta di pubblicazione. il servizio di verifica ordina sulla colonna DataDocumento per elaborare le richieste in modo circolare
		update CTL_DOC
				set DataDocumento = GETDATE()
			where Id = @idRicPub

	END

	--se abbiamo avuto uno stato "finale" e proveniamo da una rettifica, andiamo a verificare se ci sono altre rettifiche in coda 
	IF @status <> 'IN_PROGRESS' and @tipoDoc = 'RETTIFICA_GARA_TED'
	BEGIN

		set @idAttesaElab = 0
		select top 1 @idAttesaElab = id, @idPfuAttesa = IdPfu from ctl_doc with(nolock) where linkedDoc = @idDocGara and Deleted = 0 and StatoFunzionale = 'AttesaPrecedentiElaborazioni' order by DataInvio asc

		IF ISNULL(@idAttesaElab,0) > 0
		BEGIN

			update ctl_doc 
					set StatoFunzionale = case when @tipoDocCollegato <> 'DELTA_TED' then 'ElabDatiRettificaTed' else 'ElabDatiRettificaDeltaTed' end -- elaborazione dati di rettifica
				where id = @idAttesaElab

			INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
									values ( @idAttesaElab, @idPfuAttesa, 'RETTIFICA_TED', 'ELABORA' )
		END

	END


END


GO
