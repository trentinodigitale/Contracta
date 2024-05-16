USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CENSUS_OF_COMPANY]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[CENSUS_OF_COMPANY] 
( 
	@CodiceFiscaleAzi varchar(100), 
	@sessionID nvarchar(max),


	@idMP int,
	@NewIdAzi int output,
	@newIdPfu int output
)
AS

	-- NOTA: LA PAGINA CHIAMANTE DOPO AVER INVOCATO QUESTA STORED, RESPONSABILE DELLA CREAZIONE DEI RECORD "BASE" 
	--		 DELL'AZIENDA E DELL'UTENTE, CHIAMERA' IL PROCESSO "CENSIMENTO-COMPLETA_REGISTRAZIONE".
	--		 AL MOMENTO DELLA CREAZIONE DI QUESTA STORED IL SUO UTILIZZO E' LIMITATO ALLA PAGINA ASP DI CENSIMENTO OE.
	--		 Si lascia al chiamante tutti i controlli del caso.

	SET NOCOUNT ON

	select * into #dati_form_reg from FormRegistrazione with(nolock) where sessionid = @sessionID and codice_fiscale = @CodiceFiscaleAzi

	DECLARE @RagioneSocialeAzi NVARCHAR(4000)
	DECLARE @EmailAzi nvarchar(1000)
	DECLARE @PartitaIvaAzi varchar(100)
	DECLARE @ViaAzi nvarchar(500)
	DECLARE @CapAzi varchar(100)
	DECLARE @TelefonoAzi varchar(500)
	DECLARE @FaxAzi varchar(500)

	DECLARE @CittaAzi nvarchar(500)
	DECLARE @NazioneAzi nvarchar(500)
	DECLARE @ProvinciaAzi varchar(500)

	declare @LOCALITA_INT	NVARCHAR(2000)
	declare @PROVINCIA_INT	NVARCHAR(2000)
	declare @STATO_INT		NVARCHAR(2000)

	DECLARE @sitoWEB nvarchar(2000) = ''
	DECLARE @strClean		VARCHAR(100)

	declare @ANNOCOSTITUZIONE nvarchar(1000)
	declare @RuoloRapLeg nvarchar(1000)

	DECLARE @Atv			VARCHAR(100)
	DECLARE @Gph			INT

	DECLARE @nLen			INT

	DECLARE @aziAcquirente	INT
	DECLARE @aziVenditore	INT
	DECLARE @aziProfili		VARCHAR(10)

	DECLARE @valore			VARCHAR(400)

	declare @naturaGiuridica int
	declare @tipoDiAmministr nvarchar(100)

	declare @NOMECOGNO as nvarchar(4000)

	declare @PREFPROT varchar(1000)
	declare @pfuProfili as varchar(200)
	declare @pfuFunz as varchar(800)
	declare @FUNZ as varchar(800)
	declare @LNG as int
	declare @AlgoritmoPwd as varchar(2)

	declare @pfuOpzioni as varchar(1000)

	declare @pfuAcquirente int
	declare @pfuVenditore int

	declare @CF varchar(100)
	declare @COGNO nvarchar(4000)
	declare @NOME nvarchar(4000)
	declare @MAIL nvarchar(1000)
	declare @TEL varchar(500)

	declare @aziFunzionalita nvarchar(4000)
	declare @CellulareRapLeg nvarchar(1000)
	declare @IscrCCIAA nvarchar(1000)
	declare @SedeCCIAA nvarchar(4000)
	declare @EMailRiferimentoAzienda nvarchar(4000)
	declare @CodiceEORI nvarchar(1000)

	declare @referenteUfficioGare nvarchar(1000)
	declare @referenteMailGare nvarchar(1000)
	declare @referenteTelefonoGare nvarchar(1000)
	declare @classIscriz nvarchar(1000)
	declare @GerarchicoSOA nvarchar(1000)
	declare @ATECO nvarchar(1000)

	set @tipoDiAmministr = ''
	set @naturaGiuridica = 0
	set @aziAcquirente = 0
	set @aziVenditore = 2
	set @aziProfili = ''

	SET @Gph = 0
	SET @Atv = '###0###'

	BEGIN TRY

		BEGIN TRAN

		select top 1 @RagioneSocialeAzi = valore from #dati_form_reg where nome_campo = 'RAGSOC'
		select top 1 @EmailAzi = valore from #dati_form_reg where nome_campo = 'EMail'
		select top 1 @PartitaIvaAzi = valore from #dati_form_reg where nome_campo = 'PIVA'
		select top 1 @ViaAzi = valore from #dati_form_reg where nome_campo = 'INDIRIZZOLEG'
		select top 1 @CapAzi = valore from #dati_form_reg where nome_campo = 'CAPLEG'
		select top 1 @TelefonoAzi = valore from #dati_form_reg where nome_campo = 'NUMTEL'
		select top 1 @FaxAzi = valore from #dati_form_reg where nome_campo = 'NUMFAX'

		select top 1 @CittaAzi = valore from #dati_form_reg where nome_campo = 'LOCALITALEG'
		select top 1 @ProvinciaAzi = valore from #dati_form_reg where nome_campo = 'PROVINCIALEG'
		select top 1 @NazioneAzi = valore from #dati_form_reg where nome_campo = 'STATOLEG'

		select top 1 @LOCALITA_INT = valore from #dati_form_reg where nome_campo = 'aziLocalitaLeg2'
		select top 1 @PROVINCIA_INT = valore from #dati_form_reg where nome_campo = 'aziProvinciaLeg2'
		select top 1 @STATO_INT = valore from #dati_form_reg where nome_campo = 'aziStatoLeg2'

		select top 1 @sitoWEB = valore from #dati_form_reg where nome_campo = 'SITOWEB'

		select top 1 @COGNO = valore from #dati_form_reg where nome_campo = 'CognomeRapLeg'
		select top 1 @NOME = valore from #dati_form_reg where nome_campo = 'NomeRapLeg'
		select top 1 @MAIL = valore from #dati_form_reg where nome_campo = 'PFUEMAIL'
		select top 1 @TEL = valore from #dati_form_reg where nome_campo = 'TelefonoRapLeg'
		select top 1 @CF = valore from #dati_form_reg where nome_campo = 'CFRapLeg'

		select top 1 @ANNOCOSTITUZIONE = valore from #dati_form_reg where nome_campo = 'ANNOCOSTITUZIONE'
		select top 1 @RuoloRapLeg = valore from #dati_form_reg where nome_campo = 'RuoloRapLeg'

		select top 1 @CellulareRapLeg = valore from #dati_form_reg where nome_campo = 'CellulareRapLeg'
		select top 1 @IscrCCIAA = valore from #dati_form_reg where nome_campo = 'IscrCCIAA'
		select top 1 @SedeCCIAA = valore from #dati_form_reg where nome_campo = 'SedeCCIAA'
		select top 1 @EMailRiferimentoAzienda = valore from #dati_form_reg where nome_campo = 'EMailRiferimentoAzienda'
		select top 1 @CodiceEORI = valore from #dati_form_reg where nome_campo = 'CodiceEORI'

		select top 1 @referenteUfficioGare = valore from #dati_form_reg where nome_campo = 'referenteUfficioGare'
		select top 1 @referenteMailGare = valore from #dati_form_reg where nome_campo = 'referenteMailGare'
		select top 1 @referenteTelefonoGare = valore from #dati_form_reg where nome_campo = 'referenteTelefonoGare'

		select top 1 @classIscriz = valore from #dati_form_reg where nome_campo = 'classeIscrizreferente'
		select top 1 @GerarchicoSOA = valore from #dati_form_reg where nome_campo = 'GerarchicoSOAreferente'
		select top 1 @ATECO = valore from #dati_form_reg where nome_campo = 'ATECOreferente'
		
		select @naturaGiuridica = tdrCodice
			from tipidatirange,descsi, #dati_form_reg frm
			 where frm.nome_campo = 'NAGI' and  tdridtid = 131 and tdrdeleted=0     and IdDsc =  tdriddsc 
				    and frm.valore = dscTesto

		-- CREAZIONE RAGIONE SOCIALE NORMALIZZATA
		SET @strClean = UPPER(@RagioneSocialeAzi)
		SET @strClean = REPLACE(@strClean, ' ', '')
		SET @strClean = REPLACE(@strClean, '.', '')
		SET @strClean = REPLACE(@strClean, '''', '')
		SET @strClean = REPLACE(@strClean, ':', '')
		SET @strClean = REPLACE(@strClean, ';', '')
		SET @strClean = REPLACE(@strClean, '-', '')
		SET @strClean = REPLACE(@strClean, '!', '')
		SET @strClean = REPLACE(@strClean, '?', '')
		SET @strClean = REPLACE(@strClean, '"', '')
		SET @strClean = REPLACE(@strClean, ', ', '')
		SET @strClean = REPLACE(@strClean, '*', '')
		SET @nLen     = LEN (@strClean)

		IF @nLen > 4
		BEGIN
			IF RIGHT (@strClean, 3) = 'SPA' OR RIGHT (@strClean, 3) = 'SNC' OR RIGHT (@strClean, 3) = 'SRL'
			BEGIN
				SET @strClean = LEFT(@strClean, @nLen - 3)                       
			END
		END

		-- VARIABILI SPECIFICHE PER UN CENSIMENTO OE
		set @aziAcquirente = 0
		set @aziVenditore = 2
		set @aziProfili = 'S'
		set @aziFunzionalita = '0010000000000001111110000000000001111111000000100000000000000111111000000001111001110110011100101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000001000100001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'  
		--------------------------
		--- CREAZIONE AZIENDA ----
		--------------------------

		INSERT INTO Aziende (aziDataCreazione, aziRagioneSociale, aziRagioneSocialeNorm, aziPartitaIVA, aziE_Mail, aziAcquirente, 
							 aziVENDitore, aziProspect, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg,  
							 aziCAPLeg, aziTelefono1, aziFAX,  aziProssimoProtRdo, aziProssimoProtOff, 
							 aziGphValueOper, aziDeleted, aziProfili, aziStatoLeg2, aziProvinciaLeg2, aziLocalitaLeg2 ,aziNumeroCivico, aziIdDscFormaSoc, aziFunzionalita )
			VALUES (   getdate(), @RagioneSocialeAzi, @strClean , @PartitaIvaAzi, @EmailAzi, @aziAcquirente, 
					   @aziVenditore, 0, @ViaAzi , @CittaAzi, @ProvinciaAzi, @NazioneAzi,  
					   @CapAzi, @TelefonoAzi, @FaxAzi, 1, 1, 
					   0, 0, @aziProfili, @STATO_INT, @PROVINCIA_INT, @LOCALITA_INT, NULL, @naturaGiuridica, @aziFunzionalita  )

		SET @NewIdAzi = SCOPE_IDENTITY()

		INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaacquirente, mpaProfili, mpaDeleted)
			 VALUES (@idMP, @NewIdAzi, 3, 'P', 0)

		INSERT INTO AziGph (gphIdAzi, gphValue) 
			VALUES (@NewIdAzi, @Gph)

		EXEC InsAteco @NewIdAzi, @Atv

		declare @aziAtvAtecord varchar(1000) = ''
		SELECT TOP 1 @aziAtvAtecord = AtvAtecord FROM  Aziateco with(nolock) WHERE  IdAzi = @NewIdAzi

		UPDATE Aziende 
				SET aziAtvAtecord = @aziAtvAtecord
			WHERE IdAzi = @NewIdAzi


		EXEC UpdAttrAzi @NewIdAzi , 'codicefiscale', @CodiceFiscaleAzi 
		EXEC UpdAttrAzi @newidazi , 'IscrCCIAA', @IscrCCIAA 
		EXEC UpdAttrAzi @newidazi , 'SedeCCIAA', @SedeCCIAA 
		EXEC UpdAttrAzi @NewIdAzi , 'ANNOCOSTITUZIONE', @ANNOCOSTITUZIONE
		EXEC UpdAttrAzi @NewIdAzi , 'NomeRapLeg', @NOME 
		EXEC UpdAttrAzi @NewIdAzi , 'CognomeRapLeg', @COGNO
		EXEC UpdAttrAzi @NewIdAzi , 'RuoloRapLeg', @RuoloRapLeg
		EXEC UpdAttrAzi @NewIdAzi , 'TelefonoRapLeg', @TEL
		EXEC UpdAttrAzi @newidazi , 'CellulareRapLeg', @CellulareRapLeg
		EXEC UpdAttrAzi @newidazi , 'EmailRapLeg', @MAIL 
		EXEC UpdAttrAzi @newidazi , 'CFRapLeg', @CF
		EXEC UpdAttrAzi @newidazi , 'EMailRiferimentoAzienda', @EMailRiferimentoAzienda 
		EXEC UpdAttrAzi @newidazi , 'CodiceEORI', @CodiceEORI


		EXEC UpdAttrAzi @newidazi , 'referenteUfficioGare', @referenteUfficioGare
		EXEC UpdAttrAzi @newidazi , 'referenteMailGare', @referenteMailGare
		EXEC UpdAttrAzi @newidazi , 'referenteTelefonoGare', @referenteTelefonoGare
		
		declare @classValue varchar(50)
		--inserisco i valori della ClasseIscriz nella dm_attributi
		DECLARE classIscriz_cursor CURSOR  
		FOR 
			select * from dbo.Split(@classIscriz,'###')

		OPEN classIscriz_cursor  

		FETCH NEXT FROM classIscriz_cursor INTO @classValue

			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				EXEC InsAttrAzi @newidazi , 'ClasseIscriz', @classValue


				FETCH NEXT FROM classIscriz_cursor INTO @classValue

			END 

		CLOSE classIscriz_cursor
		DEALLOCATE classIscriz_cursor

		--inserisco i valori della soa nella dm_attributi
		DECLARE soa_cursor CURSOR  
		FOR 
			select * from dbo.Split(@GerarchicoSOA,'###')

		OPEN soa_cursor  

		FETCH NEXT FROM soa_cursor INTO @classValue

			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				EXEC InsAttrAzi @newidazi , 'ClassificazioneSOA', @classValue


				FETCH NEXT FROM soa_cursor INTO @classValue

			END 

		CLOSE soa_cursor
		DEALLOCATE soa_cursor

		--inserisco i valori della Ateco nella dm_attributi
		DECLARE Ateco_cursor CURSOR  
		FOR 
			select * from dbo.Split(@ATECO,'###')

		OPEN Ateco_cursor  

		FETCH NEXT FROM Ateco_cursor INTO @classValue

			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				EXEC InsAttrAzi @newidazi , 'ATECO', @classValue


				FETCH NEXT FROM Ateco_cursor INTO @classValue

			END 

		CLOSE Ateco_cursor
		DEALLOCATE Ateco_cursor

		--------------------------
		--- CREAZIONE UTENTE -----
		--------------------------

		--fornitore
		set @pfuAcquirente = 0
		set @pfuVenditore = 1
		set @pfuOpzioni = '11010110000000000000000000000000000000000000000000'
		set @pfuProfili = ''
		set @LNG=1
		set @AlgoritmoPwd = '0'
		
		select @AlgoritmoPwd=isnull(DZT_ValueDef,'0') from lib_dictionary with(nolock) where dzt_name='SYS_PWD_ALGORITMO'

		set @NOMECOGNO = @NOME + ' ' + @COGNO

		IF len(@NOMECOGNO) > 2
		BEGIN
			set @PREFPROT = left(@NOMECOGNO,3)
		END
		ELSE
		BEGIN
			set @PREFPROT = 'AFL'
		END

		INSERT INTO profiliUtente (pfuAcquirente,pfuVenditore,pfuIdAzi,pfuNome,pfucognome,pfunomeutente,pfuLogin,pfuRuoloAziendale,pfuPrefissoProt,pfuIdLng,pfuE_Mail,pfuProfili,pfuFunzionalita,pfuTel,pfuCell,pfuCodiceFiscale,pfuAlgoritmoPassword,pfuResponsabileUtente,pfuOpzioni) 
			VALUES (@pfuAcquirente,@pfuVenditore,@NewIdAzi,@NOMECOGNO,@COGNO,@NOME,NULL,@RuoloRapLeg,@PREFPROT,@LNG,@MAIL,'B','',@TEL,'',@CF,@AlgoritmoPwd,null, @pfuOpzioni)

		set @newIdPfu = scope_identity()

		COMMIT TRAN

	END TRY
	BEGIN CATCH

		declare @ErrorMessage nvarchar(max)
		declare @ErrorSeverity int
		declare @ErrorState int

		-- Nel caso in cui il chiamante gestisca male l'errore ritornato dalla stored, svuotiamo per sicurezza
		--	le variabili di output. Per non recuperare record soggetti a rollback
		set @NewIdAzi = NULL
		set @newIdPfu = NULL

		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState    = ERROR_STATE()

		ROLLBACK TRAN -- NON LASCIAMO RECORD SPORCHI SULLA TABELLA AZIENDE O SULLA PROFILIUTENTE, A PRESCINDERE SE IL CHIAMANTE
					  --	DI QUESTA STORED E' IN TRANSAZIONE O MENO

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH

	

GO
