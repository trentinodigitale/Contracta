USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERIFICA_ANOMALIA_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [dbo].[VERIFICA_ANOMALIA_CREATE_FROM_LOTTO]
	( @idDoc int , @IdUser int , @riesegui_calcoli as varchar(10) = 'NO' )
AS
BEGIN
	SET NOCOUNT ON

	declare @Id as INT
	declare @idNew  as INT

	declare @PrevDoc as INT
	set @PrevDoc=0
	
	declare @NumAmmesse int
	declare @CriterioAggiudicazioneGara varchar(50)
	declare @OffAnomale  varchar(50)
	declare @StatoRiga varchar(50)

	declare @NumAli int
	declare @idrow int
	declare @i int
	
	declare @MediaRibassi decimal( 30, 10 ) 
	declare @MediaScarti decimal( 30, 10 ) 
	declare @SogliaAnomalia decimal( 30, 10 ) 

	declare @OfferteUtili varchar(100)
	set @OfferteUtili = 'SI'

	declare @DataInvioBando as datetime
	declare @DataConfronto as datetime

	declare @ModalitaAnomalia_TEC varchar(100)
	declare @ModalitaAnomalia_ECO varchar(100)

	set @ModalitaAnomalia_TEC = ''
	set @ModalitaAnomalia_ECO = ''

	declare @SommaTuttiRibassi decimal( 30, 10 ) 
	declare @PrimoDecimale varchar(1)

	declare @Errore as nvarchar(2000)
	declare @Fascicolo as varchar(100)

	declare @NumRibassiDistinti as int
	declare @RibassoCur as decimal( 30, 10 ) 
	declare @EstensioneAli as varchar(10)
	declare @numero_esclusione_automatica as int
	declare @statofunzionale as varchar(100)
	declare @idpfu as int
	declare @PressAgg as int
	declare @metododicalcolo varchar(150)
	declare @CalcoloAnomalia INT
	declare @OfferteAnomale INT
	declare @idpdatemp int
	set @Errore = ''
	
	--recupero data pubblicazione del bando
	select 	
		@DataInvioBando = ba.DataInvio,
		@CriterioAggiudicazioneGara = b.CriterioAggiudicazioneGara,
		@CalcoloAnomalia = b.CalcoloAnomalia,
		@OfferteAnomale = b.OffAnomale,
		@idpdatemp = o.Id,
		@metododicalcolo = b.METODO_DI_CALCOLO_ANOMALIA
			FROM Document_MicroLotti_Dettagli P with(nolock)
				inner join ctl_doc o with(nolock) on p.idheader = o.id
				inner join dbo.Document_Bando b with(nolock) on o.LinkedDoc = b.idHeader
				inner join ctl_doc ba with(nolock) on ba.id=b.idHeader
			where P.id= @IdDoc

	if ( @DataInvioBando >= '2023-07-01' and @CriterioAggiudicazioneGara = 15531 and @CalcoloAnomalia = 1 and @OfferteAnomale <> 16311 and (@metododicalcolo = '' or @metododicalcolo = 'Sorteggiato'))
	begin
		if not exists (select id from ctl_doc with(nolock) where tipodoc='CRITERIO_CALCOLO_ANOMALIA_DAL_01_07_2023' and linkeddoc=@idpdatemp and StatoFunzionale = 'Inviato' and JumpCheck='PDA_MICROLOTTI' and deleted = 0)
		begin
			set @Errore = 'Per effettuare il calcolo anomalia è necessario effettuare la  conferma sul documento Seleziona Criterio Calcolo Anomalia presente allinterno del tab Documenti'
		end
	end

	if @Errore = ''
	begin
	--PRENDE IL NUMERO DAL DOCUMENTO @iddoc corrisponde ad ID del documento VERIFICA_ANOMALIA
		IF @riesegui_calcoli = 'YES'
		BEGIN
		
			if convert( varchar(10) , @DataInvioBando , 121 ) < '2023-07-01'
			BEGIN
				select @numero_esclusione_automatica=value 
				from CTL_DOC_Value with(nolock)
				where IdHeader=@idDoc and DSE_ID='MEDIE' and DZT_Name='Parametro_esclusione_automatica' and Row=0
			END
			ELSE
			BEGIN
				--SE NON TROVA LA PROPRIETà prende il default che era fisso prima, ovvero 5 per il nuovo codice appalti 2023
			set @numero_esclusione_automatica=5
			END

			--select @numero_esclusione_automatica=value 
			--	from CTL_DOC_Value with(nolock)
			--		where IdHeader=@idDoc and DSE_ID='MEDIE' and DZT_Name='Parametro_esclusione_automatica' and Row=0
		
			Delete from CTL_DOC_Value where IdHeader=@idDoc and DSE_ID='MEDIE' and DZT_Name <> 'Parametro_esclusione_automatica' 
		
			--SETTO ID DEL DOCUMENTO VERIFICA_ANOMALIA
			set @idNew = @idDoc
		
			--valorizzo il campo per rendere compatibile la stored con id del lotto
			select  @idDoc=linkeddoc from CTL_DOC with(nolock) where Id=@idDoc

		
		END
		ELSE
		BEGIN
			if convert( varchar(10) , @DataInvioBando , 121 ) < '2023-07-01'
			BEGIN
				--SE NON TROVA LA PROPRIETà prende il default che era fisso prima, ovvero 10
				set @numero_esclusione_automatica=dbo.PARAMETRI('VERIFICA_ANOMALIA_MEDIE','Parametro_esclusione_automatica','DefaultValue',10,-1)
			END
			ELSE
			BEGIN
				--SE NON TROVA LA PROPRIETà prende il default che era fisso prima, ovvero 5 per il nuovo codice appalti 2023
			set @numero_esclusione_automatica= 5
			END
		END
	


		-- cerco una versione precedente del documento 
		set @id = null
		select @idpfu=idpfu,@id = id,@statofunzionale=statofunzionale 
			from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 
				and TipoDoc in ( 'VERIFICA_ANOMALIA' ) and statofunzionale not in ( 'Annullato' )

		--SE IDPFU non coincide con il @iduser, lo cambio sul documento con utente collegato se lui è il PresAgg
		if ( @statofunzionale = 'InLavorazione' and @riesegui_calcoli = 'NO' )
		BEGIN                    
			if ( @idpfu <> @IdUser )
			BEGIN
				select top 1 @PressAgg=PresAgg from PDA_DRILL_MICROLOTTO_TESTATA_VIEW where id=@idDoc
				if ( @PressAgg = @IdUser )
				BEGIN
					update CTL_DOC set idpfu=@IdUser where Id=@id
				END
			END
		END

	
		-- se non esiste lo creo
		if @id is null or @riesegui_calcoli = 'YES'
		begin

			------------------	Richiesta:
			-- consentire il calcolo dell’anomalia anche in presenza di fornitori ammessi con riserva e procedere  alla definizione della graduatoria 

			-- se ci sono lotti per i quali è presente un ammesso con riserva si blocca la creazione
			--if exists( 
	
			--	select l.*
			--		from Document_MicroLotti_Dettagli g
			--			inner join document_pda_offerte o on o.IdHeader = g.IdHeader
			--			inner join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
			--		where g.id = @idDoc and o.StatoPDA = '22' -- ammesso con riserva

			--	) 
			--begin 
			--	-- ritorna l'errore
			--	set @Errore = 'E'' presente un fornitore con stato ammesso con riserva. Prima di procedere e'' necessario cambiare lo stato di questo fornitore'

			--end
	
			select   @CriterioAggiudicazioneGara = c.CriterioAggiudicazioneGara
				   , @OffAnomale = c.OffAnomale
				   , @ModalitaAnomalia_TEC = isnull(c.ModalitaAnomalia_TEC,'')
				   , @ModalitaAnomalia_ECO = isnull(c.ModalitaAnomalia_ECO,'')
				   , @Fascicolo=Fascicolo 

				from Document_MicroLotti_Dettagli l with(nolock)
					inner join ctl_doc p with(nolock) on  p.id = l.IdHeader
					inner join document_bando b with(nolock) on b.idheader = p.LinkedDoc
					inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c on idBando = b.idheader and ( N_Lotto = l.NumeroLotto or N_Lotto is null ) 
				where l.id = @idDoc 

			--conto le offerte ammesse 
			select @NumAmmesse = count(*) 
				from Document_MicroLotti_Dettagli g with(nolock)
						inner join document_pda_offerte o with(nolock) on o.IdHeader = g.IdHeader
						inner join Document_MicroLotti_Dettagli l with(nolock) on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
					where g.id = @idDoc 



			if @Errore = '' and exists( 
						select id
							from Document_MicroLotti_Dettagli g with(nolock)
							where g.id = @idDoc and StatoRiga <> 'VerificaAnomalia' )

			begin
				set @Errore = 'Per aprire il documento di verifica e'' necessario prima effettuare il calcolo economico'
			end

		
		
		
			--recupero data pubblicazione del bando
			select  	
				@DataInvioBando = ba.DataInvio
				FROM 
					Document_MicroLotti_Dettagli P with(nolock)
						inner join ctl_doc o with(nolock) on p.idheader = o.id
						inner join dbo.Document_Bando b with(nolock) on o.LinkedDoc = b.idHeader
						inner join ctl_doc ba with(nolock) on ba.id=b.idHeader
				where P.id= @IdDoc

		
			set   @DataConfronto = '2016-04-18 23:59:59'
			--print @dataConfronto
		

			-- CAMBIATO CRITERIO il 2017-05-20
			--prima di una certa data e dopo un'altra data è necessario che per il calcolo al prezzo ci siano almeno 5 offerte
			if  @Errore = '' and  @NumAmmesse < 5 and @CriterioAggiudicazioneGara = '15531' 
				and (  @DataInvioBando <= @DataConfronto or  @DataInvioBando >  '2017-05-19 23:59:59' ) 
			begin
				set @Errore = 'Il numero di partecipanti non consente di effettuare il calcolo dell''anomalia'

				update Document_MicroLotti_Dettagli set Statoriga = 'AggiudicazioneProvv' where id = @idDoc  and StatoRiga = 'VerificaAnomalia' 
			end

			-----------------------------------------------
			-- se non ci sono blocchi si crea il documento 
			-----------------------------------------------
			if @Errore = ''
			begin

				declare @idBando					as int
				declare @IdPDA						as Int 
				declare @Criterio					as varchar(100)
				declare @TipoDoc					as varchar(100)
				--declare @Fascicolo					as varchar(100)
				declare @FormulaEcoSDA				as nvarchar (4000)
				declare @MAX_PunteggioTecnico		decimal( 30, 10 ) 
				declare @MAX_PunteggioEconomico		decimal( 30, 10 ) 
				declare @ValoreEconomico			decimal( 30, 10 ) 
				declare @OffertaMigliore			decimal( 30, 10 ) 
				declare @PunteggioTecMin			decimal( 30, 10 ) 
				declare @Coefficiente_X				decimal( 30, 10 ) 
				declare @NumeroDecimali				int
				declare @FieldBaseAsta				varchar(200)
				declare @FieldQuantita				varchar(200)
				declare @ListaModelliMicrolotti		as varchar(500)
				declare @FormulaEconomica			as nvarchar (4000)
				declare @NumeroLotto				varchar(200)

				-- determino il criterio di calcolo economico definito sulla gara
				select  @TipoDoc = o.TipoDoc , @Criterio = b.criterioformulazioneofferte  , @ListaModelliMicrolotti = b.TipoBando
						, @MAX_PunteggioEconomico = case when  v1.Value = '' then '0.0' else v1.value end
						, @MAX_PunteggioTecnico   = case when  v2.Value = '' then '0.0' else v2.value end 
						, @FormulaEcoSDA          = v3.value
						, @PunteggioTecMin		  = case when  v4.Value = '' then '0.0' else v4.value end
						, @Coefficiente_X		  = case when  v5.Value = '' then '0.0' else v5.value end
						, @NumeroDecimali		  = isnull( b.NumDec , 5 )
						, @IdPDA = p.idheader
						, @NumeroLotto = P.NumeroLotto
						, @idBando = o.LinkedDoc
					FROM Document_MicroLotti_Dettagli P with(nolock)
							inner join ctl_doc o with(nolock) on p.idheader = o.id
							inner join dbo.Document_Bando b with(nolock) on o.LinkedDoc = b.idHeader
							inner join CTL_DOC_VALUE  v1 with(nolock) on v1.idheader = b.idHeader and v1.DSE_ID = 'CRITERI_ECO' and  v1.DZT_Name = 'PunteggioEconomico'
							inner join CTL_DOC_VALUE  v2 with(nolock) on v2.idheader = b.idHeader and v2.DSE_ID = 'CRITERI_ECO' and  v2.DZT_Name = 'PunteggioTecnico'
							inner join CTL_DOC_VALUE  v3 with(nolock) on v3.idheader = b.idHeader and v3.DSE_ID = 'CRITERI_ECO' and  v3.DZT_Name = 'FormulaEcoSDA'
							inner join CTL_DOC_VALUE  v4 with(nolock) on v4.idheader = b.idHeader and v4.DSE_ID = 'CRITERI_ECO' and  v4.DZT_Name = 'PunteggioTecMin'
							inner join CTL_DOC_VALUE  v5 with(nolock) on v5.idheader = b.idHeader and v5.DSE_ID = 'CRITERI_ECO' and  v5.DZT_Name = 'Coefficiente_X'
						where P.id= @IdDoc

				-- prendo i criteri specializzati sul lotto se presenti
				select @MAX_PunteggioEconomico = case when PunteggioEconomico = '' then '0.0' else PunteggioEconomico end
						, @MAX_PunteggioTecnico   = case when PunteggioTecnico = '' then '0.0' else PunteggioTecnico end
						, @FormulaEcoSDA          = FormulaEcoSDA
						, @PunteggioTecMin		  = case when PunteggioTecMin = '' then '0.0' else PunteggioTecMin end
						, @Coefficiente_X		  = case when Coefficiente_X = '' then '0.0' else Coefficiente_X end
					from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and ( N_Lotto = @NumeroLotto or N_Lotto is null )

				select 
					@FormulaEconomica = FormulaEconomica , @FieldBaseAsta = FieldBaseAsta , @FieldQuantita = isnull( Quantita , '' ) 
					from 
						Document_Modelli_MicroLotti_Formula  with(nolock)
					where 
						@Criterio = CriterioFormulazioneOfferte and @ListaModelliMicrolotti = Codice


				if isnull( @OffAnomale , '' ) = '' 
					set @OffAnomale = '16310' -- 'valutazione

				-- nel caso in cui il numero di offerte ammesse è inferiore a 10 non si può fare esclusione automatica
				if @OffAnomale = '16309' and @NumAmmesse < @numero_esclusione_automatica
					set @OffAnomale = '16310' -- 'valutazione


				-- le gare economicamente vantaggiose e COSTO FISSO non prevedono l'esclusione automatica ma la valutazione
				if @CriterioAggiudicazioneGara = '15532' or @CriterioAggiudicazioneGara = '25532'
					set @OffAnomale = '16310' -- 'valutazione

			
				if @OffAnomale = '16310' -- 'valutazione
					set @StatoRiga = 'SospettoAnomalo'
				else
					set @StatoRiga = 'anomalo'
			
				if @riesegui_calcoli <> 'YES'
				BEGIN
					----------------------------------------------------
					-- creo il documento di valutazione anomalia
					----------------------------------------------------
					INSERT into CTL_DOC ( IdPfu,  TipoDoc,  Titolo , LinkedDoc , Data , DataInvio , Statofunzionale, fascicolo )
							select	@IdUser as idpfu , 'VERIFICA_ANOMALIA' as TipoDoc ,  'Verifica Anomalia '  as Titolo,  @idDoc as LinkedDoc
								,getDate() as Data , getdate() as DataInvio , 'InLavorazione' as StatoFunzionale, @fascicolo

					set @idNew = SCOPE_IDENTITY()

					--inserisco nella ctl_doc_value info @OffAnomale
					insert into CTL_DOC_Value (idheader,value,DSE_ID,DZT_Name)
							values ( @idNew,@OffAnomale,'INFO_TECNICA','OffAnomale' )
				
					--inserisco nella ctl_doc_value info @OffAnomale
					insert into CTL_DOC_Value (idheader,value,DSE_ID,DZT_Name)
							values ( @idNew,@numero_esclusione_automatica,'MEDIE','Parametro_esclusione_automatica' )


					-- riporto tutte le offerte ammesse legate al lotto
					insert into Document_Verifica_Anomalia ( idHeader, aziRagioneSociale, id_rowLottoOff, id_rowOffPDA, PunteggioTecnico, PunteggioEconomico, PunteggioTotale ,Ribasso , RibassoAssoluto ) 
						select @idNew as idHeader, o.aziRagioneSociale, l.id as id_rowLottoOff, o.IdRow as id_rowOffPDA, 
									 l.PunteggioTecnico, case when isnull( l.ValoreOfferta , 0 ) - isnull( l.PunteggioTecnico , 0 ) < 0 then null else isnull( l.ValoreOfferta , 0 ) - isnull( l.PunteggioTecnico , 0 ) end as PunteggioEconomico,
									  isnull( l.ValoreOfferta , 0 ) as PunteggioTotale ,l.ValoreSconto as Ribasso , l.ValoreRibasso as RibassoAssoluto
							from Document_MicroLotti_Dettagli g with(nolock) 
									inner join document_pda_offerte o with(nolock) on o.IdHeader = g.IdHeader
									inner join Document_MicroLotti_Dettagli l with(nolock) on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso' , 'anomalo' , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
								where g.id = @idDoc 
								order by L.Graduatoria , L.Sorteggio

				END
				ELSE
				BEGIN
					delete from Document_Verifica_Anomalia where idHeader=@idNew
					-- riporto tutte le offerte ammesse legate al lotto
					insert into Document_Verifica_Anomalia ( idHeader, aziRagioneSociale, id_rowLottoOff, id_rowOffPDA, PunteggioTecnico, PunteggioEconomico, PunteggioTotale ,Ribasso , RibassoAssoluto ) 
						select @idNew as idHeader, o.aziRagioneSociale, l.id as id_rowLottoOff, o.IdRow as id_rowOffPDA, 
									 l.PunteggioTecnico, case when isnull( l.ValoreOfferta , 0 ) - isnull( l.PunteggioTecnico , 0 ) < 0 then null else isnull( l.ValoreOfferta , 0 ) - isnull( l.PunteggioTecnico , 0 ) end as PunteggioEconomico,
									  isnull( l.ValoreOfferta , 0 ) as PunteggioTotale ,l.ValoreSconto as Ribasso , l.ValoreRibasso as RibassoAssoluto
							from Document_MicroLotti_Dettagli g with(nolock)
									inner join document_pda_offerte o with(nolock) on o.IdHeader = g.IdHeader
									inner join Document_MicroLotti_Dettagli l with(nolock) on l.IdHeader = o.IdRow and l.Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'esclusoEco' ,'escluso'  , 'decaduta' , 'NonConforme' )  and g.NumeroLotto = l.NumeroLotto 
								where g.id = @idDoc 
								order by L.Graduatoria , L.Sorteggio
				END
				------------------------------------
				-- ESEGUO I CALCOLI 
				------------------------------------
				if @CriterioAggiudicazioneGara = '15532' or @CriterioAggiudicazioneGara = '25532' -- economicamente vantaggiosa o costo fisso
				begin

					IF @ModalitaAnomalia_TEC = 'ante_riparametrazione'
					BEGIN

						-- sovrascrivo la colonna PunteggioTecnico
						-- con il dato ANTE riparametrazione 
						-- isnull( PunteggioOriginale , Punteggio ) 
						-- in group by per lotto

						update Document_Verifica_Anomalia 
							set PunteggioTecnico = punteggioTecAnteRiparam 
							from Document_Verifica_Anomalia 

								inner join ( 
									select id_rowLottoOff  as idLotto, sum( isnull( PunteggioOriginale , Punteggio ) )  as punteggioTecAnteRiparam 
										from Document_Verifica_Anomalia v
											inner join Document_Microlotto_PunteggioLotto pl on pl.idHeaderLottoOff =v.id_rowLottoOff
										where  v.idHeader = @idNew 
										group by  id_rowLottoOff

								) as v on id_rowLottoOff = idLotto
							where  idHeader = @idNew

					END

					IF @ModalitaAnomalia_ECO = 'ante_riparametrazione'
					BEGIN

						-- sovrascrivo la colonna PunteggioEconomico
						-- con il dato ANTE riparametrazione 
						-- isnull( PunteggioOriginale , Punteggio ) 
						-- in group by per lotto

						update Document_Verifica_Anomalia 
							set PunteggioEconomico = punteggioTecAnteRiparam 
							from Document_Verifica_Anomalia 

								inner join ( 
									select id_rowLottoOff  as idLotto, sum( isnull( PunteggioOriginale , Punteggio ) )  as punteggioTecAnteRiparam 
										from Document_Verifica_Anomalia v
											inner join Document_Microlotto_PunteggioLotto_ECO pl on pl.idHeaderLottoOff =v.id_rowLottoOff
										where  v.idHeader = @idNew 
										group by  id_rowLottoOff

								) as v on id_rowLottoOff = idLotto
							where  idHeader = @idNew

					END


					-- tutte le offerte che superano come punteggio tecnico ed economico i 4/5 dei punteggi inidcati sul bando sono anomale
					--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
					--	where id in (
					--		select id_rowLottoOff
					--			from Document_Verifica_Anomalia
					--			where idheader = @idNew and PunteggioTecnico >=  ( 4.0 / 5.0 ) * @MAX_PunteggioTecnico  and PunteggioEconomico >=   ( 4.0 / 5.0 ) * @MAX_PunteggioEconomico 
					--	)


					-- riporto sulla tabella del calcolo anomalia lo stato della riga
					update Document_Verifica_Anomalia 
							set StatoAnomalia=@StatoRiga,
							Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
						where idheader = @idNew and PunteggioTecnico >=  ( 4.0 / 5.0 ) * @MAX_PunteggioTecnico  and PunteggioEconomico >=   ( 4.0 / 5.0 ) * @MAX_PunteggioEconomico 


					-- salviamo collegato al documento i valori utilizzati per i calcoli
					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'SogliaPunteggioTecnico' ,  ( 4.0 / 5.0 ) * @MAX_PunteggioTecnico  )

					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'SogliaPunteggioEconomico' ,  ( 4.0 / 5.0 ) * @MAX_PunteggioEconomico )

					-- salviamo collegato al documento i valori utilizzati per i calcoli
					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'PunteggioTecnico' , @MAX_PunteggioTecnico )

					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'PunteggioEconomico' , @MAX_PunteggioEconomico  )

					-- salviamo collegato al documento i valori utilizzati per i calcoli
					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'ModalitaAnomalia_TEC' , @ModalitaAnomalia_TEC )

					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'ModalitaAnomalia_ECO' , @ModalitaAnomalia_ECO  )

					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , '@idBando' , @idBando  )

					insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , '@@idNew' , @idNew  )

					IF EXISTS(SELECT * FROM DOCUMENT_BANDO WHERE IDHEADER = @idBando AND METODO_DI_CALCOLO_ANOMALIA = 'Metodo 4/5')
					BEGIN
						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'METODO_DI_CALCOLO_ANOMALIA' , 'Metodo 4/5' )
					END
				end
				else
				---------------------------------------------------------------------------------------
				-- AL PREZZO
				---------------------------------------------------------------------------------------
				begin

					declare @Algoritmo varchar(100)
					declare @Coefficiente varchar(50)
					declare @idDocAlgoritmo int

					select @idDocAlgoritmo = ID from CTL_DOC with(nolock) where linkeddoc = @IdPDA and tipodoc = 'CRITERIO_CALCOLO_ANOMALIA' and JumpCheck = 'PDA_MICROLOTTI'

					-- cerca l'algoritmo selezionato 
					select @Algoritmo = RIGHT( dzt_name , 1 ) from CTL_DOC_VALUE with(nolock) where idheader = @idDocAlgoritmo AND DSE_ID = 'CRITERI'  AND VALUE = '1' AND DZT_Name LIKE 'check_criterio%'
					select @Coefficiente = replace(  Value , ',' , '.' ) from CTL_DOC_VALUE with(nolock) where idheader = @idDocAlgoritmo AND DSE_ID = 'CRITERI'  AND DZT_Name = 'Coefficiente_Scelta_Criterio'

				
					-- se non trovo un algoritmo seleziono per default la A
					IF isnull( @Algoritmo , '' ) = '' 
						set @Algoritmo = 'A'


					-- verificare se per le nuove gare nel caso in cui non trovo il criterio devo bloccare il calcolo
				 

					---------------------------------------------------------------------------------------
					-- Calcoli effettuati fino al 2017-05-20
					---------------------------------------------------------------------------------------

					if convert( varchar(10) , @DataInvioBando , 121 ) < '2017-05-20'
					begin


						IF @Algoritmo = 'A'
						BEGIN
								---------------------------------------------------------------------------------------
								-- CRITERIO PRECEDENTE 
								---------------------------------------------------------------------------------------
								-- 2.	Si calcola il dieci per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.

								if @NumAmmesse % 10 > 0 
									set @NumAli = floor( @NumAmmesse / 10 ) + 1
								else
									set @NumAli =  @NumAmmesse / 10 


								--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
								declare CurProg Cursor static for 
									Select idRow from Document_Verifica_Anomalia 	
										where idHeader=@idNew 
									order by IdRow
			
								open CurProg

								set @i = 1
								FETCH NEXT FROM CurProg INTO @idrow
								WHILE @@FETCH_STATUS = 0
								BEGIN

									--
									if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
										update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

									set @i = @i + 1 
									FETCH NEXT FROM CurProg INTO @idrow
								END 
								CLOSE CurProg
								DEALLOCATE CurProg

								-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
								update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
										where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
												and Ribasso in ( 
													select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
												)



								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
									--set @MediaRibassi = @MediaRibassi  /  cast( ( @NumAmmesse - @NumAli - @NumAli ) as float)
								end
								else
								begin
									set @MediaRibassi = 0 
									set @OfferteUtili = 'NO'
								end

								--set @MediaRibassi =  @MediaRibassi 

								--5.	Si considerano solo le offerte la cui percentuale di ribasso è superiore alla media ottenuta allo Step 4.
								--6.	Si calcola lo scarto dei ribassi dello Step 5 rispetto alla media dello Step 4.
								update Document_Verifica_Anomalia set ScartoAritmetico = Ribasso - @MediaRibassi 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi

								--7.	Si calcola la media aritmetica degli scarti, ovvero si fa la somma degli scarti calcolati allo Step 6 e si divide il risultato per il N° Offerte non escluse (cd. scarto aritmetico medio).
								select @MediaScarti  = sum( ScartoAritmetico ) / cast( count(*) as float)
										from Document_Verifica_Anomalia 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi
				
								set @MediaScarti = isnull( @MediaScarti , 0 )
								set @MediaScarti =  @MediaScarti 


								--8.	Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
								set @SogliaAnomalia = @MediaScarti + @MediaRibassi

								if @OfferteUtili = 'SI'
								begin

									--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
									--	where id in (
									--		select id_rowLottoOff
									--			from Document_Verifica_Anomalia
									--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
									--	)

									-- riporto sulla tabella del calcolo anomalia lo stato della riga
									update Document_Verifica_Anomalia 
											set StatoAnomalia=@StatoRiga,
											Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
										where  idheader = @idNew and Ribasso >= @SogliaAnomalia
						
								end
								else
								begin
									-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
									insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
								end

								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaScarti' , @MediaScarti )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )

						END


						-----------------------------------------------------------------------------------------
						---- B 
						-----------------------------------------------------------------------------------------
						IF @Algoritmo = 'B'
						BEGIN


							-- 2.	Si calcola il dieci per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.
								if @NumAmmesse % 10 > 0 
									set @NumAli = floor( @NumAmmesse / 10 ) + 1
								else
									set @NumAli =  @NumAmmesse / 10 

								--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
								declare CurProg Cursor static for 
									Select idRow from Document_Verifica_Anomalia 	
										where idHeader=@idNew 
									order by IdRow
			
								open CurProg

								set @i = 1
								FETCH NEXT FROM CurProg INTO @idrow
								WHILE @@FETCH_STATUS = 0
								BEGIN

									--
									if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
										update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

									set @i = @i + 1 
									FETCH NEXT FROM CurProg INTO @idrow
								END 
								CLOSE CurProg
								DEALLOCATE CurProg

								-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
								update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
										where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
												and Ribasso in ( 
													select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
												)



								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
									--set @MediaRibassi = @MediaRibassi  /  cast( ( @NumAmmesse - @NumAli - @NumAli ) as float)
								end
								else
								begin
									set @MediaRibassi = 0 
									set @OfferteUtili = 'NO'
								end


								--declare @SommaTuttiRibassi float
								--declare @PrimoDecimale varchar(1)
								select @SommaTuttiRibassi = sum ( Ribasso )  from Document_Verifica_Anomalia where idheader = @idNew
						
								-- recupero la prima cifra dopo la virgola, della somma dei ribassi offerti dai concorrenti ammessi 
								set @PrimoDecimale = left( dbo.GetPos( str( @SommaTuttiRibassi  , 10,10 ) , '.' , 2 )  , 1 ) 


								set @SogliaAnomalia =  @MediaRibassi
						
								-- se la cifra è dispari
								if charindex( @PrimoDecimale , '13579' ) > 0 
									set @SogliaAnomalia = @MediaRibassi - ( ( @MediaRibassi * cast(  @PrimoDecimale as float ) ) / 100.0 )



								if @OfferteUtili = 'SI'
								begin

									--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
									--	where id in (
									--		select id_rowLottoOff
									--			from Document_Verifica_Anomalia
									--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
									--	)

									-- riporto sulla tabella del calcolo anomalia lo stato della riga
									update Document_Verifica_Anomalia 
											set StatoAnomalia=@StatoRiga,
											Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
										where  idheader = @idNew and Ribasso >= @SogliaAnomalia

								end
								else
								begin
									-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
									insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
								end



								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'PrimoDecimale' , @PrimoDecimale )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )





						END

							-----------------------------------------------------------------------------------------
							----  C
							-----------------------------------------------------------------------------------------
							if @Algoritmo = 'C'
							begin



								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow  from Document_Verifica_Anomalia where    idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
								end
								else
									set @MediaRibassi = 0 

	
								set @SogliaAnomalia = @MediaRibassi + ( ( @MediaRibassi * 20.0 ) / 100.0 )
						
						


								--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
								--	where id in (
								--		select id_rowLottoOff
								--			from Document_Verifica_Anomalia
								--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
								--	)

								-- riporto sulla tabella del calcolo anomalia lo stato della riga
								update Document_Verifica_Anomalia 
										set StatoAnomalia=@StatoRiga,
										Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
									where  idheader = @idNew and Ribasso >= @SogliaAnomalia


								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )



								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )





							end


							-----------------------------------------------------------------------------------------
							---- D 
							-----------------------------------------------------------------------------------------
							if @Algoritmo = 'D'
							begin


								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow  from Document_Verifica_Anomalia where    idheader = @idNew )
								begin
									select @MediaRibassi = sum ( RibassoAssoluto ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
								end
								else
									set @MediaRibassi = 0 

	
								set @SogliaAnomalia = @MediaRibassi - ( ( @MediaRibassi * 20.0 ) / 100.0 )
						
						


								--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
								--	where id in (
								--		select id_rowLottoOff
								--			from Document_Verifica_Anomalia
								--			where  idheader = @idNew and RibassoAssoluto >= @SogliaAnomalia
								--	)

								-- riporto sulla tabella del calcolo anomalia lo stato della riga
								update Document_Verifica_Anomalia 
										set StatoAnomalia=@StatoRiga,
										Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
									where  idheader = @idNew and RibassoAssoluto >= @SogliaAnomalia


								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )



								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )





							end



							-----------------------------------------------------------------------------------------
							---- E 
							-----------------------------------------------------------------------------------------
							if @Algoritmo = 'E'
							begin

								-- 2.	Si calcola il dieci per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.

								if @NumAmmesse % 10 > 0 
									set @NumAli = floor( @NumAmmesse / 10 ) + 1
								else
									set @NumAli =  @NumAmmesse / 10 


								--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
								declare CurProg Cursor static for 
									Select idRow from Document_Verifica_Anomalia 	
										where idHeader=@idNew 
									order by IdRow
			
								open CurProg

								set @i = 1
								FETCH NEXT FROM CurProg INTO @idrow
								WHILE @@FETCH_STATUS = 0
								BEGIN

									--
									if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
										update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

									set @i = @i + 1 
									FETCH NEXT FROM CurProg INTO @idrow
								END 
								CLOSE CurProg
								DEALLOCATE CurProg

								-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
								update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
										where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
												and Ribasso in ( 
													select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
												)



								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idrow from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
									--set @MediaRibassi = @MediaRibassi  /  cast( ( @NumAmmesse - @NumAli - @NumAli ) as float)
								end
								else
								begin
									set @MediaRibassi = 0 
									set @OfferteUtili = 'NO'
								end


								set @MediaRibassi =  @MediaRibassi 

								--5.	Si considerano solo le offerte la cui percentuale di ribasso è superiore alla media ottenuta allo Step 4.
								--6.	Si calcola lo scarto dei ribassi dello Step 5 rispetto alla media dello Step 4.
								update Document_Verifica_Anomalia set ScartoAritmetico = Ribasso - @MediaRibassi 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi

								--7.	Si calcola la media aritmetica degli scarti, ovvero si fa la somma degli scarti calcolati allo Step 6 e si divide il risultato per il N° Offerte non escluse (cd. scarto aritmetico medio).
								select @MediaScarti  = sum( ScartoAritmetico ) / cast( count(*) as float)
										from Document_Verifica_Anomalia 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi
				
								set @MediaScarti = isnull( @MediaScarti , 0 )
								set @MediaScarti =  @MediaScarti 

								--9 moltiplica la soglia di anomalia del coefficiente sorteggiato
								set @MediaScarti =  @MediaScarti * cast( @Coefficiente as float ) 

								--8.	Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
								set @SogliaAnomalia = @MediaScarti + @MediaRibassi



								if @OfferteUtili = 'SI'
								begin

									--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
									--	where id in (
									--		select id_rowLottoOff
									--			from Document_Verifica_Anomalia
									--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
									--	)

									-- riporto sulla tabella del calcolo anomalia lo stato della riga
									update Document_Verifica_Anomalia 
											set StatoAnomalia=@StatoRiga,
											Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
										where  idheader = @idNew and Ribasso >= @SogliaAnomalia
								end
								else
								begin
									-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
									insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
								end


								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaScarti' , @MediaScarti )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )

						end

			
			

					end
					else
					if convert( varchar(10) , @DataInvioBando , 121 ) < '2019-04-19'
					begin 

						---------------------------------------------------------------------------------------
						-- NUOVI ALGORITMI VECCHI - PARTENDO DALLA DATA 22-05-2017 fino al 2019-04-19
						---------------------------------------------------------------------------------------

						 --recupero proprieta che stabilisce estensione delle ali per le offerte a parità di soglia

						select @EstensioneAli = dbo.PARAMETRI ('VERIFICA_ANOMALIA_CREATE_FROM_LOTTO','EstensioneAli','','NO',-1)

						IF @Algoritmo = 'A' 
						BEGIN
								---------------------------------------------------------------------------------------
								-- CRITERIO PRECEDENTE 
								---------------------------------------------------------------------------------------
								-- CAMBIATO CRITERIO il 2017-05-20
								-- 2.	Si calcola il venti per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.

								if @NumAmmesse % 5 > 0 
									set @NumAli = floor( @NumAmmesse / 5 ) + 1
								else
									set @NumAli =  @NumAmmesse / 5 
								-- FINE cambio


								if @EstensioneAli ='NO'
								begin

									--3.	Si escludono il 20% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
									declare CurProg Cursor static for 
										Select idRow from Document_Verifica_Anomalia 	
											where idHeader=@idNew 
										order by IdRow
			
									open CurProg

									set @i = 1
									FETCH NEXT FROM CurProg INTO @idrow
									WHILE @@FETCH_STATUS = 0
									BEGIN

										--
										if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
											update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

										set @i = @i + 1 
										FETCH NEXT FROM CurProg INTO @idrow
									END 
									CLOSE CurProg
									DEALLOCATE CurProg

									-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
									update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
											where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
													and Ribasso in ( 
														select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
													)
								end
								else
								begin
								
									 --3.	Si escludono il 20% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
							    
									Select @NumRibassiDistinti=count(*) from 
										( select distinct Ribasso 
											  from 
												 Document_Verifica_Anomalia 	
											  where idHeader=@idNew 
										) A
							    
									declare CurProg Cursor static for 
										Select distinct Ribasso from Document_Verifica_Anomalia 	
											where idHeader=@idNew 
										order by Ribasso
			
									open CurProg

									set @i = 1
									FETCH NEXT FROM CurProg INTO @RibassoCur
									WHILE @@FETCH_STATUS = 0
									BEGIN

										--
										if @i <= @NumAli or @i > @NumRibassiDistinti - @NumAli 
											update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idHeader=@idNew  and dbo.AFS_ROUND(Ribasso,10) = @RibassoCur             

										set @i = @i + 1 
										FETCH NEXT FROM CurProg INTO @RibassoCur
									END 
									CLOSE CurProg
									DEALLOCATE CurProg

								end 
							 

								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
									--set @MediaRibassi = @MediaRibassi  /  cast( ( @NumAmmesse - @NumAli - @NumAli ) as float)
								end
								else
								begin
									set @MediaRibassi = 0 
									set @OfferteUtili = 'NO'
								end

								--set @MediaRibassi =  @MediaRibassi 

								--5.	Si considerano solo le offerte la cui percentuale di ribasso è superiore alla media ottenuta allo Step 4.
								--6.	Si calcola lo scarto dei ribassi dello Step 5 rispetto alla media dello Step 4.
								update Document_Verifica_Anomalia set ScartoAritmetico = Ribasso - @MediaRibassi 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi

								--7.	Si calcola la media aritmetica degli scarti, ovvero si fa la somma degli scarti calcolati allo Step 6 e si divide il risultato per il N° Offerte non escluse (cd. scarto aritmetico medio).
								select @MediaScarti  = sum( ScartoAritmetico ) / cast( count(*) as float)
										from Document_Verifica_Anomalia 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi
				
								set @MediaScarti = isnull( @MediaScarti , 0 )
								set @MediaScarti =  @MediaScarti 


								--8.	Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
								set @SogliaAnomalia = @MediaScarti + @MediaRibassi

								if @OfferteUtili = 'SI'
								begin

									--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
									--	where id in (
									--		select id_rowLottoOff
									--			from Document_Verifica_Anomalia
									--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
									--	)

									-- riporto sulla tabella del calcolo anomalia lo stato della riga
									update Document_Verifica_Anomalia 
											set StatoAnomalia=@StatoRiga,
											Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
										where  idheader = @idNew and Ribasso >= @SogliaAnomalia
						
								end
								else
								begin
									-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
									insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
								end

								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaScarti' , @MediaScarti )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )

						END


						-----------------------------------------------------------------------------------------
						---- B 
						-----------------------------------------------------------------------------------------
						IF @Algoritmo = 'B'
						BEGIN
							declare @RibassiConAli varchar(100)
							select @RibassiConAli = dbo.PARAMETRI ('VERIFICA_ANOMALIA_CREATE_FROM_LOTTO','RibassiConAli','DefaultValue','YES',-1)


							-- CAMBIATO CRITERIO il 2017-05-20
							-- 2.	Si calcola il venti per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.
								if @NumAmmesse % 5 > 0 
									set @NumAli = floor( @NumAmmesse / 5 ) + 1
								else
									set @NumAli =  @NumAmmesse / 5 

							-- Fine cambio
							
								if @EstensioneAli ='NO'
								begin
							 
									--3.	Si escludono il 20% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
									declare CurProg Cursor static for 
										Select idRow from Document_Verifica_Anomalia 	
											where idHeader=@idNew 
										order by IdRow
			
									open CurProg

									set @i = 1
									FETCH NEXT FROM CurProg INTO @idrow
									WHILE @@FETCH_STATUS = 0
									BEGIN

										--
										if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
											update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

										set @i = @i + 1 
										FETCH NEXT FROM CurProg INTO @idrow
									END 
									CLOSE CurProg
									DEALLOCATE CurProg

									-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
									update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
											where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
													and Ribasso in ( 
														select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
													)

							 
								end
								else
								begin
								
									 --3.	Si escludono il 20% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
									Select @NumRibassiDistinti=count(*) from 
										( select distinct Ribasso 
											  from 
												 Document_Verifica_Anomalia 	
											  where idHeader=@idNew 
										) A
							    
									declare CurProg Cursor static for 
										Select distinct Ribasso from Document_Verifica_Anomalia 	
											where idHeader=@idNew 
										order by Ribasso
			
									open CurProg

									set @i = 1
									FETCH NEXT FROM CurProg INTO @RibassoCur
									WHILE @@FETCH_STATUS = 0
									BEGIN

										--
										if @i <= @NumAli or @i > @NumRibassiDistinti - @NumAli 
											update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idHeader=@idNew  and dbo.AFS_ROUND(ribasso,10) = @RibassoCur             

										set @i = @i + 1 
										FETCH NEXT FROM CurProg INTO @RibassoCur
									END 
									CLOSE CurProg
									DEALLOCATE CurProg

								end 

								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
									--set @MediaRibassi = @MediaRibassi  /  cast( ( @NumAmmesse - @NumAli - @NumAli ) as float)
								end
								else
								begin
									set @MediaRibassi = 0 
									set @OfferteUtili = 'NO'
								end


								--declare @SommaTuttiRibassi float
								--declare @PrimoDecimale varchar(1)
								select @SommaTuttiRibassi = sum ( Ribasso )  
									from Document_Verifica_Anomalia 
									where idheader = @idNew and 
										( 
											isnull( TaglioAli , '' ) <> 'Ali' 
											or
											@RibassiConAli = 'YES'
										)
						
								-- recupero la prima cifra dopo la virgola, della somma dei ribassi offerti dai concorrenti ammessi 
								set @PrimoDecimale = left( dbo.GetPos( str( @SommaTuttiRibassi  , 10,10 ) , '.' , 2 )  , 1 ) 


								set @SogliaAnomalia =  @MediaRibassi
						
								-- se la cifra è dispari
								if charindex( @PrimoDecimale , '13579' ) > 0 
									set @SogliaAnomalia = @MediaRibassi - ( ( @MediaRibassi * cast(  @PrimoDecimale as float ) ) / 100.0 )



								if @OfferteUtili = 'SI'
								begin

									--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
									--	where id in (
									--		select id_rowLottoOff
									--			from Document_Verifica_Anomalia
									--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
									--	)

									-- riporto sulla tabella del calcolo anomalia lo stato della riga
									update Document_Verifica_Anomalia 
											set StatoAnomalia=@StatoRiga,
											Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
										where  idheader = @idNew and Ribasso >= @SogliaAnomalia

								end
								else
								begin
									-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
									insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
								end



								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'PrimoDecimale' , @PrimoDecimale )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )





						END

							-----------------------------------------------------------------------------------------
							----  C
							-----------------------------------------------------------------------------------------
							if @Algoritmo = 'C'
							begin



								--4.	Si calcola la media aritmetica dei ribassi percentuali delle offerte ammesse
				
								IF exists( select idRow from Document_Verifica_Anomalia where    idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
								end
								else
									set @MediaRibassi = 0 

								-- CAMBIATO CRITERIO il 2017-05-20
								set @SogliaAnomalia = @MediaRibassi + ( ( @MediaRibassi * 15.0 ) / 100.0 )
								-- Fine cambio
						


								--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
								--	where id in (
								--		select id_rowLottoOff
								--			from Document_Verifica_Anomalia
								--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
								--	)

								-- riporto sulla tabella del calcolo anomalia lo stato della riga
								update Document_Verifica_Anomalia 
										set StatoAnomalia=@StatoRiga,
										Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
									where  idheader = @idNew and Ribasso >= @SogliaAnomalia


								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )



								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )





							end


							-----------------------------------------------------------------------------------------
							---- D 
							-----------------------------------------------------------------------------------------
							if @Algoritmo = 'D'
							begin
								-- CAMBIATO CRITERIO il 2017-05-20 ( è identico al C cambia solo la percentuale dal 15 al 10 )
								--4.	Si calcola la media aritmetica dei ribassi percentuali delle offerte ammesse
				
								IF exists( select idRow from Document_Verifica_Anomalia where    idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
								end
								else
									set @MediaRibassi = 0 

							
								set @SogliaAnomalia = @MediaRibassi + ( ( @MediaRibassi * 10.0 ) / 100.0 )
						


								--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
								--	where id in (
								--		select id_rowLottoOff
								--			from Document_Verifica_Anomalia
								--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
								--	)

								-- riporto sulla tabella del calcolo anomalia lo stato della riga
								update Document_Verifica_Anomalia 
										set StatoAnomalia=@StatoRiga,
										Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
									where  idheader = @idNew and Ribasso >= @SogliaAnomalia


								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )



								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )



								-- Fine cambio


							end



							-----------------------------------------------------------------------------------------
							---- E 
							-----------------------------------------------------------------------------------------
							if @Algoritmo = 'E'
							begin

								-- 2.	Si calcola il dieci per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.

								if @NumAmmesse % 10 > 0 
									set @NumAli = floor( @NumAmmesse / 10 ) + 1
								else
									set @NumAli =  @NumAmmesse / 10 

								if @EstensioneAli ='NO'
								begin
							 
									--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
									declare CurProg Cursor static for 
										Select idRow from Document_Verifica_Anomalia 	
											where idHeader=@idNew 
										order by IdRow
			
									open CurProg

									set @i = 1
									FETCH NEXT FROM CurProg INTO @idrow
									WHILE @@FETCH_STATUS = 0
									BEGIN

										--
										if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
											update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

										set @i = @i + 1 
										FETCH NEXT FROM CurProg INTO @idrow
									END 
									CLOSE CurProg
									DEALLOCATE CurProg

									-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
									update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
											where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
													and Ribasso in ( 
														select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
													)

								 end
								else
								begin
								
									 --3.	Si escludono il 20% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
									Select @NumRibassiDistinti=count(*) from 
										( select distinct Ribasso 
											  from 
												 Document_Verifica_Anomalia 	
											  where idHeader=@idNew 
										) A
							    
									declare CurProg Cursor static for 
										Select distinct Ribasso from Document_Verifica_Anomalia 	
											where idHeader=@idNew 
										order by Ribasso
			
									open CurProg

									set @i = 1
									FETCH NEXT FROM CurProg INTO @RibassoCur
									WHILE @@FETCH_STATUS = 0
									BEGIN

										--
										if @i <= @NumAli or @i > @NumRibassiDistinti - @NumAli 
											update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idHeader=@idNew  and dbo.AFS_ROUND(ribasso,10) = @RibassoCur             

										set @i = @i + 1 
										FETCH NEXT FROM CurProg INTO @RibassoCur
									END 
									CLOSE CurProg
									DEALLOCATE CurProg

								end 

								--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
								IF exists( select idRow from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
								begin
									select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as float)  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
									--set @MediaRibassi = @MediaRibassi  /  cast( ( @NumAmmesse - @NumAli - @NumAli ) as float)
								end
								else
								begin
									set @MediaRibassi = 0 
									set @OfferteUtili = 'NO'
								end


								set @MediaRibassi =  @MediaRibassi 

								--5.	Si considerano solo le offerte la cui percentuale di ribasso è superiore alla media ottenuta allo Step 4.
								--6.	Si calcola lo scarto dei ribassi dello Step 5 rispetto alla media dello Step 4.
								update Document_Verifica_Anomalia set ScartoAritmetico = Ribasso - @MediaRibassi 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi

								--7.	Si calcola la media aritmetica degli scarti, ovvero si fa la somma degli scarti calcolati allo Step 6 e si divide il risultato per il N° Offerte non escluse (cd. scarto aritmetico medio).
								select @MediaScarti  = sum( ScartoAritmetico ) / cast( count(*) as float)
										from Document_Verifica_Anomalia 
										where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi
				
								set @MediaScarti = isnull( @MediaScarti , 0 )
								set @MediaScarti =  @MediaScarti 

								--9 moltiplica la soglia di anomalia del coefficiente sorteggiato
								set @MediaScarti =  @MediaScarti * cast( @Coefficiente as float ) 

								--8.	Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
								set @SogliaAnomalia = @MediaScarti + @MediaRibassi



								if @OfferteUtili = 'SI'
								begin

									--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
									--	where id in (
									--		select id_rowLottoOff
									--			from Document_Verifica_Anomalia
									--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
									--	)

									-- riporto sulla tabella del calcolo anomalia lo stato della riga
									update Document_Verifica_Anomalia 
											set StatoAnomalia=@StatoRiga,
											Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
										where  idheader = @idNew and Ribasso >= @SogliaAnomalia
								end
								else
								begin
									-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
									insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
								end


								-- salviamo collegato al documento i valori utilizzati per i calcoli
								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'MediaScarti' , @MediaScarti )

								insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
										values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )

						end
					end
					else if convert( varchar(10) , @DataInvioBando , 121 ) < '2023-07-01' or EXISTS(SELECT * FROM DOCUMENT_BANDO WHERE IDHEADER = @idBando AND METODO_DI_CALCOLO_ANOMALIA = 'Metodo 4/5')
					begin

						--IF EXISTS(SELECT * FROM DOCUMENT_BANDO WHERE IDHEADER = @idNew AND METODO_DI_CALCOLO_ANOMALIA = 'Metodo 4/5')
						--BEGIN
						--	insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
						--		values( @idNew , 'MEDIE'  , 0 , 'METODO_DI_CALCOLO_ANOMALIA' , 'Metodo 4/5' )
						--END

						---------------------------------------------------------------------------------------
						-- NUOVI ALGORITMI - PARTENDO DALLA DATA DI INVIO DEL BANDO 2019-04-19 DL 32/2019
						---------------------------------------------------------------------------------------



						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------


						-- 2. Si calcola il dieci per cento del numero delle offerte ammesse e si arrotonda il risultato all'unità superiore.
						if @NumAmmesse % 10 > 0 
							set @NumAli = floor( @NumAmmesse / 10 ) + 1
						else
							set @NumAli =  @NumAmmesse / 10 


						set @EstensioneAli ='SI'
						-- recupero dalla gara se considerare nelle ali le offerte con egual ribasso una volta sola anziche distinte
						if exists( select value from ctl_DOC_VALUE with(nolock) where idheader = @idBando and dzt_name = 'EstensioneAli' and DSE_ID = 'CRITERI_ECO' ) 
							select @EstensioneAli = value from ctl_DOC_VALUE with(nolock) where idheader = @idBando and dzt_name = 'EstensioneAli' and DSE_ID = 'CRITERI_ECO'
						else
							select @EstensioneAli = dbo.PARAMETRI ('BANDO_SEMPLIFICATO_CRITERI_ECO','EstensioneAli','DefaultValue','SI',-1)


						if @EstensioneAli ='NO'
						begin


							--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
							declare CurProg Cursor static for 
								Select idRow from Document_Verifica_Anomalia 	
									where idHeader=@idNew 
								order by IdRow
			
							open CurProg

							set @i = 1
							FETCH NEXT FROM CurProg INTO @idrow
							WHILE @@FETCH_STATUS = 0
							BEGIN

								--
								if @i <= @NumAli or @i > @NumAmmesse - @NumAli 
									update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idRow = @idrow             

								set @i = @i + 1 
								FETCH NEXT FROM CurProg INTO @idrow
							END 
							CLOSE CurProg
							DEALLOCATE CurProg


						end
						else
						begin



							Select @NumRibassiDistinti=count(*) from 
								( select distinct Ribasso 
										from 
											Document_Verifica_Anomalia 	
										where idHeader=@idNew 
								) A
							    
							--3.	Si escludono il 10% (appena calcolato) delle offerte più basse e più alte (taglio delle ali).
							declare CurProg Cursor static for 
								Select distinct Ribasso from Document_Verifica_Anomalia 	
									where idHeader=@idNew 
								order by Ribasso
			
							open CurProg

							set @i = 1
							FETCH NEXT FROM CurProg INTO @RibassoCur
							WHILE @@FETCH_STATUS = 0
							BEGIN

								--
								if @i <= @NumAli or @i > @NumRibassiDistinti - @NumAli 
									update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  where idHeader=@idNew  and dbo.AFS_ROUND(ribasso,10) = @RibassoCur             

								set @i = @i + 1 
								FETCH NEXT FROM CurProg INTO @RibassoCur
							END 
							CLOSE CurProg
							DEALLOCATE CurProg

						end




						-- alle ali si aggungono tutte le offerte che hanno presenta un ribasso uguale a quelle delle ali
						update Document_Verifica_Anomalia  set TaglioAli = 'Ali'  
								where  idheader = @idNew and isnull( TaglioAli , '' ) <> 'Ali' 
										and Ribasso in ( 
											select Ribasso from Document_Verifica_Anomalia where  idheader = @idNew and isnull( TaglioAli , '' ) = 'Ali'
										)



						--4.	Si calcola la media aritmetica dei ribassi delle offerte che restano dopo il taglio delle ali.
				
						IF exists( select idRow from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew )
						begin
							select @MediaRibassi = sum ( Ribasso ) / cast( count(*) as decimal( 30, 10 ) )  from Document_Verifica_Anomalia where  isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew
						end
						else
						begin
							set @MediaRibassi = 0 
							set @OfferteUtili = 'NO'
						end

						--set @MediaRibassi =  @MediaRibassi 

						--5.	Si considerano solo le offerte la cui percentuale di ribasso è superiore alla media ottenuta allo Step 4.
						--6.	Si calcola lo scarto dei ribassi dello Step 5 rispetto alla media dello Step 4.
						update Document_Verifica_Anomalia set ScartoAritmetico = Ribasso - @MediaRibassi 
								where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi

						
						select @SommaTuttiRibassi = sum ( Ribasso )  
							from Document_Verifica_Anomalia 
							where idheader = @idNew 
								and isnull( TaglioAli , '' ) <> 'Ali'
						

						-- l'algoritmo si differenzia in funzione delle offerte ammesse
						if @NumAmmesse >= 15 
						begin

							-- recupero le prime 2 cifre dopo la virgola, della somma dei ribassi offerti dai concorrenti ammessi escludendo le ali
							-- per calcolare un correttivo

							declare @PrimiDecimali varchar(2)
							declare @c1 varchar(2)
							declare @c2 varchar(2)

							declare @Correttivo  as int
							set @PrimiDecimali = left( dbo.GetPos( str( @SommaTuttiRibassi  , 20,10 ) , '.' , 2 )  , 2 ) 
							set @Correttivo = cast( left ( @PrimiDecimali  , 1 ) as int ) * cast( right ( @PrimiDecimali  , 1 ) as int ) 
							set @c1 = left ( @PrimiDecimali  , 1 )
							set @c2 = right( @PrimiDecimali  , 1 )


							--7.	Si calcola la media aritmetica degli scarti, ovvero si fa la somma degli scarti calcolati allo Step 6 e si divide il risultato per il N° Offerte considerate
							select @MediaScarti  = sum( ScartoAritmetico ) / cast( count(*) as decimal( 30, 10 ) )
									from Document_Verifica_Anomalia 
									where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi
				
							set @MediaScarti = isnull( @MediaScarti , 0 )



							--8.	Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
							set @SogliaAnomalia = @MediaScarti + @MediaRibassi

							-- la soglia calcolata al punto c) @SogliaAnomalia viene decrementata di un valore percentuale pari al prodotto delle prime due cifre dopo la virgola della somma dei ribassi di cui alla lettera a) applicato allo scarto medio aritmetico di cui alla lettera b)
							--set @SogliaAnomalia = @SogliaAnomalia * ( 1.0 - ((( @MediaScarti * cast( @Correttivo as decimal( 30, 10 )  )  ) / 100.0 ) / 100.0 ))


							---------------------- PRECEDENTE INTERPRETAZIONE ----------------------------
							--
							--  set @SogliaAnomalia = [dbo].[AF_PARSER ](str( @SogliaAnomalia ,30 , 10 )  + ' * ' + ' ( 1.0 - ((( ' + str( @MediaScarti ,30 , 10 ) + ' * ' + str( @Correttivo  , 30 , 10 ) + '  )  ) / 100.0 ) / 100.0 ) ' )
							--
							---------------------- PRECEDENTE INTERPRETAZIONE ----------------------------


							------------------- INTERPRETAZIONE DEL MIT 16-07-2019 retroattiva -------------
							--
							--Sa = M + S x[1-(c1xc2/100)]
							--dove
							--Sa = soglia di anomalia
							--M = media aritmetica calcolata come descritto alla lett. a) dell’art. 97, c. 2
							--S = scarto medio aritmetico
							--c1 = primo decimale dopo la virgola della somma dei ribassi
							--c2 = secondo decimale dopo la virgola della somma dei ribassi

							declare @Formula varchar(max)
						
							set @Formula = 'M + S * ( 1.0 - (c1 * c2 / 100.0) )'

							set @Formula =  replace ( @Formula , 'M' , str( @MediaRibassi ,30 , 10 )) 
							set @Formula =  replace ( @Formula , 'S' , str( @MediaScarti ,30 , 10 )) 
							set @Formula =  replace ( @Formula , 'c1' , @c1 ) 
							set @Formula =  replace ( @Formula , 'c2' , @c2 ) 

							set @SogliaAnomalia = [dbo].[AF_PARSER ]( @Formula )

	
						end
						else
						------------------------------------------------------------------------------------------
						-- caso in cui le offerte sono minori di 15
						------------------------------------------------------------------------------------------
						begin

						

							--7.	Si calcola la media aritmetica degli scarti, ovvero si fa la somma degli scarti calcolati allo Step 6 e si divide il risultato per il N° Offerte considerate
							select @MediaScarti  = sum( ScartoAritmetico ) / cast( count(*) as decimal( 30, 10 ) )
									from Document_Verifica_Anomalia 
									where isnull( TaglioAli , '' ) <> 'Ali' and  idheader = @idNew and Ribasso > @MediaRibassi
				
							set @MediaScarti = isnull( @MediaScarti , 0 )

						
							--AGGIUNTO PER CORREGGERE ERRORE DIVISION BY ZERO
							if @MediaRibassi <> 0
							BEGIN
								-- se il rapporto degli scarti è <= 0,15 
								if @MediaScarti / @MediaRibassi  <= 0.15 
								BEGIN
									set @SogliaAnomalia =  @MediaRibassi * 1.2
								end
								else
								begin
									-- se il rapporto degli scarti è > 0,15 
									--8.	Si somma la media aritmetica dei ribassi allo scarto aritmetico medio per ottenere la Soglia di anomalia. Si considerano offerte anomale quelle offerte che presentano un ribasso   pari   o   superiore  alla soglia calcolata.
									set @SogliaAnomalia = @MediaScarti + @MediaRibassi

								end
							END
							ELSE
							BEGIN
								set @SogliaAnomalia=0
							END

						end

						if @OfferteUtili = 'SI'
						begin

							--update Document_MicroLotti_Dettagli  set Statoriga = @StatoRiga
							--	where id in (
							--		select id_rowLottoOff
							--			from Document_Verifica_Anomalia
							--			where  idheader = @idNew and Ribasso >= @SogliaAnomalia
							--	)

							-- riporto sulla tabella del calcolo anomalia lo stato della riga
							update Document_Verifica_Anomalia 
									set StatoAnomalia=@StatoRiga,
									Notedit=case when @StatoRiga in ('Anomalo','SospettoAnomalo') then '1' else '0' end
								where  idheader = @idNew and Ribasso >= @SogliaAnomalia
						end
						else
						begin
							-- si inserisce la civetta per avvisare l'utente della mancanza di un numero di offerte utili ad effettuare il calcolo
							insert into CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value ) values ( @idNew , 'OFFERTE_UTILI' , 0 , 'OFFERTE_UTILI' , 'NO' )
						end



						-- salviamo collegato al documento i valori utilizzati per i calcoli
						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
								values( @idNew , 'MEDIE'  , 0 , 'MediaRibassi' , @MediaRibassi )

						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
								values( @idNew , 'MEDIE'  , 0 , 'SommaRibassi' , @SommaTuttiRibassi )

						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
								values( @idNew , 'MEDIE'  , 0 , 'MediaScarti' , @MediaScarti )

						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
								values( @idNew , 'MEDIE'  , 0 , 'SogliaAnomalia' , @SogliaAnomalia )


						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
								values( @idNew , 'MEDIE'  , 0 , 'EstensioneAli' , @EstensioneAli )








						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------
						---------------------------------------------------------------------------------------

					end
					else
					begin
						insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
							values( @idNew , 'MEDIE'  , 0 , 'NotEditable1' , ' Parametro_esclusione_automatica ' )

						IF @Algoritmo IN ('A','B','C')
						BEGIN
							EXEC VERIFICA_ANOMALIA_CREATE_FROM_LOTTO_DAL_01_07_2023 @idDoc, @IdUser, @idBando, @idNew,@IdPDA,@StatoRiga, @OffAnomale
						END
					end

				end
				set @id = @idNew

				-- al termine del calcolo si innesca nuovamente il calcolo della graduatoria
				--EXEC PDA_GRADUATORIA_LOTTO  @idPDA , @NumeroLotto 

			end	

		end	
		else
		begin
	
			-- cancello la civetta eventualmente inserita per evitare che si ripresenti il messaggio all'utente che il numero di offerte non è sufficiente al calcolo
			delete from CTL_DOC_VALUE where  IdHeader = @Id and  DSE_ID = 'OFFERTE_UTILI'  and DZT_Name = 'OFFERTE_UTILI' 
	
		end	
	

		insert into CTL_DOC_Value (  IdHeader, DSE_ID, Row, DZT_Name, Value )  
			values( @idNew , 'MEDIE'  , 0 , 'idNew' , @idNew )

		-- Se le offerte anomale sono a manuale 
		IF @OffAnomale = '16311' AND @Errore = ''
		BEGIN
			update Document_Verifica_Anomalia set taglioAli = '', ScartoAritmetico = null
				where idheader = @Id

			update CTL_DOC_Value set [value] = ''  
				where idheader = @Id and DZT_Name = 'MediaRibassi' and DSE_ID = 'MEDIE'

			update CTL_DOC_Value set [value] = ''  
				where idheader = @Id and DZT_Name = 'SommaRibassi' and DSE_ID = 'MEDIE'

			update CTL_DOC_Value set [value] = ''  
				where idheader = @Id and DZT_Name = 'MediaScarti' and DSE_ID = 'MEDIE'
		END
	end

	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	end
	else
	begin
		-- ritorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

	SET NOCOUNT OFF
END




GO
