USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_COMUNICAZIONE_CREATE_FROM_OFFERTA_MIGLIORATIVA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_PDA_COMUNICAZIONE_CREATE_FROM_OFFERTA_MIGLIORATIVA] 
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
	declare @DataScadenza as datetime
	set @DataScadenza=DATEADD(hh,13,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE())))

	-- verifica l'esistenza di un documento salvato
	set @id = 0
	select @id = id 
		from CTL_DOC 
		where tipodoc = 'PDA_COMUNICAZIONE' 
				and linkedDoc = @idDoc 
				and ( statodoc = 'Saved' or ( statodoc = 'Sended ' and DataScadenza > getdate()))
				and JumpCheck = '1-OFFERTA'
				and deleted = 0
		
	if isnull( @id , 0 ) = 0
	begin


		Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc
		
		---Insert nella CTL_DOC per creare la comunicazione 
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataScadenza,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
		VALUES(@IdUser,'PDA_COMUNICAZIONE','Comunicazione di Offerta Migliorativa',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataScadenza,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-OFFERTA')

			
		set @Id = @@identity	

		---inserisco la riga per tracciare la cronologia nella PDA
		declare @userRole as varchar(100)
		select    @userRole= isnull( attvalue,'')
			from ctl_doc d 
				left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @id

			
		insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Creazione Richiesta di Offerta Migliorativa' , @IdUser , @userRole   , 1  , getdate() )
			
		
		--inserisco riga nella ctl_doc_value 
		insert into CTL_DOC_VALUE 
			(IdHeader, DSE_ID, Row, DZT_Name, Value)
		values
			(@Id, 'DIRIGENTE','0','RichiestaRisposta','si')
			
					
		declare @getDate datetime
		set @getDate = getDate()		

		declare @ML_Note nvarchar (4000)
		set @ML_Note = dbo.CNV( 'ML_Si richiede offerta migliorativa per gli articoli riportati di seguito' , 'I' )


		-- lista dei fornitori - creiamo le singole richiesta di offerta migliorativa
		insert into CTL_DOC (IdPfu,TipoDoc					  ,Titolo					,Fascicolo ,LinkedDoc,Body ,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda    ,Destinatario_Azi ,Data   ,Note,JumpCheck , PrevDoc , RichiestaFirma ) 
			select  @IdPfu,'PDA_COMUNICAZIONE_OFFERTA','Richiesta Offerta Migliorativa',@Fascicolo,@Id      ,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,@getDate,@ML_Note,'1-OFFERTA' , IdMsg ,case when RequestSignTemp <> '3' then 1 else 0 end
				from Document_PDA_OFFERTE o
						inner join Document_PDA_TESTATA t on o.idheader = t.idHeader
				where o.idHEader=@idDoc 
					and o.idRow in ( select distinct o.idrow  
										from Document_PDA_OFFERTE o 
											inner join Document_MicroLotti_Dettagli d  
													on d.idheader = o.idrow		
														and d.tipodoc = 'PDA_OFFERTE' 
														and Exequo = 1
										where o.idHEader=@idDoc 
									)

		-- aggiungiamo le righe per le quali fornire l'offerta migliorativa
		--insert into Document_MicroLotti_Dettagli ( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere ,ImportoBaseAsta)
		--	select d.id as IdHeader, 'PDA_COMUNICAZIONE_OFFERTA' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere , ImportoBaseAsta
		--		from Document_PDA_OFFERTE o
		--			inner join CTL_DOC d on d.PrevDoc = o.IdMsg and d.LinkedDoc = @Id
		--			inner join Document_MicroLotti_Dettagli m on m.idHeader = o.idRow and m.Exequo = 1 and m.tipodoc = 'PDA_OFFERTE' 
		--		where o.idHEader=@idDoc 
		--		order by d.id , m.id


		declare @IdHeader INT
		declare @IdRow INT
		declare @idr INT
		declare CurProg Cursor Static for 
		select d.id as IdHeader , m.id as IdRow
					from Document_PDA_OFFERTE o
					inner join CTL_DOC d on d.PrevDoc = o.IdMsg and d.LinkedDoc = @Id
					inner join Document_MicroLotti_Dettagli m on m.idHeader = o.idRow and m.Exequo = 1 and m.tipodoc = 'PDA_OFFERTE' 
				where o.idHEader=@idDoc 
				order by d.id , m.id

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @IdHeader,@IdRow
			WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga )
						select @IdHeader , 'PDA_COMUNICAZIONE_OFFERTA' as TipoDoc,'' as StatoRiga
					set @idr = @@identity				
					-- ricopio tutti i valori
					exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow  , @idr , ',Id,IdHeader,TipoDoc,'			 
					 FETCH NEXT FROM CurProg 
				   INTO @IdHeader,@IdRow
				 END 

		CLOSE CurProg
		DEALLOCATE CurProg

		-- definisce il modello di offerta da usare
		declare @MOD_Name varchar(100)
		select @MOD_Name = m.ModelloOfferta 
			from Document_PDA_TESTATA t
				inner join Document_Modelli_MicroLotti m on t.ListaModelliMicrolotti = m.Codice
			where t.idHeader = @idDoc

		insert into CTL_DOC_SECTION_MODEL (IdHeader ,  DSE_ID , MOD_Name ) 
			select d.id , 'OFFERTA' , @MOD_Name
				from Document_PDA_OFFERTE o
					inner join CTL_DOC d on d.PrevDoc = o.IdMsg and d.LinkedDoc = @Id
				where o.idHEader=@idDoc 
				order by d.id

	end

	-- ritorna l'id della nuova comunicazione appena creata
	select @Id as id

END




GO
