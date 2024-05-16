USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_CALCOLO_DEL_SECONDO_PREZZO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE proc [dbo].[PDA_CALCOLO_DEL_SECONDO_PREZZO]( @idBando int , @idDoc int, @NumeroLotto VARCHAR)
as
begin

		declare @Algoritmo varchar(20)
		declare @idDocCriterio int
		declare @idLotto int

		-- recupero id del lotto
		select @idLotto = id
			from Document_MicroLotti_Dettagli with(nolock) 
			where IdHeader = @idDoc and TipoDoc = 'PDA_MICROLOTTI' and NumeroLotto = @NumeroLotto and voce = 0 


		-- recupero il documento di sorteggio criterio se presente
		select @idDocCriterio = id from ctl_doc with(nolock) 
			where linkeddoc = @idDoc and tipodoc = 'CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023' 
					and StatoFunzionale  = 'Inviato' and deleted = 0 

		-- definisco quale algoritmo applicare
		IF @idDocCriterio is not null
		BEGIN
			 SELECT @Algoritmo = 'Metodo ' + RIGHT( dzt_name , 1 ) from CTL_DOC_VALUE where idheader = @idDocCriterio AND DSE_ID = 'CRITERI'  AND VALUE = '1' AND DZT_Name LIKE 'check_criterio%'
		END
		ELSE
		BEGIN
			select @Algoritmo = METODO_DI_CALCOLO_ANOMALIA from document_bando where idHeader = @idBando
		END


		-- APPLICAZIONE DEL METODO DEL SECONDO PREZZO: Settato il valore di 
		--  ribasso del secondo classificato all'aggiudicatario ovvero al primo classificato

		-- se è stata effettuato il calcolo dell'anomalia 
		--  ed è una gara al prezzo
		-- ed è richiesto per il lotto la verifica dell'anomalia
		-- e l'algoritmo è il B
		-- allora rimpiazzo il prezzo del primo classificato con l'importo del secondo
		IF @Algoritmo = 'Metodo B' AND 
			EXISTS (SELECT  CalcoloAnomalia
						FROM BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c	
						WHERE idBando = @idBando AND CalcoloAnomalia = '1'
								and CriterioAggiudicazioneGara = '15531'
								and @NumeroLotto = c.N_Lotto
					
					)
			AND EXISTS(SELECT id
							FROM CTL_DOC	
							WHERE tipodoc = 'VERIFICA_ANOMALIA' and LINKEDDOC = @idLotto 	
									and deleted = 0	and StatoFunzionale = 'Confermato'
						)
		BEGIN

			declare @idPrimoClassificato int
			declare @idSecondoClassificato int

			declare @ValoreImportoLottoOriginario float
			declare @ValoreImportoLottoSecondoClassificato float

			declare @ValoreScontoOriginario float
			declare @ValoreScontoSecondoClassificato float

			select @idSecondoClassificato = id, @ValoreImportoLottoSecondoClassificato = ValoreImportoLotto, @ValoreScontoSecondoClassificato = ValoreSconto
				from Document_MicroLotti_Dettagli 
				where IdHeader in 
				(
					select  IdRow 
						from Document_PDA_OFFERTE 
						where idheader = @idDoc 
								and StatoPDA in ( '2' ,'22' ,'222')
				)
				and TipoDoc = 'PDA_OFFERTE'
				and NumeroLotto = @NumeroLotto
				and StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) --<> 'escluso'
				and Voce = 0 and posizione = 'II Classificato'

			select @idPrimoClassificato = id, @ValoreImportoLottoOriginario = ValoreImportoLotto, @ValoreScontoOriginario = ValoreSconto
				from Document_MicroLotti_Dettagli 
				where IdHeader in 
				(
					select  IdRow 
						from Document_PDA_OFFERTE 
						where idheader = @idDoc 
								and StatoPDA in ( '2' ,'22' ,'222')
				)
				and TipoDoc = 'PDA_OFFERTE'
				and NumeroLotto = @NumeroLotto
				and StatoRiga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' ) --<> 'escluso'
				and Voce = 0 and posizione like '%Aggiudicatario%'

			-- Conservo il Valore dell'importo lotto originario
			update Document_MicroLotti_Dettagli 
				set ValoreImportoLottoOriginario = @ValoreImportoLottoOriginario, ValoreScontoOriginario = @ValoreScontoOriginario
				where id = @idPrimoClassificato

			update Document_MicroLotti_Dettagli 
				set ValoreImportoLotto = @ValoreImportoLottoSecondoClassificato, ValoreSconto = @ValoreScontoSecondoClassificato
				where id = @idPrimoClassificato

		END


end































GO
