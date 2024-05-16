USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Caricamento_Catalogo]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
      Scopo:       Stored per il Caricamento Catalogo Prodotti da un file di testo
      Autore: Marranzini A.
      data:       27/02/2002
*/
CREATE PROCEDURE [dbo].[Caricamento_Catalogo] (@IdAzi AS INTeger, @FilePath AS NVARCHAR(1000), 
                  @MaxRows AS INTeger, @NumOfRows AS INTeger OUTPUT) 
As 
BEGIN
DECLARE @idums  AS INTeger       -- identificativo dell'unita di misura
DECLARE @iddsc  AS INTeger       -- identificativo della descrittiva
DECLARE @strUms AS VARCHAR (200) -- stringa che contiene l'unita di misura
DECLARE @cnt  AS INTeger  --conteggio numero elementi
--descrizioni
DECLARE @idtmp AS INTeger
DECLARE @dscTestoI AS NVARCHAR (2000)
DECLARE @dscTestoUK AS NVARCHAR (2000)
DECLARE @dscTestoE AS NVARCHAR (2000)
DECLARE @dscTestoFRA AS NVARCHAR (2000)
DECLARE @Count  AS INTeger
DECLARE @IdArt  AS INTeger
begin tran TrnInsCat
IF @MaxRows<=0 
      BEGIN
                 raiserror ('Errore impostare il numero massimo di righe',  16, 1)  
               rollback tran TrnInsCat
                   return
      END
set @NumOfRows=0
/***************** CREAZIONE TABELLE TEMPORANEE ****************/
--creazione tabella TempElabCatalogo
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[TempElabCatalogo]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[TempElabCatalogo]
CREATE TABLE [dbo].[TempElabCatalogo] (
      [IdTmp] [int] IDENTITY (1, 1) NOT NULL ,
      [Codice] [nvarchar] (30) NULL ,
      [ClassificazioneSP] [char] (10) NULL ,
      [DescrizioneI] [nvarchar] (300) NULL ,
      [DescrizioneUK] [nvarchar] (300) NULL ,
      [DescrizioneE] [nvarchar] (300) NULL ,
      [DescrizioneFRA] [nvarchar] (300) NULL ,
      [UnitaMisura] [nvarchar] (200) NULL ,
      [WebArticolo] [nvarchar] (600) NULL ,
      [QMO] [int] NULL,
      [IdDsc] [int] NULL ,
      [IdUms] [int] NULL ,
      [CspValue] [int] NULL 
) ON [PRIMARY]
ALTER TABLE [dbo].[TempElabCatalogo] WITH NOCHECK ADD 
      CONSTRAINT [PK_TempElabCatalogo] PRIMARY KEY  NONCLUSTERED 
      (
            [IdTmp]
      )  ON [PRIMARY] 
CREATE  UNIQUE  INDEX [IX_TempElabCatalogo] ON [dbo].[TempElabCatalogo]([IdTmp]) ON [PRIMARY]  
CREATE  NONCLUSTERED INDEX IX_TempElabCatalogo_Classificazionesp on TempElabCatalogo (Classificazionesp)
CREATE NONCLUSTERED INDEX IX_TempElabCatalogo_Codice on TempElabCatalogo (Codice)
CREATE NONCLUSTERED INDEX IX_TempElabCatalogo_UnitaMisura on TempElabCatalogo (UnitaMisura) 
/********* creazione tabella temporanea ang_articoli */
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[ang_articoli]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ang_articoli]
CREATE TABLE [dbo].[ang_articoli] (
      [Codice] [nvarchar] (30) NULL ,
      [ClassificazioneSP] [char] (10) NULL ,
      [DescrizioneI] [nvarchar] (300) NULL ,
      [DescrizioneUK] [nvarchar] (300) NULL ,
      [DescrizioneE] [nvarchar] (300) NULL ,
      [DescrizioneFRA] [nvarchar] (300) NULL ,
      [QMO] [int] NULL,
      [UnitaMisura] [nvarchar] (200) NULL ,
      [WebArticolo] [nvarchar] (600) NULL ,
) ON [PRIMARY]
-- Creazione tabella  temporanea mik_descsi
IF exists (SELECT * FROM sysobjects WHERE id = object_id(N'[dbo].[mik_descsi]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
   begin
            DROP TABLE dbo.mik_descsi
   end
CREATE TABLE dbo.mik_descsi
(
   iddsc INT not NULL,
   dsctesto NVARCHAR(900) not NULL
)
/********* CONTROLLO ESISTENZA CATALOGO PRODOTTI *************/
SELECT  @IdArt = a.IdArt
  FROM articoli a,  descsi c 
 WHERE a.artidazi = @idazi AND a.artdeleted=0
   AND a.artiddscdescrizione = c.iddsc  
   AND c.dsctesto = 'articolo dimostrativo (da cancellare contestualmente all''inserimento della tabella prodotti dell''azienda)'
IF @@rowcount <> 0
   begin
         update Articoli set artDeleted = 1 
          WHERE IdArt = @IdArt
     
         IF @@error <> 0
            begin
                   raiserror ('Errore "Update" Articolo Fittizio',  16, 1)  
               rollback tran TrnInsCat
                   return
            end
       
   end
set @Count = 0
SELECT  @Count = count (*) FROM articoli a WHERE a.artidazi = @idazi AND a.artdeleted=0
IF @Count <> 0
   begin
        raiserror ('Catalogo esistente',  16, 1) 
      rollback tran TrnInsCat
      return
   end
--caricamento descrittive nella tabella temporanea mik_descsi
insert INTo mik_descsi (iddsc,dsctesto)
SELECT iddsc,dsctesto
FROM descsi di inner join  (SELECT distinct artiddscdescrizione FROM articoli) a
on di.iddsc = a.artiddscdescrizione
IF @@error<>0 
   begin
        raiserror ('Errore (Insert) mik_descsi',  16, 1) 
      rollback tran TrnInsCat
      return
   end
CREATE unique nonclustered index IX_mik_descsi_iddsc on mik_descsi (iddsc)
CREATE nonclustered index IX_mik_descsi_dsctesto on mik_descsi (dsctesto)
--caricamento dati nella tabella temporanea ang_articoli
--il delimitatore di campo F il tab  '\t'
--sulla prima riga c'F il nome delle colonne quindi firstrow = 2
DECLARE @StrExec AS NVARCHAR(1000)
set @StrExec = 'bulk insert dbo.ang_articoli FROM ''' + @FilePath +''' with 
    (
           fieldterminator = ''\t'', 
           firstrow = 2, 
      lastrow = ' + cast((@MaxRows+1) AS VARCHAR(100)) +')'
exec (@StrExec)
         IF @@error <> 0
            begin 
                  raiserror ('Errore (Bulk Insert) ang_articoli', 16, 1)
                  rollback tran TrnInsCat
                  return
            end
--cancellazione dal catalogo delle righe con codice NULLo
delete FROM ang_articoli  WHERE Codice IS NULL
IF @@error<>0
   begin
                  raiserror ('Errore (Delete) ang_articoli',  16, 1) 
                  rollback tran TrnInsCat
                  return
   end
DECLARE @NumOfRowsTemp AS INTeger
SELECT @NumOfRowsTemp=count(*) FROM ang_articoli 
IF @NumOfRowsTemp=0 begin
                  raiserror ('Errore (Bulk Insert) controllare il file',  16, 1) 
                  rollback tran TrnInsCat
              set @NumOfRows = @NumOfRowsTemp
                  return
end
--trasferimento articoli da ang_articoli a tempelabcatalogo
insert INTo tempelabcatalogo (Codice, ClassificazioneSP, DescrizioneI, DescrizioneUK, DescrizioneE, DescrizioneFRA, UnitaMisura, WebArticolo, QMO) 
SELECT Codice, ClassificazioneSP, DescrizioneI, DescrizioneUK, DescrizioneE, DescrizioneFRA, UnitaMisura, WebArticolo, QMO FROM ang_articoli
IF @@error<>0
   begin
                  raiserror ('Errore (Insert) TempElabCatalogo',  16, 1)  
                  rollback tran TrnInsCat
                  return
   end
DECLARE tmpcrs cursor static for SELECT distinct UnitaMisura FROM TempElabCatalogo
open tmpcrs
fetch next FROM tmpcrs INTo @strUms
while @@fetch_status = 0
begin
  
   set @strUms = ltrim(rtrim(@strUms))
   set @iddsc = NULL
--ricavo la descrittiva dell'unita di misura
   SELECT @iddsc = iddsc 
     FROM descsi, UnitaMisura
    WHERE dsctesto like @strUms
     AND (IdDsc = umsIdDscnome or IdDsc = umsIdDscSimbolo)
-- se la descrittiva non F stata trovata
--PRIMA veniva assegnata idums=97 che equivale a 'Non disponibile'
--ORA da un msg di errore
   IF @iddsc IS NULL
      begin
         /*update TempElabCatalogo set idums = 97
           WHERE UnitaMisura = @strUms
         IF @@error <> 0
            begin 
                  raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                  rollback tran TrnInsCat
                  return
            end*/
                  raiserror ('Errore l''unita di misura non F disponibile', 16, 1)
                  rollback tran TrnInsCat
              close tmpcrs
              deallocate tmpcrs
                  return
      end
   ELSE
      begin  
          set @idums = NULL
          SELECT @idums = idums FROM UnitaMisura WHERE umsIdDscNome = @iddsc or umsIdDscSimbolo = @iddsc
          IF @idums = NULL  --ho trovato la descrittiva ma non ho trovato l'unita di misura o il suo simbolo
             begin
                  --set @idums = 97 -- viene assegnata idums=97 che equivale a 'Non disponibile'
                  raiserror ('Errore l''unita di misura non F stata specificata', 16, 1)
                  rollback tran TrnInsCat
              close tmpcrs
              deallocate tmpcrs
                  return
             end 
          
          update TempElabCatalogo set idums = @idums
            WHERE UnitaMisura = @strUms
          IF @@error <> 0
             begin 
                   raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                   rollback tran TrnInsCat
              close tmpcrs
              deallocate tmpcrs
                   return
             end
             
      end
   fetch next FROM tmpcrs INTo @strUms
end
close tmpcrs
deallocate tmpcrs
/*
    Classificazione SP
*/
DECLARE @cspcode  AS char(10)
DECLARE @cspvalue AS INTeger
DECLARE tmpcrs cursor static for SELECT distinct ClassificazioneSP FROM TempElabCatalogo
open tmpcrs
fetch next FROM tmpcrs INTo @cspcode
while @@fetch_status = 0
begin
   IF @cspcode IS NULL
      begin
         update TempElabCatalogo set cspvalue = 0
           WHERE classificazionesp IS NULL
          IF @@error <> 0
             begin 
                   raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                   rollback tran TrnInsCat
                  close tmpcrs
               deallocate tmpcrs
                   return
             end
      end
   ELSE
      begin
          set @cspvalue = NULL  
         SELECT @cspvalue = cast(dgcodiceinterno AS INT) FROM dominigerarchici  
        WHERE dgcodiceesterno = @cspcode AND dgtipogerarchia = 16 AND dgDeleted=0
          IF @cspvalue IS NULL
              begin
                     update TempElabCatalogo set cspvalue = 0
                      WHERE classificazionesp = @cspcode
                     IF @@error <> 0
                        begin 
                             raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                             rollback tran TrnInsCat
                       close tmpcrs
                       deallocate tmpcrs
                             return
                        end
              end
          ELSE
              begin
                     update TempElabCatalogo set cspvalue = @cspvalue
                      WHERE classificazionesp = @cspcode
                     IF @@error <> 0
                        begin 
                             raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                             rollback tran TrnInsCat
                        close tmpcrs
                        deallocate tmpcrs
                             return
                        end
              end
   end
   fetch next FROM tmpcrs INTo @cspcode
end
close tmpcrs
deallocate tmpcrs
/*
    Descrizioni
*/
--Disabilita Trigger su descsx 
alter table descsi disable trigger DescI_UltimaMod
alter table descse disable trigger DescsE_UltimaMod
alter table descsuk disable trigger DescUk_Ultimamod
alter table descsfra disable trigger Descfra_Ultimamod
--Disabilita Trigger su articoli 
alter table articoli disable trigger Articoli_UltimaMod
DECLARE tmpcrs cursor static for SELECT IdTmp, DescrizioneI, DescrizioneUK, DescrizioneE , DescrizioneFRA FROM TempElabCatalogo
open tmpcrs
fetch next FROM tmpcrs INTo @idtmp, @dscTestoI, @dscTestoUK, @dscTestoE, @dscTestoFRA
while @@fetch_status = 0
begin
   set @iddsc = NULL  
   SELECT @iddsc = iddsc FROM mik_descsi WHERE dsctesto = @dsctestoI
   IF @iddsc IS NULL
      begin
          insert INTo DescsI (dscTesto,dscultimamod)
            values (@dscTestoI,GETDATE())
          IF @@error <> 0
             begin 
                  raiserror ('Errore (Insert) DescsI', 16, 1)
                  rollback tran TrnInsCat
            close tmpcrs
            deallocate tmpcrs
                  return
             end
        set @iddsc = @@identity                       --<<<
          insert INTo descsUK (iddsc,dsctesto,dscultimamod) values (@iddsc,@dsctestoUK,GETDATE())          
        IF @@error <> 0
             begin 
                  raiserror ('Errore (Insert) DescsUK', 16, 1)
                  rollback tran TrnInsCat
            close tmpcrs
            deallocate tmpcrs
                  return
             end
          insert INTo descsE (iddsc,dscTesto,dscultimamod)
            values (@iddsc,@dscTestoE,GETDATE())
          IF @@error <> 0
             begin 
                  raiserror ('Errore (Insert) DescsE', 16, 1)
                  rollback tran TrnInsCat
            close tmpcrs
            deallocate tmpcrs
                  return
             end
          insert INTo descsFRA (iddsc,dscTesto,dscultimamod)
            values (@iddsc, @dscTestoFRA,GETDATE())
          IF @@error <> 0
             begin 
                  raiserror ('Errore (Insert) DescsFRA', 16, 1)
                  rollback tran TrnInsCat
                  return
             end
         update TempElabCatalogo set iddsc = @iddsc
           WHERE IdTmp =  @IdTmp
          IF @@error <> 0
             begin 
                   raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                   rollback tran TrnInsCat
            close tmpcrs
            deallocate tmpcrs
                   return
             end
            
      end
   ELSE
      begin
         update TempElabCatalogo set iddsc = @iddsc
           WHERE IdTmp =  @IdTmp
          IF @@error <> 0
             begin 
                   raiserror ('Errore (Update) TempElabCatalogo', 16, 1)
                   rollback tran TrnInsCat
            close tmpcrs
            deallocate tmpcrs
                   return
             end
      end
    fetch next FROM tmpcrs INTo @idtmp, @dscTestoI, @dscTestoUK, @dscTestoE, @dscTestoFRA
end
close tmpcrs
deallocate tmpcrs
/*
     Insert Tab Articoli
*/
insert INTo articoli (artIdAzi, artCspValue, artCode, artIdDscDescrizione, artIdUms, artQMO, artSitoWeb, artUltimaMod )
SELECT @idazi, CspValue, Codice, IdDsc, IdUms, QMO, WebArticolo, GETDATE()
FROM TempElabCatalogo        
IF @@error <> 0
    begin 
          raiserror ('Errore (Insert) Articoli', 16, 1)
          rollback tran TrnInsCat
          return
   end
--Abilita trigger  descsx
alter table descsi enable trigger DescI_UltimaMod
alter table descse enable trigger DescsE_UltimaMod 
alter table descsuk enable trigger DescUk_Ultimamod
alter table descsfra enable trigger Descfra_Ultimamod
--Abilita trigger articoli 
alter table articoli enable trigger Articoli_UltimaMod
IF EXISTS(SELECT name 
        FROM        sysobjects 
        WHERE  name = N'mik_descsi' 
        AND        type = 'U')
    DROP TABLE mik_descsi
IF EXISTS(SELECT name 
        FROM        sysobjects 
        WHERE  name = N'ang_articoli' 
        AND        type = 'U')
    DROP TABLE ang_articoli
SELECT @NumOfRows=count(*) FROM TempElabCatalogo 
commit tran TrnInsCat
END


GO
