USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SSO_UpdateAzi]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD_SSO_UpdateAzi] ( 
			@idAzi INT,
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
			@codiceIstatComune varchar(500)
)
AS

	SET NOCOUNT ON 

	DECLARE @valore			VARCHAR(400)
	DECLARE @datiVariati	INT
	DECLARE @strClean		nvarchar(1000)
	declare @nLen int
	declare @aziVenditore int
	declare @TipoDoc varchar(100)

	DECLARE @RagioneSocialeAzi1 nvarchar(1000)
	DECLARE @EmailAzi1 nvarchar(1000)
	DECLARE @PartitaIvaAzi1 varchar(100)
	DECLARE @CittaAzi1 nvarchar(500)
	DECLARE @ViaAzi1 nvarchar(500)
	DECLARE @CivicoAzi1 varchar(100)
	DECLARE @CapAzi1 varchar(100)
	DECLARE @TelefonoAzi1 varchar(500)
	DECLARE @FaxAzi1 varchar(500)
	DECLARE @NazioneAzi1 nvarchar(500)
	DECLARE @ProvinciaAzi1 varchar(500)

	DECLARE @codGeoLocalita nvarchar(2000)

	declare @LOCALITA_OUT	NVARCHAR(2000) 
	declare @PROVINCIA_OUT	NVARCHAR(2000) 
	declare @STATO_OUT		NVARCHAR(2000) 
	declare @REGIONE_OUT	NVARCHAR(2000)
	declare @LOCALITA_INT	NVARCHAR(2000)
	declare @PROVINCIA_INT	NVARCHAR(2000)
	declare @STATO_INT		NVARCHAR(2000)
	DECLARE @COD_ISTAT_COMUNE NVARCHAR(2000)

	set @datiVariati = 0

	select top 1 @RagioneSocialeAzi1 = isnull(azi.aziRagioneSociale,''),
				 @EmailAzi1 = isnull(azi.aziE_Mail,''),
				 @PartitaIvaAzi1 = isnull(azi.aziPartitaIVA,''),
				 @CittaAzi1 = isnull(azi.aziLocalitaLeg,''),
				 @ViaAzi1 = isnull(azi.aziIndirizzoLeg,''),
				 @CapAzi1 = isnull(azi.aziCAPLeg,''),
				 @TelefonoAzi1 = isnull(azi.aziTelefono1,''),
				 @FaxAzi1 = isnull(azi.aziFAX,''),
				 @NazioneAzi1 = isnull(azi.aziStatoLeg,''),
				 @ProvinciaAzi1 = isnull(azi.aziProvinciaLeg,''),
				 @codGeoLocalita = isnull( azi.aziLocalitaLeg2, '')
		from aziende azi with(nolock)
		where azi.idazi = @idAzi 

	set @LOCALITA_OUT = null
	set @PROVINCIA_OUT = null
	set @STATO_OUT = null
	set @REGIONE_OUT = null

	-- gestendo noi il codice istat in forma numerica (e non alfanumerico normlizzato) non abbiamo gli 0 a sx
	IF LEFT(@codiceIstatComune,1) = '0'
	BEGIN
		set @codiceIstatComune = right(@codiceIstatComune,5)
	END

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

	IF @RagioneSocialeAzi1 <> @RagioneSocialeAzi OR @EmailAzi1 <> @EmailAzi OR @PartitaIvaAzi1 <> @PartitaIvaAzi 
		OR @ViaAzi1 <> @ViaAzi OR @CapAzi1 <> @CapAzi OR @TelefonoAzi1 <> @TelefonoAzi
		OR @FaxAzi1 <> @FaxAzi OR @LOCALITA_INT <> @codGeoLocalita 
	BEGIN
		set @datiVariati = 1
	END

	IF @datiVariati = 1
	BEGIN

		
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

		-- se è stata una corrispondenza con il nostro dominio GEO.. sovrascrivo le variabili passate con i valori recuperati
		IF @LOCALITA_INT <> ''
		BEGIN

			set @CittaAzi = @LOCALITA_OUT
			set @ProvinciaAzi = @PROVINCIA_OUT
			set @NazioneAzi = @STATO_OUT

		END
		
		UPDATE aziende
			set aziRagioneSociale = @RagioneSocialeAzi
				, aziRagioneSocialeNorm = @strClean 
				, aziE_Mail = @EmailAzi 
				, aziPartitaIVA = @PartitaIvaAzi 
				, aziLocalitaLeg = @CittaAzi
				, aziIndirizzoLeg = @ViaAzi
				, aziCAPLeg = @CapAzi 
				, aziTelefono1 = @TelefonoAzi
				, aziFAX = @FaxAzi
				, aziStatoLeg = @NazioneAzi
				, aziProvinciaLeg = @ProvinciaAzi
				, aziStatoLeg2 = @STATO_INT 
				, aziProvinciaLeg2 = @PROVINCIA_INT 
				, aziLocalitaLeg2 = @LOCALITA_INT 
		where idazi = @idAzi

		-- Se è un operatore economico
		IF @aziVenditore <> 0
		BEGIN
			set @TipoDoc = 'AZI_UPD_SCHEDA_ANAGRAFICA_OE'
		END
		ELSE
		BEGIN
			set @TipoDoc = 'AZI_UPD_SCHEDA_ANAGRAFICA'
		END

		INSERT INTO Document_Aziende
				   (IdPfu,TipoOperAnag,Stato,isOld,IdAzi,aziDataCreazione,aziRagioneSociale,aziIdDscFormaSoc,aziPartitaIVA,aziE_Mail
				   ,aziAcquirente,aziVenditore,aziProspect,aziIndirizzoLeg,aziLocalitaLeg,aziProvinciaLeg,aziStatoLeg,aziCAPLeg,aziTelefono1
				   ,aziTelefono2,aziFAX,aziProssimoProtRdo,aziProssimoProtOff,aziGphValueOper,aziDeleted
				   ,aziSitoWeb,aziProfili,aziProvinciaLeg2,aziStatoLeg2
				   ,codicefiscale,TipoDiAmministr,TIPO_AMM_ER,aziLocalitaLeg2,aziRegioneLeg,aziRegioneLeg2)
			 VALUES ( null,@TipoDoc, 'Sended', 0, @idAzi, getdate(), @RagioneSocialeAzi, 0, @PartitaIvaAzi, @EmailAzi,
					  3, 0, 0, @ViaAzi, @CittaAzi,@ProvinciaAzi,@NazioneAzi,@CapAzi,@TelefonoAzi 
					  ,'',@FaxAzi,1,1,0,0 ,'','PE','','' 
					  ,null,'','','','','')


	END
	








GO
