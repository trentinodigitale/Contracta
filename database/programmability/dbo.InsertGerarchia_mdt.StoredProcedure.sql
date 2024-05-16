USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[InsertGerarchia_mdt]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Autore : Alfano Antonio
Scopo: Inserimento massivo DominiGerarchici
Data: 20020528
*/
CREATE PROCEDURE [dbo].[InsertGerarchia_mdt] (@dgCodiceInternoPadre VARCHAR(20),@tidNome char(101), @strLingue VARCHAR(100), @pathMDB NVARCHAR(4000), @MaxRow INT, @ErrCust INT OUTPUT)  AS 
DECLARE @iLoop INT --utilizzato per la consistenza dei dati gerarchici,forza il ciclo di caricamento dei record nel caso di loop
DECLARE @CI INT --codice INTerno nodo virtuale
DECLARE @IdTid INT --id tipo dato
DECLARE @CurNode VARCHAR(20) --nodo corrente
DECLARE @RefNode VARCHAR(20) --nodo padre
/* descrizioni del nodo*/
DECLARE @I NVARCHAR(255)
DECLARE @FRA NVARCHAR(255)
DECLARE @UK NVARCHAR(255)
DECLARE @E NVARCHAR(255)
/* lingue opzionali */
DECLARE @Lng1 NVARCHAR(255)
DECLARE @Lng2 NVARCHAR(255)
DECLARE @Lng3 NVARCHAR(255)
DECLARE @Lng4 NVARCHAR(255)
DECLARE @dgCodiceInterno INT --codice INTerno
DECLARE @RC INT --valore ritorno sp insertElemGerarchia
DECLARE @CodiceInternoPadre VARCHAR(20) --codice INTerno padre
DECLARE @CodiceEsternoNew VARCHAR(20) --codice esterno
DECLARE @strDescs NVARCHAR(4000) --concatenzione stringa decsrizioni
--init 
set @ErrCust=0
set @iLoop=0
--apertura transazione
begin tran InsertGer
/* CREAZIONE TABELLA PER IL CARICAMENTO DAL mdb*/
IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[Hierarchy]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Hierarchy]
CREATE TABLE [dbo].[Hierarchy] (
      [CurNode] [varchar] (20) NOT NULL ,
      [RefNode] [varchar] (20) NOT NULL ,
      [I] [nvarchar] (255) NULL ,
      [UK] [nvarchar] (255) NULL ,
      [FRA] [nvarchar] (255) NULL ,
      [E] [nvarchar] (255) NULL ,
      [Lng1] [nvarchar] (255) NULL ,
      [Lng2] [nvarchar] (255) NULL ,
      [Lng3] [nvarchar] (255) NULL ,
      [Lng4] [nvarchar] (255) NULL 
) ON [PRIMARY]
--caricamento valori gerarchici
exec('insert INTo Hierarchy(CurNode,RefNode,I,UK,FRA,E,Lng1,Lng2,Lng3,Lng4)
      SELECT ''A''+CurNode,''A''+isnull(RefNode, ''''),isNULL(I,''not value''),isNULL(UK,''not value''),isNULL(FRA,''not value''),isNULL(E,''not value''),isNULL(Lng1,''not value''),isNULL(Lng2,''not value''),isNULL(Lng3,''not value''),isNULL(Lng4,''not value'') 
      FROM TempHye')
IF @@error<>0      
 begin
      rollback tran InsertGer
        return 99
 end
--selezione IdTid
SELECT @IdTid=IdTid FROM TipiDati
WHERE tidNome=@tidNome AND tidDeleted=0
/* Controllo esistenza valore!!!*/
IF @IdTid IS NULL      
 begin
      set @ErrCust=5
        --raiserror ('Errore Tipo dato inesistente ', 16, 1) 
        rollback tran InsertGer
        return 0
 end
--controllo numero massimo di righe
IF (SELECT count(*) FROM Hierarchy) > @MaxRow       
 begin                  
      set @ErrCust=1
        drop table [dbo].[Hierarchy]
        rollback tran InsertGer                        
        --raiserror ('Errore numero di righe (InsertGerarchia) ', 16, 1) 
        return 0
 end
/*
Controllo valori duplicati
*/
IF exists(SELECT CurNode,RefNode FROM Hierarchy group by CurNode,RefNode having count(*)>1)      
 begin
      set @ErrCust=2
      drop table [dbo].[Hierarchy]
      rollback tran InsertGer
      --raiserror ('Errore nodo Duplicati(InsertGerarchia) ', 16, 1) 
      return 0
 end
--esistenza nodo padre
IF not exists(SELECT * FROM DominiGerarchici WHERE dgTipoGerarchia=@IdTid AND dgCodiceInterno=@dgCodiceInternoPadre AND dgDeleted=0)
 begin
      drop table [dbo].[Hierarchy]
       set @ErrCust=3
       --raiserror ('Errore nodo virtuale non presente(InsertGerarchia) ', 16, 1) 
       rollback tran InsertGer
       return 0
 end
alter table DominiGerarchici disable trigger DominiGerarchici_UltimaMod
alter table descsI disable trigger DescI_UltimaMod
alter table descsUK disable trigger DescUK_UltimaMod
alter table descsFRA disable trigger DescFRA_UltimaMod
alter table descsE disable trigger DescsE_UltimaMod
alter table descsLng1 disable trigger DescLng1_UltimaMod
alter table descsLng2 disable trigger DescLng2_UltimaMod
alter table descsLng3 disable trigger DescLng3_UltimaMod
alter table descsLng4 disable trigger DescLng4_UltimaMod
--nodi radice!!!
DECLARE crsDoc CURSOR static 
   FOR  SELECT CurNode,RefNode,I,UK,FRA,E,Lng1,Lng2,Lng3,Lng4 FROM Hierarchy
      WHERE RefNode='A' ORDER BY CurNode
OPEN crsDoc
FETCH NEXT FROM crsDoc 
INTO @CurNode,@RefNode,@I,@UK,@FRA,@E,@Lng1,@Lng2,@Lng3,@Lng4
IF @@FETCH_STATUS <> 0      
 begin
      drop table [dbo].[Hierarchy]
      set @ErrCust=6
      alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
      alter table descsI enable trigger DescI_UltimaMod
      alter table descsUK enable trigger DescUK_UltimaMod
      alter table descsFRA enable trigger DescFRA_UltimaMod
      alter table descsE enable trigger DescsE_UltimaMod
      alter table descsLng1 enable trigger DescLng1_UltimaMod
      alter table descsLng2 enable trigger DescLng2_UltimaMod
      alter table descsLng3 enable trigger DescLng3_UltimaMod
      alter table descsLng4 enable trigger DescLng4_UltimaMod
      CLOSE crsDoc
      DEALLOCATE crsDoc
      
      --raiserror ('Errore nessun nodo padre presente', 16, 1) 
      rollback tran InsertGer
      return 0
 end
WHILE @@FETCH_STATUS = 0
 BEGIN
      set @iLoop=@iLoop+1
      set @CodiceInternoPadre=@dgCodiceInternoPadre
      set @CodiceEsternoNew=substring(@CurNode,2,len(@CurNode)-1)
      set @strDescs=@strLingue
      set @strDescs=replace(@strDescs,'#~UK#~','#~'+@UK+'#~')
      set @strDescs=replace(@strDescs,'#~I#~','#~'+@I+'#~')
      set @strDescs=replace(@strDescs,'#~FRA#~','#~'+@FRA+'#~')
      set @strDescs=replace(@strDescs,'#~E#~','#~'+@E+'#~')
      set @strDescs=replace(@strDescs,'#~Lng1#~','#~'+@Lng1+'#~')
      set @strDescs=replace(@strDescs,'#~Lng2#~','#~'+@Lng2+'#~')
      set @strDescs=replace(@strDescs,'#~Lng3#~','#~'+@Lng3+'#~')
      set @strDescs=replace(@strDescs,'#~Lng4#~','#~'+@Lng4+'#~')
      EXEC @RC = [dbo].[InsertElemGerarchia] @IdTid, @CodiceInternoPadre, @CodiceEsternoNew, @strLingue, @strDescs
      IF @RC<>0      
       begin
            drop table [dbo].[Hierarchy]
            set @ErrCust=4
            alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
            alter table descsI enable trigger DescI_UltimaMod
            alter table descsUK enable trigger DescUK_UltimaMod
            alter table descsFRA enable trigger DescFRA_UltimaMod
            alter table descsE enable trigger DescsE_UltimaMod
            alter table descsLng1 enable trigger DescLng1_UltimaMod
            alter table descsLng2 enable trigger DescLng2_UltimaMod
            alter table descsLng3 enable trigger DescLng3_UltimaMod
            alter table descsLng4 enable trigger DescLng4_UltimaMod
            CLOSE crsDoc
            DEALLOCATE crsDoc
      
            --raiserror ('Errore SP InsertElemGerarchia(InsertGerarchia) ', 16, 1) 
            rollback tran InsertGer
            return 0
       end
      SELECT @dgCodiceInterno=max(cast(dgCodiceInterno AS INT)) FROM DominiGerarchici
      WHERE dgTipoGerarchia=@IdTid AND ISNUMERIC(dgCodiceInterno)=1
      --rIF alla DG
      update Hierarchy
      set RefNode= @dgCodiceInterno
      WHERE RefNode=@CurNode
      IF @@error<>0      
       begin
            drop table [dbo].[Hierarchy]
            alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
            alter table descsI enable trigger DescI_UltimaMod
            alter table descsUK enable trigger DescUK_UltimaMod
            alter table descsFRA enable trigger DescFRA_UltimaMod
            alter table descsE enable trigger DescsE_UltimaMod
            alter table descsLng1 enable trigger DescLng1_UltimaMod
            alter table descsLng2 enable trigger DescLng2_UltimaMod
            alter table descsLng3 enable trigger DescLng3_UltimaMod
            alter table descsLng4 enable trigger DescLng4_UltimaMod
            CLOSE crsDoc
            DEALLOCATE crsDoc
            rollback tran InsertGer
            return 99
       end
      FETCH NEXT FROM crsDoc 
      INTO @CurNode,@RefNode,@I,@UK,@FRA,@E,@Lng1,@Lng2,@Lng3,@Lng4
 END
CLOSE crsDoc
DEALLOCATE crsDoc
delete FROM Hierarchy
WHERE RefNode='A'
IF @@error<>0      
 begin
      drop table [dbo].[Hierarchy]
      alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
      alter table descsI enable trigger DescI_UltimaMod
      alter table descsUK enable trigger DescUK_UltimaMod
      alter table descsFRA enable trigger DescFRA_UltimaMod
      alter table descsE enable trigger DescsE_UltimaMod
      alter table descsLng1 enable trigger DescLng1_UltimaMod
      alter table descsLng2 enable trigger DescLng2_UltimaMod
      alter table descsLng3 enable trigger DescLng3_UltimaMod
      alter table descsLng4 enable trigger DescLng4_UltimaMod
      rollback tran InsertGer
      return 99
 end
while exists(SELECT * FROM Hierarchy)      
 begin
      DECLARE crsDoc CURSOR static 
          FOR SELECT CurNode,RefNode,I,UK,FRA,E,Lng1,Lng2,Lng3,Lng4 FROM Hierarchy
            WHERE RefNode in (SELECT DgCodiceInterno FROM DominiGerarchici WHERE dgTipoGerarchia=@IdTid  AND ISNUMERIC(dgCodiceInterno)=1)
             ORDER BY CurNode
      OPEN crsDoc
      FETCH NEXT FROM crsDoc 
      INTO @CurNode,@RefNode,@I,@UK,@FRA,@E,@Lng1,@Lng2,@Lng3,@Lng4
      WHILE @@FETCH_STATUS = 0
       BEGIN
            set @CodiceInternoPadre=@RefNode   
            set @CodiceEsternoNew=substring(@CurNode,2,len(@CurNode)-1)
            set @strDescs=@strLingue
            set @strDescs=replace(@strDescs,'#~UK#~','#~'+@UK+'#~')
            set @strDescs=replace(@strDescs,'#~I#~','#~'+@I+'#~')
            set @strDescs=replace(@strDescs,'#~FRA#~','#~'+@FRA+'#~')
            set @strDescs=replace(@strDescs,'#~E#~','#~'+@E+'#~')
            set @strDescs=replace(@strDescs,'#~Lng1#~','#~'+@Lng1+'#~')
            set @strDescs=replace(@strDescs,'#~Lng2#~','#~'+@Lng2+'#~')
            set @strDescs=replace(@strDescs,'#~Lng3#~','#~'+@Lng3+'#~')
            set @strDescs=replace(@strDescs,'#~Lng4#~','#~'+@Lng4+'#~')
            EXEC @RC = [dbo].[InsertElemGerarchia] @IdTid, @CodiceInternoPadre, @CodiceEsternoNew, @strLingue, @strDescs
            IF @RC<>0      
             begin
                  set @ErrCust=4
                  drop table [dbo].[Hierarchy]
                  alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
                  alter table descsI enable trigger DescI_UltimaMod
                  alter table descsUK enable trigger DescUK_UltimaMod
                  alter table descsFRA enable trigger DescFRA_UltimaMod
                  alter table descsE enable trigger DescsE_UltimaMod
                  alter table descsLng1 enable trigger DescLng1_UltimaMod
                  alter table descsLng2 enable trigger DescLng2_UltimaMod
                  alter table descsLng3 enable trigger DescLng3_UltimaMod
                  alter table descsLng4 enable trigger DescLng4_UltimaMod
                  CLOSE crsDoc
                  DEALLOCATE crsDoc
                  --raiserror ('Errore SP InsertElemGerarchia(InsertGerarchia) ', 16, 1) 
                  rollback tran InsertGer
                  return 0
             end
            SELECT @dgCodiceInterno=max(cast(dgCodiceInterno AS INT)) FROM DominiGerarchici
            WHERE dgTipoGerarchia=@IdTid AND ISNUMERIC(dgCodiceInterno)=1
            --rIF alla DG
            update Hierarchy
            set RefNode=@dgCodiceInterno
            WHERE RefNode=@CurNode
            IF @@error<>0      
             begin
                  drop table [dbo].[Hierarchy]
                  alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
                  alter table descsI enable trigger DescI_UltimaMod
                  alter table descsUK enable trigger DescUK_UltimaMod
                  alter table descsFRA enable trigger DescFRA_UltimaMod
                  alter table descsE enable trigger DescsE_UltimaMod
                  alter table descsLng1 enable trigger DescLng1_UltimaMod
                  alter table descsLng2 enable trigger DescLng2_UltimaMod
                  alter table descsLng3 enable trigger DescLng3_UltimaMod
                  alter table descsLng4 enable trigger DescLng4_UltimaMod
                  CLOSE crsDoc
                  DEALLOCATE crsDoc
                  rollback tran InsertGer
                  return 99
             end
            delete FROM Hierarchy
            WHERE CurNode=@CurNode AND RefNode=@RefNode
            IF @@error<>0      
             begin
                  drop table [dbo].[Hierarchy]
                  alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
                  alter table descsI enable trigger DescI_UltimaMod
                  alter table descsUK enable trigger DescUK_UltimaMod
                  alter table descsFRA enable trigger DescFRA_UltimaMod
                  alter table descsE enable trigger DescsE_UltimaMod
                  alter table descsLng1 enable trigger DescLng1_UltimaMod
                  alter table descsLng2 enable trigger DescLng2_UltimaMod
                  alter table descsLng3 enable trigger DescLng3_UltimaMod
                  alter table descsLng4 enable trigger DescLng4_UltimaMod
                  CLOSE crsDoc
                  DEALLOCATE crsDoc
                  rollback tran InsertGer
                  return 99
             end
            FETCH NEXT FROM crsDoc 
            INTO @CurNode,@RefNode,@I,@UK,@FRA,@E,@Lng1,@Lng2,@Lng3,@Lng4
       END
      CLOSE crsDoc
      DEALLOCATE crsDoc
      set @iLoop=@iLoop+1
      IF @iLoop>@MaxRow      
       begin      
      
            set @ErrCust=7
            drop table [dbo].[Hierarchy]
            alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
            alter table descsI enable trigger DescI_UltimaMod
            alter table descsUK enable trigger DescUK_UltimaMod
            alter table descsFRA enable trigger DescFRA_UltimaMod
            alter table descsE enable trigger DescsE_UltimaMod
            alter table descsLng1 enable trigger DescLng1_UltimaMod
            alter table descsLng2 enable trigger DescLng2_UltimaMod
            alter table descsLng3 enable trigger DescLng3_UltimaMod
            alter table descsLng4 enable trigger DescLng4_UltimaMod
            --raiserror ('Errore Gerarchia non consistente ', 16, 1) 
            rollback tran InsertGer
            return 0
       end
end
drop table [dbo].[Hierarchy]
alter table DominiGerarchici enable trigger DominiGerarchici_UltimaMod
alter table descsI enable trigger DescI_UltimaMod
alter table descsUK enable trigger DescUK_UltimaMod
alter table descsFRA enable trigger DescFRA_UltimaMod
alter table descsE enable trigger DescsE_UltimaMod
alter table descsLng1 enable trigger DescLng1_UltimaMod
alter table descsLng2 enable trigger DescLng2_UltimaMod
alter table descsLng3 enable trigger DescLng3_UltimaMod
alter table descsLng4 enable trigger DescLng4_UltimaMod
commit tran InsertGer



GO
