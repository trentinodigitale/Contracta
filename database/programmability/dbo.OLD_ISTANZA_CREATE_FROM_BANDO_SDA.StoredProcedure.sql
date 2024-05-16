USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ISTANZA_CREATE_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[OLD_ISTANZA_CREATE_FROM_BANDO_SDA]( @idOrigin as int, @idPfu as int = -20, @newId as int output ) 
AS
BEGIN
	--Versione=1&data=2014-09-22&Attivita=63141&Nominativo=Federico

	-- BEGIN TRAN

	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	DECLARE @Body as varchar(4000)
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
	declare @MOD_OffertaIND varchar(500)
	declare @CodiceModello varchar(500)
	declare @STATOLOCALITALEG varchar(500)
	declare @STATOLOCALITALEG2 varchar(500)
	declare @versione varchar(500)
	-- viste di createFrom delle sezioni che hanno il parametro view_from
	--	ISTANZA_SDA_FARMACI_FROM_BANDO_SDA	 / DOCUMENT	/	CTL_DOC
	--	ISTANZA_SDA_FARMACI_TESTATA_FROM_BANDO_SDA	 / TESTATA	/	CTL_DOC_Value  / FROM_USER_FIELD=idPfu
	-- ISTANZA_SDA_FARMACI_DOCUMENTAZIONE_FROM_BANDO_SDA / DOCUMENTAZIONE / CTL_DOC_Value / 
	-- ISTANZA_SDA_FARMACI_TESTATA_PRODOTTI_FROM_BANDO_SDA / TESTATA_PRODOTTI / CTL_DOC_Value / 

	-- variabili per la sezione DOCUMENT
	declare @fascicolo as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int
	declare @richiestaFirma as varchar(100)
	declare @sign_lock as int
	declare @sign_attach as varchar(400)
	declare @protocolloRiferimento as varchar(1000)
	declare @strutturaAziendale as varchar(4000)
	

	select @fascicolo = Fascicolo, 
		   @linkedDoc = LinkedDoc,
		   @prevDoc = PrevDoc,
		   @richiestaFirma = RichiestaFirma,
		   @sign_lock = Sign_lock,
		   @sign_attach = sign_attach,
		   @protocolloRiferimento = protocolloRiferimento,
		   @strutturaAziendale = strutturaAziendale,
		   @CodiceModello = TipoBando,
		   @versione=versione
		from ISTANZA_SDA_FARMACI_FROM_BANDO_SDA where id_from = @idOrigin
	
	
	Select 
		 @IdAzi=p.pfuidazi 
	 	,@RagSoc=aziRagioneSociale 
		,@NaGi=aziIdDscFormasoc 
		,@INDIRIZZOLEG=aziIndirizzoLeg
		,@LOCALITALEG=aziLocalitaLeg 
		,@LOCALITALEG2=aziLocalitaLeg2
		,@CAPLEG=aziCAPLeg
		,@PROVINCIALEG=aziProvinciaLeg
		,@PROVINCIALEG2=aziProvinciaLeg2
		,@STATOLOCALITALEG=aziStatoLeg
		,@STATOLOCALITALEG2=aziStatoLeg2
		,@NUMTEL=aziTelefono1
		,@NUMTEL2=aziTelefono2 
		,@NUMFAX=aziFAX
		,@EMail=aziE_Mail
		,@PIVA=aziPartitaIVA 

		from profiliUtente p
				INNER JOIN aziende a ON p.pfuidazi = a.idazi
		where idpfu=@idPfu

		
	insert into CTL_DOC ( idpfu,azienda, Titolo,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,idPfuInCharge,Versione)
		select @idPfu, @IdAzi, 'Istanza Iscrizione',case when ISNULL(@versione,'') = '' then 'ISTANZA_SDA_FARMACI' else 'ISTANZA_SDA_' + @versione end, 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				,@fascicolo, @linkedDoc, @richiestaFirma,@sign_lock, @sign_attach, @protocolloRiferimento, @strutturaAziendale,@idPfu,@versione

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		--rollback tran
		return 99
	END 

	set @newId = @@identity

	
		
	select @Body = body from ISTANZA_SDA_FARMACI_TESTATA_FROM_bando_sda where id_from = @idOrigin and idpfu = @idPfu		

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'Body', @Body)

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
		VALUES (@newId, 'TESTATA', 0, 'EMail', @EMail)

	INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
		VALUES (@newId, 'TESTATA', 0, 'PIVA', @PIVA)


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




	--set @tabella = 'ISTANZA_SDA_FARMACI_TESTATA_FROM_BANDO_SDA'
	--set @model = 'ISTANZA_SDA_FARMACI_TESTATA'

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
		select isnull(Allegato,''), isnull(AnagDoc,''), isnull(Descrizione,''), isnull(idRow,''), isnull(NotEditable,''), isnull(Obbligatorio,''), isnull(TipoEstensione,''), isnull(TipoFile,''), isnull(richiedifirma,'')
			from ISTANZA_SDA_FARMACI_DOCUMENTAZIONE_FROM_BANDO_SDA where id_from = @idOrigin		

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
		raiserror ('Errore creazione record in ctl_doc. ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		return 99
	END CATCH

	CLOSE cur1
	DEALLOCATE cur1
	-----------------------------------------------------------------------------------
	-- precarico i modelli da usare con le sezioni
	-----------------------------------------------------------------------------------

	set @MOD_OffertaIND = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_OffertaInd'

	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			values( @newId , 'PRODOTTI' , @MOD_OffertaIND  )




	-----------------------------------------------------------------------------------
	-- precarico i prodotti prelevando dal bando
	-----------------------------------------------------------------------------------

	declare @IdRow2 INT
	declare @idr INT
	declare CurProg2 Cursor Static for 
		select   id as IdRow2
			from Document_MicroLotti_Dettagli 
			where idheader = @idOrigin  and TipoDoc = 'BANDO_SDA'
			order by Id

	open CurProg2

	FETCH NEXT FROM CurProg2 
	INTO @IdRow2
		WHILE @@FETCH_STATUS = 0
			BEGIN
			--select * from Document_MicroLotti_Dettagli
				INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
					select @newId , case when ISNULL(@versione,'')='' then 'ISTANZA_SDA_FARMACI' else 'ISTANZA_SDA_' + @versione end as TipoDoc,'' as StatoRiga,'' as EsitoRiga
				set @idr = @@identity				
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga '			 
				 FETCH NEXT FROM CurProg2
			   INTO @IdRow2
			 END 

	CLOSE CurProg2
	DEALLOCATE CurProg2
		
	
	---MODELLI_LOTTI_test_MOD_OffertaInd
	--set @tabella = 'ISTANZA_SDA_FARMACI_TESTATA_FROM_BANDO_SDA'
	--set @model = 'ISTANZA_SDA_FARMACI_TESTATA_SAVE'

	--exec GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL_EXECUTE 
	--		@tabella,
	--		@model,
	--		@newId,
	--		@idOrigin,
	--		'TESTATA',
	--		'idPfu',
	--		@idPfu
			

	--exec ( @output )

	---Chiamo la stored che mi fa sostituire le informazioni dell'utente con i dati dell'utente collegato
	IF @idPfu > 0
	BEGIN
		Exec UPDATE_DATI_UTENTE_COLLEGATO_ISTANZA @newId , @idPfu
	END
	-- COMMIT TRAN
	--SE IL CAMPO IscrCCIAA non è un numerico lo svuoto in creazione
	IF EXISTS ( Select * from CTL_DOC_Value where IdHeader=@newId and DSE_ID='TESTATA' and Dzt_name='IscrCCIAA' and ISNUMERIC(Left(Value,10))=0 ) 
	BEGIN
		update CTL_DOC_Value set value=''
		where IdHeader=@newId and DSE_ID='TESTATA' and Dzt_name='IscrCCIAA'
	END

END


GO
