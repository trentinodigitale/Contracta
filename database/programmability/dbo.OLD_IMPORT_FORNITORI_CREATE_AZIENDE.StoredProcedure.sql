USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_IMPORT_FORNITORI_CREATE_AZIENDE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--/****** Object:  StoredProcedure [dbo].[IMPORT_FORNITORI_CREATE_AZIENDE]    Script Date: 09/01/2021 21:15:59 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO



--select * from #NewAzi
--drop table #NewAzi



CREATE PROC [dbo].[OLD_IMPORT_FORNITORI_CREATE_AZIENDE] (@IdDoc INT)
AS

--declare @IdDoc int
--set @IdDoc = 632


	DECLARE @NewIdAzi               INT
	DECLARE @RagSoc                 VARCHAR(100)
	DECLARE @strClean               VARCHAR(100)
	DECLARE @Atv                    VARCHAR(100)
	DECLARE @Gph                    INT
	DECLARE @Login                  VARCHAR(20)
	DECLARE @Password               VARCHAR(250)
	DECLARE @PasswordC              VARCHAR(250)
	DECLARE @email                  VARCHAR(100)
	DECLARE @nLen                   INT
	DECLARE @CognomeUtente          VARCHAR(100)
	DECLARE @EMailUtente            VARCHAR(100)
	DECLARE @RuoloUtente            VARCHAR(100)
	DECLARE @NomeTemp               VARCHAR(100)
	DECLARE @IdArt                  INT
	DECLARE @IdMdl                  INT
	DECLARE @IdArtNew               INT
	DECLARE @artCode                VARCHAR(100)
	DECLARE @artIdDscDescrizione    INT
	DECLARE @artIdUms               INT
	DECLARE @artQMO                 INT
	DECLARE @artCspValue            VARCHAR(100)
	DECLARE @azitelefono            VARCHAR(100)
	declare @aziE_Mail              varchar(300)
	declare @idpfu int
	declare @Valore					varchar(100)
	declare @AlgoritmoPwd as varchar(2)
	declare @cnt int
	declare @aziVenditore smallint
	declare @aziIndirizzoLeg varchar(500)
	declare @aziLocalitaLeg2 varchar(500)
	declare @aziCAPLeg varchar(50)
	declare @aziLocalitaLeg varchar(500)
	declare @aziProvinciaLeg2 varchar(500)
	declare @aziStatoLeg2 varchar(500)
	declare @aziPArtitaIVA  varchar(50)
	declare @aziTelefono2 varchar(50)
	declare @aziFAX varchar(50)
	declare @aziSitoWeb varchar(500)
	declare @aziDataCreazione datetime
	declare @aziRagioneSocialeNorm varchar(1000)
	declare @aziRagioneSociale varchar(1000)







	set @cnt = 0

	set @AlgoritmoPwd = '0'

	select 	@AlgoritmoPwd=isnull(DZT_ValueDef,'0') from lib_dictionary where dzt_name='SYS_PWD_ALGORITMO'

	SET @Gph = 0
	SET @Atv = '###0###'

	--SELECT @Atv = aziAtvAtecord
	--	 , @RagSoc = aziRagioneSociale 
	--	 , @email = aziE_Mail 
	--  FROM Document_Aziende 
	-- WHERE Id = @IdDoc 



	--------------------------------------------
	-- prendo  tutte i CF delle nuove anagrafiche che non presentano problemi
	--------------------------------------------
	--select distinct CodiceFiscale , aziPArtitaIVA , 0 as idNAzi
	select  OE.* , 0 as  idNewAzi
		into #NewAzi
		from IMPORT_FORNITORI_ELENCO_OE_2 OE
			left join ( select vatvalore_FT as CF 
											from Aziende a with(nolock)	
											inner join DM_Attributi d with(nolock) on d.idapp=1 and d.lnk = a.IdAzi and d.dztNome = 'CodiceFiscale' 
											where a.aziDeleted = 0 and a.aziVenditore > 0  
									) as a on a.CF = Codicefiscale
									
			where idheader = @IdDoc
				 and a.CF is null -- CF non esistente
				 and isnull( EsitoImport , '' ) <> '0' -- non sono presenti errori
				 and CodiceFiscale <> ''
				 --and aziPArtitaIVA <> ''
				 --and CodiceFiscale = '22233366699888'

--dm_attributi.CodiceFiscale
--dm_Attributi.CARCodiceFornitore

	-- creo le nuove aziende
	--insert into Aziende (

	--						aziVenditore

	--						,aziRagioneSociale
	--						--,aziRagioneSociale
	--						,aziIndirizzoLeg
	--						--,aziIndirizzoLeg
	--						,aziLocalitaLeg2
	--						,aziCAPLeg
	--						,aziLocalitaLeg
	--						,aziProvinciaLeg2
	--						,aziStatoLeg2
	--						,aziPArtitaIVA
	--						--,aziPArtitaIVA

	--						,aziTelefono1
	--						,aziTelefono2
	--						,aziFAX
	--						,aziE_Mail
	--						,aziSitoWeb
	--						,aziDataCreazione
	--						,aziRagioneSocialeNorm 
	--					)


	--	select aziVenditore

	--		,aziRagioneSociale
	--		--,aziRagioneSociale
	--		,aziIndirizzoLeg
	--		--,aziIndirizzoLeg
	--		,aziLocalitaLeg2
	--		,aziCAPLeg
	--		,aziLocalitaLeg
	--		,aziProvinciaLeg2
	--		,aziStatoLeg2
	--		,aziPArtitaIVA
	--		--,aziPArtitaIVA

	--		,aziTelefono1
	--		,aziTelefono2
	--		,aziFAX
	--		,aziE_Mail
	--		,aziSitoWeb
	--		,convert( datetime , aziDataCreazione , 105 )
	--		,replace(aziRagioneSociale,' ','')

	--	from #NewAzi

	declare @pfuOpzioni varchar(500)
	declare @MP varchar(20)

	set @MP=null

	select @mp=mplog from MarketPlace 

	set @pfuOpzioni = '11010100000000000000000000000000000000000000000000'

	if @MP = 'PA'
		set @pfuOpzioni = '11010110000000000000000000000000000000000000000000'
	-- recupera gli IDAZI associati alle PIVA per collegarci il CF
	--update N set idNewAzi = idazi from #NewAzi n inner join Aziende a with(nolock) on n.aziPArtitaIVA = a.aziPArtitaIVA

	-- inserisco il CF per ogni azienda
	DECLARE crs CURSOR static FOR 
		--SELECT idNewAzi , codicefiscale, aziRagioneSociale,aziE_Mail,aziTelefono1    FROM #NewAzi
            SELECT  codicefiscale, aziRagioneSociale,aziE_Mail,aziTelefono1,2 as aziVenditore, aziIndirizzoLeg,
					   aziLocalitaLeg2,aziCAPLeg,aziLocalitaLeg,aziProvinciaLeg2,aziStatoLeg2,aziPArtitaIVA,
					   aziTelefono2,aziFAX,aziSitoWeb,convert( datetime , aziDataCreazione , 105 ),replace(aziRagioneSociale,' ','')

				FROM #NewAzi
			             
	OPEN crs

	FETCH NEXT FROM crs INTO /*@NewIdAzi ,*/ @Valore, @RagSoc,@aziE_Mail,@azitelefono,
		@aziVenditore, @aziIndirizzoLeg, @aziLocalitaLeg2,@aziCAPLeg,@aziLocalitaLeg,@aziProvinciaLeg2,
		@aziStatoLeg2,@aziPArtitaIVA,  @aziTelefono2,@aziFAX,@aziSitoWeb,@aziDataCreazione ,@aziRagioneSocialeNorm

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @cnt = @cnt + 1

		insert into Aziende (

							aziVenditore,aziRagioneSociale,aziIndirizzoLeg,aziLocalitaLeg2,aziCAPLeg,aziLocalitaLeg,aziProvinciaLeg2,aziStatoLeg2,aziPArtitaIVA
							,aziTelefono1,aziTelefono2,aziFAX,aziE_Mail,aziSitoWeb,aziDataCreazione,aziRagioneSocialeNorm ,aziProfili
						)
				values

				(

				@aziVenditore,@RagSoc,@aziIndirizzoLeg,@aziLocalitaLeg2,@aziCAPLeg,@aziLocalitaLeg,@aziProvinciaLeg2,@aziStatoLeg2,@aziPArtitaIVA
				,@aziTelefono,@aziTelefono2,@aziFAX,@aziE_Mail,@aziSitoWeb,@aziDataCreazione,@aziRagioneSocialeNorm ,'S'

				)		


		set @NewIdAzi = SCOPE_IDENTITY ()

		execute UpdAttrAzi @NewIdAzi , 'codicefiscale', @Valore 

		---- inserisco anche mpaziende
		INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaacquirente, mpaVenditore ,  mpaProfili, mpaDeleted)
			 VALUES (1, @NewIdAzi, 0, 2 ,'S', 0)

		INSERT INTO AziGph (gphIdAzi, gphValue) VALUES (@NewIdAzi, @Gph)

		insert into Aziateco(AtvAtecord, idazi) values (@Atv, @NewIdAzi)

		-- inserimento utente
		SET @Login    = LEFT(replace(@RagSoc,' ',''), 12)
		----SET @Password = LEFT(@strClean, 12)
		set @Password=''
		exec usp_GenRandomPWD @Password output

		EXEC usp_Encrypt @Password, @PasswordC OUTPUT
		set @PasswordC=''
		exec EncryptPwdUser -1, @Password , @PasswordC output

		INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziENDale, pfuPassword, pfuPrefissoProt, 
					pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni, 
					pfutel, pfucell,pfuAlgoritmoPassword,pfuCodiceFiscale,pfunomeutente ,pfuCognome  )
		SELECT @NewIdAzi, @Login, @Login, '', @PasswordC, 
				LEFT(@Login, 3), 1, 1, @aziE_Mail, 'S', funzionalita, @pfuOpzioni, 
				@azitelefono, '',@AlgoritmoPwd,@Valore,'Utente',@RagSoc
				  FROM Profili_Funzionalita 
				 WHERE codice = 'FORNITORE'

		set @idpfu = SCOPE_IDENTITY ()

		insert into ProfiliUtenteAttrib
			(idpfu,dztNome ,attValue )
		values (@idpfu,'Profilo','FORNITORE')

		FETCH NEXT FROM crs INTO /*@NewIdAzi ,*/ @Valore, @RagSoc,@aziE_Mail,@azitelefono,
		@aziVenditore, @aziIndirizzoLeg, @aziLocalitaLeg2,@aziCAPLeg,@aziLocalitaLeg,@aziProvinciaLeg2,
		@aziStatoLeg2,@aziPArtitaIVA,  @aziTelefono2,@aziFAX,@aziSitoWeb,@aziDataCreazione ,@aziRagioneSocialeNorm
	END
	CLOSE crs
	DEALLOCATE crs


	---- gestione update
	update aziende
		set  aziVenditore = 2 --y.aziVenditore
			,aziRagioneSociale	= y.aziRagioneSociale		
			,aziIndirizzoLeg	= y.aziIndirizzoLeg		
			,aziLocalitaLeg2 = y.aziLocalitaLeg2
			,aziCAPLeg = y.aziCAPLeg
			,aziLocalitaLeg = y.aziLocalitaLeg
			,aziProvinciaLeg2 = y.aziProvinciaLeg2
			,aziStatoLeg2 = y.aziStatoLeg2
			,aziPArtitaIVA = y.aziPArtitaIVA
			,aziTelefono1 = y.aziTelefono1
			,aziTelefono2 = y.aziTelefono2
			,aziFAX = y.aziFAX
			,aziE_Mail = y.aziE_Mail
			,aziSitoWeb = y.aziSitoWeb

		from aziende x,
			(select OE.* , a.idazi -- 0 as  idNewAzi
				--into #NewAzi
				from IMPORT_FORNITORI_ELENCO_OE_2 OE
					left join ( select vatvalore_FT as CF ,d.lnk as idazi
													from Aziende a with(nolock)	
													inner join DM_Attributi d with(nolock) on d.idapp=1 and d.lnk = a.IdAzi and d.dztNome = 'CodiceFiscale' 
													where a.aziDeleted = 0 and a.aziVenditore > 0  
											) as a on a.CF = Codicefiscale
									
					where idheader = @IdDoc
						 and a.CF is not null -- CF  esistente
						 and isnull( EsitoImport , '' ) <> '0' -- non sono presenti errori
						 and CodiceFiscale <> ''
						 --and aziPArtitaIVA <> ''
						 and CodiceFiscale  not in (select CodiceFiscale from  #NewAzi) -- escludiamo quelle appena inserite
			
			) y where x.idazi=y.idazi

	drop table #NewAzi

	--update ctl_doc set versione = cast(@cnt as varchar(10)) where id = @IdDoc
	
	--INSERT INTO AziGph (gphIdAzi, gphValue) VALUES (@NewIdAzi, @Gph)


	--insert into Aziateco(AtvAtecord, idazi) values (@valtemp1, @idazi)
	----EXEC InsAteco @NewIdAzi, @Atv


	--UPDATE Aziende 
	--   SET aziAtvAtecord = (SELECT TOP 1 AtvAtecord FROM  Aziateco WHERE  IdAzi = @NewIdAzi) 
	-- WHERE IdAzi = @NewIdAzi




	
	--SET @CognomeUtente = NULL
	--SET @EMailUtente = NULL
	--SET @RuoloUtente = NULL

	--SELECT @CognomeUtente = CognomeUtente
	--	 , @EMailUtente = EMailUtente
	--	 , @RuoloUtente = RuoloUtente 
	--  FROM Document_Aziende_Utenti 
	-- WHERE IdHeader = @IdDoc

	--IF @CognomeUtente IS NOT NULL 
	--	SET @NomeTemp = @CognomeUtente 
	--ELSE
	--	SET @NomeTemp = LEFT(@RagSoc, 30)

	---- A meno che non è richiesto nella sys, non censiamo un nuovo utente alla creazione dell'ente
	--IF EXISTS ( select * from LIB_Dictionary a with (nolock) where a.DZT_Name = 'SYS_ENTE_NUOVO_REGISTRA_RAPLEG' and isnull(a.DZT_ValueDef,'no') <> 'no' )
	--BEGIN

	--	IF @CognomeUtente IS NOT NULL 
	--	BEGIN
	--			INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziENDale, pfuPassword, pfuPrefissoProt, 
	--									   pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni, pfutel, pfucell,pfuAlgoritmoPassword)
	--			SELECT @NewIdAzi, LEFT(CognomeUtente, 30), LEFT(REPLACE(CognomeUtente, ' ', ''), 12), ISNULL(RuoloUtente, 'Responsabile'), dbo.EncryptPwd(LEFT(REPLACE(CognomeUtente, ' ', ''), 12)), 
	--			LEFT(@strClean, 3), 0, 1, EMailUtente, LEFT(funzionalitautente, 1), left( right(funzionalitautente, 1000) + REPLICATE ('0',600),1000 ), '11010100000000000000000000000000000000000000000000', TelefonoUtente, CellulareUtente,@AlgoritmoPwd
	--			  FROM Document_Aziende_Utenti 
	--			 WHERE IdHeader = @IdDoc 
	--	END
	--	ELSE
	--	BEGIN 
	--			INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziENDale, pfuPassword, pfuPrefissoProt, 
	--									   pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni,pfuAlgoritmoPassword)
	--					VALUES (@NewIdAzi, @NomeTemp, @Login, ISNULL(@RuoloUtente, 'Responsabile'), @PasswordC, 
	--							LEFT(@strClean, 3), 0, 1, ISNULL(@EMailUtente, @EMail), 'B', '1101111001011111000001111111111010000000110011111110111111111000000011011110000111001001100011011000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000100100011001001101111000111111111110000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', 
	--							'11010100000000000000000000000000000000000000000000',@AlgoritmoPwd)
	--	END

	--END

	--UPDATE Aziende 
	--   SET aziFunzionalita = '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'  
	-- WHERE IdAzi = @NewIdAzi

	--DECLARE crs CURSOR static FOR SELECT IdArt
	--							, IdMdl
	--							, artCspValue
	--							, artCode
	--							, artIdDscDescrizione
	--							, artIdUms
	--						 FROM Articoli
	--							, Modelli_Prodotti
	--						WHERE mdlIdArt = IdArt
	--						  AND artIdAzi = 35152001
	--						  AND artDeleted = 0
                          
	--OPEN crs

	--FETCH NEXT FROM crs INTO @IdArt, @IdMdl, @artCspValue, @artCode, @artIdDscDescrizione, @artIdUms

	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	--		INSERT INTO Articoli (artIdAzi, artCspValue, artCode, artIdDscDescrizione, artIdUms, artQMO)
	--				VALUES (@NewIdAzi, @artCspValue, @artCode, @artIdDscDescrizione, @artIdUms, @artQMO)
                
	--		SET @IdArtNew = SCOPE_IDENTITY()
        
	--		INSERT INTO Modelli_Prodotti (IdMdl, mdlIdArt)
	--				VALUES (@IdMdl, @IdArtNew)

	--		FETCH NEXT FROM crs INTO @IdArt, @IdMdl, @artCspValue, @artCode, @artIdDscDescrizione, @artIdUms
	--END
	--CLOSE crs
	--DEALLOCATE crs

	----Inserisco il codicefiscale dell'ente nella DM_ATTRIBUTI
	--declare @valore as varchar(400)
	--select @Valore = codicefiscale from document_aziende where id = @IdDoc 
	--		execute UpdAttrAzi @NewIdAzi , 'codicefiscale', @Valore 







GO
