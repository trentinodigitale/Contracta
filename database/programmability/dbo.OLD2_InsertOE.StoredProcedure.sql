USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_InsertOE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROC [dbo].[OLD2_InsertOE] (@IdDoc INT)
AS

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
	declare @aziRagioneSocialeNorm nvarchar(1000)
	declare @aziRagioneSociale nvarchar(1000)
	declare @azitelefono            VARCHAR(100)
	declare @aziE_Mail              varchar(300)
	declare @CodiceFiscale as VARCHAR(100)
	declare @idpfu as int
	declare @Nome_Utente as nvarchar(255)
	declare @Cognome_Utente as  nvarchar(255)
	declare @PfuNome as  nvarchar(530)
	declare @CodiceFiscale_Utente as varchar(100)
	declare @aziVenditore smallint
	declare @mpaIdMp as smallint

	set @aziVenditore = 2

	declare @AlgoritmoPwd as varchar(2)
	set @AlgoritmoPwd = '0'
	select 	@AlgoritmoPwd=isnull(DZT_ValueDef,'0') from lib_dictionary where dzt_name='SYS_PWD_ALGORITMO'


	SET @Gph = 0
	SET @Atv = '###0###'



	declare @pfuOpzioni varchar(500)
	declare @MP varchar(20)

	set @MP=null

	--recupero marketplace dalla sys
	select @MP = dzt_valuedef from lib_dictionary where dzt_name='SYS_MarketPlace'

	--DUBBIO chiedere a Sabato se ok
	select @mpaIdMp = idmp from MarketPlace where mpLog = @MP

	set @pfuOpzioni = '11010100000000000000000000000000000000000000000000'

	if @MP = 'PA'
		set @pfuOpzioni = '11010110000000000000000000000000000000000000000000'

	select 
			@RagSoc = aziRagioneSociale ,
			@aziIndirizzoLeg = aziIndirizzoLeg,
			@aziLocalitaLeg2 = aziLocalitaLeg2,
			@aziCAPLeg = aziCAPLeg, 
			@aziLocalitaLeg = aziLocalitaLeg,
			@aziProvinciaLeg2 = aziProvinciaLeg2,
			@aziStatoLeg2 = aziStatoLeg2,
			@aziPArtitaIVA = aziPArtitaIVA,
			@aziTelefono = aziTelefono1,
			@aziTelefono2 = aziTelefono2,
			@aziFAX = aziFAX,
			@aziE_Mail = aziE_Mail,
			@aziSitoWeb = aziSitoWeb ,
			@aziRagioneSocialeNorm = replace(aziRagioneSociale,' ','') ,
			@CodiceFiscale = codicefiscale,
			@Nome_Utente = NomeRapLeg ,
			@Cognome_Utente = CognomeRapLeg ,
			@CodiceFiscale_Utente = CFRapLeg ,
			@PfuNome = NomeRapLeg + ' ' + CognomeRapLeg
			from 
				Document_Aziende 
			where id = @IdDoc


	insert into Aziende (

					aziVenditore,aziRagioneSociale,aziIndirizzoLeg,aziLocalitaLeg2,aziCAPLeg,aziLocalitaLeg,aziProvinciaLeg2,aziStatoLeg2,aziPArtitaIVA
					,aziTelefono1,aziTelefono2,aziFAX,aziE_Mail,aziSitoWeb,aziDataCreazione,aziRagioneSocialeNorm ,aziProfili
							)
					values

					(

					@aziVenditore,@RagSoc,@aziIndirizzoLeg,@aziLocalitaLeg2,@aziCAPLeg,@aziLocalitaLeg,@aziProvinciaLeg2,@aziStatoLeg2,@aziPArtitaIVA
					,@aziTelefono,@aziTelefono2,@aziFAX,@aziE_Mail,@aziSitoWeb,GETDATE(),@aziRagioneSocialeNorm ,'S'

					)		


	set @NewIdAzi = SCOPE_IDENTITY ()

	--aggiorno idazi della nuov aazienda sulla tabella document_aziende
	UPDATE 
		Document_Aziende 
			SET IdAzi = @NewIdAzi 
		WHERE Id = @IdDoc


	execute UpdAttrAzi @NewIdAzi , 'codicefiscale', @CodiceFiscale 

	---- inserisco anche mpaziende
	INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaacquirente, mpaVenditore ,  mpaProfili, mpaDeleted)
			VALUES (@mpaIdMp, @NewIdAzi, 0, @aziVenditore ,'S', 0)

	INSERT INTO AziGph (gphIdAzi, gphValue) VALUES (@NewIdAzi, @Gph)

	insert into Aziateco(AtvAtecord, idazi) values (@Atv, @NewIdAzi)

	-- inserimento utente
	SET @Login    = upper(LEFT(replace(@RagSoc,' ',''), 12))
	----SET @Password = LEFT(@strClean, 12)
	set @Password=''
	exec usp_GenRandomPWD @Password output

	EXEC usp_Encrypt @Password, @PasswordC OUTPUT
	set @PasswordC=''
	exec EncryptPwdUser -1, @Password , @PasswordC output



	INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziENDale, pfuPassword, pfuPrefissoProt, 
				pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni, 
				pfutel, pfucell,pfuAlgoritmoPassword,pfuCodiceFiscale,pfunomeutente ,pfuCognome  )
	SELECT @NewIdAzi, @PfuNome , @Login, '', @PasswordC, 
			LEFT(@Login, 3), 1, 1, @aziE_Mail, 'S', funzionalita, @pfuOpzioni, 
			@azitelefono, '',@AlgoritmoPwd,@CodiceFiscale_Utente ,@Nome_Utente ,@Cognome_Utente 
				FROM Profili_Funzionalita with (nolock)
				WHERE codice = 'FORNITORE'

			

	set @idpfu = SCOPE_IDENTITY ()

	insert into ProfiliUtenteAttrib
		(idpfu,dztNome ,attValue )
	values (@idpfu,'Profilo','FORNITORE')



GO
