USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_DOC_OFFERTA_CONTROLLI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















CREATE PROCEDURE [dbo].[OLD2_CK_SEC_DOC_OFFERTA_CONTROLLI] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255), @NoSquenza int = 0 )
as
BEGIN
	SET NOCOUNT ON
	declare @idPfu int
	declare @idPDA int
	set @idPDA = null
	declare @Blocco nvarchar(1000)
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
	declare @campionatura as varchar(20)
	declare @StatoFunzionaleOfferta varchar(100)
	declare @TipoProceduraCaratteristica varchar(100)

	
	--ENRPAN se la busta letta esco senza fare nulla
	if exists( select IdRow from CTL_DOC_Value D with (nolock) where @IdDoc = D.idHeader and D.DSE_ID = @SectionName and D.DZT_Name = 'LettaBusta' and d.value = '1' )
	begin
		select '' as Blocco
		return 
	end


	set @IdCommissione=-1
	
	--select @divisione_lotti = divisione_lotti  , @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara,@ProceduraGara=ProceduraGara ,@TipoBandoGara=TipoBandoGara 
	--		, @Conformita = isnull( conformita , 'No' ) 
	--	from OFFERTA_TESTATA_VIEW where id = @IdDoc 

	select 
		@divisione_lotti = divisione_lotti  , @CriterioAggiudicazioneGara = CriterioAggiudicazioneGara,@ProceduraGara=ProceduraGara ,@TipoBandoGara=TipoBandoGara  , @TipoProceduraCaratteristica = TipoProceduraCaratteristica
		from 
			CTL_DOC d with(nolock) 
				inner join Document_Bando b with(nolock) on d.LinkedDoc = b.idHeader	
		where 
			d.id = @idDoc

	-- compilatore del documento
	select @idPfu = idPfu , @StatoFunzionaleOfferta = StatoFunzionale from CTL_DOC o with (nolock) where o.id = @IdDoc 
							
	---------------------------------------------------------------------------------------
	-- il compilatore non ha vincoli sulle sezioni
	---------------------------------------------------------------------------------------
	if @IdUser  = @idPfu
		or 
		(	@StatoFunzionaleOfferta <> 'InLavorazione' 
			AND
			(
				( -- è un utente buyer e l'offerta è per una RFQ
					exists( select idpfu 
								from 
									ProfiliUtente with(nolock) 
										inner join aziende with(nolock) on idazi=pfuidazi
								where 
									IdPfu = @IdUser and pfuDeleted = 0 and  aziAcquirente > 0 )
					and 
					@TipoProceduraCaratteristica = 'RFQ'
				)
				or
				(
					exists ( -- l'utente collegato appartiene ad una delle aziende che partecipano all'offerta

						select P.idpfu 
							from 
								ctl_doc C1 with (nolock)
									inner join document_offerta_partecipanti DO with (nolock) on DO.idheader=c1.id and TipoRiferimento in ('RTI','ESECUTRICI') and Ruolo_Impresa <> 'Mandataria'
									inner join profiliutente P  with (nolock) on P.pfuidazi=DO.idazi
									inner join ProfiliUtenteAttrib PA  with (nolock) on PA.idpfu= P.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
							where 
								linkeddoc=@idDoc	and P.idpfu=@IdUser	and c1.Deleted = 0 	
								
					)
				)
			)
		)
	begin

		set @Blocco = ''

	end
	else			
	begin
		---------------------------------------------------------------------------------------
		-- per gli altri
		---------------------------------------------------------------------------------------



		-- recupero la PDA
		select @idPDA = p.id , @StatoFunzionale  = p.StatoFunzionale , @campionatura=dp.RichiestaCampionatura
				from 
					CTL_DOC o  with (nolock) 
						inner join CTL_DOC p  with (nolock) on o.LinkedDoc = p.LinkedDoc and p.TipoDoc = 'PDA_MICROLOTTI' and p.deleted=0
						inner join Document_PDA_TESTATA dp with (nolock) on dp.idHeader=p.Id 
				where 
					o.id = @IdDoc 
						
					

		-- se la PDA non esiste esco
		if @idPDA is null 
			set @Blocco = 'Per aprire le buste e'' necessario avviare la procedura di aggiudicazione'


		if @Blocco = '' and @StatoFunzionale = 'VERIFICA_AMMINISTRATIVA' and @SectionName in ( 'BUSTA_ECONOMICA' , 'BUSTA_TECNICA' , 'LISTA_LOTTI' )
		begin
			set @Blocco = 'La busta non può essere aperta non è stata completata la Verifica Amministrativa'
		end
					

		-- se la data apertura offerte non è stata raggiunta
		if @Blocco = '' and exists( 
							select o.id 
								from 
									CTL_DOC o  with (nolock) 
										inner join Document_Bando b  with (nolock) on o.LinkedDoc = b.idheader
								where 
									o.id = @IdDoc and getdate() < b.DataAperturaOfferte
							)
			set @Blocco = 'per l''apertura della busta e'' necessario attendere la data prima seduta'
						
					
		-- se la RDA risulta esclusa sulla PDA allora non è possibile aprire le restanti sezioni
--			if @Blocco = '' and exists( select * from Document_PDA_OFFERTE o
--								left outer join CTL_DOC_VALUE D on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
--							where o.idHeader = @idPDA and o.StatoPDA in ( '1' , '99' ) and D.idHeader is null 
--									and o.idMsg  = @IdDoc
--								)
		if @Blocco = '' and exists(select IdRow from Document_PDA_OFFERTE  with (nolock)  where idHeader = @idPDA and StatoPDA in ( '1' , '99' ) and idMsg  = @IdDoc)      
			set @Blocco = 'Lo stato del documento non consente l''apertura della busta'

					
		--recupero id del bando
		select @TipoDoc=JumpCheck,@IdBando=linkeddoc from ctl_doc with (nolock) where id=@IdPDA

			
		--recupero documento commissione e se esiste faccio i controlli
		--altrimenti sono le vecchie PDA
		select @IdCommissione=ID from ctl_doc with (nolock) where deleted=0 and linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 

		if @Blocco = ''
		begin	
			if @SectionName = 'BUSTA_DOCUMENTAZIONE' or @SectionName = 'DOCUMENTAZIONE'
					begin
						--controllo che l'utente loggato è il presidente della commissione A		
						if @IdCommissione<>-1	
						begin
							if not exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='A' and UtenteCommissione=@IdUser)
								--set @Blocco = ''
								set @Blocco = 'Apertura busta non possibile. Utente non abilitato' 

						end

						--controllo se per la gara è richiesta la campionatura deve essere stata fatta la verifica della campionatura per l'offerta
						if ISNULL( @campionatura,'') = '1' and @blocco = ''
						begin
							if not exists (select verificacampionatura from Document_PDA_OFFERTE with (nolock) where IdHeader=@idPDA and isnull(verificacampionatura,'')<>'' and IdMsg=@IdDoc )
								set @Blocco = 'Apertura busta non possibile. Compilare prima Inserimento Ricezione Campioni' 
						end
					end
		end
		--if @IdCommissione <> -1 and @Blocco = ''
		if @Blocco = ''
		begin
						
			if exists ( 
						select 
								id 
							from 
								document_microlotti_dettagli with (nolock)	
							where 
								idheader=@IdPDA and voce=0 and tipodoc='PDA_MICROLOTTI'
								and statoriga not in ('NonGiudicabile','Deserta','interrotto','AggiudicazioneDef','NonAggiudicabile')
					)
					
			BEGIN				
				if @SectionName = 'BUSTA_TECNICA'
				begin
					if @IdCommissione<>-1
					begin
						--controllo che l'utente loggato è il presidente della commissioneG se esiste		
						if not exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='G' and UtenteCommissione=@IdUser)

							--set @Blocco = ''
							set @Blocco = 'Apertura busta non possibile. Utente non abilitato' 
					end
				end

				--la busta tecnica non si deve aprire se nella cronologia della PDA non è presente PDA_AVVIO_APERTURE_BUSTE_TECNICHE
				if @SectionName = 'BUSTA_TECNICA' and @Blocco = ''
				begin
					if NOT EXISTS ( 
						Select APS_ID_ROW 
							from CTL_ApprovalSteps with (nolock) 
							where APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE')
						and   @Conformita <> 'Ex-Post'
					BEGIN					
						set @Blocco = 'Per aprire la busta tecnica e'' necessario aver avviato la fase di apertura delle buste tecniche dalla Procedura di aggiudicazione sezione "Valutazione Tecnica"'
					END
				END	


				--se busta tecnica e conformita EX-POST  deve esistere il documento di conformità 
				if @SectionName = 'BUSTA_TECNICA' and @Blocco = '' and @Conformita='Ex-Post'
				begin
								

					-- IL CONTROLLO SI E' MODIFICATO

					--if NOT EXISTS ( select * from ctl_doc where  tipodoc='CONFORMITA_MICROLOTTI' and linkeddoc = @idPDA and Deleted = 0 )
					-- verifico che per l'offerta sia stato calcolato il punteggio complessivo. la presenza del valore ci  garanatisce che è stato eseguito il calcolo economico
					if not exists( select p.idrow 
										from document_pda_offerte p with(nolock) 
											inner join document_microlotti_dettagli d with(nolock) on d.idheader = p.idrow and d.tipodoc = 'PDA_OFFERTE' and d.voce = 0  and isnull( d.valoreofferta , '' ) <> '' 
										where  p.idheader = @idPDA and p.IdMsg = @IdDoc
										)

					BEGIN					
						--set @Blocco = 'Per aprire la busta tecnica e'' necessario aver avviato la fase di conformita'
						set @Blocco = 'Per aprire la busta tecnica e'' necessario aver avviato il calcolo economico'
					END
						
				end


				if @SectionName = 'BUSTA_ECONOMICA'
				begin
					--controllo che l'utente loggato è il presidente della commissione C/A		
					if @IdCommissione<>-1
					begin

						if exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and TipoCommissione='C')
						begin
							--controllo che l'utente loggato è il presidente della commissione C se esiste		
							if not exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='C' and UtenteCommissione=@IdUser)
								--set @Blocco = ''
								set @Blocco = 'Apertura busta non possibile. Utente non abilitato' 
						end
						else
						begin
							--controllo che l'utente loggato è il presidente della commissione A		
							if not exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='A' and UtenteCommissione=@IdUser)
								--set @Blocco = ''
								set @Blocco = 'Apertura busta non possibile. Utente non abilitato' 
						end
					end

				end

				if @SectionName = 'LISTA_LOTTI' and  @ProceduraGara <> '15583' and @ProceduraGara <> '15479' --affidamento diretto e richiesta preventivo
				begin
					if exists( select 
									m.id
									from 
										CTL_DOC m with (nolock)
											inner join CTL_DOC D with (nolock) on d.deleted = 0 and  m.LinkedDoc = d.linkedDoc and d.TipoDoc = 'PDA_MICROLOTTI'
									where   m.id = @IdDoc and d.statofunzionale <> 'VERIFICA_AMMINISTRATIVA'
							)
					begin
						set @Blocco = ''
					end

				end

			end
			else
			begin
				--se le valutazioni sono concluse sblocco per tutti
				set @Blocco = ''
			end
			
		end
						
					
		if @SectionName = 'BUSTA_TECNICA' and @Blocco = ''
		begin
						


			--per aprire la sezione tecnica verifichiamo che tutte le BUSTA_DOCUMENTAZIONE sono aperte
			if exists( 
						select o.IdRow 
							from 
								Document_PDA_OFFERTE o with (nolock)
									left outer join CTL_DOC_VALUE D with (nolock) on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
							where 
								o.idHeader = @idPDA and o.StatoPDA <> '99' and o.StatoPDA <> '1' and D.idHeader is null )
			begin
				set @Blocco = 'Per aprire la busta Tecnica e'' necessario aprire prima tutte le buste di documentazione'
			end
						
						

		end	
								
			
		--per aprire la sezione economica verifichiamo che tutte le BUSTA_DOCUMENTAZIONE sono aperte
		-- ALTRIMENTI PER LE MONOLOTTO  che tutte le tecniche siano aperte
		if @SectionName = 'BUSTA_ECONOMICA' and @Blocco = ''
		begin
			if @divisione_lotti = '0'
			begin
						
						
				-- prima è necessario controllorare lo stato di valutazione del lotto 1
				declare @StatoTecnicoLotto varchar(100) 
				
				select 
					@StatoTecnicoLotto=LP.statoriga
						from 
							CTL_DOC m with (nolock) 
								inner join CTL_DOC D with (nolock) on d.deleted = 0 and  m.LinkedDoc = d.linkedDoc and d.TipoDoc = 'PDA_MICROLOTTI'
								--inner join Document_PDA_OFFERTE o on o.IdMsgFornitore = m.id and d.id = o.idheader
								inner join Document_MicroLotti_Dettagli LP with (nolock) on d.id = LP.IdHeader and LP.TipoDoc = 'PDA_MICROLOTTI' and LP.NumeroLotto = '1'  and LP.Voce = 0 
						where   
							m.id = @IdDoc 
							
				if  @StatoTecnicoLotto  in ( 'InValutazione','daValutare' )
					set @Blocco = 'Per aprire la busta Econimica e'' necessario terminare la valutazione Tecnica'
						
						
				if @Blocco = '' and ( @CriterioAggiudicazioneGara = '15532' or @CriterioAggiudicazioneGara = '25532' ) 
								and exists ( select o.IdRow  
												from 
													Document_PDA_OFFERTE o with (nolock)
														left outer join CTL_DOC_VALUE D with (nolock) on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_TECNICA' and D.DZT_Name = 'LettaBusta' 
												where 
													o.idHeader = @idPDA and o.StatoPDA <> '99' and o.StatoPDA <> '1' and D.idHeader is null 
											)
				begin
					set @Blocco = 'Per aprire la busta Economica e'' necessario aprire prima tutte le buste di tecniche'
				end
				if  @Blocco = '' and exists( select o.idrow 
												from 
													Document_PDA_OFFERTE o with (nolock) 
														left outer join CTL_DOC_VALUE D with (nolock) on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
												where 
													o.idHeader = @idPDA and o.StatoPDA <> '99' and o.StatoPDA <> '1' and D.idHeader is null )
				begin
					set @Blocco = 'Per aprire la busta Economica e'' necessario aprire prima tutte le buste di documentazione'
				end


				--controllo che offerta non è esclusa nella fase tecnica
				if @Blocco = '' and exists(
										select o.idrow 
											from Document_PDA_OFFERTE o with (nolock)
													inner join Document_MicroLotti_Dettagli LP with (nolock) on o.idRow = LP.IdHeader and LP.TipoDoc = 'PDA_OFFERTE' and LP.StatoRiga = 'escluso' and LP.Voce = 0 
											where  
												o.idHeader = @idPDA and o.idmsg = @IdDoc and o.TipoDoc='OFFERTA'
										)
				begin
					set @Blocco = 'Lo stato del documento non consente l''apertura della busta'
				end


			end
			else
			begin
				if exists( select o.idrow 
								from Document_PDA_OFFERTE o with (nolock)
										left outer join CTL_DOC_VALUE D with (nolock) on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
								where 
									o.idHeader = @idPDA and o.StatoPDA <> '99' and o.StatoPDA <> '1' and D.idHeader is null )
				begin
					set @Blocco = 'Per aprire la busta Economica e'' necessario aprire prima tutte le buste di documentazione'
				end
			end
		end

		-- verifico che il documento arrivato prima di questo sia stato aperto
		if @Blocco = ''
		begin


			-- se è la prima arrivata non esclusa si puo aprire
			if not exists( select 
							top 1 idrow 
								from 
									Document_PDA_OFFERTE with (nolock) 
								where @idPDA = idHeader 
									and idMsg = @IdDoc 
									and cast( NumRiga as int )  = ( select min(cast( NumRiga as int ) )  
																	from Document_PDA_OFFERTE with (nolock) 
																	where @idPDA = idHeader and StatoPDA <> '99' and StatoPDA <> '1' )
						)
			begin

				-- se esiste una offerta arrivata prima che non è stata aperta blocco la busta
				if @SectionName = 'BUSTA_ECONOMICA'  or @SectionName = 'BUSTA_TECNICA'
				begin

					if exists( select top 1 idrow from Document_PDA_OFFERTE with (nolock) 
									where @idPDA = idHeader 
										and idMsg = @IdDoc 
										and cast( NumRiga as int )  > ( -- la prima busta non letta relativa al lotto in esame
																		select min(NumRiga)  
																			from Document_PDA_OFFERTE o with (nolock) 
																				--inner join Document_MicroLotti_Dettagli L on o.IdMsgFornitore = L.IdHeader and L.TipoDoc = 'OFFERTA' and L.NumeroLotto = @NumeroLotto and L.Voce = 0 
																					inner join Document_MicroLotti_Dettagli LP with (nolock) on o.idRow = LP.IdHeader and LP.TipoDoc = 'PDA_OFFERTE' and LP.StatoRiga not in ( 'esclusoEco', 'escluso') and LP.Voce = 0 
																					left outer join CTL_DOC_VALUE D with (nolock) on o.idMsg = D.idHeader 
																													and D.DSE_ID = @SectionName 
																													and D.DZT_Name = 'LettaBusta' 
																													--and D.Row = L.id
																			where o.idHeader = @idPDA and o.StatoPDA <> '99' and D.idHeader is null 
													
																		)
								)
							-- viene esclusa dal controllo di sequenza la busta tecnica delle conformità ex-post
							and not ( @SectionName = 'BUSTA_TECNICA'  and @conformita='ex-post'  )

							-- non viene fatto il controllo di sequenza se richiesto dal parametro passato in input
							and @NoSquenza = 0
					begin
						set @Blocco = 'Per aprire la busta e'' necessario rispettare la sequenza di arrivo delle offerte'
					end


				end
				else
							
				begin
					--se lista lotti non devo controllare la sequenza di apertura
					if @SectionName <> 'LISTA_LOTTI'
					begin

						-- non effettuo il controllo di sequenza apertura  nel caso in cui si è richiesta una apertura contemporanea di tutti i documenti
						-- in questo trovero il record senza l'acronimo BUSTA esempio : DOCUMENTAZIONE,ECONOMICA,TECNICA
						if not exists( select idrow from  CTL_DOC_VALUE with (nolock) where idHeader = @IdDoc and DSE_ID = replace( @SectionName , 'BUSTA_' , '' ) and DZT_Name = 'LettaBusta'  )
						begin

							if exists( select top 1 idrow from Document_PDA_OFFERTE with (nolock) 
											where @idPDA = idHeader and idMsg = @IdDoc 
												and cast( NumRiga as int )  > 
																	(	-- la prima busta non letta
																		select min(cast( NumRiga as int ) )  
																			from Document_PDA_OFFERTE o with (nolock) 
																				left outer join CTL_DOC_VALUE D with (nolock) on o.idMsg = D.idHeader 
																												and D.DSE_ID = @SectionName 
																												and D.DZT_Name = 'LettaBusta' 
																			where o.idHeader = @idPDA and o.StatoPDA <> '99' and o.StatoPDA <> '1' and D.idHeader is null 
																	)
										)
							begin
								set @Blocco = 'Per aprire la busta e'' necessario rispettare la sequenza di arrivo delle offerte'
							end
						end
					end
				end
			end
		end


		if @Blocco = ''  
		BEGIN
			IF NOT EXISTS (select IdRow from CTL_DOC_Value with (nolock) where IdHeader=@IdDoc and DSE_ID=@SectionName and DZT_Name='richiesta_apertura_busta' and value='1')
			BEGIN
				if @SectionName = 'BUSTA_TECNICA' and  @Conformita <> 'Ex-Post'
					set @Blocco='L''apertura della busta Tecnica deve avvenire dalla scheda "Valutazione Tecnica" della Procedura di Aggiudicazione'
				if @SectionName = 'BUSTA_ECONOMICA'
					set @Blocco='L''apertura della busta Economica deve avvenire dalla scheda "Riepilogo Finale" della Procedura di Aggiudicazione'
			END
		END


	end


	select @Blocco as Blocco 



	
END





GO
