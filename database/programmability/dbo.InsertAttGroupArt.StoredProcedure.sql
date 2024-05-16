USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertAttGroupArt]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertAttGroupArt] (
      @vcDztnome              VARCHAR(50),         
      @vcValore              NVARCHAR(3000),        
        @iIdums                     INT, 
      @vcFilterAziende       VARCHAR(4000),                                       
      @vcFilterArticoli       VARCHAR(4000),
        @bDelete                 BIT
) AS
DECLARE @iIdDzt INT
DECLARE @iIdTid INT
DECLARE @bdztMultiValue BIT
DECLARE @iTipoMem INT 
DECLARE @vcTipoDom VARCHAR(5)
DECLARE @bisDsccsx TINYINT
DECLARE @iumsIdDscNome INT
DECLARE @iumsIdDscSimbolo INT
DECLARE @iIdVat INT
DECLARE @iIdArt INT
DECLARE @vcVatValore_FT NVARCHAR(3000)
DECLARE @vcVatValore_FV NVARCHAR(3000)
DECLARE @idgIdDsc INT
DECLARE @itdrIdDsc INT
DECLARE @vcFilterStato VARCHAR(50)
DECLARE @vcSQLDeleted VARCHAR(8000)
DECLARE @vcTableDeleted VARCHAR(20)
DECLARE @vcSQLTableTmp VARCHAR(8000)
/* Raddoppia gli apici singoli all'interno di una stringa in modo da evitare problemi con sql dinamico */
SET @vcFilterAziende=REPLACE(@vcFilterAziende,'''','''''')
SET @vcFilterArticoli=REPLACE(@vcFilterArticoli,'''','''''')
/*
Controlla appartenenza!!!
*/
--Estrazione dati dal dizionario
SELECT @iIdDzt=IdDzt,@iIdTid=dztIdTid,@bdztMultiValue=dztMultiValue FROM DizionarioAttributi,AppartenenzaAttributi
WHERE IdDzt=apatIddzt AND apatIdApp=2 AND dztNome=@vcDztnome AND dztDeleted=0
IF @iIdDzt IS NULL
   BEGIN
        RAISERROR ('Errore Attributo [%s] inesistente o non di articolo (InsertAttGroupArt)', 16, 1,@vcDztnome)
        RETURN 99
   END
--Estrazione TipoMem e Tipodom
SELECT @iTipoMem=tidTipoMem,@vcTipoDom=tidTipoDom FROM TipiDati
WHERE IdTid=@iIdTid  AND tidDeleted=0
IF @iIdDzt IS NULL or @iTipoMem IS NULL 
   BEGIN
        RAISERROR ('Errore Inconsistenza TipoDato Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
        RETURN 99
   END
IF @iIdums = -1
   BEGIN
        SET @iIdums=NULL
   END
--Controllo ed estrazione Unita di Misura
IF @iIdums IS NOT NULL 
   BEGIN
        SELECT @iumsIdDscNome=umsIdDscNome,@iumsIdDscSimbolo=umsIdDscSimbolo FROM UnitaMisura
        WHERE IdUms=@iIdums AND umsDeleted=0
        IF @iIdDzt IS NULL
           BEGIN
                RAISERROR ('Errore Unita di misura [%d] (InsertAttGroupArt)', 16, 1,@iIdums)
                RETURN 99
           END
   END
--IsDscsx _ 0 solo per i domini aperti
SET @bisDsccsx=CASE @vcTipoDom 
                    WHEN 'A' THEN 0 
                    ELSE 1
                    END
/*    CREAZIONE TABELLA TEMPORANEA DELLE ARTICOLI FILTRATE!! */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tmpArticoliIAGA]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
        DROP TABLE [DBO].[tmpArticoliIAGA]
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
   END
CREATE TABLE [dbo].[tmpArticoliIAGA] ( [IdArt] [int] NOT NULL ) 
IF @@ERROR <> 0
   BEGIN
        RETURN 99
   END     
-- Filtro aziende
SET @vcSQLTableTmp=CASE @vcFilterAziende
                        WHEN '' THEN ' WHERE '+@vcFilterArticoli
                        ELSE ' WHERE artIdAzi IN (SELECT mpaIdAzi FROM MpAziende  WHERE '+@vcFilterAziende+' )    AND '+@vcFilterArticoli
                        END
--Filtro articoli
SET @vcSQLTableTmp=CASE @vcFilterArticoli
                        WHEN '' THEN SUBSTRING(@vcSQLTableTmp,1,LEN(@vcSQLTableTmp)-6)
                        ELSE @vcSQLTableTmp
                        END
/* POPOLAMENTO TABELLA TEMPORANEA*/
SET @vcSQLTableTmp='INSERT INTO tmpArticoliIAGA (IdArt) SELECT DISTINCT IdArt FROM Articoli '+@vcSQLTableTmp
EXEC(@vcSQLTableTmp)
IF @@ERROR <> 0
   BEGIN
        RETURN 99
   END     
-- EVENTUALE CANCELLAZIONE DELL'ATTRIBUTO  ALLE ARTICOLI FILTRATE SIA NELLE VALORIATT.. CHE NELLA DM 
IF @bDelete=1
   BEGIN
        SET @vcTableDeleted=CASE @iTipoMem
                                 WHEN 1 THEN '_int'        
                                 WHEN 2 THEN '_money'      
                                 WHEN 3 THEN '_float'      
                                 WHEN 4 THEN '_nvarchar'      
                                 WHEN 5 THEN '_DATETIME'      
                                 WHEN 6 THEN '_descrizioni'      
                                 WHEN 7 THEN '_Keys'
                                 ELSE 'ERRORE'
                                 END
        IF @vcTableDeleted = 'ERRORE'
           BEGIN
               RAISERROR ('Errore Inconsistenza Tipidati (InsertAttGroupArt)', 16, 1,@iIdums)
               RETURN 99
           END        
        SET @vcSQLDeleted='DELETE FROM ValoriAttributi'+@vcTableDeleted+' WHERE IdVat IN (SELECT a.IdVat FROM ValoriAttributi a,DfVatArt b WHERE a.IdVat=b.IdVat AND vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+' AND b.IdArt in (SELECT IdArt FROM tmpArticoliIAGA))'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
        SET @vcSQLDeleted='DELETE FROM DfVatArt WHERE IdVat IN (SELECT IdVat FROM ValoriAttributi WHERE vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+') AND IdArt in (SELECT IdArt FROM tmpArticoliIAGA)'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
        SET @vcSQLDeleted='DELETE FROM ValoriAttributi WHERE vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+' AND IdVat NOT IN (SELECT IdVat FROM DfVatArt) AND IdVat NOT IN (SELECT IdVat FROM DfVatArt)'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
        SET @vcSQLDeleted='DELETE FROM DM_Attributi WHERE IdApp=2 AND vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+' AND lnk in (SELECT IdArt FROM tmpArticoliIAGA)'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
   END
--CURSORE PER IL CARICAMENTO DELL'ATTRIBUTO!!!
DECLARE crsArticoli CURSOR static FOR SELECT IdArt FROM tmpArticoliIAGA
OPEN crsArticoli
FETCH NEXT FROM crsArticoli INTO @iIdArt
WHILE @@FETCH_STATUS = 0
   BEGIN
--CARICAMENTO DELLE TABELLE ValoriAttributi _XXX
        INSERT ValoriAttributi (vatTipoMem, vatIdUms, vatIdDzt) VALUES (@iTipoMem, @iIdUms, @iIdDzt)
        IF @@ERROR <> 0
           BEGIN
                CLOSE crsArticoli
                DEALLOCATE crsArticoli
                RETURN 99
           END     
        SET @iIdVat = @@IDENTITY
        INSERT DfVatArt(IdVat, IdArt) VALUES (@iIdVat, @iIdArt)
        IF @@ERROR <> 0
           BEGIN
                CLOSE crsArticoli
                DEALLOCATE crsArticoli
                RETURN 99
           END
     
        IF @iTipoMem=1
           BEGIN
                INSERT INTO valoriAttributi_int (IdVat,vatValore) VALUES(@iIdVat,CAST(@vcValore AS INT))
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                SET @vcVatValore_FV=@vcValore
           END
        IF @iTipoMem=2
           BEGIN
                INSERT INTO valoriAttributi_Money (IdVat,vatValore) VALUES(@iIdVat,CAST(@vcValore AS MONEY))
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SET @vcVatValore_FT=ltrim(str(@vcValore, 20, 3))
                SET @vcVatValore_FV=ltrim(str(@vcValore, 20, 3))
           END
        IF @iTipoMem=3
           BEGIN
                INSERT INTO valoriAttributi_float (IdVat,vatValore) VALUES(@iIdVat,@vcValore)
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SET @vcVatValore_FT=ltrim(str(@vcValore, 20, 3))
                SET @vcVatValore_FV=ltrim(str(@vcValore, 20, 3))
           END
        IF @iTipoMem=4
           BEGIN
                INSERT INTO valoriAttributi_nvarchar (IdVat,vatValore) VALUES(@iIdVat,@vcValore)
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                IF @vcTipoDom='A'
                   BEGIN
                        SET @vcVatValore_FV=@vcValore
                        IF @iIdTid=21
                           BEGIN
                                SET @vcVatValore_FV=NULL
                                SELECT @vcVatValore_FV=Descrizione FROM AZ_STRUTTURA
                                WHERE cast(IdAz AS VARCHAR(20))+'#'+Path=@vcValore AND Deleted=0
                                IF @vcVatValore_FV IS NULL
                                   BEGIN
                                        RAISERROR ('Errore Inconsistenza AZ_STRUTTURA Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
                                        CLOSE crsArticoli
                                        DEALLOCATE crsArticoli
                                        RETURN 99
                                   END
                           END
                   END
                IF @vcTipoDom='G'
                   BEGIN
                        SELECT @idgIdDsc=dgIdDsc FROM DominiGerarchici
                        WHERE dgCodiceInterno=@vcValore AND dgTipoGerarchia=@iIdTid AND dgDeleted=0
                        IF @idgIdDsc IS NULL
                           BEGIN
                                RAISERROR ('Errore Inconsistenza DominiGerarchici Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
                                CLOSE crsArticoli
                                DEALLOCATE crsArticoli
                                RETURN 99
                           END
                        SET @vcVatValore_FV=CAST(@idgIdDsc AS VARCHAR(15))
                   END
                IF @vcTipoDom NOT IN ('G','A')
                   BEGIN
                        RAISERROR ('Errore Inconsistenza dominio Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
           END
        IF @iTipoMem=5
           BEGIN
                INSERT INTO ValoriAttributi_Datetime (IdVat,vatValore) VALUES(@iIdVat,@vcValore) 
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                SET @vcVatValore_FV=@vcValore
           END
        IF @iTipoMem=6
           BEGIN
                IF @vcTipoDom <> 'C'
                   BEGIN
                        RAISERROR ('Errore Inconsistenza dominio Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SELECT @itdrIdDsc=tdrIdDsc FROM TipiDatiRange
                WHERE tdrIdTid=@iIdTid AND tdrCodice=@vcValore AND tdrDeleted=0
                IF @itdrIdDsc IS NULL
                   BEGIN
                        RAISERROR ('Errore Inconsistenza TipiDatiRange Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                INSERT INTO ValoriAttributi_Descrizioni (IdVat,vatIdDsc) VALUES(@iIdVat,CAST(@vcValore AS INT))
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                SET @vcVatValore_FV=CAST(@itdrIdDsc AS VARCHAR(20))
           END
        IF @iTipoMem=7
           BEGIN
                SELECT @idgIdDsc=dgIdDsc FROM DominiGerarchici
                WHERE dgCodiceInterno=@vcValore AND dgTipoGerarchia=@iIdTid AND dgDeleted=0
                IF @idgIdDsc IS NULL
                   BEGIN
                        RAISERROR ('Errore Inconsistenza DominiGerarchici Attributo [%s] (InsertAttGroupArt)', 16, 1,@vcDztnome)
                        CLOSE crsArticoli
                        DEALLOCATE crsArticoli
                        RETURN 99
                   END
                INSERT INTO ValoriAttributi_Keys(IdVat,vatValore) VALUES(@iIdVat,@vcValore)
                IF @@ERROR <> 0
                   BEGIN
                       CLOSE crsArticoli
                       DEALLOCATE crsArticoli
                       RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                SET @vcVatValore_FV=CAST(@idgIdDsc AS VARCHAR(15))
           END
--CARICAMENTO DM_ATTRIBUTI
       INSERT INTO DM_ATTRIBUTI (idApp,lnk,idVat, vatiddzt,vatidUMS,vatidUMSDscNome,vatidUMSDscSimbolo,dztNome,dztMultiValue,dztIdTid,vatValore_FT,vatValore_FV,isDsccsx,vatTipoMem)
                  VALUES(2,@iIdArt,@iIdVat,@iIdDzt ,@iIdums,@iumsIdDscNome,@iumsIdDscSimbolo,@vcDztnome,@bdztMultiValue,@iIdTid,@vcVatValore_FT,@vcVatValore_FV,@bisDsccsx,@iTipoMem)
       IF @@ERROR <> 0
          BEGIN
               CLOSE crsArticoli
               DEALLOCATE crsArticoli
               RETURN 99
          END
        FETCH NEXT FROM crsArticoli INTO @iIdArt           
   END
CLOSE crsArticoli
DEALLOCATE crsArticoli
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tmpArticoliIAGA]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
        DROP TABLE [DBO].[tmpArticoliIAGA]
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
   END


GO
