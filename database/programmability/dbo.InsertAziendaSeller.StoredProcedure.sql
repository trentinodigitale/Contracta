USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertAziendaSeller]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[InsertAziendaSeller] (

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
@IdDscFormaSoc INT
)

AS


DECLARE @NewIdAzi                        INT
DECLARE @strClean                        NVARCHAR(100)

DECLARE @Login                           VARCHAR(20)
DECLARE @Password                        NVARCHAR(40)
DECLARE @PasswordC                       NVARCHAR(40)
DECLARE @email                           VARCHAR(100)
DECLARE @nLen                            INT

if @IdDscFormaSoc is null
	SET @IdDscFormaSoc = 23903

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


SET @NewIdAzi = @@IDENTITY

--UPDATE Document_Aziende 
--   SET IdAzi = @NewIdAzi 
-- WHERE Id = @idDoc

INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaVenditore, mpaProfili, mpaDeleted)
     VALUES (1,  @NewIdAzi, 2, 'S', 0)

INSERT INTO AziGph (gphIdAzi, gphValue) VALUES (@NewIdAzi, @Gph)

INSERT INTO Scheduled_Event_Aziende (EVENT, IDAZI, NUM_ATTEMPT, DATE_LASTATTEMPT) 
     VALUES ('ISCRIZIONEALBOFORNITORI', @NewIdAzi, 3, GETDATE())

EXEC InsAteco @NewIdAzi, @Atv

--inserisco attributo opzionale codicefiscale sull'azienda
EXEC InsAttrAzi @NewIdAzi , 'codicefiscale' , @CodiceFiscale

UPDATE Aziende 
   SET aziAtvAtecord = (SELECT TOP 1 AtvAtecord FROM Aziateco WHERE IdAzi = @NewIdAzi) 
 WHERE IdAzi = @NewIdAzi

SET @Login    = LEFT(@strClean, 12)
SET @Password = LEFT(@strClean, 12)

EXEC usp_Encrypt @Password, @PasswordC OUTPUT

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
GO
