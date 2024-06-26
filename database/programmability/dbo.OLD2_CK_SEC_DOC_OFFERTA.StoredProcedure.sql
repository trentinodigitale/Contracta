USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_DOC_OFFERTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[OLD2_CK_SEC_DOC_OFFERTA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255), @Blocco  nvarchar(1000)=null OUTPUT , @NoSquenza int = 0 )
as
begin
	
	--inserita perchè non restituiva record se faceva una insert
	SET NOCOUNT ON

	-- verifico se aa sezione puo essere aperta.
	-- sulle offerte il criterio di blocco è:
	-- si deve raggiungere la data apertura offerta
	-- i documenti devono essere aperti in sequenza di arrivo
	-- devono essere aperte prima le buste di documentazione poi quelle economiche



	declare @idPfu int
	declare @idPDA int
	set @idPDA = null
	--declare @Blocco nvarchar(1000)
	set @Blocco = ''
	declare @TipoDoc as varchar(200)
	declare @IdBando as int
	declare @IdCommissione as int
	declare @divisione_lotti  varchar(10)
	declare @StatoFunzionale varchar(100)
	declare @CriterioAggiudicazioneGara varchar(100)
	declare @Allegato nvarchar(4000)
	declare @idRow int
	declare @Conformita varchar(100)
	declare @ProceduraGara  varchar(100)
	declare @TipoBandoGara  varchar(100)
	declare @Controllo_superamento_importo_gara  varchar(10)
	declare @TipoSedutaGara as varchar(100)
	declare @StatoSeduta as varchar(100)
	declare @Visualizzazione_Offerta_Tecnica as varchar(100)
	declare @dzt_type_decrypt varchar(max) = ''
	declare @StatoRiga varchar(500)=''

	declare @StatoFunzionaleOfferta varchar(100)
	declare @TipoProceduraCaratteristica varchar(100)
	declare @isBuyer int 

	set @isBuyer  = 0
	-- definisce se chi sta aprendo il documento è un buyer o un seller
	if exists( select idpfu from ProfiliUtente with(nolock) 
											inner join aziende with(nolock) on idazi=pfuidazi
									where IdPfu = @IdUser and pfuDeleted = 0 and  aziAcquirente > 0  ) 
		set @isBuyer  = 1

	

	set @IdCommissione=-1
	
	--select @divisione_lotti = divisione_lotti  , @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara,@ProceduraGara=ProceduraGara ,@TipoBandoGara=TipoBandoGara 
	--			, @Conformita = isnull( conformita , 'No' ) 
	--	from OFFERTA_TESTATA_VIEW where id = @IdDoc 
    
	
	--recupero id del bando dal documento offerta
	select @IdBando=linkeddoc from ctl_doc with(nolock) where id=@IdDoc

	-- recupero la PDA
	select 
		@idPDA = p.id , @StatoFunzionale  = p.StatoFunzionale ,@TipoDoc=p.JumpCheck
		from CTL_DOC o  with(nolock) 
			inner join CTL_DOC p  with(nolock) on o.LinkedDoc = p.LinkedDoc and p.TipoDoc = 'PDA_MICROLOTTI' and p.deleted=0
		where o.id = @IdDoc 



	-- informazioni relative la bando
	select 
		@divisione_lotti = divisione_lotti  
		, @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara
		, @ProceduraGara=ProceduraGara 
		, @TipoBandoGara=TipoBandoGara 
		, @Conformita = isnull( conformita , 'No' ) 
		, @Controllo_superamento_importo_gara=ISNULL(Controllo_superamento_importo_gara,'') 
		, @TipoSedutaGara= TipoSedutaGara
		, @StatoSeduta= StatoSeduta
		, @Visualizzazione_Offerta_Tecnica =ISNULL(Visualizzazione_Offerta_Tecnica,'una_fase')
		, @TipoProceduraCaratteristica = TipoProceduraCaratteristica
		from 
			Document_Bando  with(nolock) 
		where idHeader=@IdBando
		

		-- Se l'offerta è monolotto allora la busta tecnica non è presente
		--if @SectionName = 'BUSTA_TECNICA' and @divisione_lotti <> '0' and @CriterioAggiudicazioneGara <> '15532' 
		--if @SectionName = 'BUSTA_TECNICA' and ( @divisione_lotti <> '0' or @CriterioAggiudicazioneGara <> '15532' ) 
		--	set @Blocco = 'NON_VISIBILE'


	
	---- una gara senza lotti sul primo livello prevede la busta tecnica se economicamente vantaggiosa oppure costo fisso oppure conformità ?
	if  @SectionName = 'BUSTA_TECNICA' 
	begin
		
		-- RFQ: nel caso di offerta aperta dal compilatore la busta tecnica non è visibile ( si lascio solo il tab dei prodotti ) 
		if  @TipoProceduraCaratteristica = 'RFQ' and @isBuyer = 0
		begin
			set @Blocco = 'NON_VISIBILE'
		end
		else if @divisione_lotti = '0'  and ( @CriterioAggiudicazioneGara = '15532' or @CriterioAggiudicazioneGara = '25532' or  @Conformita <> 'No' ) --= 'Ex-Ante') 
		begin
			set @Blocco = ''
		end
		else
		begin
			set @Blocco = 'NON_VISIBILE'
		end

		----se domanda di partecipazione busta tecnica non visibile
		--if @Blocco = '' and @ProceduraGara='15477' and @TipoBandoGara = '2' 
		--begin
		--  	set @Blocco = 'NON_VISIBILE'
		--end
	end

	if  @SectionName = 'BUSTA_ECONOMICA' 
	begin
			-- nel caso di offerta aperta dal compilatore la busta economica non è visibile ( si lascio solo il tab dei prodotti ) 
		if  @TipoProceduraCaratteristica = 'RFQ' and @isBuyer = 0
		begin
			set @Blocco = 'NON_VISIBILE'
		end
		else
		begin
			--nascondo BUSTA_ECONOMICA se: GARA A LOTTI e NON AFFIDAMENTO DIRETTO e NON RICHIESTA PREVENTIVO oppure in generale se RISTRETTA-BANDO 
			if ( @divisione_lotti <> '0' and @ProceduraGara not in ( '15583' ,'15479' ) ) 
				or (@ProceduraGara = '15477' and @TipoBandoGara='2')
				-- nel caso di offerta aperta dal compilatore la busta economica non è visibile ( si lascio solo il tab dei prodotti ) 
				--or (  @TipoProceduraCaratteristica = 'RFQ' and @isBuyer = 1  ) 
			begin
				set @Blocco = 'NON_VISIBILE'
			end
		end

	end

	--if  @SectionName = 'LISTA_LOTTI'  and ( @ProceduraGara = '15583' or @ProceduraGara = '15479' )  --AFFIDAMENTO DIRETTO oppure RICHIESTA PREVENTIVO
	if  @SectionName = 'LISTA_LOTTI'
	begin
		--nascondo LISTA_LOTTI se: GARA NON A LOTTI oppure AFFIDAMENTO DIRETTO oppure RICHIESTA PREVENTIVO oppure RISTRETTA-BANDO
		if @divisione_lotti = '0' or @ProceduraGara = '15583' or @ProceduraGara = '15479' or   (@ProceduraGara = '15477' and @TipoBandoGara='2') 
			
			-- nel caso di offerta aperta dal compilatore l'elenco lotti non è visibile ( si lascio solo il tab dei prodotti ) 
			or (  @TipoProceduraCaratteristica = 'RFQ' and @isBuyer = 0  ) 
		begin
			set @Blocco = 'NON_VISIBILE'
		end
	end

	if  @SectionName = 'PRODOTTI_AMPIEZZA_GAMMA'
	begin
		--se non è attivo il modulo
		IF not EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'	)
		begin
			set @Blocco = 'NON_VISIBILE'
		end
		else
		begin 
			--se il bando non prevede ampiezza di gamma
			if not exists (select id from Document_MicroLotti_Dettagli with(nolock) where AmpiezzaGamma = '1' and IdHeader = @IdBando and TipoDoc in ('BANDO_GARA', 'BANDO_SEMPLIFICATO'))
			begin
				set @Blocco = 'NON_VISIBILE'
			end
		end
	end
	
	if @Blocco = ''
	begin
	
		if left( @IdDoc , 3 ) <> 'new'
		begin
			
			-- se la busta risulta gia aperta non sono necesasri altri controlli
			if  exists( select IdRow from CTL_DOC_Value D with (nolock) where @IdDoc = D.idHeader and D.DSE_ID = @SectionName and D.DZT_Name = 'LettaBusta' and d.value = '1' )
			begin					

				
				-- per la busta tecnica, anche se aperta, se la gara prevede ll'apertura in due faSI è NECESSARIO VERIFICARE SE LA FASE è SUPERATA
				if  @SectionName = 'BUSTA_TECNICA' 
				begin
					if @Visualizzazione_Offerta_Tecnica = 'due_fasi'
					begin
						
						select @StatoRiga=StatoRiga  from Document_microlotti_dettagli  with(nolock)  where idheader=@idPDA and tipodoc = 'PDA_MICROLOTTI' and voce = 0 

						if @StatoRiga in ('daValutare','PrimaFaseTecnica')
							set @Blocco='BUSTA TECNICA NON DISPONIBILE. Essendo una gara "due fasi" i valori per la valutazione sono visibili nella Scheda Valutazione fino all''esecuzione del comando Chiusura punteggio tecnico'			
					end

				end


				--select @StatoRiga=StatoRiga  from PDA_LISTA_MICROLOTTI_VIEW  where idheader=@idPDA
								
				--if  @SectionName = 'BUSTA_TECNICA'  and  ( @Visualizzazione_Offerta_Tecnica = 'due_fasi' and @StatoRiga in ('daValutare','PrimaFaseTecnica') )
				--BEGIN
				--	set @Blocco='BUSTA TECNICA NON DISPONIBILE. Essendo una gara "due fasi" i valori per la valutazione sono visibili nella Scheda Valutazione fino all''esecuzione del comando Chiusura punteggio tecnico'			
				--END
				--ELSE					
				--	set @Blocco = ''
				
			end
			else
			begin

				-- compilatore del documento
				select @idPfu = idPfu , @StatoFunzionaleOfferta = StatoFunzionale 
					from CTL_DOC o  with(nolock)  where o.id = @IdDoc 

						
				---------------------------------------------------------------------------------------
				-- il compilatore non ha vincoli sulle sezioni
				---------------------------------------------------------------------------------------
				if @IdUser  = @idPfu
					or 
					(	@StatoFunzionaleOfferta <> 'InLavorazione' 
						AND
						exists ( -- l'utente collegato appartiene ad una delle aziende che partecipano all'offerta

									select P.idpfu 
										from ctl_doc C1  with(nolock) 
											inner join document_offerta_partecipanti DO  with(nolock) on DO.idheader=c1.id and TipoRiferimento in ('RTI','ESECUTRICI') and Ruolo_Impresa <> 'Mandataria'
											inner join profiliutente P  with(nolock) on P.pfuidazi=DO.idazi
											inner join ProfiliUtenteAttrib PA  with(nolock) on PA.idpfu= P.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
										where linkeddoc=@idDoc	and P.idpfu=@IdUser	and c1.Deleted = 0 	
								
								)
					)
				begin

					set @Blocco = ''

				end
				else			
				begin				
					
					--INVOCO LA STORED PER I CONTROLLI
					select top 0 cast('' as varchar(max)) as blocco into #temp
					insert into #temp 
						exec CK_SEC_DOC_OFFERTA_CONTROLLI @SectionName , @IdDoc , @IdUser , @NoSquenza
					
					select @Blocco=blocco from #temp




					-- se non ci sono blocchi  ed è stato fatto il comando di apertura per la busta allora si segna che è stata aperta
					if  @Blocco = '' and left( @IdDoc , 3 ) <> 'new' and ( EXISTS (select IdRow from CTL_DOC_Value  with(nolock) where IdHeader=@IdDoc and dse_id=@SectionName and DZT_Name='richiesta_apertura_busta' and value='1' ) or @SectionName in ('BUSTA_DOCUMENTAZIONE','DOCUMENTAZIONE') ) 
					begin
						if not exists( select IdRow from CTL_DOC_VALUE D  with(nolock) where @IdDoc = D.idHeader and D.DSE_ID = @SectionName and D.DZT_Name = 'LettaBusta' )
						begin

							--traccio i controlli superati

							
							-- per la busta tecnica si aggiunge anche il flag per
							if @SectionName in ( 'BUSTA_TECNICA' ) 
							begin

								insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
									--values ( @IdDoc , 'OFFERTA_BUSTA_TEC'  , 0 , 'LettaBusta' , '1' )
									select LO.id , 'OFFERTA_BUSTA_TEC'  , 0 , 'LettaBusta' , '1' 
										from 
											CTL_DOC m  with(nolock) 
												inner join CTL_DOC D  with(nolock) on d.deleted = 0 and  m.LinkedDoc = d.linkedDoc and d.TipoDoc = 'PDA_MICROLOTTI'
												inner join Document_PDA_OFFERTE o with(nolock) on o.IdMsgFornitore = m.id and d.id = o.idheader
												inner join Document_MicroLotti_Dettagli LP  with(nolock) on o.idheader = LP.IdHeader and LP.TipoDoc = 'PDA_MICROLOTTI' and LP.NumeroLotto = '1'  and LP.Voce = 0 
												inner join Document_MicroLotti_Dettagli LO  with(nolock) on LO.IdHeader = o.idRow and LO.TipoDoc = 'PDA_OFFERTE' and LO.NumeroLotto = '1'  and LO.Voce = 0 
										where  
											m.id = @IdDoc 
							 
							end

							------------------------------------------------------------------------
							-- sulle offerte quando si apre la busta si decifra il contenuto
							------------------------------------------------------------------------
							if @SectionName = 'BUSTA_DOCUMENTAZIONE' or @SectionName = 'DOCUMENTAZIONE'
							begin
								exec AFS_DECRYPT_DATI  @IdUser ,  'CTL_DOC_ALLEGATI' , 'DOCUMENTAZIONE' ,  'idHeader'  ,  @IdDoc   ,'OFFERTA_ALLEGATI'  , 'idRow,idHeader' , '' , 1 
								select @Allegato = F2_SIGN_ATTACH from CTL_DOC_SIGN  with(nolock) where idheader = @IdDoc
								exec AFS_DECRYPT_ATTACH  @IdUser ,    @Allegato , @IdDoc

								--QUANDO APRE LA BUSTA DOCUMENTAZIONE, SOLO LA PRIMA, TRACCIO LA CRONOLOGIA "Prima Seduta Apertura Amministrativa"
								insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
									select top 1 'PDA_MICROLOTTI' , @idPDA  , 'Prima Seduta Apertura Amministrativa' , 'Inizio Valutazione Amministrativa', @IdUser , attvalue , 1 , getdate() 
										from profiliutenteattrib  with(nolock) 
											left outer join CTL_ApprovalSteps with(nolock) on APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='Prima Seduta Apertura Amministrativa'
										where idpfu = @IdUser and dztnome = 'UserRoleDefault' and CTL_ApprovalSteps.APS_ID_DOC IS null

								
								--se esiste decifro il modulo questionario amministrativo
								declare @IdModuloQuest as int
								declare @ModelName as varchar(500)

								set @IdModuloQuest = -1
								select 
									@IdModuloquest=id ,
									@ModelName = MOD_Name
									from 
									ctl_doc with (nolock) 
										inner join CTL_DOC_SECTION_MODEL with (nolock) on id=IdHeader and dse_id='MODULO'
										where LinkedDoc = @IdDoc and tipodoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and Deleted=0

								
								--if @IdModuloQuest <> -1
								--begin
								--	exec AFS_DECRYPT_DATI  @IdUser ,  'CTL_DOC_VALUE' , 'MODULO' ,  'idHeader'  ,  @IdModuloquest   , @ModelName , 'idRow,idHeader' , '' , 1 
								--end



							end


							declare @modellobando varchar(200)
							declare @modelloofferta varchar(200)
							--recupero modello selezionato
							select @modellobando = b.TipoBando 
								from 
									Document_Bando b  with(nolock) 
										inner join CTL_DOC d  with(nolock) on b.idHeader = d.LinkedDoc
								where 
									d.id = @iddoc

							if @SectionName = 'BUSTA_ECONOMICA'  and @divisione_lotti = '0'
							begin
	

								set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_Offerta'

								exec AFS_DECRYPT_DATI  @IdUser ,  'Document_MicroLotti_Dettagli' , 'BUSTA_ECONOMICA' ,  'idHeader'  ,  @IdDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , '' , 1 
								-- Ricopio i dati legati alla parte di valutazione dell'offerta
								exec COPY_DATI_VALUTAZIONE_OFFERTA @IdDoc , @modelloofferta , ''

								select @Allegato = F1_SIGN_ATTACH from CTL_DOC_SIGN  with(nolock) where idheader = @IdDoc
								exec AFS_DECRYPT_ATTACH  @IdUser ,    @Allegato , @IdDoc
								
								
								exec POPOLA_OFFERTA_ALLEGATI  @idPDA , @IdDoc , -1 , @SectionName ,@IdUser,@modelloofferta

							end


							if @SectionName = 'BUSTA_TECNICA'  and @divisione_lotti = '0'
							begin

								set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_OffertaTec'

								--se il campo "visualizzazione offerta tecnica" ha il valore "due fasi" 
								--mettiamo a null tutti i campi del modello della busta tecnica tranne quelli di tipo allegato 
								if @Visualizzazione_Offerta_Tecnica = 'due_fasi'
								BEGIN						
									set @Blocco='BUSTA TECNICA NON DISPONIBILE. Essendo una gara "due fasi" i valori per la valutazione sono visibili nella Scheda Valutazione fino all''esecuzione del comando Chiusura punteggio tecnico'									
									set @dzt_type_decrypt='18'

									IF EXISTS ( select v.Allegati_da_oscurare
													from 
														Document_Microlotto_Valutazione v  with(nolock) 
														where
															v.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and v.idheader = @idBando  and v.CriterioValutazione = 'quiz'
															and ISNULL(v.Allegati_da_oscurare,'')<>''
												)
									BEGIN
										set @dzt_type_decrypt=''
										select 
											@dzt_type_decrypt=@dzt_type_decrypt + v.Allegati_da_oscurare
											from 
												Document_Microlotto_Valutazione v  with(nolock) 
											where v.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and v.idheader = @idBando  and v.CriterioValutazione = 'quiz'
													and ISNULL(v.Allegati_da_oscurare,'')<>''					
						
									END					
									set @dzt_type_decrypt=REPLACE(@dzt_type_decrypt,'###',',')
									set @dzt_type_decrypt=REPLACE(@dzt_type_decrypt,'.',',')


								END


								exec AFS_DECRYPT_DATI  @IdUser ,  'Document_MicroLotti_Dettagli' , 'BUSTA_TECNICA' ,  'idHeader'  ,  @IdDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , '' , 1 ,@dzt_type_decrypt
								-- Ricopio i dati legati alla parte di valutazione dell'offerta
								exec COPY_DATI_VALUTAZIONE_OFFERTA @IdDoc , @modelloofferta , ''

								select @Allegato = F3_SIGN_ATTACH from CTL_DOC_SIGN  with(nolock)  where idheader = @IdDoc
								exec AFS_DECRYPT_ATTACH  @IdUser ,    @Allegato , @IdDoc

								-- eseguo la VALUTAZIONE TECNICA DEL LOTTO
								select @idRow = LO.id
									from 
										CTL_DOC m  with(nolock) 
											inner join CTL_DOC D  with(nolock) on d.deleted = 0 and  m.LinkedDoc = d.linkedDoc and d.TipoDoc = 'PDA_MICROLOTTI'
											inner join Document_PDA_OFFERTE o  with(nolock) on o.IdMsgFornitore = m.id and d.id = o.idheader
											inner join Document_MicroLotti_Dettagli LO  with(nolock) on LO.IdHeader = o.idRow and LO.TipoDoc = 'PDA_OFFERTE' 
									where   
										m.id = @IdDoc and LO.NumeroLotto = '1' and Voce = 0 

								exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO @idRow									
								
								exec POPOLA_OFFERTA_ALLEGATI  @idPDA , @IdDoc , -1 , @SectionName ,@IdUser,@modelloofferta

								--QUANDO SIAMO SULLE DUE FASI
								--SPOSTO IL RIFERIMENTO TECNICO DEL FILE DELLA BUSTA TECNICA FIRMATA NEL CAMPO f4, il quale verrà ripristinato
								--dal comando Chiusura punteggio tecnico
								if @Visualizzazione_Offerta_Tecnica = 'due_fasi'
								BEGIN
									update CTL_DOC_SIGN set F4_SIGN_ATTACH=F3_SIGN_ATTACH
										where idheader = @IdDoc

									update CTL_DOC_SIGN set F3_SIGN_ATTACH=NULL
										where idheader = @IdDoc and ISNULL(F4_SIGN_ATTACH,'')<>''
									 
								END

								--QUANDO APRE LA BUSTA TECNICA , SOLO LA PRIMA, TRACCIO LA CRONOLOGIA "Prima Seduta Tecnica"
								insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
									select top 1 'PDA_MICROLOTTI' , @idPDA  , 'Ricognizione Offerte Tecniche' , '', @IdUser , attvalue , 1 , getdate() 
										from 
											profiliutenteattrib  with(nolock) 
												left outer join CTL_ApprovalSteps with(nolock) on APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='Ricognizione Offerte Tecniche'
										where 
											idpfu = @IdUser and dztnome = 'UserRoleDefault' and CTL_ApprovalSteps.APS_ID_DOC IS null





							end
							
							-- se si apre la busta economica e la SYS dice che si deve fare la verifica di base asta in apertura
							if  @SectionName = 'BUSTA_ECONOMICA'  and @divisione_lotti = '0' 
								and (
										@Controllo_superamento_importo_gara = 'si' or
										( @Controllo_superamento_importo_gara = '' and exists( select dzt_name from  LIB_Dictionary  with(nolock)  where DZT_Name = 'SYS_VERIFICA_SUPERAMENTO_BASE_ASTA' and DZT_ValueDef = 'PDA' ) )
									) 							
							begin
								exec VerificaBaseAstaOffertaLotto @IdUser , @idPDA , -1 , @IdDoc
							end

							
							insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values ( @IdDoc , @SectionName , 0 , 'LettaBusta' , '1' )
								
							if  @SectionName = 'BUSTA_ECONOMICA' and @divisione_lotti = '0' 
							BEGIN
								--QUANDO APRE LA BUSTA ECONOMICA , SOLO LA PRIMA, TRACCIO LA CRONOLOGIA "Prima Seduta Economica"
								insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
									select top 1 'PDA_MICROLOTTI' , @idPDA  , 'Apertura Offerte Economiche' , '', @IdUser , attvalue , 1 , getdate() 
										from 
											profiliutenteattrib  with(nolock) 
												left outer join CTL_ApprovalSteps  with(nolock)  on APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='Apertura Offerte Economiche'
										where 
											idpfu = @IdUser and dztnome = 'UserRoleDefault' and CTL_ApprovalSteps.APS_ID_DOC IS null

							END


							
							-- SE PRESENTI DOCUMENTI DI ANOMALIA_BUSTA_AMMINISTRATIVA INSERISCO ANOMALIE 
							-- PER IL FORNITORE FORNITORE DOPO AVER APERTO LA BUSTA DOCUMENTAZIONE
							if @SectionName = 'BUSTA_DOCUMENTAZIONE' or @SectionName = 'DOCUMENTAZIONE'
							begin

								insert into Document_Pda_Offerte_Anomalie
									(IdHeader, IdRowOfferta, IdDocOff, IdFornitore, Descrizione,TipoAnomalia)
											
									select @idPda,O.IdRow, C.id ,o.idAziPartecipante,dbo.cnv('OFFERTA_ANOMALIE_AMMINISTRATIVA','I'),'OFFERTA_ANOMALIE_AMMINISTRATIVA'
										from 
											Document_PDA_OFFERTE O with(NOLOCK)					
												inner join ctl_doc C with(NOLOCK) on C.LinkedDoc=O.Idmsg and C.TipoDoc='OFFERTA_ANOMALIE_AMMINISTRATIVA' and C.Deleted=0 and C.StatoFunzionale='Confermato'
												left join Document_Pda_Offerte_Anomalie OP with(NOLOCK) on OP.idheader=@idPda and OP.TipoAnomalia='OFFERTA_ANOMALIE_AMMINISTRATIVA' and Op.IdDocOff=C.id
										where  
											O.idheader=@idPda and O.IdMsg=@IdDoc and OP.IdDocOff IS NULL

								-- invoco il controllo dei motivi di esclusione sulla compilazione del questionario amministrativo
								 exec PDA_UPD_WARNING_QUESTIONARIO_AMMINISTRATIVO @idPda , @IdDoc

								-- aggiorno il warning ( spostato per accentrare la logica di composizione )
								exec PDA_UPD_WARNING @idPda 

								--SE SONO PRESENTI le ausiliarie valorizzo sulla document_pda_offerte la colonna Avvalimento
								IF EXISTS ( select IdRow from Document_Offerta_Partecipanti with(nolock) where IdHeader=@IdDoc and TipoRiferimento='AUSILIARIE')
								BEGIN
									update Document_PDA_OFFERTE set Avvalimento='S' where IdHeader=@idPDA and IdMsg=@IdDoc
								END
								-- La stored deve creare il documento OFFERTA_ALLEGATI se mancante ed aggiungere i dati 
								-- decrittografati degli allegati presenti nella busta al documento OFFERTA_ALLEGATI
								exec POPOLA_OFFERTA_ALLEGATI  @idPDA , @IdDoc , NULL , NULL ,@IdUser,NULL		


							END


						end

					end
				end
			end
		end
	end
	
	-- se Nei parametri di configurazione risulta apertura prima seduta automatica
	if exists(
				select d.id 
					from 
						CTL_DOC d with(nolock)
							inner join Document_Parametri_Sedute_Virtuali p with(nolock) on d.id= p.idheader 
					where 
						TipoDoc='PARAMETRI_SEDUTA_VIRTUALE' and d.deleted=0 and statoFunzionale='confermato' and apertura='automatica'
			)
	begin
		
		--Se non ci sono errori e la seduta è virtual e non è stata già aperta e non sono il compilatore dell'offerta
		--perchè questa operazione è consentita solo per chi supera i controlli (@Blocco='') e non essere fatta dal compilatore dell'offerta
		if @Blocco='' and @TipoSedutaGara='virtuale' and @StatoSeduta <> 'aperta' and @idPfu <>  @IdUser
		begin
			
			if not exists(select idrow from [CTL_DOC_Value]  with(nolock) where [IdHeader]=@IdBando and [DSE_ID]='PrimaAperturaSedutaDaBusta' and [DZT_Name]='StatoSeduta' and value='yes')
			begin
				
				UPDATE [Document_Bando]
					SET [StatoSeduta] = 'aperta'
					where idHeader=@IdBando

				INSERT INTO [CTL_DOC_Value]
							([IdHeader]
							,[DSE_ID]
							,[Row]
							,[DZT_Name]
							,[Value])
						VALUES
							(@IdBando
							,'PrimaAperturaSedutaDaBusta'
							,0
							,'StatoSeduta'
							,'yes')
		
				-- Si inizializza la data di inizio della seduta virtuale
				if not exists(select IdRow from [CTL_DOC_Value]  with(nolock) where [IdHeader]=@IdBando and [DSE_ID]='SedutaVirtuale' and [DZT_Name]='DataInizio')
				begin

					INSERT INTO [CTL_DOC_Value]
								([IdHeader]
								,[DSE_ID]
								,[Row]
								,[DZT_Name]
								,[Value])
							VALUES
								(@IdBando
								,'SedutaVirtuale'
								,0
								,'DataInizio'
								,convert( varchar(19) , getdate() , 126 ))
				end
				else
				begin
					UPDATE [CTL_DOC_Value]
						SET [Value] = convert( varchar(19) , getdate() , 126 )
						where [IdHeader]=@IdBando and [DSE_ID]='SedutaVirtuale' and [DZT_Name]='DataInizio'			
				end

			end
		end


	end
	


	if @SectionName in ( 'PRODOTTI' ) 
	begin
		
		-- in caso di RFQ (Mondo Impresa) il tab prodotti deve essere visibile anche ai buyer
		-- in sostituzione delle buste tecniche ed economiche
		-- I buyer per gli ENTI (Mondo PA) non vedono il tab prodotti ma solo le buste tecniche ed economiche


		--EVOLUZIONE i Buyer non vedono il tab prodotti 
		if /*@TipoProceduraCaratteristica <> 'RFQ' and*/ @isBuyer  = 1  -- mondo PA
			set @Blocco = 'NON_VISIBILE'
		else
		begin		
		
			if @Divisione_lotti = 0 
				if isnull( @Blocco , '' ) = ''
					set @Blocco = 'CAPTION:Prodotti' 
				else
					set @Blocco = 'CAPTION:Prodotti~' + isnull( @Blocco , '' )
		
		end
	
	end



	select @Blocco as Blocco 

	

end
GO
