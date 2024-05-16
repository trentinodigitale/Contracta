USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DELTA_TED_AGGIUDICAZIONE_ANNULLA_RICHIESTA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DELTA_TED_AGGIUDICAZIONE_ANNULLA_RICHIESTA] ( @idGara int , @IdUser int, @lotto varchar(max) = null )
AS
BEGIN 

	SET NOCOUNT ON

	--Ricerca un documento di aggiudicazione F03 per il lotto indicato
	--Se la richiesta F03 è ancora nello stato di "AttesaIntegrazione" ( o in "InvioInCorso" )

	--- AttesaIntegrazione
	--   mettiamo il documento nello stato di "Annullato" ( quando passerà la schedulazione trovandolo annullato non sarà seguito )

	--- InvioInCorso
	--		- Verificare che la sentinella sia stata presa in carico
	--		- Se lo stato nella tabella dei servizi = "Inserita" allora possiamo mettere ad Annullato e la pagina verificherà lo stato del documento.
	--		- Se Stato è <> "Inserita bisogna innescare una integrazione di annullamento ( da Analizzare/da fare forse in futuro )

	declare @idDocTed INT
	declare @statoFunzionale varchar(100)
	declare @idSentinella INT

	SELECT @idDocTed = id, @statoFunzionale = StatoFunzionale 
		FROM CTL_DOC WITH(NOLOCK) 
		WHERE tipodoc = 'DELTA_TED_AGGIUDICAZIONE' and Deleted = 0 and VersioneLinkedDoc = @lotto and LinkedDoc = @idGara

	if @statoFunzionale = 'AttesaIntegrazione'
	begin

		UPDATE CTL_DOC
				set StatoFunzionale = 'Annullato'
			where id = @idDocTed

	end

	if @statoFunzionale = 'InvioInCorso'
	begin

		select @idSentinella = max(idrow) from Services_Integration_Request with(nolock) where integrazione = 'TED' and operazioneRichiesta = 'aggiudicazione' and statoRichiesta = 'Inserita' and idRichiesta = @idDocTed and isOld = 0

		if not @idSentinella is null
		begin
			
			update Services_Integration_Request
					set isold = 1
				where idrow = @idSentinella

		end


	end



END

GO
