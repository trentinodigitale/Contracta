USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetDati]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetDati] (@strAttributi AS VARCHAR(1000), @CodiceAppartenenza  AS INTeger, @Nome_Colonna AS VARCHAR(30)) 
as
/*
   Corpo della stored Procedure
*/
DECLARE @Attributo          AS VARCHAR(10)
DECLARE @IdDzt              AS INT
DECLARE @Pos                AS INTeger
DECLARE @Cnt                AS INTeger
DECLARE @Rows               AS INTeger
DECLARE @SQLCommand         AS VARCHAR(4000)
DECLARE @strAttributiTemp   AS VARCHAR(4000)
DECLARE @TipoMem            AS smallint
DECLARE @Chiave             AS VARCHAR(100)
DECLARE @vatValore          AS NVARCHAR(100)
--DECLARE @vatValoreFloat     AS float
DECLARE @NomeTabella        AS VARCHAR(30)
DECLARE @DataElab           AS VARCHAR(8)
DECLARE @SQLDropTable       AS VARCHAR(1000)
DECLARE @SQLUpdateTable     AS VARCHAR(1000)      
DECLARE @SQLRenameTable     AS VARCHAR(1000)
DECLARE @sqlcommand1        AS VARCHAR(1000)
set @NomeTabella      = ''
set @Cnt              = 0
set @Pos              = 0
set @SQLCommand       = ''
set @strAttributiTemp = @strAttributi
while @strAttributiTemp <> ''
begin
    set @Cnt = @Cnt + 1
  
   
    set @Pos                = charindex('#', @strAttributiTemp)
    set @Attributo          = left (@strAttributiTemp, @Pos - 1)
    set @IdDzt              = cast (@Attributo AS INT)
    set @Attributo          = @IdDzt + 10000
    set @strAttributiTemp   = substring(@strAttributiTemp, @Pos + 1, len(@strAttributiTemp)- @Pos)
    SELECT @TipoMem = td.tidTipoMem
      FROM DizionarioAttributi dz 
     inner join TipiDati td
        on dz.dztIdTid = td.IdTid
     WHERE dz.IdDzt = @IdDzt
    IF @@rowcount = 0
       begin
             raiserror ('Attributo [%d] non trovato in DizionarioAttributi', 16, 1, @IdDzt) 
             return (99)
       end
    IF  @TipoMem = 1
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' INT'                                        
            END   
    IF  @TipoMem = 2
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' float'                                        
            END   
    IF  @TipoMem = 3
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' float'                                        
            END   
    IF  @TipoMem = 4
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' VARCHAR(100)'                                        
            END   
    IF  @TipoMem = 5
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' INT'
            END   
    IF  @TipoMem = 6
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' INT'                                        
            END   
    IF  @TipoMem = 7 
            BEGIN
                  set @SQLCommand = @SQLCommand + ',Attr_'+@Attributo + ' INT'
            END       
      
    set @DataElab = replace (convert(varchar(10),GETDATE(),102),'.','')
                
       
end
IF @CodiceAppartenenza = 1000
                        BEGIN
                            set @NomeTabella = 'AZI_DATI_' + @DataElab
                           set @SQLCommand = 'CREATE TABLE AZI_DATI_' + @DataElab + ' (Chiave INT' + @SQLCommand + ')'
                           --Creazione indice sulla tabella AZI_DATI_.....
                           set @SQLCommand1 = 'Create Unique NonClustered index '+ 'AZI_DATI_INDX_' + @DataElab +' on '+'AZI_DATI_'+@DataElab+' ('+'Chiave'+')'                                    
                        END
IF @CodiceAppartenenza = 2000
                        BEGIN
                           set @NomeTabella = 'ART_DATI_' + @DataElab
                           set @SQLCommand  = 'CREATE TABLE ART_DATI_' + @DataElab + ' (Chiave INT' + @SQLCommand +')'
                           --Creazione indice sulla tabella ART_DATI_......
                              set @SQLCommand1 = 'Create Unique NonClustered index '+ 'ART_DATI_INDX_' + @DataElab +' on '+'ART_DATI_'+@DataElab+' ('+'Chiave'+')'      
                        END 
set @SQLDropTable = ''
set @SQLDropTable ='IF exists (SELECT * FROM sysobjects WHERE name = ' + '''' + @NomeTabella + '''' + ' AND xtype= ''u'')' + 'Drop table ' + @NomeTabella
execute  (@SQLDropTable)
execute  (@SQLCommand)
execute  (@SQLCommand1)
--goto on_pippo
set @strAttributiTemp = @strAttributi
while @strAttributiTemp <> ''
begin
   
      set @Pos              = charindex('#', @strAttributiTemp)
      set @Attributo        = left (@strAttributiTemp, @Pos - 1)
      set @IdDzt            = cast (@Attributo AS INT)
      set @Attributo        = @IdDzt + 10000
      set @strAttributiTemp = substring(@strAttributiTemp, @Pos + 1, len(@strAttributiTemp)- @Pos)
                 
      SELECT top 1 @TipoMem = vatTipoMem
        FROM ValoriAttributi 
       WHERE vatIdDzt = @IdDzt
      IF @@rowcount = 0 
          continue
      IF @CodiceAppartenenza = 1000
         begin
               IF @TipoMem = 1
                        DECLARE crs cursor static for SELECT a.IdAzi, cast(b.vatValore AS INT)
                                                 FROM DFVatAzi a, ValoriAttributi_int b, ValoriAttributi c
                                                 WHERE a.IdVat = c.IdVat
                                                 AND a.IdVat = b.IdVat
                                                 AND c.vatIdDzt =  @IdDzt
               ELSE
               IF @TipoMem = 2
                        --DECLARE crs cursor for SELECT a.IdAzi, cast(b.vatValore AS VARCHAR(100))
                        --                         FROM DFVatAzi a, ValoriAttributi_money b, ValoriAttributi c
                        --                         WHERE a.IdVat = c.IdVat
                        --                         AND a.IdVat = b.IdVat
                        --                         AND c.vatIdDzt =   @IdDzt
              DECLARE crs cursor static for SELECT a.idazi,convert(varchar(100),(SELECT (convert(float,convert(float,(b.vatvalore) / case
                                                     when c.vatidums <> 15 then (SELECT top 1 convert(float,s.sdvcambio)
                                                                   FROM storicodivise s
                                                                       WHERE /*b.idvat = c.idvat and*/ c.vatidums = s.sdvidums
                                                                       ORDER BY sdvdata desc) 
                                              ELSE 1
                                           end))) AS 'b.vatvalore'),2)
                  FROM dfvatazi a,valoriattributi c,valoriattributi_money b
            WHERE a.idvat = c.idvat
            AND a.idvat = b.idvat
            AND c.vatiddzt = @iddzt
                  
               ELSE
               IF @TipoMem = 3
                        DECLARE crs cursor static for SELECT a.IdAzi, cast(b.vatValore AS float)
                                                 FROM DFVatAzi a, ValoriAttributi_float b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 4
                        DECLARE crs cursor static for SELECT a.IdAzi, cast(b.vatValore AS NVARCHAR(100))
                                                 FROM DFVatAzi a, ValoriAttributi_nvarchar b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 5
                  DECLARE crs cursor static for SELECT a.IdAzi, cast(replace (convert (varchar(10), b.vatValore, 120), '-', '') AS INT)
                                                 FROM DFVatAzi a, ValoriAttributi_Datetime b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 6
                        DECLARE crs cursor static for SELECT a.IdAzi, cast(b.vatIdDsc AS INT)
                                                 FROM DFVatAzi a, ValoriAttributi_Descrizioni b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt 
               ELSE
               IF @TipoMem = 7
                        DECLARE crs cursor static for SELECT a.IdAzi, cast(b.vatValore AS INT)
                                                 FROM DFVatAzi a, ValoriAttributi_Keys b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =  @IdDzt
         end
      ELSE
      IF @CodiceAppartenenza = 2000
         begin
               IF @TipoMem = 1
                        DECLARE crs cursor static for SELECT a.IdArt, cast(b.vatValore AS INT)
                                                 FROM DFVatArt a, ValoriAttributi_int b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 2
                        --DECLARE crs cursor for SELECT a.IdArt, cast(b.vatValore AS float)
                        --                         FROM DFVatArt a, ValoriAttributi_money b, ValoriAttributi c
                        --                        WHERE a.IdVat = c.IdVat
                        --                          AND a.IdVat = b.IdVat
                        --                          AND c.vatIdDzt =   @IdDzt
                  DECLARE crs cursor static for SELECT a.idart,convert(varchar(100),(SELECT (convert(float,convert(float,(b.vatvalore) / case
                                                           when c.vatidums <> 15 then (SELECT top 1 convert(float,s.sdvcambio)
                                                                       FROM storicodivise s
                                                                             WHERE /*b.idvat = c.idvat and*/ c.vatidums = s.sdvidums
                                                                             ORDER BY sdvdata desc) 
                                                                 ELSE 1
                                                      end))) AS 'b.vatvalore'),2)
                                                 FROM dfvatart a,valoriattributi c,valoriattributi_money b
                                                WHERE a.idvat = c.idvat
                                                      AND a.idvat = b.idvat
                                                    AND c.vatiddzt = @iddzt
               ELSE
               IF @TipoMem = 3
                        DECLARE crs cursor static for SELECT a.IdArt, cast(b.vatValore AS float)
                                                 FROM DFVatArt a, ValoriAttributi_float b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 4
                        DECLARE crs cursor static for SELECT a.IdArt, cast(b.vatValore AS NVARCHAR(100))
                                                 FROM DFVatArt a, ValoriAttributi_nvarchar b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =  @IdDzt
               ELSE
               IF @TipoMem = 5
                        DECLARE crs cursor static for SELECT a.IdArt, cast(replace (convert (varchar(10), b.vatValore, 120), '-', '') AS INT)
                                                 FROM DFVatArt a, ValoriAttributi_Datetime b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 6
                        DECLARE crs cursor static for SELECT a.IdArt, cast(b.vatIdDsc AS INT)
                                                 FROM DFVatArt a, ValoriAttributi_Descrizioni b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
               ELSE
               IF @TipoMem = 7
                        DECLARE crs cursor static for SELECT a.IdArt, cast(b.vatValore AS INT)
                                                 FROM DFVatArt a, ValoriAttributi_Keys b, ValoriAttributi c
                                                WHERE a.IdVat = c.IdVat
                                                  AND a.IdVat = b.IdVat
                                                  AND c.vatIdDzt =   @IdDzt
         end
      ELSE
         begin
              raiserror ('Appartenenza [%d] non gestita dalla procedura', 16, 1, @CodiceAppartenenza) 
              return (99)
         end
     open crs
     fetch next FROM crs INTo @Chiave, @vatValore
     while @@fetch_status = 0
     begin
       set @SQLUpdateTable = ''      
       IF @CodiceAppartenenza = 1000 
            begin      
            set @SQLUpdateTable = 'IF exists (SELECT Chiave FROM ' + @NomeTabella + ' WHERE chiave = ' + @Chiave + ')' + 
                              ' Update ' + @NomeTabella + ' set Attr_' + @Attributo + ' = ' + @vatvalore + 
                                      ' WHERE Chiave = ' + @chiave +
                                      ' ELSE Insert INTo ' + @NomeTabella + ' (Chiave,Attr_' + @Attributo + ')' + 
                                      ' values' + '(' + @chiave + ',' + @vatvalore + ')' 
            end
       IF @CodiceAppartenenza = 2000
            begin
                set @SQLUpdateTable = 'IF exists (SELECT Chiave FROM ' + @NomeTabella + ' WHERE chiave = ' + @Chiave + ')' + 
                                      ' Update ' + @NomeTabella + ' set Attr_' + @Attributo +  ' = ' + @vatvalore + 
                                      ' WHERE Chiave = ' + @chiave +
                                      ' ELSE Insert INTo ' + @NomeTabella + ' (Chiave,Attr_' + @Attributo + ')' + 
                                      ' values' + '(' + @chiave + ',' + @vatvalore + ')' 
            end      
         exec (@SQLUpdateTable)
         fetch next FROM crs INTo @Chiave, @vatValore
     end
                   
     close crs
     deallocate crs       
     
      
end
    --Codice per droppare l'indice inizia qui
    DECLARE @var_drop_index VARCHAR(1000)
    IF @codiceappartenenza = 1000
                            BEGIN
                                  set @var_drop_index = 'IF exists (SELECT name FROM sysindexes WHERE name = '+' '''+'AZI_DATI_INDX_'+@DataElab+''''+')'+' Drop Index '+@Nometabella+'.'+'AZI_DATI_INDX_'+@DataElab                
                        END
                  ELSE
                        BEGIN
                              set @var_drop_index = 'IF exists (SELECT name FROM sysindexes WHERE name = '+' '''+'ART_DATI_INDX_'+@DataElab+''''+')'+' Drop Index '+@nometabella+'.'+'ART_DATI_INDX_'+@DataElab                
                        END
    --PRINT @VAR_DROP_INDEX
    execute (@var_drop_index)
    --termina qui 
    --on_pippo:
    
    set @SQLRenameTable = 'exec sp_rename ' + '''' + @NomeTabella + '.' + 'Chiave' + '''' + ',' + ''''+
                           @Nome_Colonna + '''' + ',' + '''Column'''
--    print @SQLRenameTable 
    execute (@SQLRenameTable)


GO
