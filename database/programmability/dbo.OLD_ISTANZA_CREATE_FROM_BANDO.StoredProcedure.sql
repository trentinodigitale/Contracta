USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_ISTANZA_CREATE_FROM_BANDO]( @idOrigin as int, @idPfu as int = -20, @newId as int output ) 
AS
BEGIN
	--Versione=1&data=2014-09-22&Attivita=63141&Nominativo=Federico
	--Versione=2&data=2016-01-21&Attivita=97053&Nominativo=Enrico
	-- BEGIN TRAN

	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	declare @IdAzi as INT
	declare @Valore nvarchar (4000)
	declare @RagSoc		nvarchar( 500)
	declare @NaGi nvarchar( 500)
	declare @INDIRIZZOLEG nvarchar( 500)
	declare @LOCALITALEG nvarchar( 500)
	declare @LOCALITALEG2 nvarchar( 500)
	declare @CAPLEG nvarchar( 500)
	declare @PROVINCIALEG nvarchar( 500)
	declare @PROVINCIALEG2 nvarchar( 500)
	declare @NUMTEL nvarchar( 500)
	declare @NUMTEL2 nvarchar( 500)
	declare @NUMFAX nvarchar( 500)
	declare @EMail nvarchar( 500)
	declare @PIVA nvarchar( 500)
	declare @NomeRapLeg varchar(500)
	declare @CognomeRapLeg varchar(500)
	declare @CFRapLeg varchar(500)
	declare @TelefonoRapLeg varchar(500)
	declare @CellulareRapLeg varchar(500)
	declare @EmailRapLeg varchar(500)
	declare @RuoloRapLeg varchar(500)
	declare @STATOLOCALITALEG varchar(500)
	declare @STATOLOCALITALEG2 varchar(500)

	declare @errore as int
	set @errore = 0

	--select * from istanza_alboOperaEco_from_bando where id_from = 58673
	--select * from ISTANZA_AlboOperaEco_TESTATA_FROM_BANDO where id_from = 58673
	--select * from ISTANZA_AlboOperaEco_DISPLAY_ABILITAZIONI_FROM_BANDO where id_from = 58673
	--select * from ISTANZA_AlboOperaEco_DOCUMENTAZIONE_FROM_BANDO where id_from = 58673
	--select * from ctl_doc where id = 58679
	--select * from ctl_doc_value where idheader = 58679

	-- viste di createFrom delle sezioni che hanno il parametro view_from
	--	ISTANZA_AlboOperaEco_FROM_BANDO	 / DOCUMENT	/	CTL_DOC
	--	ISTANZA_AlboOperaEco_TESTATA_FROM_BANDO	 / TESTATA	/	CTL_DOC_Value  / FROM_USER_FIELD=idPfu
	--	ISTANZA_AlboOperaEco_DISPLAY_ABILITAZIONI_FROM_BANDO	 / DISPLAY_ABILITAZIONI	/	CTL_DOC_Value  / FROM_USER_FIELD=idPfu
	--	ISTANZA_AlboOperaEco_DOCUMENTAZIONE_FROM_BANDO	 / DOCUMENTAZIONE	/	CTL_DOC_Value
	
	-- variabili per la sezione DOCUMENT
	declare @fascicolo as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int
	declare @richiestaFirma as varchar(100)
	declare @sign_lock as int
	declare @sign_attach as varchar(400)
	declare @protocolloRiferimento as varchar(1000)
	declare @strutturaAziendale as varchar(4000)
	declare @TipoBando as varchar(500)
	declare @jumpcheck as varchar(500)
	declare @jumpcheck_ric_ist as varchar(500)
	declare @titolo as varchar(500)

	select @fascicolo = Fascicolo, 
		   @linkedDoc = LinkedDoc,
		   @prevDoc = PrevDoc,
		   @richiestaFirma = RichiestaFirma,
		   @sign_lock = Sign_lock,
		   @sign_attach = sign_attach,
		   @protocolloRiferimento = protocolloRiferimento,
		   @strutturaAziendale = strutturaAziendale
		  
		from ISTANZA_AlboOperaEco_FROM_BANDO where id_from = @idOrigin
	
	--recupero TipoBando dal bando per creare dinamicamente il tipo di istanza
	select @TipoBando=TipoBando,@jumpcheck=ISNULL(jumpcheck,'') from document_bando with(nolock) inner join ctl_doc with(nolock) on id=idheader where idheader=@idOrigin
	
	--mi serve per cercare l'ultima istanza conferm per la tipologia,mettendo ME non riuscivo a trovare l'istanza a causa di NULL e '' sul BANDO	
	set @jumpcheck_ric_ist=@jumpcheck
	
	if @jumpcheck=''
		set @jumpcheck='ME'
	
	set @titolo='Istanza Iscrizione'
	if @TipoBando in ('ALBO_ME_4','AlboLavori_2','AlboFornitori_2')
		set @titolo='Domanda di Ammissione'

	insert into CTL_DOC( idpfu,Titolo, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,idPfuInCharge)
		select @idPfu,@titolo, 'ISTANZA_' + @TipoBando , 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				,@fascicolo, @linkedDoc, @richiestaFirma,@sign_lock, @sign_attach, @protocolloRiferimento, @strutturaAziendale,@idPfu

	IF @@ERROR <> 0 
	BEGIN
		--set @errore = @@ERROR
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		--rollback tran
		return 99
	END 

	set @newId = SCOPE_IDENTITY()

	Select 
		 @IdAzi=p.pfuidazi 
	 	,@RagSoc=aziRagioneSociale 
		,@NaGi=aziIdDscFormasoc 
		,@INDIRIZZOLEG=aziIndirizzoLeg
		,@LOCALITALEG=aziLocalitaLeg 
		,@STATOLOCALITALEG=aziStatoLeg
		,@LOCALITALEG2=aziLocalitaLeg2
		,@STATOLOCALITALEG2=aziStatoLeg2
		,@CAPLEG=aziCAPLeg
		,@PROVINCIALEG=aziProvinciaLeg
		,@PROVINCIALEG2=aziProvinciaLeg2
		,@NUMTEL=aziTelefono1
		,@NUMTEL2=aziTelefono2 
		,@NUMFAX=aziFAX
		,@EMail=aziE_Mail
		,@PIVA=aziPartitaIVA 

		from profiliUtente p with(nolock)
				INNER JOIN aziende a with(nolock) ON p.pfuidazi = a.idazi
		where idpfu=@idPfu

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'RagSoc', @RagSoc)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'NaGi', @NaGi)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'STATOLOCALITALEG', @STATOLOCALITALEG)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'STATOLOCALITALEG2', @STATOLOCALITALEG2)
	
	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'INDIRIZZOLEG', @INDIRIZZOLEG)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'LOCALITALEG', @LOCALITALEG)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'LOCALITALEG2', @LOCALITALEG2)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'CAPLEG', @CAPLEG)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'PROVINCIALEG', @PROVINCIALEG)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'PROVINCIALEG2', @PROVINCIALEG2)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'NUMTEL', @NUMTEL)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'NUMTEL2', @NUMTEL2)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'NUMFAX', @NUMFAX)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA2', 0, 'EMail', @EMail)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'PIVA', @PIVA)

	
	if left(@TipoBando,8)='AlboProf'
	begin
		--popolo la sezione STUDIO_ASSOCIATO
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'AziRagioneSociale', @RagSoc)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'NaGi', @NaGi)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'Sede', @INDIRIZZOLEG)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'STATOLOCALITALEG', @STATOLOCALITALEG)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'STATOLOCALITALEG2', @STATOLOCALITALEG2)
		
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'aziLocalitaLeg', @LOCALITALEG)
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'aziLocalitaLeg2', @LOCALITALEG2)


		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'aziCAPLeg', @CAPLEG)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'aziProvinciaLeg', @PROVINCIALEG)
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'aziProvinciaLeg2', @PROVINCIALEG2)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'NUMTEL', @NUMTEL)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'NUMFAX', @NUMFAX)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'EmailAssociato', @EMail)
		
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'PIVAassociato', @PIVA)
		
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'PROVINCIALEG', @PROVINCIALEG)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'PROVINCIALEG2', @PROVINCIALEG2)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'LOCALITALEG', @LOCALITALEG)

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			VALUES (@newId, 'STUDIO_ASSOCIATO', 0, 'LOCALITALEG2', @LOCALITALEG2)
		
		execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'SedeCCIAA' , @newId ,'STUDIO_ASSOCIATO' 
		execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'IscrCCIAA' , @newId ,'STUDIO_ASSOCIATO'

		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		--select    
		--	@newId, 'STUDIO_ASSOCIATO', 0, 'CFRapLegassociato', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'CFRapLeg'

		select    
			@newId, 'STUDIO_ASSOCIATO', 0, 'CFRapLegassociato', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'codicefiscale'

	
	end



	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'NomeRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'CognomeRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'LocalitaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'DataRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'CFRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'TelefonoRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'CellulareRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'EmailRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ResidenzaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ProvResidenzaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'IndResidenzaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'CapResidenzaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ProvinciaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'RuoloRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'NumProcura' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'DelProcura' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'NumRaccolta' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'codicefiscale' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ANNOCOSTITUZIONE' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'SedeCCIAA' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'IscrCCIAA' , @newId ,'TESTATA' 

	IF EXISTS (Select * from CTL_DOC_Value with(nolock)  where IdHeader=@newId and DZT_Name='ANNOCOSTITUZIONE' and value <> '')
	BEGIN
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'BelongCCIAA', 'SI')
	END
	ELSE
	BEGIN
		INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'BelongCCIAA', '')
	END

	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'EmailRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'StatoRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'StatoResidenzaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'StatoResidenzaRapLeg2' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'StatoRapLeg2' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'LocalitaRapLeg2' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ProvResidenzaRapLeg2' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ResidenzaRapLeg2' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ProvinciaRapLeg' , @newId ,'TESTATA' 
	execute INS_CTL_DOC_Value_DA_DMATTR @IdAzi, 'ProvinciaRapLeg2' , @newId ,'TESTATA' 

	--set @tabella = 'ISTANZA_AlboOperaEco_TESTATA_FROM_BANDO'
	--set @model = 'ISTANZA_AlboOperaEco_TESTATA'

	--exec GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL 
	--		@tabella,
	--		@model,
	--		@newId,
	--		@idOrigin,
	--		'TESTATA',
	--		'idPfu',
	--		@idPfu,
	--		@output output

	--exec ( @output )

	IF @@ERROR <> 0 
	BEGIN	
		--set @errore = @@ERROR
		raiserror ('Errore popolamento TESTATA.  ', 16, 1 ) --, CAST(@@ERROR AS NVARCHAR(4000)))
		--rollback tran
		return 99
	END

	---COMMENTATO QUESTO STEP, IL QUALE RECUPERAVA LE CLASSIISCRIZ E GERARCHICOSOA DELL'AZIENDA E LI METTE SULL'ISTANZA
	---NON VA BENE VISTO LA MANCATA COERENZA CON LE CLASSI DEL BANDO
	
	/*
	set @tabella = 'ISTANZA_AlboOperaEco_DISPLAY_ABILITAZIONI_FROM_BANDO'
	set @model = 'ISTANZA_AlboOperaEco_DISPLAY_ABILITAZIONI_SAVE'

	exec GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL 
			@tabella,
			@model,
			@newId,
			@idOrigin,
			'DISPLAY_ABILITAZIONI',
			'idPfu',
			@idPfu,
			@output output

	exec ( @output )

	IF @@ERROR <> 0 
	BEGIN
		--set @errore = @@ERROR
		raiserror ('Errore popolamento DISPLAY_ABILITAZIONI.  ', 16, 1 ) --, CAST(@@ERROR AS NVARCHAR(4000)))
		--rollback tran
		return 99
	END 
	*/

	set @tabella = 'ISTANZA_AlboOperaEco_DOCUMENTAZIONE_FROM_BANDO'
	set @model = 'ISTANZA_AlboOperaEco_DOCUMENTAZIONE'

	-- idHeader
	-- dse_id   = DOCUMENTAZIONE
	-- row      = incrementale da 0
	-- dzt_name = Allegato, AnagDoc, Descrizione, idRow, NotEditable, Obbligatorio, TipoEstensione, TipoFile
	declare @Allegato varchar(1000)
	declare @AnagDoc varchar(1000)
	declare @Descrizione nvarchar(4000)
	declare @idRow int
	declare @NotEditable varchar(400)
	declare @Obbligatorio int
	declare @TipoEstensione varchar(4000)
	declare @TipoFile varchar(4000)
	declare @richiediFirma varchar(400)

	declare @sql nvarchar(max)

	declare @riga int
	set @riga = 0
	set @richiediFirma = '0'

	DECLARE cur1 CURSOR STATIC FOR
		select isnull(Allegato,''), isnull(AnagDoc,''), isnull(Descrizione,''), isnull(idRow,''), isnull(NotEditable,''), isnull(Obbligatorio,''), isnull(TipoEstensione,''), isnull(TipoFile,''), isnull(richiediFirma,'')
			from ISTANZA_AlboOperaEco_DOCUMENTAZIONE_FROM_BANDO where id_from = @idOrigin		

	OPEN cur1 
	FETCH NEXT FROM cur1 INTO @Allegato,@AnagDoc,@Descrizione,@idRow,@NotEditable,@Obbligatorio,@TipoEstensione,@TipoFile, @richiediFirma


        BEGIN TRY
        
	        WHILE @@FETCH_STATUS = 0   
	        BEGIN
        		
		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'Allegato', @Allegato)

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'AnagDoc', @AnagDoc)

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'Descrizione', @Descrizione)

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'idRow', cast(@idRow as varchar(10)))

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'NotEditable', @NotEditable)

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'Obbligatorio', @Obbligatorio)

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'TipoEstensione', @TipoEstensione)

		        INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'TipoFile', @TipoFile)

				INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			        VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'RichiediFirma', @richiediFirma)

		        set @riga = @riga + 1

		        FETCH NEXT FROM cur1 INTO @Allegato,@AnagDoc,@Descrizione,@idRow,@NotEditable,@Obbligatorio,@TipoEstensione,@TipoFile, @richiediFirma

	        END

     END TRY
     BEGIN CATCH
        --set @errore = @@ERROR
		raiserror ('Errore popolamento DOCUMENTAZIONE  ', 16, 1 ) --, CAST(@@ERROR AS NVARCHAR(4000)))
		--rollback tran
		return 99
     END CATCH

	CLOSE cur1
	DEALLOCATE cur1


	--nel caso di ISTANZA ALBOPROF popolo sezione TIPOLOGIA_INCARICO
	if @TipoBando='AlboProf' OR @TipoBando='AlboProf_RP'
	BEGIN
		
		declare @Num as varchar(100)
		declare @DescrizioneTipoLogia as varchar(800)
		declare @FOLDER_NODE as varchar(10)
		
		set @riga = 0

		DECLARE crsTIPOLOGIA CURSOR STATIC FOR 
			--select 
			--	DMV_COD as Num,
			--	DMV_DescML as Descrizione,
			--	case when dmv_image='folder.gif' then 1 else 0 end as FOLDER_NODE
			--from LIB_DOMAINVALUES
			--	where  DMV_DM_ID='TipologiaIncarico' order by DMV_Father

			select 
				DMV_COD as Num,
				DMV_DescML as Descrizione,
				case when DMV_Level=0 then 1 else 0 end as FOLDER_NODE
			from LIB_DOMAINVALUES with(nolock)
				where  DMV_DM_ID='TipologiaIncarico' and DMV_Level < 2 order by DMV_Father

		OPEN crsTIPOLOGIA

		FETCH NEXT FROM crsTIPOLOGIA INTO @Num,@DescrizioneTipoLogia,@FOLDER_NODE
		WHILE @@FETCH_STATUS = 0

		BEGIN
			
		    INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			    VALUES (@newId, 'TIPOLOGIA_INCARICO', @riga, 'DMV_COD', @Num)

		    INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			    VALUES (@newId, 'TIPOLOGIA_INCARICO', @riga, 'Descrizione',case when @num not in ('A','B') then @Num + ': ' + @DescrizioneTipoLogia else '<strong>' + @DescrizioneTipoLogia + '</strong>' end )

			INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
			    VALUES (@newId, 'TIPOLOGIA_INCARICO', @riga, 'Folder_Node', @FOLDER_NODE)

			set @riga = @riga + 1
			FETCH NEXT FROM crsTIPOLOGIA INTO @Num,@DescrizioneTipoLogia,@FOLDER_NODE

		END

		CLOSE crsTIPOLOGIA 
		DEALLOCATE crsTIPOLOGIA 


		--inserisco una riga nella sezione POSIZIONI_ELENCO_PROF
		 INSERT INTO CTL_DOC_Value
			(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select    
			@newId, 'POSIZIONI_ELENCO_PROF', 0, 'NomeDirTec', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'NomeRapLeg'
		

		INSERT INTO CTL_DOC_Value
			(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select    
			@newId, 'POSIZIONI_ELENCO_PROF', 0, 'CognomeDirTec', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'CognomeRapLeg'

		INSERT INTO CTL_DOC_Value
			(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select    
			@newId, 'POSIZIONI_ELENCO_PROF', 0, 'LocalitaDirTec', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'LocalitaRapLeg'

		INSERT INTO CTL_DOC_Value
			(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select    
			@newId, 'POSIZIONI_ELENCO_PROF', 0, 'DataDirTec', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'DataRapLeg'

        INSERT INTO CTL_DOC_Value
			(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select    
			@newId, 'POSIZIONI_ELENCO_PROF', 0, 'CFDirTec', vatValore_FT  from dm_attributi where lnk=@IdAzi and dztNome = 'CFRapLeg'



	end
	--PER LA VERSIONE fatta per SORESA inserisco una riga fissa nella griglia GEIE
	if @TipoBando='AlboProf_3'
	begin
		insert into Document_Offerta_Partecipanti (IdHeader,TipoRiferimento,CodiceFiscale,RagSoc,IndirizzoLeg,LocalitaLeg,PROVINCIALEG,IdAzi )
			select @newId,'GEIE',CV.Value,aziragionesociale,aziIndirizzoLeg,aziLocalitaLeg,aziProvinciaLeg,IdAzi
				from CTL_DOC_Value CV with(nolock) 
					inner join DASHBOARD_VIEW_AZIENDE on CodiceFiscale=Value
					where CV.IdHeader=@newId and CV.DSE_ID='TESTATA' and CV.DZT_Name='CodiceFiscale' and CV.Row=0
		 
		 insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @newId,'TESTATA_GEIE',0,'DenominazioneATI',aziragionesociale
				from CTL_DOC_Value CV with(nolock)
					inner join DASHBOARD_VIEW_AZIENDE on CodiceFiscale=Value
					where CV.IdHeader=@newId and CV.DSE_ID='TESTATA' and CV.DZT_Name='CodiceFiscale' and CV.Row=0
	end

	

	--mi vado a recuperare l'allegato del Patto Integrità messo in configurazione e lo metto sulla table della firma e sull'istanza 
	
	declare @TipoDocParametri as varchar(100)
	set @TipoDocParametri='ALBO'
	if @TipoBando='AlboLavori'
		set @TipoDocParametri='ALBO_LAVORI'	

	insert into CTL_DOC_SIGN (IdHEader,F1_SIGN_ATTACH,F2_SIGN_HASH)
		select @newId,SIGN_ATTACH,SIGN_HASH from Document_Parametri_Abilitazioni DP with(nolock)
		inner join ctl_doc with(nolock) on idheader=id
		where DP.tipodoc=@TipoDocParametri and DP.deleted=0

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select @newId,'DISPLAY_ABILITAZIONI',0,'F1_SIGN_ATTACH',SIGN_ATTACH
			 from Document_Parametri_Abilitazioni DP with(nolock)
			inner join ctl_doc with(nolock) on idheader=id
			where DP.tipodoc=@TipoDocParametri and DP.deleted=0

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		select @newId,'DISPLAY_ABILITAZIONI',0,'F2_SIGN_HASH',SIGN_HASH
			 from Document_Parametri_Abilitazioni DP with(nolock)
			inner join ctl_doc with(nolock) on idheader=id
			where DP.tipodoc=@TipoDocParametri and DP.deleted=0

   
			        
	--COMMIT TRAN
	---Chiamo la stored che mi fa sostituire le informazioni dell'utente con i dati dell'utente collegato
	IF @idPfu > 0
	BEGIN
		Exec UPDATE_DATI_UTENTE_COLLEGATO_ISTANZA @newId , @idPfu
	END

	--SE IL CAMPO IscrCCIAA non è un numerico lo svuoto in creazione
	IF EXISTS ( Select * from CTL_DOC_Value with(nolock) where IdHeader=@newId and DSE_ID='TESTATA' and Dzt_name='IscrCCIAA' and ISNUMERIC(Left(Value,10))=0 ) 
	BEGIN
		update CTL_DOC_Value set value=''
		where IdHeader=@newId and DSE_ID='TESTATA' and Dzt_name='IscrCCIAA'
	END

	----SE PER IL CLIENTE ESISTE LA RELAZIONE ISTANZA_ATTRIBUTI_RIPORTATI per la modalita di bando, controllo fatto su jumpcheck, aggiorno dall'ultima istanza confermata se esiste i dati
	IF EXISTS ( select * from [CTL_Relations] with(nolock) where [REL_Type]='ISTANZA_ATTRIBUTI_RIPORTATI' and [REL_ValueInput]='JUMPCHECK_' + @jumpcheck )
	BEGIN
		--CERCA DI RECUPERARE istanza confermata/confermataparz per l'azienda dell'utente dalla quale riportare i dati
		declare @id_ist as int

		select 
			@id_ist=max(I.id)
			from ProfiliUtente P with(nolock)
				inner join ctl_doc I with(nolock) on I.Azienda=P.pfuIdAzi and I.StatoFunzionale like 'Confermato%' and I.Deleted=0 and I.TipoDoc like 'Istanza%'
				inner join ctl_doc B with(nolock) on B.id=I.LinkedDoc and  ISNULL(B.JumpCheck,'')=@jumpcheck_ric_ist 
			where P.idpfu=@idPfu

		--se trova istanza confermata/parz aggiorna i campi indicati dalla relazione per la tipologia di BANDO
		if @id_ist is not null
		begin
			
			--aggiorna i campi che trova già sull'istanza
			update CV2 set value=Cv.value
				from CTL_DOC_Value CV with(nolock)
					inner join (select REL_ValueOutput from [CTL_Relations] where [REL_Type]='ISTANZA_ATTRIBUTI_RIPORTATI' and [REL_ValueInput]='JUMPCHECK_' + @jumpcheck) W on W.REL_ValueOutput=CV.DZT_Name
					inner join CTL_DOC_Value CV2 with(nolock) on cv2.IdHeader=@newId and cv2.DZT_Name=w.REL_ValueOutput
				where CV.IdHeader=@id_ist and Cv.DZT_Name=CV2.DZT_Name and cv.Row=CV2.Row and CV.DSE_ID=CV2.DSE_ID
			
			--inserisci i record nella ctl_doc_value non presenti ancora sull'istanza, in quanto non è stato fatto un salvataggio
			insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
				select @newId,cv.DSE_ID,cv.Row,cv.DZT_Name,cv.Value
					from CTL_DOC_Value CV with(nolock)
					inner join (select REL_ValueOutput from [CTL_Relations] where [REL_Type]='ISTANZA_ATTRIBUTI_RIPORTATI' and [REL_ValueInput]='JUMPCHECK_' + @jumpcheck) W on W.REL_ValueOutput=CV.DZT_Name
					left join CTL_DOC_Value CV2 with(nolock) on cv2.IdHeader=@newId and cv2.DZT_Name=w.REL_ValueOutput
				where CV.IdHeader=@id_ist and cv2.DZT_Name is null
		end

		
	END

END




GO
