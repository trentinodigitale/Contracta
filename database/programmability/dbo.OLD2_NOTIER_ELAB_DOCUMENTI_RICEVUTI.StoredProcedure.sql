USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NOTIER_ELAB_DOCUMENTI_RICEVUTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select * from Document_NoTIER_ListaDocumenti_lavoro



CREATE PROCEDURE [dbo].[OLD2_NOTIER_ELAB_DOCUMENTI_RICEVUTI]( @idAzi as int )
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	declare @inizioElab datetime
	set @inizioElab = getdate()

	insert into ctl_trace( contesto, iddoc, descrizione) values ( 'NOTIER_ELAB_DOCUMENTI_RICEVUTI', @idAzi, 'Inizio elaborazione')

	-- SE IL RECORD CHE PILOTA L'INVIO DELLE EMAil NON ESISTE LO CREIAMO ( IL PROCESSO DI SEND_MAIL LO AGGIORNERA' )
	IF 	NOT EXISTS ( select top 1 idazi from Document_NoTIER_Alerting with(nolock) where idazi = @idAzi )
	BEGIN

		INSERT Document_NoTIER_Alerting(idazi, data) values ( @idAzi, getdate() )

	END


	------------------------------
	--  Scorporo URN e Versione --
	------------------------------
	BEGIN TRY

		UPDATE Document_NoTIER_ListaDocumenti_lavoro
			   SET URN_NO_V = dbo.notier_getURN_V( urn ),
				  URN_V = dbo.notier_getVersioneURN( urn)
			where idazi = @idAzi

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Scorporo URN e Versione :' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH 

	---------------------------------------------------------------------------------------------------------------
	-- Cancello logicamente le righe della tabella lavoro per quegli URN gia presenti nella tabella complessivo ---
	---------------------------------------------------------------------------------------------------------------
	BEGIN TRY

		UPDATE lavoro 
			   set deleted = 1
			from Document_NoTIER_ListaDocumenti_lavoro lavoro WITH(NOLOCK)
				  INNER JOIN Document_NoTIER_ListaDocumenti completa WITH(NOLOCK, index(IX_URN)) ON completa.urn = lavoro.urn
			--where lavoro.idazi = @idAzi  and completa.idazi = @idAzi

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Cancellazione logica degli urn gia presenti :' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH 

	-----------------------------------------------------------------------------------------------------------------------------------------------------
	-- Cancello logicamente le righe della tabella complessiva con gli URN_V presenti anche nella tabella di lavoro e che hanno una versione maggiore di 1 --
	-----------------------------------------------------------------------------------------------------------------------------------------------------
	BEGIN TRY

		--UPDATE completa 
		--		set deleted = 1
		--	from Document_NoTIER_ListaDocumenti completa with(nolock)
		--			INNER JOIN Document_NoTIER_ListaDocumenti_lavoro lavoro with(nolock) ON  CAST(lavoro.URN_V AS INT) > 1 and lavoro.URN_NO_V = completa.URN_NO_V and lavoro.deleted = 0
		--	where completa.idazi = @idAzi and completa.deleted = 0 

		UPDATE completa 
				set deleted = 1
			from Document_NoTIER_ListaDocumenti_lavoro lavoro with(nolock)
					inner join Document_NoTIER_ListaDocumenti completa with( index(IX_URN_NO_V ) ) ON  lavoro.URN_NO_V = completa.URN_NO_V and completa.deleted = 0
			where completa.idazi = @idAzi and CAST(lavoro.URN_V AS INT) > 1 and lavoro.deleted = 0 

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Cancellazione logica degli urn_v gia presenti :' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH

	-------------------------------------------------------------------------------------------------------------
	--- Travaso tutti i record rimanenti dalla tabella di lavoro alla complessiva e aggiorno i destinatari -----
	-------------------------------------------------------------------------------------------------------------
	BEGIN TRY

		INSERT INTO Document_NoTIER_ListaDocumenti ( idazi, idpfu, data, URN, DATARICEZIONENOTIER, STATOGIACENZA, CHIAVE_CODICEFISCALEMITTENTE, CHIAVE_ANNO, CHIAVE_NUMERO, CHIAVE_TIPODOCUMENTO, URN_NO_V, URN_V, deleted, IDPEPPOLDESTINATARIO, IDPEPPOLMITTENTE, RagioneSocialeMittente, IDNOTIER_FLUSSO )
			select idazi, idpfu, getDate(), URN, DATARICEZIONENOTIER, STATOGIACENZA, CHIAVE_CODICEFISCALEMITTENTE, CHIAVE_ANNO, CHIAVE_NUMERO, CHIAVE_TIPODOCUMENTO, URN_NO_V, URN_V, deleted, IDPEPPOLDESTINATARIO,IDPEPPOLMITTENTE, RagioneSocialeMittente, IDNOTIER_FLUSSO
				from Document_NoTIER_ListaDocumenti_lavoro with(nolock) 
				where idazi = @idAzi and deleted = 0

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Inserimento dei documenti nella tabella finale :' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH
		

	-- AGGIUNGO NELLA TABELLA DEI DESTINATARI NUOVI MITTENTI/ENTI NOTI DI DOCUMENTI DI TIPO ORDINE.
	BEGIN TRY

		--se il codice fiscale mittente è presente in anagrafica la sorgene sarà NULL , così da far uscire l'ente tra i potenziali destinatari dei DDT. altrimenti 'lista' che invece viene esclusa
		INSERT INTO Document_NoTIER_Destinatari( ID_NOTIER, ID_PEPPOL, ID_IPA, piva_cf, denominazione, sorgente)
			select distinct '', a.IDPEPPOLMITTENTE, '', a.CHIAVE_CODICEFISCALEMITTENTE,  a.RagioneSocialeMittente, case when dm.lnk is null then 'LISTA'  else NULL end
				from Document_NoTIER_ListaDocumenti_lavoro a with(nolock) 
						left join Document_NoTIER_Destinatari b with(nolock) on b.ID_PEPPOL = a.IDPEPPOLMITTENTE
						left join DM_Attributi dm with(nolock) on dm.dztNome = 'codicefiscale' and dm.vatValore_FT = a.CHIAVE_CODICEFISCALEMITTENTE and dm.idApp = 1
				where idazi = @idAzi and deleted = 0 and CHIAVE_TIPODOCUMENTO = 'ORDINE' and b.id IS NULL and a.IDPEPPOLMITTENTE is not null

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Aggiunta dei nuovi destinatari :' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH


	BEGIN TRY

		DELETE FROM Document_NoTIER_ListaDocumenti_lavoro where idazi = @idAzi

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Cancellazione dei dati dalla tabella di lavoro : ' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH

	BEGIN TRY

		IF EXISTS ( 
			select top 1 a.id 
				from Document_NoTIER_ListaDocumenti a with(nolock) 
						inner join Document_NoTIER_Alerting b on b.idAzi = a.idazi and a.data >= b.data -- tutti i documenti con data maggiore dell'ultimo invio mail
				where a.idazi = @idazi and a.deleted = 0 
		)
		BEGIN

			INSERT INTO CTL_Schedule_Process   ( iddoc, iduser, DPR_DOC_ID, DPR_ID)
										values ( @idAzi, 0, 'NOTIER_LISTA_PUSH', 'SEND_MAIL' )

		END
		ELSE
		BEGIN

			-- in assenza di nuovi documenti facciamo comunque avanzare la sentinella 
			UPDATE Document_NoTIER_Alerting
					SET data = getdate()
				WHERE idazi = @idAzi

		END

	END TRY
	BEGIN CATCH  

		SELECT  @ErrorMessage = 'Schedulazione invio email di notifica : ' + ERROR_MESSAGE(),  
				@ErrorSeverity = ERROR_SEVERITY(),  
				@ErrorState = ERROR_STATE() 

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity,
				   @ErrorState
				   )

		RETURN 
	END CATCH
	
	insert into ctl_trace( contesto, iddoc, descrizione) values ( 'NOTIER_ELAB_DOCUMENTI_RICEVUTI', @idAzi, 'fine elaborazione.' + cast( datediff(MS, @inizioElab, getdate()) as varchar) )



END


GO
