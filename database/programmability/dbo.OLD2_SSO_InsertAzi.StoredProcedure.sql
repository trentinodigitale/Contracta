USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SSO_InsertAzi]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[OLD2_SSO_InsertAzi] 
( 
	@CodiceFiscaleAzi varchar(100), 
	@RagioneSocialeAzi nvarchar(1000), 
	@EmailAzi nvarchar(1000), 
	@PartitaIvaAzi varchar(100),
	@CittaAzi nvarchar(500),
	@ViaAzi nvarchar(500),
	@CivicoAzi varchar(100),
	@CapAzi varchar(100),
	@TelefonoAzi varchar(500),
	@FaxAzi varchar(500),
	@NazioneAzi nvarchar(500),
	@ProvinciaAzi varchar(500),
	@codiceIstatComune varchar(100),
	@codicaEsternaTipoAzi varchar(100), -- per un OE è la codifica esterna della natura giuridica, per l'ente è la codifica esterna del tipo di amministrazione
	@isEnte int = 0,
	@sitoWEB nvarchar(2000) = ''
)
AS

	SET NOCOUNT ON

	DECLARE @NewIdAzi		INT
	DECLARE @strClean		VARCHAR(100)

	DECLARE @Atv			VARCHAR(100)
	DECLARE @Gph			INT

	DECLARE @nLen			INT

	DECLARE @aziAcquirente	INT
	DECLARE @aziVenditore	INT
	DECLARE @aziProfili		VARCHAR(10)

	DECLARE @valore			VARCHAR(400)

	declare @LOCALITA_OUT	NVARCHAR(2000) 
	declare @PROVINCIA_OUT	NVARCHAR(2000) 
	declare @STATO_OUT		NVARCHAR(2000) 
	declare @REGIONE_OUT	NVARCHAR(2000)
	declare @LOCALITA_INT	NVARCHAR(2000)
	declare @PROVINCIA_INT	NVARCHAR(2000)
	declare @STATO_INT		NVARCHAR(2000)

	declare @naturaGiuridica int
	declare @tipoDiAmministr nvarchar(100)

	set @tipoDiAmministr = ''
	set @naturaGiuridica = 0
	set @aziAcquirente = 0
	set @aziVenditore = 2
	set @aziProfili = ''

	SET @Gph = 0
	SET @Atv = '###0###'

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

	IF  @nLen > 4
	BEGIN
		IF  RIGHT (@strClean, 3) = 'SPA' OR RIGHT (@strClean, 3) = 'SNC' OR RIGHT (@strClean, 3) = 'SRL'
		BEGIN
			SET @strClean = LEFT(@strClean, @nLen - 3)                       
		END
	END

	IF @isEnte = 0 
	BEGIN

		set @aziAcquirente = 0
		set @aziVenditore = 2
		set @aziProfili = 'S'

	END
	ELSE
	BEGIN

		set @aziAcquirente = 3
		set @aziVenditore = 0
		set @aziProfili = 'PE'

	END

	set @LOCALITA_OUT = null
	set @PROVINCIA_OUT = null
	set @STATO_OUT = null
	set @REGIONE_OUT = null

	-- gestendo noi il codice istat in forma numerica (e non alfanumerico normlizzato) non abbiamo gli 0 a sx
	IF LEFT(@codiceIstatComune,1) = '0'
	BEGIN
		set @codiceIstatComune = right(@codiceIstatComune,5)
	END

	--codiceistat di test : 37011
	EXEC SSO_GetGEO_FomComune @codiceIstatComune, 
							  @CittaAzi, 
							  @ProvinciaAzi,
							  @NazioneAzi,
							  @LOCALITA_OUT out,
							  @PROVINCIA_OUT out,
							  @STATO_OUT out, 
							  @REGIONE_OUT out,
							  @LOCALITA_INT out,
							  @PROVINCIA_INT out,
							  @STATO_INT out

	-- se è stata una corrispondenza con il nostro dominio GEO.. sovrascrivo le variabili passate con i valori recuperati
	IF @LOCALITA_INT <> ''
	BEGIN

		set @CittaAzi = @LOCALITA_OUT
		set @ProvinciaAzi = @PROVINCIA_OUT
		set @NazioneAzi = @STATO_OUT

	END

	INSERT INTO Aziende (aziDataCreazione, aziRagioneSociale, aziRagioneSocialeNorm, aziPartitaIVA, aziE_Mail, aziAcquirente, 
						 aziVENDitore, aziProspect, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg,  
						 aziCAPLeg, aziTelefono1, aziFAX,  aziProssimoProtRdo, aziProssimoProtOff, 
						 aziGphValueOper, aziDeleted, aziProfili, aziStatoLeg2, aziProvinciaLeg2, aziLocalitaLeg2  )
		VALUES (   getdate(), @RagioneSocialeAzi, @strClean , @PartitaIvaAzi, @EmailAzi, @aziAcquirente, 
				   @aziVenditore, 0, @ViaAzi + isnull(@CivicoAzi,''), @CittaAzi, @ProvinciaAzi, @NazioneAzi,  
				   @CapAzi, @TelefonoAzi, @FaxAzi, 1, 1, 
				   0, 0, @aziProfili, @STATO_INT, @PROVINCIA_INT, @LOCALITA_INT  )

	SET @NewIdAzi = @@IDENTITY

	INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaacquirente, mpaProfili, mpaDeleted)
		 VALUES (1, @NewIdAzi, 3, 'P', 0)

	INSERT INTO AziGph (gphIdAzi, gphValue) 
		VALUES (@NewIdAzi, @Gph)

	EXEC InsAteco @NewIdAzi, @Atv

	UPDATE Aziende 
	   SET aziAtvAtecord = (SELECT TOP 1 AtvAtecord FROM  Aziateco with(nolock) WHERE  IdAzi = @NewIdAzi) 
	 WHERE IdAzi = @NewIdAzi


	 IF @isEnte = 0
	 BEGIN
		
		-- Se sono un OE effettuo la trascodifica della forma giuridica
		select top 1 @naturaGiuridica = ValOut 
			from CTL_Transcodifica with(nolock) 
			where sistema = 'soresa' and dztNome = 'aziIdDscFormaSoc' and valin = @codicaEsternaTipoAzi

		UPDATE Aziende 
			SET aziFunzionalita = '0010000000000001111110000000000001111111000000100000000000000111111000000001111001110110011100101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000001000100001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'  
				,aziIdDscFormaSoc = @naturaGiuridica
		WHERE IdAzi = @NewIdAzi

	 END
	 ELSE
	 BEGIN

		-- Se sono un OE effettuo la trascodifica del tipo di amministrazione
		select top 1 @tipoDiAmministr = ValOut 
			from CTL_Transcodifica with(nolock) 
			where sistema = 'soresa' and dztNome = 'TIPO_AMM_ER' and valin = @codicaEsternaTipoAzi

		--Inserisco il codicefiscale nella DM_ATTRIBUTI
		EXEC UpdAttrAzi @NewIdAzi , 'TIPO_AMM_ER', @tipoDiAmministr 

		UPDATE Aziende 
			SET aziFunzionalita = '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'
		WHERE IdAzi = @NewIdAzi

	 END

		
	--Inserisco il codicefiscale nella DM_ATTRIBUTI
	EXEC UpdAttrAzi @NewIdAzi , 'codicefiscale', @CodiceFiscaleAzi 

	-- Ritorno al chiamante l'id dell'azienda appena creata
	select @NewIdAzi as idAzi











GO
