USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpdateArticleKey]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Marranzini Angelica
Scopo:       Chiave Articoli: aggiunge un attributo opzionale come colonna della tabella articoli e lo
      inserisce nell'indice IX_Articoli_APPKEY
      se l'attributo non _ obbligatorio la nuova colonna prende come nome il valore di @vcdztNome passato in input
      altrimenti prende il valore dztcampoSpeciale relativo all'attributo di nome @vcdztNome
      NOTA L'unico attributo che non deve essere censito  nell'appartenenzaattributi _ IdArt (viene cablato da codice) 
      ATTENZIONE: per il corretto funzionamento della Stored Procedure UpdateArticleKey 
                occorre che il tipo di appartenenza 16 sia giO censito nella tabella Appartenenza
Data:        28/06/2002
*/
CREATE PROCEDURE [dbo].[UpdateArticleKey] (
            @iIdRd INT,
            @vcdztNome VARCHAR(50)
)    AS   
DECLARE @iIdDzt             AS INT         /*id dell'attributo*/
DECLARE @vcDztTabellaSpeciale        AS VARCHAR(40)      /*colonna Tabella speciale nel dizionarioattributi*/
DECLARE @vcDztCampoSpeciale        AS VARCHAR(40)  /*colonna Campo speciale nel dizionarioattributi*/
DECLARE @idztIdTid             AS INT             /*id del tipo dati*/
DECLARE @itidTipoMem             AS INT             /*tipo di memorizzazione*/
DECLARE @vcApatTabellaSpeciale       AS VARCHAR(40)       /*colonna Tabella speciale nell'appartenenzaattributi*/
DECLARE @vcApatCampoSpeciale        AS VARCHAR(40)       /*colonna Campo speciale nell'appartenenzaattributi*/
DECLARE @iIdApAt             AS INT             /*Id dell'appartenenzaattributi*/
DECLARE @vcStringaSQL             AS NVARCHAR(4000) /*stringa sql*/
DECLARE @vcNomeTabVatValori             AS VARCHAR(50)       /*Tabella ValoriAttributi_X da cui prendere i valori dell'attributo*/
DECLARE @vcTipoDati             AS VARCHAR(30)  /*Utilizzata per il tipo di dati della nuova colonna */
DECLARE @iIdArt             AS INT        /*id articolo*/
DECLARE @iIdVat             AS INT             /*id valore attributo*/
DECLARE @vatValoreInt             AS INT
DECLARE @vatValoreMoney       AS MONEY
DECLARE @vatValoreFloat       AS FLOAT
DECLARE @vatValoreNVarchar       AS NVARCHAR(1500)
DECLARE @vatValoreDatetine       AS DATETIME
DECLARE @vcNomeCampovatvalore       AS VARCHAR(30)
DECLARE @vcIndice             AS VARCHAR(4000)
DECLARE @vcNomeCampoIndice      AS VARCHAR(30)
DECLARE @sidztLunghezza       AS SMALLINT 
DECLARE @iCols                   AS INT
DECLARE @iSizeIndex              AS INT 
SET @vcStringaSQL=''
SET @vcTipoDati=''
SET @vcNomeTabVatValori=''
SET @vcNomeCampoIndice=''
SET @vcIndice=''
--controllo esistenza @iIdRd in Regdefault
IF NOT EXISTS (SELECT IdRd FROM RegDefault WHERE IdRd=@iIdRd AND rdDeleted=0
            AND (rdKey = 'AttribKeyForInsertCatalog' OR rdKey = 'AttribKeyForInsertCatalogMP')) 
   BEGIN
       RAISERROR('Errore: Chiave RegDefault non trovata',16,1)
      RETURN 99
   END
--IdArt non _ un nome di attributo valido
--poich_ _ cablato (vedi Nota sopra)
IF @vcdztNome='IdArt' 
  BEGIN 
       RAISERROR('Errore: IdArt non _ un nome di attributo valido',16,1)
      RETURN 99
  END
-- recupero valori dell'id dell'attributo, tabella speciale e campo speciale
SELECT @iIdDzt=IdDzt, @vcdztTabellaSpeciale=dztTabellaSpeciale, 
       @vcdztCampoSpeciale=dztCampoSpeciale, @idztIdTid=dztIdTid, 
       @sidztLunghezza=dztLunghezza
  FROM DizionarioAttributi 
 WHERE dztNome=@vcdztNome
   AND dztDeleted=0
--controllo esistenza attributo
IF @iIdDzt IS NULL 
   BEGIN
       RAISERROR('Errore: Attributo non trovato nel DizionarioAttributi',16,1)
      RETURN 99
   END
SELECT @itidTipoMem=tidTipoMem
  FROM TIpiDati
 WHERE IdTid=@idztIdTid
   AND tidDeleted=0
IF @itidTipoMem IS NULL 
   BEGIN
       RAISERROR('Errore: Tipo di memorizzazione non trovato',16,1)
      RETURN 99
   END
SELECT @iIdApAt=IdApAt, @vcApatTabellaSpeciale=ApatTabellaSpeciale, @vcApatCampoSpeciale=apatTabellaSpeciale
  FROM AppartenenzaAttributi 
 WHERE apatIdDzt=@iIdDzt 
   AND apatIdApp=16
   AND apatDeleted=0
IF @iIdApAt IS NULL 
   BEGIN      /*l'attributo non _ censito in appartenenza attributi
            quindi occorre inserirlo e creare la colonna in Articoli*/
            /*Controllo numero di colonne: numero max ammesse nell'indice _ 16*/
            SELECT @iCols=COUNT(DISTINCT apatCampoSpeciale)
              FROM appartenenzaattributi 
             WHERE apatDeleted=0
               AND apatIdApp=16 
            
            IF @iCols>=15 
               BEGIN
                   RAISERROR('Errore: superato il numero massimo di colonne ammesse nell''indice',16,1)
                  RETURN 99
               END
            /*controllo somma della size dell'indice*/
            SELECT @iSizeIndex=SUM(c.length) 
              FROM syscolumns c, sysobjects t 
             WHERE t.name='Articoli' AND c.id=t.id 
               AND (c.name in (SELECT DISTINCT apatCampoSpeciale 
                             FROM appartenenzaattributi 
                            WHERE apatdeleted=0 AND apatidapp=16)
                    or c.name='IdArt')
            IF @iSizeIndex IS NULL
               BEGIN
                  SET @iSizeIndex=0
               END
            IF @sidztLunghezza IS NULL OR @sidztLunghezza=0 
               BEGIN 
                  SET @sidztLunghezza=255
               END
      
      /*controllo non obbligatorietO dell'attributo
        se non _ obbligatorio tabellaspeciale e campospeciale 
           nel dizionarioattributi sono NULL*/
      IF @vcDztTabellaSpeciale IS NULL AND @vcDztCampoSpeciale IS NULL 
         BEGIN       /*attributo non obbligatorio*/
            --creo lo stringa sql
            SET @vcNomeCampovatvalore='vatValore'
            IF @itidTipoMem=1
               BEGIN
                  SET @vcTipoDati=' INT '
                  SET @vcNomeTabVatValori=' VALORIATTRIBUTI_INT '
                  SET @sidztLunghezza=4
               END
            ELSE IF @itidTipoMem=2
                    BEGIN
                        SET @vcTipoDati=' MONEY '
                        SET @vcNomeTabVatValori=' VALORIATTRIBUTI_MONEY '
                        SET @sidztLunghezza=8
                     END
            ELSE IF @itidTipoMem=3
                     BEGIN
                        SET @vcTipoDati= ' FLOAT '
                        SET @vcNomeTabVatValori=' VALORIATTRIBUTI_FLOAT '
                        SET @sidztLunghezza=8
                     END
            ELSE IF @itidTipoMem=4
                  BEGIN
                        SET @vcTipoDati= ' NVARCHAR('+cast(@sidztLunghezza AS VARCHAR(10))+') '
                        SET @vcNomeTabVatValori=' VALORIATTRIBUTI_NVARCHAR '
                        SET @sidztLunghezza=2*@sidztLunghezza
                     END
            ELSE IF @itidTipoMem=5
                      BEGIN
                        SET @vcTipoDati=' DATETIME '
                        SET @vcNomeTabVatValori= ' ValoriAttributi_Datetime '
                        SET @sidztLunghezza=8
                     END
            ELSE IF @itidTipoMem=6 --OR  @itidTipoMem=8
                    BEGIN
                        SET @vcTipoDati=' INT '
                        SET @vcNomeTabVatValori=' VALORIATTRIBUTI_DESCRIZIONI '
                        SET @vcNomeCampovatvalore='vatIdDsc'
                        SET @sidztLunghezza=4
                     END
            ELSE IF @itidTipoMem=7
                    BEGIN
                        SET @vcTipoDati=' INT '
                        SET @vcNomeTabVatValori=' VALORIATTRIBUTI_KEYS '
                        SET @sidztLunghezza=4
                     END
            ELSE IF @itidTipoMem=8
                     BEGIN
                        SET @vcTipoDati=  ' NVARCHAR('+cast(@sidztLunghezza AS VARCHAR(10))+') '
                        SET @vcNomeTabVatValori=' VALORIATTRIBUTI_NVARCHAR '
                        SET @sidztLunghezza=2*@sidztLunghezza
                     END
            ELSE IF @itidTipoMem=9
                     BEGIN
                        RAISERROR('Tipi dati non ammesso',16,1)
                        RETURN 99
                     END
            SET @iSizeIndex=@iSizeIndex+@sidztLunghezza
            IF @iSizeIndex>900 
                     BEGIN
                  RAISERROR('Errore: l''indice eccede la lunghezza massima consentita',16,1)
                  RETURN 99
                  END
            /*L'attributo viene inserito*/
            INSERT INTO AppartenenzaAttributi (apatIdDzt,apatIdApp,apatDeleted, apatUltimaMod, apatTabellaSpeciale, apatCampoSpeciale)
                       VALUES (@iIdDzt, 16, 0, GETDATE(), 'Articoli', @vcdztNome)
            --SET @iIdApAt= @@IDENTITY
            IF @@ERROR<>0 
                     BEGIN
                  RETURN 99
                  END
            -- CONTROLLO ESISTENZA COLONNA NELLA TABELLA
            IF NOT EXISTS (SELECT c.name FROM syscolumns c, sysobjects o 
                  WHERE o.name='Articoli' AND c.id=o.id AND c.name=@vcdztNome) 
                   BEGIN
                  SET @vcStringaSQL= 'ALTER TABLE [dbo].[Articoli] ADD ' +@vcdztNome + ' ' + @vcTipoDati+ ' NULL'
                  --aggiunta colonna @vcdztNome alla tabella Articoli
                  EXEC (@vcStringaSQL)
                  IF @@ERROR<>0 
                        BEGIN
                        RETURN 99
                        END
                  --inserimento massivo dati nella nuova colonna
                  ALTER TABLE Articoli disable TRIGGER Articoli_UltimaMod
                  SET @vcStringaSQL ='UPDATE Articoli SET ' + @vcdztNome + '= c.' + @vcNomeCampovatvalore
                        + ' FROM ValoriAttributi a, dfVatArt b, '+ @vcNomeTabVatValori 
                        + ' c WHERE Articoli.IdArt=b.IdArt AND a.IdVat=b.IdVat AND a.IdVat=c.Idvat AND a.vatIdDzt=' + cast(@iIdDzt      as VARCHAR(10))
                  EXEC (@vcStringaSQL)
                  
                  IF @@ERROR<>0 
                        BEGIN
                        RETURN 99
                        END
                  ALTER TABLE Articoli enable TRIGGER Articoli_UltimaMod
                  END            
         END
      ELSE
         BEGIN
            /* L'ATTRIBUTO _ OBBLIGATORIO*/
            /*controllo size della colonna e dell'indice*/
            SELECT @sidztLunghezza=c.length 
              FROM syscolumns c, sysobjects t 
             WHERE t.name='Articoli' 
               AND c.id=t.id 
               AND c.name=@vcdztCampoSpeciale
            IF @sidztLunghezza IS NULL
               BEGIN
                  RAISERROR('Errore: colonna obbligatoria non esistente nella tabella Articoli',16,1)
                  RETURN 99
               END
            SET @iSizeIndex=@iSizeIndex+@sidztLunghezza
            IF @iSizeIndex>900 
                     BEGIN
                  RAISERROR('Errore: l''indice eccede la size massima consentita',16,1)
                  RETURN 99
                  END
            /*L'attributo viene inserito in appartenenzaattributi ma il suo nome _ dztCampoSpeciale*/
            INSERT INTO AppartenenzaAttributi (apatIdDzt,apatIdApp,apatDeleted, apatUltimaMod, apatTabellaSpeciale, apatCampoSpeciale)
                       VALUES (@iIdDzt, 16, 0, GETDATE(), 'Articoli', @vcdztCampoSpeciale)
            --SET @iIdApAt= @@IDENTITY
            IF @@ERROR<>0 
                     BEGIN
                  RETURN 99
                  END
         END
      --eliminazione e ricreazione dell'indice IX_Articoli_APPKEY
      IF EXISTS (SELECT [name] FROM dbo.sysindexes WHERE name = 'IX_Articoli_APPKEY')
               DROP INDEX Articoli.IX_Articoli_APPKEY  
      /*IdArt _ cablato, gli altri vengono presi da AppartenenzaAttributi */
      --ottengo la stringa per ricreare l'indice 
      DECLARE curs CURSOR static FOR 
            SELECT DISTINCT apatCampoSpeciale
                  FROM appartenenzaattributi 
              WHERE apatDeleted=0
                  AND apatIdApp=16 
                  --AND apatTabellaSpeciale='Articoli'
      SET @vcIndice=''
      OPEN curs 
      FETCH NEXT FROM curs INTO @vcNomeCampoIndice
      WHILE @@FETCH_STATUS = 0
            BEGIN
               SET @vcIndice=@vcIndice+', ['+@vcNomeCampoIndice+']'
               FETCH NEXT FROM curs INTO @vcNomeCampoIndice
            END
      close curs
      deallocate curs
      SET @vcIndice='CREATE UNIQUE NONCLUSTERED INDEX [IX_Articoli_APPKEY] ON [dbo].[Articoli] (IdArt'+@vcIndice+') ON [PRIMARY]'
      EXEC (@vcIndice)
      IF @@ERROR<>0 
         BEGIN
            RETURN 99
         END            
   END
ELSE
   BEGIN         
      IF @vcdztTabellaSpeciale IS NULL AND @vcdztCampoSpeciale IS NULL
         BEGIN
            SET @vcdztCampoSpeciale=@vcdztNome
         END
      IF (@vcApatTabellaSpeciale<>'Articoli' OR @vcApatTabellaSpeciale IS NULL) 
         OR (@vcApatCampoSpeciale<>@vcdztCampoSpeciale OR @vcApatCampoSpeciale IS NULL)
         BEGIN
            UPDATE AppartenenzaAttributi 
               SET ApatTabellaSpeciale='Articoli', ApatCampoSpeciale=@vcdztCampoSpeciale
             WHERE IdApAt=@iIdApAt
            IF @@ERROR<>0 
               BEGIN
                  RETURN 99
               END      
         END
   END
      
--aggiorno valore in RegDefault.rdDefValue
DECLARE  @vcrdDefValue AS VARCHAR(2000)
SELECT @vcrdDefValue=rdDefValue FROM RegDefault WHERE  IdRd=@iIdRd
IF LEN(@vcrdDefValue)=0 
   BEGIN 
      SET @vcrdDefValue=@vcdztNome
   END
ELSE IF RIGHT(@vcrdDefValue,2)='#~' 
   BEGIN
      SET @vcrdDefValue=@vcrdDefValue+@vcdztNome
   END
ELSE
   BEGIN
      SET @vcrdDefValue= @vcrdDefValue+'#~'+@vcdztNome
   END
      
UPDATE RegDefault SET rdDefValue= @vcrdDefValue WHERE  IdRd=@iIdRd
IF @@ERROR<>0 
  BEGIN
      RETURN 99
  END


GO
