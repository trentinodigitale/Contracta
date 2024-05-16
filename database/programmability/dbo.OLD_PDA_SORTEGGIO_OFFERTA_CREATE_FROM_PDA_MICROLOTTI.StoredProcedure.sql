USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_SORTEGGIO_OFFERTA_CREATE_FROM_PDA_MICROLOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_PDA_SORTEGGIO_OFFERTA_CREATE_FROM_PDA_MICROLOTTI] ( @idPDA int , @IdUser int  )
AS
BEGIN

	----------------------------------------------------------------------------------------------------------------
	-- QUESTA STORED DI MAKE DOC FROM VIENE UTILIZZATA PER CREARE IL DOCUMENTO DI SORTEGGIO A PARTIRE DA UNA PDA ---
	-- DI UNA GARA SENZA LOTTI ( O MONOLOTTO )  
	----------------------------------------------------------------------------------------------------------------
	-- LA CONTROPARTE PROCESSO PER LA CREAZIONE DEL SORTEGGIO AUTOMATICO è SORTEGGIO_EXEQUO_MONOLOTTO,PDA_MICROLOTTI
	----------------------------------------------------------------------------------------------------------------

	-- la variabile @idDoc identifica la pda

	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT

	declare @idDoc int
	declare @idRow int
	declare @idCom int

	set @PrevDoc=0
	
	declare @Errore as nvarchar(2000)
	set @Errore = ''

	set @id = null

	IF NOT EXISTS ( select idheader , tipodoc ,  id from PDA_DRILL_MICROLOTTO_TESTATA_VIEW where idheader = @idPDA and tipodoc = 'PDA_MICROLOTTI' and voce = 0 and numerolotto = '1' and Exequo = '1' )
	BEGIN
		set @Errore = 'Lo stato non è coerente con la funzione richiamata'
	END
	ELSE
	BEGIN

		-- il sorteggio ha come linkeddoc la comunicazione che a sua volta ha come linkeddoc la pda

		--SE NON SONO IN ERRORE CERCO UNA VERSIONE PRECEDENTE DEL DOCUMENTO 
		select @id = sor.id 
			from CTL_DOC sor with(nolock)
					INNER JOIN CTL_DOC com with(nolock) ON sor.LinkedDoc = com.id and com.tipodoc = 'PDA_COMUNICAZIONE' and com.JumpCheck = '0-SORTEGGIO' and com.deleted = 0 
					INNER JOIN CTL_DOC pda with(nolock) ON com.linkeddoc = pda.id and pda.deleted = 0
			where pda.id = @idPDA and sor.deleted = 0 and sor.TipoDoc in ( 'PDA_SORTEGGIO_OFFERTA' ) and sor.statofunzionale = 'InLavorazione' and sor.JumpCheck = 'MANUALE'
 
	END
	

	-- se non esiste lo creo
	IF @id is null and @Errore=''
	BEGIN

		select @idDoc = id from dbo.Document_MicroLotti_Dettagli where idheader = @idPDA and tipodoc = 'PDA_MICROLOTTI' and voce = 0 and numerolotto = '1'

		-- creo il documento comunicazione contenitore
		exec  PDA_COMUNICAZIONE_CREATE_FROM_SORTEGGIO @idPDA , @IdUser ,@idCom output

		-- creo il documento sorteggio del singolo lotto
		exec PDA_SORTEGGIO_OFFERTA_CREATE_FROM_SORTEGGIO @idDoc , @IdUser, 'MANUALE', @Id output

	END		

	if @Errore = ''
	begin

		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id

	end
	else
	begin

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	end

	SET NOCOUNT OFF

END
		













GO
