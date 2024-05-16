USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteArticleKey]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Autore: Marranzini Angelica
Scopo:       Chiave Articoli: elimina gli attributi opzionali della tabella articoli che si trovano 
      nella RegDefault con IdRd=@iIdRd e ricrea l'indice IX_Articoli_APPKEY
      NOTA L'unico attributo che non deve essere censito nell'appartenenzaattributi _ IdArt (viene cablato da codice) 
      ATTENZIONE: per il corretto funzionamento della presente Stored Procedure  
                occorre che il tipo di appartenenza 16 sia giO censito nella tabella Appartenenza
Data:        01/07/2002
*/
CREATE PROCEDURE [dbo].[DeleteArticleKey] (@iIdRd INT)    AS   
DECLARE @iIdDzt             AS INT         /*id dell'attributo*/
DECLARE @vcDztTabellaSpeciale        AS VARCHAR(40)      /*colonna Tabella speciale nel dizionarioattributi*/
DECLARE @vcDztCampoSpeciale        AS VARCHAR(40)  /*colonna Campo speciale nel dizionarioattributi*/
DECLARE @vcIndice             AS VARCHAR(4000)
DECLARE @vcdztNome             AS VARCHAR(50)
DECLARE @vcRdDefValue            AS VARCHAR(2000)
DECLARE @iPos                   AS INT         /*posizione del separatore */
DECLARE @iCount             AS INT
SET @vcdztNome=''
SET @vcIndice=''
SET @vcrdDefValue=''
--controllo esistenza @iIdRd in Regdefault
IF NOT EXISTS (SELECT IdRd FROM RegDefault 
            WHERE IdRd=@iIdRd AND rdDeleted=0 
               AND (rdKey = 'AttribKeyForInsertCatalog' OR rdKey = 'AttribKeyForInsertCatalogMP')) 
   BEGIN
       RAISERROR('Errore: Chiave RegDefault non trovata',16,1)
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
SELECT @vcrdDefValue=rdDefValue+'#~' 
  FROM RegDefault 
 WHERE IdRd=@iIdRd AND rdDeleted=0
   AND (rdKey = 'AttribKeyForInsertCatalog' OR rdKey = 'AttribKeyForInsertCatalogMP')
--scompattamento stringa @vcrdDefValue
WHILE @vcrdDefValue<>'' AND @vcrdDefValue<>'#~'
BEGIN
      SET @iPos = PATINDEX('%#~%', @vcrdDefValue)
      SET @vcdztNome = left (@vcrdDefValue, @iPos - 1) -- Estrazione dell'attributo
      SET @vcrdDefValue = substring(@vcrdDefValue, @iPos + 2, len(@vcrdDefValue)- @iPos)  --riduzione della stringa degli attributi
      -- recupero valori dell'id dell'attributo, tabella speciale e campo speciale
      SELECT @iIdDzt=IdDzt, @vcdztTabellaSpeciale=dztTabellaSpeciale , @vcdztCampoSpeciale=dztCampoSpeciale
        FROM DizionarioAttributi 
       WHERE dztNome=@vcdztNome
         AND dztDeleted=0
      --controllo esistenza attributo
      IF @iIdDzt is not NULL 
         BEGIN
            /*controllo se utilizzato in altre chiavi*/
            SELECT @iCount=count(*) 
              FROM (
                  SELECT IdRd, '#~' + rdDefValue + '#~' AS DefValue, rdkey FROM RegDefault 
                   WHERE   rdDeleted=0 
                     AND (rdKey = 'AttribKeyForInsertCatalog' OR rdKey = 'AttribKeyForInsertCatalogMP')
                       AND IdRd<>@iIdRd) v
             WHERE v.DefValue LIKE '%#~'+@vcdztNome+'#~%'
            IF @iCount=0   /*non _ utilizzato in nessun'altra chiave*/
               BEGIN
                   UPDATE AppartenenzaAttributi
                     SET apatDeleted=1
                   WHERE apatIdDzt=@iIdDzt
                     AND apatDeleted=0 
                     AND apatIdApp=16
                  IF @@ERROR<>0 
                        BEGIN
                        RETURN 99
                        END
            
                  /*controllo non obbligatorietO attributo*/
                  IF @vcDztTabellaSpeciale IS NULL AND @vcDztCampoSpeciale IS NULL 
                     BEGIN       /*attributo non obbligatorio, quindi posso droppare la colonna*/
                        -- CONTROLLO ESISTENZA COLONNA NELLA TABELLA
                        IF  EXISTS (SELECT c.name FROM syscolumns c, sysobjects o 
                              WHERE o.name='Articoli' AND c.id=o.id AND c.name=@vcdztNome) 
                                   BEGIN
                              SET @vcIndice='ALTER TABLE [dbo].[Articoli] DROP COLUMN [' + @vcdztNome +']'
                              EXEC (@vcIndice)
                              IF @@ERROR<>0 
                                     BEGIN
                                    RETURN 99
                                       END
                           END
                     END
               END
         END
END
-- ricreazione dell'indice IX_Articoli_APPKEY
/*IdArt _ cablato, gli altri vengono presi da AppartenenzaAttributi */
--ottengo la stringa per ricreare l'indice 
DECLARE curs CURSOR static FOR 
      SELECT DISTINCT apatCampoSpeciale
                   FROM appartenenzaattributi 
               WHERE apatDeleted=0
                   AND apatIdApp=16 
OPEN curs 
set @vcIndice=''
FETCH NEXT FROM curs INTO @vcdztNome
WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @vcIndice=@vcIndice+', ['+@vcdztNome+']'
         FETCH NEXT FROM curs INTO @vcdztNome
      END
close curs
deallocate curs
SET @vcIndice='CREATE UNIQUE NONCLUSTERED INDEX [IX_Articoli_APPKEY] ON [dbo].[Articoli] (IdArt'+@vcIndice+') ON [PRIMARY]'
print @vcIndice
EXEC (@vcIndice)
IF @@ERROR<>0 
   BEGIN
      RETURN 99
   END
--cancellazione logica chiave regdefault
UPDATE RegDefault SET rdDeleted=1
 WHERE IdRd=@iIdRd
IF @@ERROR<>0 
   BEGIN
      RETURN 99
   END


GO
