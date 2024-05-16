USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertAttGroupAzi]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertAttGroupAzi] (
      @vcDztnome              VARCHAR(50),         
      @vcValore              NVARCHAR(3000),        
        @iIdums                     INT,                                        
      @vcFilterAziende       VARCHAR(4000),
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
DECLARE @iIdAzi INT
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
/*
Controlla appartenenza!!!
*/
--Estrazione dati dal dizionario
SELECT @iIdDzt=IdDzt,@iIdTid=dztIdTid,@bdztMultiValue=dztMultiValue FROM DizionarioAttributi,AppartenenzaAttributi
WHERE IdDzt=apatIddzt AND apatIdApp=1 AND dztNome=@vcDztnome AND dztDeleted=0
IF @iIdDzt IS NULL
   BEGIN
        RAISERROR ('Errore Attributo [%s] inesistente o non di azienda (InsertAttGroupAzi)', 16, 1,@vcDztnome)
        RETURN 99
   END
--Estrazione TipoMem e Tipodom
SELECT @iTipoMem=tidTipoMem,@vcTipoDom=tidTipoDom FROM TipiDati
WHERE IdTid=@iIdTid  AND tidDeleted=0
IF @iIdDzt IS NULL or @iTipoMem IS NULL 
   BEGIN
        RAISERROR ('Errore Inconsistenza TipoDato Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
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
                RAISERROR ('Errore Unita di misura [%d] (InsertAttGroupAzi)', 16, 1,@iIdums)
                RETURN 99
           END
   END
--IsDscsx _ 0 solo per i domini aperti
SET @bisDsccsx=CASE @vcTipoDom 
                    WHEN 'A' THEN 0 
                    ELSE 1
                    END
/*    CREAZIONE TABELLA TEMPORANEA DELLE AZIENE FILTRATE!! */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tmpAziendeIAGA]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
        DROP TABLE [DBO].[tmpAziendeIAGA]
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
   END
CREATE TABLE [dbo].[tmpAziendeIAGA] ( [IdAzi] [int] NOT NULL ) 
IF @@ERROR <> 0
   BEGIN
        RETURN 99
   END     
SET @vcSQLTableTmp=CASE @vcFilterAziende
                        WHEN '' THEN 'INSERT INTO tmpAziendeIAGA (IdAzi) SELECT DISTINCT mpaIdAzi FROM MpAziende '
                        ELSE 'INSERT INTO tmpAziendeIAGA (IdAzi) SELECT DISTINCT mpaIdAzi FROM MpAziende WHERE '+@vcFilterAziende
                        END   
  
/* POPOLAMENTO TABELLA TEMPORANEA*/
EXEC (@vcSQLTableTmp)
IF @@ERROR <> 0
   BEGIN
        RETURN 99
   END     
-- EVENTUALE CANCELLAZIONE DELL'ATTRIBUTO  ALLE AZIENDE FILTRATE SIA NELLE VALORIATT.. CHE NELLA DM 
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
               RAISERROR ('Errore Inconsistenza Tipidati (InsertAttGroupAzi)', 16, 1,@iIdums)
               RETURN 99
           END        
        SET @vcSQLDeleted='DELETE FROM ValoriAttributi'+@vcTableDeleted+' WHERE IdVat IN (SELECT a.IdVat FROM ValoriAttributi a,DfVatAzi b WHERE a.IdVat=b.IdVat AND vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+' AND b.Idazi in (SELECT IdAzi FROM tmpAziendeIAGA))'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
        SET @vcSQLDeleted='DELETE FROM DfVatAzi WHERE IdVat IN (SELECT IdVat FROM ValoriAttributi WHERE vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+') AND IdAzi in (SELECT IdAzi FROM tmpAziendeIAGA)'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
        SET @vcSQLDeleted='DELETE FROM ValoriAttributi WHERE vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+' AND IdVat NOT IN (SELECT IdVat FROM DfVatAzi) AND IdVat NOT IN (SELECT IdVat FROM DfVatArt)'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
        SET @vcSQLDeleted='DELETE FROM DM_Attributi WHERE IdApp=1 AND vatIdDzt='+CAST(@iIdDzt AS VARCHAR(20))+' AND lnk in (SELECT IdAzi FROM tmpAziendeIAGA)'
        EXEC(@vcSQLDeleted)
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
   END
--CURSORE PER IL CARICAMENTO DELL'ATTRIBUTO!!!
DECLARE crsAziende CURSOR static FOR SELECT IdAzi FROM tmpAziendeIAGA
OPEN crsAziende
FETCH NEXT FROM crsAziende INTO @iIdAzi
WHILE @@FETCH_STATUS = 0
   BEGIN
--CARICAMENTO DELLE TABELLE ValoriAttributi _XXX
        INSERT ValoriAttributi (vatTipoMem, vatIdUms, vatIdDzt) VALUES (@iTipoMem, @iIdUms, @iIdDzt)
        IF @@ERROR <> 0
           BEGIN
                CLOSE crsAziende
                DEALLOCATE crsAziende
                RETURN 99
           END     
        SET @iIdVat = @@IDENTITY
        INSERT DfVatAzi(IdVat, IdAzi) VALUES (@iIdVat, @iIdAzi)
        IF @@ERROR <> 0
           BEGIN
                CLOSE crsAziende
                DEALLOCATE crsAziende
                RETURN 99
           END
     
        IF @iTipoMem=1
           BEGIN
                INSERT INTO valoriAttributi_int (IdVat,vatValore) VALUES(@iIdVat,CAST(@vcValore AS INT))
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
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
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
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
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
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
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
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
                                        RAISERROR ('Errore Inconsistenza AZ_STRUTTURA Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
                                        CLOSE crsAziende
                                        DEALLOCATE crsAziende
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
                                RAISERROR ('Errore Inconsistenza DominiGerarchici Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
                                CLOSE crsAziende
                                DEALLOCATE crsAziende
                                RETURN 99
                           END
                        SET @vcVatValore_FV=CAST(@idgIdDsc AS VARCHAR(15))
                   END
                IF @vcTipoDom NOT IN ('G','A')
                   BEGIN
                        RAISERROR ('Errore Inconsistenza dominio Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
                        RETURN 99
                   END
           END
        IF @iTipoMem=5
           BEGIN
                INSERT INTO ValoriAttributi_Datetime (IdVat,vatValore) VALUES(@iIdVat,@vcValore) --CAST(@vcValore AS DATETIME))
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
                        RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                SET @vcVatValore_FV=@vcValore
           END
        IF @iTipoMem=6
           BEGIN
                IF @vcTipoDom <> 'C'
                   BEGIN
                        RAISERROR ('Errore Inconsistenza dominio Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
                        RETURN 99
                   END
                SELECT @itdrIdDsc=tdrIdDsc FROM TipiDatiRange
                WHERE tdrIdTid=@iIdTid AND tdrCodice=@vcValore AND tdrDeleted=0
                IF @itdrIdDsc IS NULL
                   BEGIN
                        RAISERROR ('Errore Inconsistenza TipiDatiRange Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
                        RETURN 99
                   END
                INSERT INTO ValoriAttributi_Descrizioni (IdVat,vatIdDsc) VALUES(@iIdVat,@vcValore)
                IF @@ERROR <> 0
                   BEGIN
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
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
                        RAISERROR ('Errore Inconsistenza DominiGerarchici Attributo [%s] (InsertAttGroupAzi)', 16, 1,@vcDztnome)
                        CLOSE crsAziende
                        DEALLOCATE crsAziende
                        RETURN 99
                   END
                INSERT INTO ValoriAttributi_Keys(IdVat,vatValore) VALUES(@iIdVat,CAST(@vcValore AS INT))
                IF @@ERROR <> 0
                   BEGIN
                       CLOSE crsAziende
                       DEALLOCATE crsAziende
                       RETURN 99
                   END
                SET @vcVatValore_FT=@vcValore
                SET @vcVatValore_FV=CAST(@idgIdDsc AS VARCHAR(15))
           END
--CARICAMENTO DM_ATTRIBUTI
       INSERT INTO DM_ATTRIBUTI (idApp,lnk,idVat, vatiddzt,vatidUMS,vatidUMSDscNome,vatidUMSDscSimbolo,dztNome,dztMultiValue,dztIdTid,vatValore_FT,vatValore_FV,isDsccsx,vatTipoMem)
                  VALUES(1,@iIdAzi,@iIdVat,@iIdDzt ,@iIdums,@iumsIdDscNome,@iumsIdDscSimbolo,@vcDztnome,@bdztMultiValue,@iIdTid,@vcVatValore_FT,@vcVatValore_FV,@bisDsccsx,@iTipoMem)
       IF @@ERROR <> 0
          BEGIN
               CLOSE crsAziende
               DEALLOCATE crsAziende
               RETURN 99
          END
        FETCH NEXT FROM crsAziende INTO @iIdAzi           
   END
CLOSE crsAziende
DEALLOCATE crsAziende
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[tmpAziendeIAGA]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   BEGIN
        DROP TABLE [DBO].[tmpAziendeIAGA]
        IF @@ERROR <> 0
           BEGIN
                RETURN 99
           END     
   END


GO
