USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PCP_SCHEDE_INSERT_REQUEST]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC PCP_SCHEDE_INSERT_REQUEST @idGara, @idpfu, @tipoScheda, '', @idGara, 1

CREATE PROC [dbo].[OLD_PCP_SCHEDE_INSERT_REQUEST] ( 
			@idRic INT , 
			@idPfu INT, 
			@tipoScheda varchar(100), 
			@operazioneRichiesta varchar(50),
			@IdDoc_Scheda int = 0,
			@noServiceRequest int = 0,
			@ElencoCIG varchar(max) = null,
			@DatiElaborazione varchar(max) = null,
			@idRowScheda INT = -1 OUTPUT)
AS
BEGIN

	-- STORED UTILE PER ACCENTRARE LA RICHIESTA DI UNA NUOVA SCHEDA. E' NATA PER GESTIRE S1 ed S2. giri post pubblicazione gara

	--	@idRic in input è l'idHeader della Document_PCP_Appalto_Schede e dovrebbe essere l'id della gara
	--	@idPfu utente che effettua l'operazione
	--	@tipoScheda dovrà essere un valore gestito dai controller, quindi non inventato. ad es. S2
	--	@operazioneRichiesta  dovrà essere un operation riconosciuta dal giro di integration request, quindi con ctl_parametri valorizzata etc
	--  @IdDoc_Scheda (opz) è l'id del documento richiedente. può non coincidere con la gara. ad es. l'id del contratto o della convenzione se si richide una scheda A1_29
	--  @noServiceRequest (opz) 0, che è il default, se si vuole che l'inserimento della scheda porti anche ad una richiesta di integrazione. giro standard per il flusso di comunica post pubblicazione. 1 se si vuole solo il record della scheda
	--  @idRowScheda (opz) parametro di output per far avere al chiamante l'idrow del record appena creato della Document_PCP_Appalto_Schede

	SET NOCOUNT ON

	DECLARE @integrazione varchar(50) = 'INTEROPERABILITA'
	--DECLARE @idRow INT

	-- a parità di "idHeader + IdDoc_Scheda + tipoScheda" metto a cancellato logico i record precedenti
	--		utilizzo come chiave anche IdDoc_Scheda perchè la stessa scheda potrebbe essere inviata su documenti differenti ( vedi ad es. contratti e conv )
	--		ma relativi alla stessa gara. Questi documenti avranno dati/cig diversi e quindi devono restare tutti validi

	IF isnull(@ElencoCIG,'') = ''
	BEGIN

		UPDATE Document_PCP_Appalto_Schede
				set bDeleted = 1
			WHERE idHeader = @idRic and IdDoc_Scheda = @IdDoc_Scheda and tipoScheda = @tipoScheda and bDeleted = 0

	END
	ELSE
	BEGIN

		UPDATE Document_PCP_Appalto_Schede
				set bDeleted = 1
			WHERE idHeader = @idRic and IdDoc_Scheda = @IdDoc_Scheda and tipoScheda = @tipoScheda and bDeleted = 0 and CIG = @ElencoCIG

	END

	INSERT INTO Document_PCP_Appalto_Schede ( idHeader, bDeleted, dateInsert, tipoScheda, statoScheda, IdDoc_Scheda,  CIG, DatiElaborazione)
									VALUES  ( @idRic, 0, getDate(), @tipoScheda, 'InvioInCorso', @IdDoc_Scheda, @ElencoCIG, @DatiElaborazione ) 

	set @idRowScheda = SCOPE_IDENTITY()

	-- se è stato richiesto di NON inserire la richiesta nella Services_Integration_Request non chiamiamo la stored INSERT_SERVICE_REQUEST
	IF @noServiceRequest = 0
	BEGIN
		EXEC INSERT_SERVICE_REQUEST @integrazione, @operazioneRichiesta, @idPfu, @idRowScheda
	END

END



GO
