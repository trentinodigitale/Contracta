USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_ART_36_CREATE_FROM_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_PDA_ART_36_CREATE_FROM_LOTTO] 
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

	--CONTROLLO SE L'OPERAZIONE E' CONSENTITA
	--da ID DEL LOTTO OFFERTO RICAVO ID DEL LOTTO SULLA PDA
	--PRENDO IDHEADER=IDROW DELLA TABELLA DOCUMENT_PDA_OFFERTE
	--select idheader,numerolotto from document_microlotti_Dettagli with (nolock) where id =344678
	--da qui idheader=id dell apda
	--SELECT idheader FROM DOCUMENT_pda_offerte where idrow= 12346
	--select statoriga from document_microlotti_dettagli where idheader=480275 and tipodoc='pda_microlotti' and numerolotto=1
	
	--CONTROLLO SE L'OPERAZIONE E' CONSENTITA
	declare @StatoLotto varchar(200)

	select 
		@StatoLotto = C.statoriga
		from 
			document_microlotti_Dettagli A with (nolock)
			inner join DOCUMENT_pda_offerte O with (nolock) on O.IdRow = A.IdHeader
			inner join document_microlotti_dettagli C with (nolock) on C.IdHeader = O.idheader 
				and C.tipodoc = 'pda_microlotti' 
				and C.numerolotto = A.NumeroLotto and C.Voce=0
		where A.id = @IdDoc

	if @StatoLotto not in ('Controllato','AggiudicazioneCond','AggiudicazioneDef','AggiudicazioneProvv')
	begin
		set @Errore ='Il lotto non si trova nello stato per consentire l''apertura del documento'
	end
	

	if @Errore = '' 
	begin

		set @id = null
		select @id = id 
			from CTL_DOC with (nolock) 
				where LinkedDoc = @idDoc and deleted = 0 
					and TipoDoc in ( 'PDA_ART_36' ) and statofunzionale in (  'Confermato' , 'InLavorazione' )

		IF @id is null
		BEGIN

			   -- altrimenti lo creo

				INSERT into CTL_DOC (
							IdPfu,  TipoDoc, 
							Titolo, Body, Azienda,  
							ProtocolloRiferimento, Fascicolo, LinkedDoc )
					select @IdUser as idpfu , 'PDA_ART_36' as TipoDoc ,  
							'Art.36 comma 2' as Titolo, '' Body, idAziPartecipante as  Azienda,  
							ProtocolloRiferimento, Fascicolo, d.id as LinkedDoc
					from Document_MicroLotti_Dettagli d with (nolock)
							inner join Document_PDA_OFFERTE o with (nolock) on o.IdRow = d.idHeader
							inner join Document_PDA_TESTATA t with (nolock) on o.idHeader = t.idHeader
							inner join CTL_DOC b with (nolock) on o.idHeader = b.id
					where d.id = @idDoc

				set @id = SCOPE_IDENTITY()

				/* INSERISCO GLI ALLEGATI DELLE BUSTE */

				declare @PdaOfferta int
				declare @IdModel int
				declare @NumeroLotto varchar(100)
				declare @IdOfferta int
				declare @IdBando int

				select 
					 @PdaOfferta = l.idheader
					,@IdModel = M.id
					,@NumeroLotto = l.NumeroLotto
					,@IdOfferta = O.IdMsgFornitore
					,@IdBando = B.id
					from 
						--Dal Doc ART_36 prendo il linkeddoc
						ctl_doc d with(nolock) 
						--Con il linkeddoc sono già sulla singola offerta per ID di quel lotto/fornitore
						left join document_microlotti_dettagli l with(nolock) on l.id = d.linkeddoc and l.tipodoc = 'PDA_OFFERTE' and voce = 0
						--Salgo sull'offerta
						left join Document_PDA_OFFERTE O with(nolock) on O.idrow = l.IdHeader
						--Salgo sulla PDA_MICROLOTTI
						left join CTL_DOC MIC with(nolock) on MIC.id = O.IdHeader
						--Salgo sul bando gara
						left join CTL_DOC B with(nolock) on B.id = MIC.LinkedDoc
						-- recuperiamo il modello
						left join CTL_DOC M with(nolock) on M.linkeddoc = B.id 
							and M.deleted = 0 
							and M.tipodoc = 'CONFIG_MODELLI_LOTTI'
					where d.linkeddoc = @IdDoc
						and d.deleted = 0 
						and d.TipoDoc in ( 'PDA_ART_36' ) 
						and d.statofunzionale in (  'Confermato' , 'InLavorazione' )


				declare @dynamic_query nvarchar(max)
				declare @dzt_name nvarchar(255)
				declare @TipoBusta varchar(50)
				declare @descrizione nvarchar(max)

				-- Dichiarazione del cursore
				declare AllegatiCursor cursor for
				select
					 d.dzt_name
					,p.DZT_Name as TipoBusta
					,v.value as Descrizione 
					from 
						ctl_doc_value p with (nolock)
						inner join ctl_doc_value a with (nolock) on a.DSE_ID = p.DSE_ID 
							and a.IdHeader = p.IdHeader 
							and a.DZT_Name = 'DZT_Name' 
							and a.Row = p.Row
						inner join ctl_doc_value v with (nolock) on v.DSE_ID = p.DSE_ID 
							and v.IdHeader = p.IdHeader 
							and v.DZT_Name = 'Descrizione' 
							and v.Row = p.Row
						inner join LIB_Dictionary d with (nolock) on d.DZT_Name = a.value 
							and d.DZT_Type = 18
					where p.dse_id = 'MODELLI' 
						and p.DZT_Name in ( 'MOD_OffertaTec' , 'MOD_Offerta')
						and p.Value <> ''
						and p.idheader = @IdModel

				-- Apertura del cursore
				open AllegatiCursor

				fetch next from AllegatiCursor into @dzt_name, @TipoBusta, @descrizione

				-- Ciclo attraverso i risultati del cursore
				while @@fetch_status = 0
				begin
					-- Costruzione della query dinamica
					set @dynamic_query = 'INSERT INTO CTL_DOC_ALLEGATI (IdHeader, Allegato, Descrizione)
											select
												''' + convert(nvarchar, @id) + '''
												,' + quotename(@dzt_name) + ' as Allegato
												, case 
													when ''' + @TipoBusta + ''' = ''MOD_OffertaTec'' 
														then ''T-' + @descrizione + ''' 
														else ''E-' + @descrizione + ''' 
												  end as Descrizione
												from 
													document_microlotti_dettagli with (nolock)
												where tipodoc = ''PDA_OFFERTE'' 
													and voce = 0 
													and idheader = ''' + convert(nvarchar, @PdaOfferta) + ''' 
													and NumeroLotto = ''' + @NumeroLotto + '''
													and isnull(' + quotename(@dzt_name) + ','''') <>'''''

					-- Eseguo la query dinamica
					exec sp_executesql @dynamic_query

					-- Recupero del prossimo valore del cursore
					fetch next from AllegatiCursor into @dzt_name, @TipoBusta, @descrizione
				end

				-- Chiusura del cursore
				close AllegatiCursor
				deallocate AllegatiCursor

				/*INSERISCO GLI ALLEGATI DELLE BUSTE FIRMATE*/
				--Nel caso di una monolotto sono presenti gli allegati della busta tecnica ed economica firmata.
				--mancando un discriminante assouluto nel caso della tecnica recupero il dato posizionalmente essendo 
				--sempre messo relativo all'allegato num.3 e l'economico relativo all'allegato num.1


				--Economica (pos.1)
				insert into CTL_DOC_ALLEGATI(IdHeader, Allegato, Descrizione)
				select
					 @id as IdHeader
					,F1_SIGN_ATTACH
					,'E-Busta Economica Firmata' as F1_SIGN_NAME
					from 
						CTL_DOC_SIGN with(nolock) 
					where isnull(F1_SIGN_ATTACH,'') <> ''
						and idheader = @IdOfferta

				--Tecnica (pos.3)
				insert into CTL_DOC_ALLEGATI(IdHeader, Allegato, Descrizione)
				select
					 @id as IdHeader
					,F3_SIGN_ATTACH
					,'T-Busta Tecnica Firmata' as F3_SIGN_NAME
					from 
						CTL_DOC_SIGN with(nolock) 
					where isnull(F3_SIGN_ATTACH,'') <> ''
						and idheader = @IdOfferta


				--Nel caso di gara a lotti Document_Microlotto_Firme è la tabella di riferimento per gli allegati,
				--collegata all'offerta ma in relazione anche al numero del lotto

				--Economica (pos.1)
				insert into CTL_DOC_ALLEGATI(IdHeader, Allegato, Descrizione)
				select 
					 @id as IdHeader
					,F1_SIGN_ATTACH
					,'E-Busta Economica Firmata' as F1_SIGN_NAME
					from 
						Document_Microlotto_Firme with (nolock)
					where idheader in (
										select
											id
											from 
												Document_Microlotti_dettagli  with (nolock)
											where 
												idheader = @IdOfferta 
												and tipodoc = 'OFFERTA' 
												and NumeroLotto = @NumeroLotto
									  )
						and isnull(F1_SIGN_ATTACH,'') <> ''

				--Tecnica (pos.2)
				insert into CTL_DOC_ALLEGATI(IdHeader, Allegato, Descrizione)
				select 
					 @id as IdHeader
					,F2_SIGN_ATTACH
					,'T-Busta Tecnica Firmata' as F2_SIGN_NAME
					from 
						Document_Microlotto_Firme  with (nolock)
					where idheader in (
										select
											id
											from 
												Document_Microlotti_dettagli  with (nolock)
											where 
												idheader = @IdOfferta
												and tipodoc = 'OFFERTA' 
												and NumeroLotto = @NumeroLotto
									  )
						and isnull(F2_SIGN_ATTACH,'') <> ''


				-- Inserisco gli allegati relativi alla busta Amministrativa

				declare @sign_attach as nvarchar(1000)

				--TABELLA DI LAVORO DOVE INSERISCO TUTTI GLI ALLEGATI E LA USO PER POPOLARE LA CTL_DOC_ALLEGATI

				CREATE TABLE #TMP_WORK_AMMI
				(
					[IdRow] [int] IDENTITY(1,1) NOT NULL,
					[EsitoRiga] [nvarchar](max) COLLATE database_default NULL,
					[Descrizione] [nvarchar](max)  COLLATE database_default NULL,
					[Allegato] [nvarchar](1000) COLLATE database_default NULL
				 )

				--INSERISCO EVENTUALE DGUE SE RICHIESTO
				IF EXISTS (Select IdRow  from ctl_doc_value with (nolock) where idheader=@idbando and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE' and ISNULL(value,'')='si')
				BEGIN
					--DGUE MANDATARIA
						Select 
							@sign_attach=SIGN_ATTACH 
						from ctl_doc with (nolock)
							where tipodoc='MODULO_TEMPLATE_REQUEST' 
							and LinkedDoc=@IdOfferta and deleted = 0 
					
					insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
							Select case when ISNULL(@sign_attach,'')='' then '<img src="../images/Domain/State_Warning.gif"><br>Allegato DGUE non presente' else '<img src="../images/Domain/State_OK.gif">'  end ,'Allegato DGUE',@sign_attach					
				
					--CONTROLLO DGUE PARTECIPANTI
					insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
						select case when ISNULL(AllegatoDGUE,'')='' then '<img src="../images/Domain/State_Warning.gif"><br>Allegato DGUE non presente' else '<img src="../images/Domain/State_OK.gif">'  end ,TipoRiferimento + ' - Allegato DGUE',AllegatoDGUE
							from Document_Offerta_Partecipanti with (nolock) where IdHeader=@IdOfferta and ISNULL(Ruolo_Impresa,'') <> 'Mandataria' and isnull(idazi,0)<>0
			
				END
			
				--INSERISCO GLI ALLEGATI RICHIESTI SUL BANDO 
					insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
						select 
							case when OFFERTA.Descrizione IS NULL then '<img src="../images/Domain/State_Warning.gif"><br>Allegato previsto dal bando e non presente'
								 else EsitoRiga 
							end
							,BANDO.descrizione, OFFERTA.allegato
							from OFFERTA_ALLEGATI_FROM_BANDO_GARA BANDO
								left join CTL_DOC_ALLEGATI OFFERTA with(nolock)  on OFFERTA.idHeader=@IdOfferta and OFFERTA.Descrizione=BANDO.Descrizione
							where BANDO.id_from = @IdBando --and BANDO.obbligatorio=1
			
				--INSERISCO ALTRI ALLEGATI INSERITI DA OE SUL DOCUMENTO OFFERTA
					insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
						select OFFERTA.EsitoRiga,OFFERTA.descrizione, OFFERTA.allegato
							 from CTL_DOC_ALLEGATI OFFERTA with(nolock)  
								left join #TMP_WORK_AMMI T on T.Descrizione=OFFERTA.Descrizione
							  where OFFERTA.idHeader=@IdOfferta  and ( T.Descrizione IS NULL or ( Offerta.Descrizione = 'ALLEGATO DGUE' and OFFERTA.NotEditable = '') )
							  --kpf 547502  per far uscire eventuali allegati di iniziativa con descrizione ALLEGATO DGUE

				--RECUPERO ANOMALIE ATTESTATO PARTECIPAZIONE SE RICHIESTO			
				IF EXISTS (select * from document_bando where IdHeader=@IdBando and ISNULL(ClausolaFideiussoria,0)=1)
				BEGIN
				
					select @sign_attach=F2_SIGN_ATTACH from CTL_DOC_SIGN where idHeader=@IdOfferta
				
					insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
						Select case when ISNULL(@sign_attach,'')='' then '<img src="../images/Domain/State_Warning.gif"><br>Attestato di Partecipazione non presente' else '<img src="../images/Domain/State_OK.gif">'  end ,'Attestato di Partecipazione',@sign_attach					
				
				END		


				----COLLEZIONO ELENCO ANOMALIE SUL DOCUMENTO
				--insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				--	select @id,'DETTAGLI','EsitoRiga',EsitoRiga,[IdRow]-1 
				--		from #TMP_WORK_AMMI 
				--			order by [IdRow]

				--insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				--	select @id,'DETTAGLI','Descrizione',Descrizione,[IdRow]-1 
				--		from #TMP_WORK_AMMI 
				--			order by [IdRow]

				--insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				--	select @id,'DETTAGLI','Allegato',Allegato,[IdRow]-1 
				--		from #TMP_WORK_AMMI 
				--			order by [IdRow]

				-- Inserisco gli allegati con esito riga ok all'interno della CTL_DOC_ALLEGATI
				Insert into CTL_DOC_ALLEGATI(idheader,Descrizione, Allegato)
				select 
					@id, 
					'A-' + Descrizione,
					Allegato
				from #TMP_WORK_AMMI
				where isnull(EsitoRiga,'') like '%images/Domain/State_OK.gif%'

			
				drop table #TMP_WORK_AMMI



				---- cerco una versione precedente se esiste
				--declare @idPrev int
				--set @idPrev = null
				--select @idPrev = max(id) from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_ART_36' ) and statofunzionale in (  'Annullato' )

				--if @idPrev is not null
				--begin

				--	-- se esiste una versione precedente ricopiamo le note per la compilazione
				--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				--		select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
				--			from CTL_DOC_Value with (nolock)
				--			where idheader = @idPrev and dzt_name = 'Note'

				--end
				--else
				--begin

					--declare @CriterioValutazione varchar(20)
					--declare @DescrizioneCriterio nvarchar(255)
					--declare @Modello nvarchar(255)
					--declare @PunteggioMax varchar(50)
					--declare @Punteggio varchar(50)
					--declare @Formula  nvarchar(4000)
					--declare @AttributoCriterio nvarchar(255)
					--declare @Coefficiente float

					--declare @ModAttribPunteggio varchar(50)
					--declare @NumeroLotto varchar(50)
					--declare @idBando as int

					--declare @formulaEcoSDA varchar(8000)

					--declare @idRow int 
					--declare @Row int 
					
					--set @Row = 0
					--set @formulaEcoSDA = ''



					---- recupero il modello di input del fornitore
					--select @Modello = 'MODELLI_LOTTI_' + TipoBando  + '_MOD_OffertaINPUT'
					--		, @idBando = ba.idHeader 
					--		, @NumeroLotto = d.NumeroLotto
					--	from Document_MicroLotti_Dettagli d with(nolock)
					--			inner join Document_PDA_OFFERTE o with(nolock) on o.IdRow = d.idHeader
					--			inner join Document_PDA_TESTATA t with(nolock) on o.idHeader = t.idHeader
					--			inner join CTL_DOC b with(nolock) on o.idHeader = b.id
					--			inner join Document_Bando ba with(nolock) on ba.idHeader = b.LinkedDoc
					--		where d.id = @idDoc


					---- recupero @ModAttribPunteggio dal lotto per determinare quale colonna gestire in edit, se coefficiente o punteggio
					--select @ModAttribPunteggio = ModAttribPunteggio from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idBando = @idBando and N_Lotto = @NumeroLotto


					----recupero le desc degli attributi criterio
					--select MA_DZT_Name , isnull( ML_Description , MA_DescML ) as MA_DescML into #t
					--	from CTL_ModelAttributes	with (nolock)
					--		left outer join  LIB_Multilinguismo with (nolock) on ML_KEY = MA_DescML and ML_LNG = 'I'
					--	where MA_MOD_ID = @Modello 


						--- TORNA SEMPRE RECORD ? 

					--declare crsOf cursor static for
					--	select p.idRow , CriterioFormulazioneOfferte, DescrizioneCriterio, PunteggioMax, FormulaEconomica, AttributoValore , p.Punteggio , p.Giudizio, v.FormulaEcoSDA
					--	from Document_MicroLotti_Dettagli d with(nolock)
					--		inner join Document_Microlotto_PunteggioLotto_ECO p with(nolock) on p.idHeaderLottoOff = d.id
					--		inner join Document_Microlotto_Valutazione_ECO v with(nolock) on p.idRowValutazione = v.idRow
					--	where d.id = @idDoc
					--	order by p.idRow

					--	-- la select fatta per la parte tecnica : 
					--	--select  
					--	--	 p.idRow , CriterioValutazione, DescrizioneCriterio, PunteggioMax, Formula, AttributoCriterio , Punteggio , Giudizio
					--	--from Document_MicroLotti_Dettagli d 
					--	--		inner join Document_Microlotto_PunteggioLotto p on p.idHeaderLottoOff = d.id
					--	--		inner join Document_Microlotto_Valutazione v on p.idRowValutazione = v.idRow
					--	--	where d.id = @idDoc
					--	--	order by p.idRow

					--open crsOf 
					--fetch next from crsOf into  @idRow , @CriterioValutazione, @DescrizioneCriterio, @PunteggioMax, @Formula, @AttributoCriterio , @Punteggio , @Coefficiente,@formulaEcoSDA

					--while @@fetch_status=0 
					--begin 

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'CriterioFormulazioneOfferta2' , @CriterioValutazione )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'DescrizioneCriterio' , @DescrizioneCriterio )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'PunteggioMax' , @PunteggioMax )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Formula' , @Formula )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'AttributoCriterio' , @AttributoCriterio )

					--	set @AttDZT_NAME = dbo.GetPos(@AttributoCriterio, '.', 2 )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		select top 1 @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Descrizione' , dbo.StripHTML( MA_DescML )
					--				from #t 
					--			where  @AttDZT_NAME = MA_DZT_Name


					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Value' , @Punteggio )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'idRow' , @idRow )

					--	--le uniche righe abilitate alla compilazione sono quelle dove la formula è "Valutazione soggettiva"
					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'NotEditable' , case 
					--																			when @formulaEcoSDA <> 'Valutazione soggettiva' 

					--																				-- la valutazione con formula rende tutti i campi non editabili
					--																				then ' CriterioFormulazioneOfferta2 Coefficiente Note Value ' 

					--																				-- altrimenti la valutazione è soggettiva, in questo caso si lascia editabile solo la colonna coefficiente o punteggio
					--																				else ' CriterioFormulazioneOfferta2 ' +
																									
					--																					case when @ModAttribPunteggio = 'punteggio'
					--																						then ' Coefficiente '
					--																						else ' Value '
					--																						end 
																									
					--																				end 

					--																				)

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'Coefficiente' , @Coefficiente )

					--	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					--		values(  @id , 'PDA_VALUTA_LOTTO_ECO' , @Row, 'FormulaEcoSDA' , @FormulaEcoSDA )

					--	set @Row = @Row + 1

					--	fetch next from crsOf into  @idRow , @CriterioValutazione, @DescrizioneCriterio, @PunteggioMax, @Formula, @AttributoCriterio , @Punteggio , @Coefficiente,@formulaEcoSDA

					--end

					--close crsOf
					--deallocate crsOf

				--end

		end

	end
		
	



	if @Errore = ''
	begin

		---- verifico se alla valutazione è stata associata la sezione per la visualizzazione dei dati offerti
		--if not exists ( select [IdRow] from CTL_DOC_SECTION_MODEL with (nolock) where [IdHeader] = @Id and DSE_ID = 'PDA_OFFERTA_BUSTA_ECO' )
		--begin


		--	insert into CTL_DOC_SECTION_MODEL ( IdHeader , DSE_ID , MOD_Name ) 
		--		select @Id , 'PDA_OFFERTA_BUSTA_ECO' ,  'MODELLI_LOTTI_' + TipoBando + '_MOD_Offerta'
		--			from Document_MicroLotti_Dettagli d with (nolock)
		--					inner join Document_PDA_OFFERTE o with (nolock)on o.IdRow = d.idHeader
		--					inner join CTL_DOC p with (nolock)on o.idHeader = p.id
		--					inner join document_bando b with (nolock) on p.LinkedDoc = b.idHeader
		--				where d.id = @idDoc

		--end



		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
		--select @IdOfferta as idoff

	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END


















GO
