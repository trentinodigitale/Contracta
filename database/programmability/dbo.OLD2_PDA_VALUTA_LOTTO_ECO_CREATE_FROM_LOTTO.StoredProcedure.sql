USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_VALUTA_LOTTO_ECO_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dbo].[OLD2_PDA_VALUTA_LOTTO_ECO_CREATE_FROM_LOTTO] 
	( @idDoc int -- rappresenta l'id dela riga del lotto, legato all'offerta della PDA, sul quale si fa la valutazione
	, @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @AttDZT_NAME  as varchar(200)

	set @Errore = ''

	set @id = null

	select @id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_ECO' ) and statofunzionale in (  'Confermato' )

	if exists( select IdRow from PDA_LST_BUSTE_ECO_OFFERTE_VIEW where IdRow = @idDoc and bReadDocumentazione = '1' )
	begin
		set @Errore = 'Per effettuare la valutazione economica e'' necessario prima aprire la relativa busta economica' 
	end

	if exists( select IdRow from PDA_LST_BUSTE_ECO_OFFERTE_VIEW where IdRow = @idDoc and StatoRiga = 'escluso' )
	begin

		if @id is null
		begin
			set @Errore = 'Non e'' possibile la valutazione economica se il lotto e'' stato escluso' 
		end

	end

	if exists( select IdRow from PDA_LST_BUSTE_ECO_OFFERTE_VIEW where IdRow = @idDoc and StatoRiga not in ( 'inVerificaEco' , 'daValutare' , 'Valutato', 'ValutatoECO','SospettoAnomalo') )
	begin
	
		if @id is null
		begin
			set @Errore = 'Lo stato del lotto non consente la valutazione' 
		end
	end


	if @Errore = '' 
	begin


		set @id = null
		select @id = id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_ECO' ) and statofunzionale in (  'Confermato' , 'InLavorazione' )

		IF @id is null
		BEGIN

			   -- altrimenti lo creo

				INSERT into CTL_DOC (
							IdPfu,  TipoDoc, 
							Titolo, Body, Azienda,  
							ProtocolloRiferimento, Fascicolo, LinkedDoc )
					select @IdUser as idpfu , 'PDA_VALUTA_LOTTO_ECO' as TipoDoc ,  
							'Valutazione Lotto' as Titolo, '' Body, idAziPartecipante as  Azienda,  
							ProtocolloRiferimento, Fascicolo, d.id as LinkedDoc
					from Document_MicroLotti_Dettagli d with (nolock)
							inner join Document_PDA_OFFERTE o with (nolock) on o.IdRow = d.idHeader
							inner join Document_PDA_TESTATA t with (nolock) on o.idHeader = t.idHeader
							inner join CTL_DOC b with (nolock) on o.idHeader = b.id
					where d.id = @idDoc

				set @id = SCOPE_IDENTITY()

				-- cerco una versione precedente se esiste
				declare @idPrev int
				set @idPrev = null
				select @idPrev = max(id) from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_VALUTA_LOTTO_ECO' ) and statofunzionale in (  'Annullato' )

				if @idPrev is not null
				begin

					-- se esiste una versione precedente ricopiamo le note per la compilazione
					insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
						select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
							from CTL_DOC_Value with (nolock)
							where idheader = @idPrev and dzt_name = 'Note'

				end
				--else
				begin

					declare @CriterioValutazione varchar(20)
					declare @DescrizioneCriterio nvarchar(255)
					declare @Modello nvarchar(255)
					declare @PunteggioMax varchar(50)
					declare @Punteggio varchar(50)
					declare @Formula  nvarchar(4000)
					declare @AttributoCriterio nvarchar(255)
					declare @Coefficiente float

					declare @ModAttribPunteggio varchar(50)
					declare @NumeroLotto varchar(50)
					declare @idBando as int

					declare @formulaEcoSDA varchar(8000)

					declare @idRow int 
					declare @Row int 
					
					set @Row = 0
					set @formulaEcoSDA = ''



					-- recupero il modello di input del fornitore
					select @Modello = 'MODELLI_LOTTI_' + TipoBando  + '_MOD_OffertaINPUT'
							, @idBando = ba.idHeader 
							, @NumeroLotto = d.NumeroLotto
						from Document_MicroLotti_Dettagli d with(nolock)
								inner join Document_PDA_OFFERTE o with(nolock) on o.IdRow = d.idHeader
								inner join Document_PDA_TESTATA t with(nolock) on o.idHeader = t.idHeader
								inner join CTL_DOC b with(nolock) on o.idHeader = b.id
								inner join Document_Bando ba with(nolock) on ba.idHeader = b.LinkedDoc
							where d.id = @idDoc


					-- recupero @ModAttribPunteggio dal lotto per determinare quale colonna gestire in edit, se coefficiente o punteggio
					select @ModAttribPunteggio = ModAttribPunteggio from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and N_Lotto = @NumeroLotto


					--recupero le desc degli attributi criterio
					select MA_DZT_Name , isnull( ML_Description , MA_DescML ) as MA_DescML into #t
						from CTL_ModelAttributes	with (nolock)
							left outer join  LIB_Multilinguismo with (nolock) on ML_KEY = MA_DescML and ML_LNG = 'I'
						where MA_MOD_ID = @Modello 


						--- TORNA SEMPRE RECORD ? 

					declare crsOf cursor static for
						select p.idRow , CriterioFormulazioneOfferte, DescrizioneCriterio, PunteggioMax, FormulaEconomica, AttributoValore , p.Punteggio , p.Giudizio, v.FormulaEcoSDA
						from Document_MicroLotti_Dettagli d with(nolock)
							inner join Document_Microlotto_PunteggioLotto_ECO p with(nolock) on p.idHeaderLottoOff = d.id
							inner join Document_Microlotto_Valutazione_ECO v with(nolock) on p.idRowValutazione = v.idRow
						where d.id = @idDoc
						order by p.idRow

						-- la select fatta per la parte tecnica : 
						--select  
						--	 p.idRow , CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio , Punteggio , Giudizio
						--from Document_MicroLotti_Dettagli d 
						--		inner join Document_Microlotto_PunteggioLotto p on p.idHeaderLottoOff = d.id
						--		inner join Document_Microlotto_Valutazione v on p.idRowValutazione = v.idRow
						--	where d.id = @idDoc
						--	order by p.idRow

					open crsOf 
					fetch next from crsOf into  @idRow , @CriterioValutazione, @DescrizioneCriterio, @PunteggioMax, @Formula, @AttributoCriterio , @Punteggio , @Coefficiente,@formulaEcoSDA

					while @@fetch_status=0 
					begin 

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'CriterioFormulazioneOfferta2' , @CriterioValutazione )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'DescrizioneCriterio' , @DescrizioneCriterio )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'PunteggioMax' , @PunteggioMax )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Formula' , @Formula )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'AttributoCriterio' , @AttributoCriterio )

						set @AttDZT_NAME = dbo.GetPos(@AttributoCriterio, '.', 2 )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							select top 1 @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Descrizione' , dbo.StripHTML( MA_DescML )
									from #t 
								where  @AttDZT_NAME = MA_DZT_Name


						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Value' , @Punteggio )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'idRow' , @idRow )

						--le uniche righe abilitate alla compilazione sono quelle dove la formula è "Valutazione soggettiva"
						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'NotEditable' , case 
																								when @formulaEcoSDA <> 'Valutazione soggettiva' 

																									-- la valutazione con formula rende tutti i campi non editabili
																									then ' CriterioFormulazioneOfferta2 Coefficiente Note Value ' 

																									-- altrimenti la valutazione è soggettiva, in questo caso si lascia editabile solo la colonna coefficiente o punteggio
																									else ' CriterioFormulazioneOfferta2 ' +
																									
																										case when @ModAttribPunteggio = 'punteggio'
																											then ' Coefficiente '
																											else ' Value '
																											end 
																									
																									end 

																									)

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Coefficiente' , @Coefficiente )

						insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
							values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'FormulaEcoSDA' , @FormulaEcoSDA )

						set @Row = @Row + 1

						fetch next from crsOf into  @idRow , @CriterioValutazione, @DescrizioneCriterio, @PunteggioMax, @Formula, @AttributoCriterio , @Punteggio , @Coefficiente,@formulaEcoSDA

					end

					close crsOf
					deallocate crsOf

				end

		end

	end
		
	



	if @Errore = ''
	begin

		-- verifico se alla valutazione è stata associata la sezione per la visualizzazione dei dati offerti
		if not exists ( select [IdRow] from CTL_DOC_SECTION_MODEL with (nolock) where [IdHeader] = @Id and DSE_ID = 'PDA_OFFERTA_BUSTA_ECO' )
		begin


			insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) 
				select @Id , 'PDA_OFFERTA_BUSTA_ECO' ,  'MODELLI_LOTTI_' + TipoBando + '_MOD_Offerta'
					from Document_MicroLotti_Dettagli d with (nolock)
							inner join Document_PDA_OFFERTE o with (nolock)on o.IdRow = d.idHeader
							inner join CTL_DOC p with (nolock)on o.idHeader = p.id
							inner join document_bando b with (nolock) on p.LinkedDoc = b.idHeader
						where d.id = @idDoc

		end



		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END


















GO
