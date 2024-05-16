USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertAziendaSellerATI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[InsertAziendaSellerATI] (

@RagSoc NVARCHAR(100),
@aziPartitaIVA NVARCHAR(20),
@CodiceFiscale NVARCHAR(20),
@aziIndirizzoLeg  NVARCHAR(80),
@aziLocalitaLeg  NVARCHAR(80),
@aziProvinciaLeg  NVARCHAR(20), 
@aziStatoLeg  NVARCHAR(80), 
@aziCAPLeg  NVARCHAR(8),
@aziTelefono1  NVARCHAR(50),
@aziTelefono2  NVARCHAR(50),
@aziFAX  NVARCHAR(50),
@aziE_Mail  NVARCHAR(50),
@aziSitoWeb   NVARCHAR(300),
@Atv NVARCHAR(100),
@Gph INT,
@IdDscFormaSoc INT,
@idmsg INT,
@codiceruoloimpresa NVARCHAR(20),
@NewIdAzi int OUTPUT
)

AS
--DECLARE @NewIdAzi                        INT
DECLARE @strClean                        NVARCHAR(100)

DECLARE @Login                           VARCHAR(20)
DECLARE @Password                        NVARCHAR(40)
DECLARE @PasswordC                       NVARCHAR(40)
DECLARE @email                           VARCHAR(100)
DECLARE @descruoloimpresa                VARCHAR(100)
DECLARE @nLen                            INT
DECLARE @TIPO_OPER_ANAG					 VARCHAR(100)  	

set @idmsg = @idmsg * -1

if @codiceruoloimpresa = '1'
	set @descruoloimpresa='Mandataria'
else
	set @descruoloimpresa='Mandante'

if @IdDscFormaSoc is null
	--SET @IdDscFormaSoc = 23903
	--select @IdDscFormaSoc=tdriddsc from tipidatirange where tdridtid=131 and tdrdeleted=0 and tdrcodice='845326'
	SET @IdDscFormaSoc = '845326'
	
if @Atv=''
	SET @Atv = '###0###'


SET @strClean = UPPER(@RagSoc)
SET @strClean = REPLACE(@strClean, ' ', '')
SET @strClean = REPLACE(@strClean, '.', '')
SET @strClean = REPLACE(@strClean, '''', '')
SET @strClean = REPLACE(@strClean, ':', '')
SET @strClean = REPLACE(@strClean, ';', '')
SET @strClean = REPLACE(@strClean, '-', '')
SET @strClean = REPLACE(@strClean, '!', '')
SET @strClean = REPLACE(@strClean, '?', '')
SET @strClean = REPLACE(@strClean, '"', '')
SET @strClean = REPLACE(@strClean, ',', '')
SET @strClean = REPLACE(@strClean, '*', '')
SET @nLen     = LEN (@strClean)


IF  @nLen > 4
BEGIN
        IF  RIGHT (@strClean, 3) = 'SPA' OR RIGHT (@strClean, 3) = 'SNC' OR RIGHT (@strClean, 3) = 'SRL'
        BEGIN
                SET @strClean = LEFT(@strClean, @nLen - 3)                       
        END
END


--controllo se l'azienda già esiste
set @NewIdAzi = null

if @CodiceFiscale<>''
	select @NewIdAzi=idazi from aziende,dm_attributi where idazi=lnk and idapp=1 and dztnome='codicefiscale' and vatvalore_ft=@CodiceFiscale

if @NewIdAzi is null
begin
	
	--INSERIMENTO NELLA TABELLA AZIENDE
	INSERT INTO Aziende 
	(aziDataCreazione, aziRagioneSociale, aziRagioneSocialeNorm, aziIdDscFormaSoc, aziPartitaIVA, aziE_Mail, aziAcquirente, 
	 aziVenditore, aziProspect, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg,  
	 aziTelefono1, aziTelefono2, aziFAX, aziProssimoProtRdo, aziProssimoProtOff, aziGphValueOper, aziDeleted, 
	 aziDBNumber,  aziSitoWeb, aziProfili ) 
	values
	( getdate(), @RagSoc, @strClean, @IdDscFormaSoc, @aziPartitaIVA, @aziE_Mail, 
	 0, 2, 0, @aziIndirizzoLeg, @aziLocalitaLeg, @aziProvinciaLeg, @aziStatoLeg, @aziCAPLeg, 
	 @aziTelefono1, @aziTelefono2, @aziFAX,  1, 1, 0, 0, 
	 0,  @aziSitoWeb, 'S' )


	SET @NewIdAzi = SCOPE_IDENTITY()
	
	--INSERIMENTO NELLA TABELLA DOCUMENT_AZIENDE
	set @TIPO_OPER_ANAG = 'AZI_RTI'

	if @RagSoc <> cast(@idmsg as varchar(50)) 
		set @TIPO_OPER_ANAG = 'AZI_PERGIUR_LIGHT'  

	INSERT INTO Document_Aziende 
		(IdPfu, TipoOperAnag, Stato, Protocol, isOld, IdAzi, aziRagioneSociale, aziRagioneSocialeNorm, aziPartitaIVA,
		aziCAPLeg, aziStatoLeg, aziSitoWeb, aziFAX, aziTelefono1, aziIndirizzoLeg, aziE_Mail, aziIdDscFormaSoc, 
		aziLocalitaLeg, aziDataCreazione, CodiceFiscale, aziProvinciaLeg, aziTelefono2)
		SELECT 35774, @TIPO_OPER_ANAG , 'Sended', '', 0, IdAzi, aziRagioneSociale, aziRagioneSocialeNorm, aziPartitaIVA,
		aziCAPLeg, aziStatoLeg, aziSitoWeb, aziFAX, aziTelefono1, aziIndirizzoLeg, aziE_Mail, aziIdDscFormaSoc, 
		aziLocalitaLeg, aziDataCreazione, vatValore_FT, aziProvinciaLeg, aziTelefono2
		FROM Aziende 
		LEFT JOIN DM_Attributi ON IdAzi = lnk AND IdApp = 1 AND dztNome = 'CodiceFiscale'
		WHERE IdAzi = @NewIdAzi    

	--INSERIMENTO NELLA TABELLA MPAZIENDE
	INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaVenditore, mpaProfili, mpaDeleted)
     VALUES (1,  @NewIdAzi, 2, 'S', 0)
	
	--INSERIMENTO AREE GEOGRAFICHE
	INSERT INTO AziGph (gphIdAzi, gphValue) VALUES (@NewIdAzi, @Gph)
	

	INSERT INTO Scheduled_Event_Aziende (EVENT, IDAZI, NUM_ATTEMPT, DATE_LASTATTEMPT) 
		 VALUES ('ISCRIZIONEALBOFORNITORI', @NewIdAzi, 3, GETDATE())
	
	--INSERIMENTO ATTIVITA ECONOMICHE
	EXEC InsAteco @NewIdAzi, @Atv

	--inserisco attributo opzionale codicefiscale sull'azienda
	EXEC InsAttrAzi @NewIdAzi , 'codicefiscale' , @CodiceFiscale
	
	UPDATE Aziende 
	   SET aziAtvAtecord = (SELECT TOP 1 AtvAtecord FROM Aziateco WHERE IdAzi = @NewIdAzi) 
	 WHERE IdAzi = @NewIdAzi

	SET @Login    = LEFT(@strClean, 12)
	SET @Password = LEFT(@strClean, 12)

	EXEC usp_Encrypt @Password, @PasswordC OUTPUT
	
	--INSERIMENTO UTENTE
	INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziendale, pfuPassword, pfuPrefissoProt,
							   pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni)
		 VALUES (@NewIdAzi, LEFT(@RagSoc, 30), @Login, 'Amministratore', @PasswordC,
				 LEFT(@strClean, 3), 1, 1, @EMail, 'S', '0010000000000001111110000000000001111111000000100000000000000011111000000001111001110110011100101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
				 '11010010000000000000000000000000000000000000000000')

	UPDATE Aziende 
	   SET azifunzionalita = '0010000000000001111110000000000001111111000000100000000000000111111000000001111001110110011100101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'  
	 WHERE IdAzi = @NewIdAzi

	UPDATE Aziende 
	   SET aziFunzionalita = STUFF(aziFunzionalita, 229, 1, '1')
	 WHERE IdAzi = @NewIdAzi

	UPDATE Aziende 
	   SET aziFunzionalita = STUFF(aziFunzionalita, 239, 1, '1')  
	 WHERE IdAzi = @NewIdAzi

	UPDATE ProfiliUtente 
	   SET pfuFunzionalita = STUFF(pfuFunzionalita, 239, 1, '1')  
	 WHERE pfuIdAzi = @NewIdAzi

end

--CENSISCO le aziende partecipanti come ATI tranne l'ati stessa
if @RagSoc <> cast(@idmsg as varchar(50))
INSERT INTO [Document_Aziende_RTI]
           ([idDoc]
           ,[idAziPartecipante]
           ,[Ruolo_Impresa]
           ,[DataInizio]
           ,[DataFine]
           ,[PIVA_CF]
           ,[DataCreazione]
           ,[isOld]
           ,[idAziRTI])
VALUES
           ( @idmsg
           ,@NewIdAzi
           ,@descruoloimpresa
           ,getdate()
           ,getdate()
           ,@CodiceFiscale
           ,getdate()
           ,0
           ,@idmsg )
GO
