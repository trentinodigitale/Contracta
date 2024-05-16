USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Gestione_Modifiche_Bando_QF]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[Gestione_Modifiche_Bando_QF] ( @IdBando int  , @IdVar int , @IdPfu int )
AS
BEGIN
	
	

	SET NOCOUNT ON

		------------------------------------------------------------------
		-- vede se è stato variato un dato significativo
		------------------------------------------------------------------

		declare @merc varchar(max)
		declare @merc_var varchar(max)
		declare @AreaVal varchar(max)
		declare @AreaVal_var varchar(max)
		declare @esito int
		declare @NotificaVar char(2)
		declare @IdBandoOrig int

		select @IdBandoOrig=prevdoc from CTL_DOC with (nolock) where Id = @IdVar

		set @NotificaVar = 'NO'

		select @merc = isnull(ArtClasMerceologica ,''),@AreaVal=isnull(AreaValutazione ,'')
			from document_bando with (nolock)
				where idHeader  = @IdBando

		select @merc_var = isnull(ArtClasMerceologica ,''),@AreaVal_var=isnull(AreaValutazione ,'')
			from document_bando with (nolock)
				where idHeader  = @IdVar
		
		if @AreaVal <> @AreaVal_var
			set @NotificaVar = 'SI'

		if @NotificaVar = 'NO'
		begin
			-- la prima merc è quella originale e la seconda quella variata, 
			--se torna esito = 0 allora bisogna segnalare al forn la variazione
			exec CompareMercBandoQF @merc,@merc_var, @esito output
			if @esito = 0
				set @NotificaVar = 'SI'

		end

		-- vede se è variato uno dei documenti allegati richiesti e obbligatori
		if @NotificaVar = 'NO'
		begin
			

			if exists(
						select idrow from Document_Bando_DocumentazioneRichiesta with (nolock)
							where idHeader = @IdBando and [Obbligatorio]=1
								and AnagDoc not in (
													select AnagDoc
														from Document_Bando_DocumentazioneRichiesta with (nolock)
															where idHeader = @IdVar  and [Obbligatorio]=1
													)
						)
			begin
				set @NotificaVar = 'SI'
			end


		end

		if @NotificaVar = 'NO'
		begin
			

			if exists(
						select idrow from Document_Bando_DocumentazioneRichiesta with (nolock)
							where idHeader = @IdVar and [Obbligatorio]=1
								and AnagDoc not in (
													select AnagDoc
														from Document_Bando_DocumentazioneRichiesta with (nolock)
															where idHeader = @IdBando  and [Obbligatorio]=1
													)
						)
			begin
				set @NotificaVar = 'SI'
			end


		end

		if @NotificaVar = 'NO'
		begin
			
			declare @cnt1 int
			declare @cnt2 int

			set @cnt1=0
			set @cnt2=0

			
			select @cnt1=COUNT(*) from Document_Bando_DocumentazioneRichiesta with (nolock)
				where idHeader = @IdVar and [Obbligatorio]=1

			select @cnt2=COUNT(*) from Document_Bando_DocumentazioneRichiesta with (nolock)
				where idHeader = @IdBando and [Obbligatorio]=1
						
			if @cnt1 <> @cnt2
				set @NotificaVar = 'SI'

		end


		if @NotificaVar = 'NO'
		begin
			
			

			if exists(
						select a.idrow 
							from Document_Bando_DocumentazioneRichiesta a with (nolock)
								inner join Document_Bando_DocumentazioneRichiesta b with (nolock) on b.idHeader = @IdBando and a.AnagDoc = b.AnagDoc and b.[Obbligatorio]=1
									where a.idHeader = @IdVar and a.[Obbligatorio]=1
										and (	a.AllegatoRichiesto <> b.AllegatoRichiesto or
												a.AreaValutazione <> b.AreaValutazione or
												a.Peso <> b.Peso  or
												a.TipoValutazione <> b.TipoValutazione )
						)
			begin
				set @NotificaVar = 'SI'
			end

		end

		------------------------------------------------------------------		
		-- se ci sono state variazioni significative
		------------------------------------------------------------------
		if @NotificaVar = 'SI'
		begin


			------------------------------------------------------------------
			--if Avvisa_Forn_Cambiamento = si
			------------------------------------------------------------------
			if exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader = @IdVar and DSE_ID = 'Gestione_Modifiche'
						and DZT_Name = 'Avvisa_Forn_Cambiamento' and Value='si' )
			begin
				-- invia mail di avviso cambiamento a quelli che hanno inviato istanza
				-- ma per cui non si è conclusa la fase di qualificazione
					
				insert into CTL_Schedule_Process 
					( IdDoc ,IdUser ,DPR_DOC_ID ,DPR_ID ,State ,dateIn )					
				--select idrow,@IdPfu,'BANDO_QF','Avvisa_Forn_Cambiamento' ,0,GETDATE()
				--	from Document_Questionario_Fornitore_Punteggi with (nolock)
				--		where idHeader = @IdBandoOrig
							--and isnull(StatoAbilitazione,'') <> 'Sospeso'
				select distinct azienda ,@IdPfu,'BANDO_QF','Avvisa_Forn_Cambiamento' ,0,GETDATE()
					from CTL_DOC with (nolock)
						left outer join Document_Questionario_Fornitore_Punteggi with (nolock) on LinkedDoc=idHeader and Azienda=idazi
						where LinkedDoc = @IdBandoOrig
						and TipoDoc = 'ISTANZA_AlboOperaEco_QF'
						and Deleted=0
						and StatoFunzionale = 'Inviato'
						and idrow is null

			end  --if Avvisa_Forn_Cambiamento = si

			
			
			------------------------------------------------------------------
			--if Sospendi_Iscrizioni = si OR Richiedi_Nuova_Istanza = si
			------------------------------------------------------------------
			if exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader = @IdVar and DSE_ID = 'Gestione_Modifiche'
						and DZT_Name = 'Sospendi_Iscrizioni' and Value='si' ) OR
				exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader = @IdVar and DSE_ID = 'Gestione_Modifiche'
						and DZT_Name = 'Richiedi_Nuova_Istanza' and Value='si' )
			begin
				--- sospensione delle iscrizioni
				
				select idrow,idazi into #Temp from Document_Questionario_Fornitore_Punteggi with (nolock)
					where idHeader = @IdBandoOrig
							--and isnull(StatoAbilitazione,'') <> 'Sospeso'

				update Document_Questionario_Fornitore_Punteggi
					set StatoAbilitazione = 'Sospeso'
						where idHeader = @IdBandoOrig
							--and isnull(StatoAbilitazione,'') <> 'Sospeso'

				-- cancella documenti di esito qualificazione inviati
				update Document_Esito_Qualificazione set Deleted = 1
					where IdCom in (
								select IdCom from Document_Esito_Qualificazione a with (nolock)
									inner join Document_Questionario_Fornitore_Punteggi b with (nolock) on a.idrow=b.idrow and a.IdAzienda = b.IdAzi 
										where b.idHeader = @IdBandoOrig and StatoAbilitazione = 'Sospeso'
									)
				
				-- cancella istanze non ancora inviate su quel bando
				update CTL_DOC
					set Deleted = 1
						where TipoDoc =  'ISTANZA_AlboOperaEco_QF'  
							and LinkedDoc = @IdBandoOrig
							and Deleted=0
							and  Statofunzionale<>'Inviato'	
							and  Statofunzionale<>'Annullato'	
				
				-- annulla istanze  inviate su quel bando
				update CTL_DOC
					set Statofunzionale='Annullato'
						where TipoDoc =   'ISTANZA_AlboOperaEco_QF'  
							and LinkedDoc = @IdBandoOrig
							and Deleted=0
							and  Statofunzionale = 'Inviato'				
				
				-- cancella questionari aperti sulle istanze annullate
				update CTL_DOC				
					set Deleted = 1
						where tipodoc='QUESTIONARIO_FORNITORE'
							and deleted=0 and linkeddoc=@IdBandoOrig
							and NumeroDocumento in (
														select id from CTL_DOC with (nolock)
															where TipoDoc =   'ISTANZA_AlboOperaEco_QF'  
																and LinkedDoc = @IdBandoOrig
																and Deleted=0
																and Statofunzionale='Annullato'
													)

			
			
				------------------------------------------------------------------
				--if Invia_Notifica_Sospensione = si
				------------------------------------------------------------------
				if exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader = @IdVar and DSE_ID = 'Gestione_Modifiche'
							and DZT_Name = 'Invia_Notifica_Sospensione' and Value='si' )
				begin
					-- invia mail di notifica sospensione
					
					insert into CTL_Schedule_Process 
						( IdDoc ,IdUser ,DPR_DOC_ID ,DPR_ID ,State ,dateIn )					
					select idrow,@IdPfu,'BANDO_QF','Invia_Notifica_Sospensione' ,0,GETDATE()
						from #Temp

				end  --if Invia_Notifica_Sospensione = si
			
				------------------------------------------------------------------
				--if Richiedi_Nuova_Istanza = si
				------------------------------------------------------------------
				if exists(select idrow from CTL_DOC_Value with (nolock) where IdHeader = @IdVar and DSE_ID = 'Gestione_Modifiche'
						and DZT_Name = 'Richiedi_Nuova_Istanza' and Value='si' )
				begin
					
					-- inserisce nella lista attività
					insert into CTL_Attivita 
					(ATV_Object ,ATV_DateInsert ,ATV_Obbligatory ,ATV_Execute ,ATV_DocumentName ,ATV_IdDoc ,ATV_IdAzi ,ATV_IdPfu )
					select distinct 'Richiesta Nuova Istanza per Bando Variato',GETDATE(),'no','no','BANDO_FORN_QF',@IdBandoOrig,idazi,idpfu
						from #Temp
							inner join ProfiliUtente with (nolock) on idazi=pfuidazi

						

				end -- if Richiedi_Nuova_Istanza = si
			
			
			end -- if Sospendi_Iscrizioni = si


			



		end --if @NotificaVar = 'SI'
		

END

GO
