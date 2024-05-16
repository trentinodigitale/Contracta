USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_AMPIEZZA_DI_GAMMA_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--exec OFFERTA_AMPIEZZA_DI_GAMMA_CREATE_FROM_OFFERTA 485334,45828


CREATE PROCEDURE [dbo].[OFFERTA_AMPIEZZA_DI_GAMMA_CREATE_FROM_OFFERTA] 
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

	set @Id = 0
	set @BandoAlPrezzoConformita = '0'
	set @ModAmpGammaEconomico = '0'
	set @ModAmpGammaTecnico = '0'
	set @ModAmpGammaTecnicoEconomico = '0'
	
	SET NOCOUNT ON

	--mi prendo i paramentri di lottvoce nella ctl_import
	select @lottoVoceSelezionato = A from CTL_Import with(nolock) where idPfu = @IdUser
			
	set @lotto = dbo.GetPos(@lottoVoceSelezionato, '-', 1)
	set @voce = dbo.GetPos(@lottoVoceSelezionato, '-', 2)

	--vede se deve gestire la nuova ampiezza di gamma o la vecchia
	declare @New_Amp_Gamma as varchar(1)

	set @New_Amp_Gamma =  dbo.IsNewOffertaGamma(@idDoc,default)
	
	declare @Errore as nvarchar(2000)
	set @Errore=''
	
	if @New_Amp_Gamma<>'1' -- caso vecchio
	begin

		if exists (select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' and VersioneLinkedDoc = @lotto + '-' + @voce and Deleted = 0)
			begin
				select @Id = id 
					from CTL_DOC with(nolock)
					where LinkedDoc = @idDoc and TipoDoc = 'OFFERTA_AMPIEZZA_DI_GAMMA' and VersioneLinkedDoc = @lotto + '-' + @voce and Deleted = 0
			end
		else
			begin 
			
				--acquisizione dati 
				select @azienda = pfuIdAzi 
					from ProfiliUtente where IdPfu = @idUser

				select 
						@idbando = doc.LinkedDoc,
						@descrizioneLotto = lot.Descrizione, 
						@CIGLotto = lot.CIG
					from ctl_doc as doc with(nolock) 
						inner join Document_MicroLotti_Dettagli as lot with(nolock) on doc.Id = LOT.IdHeader and Voce = '0' and NumeroLotto = @lotto
				where doc.id = @idDoc --bando
			
				select @idmodelloAcquisto = Value						
					from CTL_DOC_Value with(nolock)
					where idheader = @idbando and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' --idModello acquisto

				select @idmodelloAmpiezzaGamma = Value 
					from CTL_DOC_Value with(nolock)
					where IdHeader = @idmodelloAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma' --idmodelloAmpiezzaGamma


				insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, LinkedDoc, VersioneLinkedDoc, NumeroDocumento, Body, Azienda) 
					values (@idUser,  'OFFERTA_AMPIEZZA_DI_GAMMA' , 'Saved' , @idDoc , @lottoVoceSelezionato, @CIGLotto, @descrizioneLotto, @azienda)

				set @Id = SCOPE_IDENTITY()

			

				--controllo se il bando è al prezzo senza conformita
				if exists (select idLotto from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO with(nolock) where idBando = @idbando and CriterioAggiudicazioneGara = 15536 and Conformita = 'no' and idLotto in ( select id from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @idbando and AmpiezzaGamma = 1))
					set @BandoAlPrezzoConformita = '1'
			
				--controllo se il modello di ampiezza di gamma prevede busta economica 
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_Offerta' and DSE_ID = 'MODELLI' and Value <> '')  
					set @ModAmpGammaEconomico = '1'

				--controllo se il modello di ampiezza di gamma prevede busta tecnica 
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaTec' and DSE_ID = 'MODELLI' and Value <> '')  
					set @ModAmpGammaTecnico = '1'

				--controllo se il modello di ampiezza di gamma prevede busta economica e tecnica
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaINPUT' and DSE_ID = 'MODELLI' and Value <> '')  
					set @ModAmpGammaTecnicoEconomico = '1'

				--associo i modelli

				select @nomeModelloAmpGamma = Titolo from CTL_DOC where id = @idmodelloAmpiezzaGamma

				--if (@ModAmpGammaTecnico = '1' and @BandoAlPrezzoConformita <> '1')
				--begin 
				--	--set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaTec'

				--	insert into ctl_doc_value (IdHeader, DSE_ID, Row, DZT_Name, Value)
				--		values(@Id, 'TESTATA_PRODOTTI', 0, 'Tipo_Modello_AmpiezzaGamma', @nomeModelloAmpGammaTemp)
				--end

				--if (@ModAmpGammaEconomico = '1')
				--begin 

				--	--set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_Offerta'

				--	--INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
				--	--	 VALUES(@Id,'PRODOTTI',@nomeModelloAmpGammaTemp)
				
				--end

				if (@ModAmpGammaTecnicoEconomico = '1')
				begin 
					set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT'

					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
						 VALUES(@Id,'PRODOTTI',@nomeModelloAmpGammaTemp)

					insert into ctl_doc_value (IdHeader, DSE_ID, Row, DZT_Name, Value)
						values(@Id, 'MODELLI', 0, 'ModelloAmpiezzaDamma', @nomeModelloAmpGammaTemp)

					insert into ctl_doc_value (IdHeader, DSE_ID, Row, DZT_Name, Value)
						values(@Id, 'TESTATA_PRODOTTI', 0, 'Tipo_Modello_AmpiezzaGamma', @nomeModelloAmpGammaTemp)
				end

			end
		
		end --if @New_Amp_Gamma<>'1' -- caso vecchio
	else
	begin -- caso nuovo
		
		select @id = idheaderlotto 
			from Document_microlotti_dettagli m with(nolock)
				where IdHeader = @idDoc and TipoDoc = 'OFFERTA' and NumeroLotto = @lotto and Voce = @voce

		if not exists(select id 
			from Document_microlotti_dettagli m with(nolock)
				where IdHeader = @idDoc and TipoDoc = 'OFFERTA_AMPIEZZA' 
					and NumeroLotto = @lotto and idheaderlotto=@id)		
						--set @Errore='Inserire ampiezza di gamma per il lotto ' + @lotto + ' nel folder dedicato ed eseguire il comando verifica informazioni'
						set @Errore= 'ERRORE_MANCANZA_AMPIEZZA_GAMMA'

		if @Errore='' and exists(select id 
			from Document_microlotti_dettagli m with(nolock)
				where IdHeader = @idDoc and TipoDoc = 'OFFERTA_AMPIEZZA' 
					and NumeroLotto = @lotto and idheaderlotto=@id and EsitoRiga not like '%state_ok.gif%' )		
						--set @Errore='Eseguire il comando verifica informazioni ampiezza di gamma nel folder dedicato'
						set @Errore= 'ERRORE_MANCANZA_AMPIEZZA_GAMMA'

		--if @Errore <> ''
			--set @Errore = 'NO_ML###' + @Errore
	end

	if @Errore <> ''
	BEGIN
		select 'ERRORE' as id ,  @Errore + '~~@TITLE=Attenzione~~@ICON=4'   as Errore
	END
	else
	begin
		if @New_Amp_Gamma<>'1' -- caso vecchio
			select @id as id
		else
			select @id as id,'OFFERTA_AMPIEZZA' as TYPE_TO
	end

END















GO
