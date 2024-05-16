USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PCP_SCHEDE_UPDATE_REQUEST]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PCP_SCHEDE_UPDATE_REQUEST] ( 
			@idRic INT , 
			@idPfu INT, 
			@tipoScheda varchar(100), 
			@IdDoc_Scheda int,
			@statoScheda varchar(100),
			@idRowScheda int = 0)
AS
BEGIN

	-- STORED UTILE A MODIFICARE LO STATO SCHEDA/APPALTO PRESENTE NELLA TABELLA Document_PCP_Appalto_Schede
	--		per i flussi di schede di "comunica post pubblicazione" questa stored non serve perchè 
	--		lì il perno dell'integrazione è l'idrow della Document_PCP_Appalto_Schede. il cambio di stato avviene da codice con un update "secco".
	--		per l'appalto invece, dove si parte dalla gara e non si innesca il giro richiedendo un integrazione con PCP_SCHEDE_INSERT_REQUEST,
	--		siamo costretti ad usare logiche "meno forti" per trovare il record per poi aggiornarlo.

	--	@idRic in input è l'idHeader della Document_PCP_Appalto_Schede e dovrebbe essere l'id della gara
	--	@idPfu utente che effettua l'operazione
	--	@tipoScheda la scheda che si vuole aggiornare, dovrebbe coincidere con il valore della colonna pcp_TipoScheda della tabella Document_PCP_Appalto
	--  @IdDoc_Scheda è l'id del documento richiedente. può non coincidere con la gara. ad es. l'id del contratto o della convenzione se si richide una scheda A1_29
	--  @statoScheda è lo stato che si vuole riportare sulla scheda

	SET NOCOUNT ON

	DECLARE @idRow INT

	-- SE IL CHIAMANTE NON CONOSCE L'IDROW DELLA SCHEDA LO CERCO
	IF @idRowScheda = 0
	BEGIN

		-- Per trovare il record da aggiornare cerco a parità di "idHeader + IdDoc_Scheda + tipoScheda + bDeleted a 0" 
		--	per sicurezza prendiamo l'ultimo record, ma con la gestione del cancellato logico non dovrebbe essercene bisogno
		SELECT top 1 @idRow = idRow 
			from Document_PCP_Appalto_Schede with(nolock)
			where idHeader = @idRic and IdDoc_Scheda = @IdDoc_Scheda and tipoScheda = @tipoScheda and bDeleted = 0
			order by idRow desc

	END
	ELSE
	BEGIN
		set @idRow = @idRowScheda
	END

	update Document_PCP_Appalto_Schede
			set statoScheda = @statoScheda
		where idRow = @idRow


END



GO
