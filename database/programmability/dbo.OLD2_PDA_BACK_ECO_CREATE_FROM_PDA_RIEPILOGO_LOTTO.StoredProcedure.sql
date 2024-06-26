USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_BACK_ECO_CREATE_FROM_PDA_RIEPILOGO_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_PDA_BACK_ECO_CREATE_FROM_PDA_RIEPILOGO_LOTTO] 
	( @iddoc int  , @idUser int )
AS
BEGIN
	
	set nocount on

	DECLARE @id INT	
	DECLARE @Errore AS NVARCHAR(4000)
	DECLARE @IDGARA INT
	DECLARE @CIG VARCHAR(100)
	declare @linkedDoc int

	SET @Errore = ''


	----CONTROLLO CHE NON SIANO STATE INVIATE SCHEDE DI NON AGG PER QUESTO LOTTO IN TAL CASO BLOCCO IL DOCUMENTO
	SELECT @IDGARA = PDA.LinkedDoc, @CIG = C.CIG
		FROM ctl_doc PDA WITH(nolock) 
		JOIN Document_MicroLotti_Dettagli C WITH(nolock) ON C.IdHeader = PDA.Id
			WHERE C.Id = @iddoc
	

	IF(dbo.attivo_INTEROP_Gara(@IDGARA) = 1)
	BEGIN
			
		--CONTROLLO CHE NON SIANO STATE INVIATE SCHEDE ANDATE A BUON FINE PER QUELA GARA E QUEL CIG
		IF EXISTS( SELECT idHeader FROM Document_PCP_Appalto_Schede with(nolock) WHERE idHeader = @IDGARA AND CIG = @CIG AND tipoScheda IN ('NAG','A1_29') AND bDeleted = 0 AND statoScheda NOT IN ('SC_N_CONF','SC_CONF_MAX_RETRY','SC_CONF_NO_ESITO','ErroreCreazione') )
		BEGIN
			SET @id = 0
			SET @Errore = 'Errore nelle creazione del documento, è stata inviata una scheda di non aggiudicazione per questo lotto'
		END

	END



	IF @Errore = ''
	BEGIN
		
		select @linkedDoc = LinkedDoc from PDA_BACK_ECO_FROM_PDA_RIEPILOGO_LOTTO where ID_FROM = @iddoc

		--VERIFICA SE ESISTE UN DOCUMENTO IN LAVORAZIONE E LO RIAPRE
		SELECT @id=id
			FROM CTL_DOC WITH(NOLOCK) 
				WHERE LinkedDoc = @linkedDoc and TipoDoc='PDA_BACK_ECO' and deleted=0 and StatoFunzionale in ('InLavorazione') 

	
		IF ISNULL(@id,0) = 0
		BEGIN

			--CREO IL DOCUMENTO
			INSERT INTO CTL_DOC (IdPfu, IdDoc, LinkedDoc, TipoDoc, StatoFunzionale, VersioneLinkedDoc, Note, Fascicolo, JumpCheck, Deleted)
				SELECT distinct @idUser, IDDOC, LinkedDoc, 'PDA_BACK_ECO', 'InLavorazione', VersioneLinkedDoc, Note, Fascicolo, JumpCheck, 0
					FROM PDA_BACK_ECO_FROM_PDA_RIEPILOGO_LOTTO WHERE ID_FROM = @iddoc

			SET @id = SCOPE_IDENTITY()


		END


	END
	

	IF ISNULL(@id,0) = 0
	BEGIN
		SELECT 'Errore' AS id , @Errore AS Errore
	END
	ELSE
	BEGIN
		--SELEZIONO L'ID DEL DOC PER PARIRE IL RIPRISTINA FASE
		SELECT @id AS id, @Errore AS Errore	
					
	END

END
GO
