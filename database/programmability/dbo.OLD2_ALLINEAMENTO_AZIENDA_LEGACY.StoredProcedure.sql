USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ALLINEAMENTO_AZIENDA_LEGACY]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[OLD2_ALLINEAMENTO_AZIENDA_LEGACY]  (	 @idAzi int )
AS
BEGIN

	--	QUESTA STORED SERVE PER ALLINEARE UN AZIENDA GIA' PRESENTE, CON CHIAVE IDAZI, NEL DATABASE CONTENUTO NELLA SYS 'SYS_DBNAME_PREV_VER'
	--	NON È PREVISTA L'AGGIUNTA DI NUOVE AZIENDE 

	SET NOCOUNT ON;

	DECLARE @newID INT
	DECLARE @RagSocNew nvarchar(4000)
	DECLARE @RagSocNewNorm nvarchar(4000)
	DECLARE @NagiNew INT
	DECLARE @indirizzoNew nvarchar(4000)
	DECLARE @comuneNEW nvarchar(4000)
	DECLARE @provinciaNEW nvarchar(4000)
	DECLARE @capNEW nvarchar(4000)
	DECLARE @mailpecNEW nvarchar(4000)
	DECLARE @cfNEW nvarchar(4000)
	DECLARE @pivaNEW nvarchar(4000)
	DECLARE @dbLegacy varchar(500)

	DECLARE @aziTelefono1 varchar(500)
	DECLARE @aziTelefono2 varchar(500)
	DECLARE @aziFax varchar(500)

	
	declare @Notes varchar(255)
	declare @codicefiscale varchar(255)
	declare @SedeINPS varchar(255)
	declare @UfficioINPS varchar(255)
	declare @IndirizzoINPS varchar(255)
	declare @TelefonoINPS varchar(255)
	declare @FaxINPS varchar(255)
	declare @NumINPS varchar(255)

	declare @SedeINAIL varchar(255)
	declare @UfficioINAIL varchar(255)
	declare @IndirizzoINAIL varchar(255)
	declare @TelefonoINAIL varchar(255)
	declare @FaxINAIL varchar(255)
	declare @NumINAIL varchar(255)

	declare @ProtGen varchar(255)
	declare @DataProt varchar(255)
	declare @ClasseIscriz varchar(255)
	declare @sysHabilitStartDate varchar(255)
	declare @CARBelongTo varchar(255)
	declare @AltraClassificazione varchar(255)

	declare @ANNOCOSTITUZIONE varchar(255)
	declare @IscrCCIAA varchar(255)
	declare @SedeCCIAA varchar(255)
	declare @NotaIscrizioneCCIAA varchar(255)
	declare @Persgiuridica varchar(255)
	declare @QualitaImprenditore varchar(255)

	declare @PAIndirizzoOp varchar(255)
	declare @PALocalitaOp varchar(255)
	declare @PAProvinciaOp varchar(255)
	declare @PACapOp varchar(255)
	declare @PAStatoOp varchar(255)

	declare @CognomeRapLeg varchar(255)
	declare @NomeRapLeg varchar(255)
	declare @RuoloRapLeg varchar(255)
	declare @TelefonoRapLeg varchar(255)
	declare @CellulareRapLeg varchar(255)
	declare @LocalitaRapLeg varchar(255)
	declare @ProvinciaRapLeg varchar(255)
	declare @DataRapLeg varchar(255)
	declare @EmailRapLeg varchar(255)

	declare @CARClasMercAzienda varchar(255)
	declare @CategoriaSOA varchar(255)

	declare @Banca varchar(255)
	declare @AgenziaBanca varchar(255)
	declare @CittaBanca varchar(255)
	declare @ProvBanca varchar(255)
	declare @ABIBanca varchar(255)
	declare @CABBanca varchar(255)
	declare @CINBanca varchar(255)
	declare @CCBanca varchar(255)
	declare @IBAANBanca varchar(255)


	declare @SedeEdile varchar(255)
	declare @UfficioEdile varchar(255)
	declare @IndirizzoEdile varchar(255)
	declare @TelefonoEdile varchar(255)
	declare @FaxEdile varchar(255)
	declare @NumEdile varchar(255)
	

	DECLARE @strSQL nvarchar(max)

	SET @dbLegacy = ''

	SELECT @dbLegacy = DZT_ValueDef
		from LIB_Dictionary with(nolock)
		where DZT_Name = 'SYS_DBNAME_PREV_VER'

	----------------------------------------------------------- 
	-- SE ESISTE LA SYS 'SYS_DBNAME_PREV_VER' E NON E' VUOTA --
	-----------------------------------------------------------
	IF LTRIM(rtrim(@dbLegacy)) <> '' 
	BEGIN

		CREATE TABLE #T1
		(
			idazi int
		)

		INSERT INTO #T1 exec('SET NOCOUNT ON; select idazi from ' + @dbLegacy + '..Aziende where idazi = ' + @idAzi )
		
		---------------------------------------------
		-- SE L'AZIENDA ESISTE NEL DATABASE SLAVE ---
		---------------------------------------------
		IF EXISTS ( select idazi from #T1 )
		BEGIN

			SET @newID = -1

			------------------------------------------------------------------------
			-- PRENDO I DATI DAL DB MASTER. CIOÈ QUELLO SUL QUALE GIRA LA STORED ---
			------------------------------------------------------------------------
			SELECT	   @RagSocNEW = isnull(azi.aziRagioneSociale,'') ,
					   @NagiNEW = isnull(azi.aziIdDscFormaSoc,-1),
					   @indirizzoNEW = isnull(azi.aziIndirizzoLeg,'') ,
					   @comuneNEW = isnull(azi.aziLocalitaLeg,'') ,
					   @provinciaNEW = isnull(azi.aziProvinciaLeg,'') ,
					   @capNEW = isnull(azi.aziCAPLeg,'') ,
					   @mailpecNEW = isnull(azi.aziE_Mail ,''),
					   @RagSocNewNorm = isnull(azi.aziRagioneSocialeNorm,''),
					   @pivaNEW = isnull(azi.aziPartitaIVA,''),
					   @cfnew = isnull(attr.vatValore_FT,''),
					   @aziTelefono1 = ISNULL(aziTelefono1,''),
					   @aziTelefono2 = ISNULL(aziTelefono2,''),
					   @aziFax = ISNULL(aziFAX ,'')
					from aziende azi with(nolock) 
							INNER JOIN DM_Attributi attr with(nolock) ON attr.lnk = azi.idazi and attr.dztNome = 'codicefiscale'
					where idazi = @idAzi

			SET @strSQL = 'SET NOCOUNT ON; 
				UPDATE ' + @dbLegacy + '..AZIENDE
					SET aziRagioneSociale = ''' + replace(@RagSocNew, '''','''''') + '''
						,aziRagioneSocialeNorm = ''' + @RagSocNewNorm + '''
						,aziIdDscFormaSoc = ' + CAST( @NagiNew as varchar(100)) + '
						,aziIndirizzoLeg = ''' + replace(@indirizzoNew, '''','''''') + '''
						,aziLocalitaLeg = ''' + replace(@comuneNEW, '''','''''') + '''
						,aziProvinciaLeg = ''' + replace(@provinciaNEW, '''','''''') + '''
						,aziCAPLeg =  ''' + replace(@capNEW, '''','''''') + '''
						,aziE_Mail = ''' + replace(@mailpecNEW , '''','''''') + '''
						,aziPartitaIVA = ''' + replace(@pivaNEW , '''','''''') + '''
						,aziTelefono1 = ''' + replace(@aziTelefono1 , '''','''''') + '''
						,aziTelefono2 = ''' + replace(@aziTelefono2 , '''','''''') + '''
						,aziFAX = ''' + replace(@aziFax , '''','''''') + '''
				WHERE idazi = ' + cast(@idAzi as varchar(100))

			EXEC(@strSQL)

			SET @strSQL = 'SET NOCOUNT ON; 
				UPDATE ' + @dbLegacy + '..DM_Attributi 
					SET vatValore_FT = ''' + replace(@cfNEW, '''','''''') + '''
						,vatValore_FV = ''' + replace(@cfNEW, '''','''''') + '''
					WHERE lnk = ' + cast(@idAzi as varchar(100)) + ' and dztNome = ''codicefiscale'''

			EXEC(@strSQL)

		END
		ELSE
		--NEL CASO NON ESISTE L'AZIENDA E LA CONFIGURAZIONE PREVEDE L'INSERIMENTO INSERT_USER_AZI = 'SI' nella CTL_PARAMETRI
		BEGIN
			IF dbo.parametri('PREVIOUS_VERSION','INSERT_USER_AZI','ATTIVO','NO',-1) = 'SI'
			BEGIN	
					--INSERISCO AZIENDA NEL VECCHIO DB
					SET @strSQL = 'SET NOCOUNT ON; 
						 INSERT INTO '  +  @dbLegacy + '..Aziende ([IdAzi], [aziLog], [aziDataCreazione], [aziRagioneSociale], [aziRagioneSocialeNorm], [aziIdDscFormaSoc], [aziPartitaIVA], [aziE_Mail], [aziAcquirente], [aziVenditore], [aziProspect], [aziIndirizzoLeg], [aziIndirizzoOp], [aziLocalitaLeg], [aziLocalitaOp], [aziProvinciaLeg], [aziProvinciaOp], [aziStatoLeg], [aziStatoOp], [aziCAPLeg], [aziCapOp], [aziPrefisso], [aziTelefono1], [aziTelefono2], [aziFAX], [aziLogo], [aziIdDscDescrizione], [aziProssimoProtRdo], [aziProssimoProtOff], [aziGphValueOper], [aziDeleted], [aziDBNumber], [aziAtvAtecord], [aziSitoWeb], [aziCodEurocredit], [aziProfili], [aziProvinciaLeg2], [aziStatoLeg2], [aziFunzionalita], [CertificatoIscrAtt], [TipoDiAmministr])
								SELECT [IdAzi], [aziLog], [aziDataCreazione], [aziRagioneSociale], [aziRagioneSocialeNorm], [aziIdDscFormaSoc], [aziPartitaIVA], [aziE_Mail], [aziAcquirente], [aziVenditore], [aziProspect], [aziIndirizzoLeg], [aziIndirizzoOp], [aziLocalitaLeg], [aziLocalitaOp], [aziProvinciaLeg], [aziProvinciaOp], [aziStatoLeg], [aziStatoOp], [aziCAPLeg], [aziCapOp], [aziPrefisso], [aziTelefono1], [aziTelefono2], [aziFAX], [aziLogo], [aziIdDscDescrizione], [aziProssimoProtRdo], [aziProssimoProtOff], [aziGphValueOper], [aziDeleted], [aziDBNumber], [aziAtvAtecord], [aziSitoWeb], [aziCodEurocredit], [aziProfili], [aziProvinciaLeg2], [aziStatoLeg2], [aziFunzionalita], [CertificatoIscrAtt], [TipoDiAmministr]
									FROM Aziende
										WHERE Idazi = ' + cast(@idAzi as varchar(100)) 					
					--print @strSQL
					EXEC(@strSQL)

					--INSERISCO MPAziende NEL VECCHIO DB
					SET @strSQL = 'SET NOCOUNT ON; 
						 INSERT INTO '  +  @dbLegacy + '..MPAziende ( [mpaIdMp], [mpaIdAzi], [mpaAcquirente], [mpaVenditore], [mpaProspect], [mpaDeleted], [mpaDataCreazione], [mpaProfili])
								SELECT  [mpaIdMp], [mpaIdAzi], [mpaAcquirente], [mpaVenditore], [mpaProspect], [mpaDeleted], [mpaDataCreazione], [mpaProfili]
									FROM MPAziende
										WHERE mpaIdAzi = ' + cast(@idAzi as varchar(100)) 					
					--print @strSQL
					EXEC(@strSQL)

					--INSERISCO AziGph NEL VECCHIO DB
					SET @strSQL = 'SET NOCOUNT ON; 
						 INSERT INTO '  +  @dbLegacy + '..AziGph (gphIdAzi, gphValue)
								SELECT gphIdAzi, gphValue
									FROM AziGph
										WHERE gphIdAzi = ' + cast(@idAzi as varchar(100)) 					
					--print @strSQL
					EXEC(@strSQL)
					--RECUPERO I VALORI DA METTERE NELLA DM_ATTRIBUTI					
					select 						
						@Notes = Notes , 
						@codicefiscale = codicefiscale , 
						@SedeINPS = SedeINPS , 
						@UfficioINPS = UfficioINPS , 
						@IndirizzoINPS = IndirizzoINPS , 
						@TelefonoINPS = TelefonoINPS , 
						@FaxINPS = FaxINPS , 
						@NumINPS = NumINPS ,
						@SedeINAIL = SedeINAIL , 
						@UfficioINAIL = UfficioINAIL , 
						@IndirizzoINAIL = IndirizzoINAIL , 
						@TelefonoINAIL = TelefonoINAIL , 
						@FaxINAIL = FaxINAIL , 
						@NumINAIL = NumINAIL , 
						@ProtGen = ProtGen , 
						@DataProt = DataProt , 
						@ClasseIscriz = ClasseIscriz , 
						@sysHabilitStartDate = sysHabilitStartDate , 
						@CARBelongTo = CARBelongTo , 
						@AltraClassificazione = AltraClassificazione , 
						@ANNOCOSTITUZIONE = ANNOCOSTITUZIONE , 
						@IscrCCIAA = IscrCCIAA , 
						@SedeCCIAA = SedeCCIAA , 
						@NotaIscrizioneCCIAA = NotaIscrizioneCCIAA , 
						@Persgiuridica = Persgiuridica , 
						@QualitaImprenditore = QualitaImprenditore , 
						@PAIndirizzoOp = PAIndirizzoOp , 
						@PALocalitaOp = PALocalitaOp , 
						@PAProvinciaOp = PAProvinciaOp , 
						@PACapOp = PACapOp , 
						@PAStatoOp = PAStatoOp , 						

						@Banca = Banca ,
						@AgenziaBanca = AgenziaBanca ,
						@CittaBanca = CittaBanca ,
						@ProvBanca = ProvBanca ,
						@ABIBanca = ABIBanca ,
						@CABBanca = CABBanca ,
						@CINBanca = CINBanca ,
						@CCBanca = CCBanca ,
						@IBAANBanca = IBAANBanca ,
						@SedeEdile = SedeEdile ,
						@UfficioEdile = UfficioEdile ,
						@IndirizzoEdile = IndirizzoEdile,
						@TelefonoEdile = TelefonoEdile ,
						@FaxEdile = FaxEdile ,
						@NumEdile = NumEdile  

					from document_aziende where id = @idAzi 

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''Notes'' ,''' +  replace(@Notes, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''codicefiscale'' ,''' +  replace(@codicefiscale, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''SedeINPS'' ,''' +  replace(@SedeINPS, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''UfficioINPS'' ,''' +  replace(@UfficioINPS, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''IndirizzoINPS'' ,''' +  replace(@IndirizzoINPS, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''TelefonoINPS'' ,''' +  replace(@TelefonoINPS, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''FaxINPS'' ,''' +  replace(@FaxINPS, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''NumINPS'' ,''' +  replace(@NumINPS, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''SedeINAIL'' ,''' +  replace(@SedeINAIL, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''UfficioINAIL'' ,''' +  replace(@UfficioINAIL, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''IndirizzoINAIL'' ,''' +  replace(@IndirizzoINAIL, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''TelefonoINAIL'' ,''' +  replace(@TelefonoINAIL, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''FaxINAIL'' ,''' +  replace(@FaxINAIL, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''NumINAIL'' ,''' +  replace(@NumINAIL, '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''TelefonoINAIL'' ,''' +  replace(@TelefonoINAIL, '''','''''')  + ''''
					EXEC(@strSQL)				

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''ProtGen'' ,''' +  replace( @ProtGen , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''DataProt'' ,''' +  replace( @DataProt , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''ClasseIscriz'' ,''' +  replace( @ClasseIscriz , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''sysHabilitStartDate'' ,''' +  replace( @sysHabilitStartDate , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''CARBelongTo'' ,''' +  replace( @CARBelongTo , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''AltraClassificazione'' ,''' +  replace( @AltraClassificazione , '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''ANNOCOSTITUZIONE'' ,''' +  replace( @ANNOCOSTITUZIONE , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''IscrCCIAA'' ,''' +  replace( @IscrCCIAA , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''SedeCCIAA'' ,''' +  replace( @SedeCCIAA , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''NotaIscrizioneCCIAA'' ,''' +  replace( @NotaIscrizioneCCIAA , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''Persgiuridica'' ,''' +  replace( @Persgiuridica , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''QualitaImprenditore'' ,''' +  replace( @QualitaImprenditore , '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''PAIndirizzoOp'' ,''' +  replace( @PAIndirizzoOp , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''PALocalitaOp'' ,''' +  replace( @PALocalitaOp , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''PAProvinciaOp'' ,''' +  replace( @PAProvinciaOp , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''PACapOp'' ,''' +  replace( @PACapOp , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''PAStatoOp'' ,''' +  replace( @PAStatoOp , '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''Banca'' ,''' +  replace( @Banca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''AgenziaBanca'' ,''' +  replace( @AgenziaBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''CittaBanca'' ,''' +  replace( @CittaBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''ProvBanca'' ,''' +  replace( @ProvBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''ABIBanca'' ,''' +  replace( @ABIBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''CABBanca'' ,''' +  replace( @CABBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''CINBanca'' ,''' +  replace( @CINBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''CCBanca'' ,''' +  replace( @CCBanca , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''IBAANBanca'' ,''' +  replace( @IBAANBanca , '''','''''')  + ''''
					EXEC(@strSQL)

					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''SedeEdile'' ,''' +  replace( @SedeEdile, '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''UfficioEdile'' ,''' +  replace( @UfficioEdile , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''IndirizzoEdile'' ,''' +  replace( @IndirizzoEdile , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''TelefonoEdile'' ,''' +  replace( @TelefonoEdile , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''FaxEdile'' ,''' +  replace( @FaxEdile , '''','''''')  + ''''
					EXEC(@strSQL)
					SET @strSQL = 'SET NOCOUNT ON;
						execute ' + @dbLegacy + '..UpdAttrAzi ' + cast(@idAzi as varchar(100)) +', ''NumEdile'' ,''' +  replace( @NumEdile, '''','''''')  + ''''
					EXEC(@strSQL)


			END
		END

	END

END








GO
