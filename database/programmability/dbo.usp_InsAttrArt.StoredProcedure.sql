USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_InsAttrArt]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_InsAttrArt] (@IdArt INT, @dztNome VARCHAR(50), @Valore VARCHAR(8000), @Sep VARCHAR(10) = '#')
AS

SET NOCOUNT ON

DECLARE @TipoMem          INT
DECLARE @dztMultiValue    INT
DECLARE @IdVat            INT
DECLARE @IdDzt            INT
DECLARE @IdUms            INT
DECLARE @IdDscS           INT
DECLARE @IdDscN           INT
DECLARE @IdTid            INT
DECLARE @IdDsc            INT
DECLARE @SepLen           INT
DECLARE @Pos              INT
DECLARE @TipoDom          CHAR(1)
DECLARE @ValTemp          VARCHAR(8000)
DECLARE @ValTemp1         VARCHAR(8000)

IF NOT EXISTS (SELECT * FROM Articoli WHERE IdArt = @IdArt)
BEGIN
        RAISERROR ('Articolo [%s] non trovata', 16, 1)
        RETURN 99
END

IF @Sep IS NULL OR @Sep = ''
BEGIN
        RAISERROR ('Separatore [%s] non valido', 16, 1)
        RETURN 99
END

SET @SepLen = LEN(@Sep)

SELECT @TipoMem = tidTipoMem
     , @IdDzt = IdDzt
     , @IdUms = dztIdUmsDefault
     , @IdTid = dztIdTid
     , @TipoDom = tidTipoDom
     , @dztMultiValue = dztMultiValue
  FROM TipiDati, DizionarioAttributi
 WHERE dztIdTid = IdTid
   AND dztNome = @dztNome

IF @IdDzt IS NULL
BEGIN
        RAISERROR('Attributo %s non trovato', 16, 1, @dztNome)
        RETURN 99
END

/* Cancellazione */

BEGIN TRAN

IF @TipoMem = 1
BEGIN
        DELETE FROM ValoriAttributi_Int 
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_Int', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END
ELSE
IF @TipoMem = 2
BEGIN
        DELETE FROM ValoriAttributi_Money 
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_Money', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END
IF @TipoMem = 3
BEGIN
        DELETE FROM ValoriAttributi_Float
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_Float', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END
IF @TipoMem = 4
BEGIN
        DELETE FROM ValoriAttributi_NVarchar 
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_NVarchar', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END
IF @TipoMem = 5
BEGIN
        DELETE FROM ValoriAttributi_Datetime
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_Datetime', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END
IF @TipoMem = 6
BEGIN
        DELETE FROM ValoriAttributi_Descrizioni 
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_Descrizioni', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END
IF @TipoMem = 7
BEGIN
        DELETE FROM ValoriAttributi_keys 
              WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "DELETE" ValoriAttributi_keys', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END      
END

DELETE FROM DFVatArt 
      WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

IF @@ERROR <> 0
BEGIN
        RAISERROR ('Errore "DELETE" DFVatArt', 16, 1)
        ROLLBACK TRAN
        RETURN 99
END      

DELETE FROM ValoriAttributi WHERE IdVat IN (SELECT IdVat FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 1)

IF @@ERROR <> 0
BEGIN
        RAISERROR ('Errore "DELETE" ValoriAttributi', 16, 1)
        ROLLBACK TRAN
        RETURN 99
END      

DELETE FROM DM_Attributi WHERE Lnk = @IdArt AND dztNome = @dztNome AND IdApp = 2 

IF @@ERROR <> 0
BEGIN
        RAISERROR ('Errore "DELETE" DFVatArt', 16, 1)
        ROLLBACK TRAN
        RETURN 99
END      


/* Fine Cancellazione */


IF @IdUms IS NOT NULL
BEGIN 
        SET @IdDscS = NULL
        SET @IdDscN = NULL
        
       SELECT @IdDscS = umsIdDscsimbolo
            , @IdDscN = umsIdDscnome
         FROM UnitaMisura
        WHERE IdUms = @IdUms
END

SET @ValTemp = @Valore

WHILE @ValTemp <> '' AND @ValTemp <> @Sep
BEGIN
        SET @Pos = 0
        SET @Pos = CHARINDEX(@Sep, @ValTemp)

        IF @Pos <> 0
        BEGIN
                SET @ValTemp1 = RTRIM(LTRIM(SUBSTRING (@ValTemp, 1, @Pos - 1)))
                SET @ValTemp  = RTRIM(LTRIM(SUBSTRING (@ValTemp, @Pos + @SepLen, 8000)))
        END
        ELSE 
        BEGIN
                SET @ValTemp1 = RTRIM(LTRIM(@ValTemp))
                SET @ValTemp = ''
        END

        INSERT INTO ValoriAttributi (vatIdDzt, vatTipoMem) 
             VALUES (@IdDzt, @TipoMem)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "INSERT" ValoriAttributi', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END

        SET @IdVat = @@IDENTITY

        INSERT INTO DFVatArt (IdArt, IdVat) 
             VALUES (@IdArt, @IdVat)

        IF @@ERROR <> 0
        BEGIN
                RAISERROR ('Errore "INSERT" ValoriAttributi', 16, 1)
                ROLLBACK TRAN
                RETURN 99
        END

        IF @TipoMem = 1
        BEGIN
                INSERT INTO ValoriAttributi_Int (IdVat, vatValore) 
                     VALUES (@IdVat, @ValTemp1)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" ValoriAttributi_Int', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      

                INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                          dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                     VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                             @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @ValTemp1, 0, 1)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      
        END
        ELSE
        IF @TipoMem = 2
        BEGIN
                INSERT INTO ValoriAttributi_Money (IdVat, vatValore) 
                     VALUES (@IdVat, CAST(@ValTemp1 AS MONEY))

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" ValoriAttributi_Money', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      

                INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                          dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                     VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                             @dztNome, @dztMultiValue, @IdTid, LTRIM(STR(@ValTemp1, 20, 3)), LTRIM(STR(@ValTemp1, 20, 3)), 0, 2)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      
        END
        IF @TipoMem = 3
        BEGIN
                INSERT INTO ValoriAttributi_Float (IdVat, vatValore) 
                     VALUES (@IdVat, @ValTemp1)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      

                INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                          dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                     VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                             @dztNome, @dztMultiValue, @IdTid, LTRIM(STR(@ValTemp1, 20, 3)), LTRIM(STR(@ValTemp1, 20, 3)), 0, 3)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      
        END
        IF @TipoMem = 4
        BEGIN
                IF @TipoDom = 'A'
                BEGIN
                        INSERT INTO ValoriAttributi_NVarchar (IdVat, vatValore) 
                             VALUES (@IdVat, @ValTemp1)
        
                        IF @@ERROR <> 0
                        BEGIN
                                RAISERROR ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
                                ROLLBACK TRAN
                                RETURN 99
                        END      
        
                        INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                                  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                             VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                                     @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @ValTemp1, 0, 4)
        
                        IF @@ERROR <> 0
                        BEGIN
                                RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                                ROLLBACK TRAN
                                RETURN 99
                        END      
                END
                ELSE
                IF @TipoDom = 'G'
                BEGIN
                        SELECT @IdDsc = dgIdDsc
                          FROM DominiGerarchici 
                         WHERE dgTipoGerarchia = @IdTid
                           AND dgCodiceInterno = @ValTemp1
                           AND dgDeleted = 0

                        IF @IdDsc IS NULL
                        BEGIN
                                RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
                                ROLLBACK TRAN
                                RETURN 99
                        END
        
                        INSERT INTO ValoriAttributi_NVarchar (IdVat, vatValore) 
                             VALUES (@IdVat, @ValTemp1)
        
                        IF @@ERROR <> 0
                        BEGIN
                                RAISERROR ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
                                ROLLBACK TRAN
                                RETURN 99
                        END      
        
                        INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                                  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                             VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                                     @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 4)
        
        
                        IF @@ERROR <> 0
                        BEGIN
                                RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                                ROLLBACK TRAN
                                RETURN 99
                        END      
                END
                ELSE
                IF @TipoDom = 'C'
                BEGIN
                        SELECT @IdDsc = tdrIdDsc
                          FROM TipiDatiRange
                         WHERE tdrIdTid = @IdTid
                           AND tdrCodice = @ValTemp1
                           AND tdrDeleted = 0

                        IF @IdDsc IS NULL
                        BEGIN
                                RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
                                ROLLBACK TRAN
                                RETURN 99
                        END
                
                        INSERT INTO ValoriAttributi_NVarchar (IdVat, vatValore) VALUES (@IdVat, @ValTemp1)
        
                        IF @@ERROR <> 0
                        BEGIN
                                RAISERROR ('Errore "INSERT" ValoriAttributi_NVarchar', 16, 1)
                                ROLLBACK TRAN
                                RETURN 99
                        END      
        
                        INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                                  dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                             VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                                     @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 4)
        
        
                        IF @@ERROR <> 0
                        BEGIN
                                RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                                ROLLBACK TRAN
                                RETURN 99
                        END      
                END
        END
        IF @TipoMem = 5
        BEGIN
                INSERT INTO ValoriAttributi_Datetime (IdVat, vatValore) 
                     VALUES (@IdVat, @ValTemp1)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" ValoriAttributi_Datetime', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      

                INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                          dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                     VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                             @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @ValTemp1, 0, 5)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      
        END
        IF @TipoMem = 6
        BEGIN
                SELECT @IdDsc = tdrIdDsc
                  FROM TipiDatiRange
                 WHERE tdrIdTid = @IdTid
                   AND tdrCodice = @ValTemp1
                   AND tdrDeleted = 0

                IF @IdDsc IS NULL
                BEGIN
                        RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
                        ROLLBACK TRAN
                        RETURN 99
                END
                
                INSERT INTO ValoriAttributi_Descrizioni (IdVat, vatIdDsc) 
                     VALUES (@IdVat, @ValTemp1)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" ValoriAttributi_Descrizioni', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      

                INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                          dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                     VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                                   @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 6)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      
        END
        IF @TipoMem = 7
        BEGIN
                SELECT @IdDsc = dgIdDsc
                  FROM DominiFerarchici 
                 WHERE dgTipoGerarchia = @IdTid
                   AND dgCodiceInterno = @ValTemp1
                   AND dgDeleted = 0

                IF @IdDsc IS NULL
                BEGIN
                        RAISERROR ('Codice %s non trovato per l''attributo %s', 16, 1, @ValTemp1, @dztNome)
                        ROLLBACK TRAN
                        RETURN 99
                END
                
                INSERT INTO ValoriAttributi_Keys (IdVat, vatValore) 
                     VALUES (@IdVat, @ValTemp1)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" ValoriAttributi_Descrizioni', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      

                INSERT INTO DM_Attributi (IdApp, Lnk, IdVat, vatIdDzt, vatIdUms, vatIdUmsdscnome, vatIdUmsdscsimbolo,
                                          dztNome, dztMultiValue, dztIdTid, vatValore_ft, vatValore_fv, isdsccsx, vatTipoMem)
                     VALUES (2, @IdArt, @IdVat, @IdDzt, @IdUms, ISNULL(@IdDscN, '0'), ISNULL(@IdDscS, '0'),
                             @dztNome, @dztMultiValue, @IdTid, @ValTemp1, @IdDsc, 1, 7)

                IF @@ERROR <> 0
                BEGIN
                        RAISERROR ('Errore "INSERT" DM_Attributi', 16, 1)
                        ROLLBACK TRAN
                        RETURN 99
                END      
        END
       
END 

COMMIT TRAN
SET NOCOUNT OFF



GO
