USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_TED_AVANZAMENTO_ELABORAZIONE_RETTIFICA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_TED_AVANZAMENTO_ELABORAZIONE_RETTIFICA] ( @idDoc int , @IdUser int )
AS
BEGIN


	SET NOCOUNT ON

	DECLARE @statoFunzionaleAttuale varchar(100) = ''
	DECLARE @idDocGara INT

	select @statoFunzionaleAttuale = statoFunzionale, @idDocGara = LinkedDoc from ctl_doc with(nolock) where id = @idDoc

	IF @statoFunzionaleAttuale = 'ElabDatiRettificaTed' --se nello stato  "Elaborazione dati di rettifica" verifico se è necessario il documento di variazione per il SIMOG. 
	BEGIN

		--------------------------------------------
		--	SE NECESSARIO CREO IL DOCUMENTO DI VARIAZIONE PER SIMOG, CI AGGIUNGO UN ATTRIBUTO NELLA DOC_VALUE "LINKEDDOCRETTIFICATED" CON L'ID DELLA RETTIFICA E PASSO LA RETTIFICA NELLO STATO DI "ELABORAZIONE DATI DI RETTIFICA ATTESA SIMOG" 
		--------------------------------------------

		declare @Esito as varchar(20) = ''
		declare @bAttesaSimog INT = 0

		CREATE TABLE #TempCheck2
		(
			[Esito] [varchar](20) collate DATABASE_DEFAULT NULL
		)  
				
		insert into #TempCheck2 
			select top 0 '' as Esito
			
		insert into #TempCheck2  
			exec CK_RICHIESTA_CIG_DATI_GARA @idDocGara , @idUser ----VERIFICA SE SONO CAMBIATI I DATI DELLA GARA RISPETTO ALL'ULTIMA RICHIESTA_CIG

		select @Esito=Esito from #TempCheck2
		drop table #TempCheck2 

		if @Esito='KO'
		BEGIN			

			--se c'era una precedente richiesta di modifica in lavorazione la cancelliamo logicamente, per far vincere questa nuova
			UPDATE CTL_DOC
					set deleted = 1
				where LinkedDoc = @idDocGara and deleted = 0 and TipoDoc = 'RICHIESTA_CIG' and StatoFunzionale = 'InLavorazione' and JumpCheck = 'MODIFICA'

			CREATE TABLE #TempCheck
			(
				[id] varchar(20) collate DATABASE_DEFAULT NULL,
				[errore] nvarchar(1000) collate DATABASE_DEFAULT NULL
			) 

			insert into #TempCheck  
				exec RICHIESTA_CIG_CREATE_FROM_BANDO_MODIFICA_CIG @idDocGara, @idUser

			declare @idDocSimog varchar(20) = ''

			select @idDocSimog = id from #TempCheck 

			IF isnumeric(@idDocSimog) = 1
			BEGIN

				update ctl_doc
						set VersioneLinkedDoc = 'SCHEDULATO'
					where id = @idDocSimog
			
				INSERT INTO CTL_Schedule_Process ( iddoc, iduser, DPR_DOC_ID, DPR_ID)
											values ( @idDocSimog, @idUser, 'RICHIESTA_CIG', 'SEND' )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, DZT_Name, value ) values ( @idDocSimog, 'TED', 'LinkedDocRettificaTED', @idDoc )

				UPDATE ctl_doc 
						SET statofunzionale = 'ElabDatiRettificaTedAttesaSimog' 
					WHERE id = @idDoc

				set @bAttesaSimog = 1

			END

		END --if @Esito='KO'

		--	Se non è necessario avanziamo lo stato in  "Elaborazione dati di rettifica – DELTA TED" 
		IF @bAttesaSimog = 0
		BEGIN

			UPDATE ctl_doc 
						SET statofunzionale = 'ElabDatiRettificaDeltaTed' 
					WHERE id = @idDoc

			INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
						values ( @idDoc, @idUser, 'RETTIFICA_TED', 'ELABORA' )

		END

	END
	ELSE IF @statoFunzionaleAttuale = 'ElabDatiRettificaDeltaTed' --	Se nello stato   "Elaborazione dati di rettifica – DELTA TED" verifico se è necessario il documento di variazione per il TED . 
	BEGIN

		declare @tipoDocCollegato varchar(100) = ''
		declare @idDocCollegato INT

		select @tipoDocCollegato = b.tipodoc, @idDocCollegato = b.Id
			from ctl_doc a with(nolock)
					inner join ctl_doc b with(nolock) on b.id = a.IdDoc
			where a.id = @idDoc

		declare @newid int = 0

		IF @tipoDocCollegato <> 'DELTA_TED'
			EXEC DELTA_TED_CREATE_FROM_BANDO @idDocGara , @IdUser , 1, 1, @newid output

		IF isnull(@newid,0) > 0
		BEGIN

			-- creato un documento di rettifica ted ne scheduliamo l'invio.

			update ctl_doc
					set DataInvio = getDate()
				where id = @newid

			INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, DZT_Name, value ) values ( @newid, 'TED', 'LinkedDocRettificaTED', @idDoc )

			UPDATE ctl_doc 
					SET statofunzionale = 'ElabDatiRettificaAttesaTed' 
				WHERE id = @idDoc

			INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
						values ( @newid, @idUser, 'DELTA_TED', 'SEND_WS' )
								
		END
		ELSE
		BEGIN

			--se il richiedente della rettifica è il formulario completo delta ted dobbiamo farlo partire, sarà poi il processo SEND_WS a far avanzare lo stato di rettifica
			IF @tipoDocCollegato = 'DELTA_TED'
			BEGIN

				INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
								values ( @idDocCollegato, @idUser, 'DELTA_TED', 'SEND_WS' )

			END
			ELSE
			BEGIN

				UPDATE ctl_doc 
						SET statofunzionale = 'ElabDatiRettificaConclusaTed' 
					WHERE id = @idDoc

				INSERT INTO CTL_Schedule_Process( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
							values ( @idDoc, @idUser, 'RETTIFICA_TED', 'ELABORA' )

			END
			



		END

	END
	ELSE IF @statoFunzionaleAttuale = 'ElabDatiRettificaConclusaTed'
	BEGIN

		UPDATE ctl_doc 
				SET statofunzionale = 'InvioInCorso' 
			WHERE id = @idDoc

		EXEC INSERT_SERVICE_REQUEST 'TED', 'rettificaGara', @IdUser, @idDoc

	END


END

GO
