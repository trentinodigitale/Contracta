USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteAttribFromArticleKey]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Marranzini Angelica
Scopo:       Chiave Articoli: elimina un attributo opzionale come colonna della tabella articoli e 
      ricrea l'indice IX_Articoli_APPKEY
      NOTA L'unico attributo che non deve essere censito nell'appartenenzaattributi _ IdArt (viene cablato da codice) 
      ATTENZIONE: per il corretto funzionamento della presente Stored Procedure  
                occorre che il tipo di appartenenza 16 sia giO censito nella tabella Appartenenza
Data:        01/07/2002
*/
CREATE PROCEDURE [dbo].[DeleteAttribFromArticleKey] (
            @iIdRd INT,
            @vcdztNome VARCHAR(50)
)    AS   
DECLARE @iIdDzt             AS INT         /*id dell'attributo*/
DECLARE @vcDztTabellaSpeciale        AS VARCHAR(40)      /*colonna Tabella speciale nel dizionarioattributi*/
DECLARE @vcDztCampoSpeciale        AS VARCHAR(40)  /*colonna Campo speciale nel dizionarioattributi*/
DECLARE @vcIndice             AS VARCHAR(4000)
DECLARE @vcNomeCampoIndice      AS VARCHAR(30)
DECLARE @vcAlter             AS VARCHAR(4000)
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
SELECT @iIdDzt=IdDzt, @vcdztTabellaSpeciale=dztTabellaSpeciale , @vcdztCampoSpeciale=dztCampoSpeciale
  FROM DizionarioAttributi 
 WHERE dztNome=@vcdztNome
   AND dztDeleted=0
--controllo esistenza attributo
IF @iIdDzt IS NULL 
   BEGIN
       RAISERROR('Errore: Attributo non trovato nel DizionarioAttributi',16,1)
      RETURN 99
   END
DECLARE @iCount AS INT
SELECT @iCount=count(*) 
  FROM (
      SELECT IdRd, '#~' + rdDefValue + '#~' AS DefValue, rdkey FROM RegDefault 
       WHERE   rdDeleted=0 
         AND (rdKey = 'AttribKeyForInsertCatalog' OR rdKey = 'AttribKeyForInsertCatalogMP')
           AND IdRd<>@iIdRd) v
 WHERE v.DefValue LIKE '%#~'+@vcdztNome+'#~%'
--eliminazione attributo da regdefault.rddefvalue
DECLARE @vcNewDefValue AS  VARCHAR(2000)
SELECT @vcNewDefValue = '#~'+rdDefValue+'#~' FROM RegDefault
WHERE IdRd=@iIdRd
  AND LEN(rdDefValue)>0
SET @vcNewDefValue=Replace(@vcNewDefValue,'#~'+@vcdztNome+'#~','#~')
IF @vcNewDefValue<>'#~'
   BEGIN
      SET @vcNewDefValue=SubString(@vcNewDefValue,3, len(@vcNewDefValue)-4)
   END
ELSE
   BEGIN
      SET @vcNewDefValue=NULL
   END
UPDATE RegDefault SET rdDefValue= @vcNewDefValue WHERE IdRd=@iIdRd
      IF @@ERROR<>0 
            BEGIN
            RETURN 99
            END
IF @iCount=0       /*l'attributo non _ utilizzato in nessun'altra chiave*/
   BEGIN 
            UPDATE AppartenenzaAttributi
               SET apatDeleted=1 
             WHERE apatIddzt=@iIdDzt
               AND apatIdApp=16
               AND apatDeleted=0
            IF @@ERROR<>0 
                  BEGIN
                  RETURN 99
                     END
            --eliminazione e ricreazione dell'indice IX_Articoli_APPKEY
            IF EXISTS (SELECT [name] FROM dbo.sysindexes WHERE name = 'IX_Articoli_APPKEY')
               BEGIN
                     DROP INDEX Articoli.IX_Articoli_APPKEY  
               END
            IF @@ERROR<>0 
                  BEGIN
                  RETURN 99
                     END
            /*IdArt _ cablato, gli altri vengono presi da AppartenenzaAttributi */
      
            --ottengo la stringa per ricreare l'indice 
            DECLARE curs CURSOR STATIC FOR 
                  SELECT DISTINCT apatCampoSpeciale
                        FROM appartenenzaattributi 
                    WHERE apatDeleted=0
                        AND apatIdApp=16 
      
            OPEN curs 
            FETCH NEXT FROM curs INTO @vcNomeCampoIndice
            WHILE @@FETCH_STATUS = 0
                  BEGIN
                     SET @vcIndice=@vcIndice+', ['+@vcNomeCampoIndice+']'
                     FETCH NEXT FROM curs INTO @vcNomeCampoIndice
                  END
            close curs
            deallocate curs
      /*controllo non obbligatorietO attributo*/
      IF @vcDztTabellaSpeciale IS NULL AND @vcDztCampoSpeciale IS NULL 
         BEGIN       /*attributo non obbligatorio, quindi posso droppare la colonna*/
            -- CONTROLLO ESISTENZA COLONNA NELLA TABELLA
            IF  EXISTS (SELECT c.name FROM syscolumns c, sysobjects o 
                  WHERE o.name='Articoli' AND c.id=o.id AND c.name=@vcdztNome) 
                   BEGIN
                  SET @vcAlter='ALTER TABLE dbo.Articoli DROP COLUMN [' + @vcdztNome +']'
                  EXEC (@vcAlter)
                  IF @@ERROR<>0 
                        BEGIN
                        RETURN 99
                           END
               END
         END
            SET @vcIndice='CREATE UNIQUE NONCLUSTERED INDEX [IX_Articoli_APPKEY] ON [dbo].[Articoli] (IdArt'+@vcIndice+') ON [PRIMARY]'
            EXEC (@vcIndice)
            IF @@ERROR<>0 
                  BEGIN
                  RETURN 99
                     END
   END


GO
