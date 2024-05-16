USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_OFFERTA_RISP_CREATE_FROM_PDA_COMUNICAZIONE_OFFERTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_OFFERTA_RISP_CREATE_FROM_PDA_COMUNICAZIONE_OFFERTA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
	declare @Destinatario_azi as INT
	declare @DataScadenza as datetime
	declare @RichiestaFirma as varchar(2)

	-- verifica l'esistenza di un documento salvato
	set @id = 0
	select @id = id 
		from CTL_DOC 
		where tipodoc = 'PDA_COMUNICAZIONE_OFFERTA_RISP' 
				and linkedDoc = @idDoc 
				--and statodoc = 'Saved'
		
	if isnull( @id , 0 ) = 0
	begin
			Select @IdPfu=IdPfu,@RichiestaFirma=RichiestaFirma,@DataScadenza=DataScadenza,@Destinatario_azi=Destinatario_azi,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Note,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc --and TipoDoc='PDA_COMUNICAZIONE_GARA' and Statodoc='Sended'
			
			---Insert nella CTL_DOC per creare la comunicazione risposta
		   insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,LinkedDoc,Azienda,StrutturaAziendale,Destinatario_user,Destinatario_azi,JumpCheck,DataScadenza,RichiestaFirma)
			values (@IdUser,'PDA_COMUNICAZIONE_OFFERTA_RISP','Offerta Migliorativa',@Fascicolo,@Body,@ProtocolloRiferimento,@idDoc,@azienda,@StrutturaAziendale,@IdPfu,@Destinatario_azi,'0-PDA_COMUNICAZIONE_OFFERTA_RISP',@DataScadenza,@RichiestaFirma)	
			set @Id = SCOPE_IDENTITY()	


			-- copio le righe da per le quali è necessario migliorare l'offerta
			--insert into Document_MicroLotti_Dettagli
			--	( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta) 
			--	select @Id as IdHeader, 'PDA_COMUNICAZIONE_OFFERTA_RISP' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta
			--		from Document_MicroLotti_Dettagli
			--		where IdHeader = @idDoc
			--		order by Id

		declare @IdHeader INT
		declare @IdRow INT
		declare @idr INT
		declare CurProg Cursor Static for 
		select @Id as IdHeader , id as IdRow
					from Document_MicroLotti_Dettagli
					where IdHeader = @idDoc
					order by Id

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @IdHeader,@IdRow
			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga )
						select @IdHeader , 'PDA_COMUNICAZIONE_OFFERTA_RISP' as TipoDoc,'' as StatoRiga
					set @idr = SCOPE_IDENTITY()				
					-- ricopio tutti i valori
					exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow  , @idr , ',Id,IdHeader,TipoDoc,'			 
					 FETCH NEXT FROM CurProg 
				   INTO @IdHeader,@IdRow
				 END 

		CLOSE CurProg
		DEALLOCATE CurProg



			-- copio il modello da usare
			insert into CTL_DOC_SECTION_MODEL (  IdHeader, DSE_ID, MOD_Name )
				select @Id as IdHeader, DSE_ID, MOD_Name 
					from CTL_DOC_SECTION_MODEL
					where IdHeader = @idDoc

	end

	-- ritorna l'id della nuova comunicazione appena creata
	select @Id as id

END






GO
