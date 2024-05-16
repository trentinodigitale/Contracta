USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PUBBLICA_GARA_TED_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_PUBBLICA_GARA_TED_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int, @da_invio_gara int = 0 )
AS
BEGIN

	-- non permettiamo più la richiesta di pubblicazione GUUE con il comando sulla toolbar.
	--	l'unica richiesta ammissibile è quella che scatta automaticamente all'invio della gara.
	--	il comando pubblica lo lasciamo solo come scorciatoia per aprire la richiesta di pubblicazione

	SET NOCOUNT ON

	declare @Id as INT
	declare @Idazi as INT
	declare @Errore as nvarchar(2000)
	declare @newid as int
	declare @Bando as int
	declare @Rup varchar(50) = ''
	declare @RupName nvarchar(1000)

	set @Errore=''	

	IF @da_invio_gara = 0
	BEGIN

		set @newId = 0
		select @newId = isnull(max(id),0) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'PUBBLICA_GARA_TED'  ) and StatoFunzionale not in ( 'Annullato', 'Rifiutato' )

		if @newid = 0
		begin
			set @Errore = 'Nessuna Richiesta Pubblicazione GUUE presente per la procedura'
		end


	END
	ELSE
	BEGIN
	
		select @newId = max(id) from CTL_DOC  with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in (  'PUBBLICA_GARA_TED'  ) and StatoFunzionale not in ( 'Inviato' , 'Annullato','Invio_con_errori', 'Rifiutato' )

		IF @newId is null
		BEGIN

			set @Bando = @idDoc

			INSERT INTO CTL_DOC (IdPfu,  TipoDoc, Titolo, idpfuincharge ,Azienda ,body,LinkedDoc, JumpCheck, PrevDoc, Caption, Deleted, DataDocumento) --la colonna dataDocumento servirà per il servizio di verifica pubblicazione
				VALUES ( @IdUser,'PUBBLICA_GARA_TED' ,'Richiesta Pubblicazione GUUE' , @IdUser ,@Idazi ,'',@idDoc, '' ,NULL, NULL, 1, getDate())

			set @newId = SCOPE_IDENTITY()

			INSERT INTO Document_TED_GARA( idHeader, id_gara, TED_DATA_SCADENZA_PAG, TED_DATA_SCADENZA_RICHIESTA_INVITO, TED_DATA_LETTERA_INVITO, TED_NUMERO_QUOTIDIANI_NAZ, TED_NUMERO_QUOTIDIANI_REGIONALI, TED_SITO_MINISTERO_INF_TRASP, TED_LINK_SITO)
							select @newId, simog_id_gara, TED_DATA_SCADENZA_PAG, DATA_SCADENZA_RICHIESTA_INVITO, DATA_LETTERA_INVITO, NUMERO_QUOTIDIANI_NAZ, NUMERO_QUOTIDIANI_REGIONALI, TED_SITO_MINISTERO_INF_TRASP, LINK_SITO 
							from [SIMOG_PUBBLICA_DATI_WS]
							where id_gara = @Bando

			if @da_invio_gara = 0
			begin

				--richiediamo l'invio per il ws deltaGaraTED.
				-- nel processo TED-FINALIZZA gestiamo il ritorno
				EXEC INSERT_SERVICE_REQUEST 'TED', 'pubblicaGara', @IdUser, @newid

				update CTL_DOC
					--set StatoFunzionale = case when @da_invio_gara = 0 then 'InvioInCorso' else 'InAttesaPubTed' end,
					set StatoFunzionale = 'InvioInCorso',
						Deleted = 0
				where id = @newid

				--annullo eventuali altri documenti di pubblicazione ted
				update CTL_DOC
						set StatoFunzionale = 'Annullato'
					where id <> @newid and TipoDoc = 'PUBBLICA_GARA_TED' and LinkedDoc = @Bando

			end

		END --IF @newId is null

	END

	if  ISNULL(@newId,0) <> 0
	begin

		-- rirorna l'id del doc da aprire
		select @newId as id, 'PUBBLICA_GARA_TED' as TYPE_TO
	
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end
END










GO
