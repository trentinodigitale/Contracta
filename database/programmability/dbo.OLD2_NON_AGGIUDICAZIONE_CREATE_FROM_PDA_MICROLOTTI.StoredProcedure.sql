USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NON_AGGIUDICAZIONE_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_NON_AGGIUDICAZIONE_CREATE_FROM_PDA_MICROLOTTI] 
	( @iddoc int  , @idUser int )
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @id INT	
	DECLARE @Errore AS NVARCHAR(4000)
	DECLARE @count INT
	DECLARE @idGara INT
	
	SET @Errore = ''

	--VERIFICO CHE INTEROPERABILITà SIA ATTIVO
	SELECT @idGara = LinkedDoc FROM CTL_DOC WHERE Id = @iddoc

	IF dbo.attivo_INTEROP_Gara( @idGara ) = 1
	BEGIN

		----VERIFICA SE ESISTE UN DOCUMENTO IN LAVORAZIONE E LO RIAPRE
		SELECT @id=id
			FROM CTL_DOC WITH(NOLOCK) 
				WHERE LinkedDoc=@iddoc and TipoDoc='NON_AGGIUDICAZIONE' and deleted=0 and StatoFunzionale   in ('InLavorazione') 

		--SE NON HO TROVATO DOC CONTINUO
		IF ISNULL(@id,0)=0
		BEGIN
			
			--CREO UNA TABELLA CON I LOTTI ADATTI
			SELECT CIG
				INTO #LottiNonAgg
					FROM Document_MicroLotti_Dettagli  P WITH(nolock)
					JOIN ctl_doc PDA WITH(nolock) on p.idheader = PDA.id
						WHERE  p.StatoRiga IN ('Deserta','Revocato','NonAggiudicabile','NonGiudicabile','decaduta')  AND PDA.Id = @iddoc
		

			--ELIMINO I LOTTI CON CIG VUOTO O NULL
			DELETE FROM #LottiNonAgg WHERE ISNULL(CIG, '') = '' 

			--ELIMINO I LOTTI CON SCHEDE GIà INVIATE
				DELETE FROM #LottiNonAgg
					WHERE CIG IN (
						SELECT CIG FROM Document_PCP_Appalto_Schede
									WHERE  statoScheda <> ('ErroreCreazione') AND idHeader = @idGara AND bDeleted = 0 AND tipoScheda IN ('A1_29', 'NAG')
				)


			--SE ESISTONO LOTTI CONTINUO SENNò ERRORE
			SELECT @count = COUNT(*) from #LottiNonAgg	
			IF(@count > 0)
			BEGIN

				--CREA UN DOCUMENTO NON AGGIUDICAZIONE		
				INSERT into CTL_DOC ( IdPfu, Titolo , TipoDoc , deleted  ,LinkedDoc, Body, Fascicolo , Azienda, ProtocolloRiferimento)
					select @idUser, 'Scheda di non aggiudicazione' ,'NON_AGGIUDICAZIONE'  , 0 , @iddoc , body , C.Fascicolo, P.pfuidazi, ProtocolloRiferimento
						from CTL_DOC C with(NOLOCK) 
							inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser				
								WHERE C.Id=@iddoc 
								

				SET @id = SCOPE_IDENTITY()

			
				--INSERISCO I LOTTI DA REVOCARE
				insert into Document_MicroLotti_Dettagli (IdHeader, CIG , NumeroLotto, Descrizione, StatoRiga, TipoDoc, SelRow)
					select @id, P.CIG, NumeroLotto, Descrizione, P.StatoRiga, 'NON_AGGIUDICAZIONE', 0
						FROM Document_MicroLotti_Dettagli  P WITH(nolock)
							JOIN ctl_doc PDA WITH(nolock) on p.idheader = PDA.id
								WHERE  p.StatoRiga IN ('Deserta','Revocato','NonAggiudicabile','NonGiudicabile','decaduta')
								AND CIG IN (SELECT CIG FROM #LottiNonAgg) AND PDA.Id = @iddoc

			END
			ELSE
			BEGIN
				SET @id = 0
				SET @Errore = 'Operazione annullata, nessun lotto adatto alla creazione della scheda di non aggiudicazione'
			END

			DROP TABLE #LottiNonAgg
		END	
	END
	ELSE
	BEGIN
		SET @id = 0
		SET @Errore = 'Operazione non disponibile per questo tipo di gara'
	END


	IF @Errore = '' and ISNULL(@id,0) <> 0
	BEGIN
		-- rirorna l'id del doc da aprire
		select @Id as id, @Errore AS Errore	
	END
	ELSE
	BEGIN
		select 'Errore' as id , @Errore as Errore	
	END

END
GO
