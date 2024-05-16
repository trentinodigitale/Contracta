USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[IsUsed]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IsUsed](@Id AS INT, @Tipo AS VARCHAR (5), @Valore AS NVARCHAR (4000), @Esito AS INT OUTPUT, @Nometabella AS VARCHAR(50) OUTPUT) --aggiungere un altro parametro out opzionale
as
DECLARE @TipoDom            AS VARCHAR (5)
DECLARE @TipoMem            AS tinyint
DECLARE @IdDzt              AS INTeger
DECLARE @dztTabellaSpeciale AS VARCHAR (4000)
DECLARE @dztCampoSpeciale   AS VARCHAR (4000)
DECLARE @SQLCommand         AS VARCHAR (8000)
set @Nometabella=NULL
set @Esito = 0
IF @Tipo='UsysV' 
   goto l_usysvalue
ELSE
IF @Tipo = 'CNT' 
   goto l_CountersValues
ELSE
IF @Tipo = 'CR' 
   goto l_CountersRules
ELSE
IF @Tipo = 'MD' 
   goto l_Modelli
ELSE
IF @Tipo = 'CN' 
   goto l_CastNumeric
ELSE
IF @Tipo = 'GA' 
   goto l_GerarchiaAttributi
ELSE
IF @Tipo = 'L' AND @id=-1
   goto l_Lingua
ELSE
IF @Tipo = 'T'
   goto l_TipoDato
ELSE
IF @Tipo = 'A'
   goto l_Attributo
ELSE
IF @Tipo = 'V'
   goto l_Valore
ELSE
IF @Tipo = 'G'
   goto l_Gruppi
ELSE
IF @Tipo = 'U'
   goto l_Unita
ELSE
IF @Tipo = 'GU'
   goto l_GU
ELSE
   begin
         raiserror ('Tipo controllo [%s] non gestito o valori errati (IsUsed)', 16, 1, @Tipo) 
         return
   end
-- modifiche per controllo usysvalues
l_usysvalue: 
DECLARE @usvValue AS VARCHAR(4000)   --usysvalues
DECLARE @usvIdUsc AS INT    --riferimento usyscolumns
DECLARE @uscTableName AS VARCHAR(100)  --nome tabella estratta
DECLARE @uscColumnName AS VARCHAR(100)  --nome colonna estratta
DECLARE @strsql AS VARCHAR(8000)    --stringa sql 
DECLARE @clmnDeleted AS VARCHAR(100)   --eventuale flag di cancellazione
--estrazione del valore e del riferimento
SELECT @usvValue=usvValue, @usvIdUsc=usvIdUsc FROM usysvalues WHERE IdUsv= @id 
IF @usvValue IS NULL 
begin
                     raiserror ('Valore inesistente [%d] (IsUsed)', 16, 1, @Id) 
                       return (99)
end
--estrazione nome tabella e colonna
SELECT @uscTableName=uscTableName, @uscColumnName=uscColumnName FROM usyscolumns 
WHERE IdUsc=@usvIdUsc
IF @uscTableName IS NULL 
begin
                     raiserror ('Dati inconsistenti (IsUsed)', 16, 1) 
                       return (99)
end
--estrazione eventuale flag di cancellazione
/*SELECT @clmnDeleted=c.name FROM sysobjects o, syscolumns c 
WHERE o.id=c.id   AND o.xtype='U' AND o.name=@uscTableName 
and (c.name like '%deleted%'  or c.name like '%cancellato%')
IF @clmnDeleted IS NULL 
      BEGIN 
            set @clmnDeleted=''
      END
ELSE
      BEGIN 
            set @clmnDeleted=' AND ' +@clmnDeleted +'=0'
      END
 --composizione stringa sql
set @strsql ='SELECT * FROM ' +@uscTableName +' WHERE ' + @uscColumnName +' = ' +@usvValue + @clmnDeleted */
set @strsql ='SELECT * FROM ' +@uscTableName +' WHERE ' + @uscColumnName +' = ''' +@usvValue+''''
exec(@strsql)
IF @@ROWCOUNT >0 
      BEGIN
            set @Esito=1
            set @Nometabella=@uscTableName
            return
      END
set @Esito = 0
return
--Modifiche x tabelle contatori
--valori dei contatori
l_CountersValues:
--esistenza del contatore
IF not exists(SELECT * FROM Counters WHERE IdCnt=@Id AND cntDeleted=0)      BEGIN
                                                         raiserror ('Contatore inesistente o gia cancellato  [%d] (IsUsed)', 16, 1, @Id) 
                                                           return (99)
                                                      END
--Verifica
IF exists(SELECT * FROM CountersValue WHERE cvIdCnt=@Id)            BEGIN
                                                      set @Esito = 1
                                                      set @Nometabella='CountersValue'
                                                      return
                                                      END
set @Esito = 0
return
--per le regole
l_CountersRules:
--Controllo esistenza regola
IF not exists(SELECT * FROM CountersRules WHERE IdCr=@Id AND crDeleted=0)      BEGIN
                                                               raiserror ('Regola inesistente o gia cancellato [%d] (IsUsed)', 16, 1, @Id) 
                                                                 return (99)
                                                            END
--Verifica
IF exists(SELECT * FROM Counters WHERE cntIdCr=@Id AND cntDeleted=0)            BEGIN
                                                            set @Esito = 1
                                                            set @Nometabella='Counters'
                                                            return
                                                            END
set @Esito = 0
return
l_Modelli:
DECLARE @cDoc INT --contatore  documenti
set @cDoc=0
DECLARE @IdMpMod INT
set @IdMpMod=NULL
set @Nometabella='0' 
SELECT @IdMpMod=docIdMpMod FROM MpDocumenti
WHERE IdDoc=@Id AND docDeleted=0
IF @IdMpMod IS NULL      BEGIN
                     raiserror ('Documento inesistente o gia cancellato [%d] (IsUsed)', 16, 1, @Id) 
                       return (99)
                  END
--esistenza di un altro documento legato al modello
/*IF exists(SELECT * FROM MpDocumenti WHERE IdDoc<>@Id AND docIdMpMod=@IdMpMod AND docDeleted=0)      BEGIN
set @Esito = 0
set @Nometabella='0' 
return
                              END
*/
--esistenza di un altro documento legato al modello
SELECT @cDoc=count(*) FROM MpDocumenti WHERE IdDoc<>@Id AND docIdMpMod=@IdMpMod AND docDeleted=0
IF @cDoc>0      BEGIN
            set @Esito = 0
            set @Nometabella=cast(@cDoc AS VARCHAR(4000))
            return
            END
--Modelli di tipo utente
IF exists(SELECT * FROM MpModelli WHERE IdMpMod=@IdMpMod AND mpmTipo=7 AND mpmDeleted=0 AND @IdMpMod in (SELECT pfuIdMpMod FROM profiliUtente WHERE pfuDeleted=0))      BEGIN
                                    set @Esito = 1
                                    set @Nometabella='ProfiliUtente'
                                    return
                                                                                                                              END
--Modelli di tipo filtro legato a modello di visualizzazione (mpmidmpmodvisual is not NULL) 
IF exists(SELECT * FROM MpModelli WHERE IdMpMod=@IdMpMod AND mpmTipo=5 AND mpmDeleted=0 AND mpmidmpmodvisual is not NULL)      BEGIN
                                    set @Esito = 1
                                    set @Nometabella='filtro collegato a visualizzazione' 
                                    return
                                                                                                                              END
--Modelli di tipo visualizzazione legato a modello di filtro (mpmidmpmodvisual = @IdMpMod) 
IF exists(SELECT * FROM MpModelli a,MpModelli b WHERE a.IdMpMod=@IdMpMod  AND a.mpmDeleted=0 AND b.mpmidmpmodvisual=@IdMpMod AND b.mpmDeleted=0 AND b.mpmTipo=5)            BEGIN
                                    set @Esito = 1
                                    set @Nometabella='MpModelli'
                                    return
                                                                                                                              END
set @Esito = 0
return
l_CastNumeric:
--controllo cast da alfanumerico a numerico
set @TipoMem=NULL
SELECT @TipoMem = tidTipoMem FROM TipiDati WHERE IdTid = @Id AND tidDeleted=0 AND tidTipoMem in (6,8)
  IF @TipoMem IS NULL  
     begin
           raiserror ('Tipo Dato [%d] non trovato in TipiDati o TipoMem diverso da 6 o da 8  (IsUsed)', 16, 1, @Id) 
           return
     end
IF @TipoMem=6      BEGIN
                  set @Esito = 0
                       return
            END
IF exists(SELECT * FROM TipiDatiRange WHERE tdrIdTid=@Id AND tdrDeleted=0 AND isNumeric(tdrCodice)=0) AND @TipoMem=8                   BEGIN
                                                                                                              set @Esito = 1
                                                                                                                 return
                                                                                                      END
set @Esito = 1
return
l_GerarchiaAttributi:
--verifica esistenza
IF not exists (SELECT * FROM MpgerarchiaAttributi WHERE IdMpGa=@id AND mpgaDeleted=0)                  BEGIN
                                                                                   raiserror ('Elemento [%d] non trovato in MpGerarchiaAttributi (IsUsed)', 16, 1, @Id) 
                                                                                   return
                                                                              END 
--F possibile cancellarlo se esiste e il Idmp<>0
/*IF exists (SELECT * FROM MpgerarchiaAttributi WHERE IdMpGa=@id AND mpgaDeleted=0 AND mpgaIdMp<>0)      BEGIN
                                                                              set @Esito = 0
                                                                              return
                                                                              END 
*/
--controllare se c'F almeno un record al primo livello con idmp=0 escluso quello corrente
IF (SELECT count(*) FROM  MpgerarchiaAttributi WHERE  IdMpga<>@id AND mpgaLivello=1 AND mpgaDeleted=0 
and mpgaContesto in (SELECT mpgaContesto FROM MpgerarchiaAttributi WHERE IdMpGa=@id AND mpgaDeleted=0) 
and  mpgaIdMp in (SELECT mpgaIdMp FROM MpgerarchiaAttributi WHERE IdMpGa=@id AND mpgaDeleted=0))>=1            
begin                                                                  set @Esito = 0
                                                                  return      
end 
set @Esito = 1
return
l_Lingua:
IF not exists (SELECT * FROM LingueAttivabili WHERE LaSuffix=@Valore)            BEGIN
         raiserror ('Lingua inesistente o non disattivabile [%s] (IsUsed)', 16, 1, @Valore) 
           return
                                                                  END
 DECLARE @IdLng AS INTeger 
 SELECT @IdLng=IdLng FROM Lingue WHERE LngSuffisso=@Valore AND LngDeleted=0
--lingua inesistente o gia disattivata 
  IF @IdLng IS NULL
     begin
         raiserror ('Lingua inesistente o gia disattivata [%s]  (IsUsed)', 16, 1, @Valore) 
           return
     end
  
 IF exists (SELECT * FROM marketplace WHERE mpIdLng=@IdLng AND mpDeleted=0)
     begin
           set @Esito = 1
           set @Nometabella='marketplace'
           return
     end
 IF exists (SELECT * FROM ProfiliUtente_Prospect WHERE pfuIdLng=@IdLng AND pfuDeleted=0)
     begin
           set @Esito = 1
           set @Nometabella='ProfiliUtente_Prospect'
           return
     end
 IF exists (SELECT * FROM ProfiliUtente WHERE pfuIdLng=@IdLng AND pfuDeleted=0)
     begin
           set @Esito = 1
           set @Nometabella='ProfiliUtente'
           return
     end
return
l_Gruppi:
--Provare l'esistenza dell'id in input
  IF not exists (SELECT * FROM GruppiUnitaMisura WHERE IdGum = @Id AND gumDeleted=0)
     begin
           raiserror ('Gruppo Unita di Misura [%d] non trovato in GruppiUnitaMisura (IsUsed)', 16, 1, @Id) 
           return
     end
--Controllori vari
--DizionarioAttributi
  IF exists (SELECT * FROM DizionarioAttributi WHERE dztIdGum = @Id AND dztDeleted=0)
     begin
           set @Esito = 1
           set @Nometabella='DizionarioAttributi'
           return
     end
--UnitaMisura
  IF exists (SELECT * FROM UnitaMisura WHERE umsIdGum = @Id AND umsDeleted=0)
     begin
           set @Esito = 1
         set @Nometabella='UnitaMisura'
           return
     end
  return
l_Unita:
--Provare l'esistenza dell'id in input
  IF not exists (SELECT * FROM UnitaMisura WHERE IdUms = @Id AND umsDeleted=0)
     begin
           raiserror ('Unita di Misura [%d] non trovata in UnitaMisura (IsUsed)', 16, 1, @Id) 
           return
     end
--Controllori vari
--DizionarioAttributi
  IF exists (SELECT * FROM DizionarioAttributi WHERE dztIdUmsDefault = @Id AND dztDeleted=0)
     begin
           set @Esito = 1
         set @Nometabella='DizionarioAttributi'
           return
     end
--Articoli
  IF exists (SELECT * FROM Articoli WHERE artIdUms = @Id AND artDeleted=0)
     begin
           set @Esito = 1
         set @Nometabella='Articoli'
           return
     end
--CodiciDivise
  IF exists (SELECT * FROM CodiciDivise WHERE cdvIdUms = @Id)
     begin
           set @Esito = 1
         set @Nometabella='CodiciDivise'
           return
     end
--MpModelliAttributi
  IF exists (SELECT * FROM MpModelliAttributi WHERE mpmaIdUmsDef=@Id AND mpmaDeleted=0)
     begin
           set @Esito = 1
         set @Nometabella='MpModelliAttributi'
           return
     end
--ValoriAttributi
  IF exists (SELECT * FROM ValoriAttributi WHERE vatIdUms=@Id )
     begin
           set @Esito = 1
           set @Nometabella='ValoriAttributi'
           return
     end
--TipiDatiRange
  IF exists (SELECT * FROM TipiDatiRange WHERE tdrIdTid in (SELECT IdTid FROM tipiDati WHERE tIdNome='SIMPLE_UM') AND tdrCodice=cast(@Id AS VARCHAR(20)) AND tdrDeleted=0)
     begin
           set @Esito = 1
           set @Nometabella='TipiDatiRange'
           return
     end
  return
l_GU:
--Provare l'esistenza dell'id in input
  IF not exists (SELECT * FROM UnitaMisura WHERE IdUms = @Id AND umsDeleted=0)
     begin
           raiserror ('Unita di Misura [%d] non trovata in UnitaMisura (IsUsed)', 16, 1, @Id) 
           return
     end
--Controllori vari
--DizionarioAttributi
  IF exists (SELECT * FROM DizionarioAttributi WHERE dztIdUmsDefault = @Id AND dztDeleted=0)
     begin
           set @Esito = 1
           set @Nometabella='DizionarioAttributi'
           return
     end
return
l_TipoDato:
set @TipoDom = NULL
  SELECT @TipoDom = tidTipoDom FROM TipiDati WHERE IdTid = @Id
  IF @TipoDom IS NULL
     begin
           raiserror ('Tipo Dato [%d] non trovato in TipiDati (IsUsed)', 16, 1, @Id) 
           return
     end
/* Controllo record nel caso di un dominio gerarchico */
  IF @TipoDom = 'G'
     begin
  IF  exists (SELECT * FROM DizionarioAttributi WHERE dztIdTid = @Id AND dztDeleted=0)
            or exists (SELECT * FROM MpDominiGerarchici WHERE mpdgTipo=@id AND mpdgDeleted=0)
    begin
           set @Esito = 1
           return
     end
     end
IF @TipoDom = 'C' or @TipoDom = 'A'
                  begin
  IF exists (SELECT * FROM DizionarioAttributi WHERE dztIdTid = @Id AND dztDeleted=0)
     begin
           set @Esito = 1
           return
     end
              end
  
  return
l_Attributo:
  IF not exists (SELECT * FROM DizionarioAttributi WHERE IdDzt = @Id)
     begin
           raiserror ('Attributo [%d] non trovato in DizionarioAttributi (IsUsed)', 16, 1, @Id) 
           return
     end
/* Controllo se l'attributo "mappa" una tabella speciale o F utilizzato nella ValoriAttributi */
  IF exists (SELECT * FROM DizionarioAttributi WHERE IdDzt = @Id AND dztTabellaSpeciale is not NULL AND dztDeleted=0)
     or exists (SELECT * FROM ValoriAttributi WHERE vatIdDzt = @Id)
     or exists (SELECT * FROM ModelliColonne WHERE mclIdDzt = @Id)
     or exists (SELECT * FROM MPAttributiControlli WHERE mpacIdDzt = @Id AND mpacDeleted=0)
     or exists (SELECT * FROM MPGerarchiaAttributi WHERE mpgaIdDzt = @Id AND mpgaDeleted=0)
     or exists (SELECT * FROM MPModelliAttributi WHERE mpmaIdDzt = @Id AND mpmaDeleted=0)
     or exists (SELECT * FROM SchemiAttributi WHERE satIdDzt = @Id)
    begin
           set @Esito = 1
           return
     end
/* Significa che l'attributo F mappato in una colonna nella tabella articoli   */
IF EXISTS(SELECT * FROM AppartenenzaAttributi WHERE apatIdApp=16 AND  apatIdDzt = @Id AND apatDeleted=0)
   BEGIN
        SET @Esito = 1
        RETURN
   END
  return
l_Valore:
  set @TipoDom = NULL
  SELECT @TipoDom = tidTipoDom, @TipoMem = tidTipoMem FROM TipiDati WHERE IdTid = @Id
  IF @TipoDom IS NULL
     begin
           raiserror ('Tipo Dato [%d] non trovato in TipiDati (IsUsed)', 16, 1, @Id) 
           return
     end
  IF @TipoDom = 'A'
     begin
           raiserror ('Tipo Dato [%d] di tipo aperto (IsUsed)', 16, 1, @Id) 
           return
     end
/* Controllo record nel caso di un dominio gerarchico */
  IF @TipoDom = 'G'
     begin
  IF  exists ( SELECT * FROM MpDominiGerarchici WHERE mpdgIdDg in (SELECT b.IdDg FROM DominiGerarchici a,DominiGerarchici b WHERE b.dgTipoGerarchia=@Id AND a.dgTipoGerarchia=@Id AND a.dgCodiceInterno=@Valore AND b.dgPath like a.dgPath+'%' AND a.dgDeleted=0 AND b.dgDeleted=0) AND mpdgDeleted=0)
    begin
           set @Esito = 1
           return
     end
     end
  DECLARE crs cursor static for SELECT IdDzt, dztTabellaSpeciale, dztCampoSpeciale 
                           FROM DizionarioAttributi
                          WHERE dztIdTid = @Id
  open crs
  fetch next FROM crs INTo @IdDzt, @dztTabellaSpeciale, @dztCampoSpeciale 
  while @@fetch_status = 0
  begin
       /* 
          Se l'attributo associato al tipo dato (@Id) passato in input "mappa" la colonna di una tabella       
          controllo se il valore passato in input F utilizzato. Per i domini gerarchici controllo anche se 
          venga utilizzato un figlio del valore passato in input
       */ 
       IF @dztTabellaSpeciale is not NULL
          begin
               IF @TipoDom = 'C'
                  begin
                        set @SQLCommand = 'SELECT top 1 ' + @dztCampoSpeciale + ' FROM ' + @dztTabellaSpeciale + 
                                          ' WHERE cast(' + @dztCampoSpeciale + ' AS VARCHAR(4000)) = ''' + @Valore + '''' 
                        exec (@sqlcommand)
                        IF @@rowcount <> 0
                           begin
                                set @Esito = 1
                                close crs
                                deallocate crs
                                return
                           end 
                  end
               ELSE
               IF @TipoDom = 'G'
                  begin
                        set @SQLCommand = 'SELECT top 1 ' + @dztCampoSpeciale + ' FROM ' + @dztTabellaSpeciale + 
                                          ' WHERE cast(' + @dztCampoSpeciale + ' AS VARCHAR(20)) in (SELECT a1.dgCodiceInterno ' +
                                ' FROM DominiGerarchici a, DominiGerarchici a1 ' +
                                          ' WHERE a.dgTipoGerarchia = ' + cast(@Id AS VARCHAR(10)) + 
                                          ' AND a1.dgTipoGerarchia =  ' + cast(@Id AS VARCHAR(10))  +
                                          ' AND a.dgCodiceInterno = ' + '''' + @Valore + '''' +
                                          ' AND a1.dgPath like a.dgPath + ''%''' +
                                          ' AND (a1.dgLivello = a.dgLivello + 1 or a1.dgLivello = a.dgLivello) ' +
                                          ' AND a1.dgDeleted = 0)'
                        exec (@sqlcommand)
                        IF @@rowcount <> 0
                           begin                                set @Esito = 1
                                close crs
                                deallocate crs
                                return
                           end 
                  end
          end
       ELSE
       /* 
          Controllo se il valore passato in input F utilizzato. Per i domini gerarchici controllo anche se 
          venga utilizzato un figlio del valore passato in input
       */ 
          begin
                IF @TipoMem = 4
                   begin
                        IF @TipoDom = 'C'
                           begin
                                IF exists (
                                           SELECT * 
                                             FROM ValoriAttributi a, ValoriAttributi_nvarchar b, DizionarioAttributi
                                            WHERE a.vatIdDzt = IdDzt
                                              AND a.IdVat = b.IdVat
                                              AND dztIdTid = @Id
                                              AND b.VatValore = @Valore
                                           )
                                    set @Esito = 1
                                    close crs
                                    deallocate crs
                                    return
                           end
                        ELSE
                           begin
                                IF exists (
                                           SELECT * 
                                             FROM ValoriAttributi a, ValoriAttributi_nvarchar b, DizionarioAttributi,
                                                  DominiGerarchici d, DominiGerarchici d1 
                                            WHERE a.vatIdDzt = IdDzt
                                              AND a.IdVat = b.IdVat
                                              AND dztIdTid = @Id
                                              AND b.VatValore = @Valore
                                              AND d.dgTipoGerarchia = @Id
                                              AND d1.dgTipoGerarchia = @Id
                                              AND d.dgCodiceInterno = @Valore
                                              AND d1.dgPath like d.dgPath + '%'
                                              AND (d1.dgLivello = d.dgLivello + 1 or d1.dgLivello = d.dgLivello)
                                              AND d1.dgDeleted = 0
                                           )
                                    set @Esito = 1
                                    close crs
                                    deallocate crs
                                    return
                           end
                   end
                ELSE
--inizio tipomem=8
                IF @TipoMem = 8
                   begin
                        IF @TipoDom = 'C'
                           begin
                                IF exists (
                                           SELECT * 
                                             FROM ValoriAttributi a, ValoriAttributi_nvarchar b, DizionarioAttributi
                                            WHERE a.vatIdDzt = IdDzt
                                              AND a.IdVat = b.IdVat
                                              AND dztIdTid = @Id
                                              AND b.VatValore = @Valore
                                           )
                                    set @Esito = 1
                                    close crs
                                    deallocate crs
                                    return
                           end
                        ELSE
                           begin
                                IF exists (
                                           SELECT * 
                                             FROM ValoriAttributi a, ValoriAttributi_nvarchar b, DizionarioAttributi,
                                                  DominiGerarchici d, DominiGerarchici d1 
                                            WHERE a.vatIdDzt = IdDzt
                                              AND a.IdVat = b.IdVat
                                              AND dztIdTid = @Id
                                              AND b.VatValore = @Valore
                                              AND d.dgTipoGerarchia = @Id
                                              AND d1.dgTipoGerarchia = @Id
                                              AND d.dgCodiceInterno = @Valore
                                              AND d1.dgPath like d.dgPath + '%'
                                              AND (d1.dgLivello = d.dgLivello + 1 or d1.dgLivello = d.dgLivello)
                                              AND d1.dgDeleted = 0
                                           )
                                    set @Esito = 1
                                    close crs
                                    deallocate crs
                                    return
                           end
                   end
                ELSE
--fine tipomem=8
                IF @TipoMem = 7
                   begin                        IF @TipoDom = 'C'
                           begin
                                IF exists (
                                           SELECT * 
                                             FROM ValoriAttributi a, ValoriAttributi_keys b, DizionarioAttributi
                                            WHERE a.vatIdDzt = IdDzt
                                              AND a.IdVat = b.IdVat
                                              AND dztIdTid = @Id
                                              AND cast (b.VatValore AS VARCHAR(4000)) = @Valore
                                           )
                                    set @Esito = 1
                                    close crs
                                    deallocate crs
                                    return
                          end
                        ELSE
                          begin
                                IF exists (
                                           SELECT * 
                                             FROM ValoriAttributi a, ValoriAttributi_keys b, DizionarioAttributi,
                                                  DominiGerarchici d, DominiGerarchici d1 
                                            WHERE a.vatIdDzt = IdDzt
                                              AND a.IdVat = b.IdVat
                                              AND dztIdTid = @Id
                                              AND cast(b.VatValore AS VARCHAR(4000)) = @Valore
                                              AND d.dgTipoGerarchia = @Id
                                              AND d1.dgTipoGerarchia = @Id
                                              AND d.dgCodiceInterno = @Valore
                                              AND d1.dgPath like d.dgPath + '%'
                                              AND (d1.dgLivello = d.dgLivello + 1 or d1.dgLivello = d.dgLivello)
                                              AND d1.dgDeleted = 0
                                           )
                                    set @Esito = 1
                                    close crs
                                    deallocate crs
                                    return
                          end
                   end
                ELSE
                   begin
                        IF @TipoMem = 6
                           begin
                                IF @TipoDom = 'C'
                                   begin
                              set @valore = cast(@valore AS INT)
                                        IF exists (
                                                   SELECT * 
                                                     FROM ValoriAttributi a, ValoriAttributi_Descrizioni b, DizionarioAttributi
                                                    WHERE a.vatIdDzt = IdDzt
                                                      AND a.IdVat = b.IdVat
                                                      AND dztIdTid = @Id
                                              AND b.vatIdDsc = @valore
                                                   )
                                            set @Esito = 1
                                            close crs
                                            deallocate crs
                                            return
                                  end
                           end
                   end
          end
       fetch next FROM crs INTo @IdDzt, @dztTabellaSpeciale, @dztCampoSpeciale 
  end
  
close crs 
deallocate crs


GO
