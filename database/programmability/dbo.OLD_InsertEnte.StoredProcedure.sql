USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_InsertEnte]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROC [dbo].[OLD_InsertEnte] (@IdDoc INT)
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
declare @AlgoritmoPwd as varchar(2)
set @AlgoritmoPwd = '0'
select 	@AlgoritmoPwd=isnull(DZT_ValueDef,'0') from lib_dictionary where dzt_name='SYS_PWD_ALGORITMO'

SET @Gph = 0
SET @Atv = '###0###'

SELECT @Atv = aziAtvAtecord
     , @RagSoc = aziRagioneSociale 
     , @email = aziE_Mail 
  FROM Document_Aziende 
 WHERE Id = @IdDoc 

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

INSERT INTO Aziende (aziDataCreazione, aziRagioneSociale, aziRagioneSocialeNorm, aziIdDscFormaSoc, aziPartitaIVA, aziE_Mail, aziAcquirente, 
                     aziVENDitore, aziProspect, aziIndirizzoLeg, aziIndirizzoOp, aziLocalitaLeg, aziLocalitaOp, aziProvinciaLeg, aziProvinciaOp, aziStatoLeg, aziStatoOp, 
                     aziCAPLeg, aziCapOp, aziPrefisso, aziTelefono1, aziTelefono2, aziFAX,  aziIdDscDescrizione, aziProssimoProtRdo, aziProssimoProtOff, 
                     aziGphValueOper, aziDeleted, aziDBNumber,  aziSitoWeb, aziCodEurocredit, aziProfili, aziProvinciaLeg2, aziStatoLeg2,TipoDiAmministr)
SELECT aziDataCreazione, aziRagioneSociale, @strClean as aziRagioneSocialeNorm, aziIdDscFormaSoc, aziPartitaIVA, aziE_Mail, aziAcquirente, 
       aziVENDitore, aziProspect, aziIndirizzoLeg, aziIndirizzoOp, aziLocalitaLeg, aziLocalitaOp, aziProvinciaLeg, aziProvinciaOp, aziStatoLeg, aziStatoOp, 
       aziCAPLeg, aziCapOp, aziPrefisso, aziTelefono1, aziTelefono2, aziFAX,  aziIdDscDescrizione, aziProssimoProtRdo, aziProssimoProtOff, 
       aziGphValueOper, aziDeleted, aziDBNumber,  aziSitoWeb, aziCodEurocredit, aziProfili, aziProvinciaLeg2, aziStatoLeg2,TipoDiAmministr
  FROM Document_Aziende
 WHERE Id = @IdDoc

SET @NewIdAzi = SCOPE_IDENTITY()

UPDATE Document_Aziende 
   SET IdAzi = @NewIdAzi 
 WHERE Id = @IdDoc

INSERT INTO MPAziende (mpaIdMp, mpaIdAzi, mpaacquirente, mpaProfili, mpaDeleted)
     VALUES (1, @NewIdAzi, 3, 'P', 0)

INSERT INTO AziGph (gphIdAzi, gphValue) VALUES (@NewIdAzi, @Gph)

EXEC InsAteco @NewIdAzi, @Atv

UPDATE Aziende 
   SET aziAtvAtecord = (SELECT TOP 1 AtvAtecord FROM  Aziateco WHERE  IdAzi = @NewIdAzi) 
 WHERE IdAzi = @NewIdAzi

SET @Login    = LEFT(@strClean, 12)
--SET @Password = LEFT(@strClean, 12)
set @Password=''
exec usp_GenRandomPWD @Password output

--EXEC usp_Encrypt @Password, @PasswordC OUTPUT
set @PasswordC=''
exec EncryptPwdUser -1, @Password , @PasswordC output

SET @CognomeUtente = NULL
SET @EMailUtente = NULL
SET @RuoloUtente = NULL

SELECT @CognomeUtente = CognomeUtente
     , @EMailUtente = EMailUtente
     , @RuoloUtente = RuoloUtente 
  FROM Document_Aziende_Utenti 
 WHERE IdHeader = @IdDoc

IF @CognomeUtente IS NOT NULL 
	SET @NomeTemp = @CognomeUtente 
ELSE
	SET @NomeTemp = LEFT(@RagSoc, 30)

-- A meno che non è richiesto nella sys, non censiamo un nuovo utente alla creazione dell'ente
IF EXISTS ( select * from LIB_Dictionary a with (nolock) where a.DZT_Name = 'SYS_ENTE_NUOVO_REGISTRA_RAPLEG' and isnull(a.DZT_ValueDef,'no') <> 'no' )
BEGIN

	IF @CognomeUtente IS NOT NULL 
	BEGIN
			INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziENDale, pfuPassword, pfuPrefissoProt, 
									   pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni, pfutel, pfucell,pfuAlgoritmoPassword)
			SELECT @NewIdAzi, LEFT(CognomeUtente, 30), LEFT(REPLACE(CognomeUtente, ' ', ''), 12), ISNULL(RuoloUtente, 'Responsabile'), dbo.EncryptPwd(LEFT(REPLACE(CognomeUtente, ' ', ''), 12)), 
			LEFT(@strClean, 3), 0, 1, EMailUtente, LEFT(funzionalitautente, 1), left( right(funzionalitautente, 1000) + REPLICATE ('0',600),1000 ), '11010100000000000000000000000000000000000000000000', TelefonoUtente, CellulareUtente,@AlgoritmoPwd
			  FROM Document_Aziende_Utenti 
			 WHERE IdHeader = @IdDoc 
	END
	ELSE
	BEGIN 
			INSERT INTO ProfiliUtente (pfuIdAzi, pfuNome, pfuLogin, pfuRuoloAziENDale, pfuPassword, pfuPrefissoProt, 
									   pfuVenditore, pfuIdLng, pfuE_Mail, pfuProfili, pfuFunzionalita, pfuopzioni,pfuAlgoritmoPassword)
					VALUES (@NewIdAzi, @NomeTemp, @Login, ISNULL(@RuoloUtente, 'Responsabile'), @PasswordC, 
							LEFT(@strClean, 3), 0, 1, ISNULL(@EMailUtente, @EMail), 'B', '1101111001011111000001111111111010000000110011111110111111111000000011011110000111001001100011011000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000100100011001001101111000111111111110000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', 
							'11010100000000000000000000000000000000000000000000',@AlgoritmoPwd)
	END

END

UPDATE Aziende 
   SET aziFunzionalita = '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'  
 WHERE IdAzi = @NewIdAzi

DECLARE crs CURSOR static FOR SELECT IdArt
                            , IdMdl
                            , artCspValue
                            , artCode
                            , artIdDscDescrizione
                            , artIdUms
                         FROM Articoli
                            , Modelli_Prodotti
                        WHERE mdlIdArt = IdArt
                          AND artIdAzi = 35152001
                          AND artDeleted = 0
                          
OPEN crs

FETCH NEXT FROM crs INTO @IdArt, @IdMdl, @artCspValue, @artCode, @artIdDscDescrizione, @artIdUms

WHILE @@FETCH_STATUS = 0
BEGIN
        INSERT INTO Articoli (artIdAzi, artCspValue, artCode, artIdDscDescrizione, artIdUms, artQMO)
                VALUES (@NewIdAzi, @artCspValue, @artCode, @artIdDscDescrizione, @artIdUms, @artQMO)
                
        SET @IdArtNew = SCOPE_IDENTITY()
        
        INSERT INTO Modelli_Prodotti (IdMdl, mdlIdArt)
                VALUES (@IdMdl, @IdArtNew)

        FETCH NEXT FROM crs INTO @IdArt, @IdMdl, @artCspValue, @artCode, @artIdDscDescrizione, @artIdUms
END
CLOSE crs
DEALLOCATE crs

--Inserisco il codicefiscale dell'ente nella DM_ATTRIBUTI
declare @valore as varchar(400)
select @Valore = codicefiscale from document_aziende where id = @IdDoc 
		execute UpdAttrAzi @NewIdAzi , 'codicefiscale', @Valore 






GO
