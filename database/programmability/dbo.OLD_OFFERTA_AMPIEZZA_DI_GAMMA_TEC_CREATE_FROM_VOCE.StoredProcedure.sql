USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_OFFERTA_AMPIEZZA_DI_GAMMA_TEC_CREATE_FROM_VOCE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD_OFFERTA_AMPIEZZA_DI_GAMMA_TEC_CREATE_FROM_VOCE] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @voce varchar(10)
	declare @lotto varchar(10)
	declare @idbando int
	declare @idmodelloAcquisto int
	declare @idmodelloAmpiezzaGamma int
	declare @lottoVoceSelezionato varchar(1000)
	declare @CIGLotto varchar(1000)
	declare @descrizioneLotto varchar(1000)
	declare @BandoAlPrezzoConformita varchar(1)
	declare @ModAmpGammaTecnico varchar(1)
	declare @ModAmpGammaEconomico varchar(1)
	declare @ModAmpGammaTecnicoEconomico varchar(1)
	declare @azienda varchar(100)
	declare @nomeModelloAmpGamma varchar(1000)
	declare @nomeModelloAmpGammaTemp varchar(1000)
	declare @idOfferta int
	declare @idOffertaAmpGamma int
	declare @idOffertaAmpGammaTec int
	declare @errore varchar(max)
	declare @aziAcquirente int
	declare @bandolotti varchar(10)

	set @Id = 0
	set @BandoAlPrezzoConformita = '0'
	set @ModAmpGammaEconomico = '0'
	set @ModAmpGammaTecnico = '0'
	set @ModAmpGammaTecnicoEconomico = '0'
	set @idOffertaAmpGamma = 0
	set @idOffertaAmpGammaTec = 0
	set @errore = ''

	SET NOCOUNT ON

	--mi prendo i paramentri di lottvoce nella ctl_import
	select @lottoVoceSelezionato = A from CTL_Import with(nolock) where idPfu = @IdUser
	set @lotto = dbo.GetPos(@lottoVoceSelezionato, '-', 1)
	set @voce = dbo.GetPos(@lottoVoceSelezionato, '-', 2)

	--risalgo all'offerta
	if exists(select Id from CTL_DOC with(nolock) where id = @idDoc and tipodoc like 'PDA_VALUTA_LOTTO%' )
	begin
		select @idOfferta = l1.idmsg
			from CTL_DOC PDA with(nolock)
				inner join Document_MicroLotti_Dettagli as l with(nolock) on l.id = PDA.LinkedDoc
				inner join Document_pda_offerte as l1  with(nolock) on l1.idrow = l.idHeader			
			where pda.Id = @idDoc 	
	end	
	else
	begin -- altrimenti il punto di partenza è la riga del lotto
		select @idOfferta = l1.IdHeader
			from  Document_MicroLotti_Dettagli as l
				inner join Document_MicroLotti_Dettagli as l1 on l1.id = l.idHeaderLotto			
			where l.Id = @idDoc 
	end

	
	declare @idpfuCompilatore int

	--mi prendo l'id del documento di offerta ampiezza di gamma
	select @idOffertaAmpGamma = isnull(id, 0)  , @idpfuCompilatore = idpfu from CTL_DOC with(nolock) where LinkedDoc = @idOfferta and TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' and VersioneLinkedDoc = @lotto + '-' + @voce and Deleted = 0
	
	
	--vede se deve gestire la nuova ampiezza di gamma o la vecchia
	declare @New_Amp_Gamma as varchar(1)

	set @New_Amp_Gamma =  dbo.IsNewOffertaGamma(@idOfferta,default)


	if @New_Amp_Gamma<>'1' -- caso vecchio
	begin
		if @idOffertaAmpGamma <> 0
		begin 

			select @aziAcquirente = a.aziAcquirente 
				from ProfiliUtente pu with(nolock)
					inner join Aziende a with(nolock) on pu.pfuIdAzi = a.IdAzi and pu.IdPfu = @idUser

			if @idUser <> @idpfuCompilatore
			begin 

			
				--se id user non è il compilatore ma un utente di tipo ente 
				if @aziAcquirente = 0
				begin
					set @errore = 'Contenuto non disponibile. Utente non autorizzato'
				end
				else
				begin
					--verifico se la gara ha lotti 
					select @bandolotti = ba.Divisione_lotti from CTL_DOC as offe with(nolock)
						inner join Document_Bando as ba with(nolock) on ba.idHeader = offe.LinkedDoc
					where offe.Id = @idOfferta

					--se è senza lotti
					if @bandolotti = '0'
						begin
							if not exists (select IdHeader from ctl_doc_value with(nolock) where IdHeader = @idOfferta and DSE_ID = 'OFFERTA_BUSTA_TEC' and DZT_Name = 'LettaBusta' and Value = '1' and Row = 0)
								set @errore = 'Prima di aprire offerta ampiezza di gamma è necessario aprire la busta offerta'								
						end
					else					
						begin
							if not exists (select IdRow from ctl_doc_value as o inner join Document_MicroLotti_Dettagli as od on od.Id = o.Row and NumeroLotto = @lotto where o.IdHeader = @idOfferta and o.DSE_ID = 'OFFERTA_BUSTA_TEC' and o.DZT_Name = 'LettaBusta' and o.Value = '1')
								set @errore = 'Prima di aprire offerta ampiezza di gamma è necessario aprire la busta offerta'
						end

					if @errore = ''
						begin
							--se non esistono prodotti con il campo descrizione in chiaro
							IF not EXISTS (select * FROM Document_MicroLotti_Dettagli WHERE IdHeader = @idOffertaAmpGamma AND Descrizione is not null)
								begin
									exec START_OFFERTA_CHECK_PRODUCT @idOffertaAmpGamma , @idUser
								end
						END

				end		
			end


			-- controllo la presenza del modello associata all'ampiezza di gamma 
			if not exists ( select idrow from CTL_DOC_SECTION_MODEL with(nolock) where idheader = @idOffertaAmpGamma and DSE_ID = 'PRODOTTI_TEC')
			begin


				select 
						@idbando = doc.LinkedDoc
					from ctl_doc as doc with(nolock) 
						inner join Document_MicroLotti_Dettagli as lot with(nolock) on doc.Id = LOT.IdHeader and Voce = '0' and NumeroLotto = @lotto
					where doc.id = @idOfferta -- recupero il bando
			
				select @idmodelloAcquisto = Value						
					from CTL_DOC_Value with(nolock)
					where idheader = @idbando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' --idModello acquisto

				select @idmodelloAmpiezzaGamma = Value 
					from CTL_DOC_Value with(nolock)
					where IdHeader = @idmodelloAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma' --idmodelloAmpiezzaGamma
			
				select @nomeModelloAmpGamma = Titolo from CTL_DOC where id = @idmodelloAmpiezzaGamma

				--controllo se il modello di ampiezza di gamma prevede busta tecnica 
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaTec' and DSE_ID = 'MODELLI' and Value <> '')  
				begin				
					--se nel modello di ampiezza di gamma è presente anche la busta economica apro il modello busta tecnica dedicata
					if exists(select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_Offerta' and DSE_ID = 'MODELLI' and Value <> '')
					begin
						set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaTec' -- se l'ampiezza di gamma prevede un modello dedicato
					end
					else --altrimenti apro offertaInput con tutti i campi presenti nel modello
					begin
						set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT' 
					end
				

					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
							 VALUES(@idOffertaAmpGamma,'PRODOTTI_TEC',@nomeModelloAmpGammaTemp)

				end
				else
				begin

					-- nel caso in cui non è prevista l'ampiezza di gamma tecnica non apriamo il documento
					set @errore = 'L''ampiezza di gamma non prevede la parte tecnica'			
				end

	
			end




		end 
		else
			begin 
				set @errore = 'Documento Ampiezza di Gamma non trovato'			
			end 
	end ----if @New_Amp_Gamma<>'1' -- caso vecchio
	else
	begin -- caso nuovo
		
		set @errore = ''
		select @id = idheaderlotto 
			from Document_microlotti_dettagli m with(nolock)
				where IdHeader = @idOfferta and TipoDoc = 'OFFERTA' and NumeroLotto = @lotto and Voce = @voce

		if not exists(select id 
			from Document_microlotti_dettagli m with(nolock)
				where IdHeader = @idOfferta and TipoDoc = 'OFFERTA_AMPIEZZA' 
					and NumeroLotto = @lotto and idheaderlotto=@id)		
						--set @Errore='Inserire ampiezza di gamma per il lotto ' + @lotto + ' nel folder dedicato ed eseguire il comando verifica informazioni'
						set @Errore= 'ERRORE_MANCANZA_AMPIEZZA_GAMMA'


		if @Errore='' and exists(select id 
			from Document_microlotti_dettagli m with(nolock)
				where IdHeader = @idOfferta and TipoDoc = 'OFFERTA_AMPIEZZA' 
					and NumeroLotto = @lotto and idheaderlotto=@id and EsitoRiga not like '%state_ok.gif%' )		
						--set @Errore='Eseguire il comando verifica informazioni ampiezza di gamma nel folder dedicato'
						set @Errore= 'ERRORE_MANCANZA_AMPIEZZA_GAMMA'
		
		if @Errore <> ''				
			--	set @Errore = 'NO_ML###' + @Errore + '~~@TITLE=Attenzione~~@ICON=4'
			set @Errore =  @Errore + '~~@TITLE=Attenzione~~@ICON=4'

	end


	if @errore = ''
		if @New_Amp_Gamma<>'1' -- caso vecchio
			select @idOffertaAmpGamma as id, 'OFFERTA_AMPIEZZA_DI_GAMMA_TEC' as TipoDoc		
		else
			select @id as id, 'OFFERTA_AMPIEZZA_TEC' as TYPE_TO	
	else
		select 'ERRORE' as id, @errore as Errore		

END















GO
